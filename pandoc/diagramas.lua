-- Convierte los bloques de código ```{.dot caption="…"} en figuras SVG
-- generadas con Graphviz (orden dot). Requiere dot en el PATH.
--
-- Cada bloque es un grafo de Graphviz válido, "digraph { … }", para que
-- también se pueda previsualizar en el editor: lleva rankdir=BT y los
-- valores por defecto node [...] y edge [weight=50], y coloca él
-- mismo las referencias. Las líneas node [...] del bloque se ignoran. Este filtro le añade el
-- estilo común y expande las macros. El historial se dibuja como en git
-- tree: el commit más reciente arriba y las referencias a la derecha de su
-- commit, como texto en color. Los nodos sin estilo son commits, y una
-- flecha "padre -> hijo" va del commit anterior al siguiente, en el orden
-- en que se crearon.
--
-- Si la etiqueta de un commit empieza por su hash abreviado (7 caracteres),
-- el hash se escribe en gris: c5 [label="5e7b3a2 Añade…"]. Solo
-- se pone cuando el texto del curso muestra ese hash.
--
-- Macros de estilo, con el atributo class de Graphviz:
--   main [class=rama]         rama local
--   o_main [class=remota label="origin/main"]   rama de seguimiento
--   HEAD [class=head]         HEAD
--   v010 [class=etiqueta label="v0.1.0"]        etiqueta (tag)
--   X [class=huerfano style="rounded,dashed" color=gray50 fontcolor=gray50]
--                             commit que no está en ninguna rama. El estilo
--                             explícito sólo sirve para la vista previa del
--                             editor; el filtro lo sustituye por el suyo
--   X [class=nota]            texto suelto, sin caja
--   repo [class=repo]         repositorio (diagramas de remotos)
--   z [class=zona]            recuadro rectangular que no es un commit
--                             (las zonas de Git: trabajo, staging…)
--   A -> B [class=huerfano style=dashed color=gray50]
--                             flecha hacia un commit huérfano
--   A -> A2 [class=copia]     A2 es una copia de A (cherry-pick, rebase)
--   { rank=same; C -> main -> HEAD [class=ref dir=back] }
--                             HEAD apunta a main, que apunta a C. La fila
--                             rank=same coloca las referencias en la fila de
--                             C, a su derecha y en el orden escrito; con
--                             dir=back las flechas apuntan hacia C.
--                             Para ponerlas a la izquierda:
--                             { rank=same; HEAD -> main -> C [class=ref dir=forward] }
--                             En un «antes y después», dentro de su cluster.
--   r [class=refs label="HEAD -> main, origin/main, v1.0.0"]
--                             varias referencias de un mismo commit, como en
--                             git tree, cada una en su color (HEAD, ramas,
--                             ramas remotas con "/" y etiquetas que empiezan
--                             por v y un número). Se une a su commit con una
--                             sola fila: { rank=same; C -> r [class=ref dir=back] }
--   A -> B [class=accion label="git push"]      flecha de una acción
-- Las macros admiten atributos adicionales: main [class=rama label="otra"].
-- Para que los commits de una rama queden en columna, dales el mismo
-- atributo group de Graphviz: c1 [label="…" group=develop].
-- Un «antes y después» se escribe con dos subgraph cluster_… { label="…" };
-- se apilan de arriba abajo en el orden en que se escriben.

local PREAMBULO = [[
  rankdir=BT;
  newrank=true;
  bgcolor="transparent";
  nodesep=0.18;
  ranksep=0.25;
  fontname="DejaVu Sans";
  fontsize=10;
  labelloc=b;
  style=rounded;
  color="#c5ced8";
  node [shape=box, style="rounded,filled", fillcolor="#e8eef6",
        color="#4a5b70", fontcolor="#1d2733", fontname="DejaVu Sans",
        fontsize=10, height=0.3, margin="0.1,0.04", penwidth=1.2];
  edge [weight=50, color="#4a5b70", arrowsize=0.6, penwidth=1.2,
        fontname="DejaVu Sans", fontsize=9];
]]

-- Las referencias son texto en negrita y en color, sin recuadro
local function referencia(color)
  return 'shape=plaintext, style="", margin="0.02,0", fontcolor="' .. color .. '"'
end

local COLORES = {
  rama = '#2e7d4f',
  remota = '#7a4fa3',
  head = '#d9822b',
  etiqueta = '#9a6b00',
}
local FLECHA = '#6b7785'

local MACROS = {
  rama = referencia(COLORES.rama),
  remota = referencia(COLORES.remota),
  head = referencia(COLORES.head),
  etiqueta = referencia(COLORES.etiqueta),
  huerfano = 'style="rounded,filled,dashed", fillcolor="#f2f2f2", color="#7b848e", fontcolor="#7b848e", penwidth=1.4',
  nota = 'shape=plaintext, style="", fontcolor="#4a5b70", fontsize=9',
  zona = 'shape=box, style="filled", fillcolor="white", color="#4a5b70", margin="0.15,0.08"',
  repo = 'shape=folder, style="filled", fillcolor="#e8eef6", height=0.5, margin="0.15,0.08"',
  copia = 'dir=forward, style=dashed, color="#9aa3ad", arrowhead=empty, constraint=false',
  accion = 'dir=forward, color="#4a5b70", fontcolor="#4a5b70"',
}
local REFERENCIAS = { rama = true, remota = true, head = true, etiqueta = true }
local COLOR_HASH = '#6b7785'
local REF = 'style=dashed, color="#6b7785", arrowhead=vee, arrowsize=0.5'
local HUERFANO_ARISTA = 'style=dashed, color="#9aa3ad"'

-- Sustituye "[class=macro ...]" por "[atributos ...]" en cada sentencia.
-- Las sentencias se separan con saltos de línea o con ";", así que las
-- etiquetas no pueden contener ";".
-- Busca label="…" en los atributos, respetando las comillas escapadas
-- (\"), y devuelve dónde empieza y acaba y su contenido sin las comillas
local function etiqueta(atributos)
  local ini, abre = atributos:find('label%s*=%s*"')
  if not ini then
    return nil
  end
  local i = abre + 1
  while i <= #atributos do
    local c = atributos:sub(i, i)
    if c == '\\' then
      i = i + 2
    elseif c == '"' then
      return ini, i, atributos:sub(abre + 1, i - 1)
    else
      i = i + 1
    end
  end
  return nil
end

local function expandir_sentencia(s, cluster)
  local inicio, atributos, fin = s:match('^(.-)%[(.-)%](.*)$')
  local macro = atributos and atributos:match('class%s*=%s*"?([%w_]+)"?')
  -- Los commits sin group se ponen en un grupo común (y los huérfanos en
  -- otro) para que los de una misma rama queden en la misma columna
  local id = s:match('^%s*([%w_]+)%s*%[.-%]%s*$')
  if id and id ~= 'node' and id ~= 'edge' and id ~= 'graph'
    and (not macro or macro == 'huerfano') and not atributos:find('group%s*=') then
    local grupo = (macro == 'huerfano' and 'huerfanos' or 'principal') .. cluster
    s = inicio .. '[' .. atributos .. ' group=' .. grupo .. ']' .. fin
    inicio, atributos, fin = s:match('^(.-)%[(.-)%](.*)$')
  end
  -- Un hash al principio de la etiqueta ("5e7b3a2 Añade…") se escribe en
  -- gris, como el que muestra git tree
  local ini, fin_etiqueta, valor = etiqueta(atributos or '')
  local hash, texto
  if valor then
    hash, texto = valor:match('^(%x%x%x%x%x%x%x) (.*)$')
  end
  if id and hash then
    texto = texto:gsub('\\"', '"'):gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'):gsub('\\n', '<BR/>')
    -- Dos celdas con separación fija: así el hueco no depende de cómo mida
    -- cada programa el ancho del texto
    local html = '<<TABLE BORDER="0" CELLBORDER="0" CELLSPACING="4" CELLPADDING="0"><TR>'
      .. '<TD><FONT COLOR="' .. COLOR_HASH .. '">' .. hash .. '</FONT></TD>'
      .. '<TD>' .. texto .. '</TD></TR></TABLE>>'
    atributos = atributos:sub(1, ini - 1) .. 'label=' .. html .. atributos:sub(fin_etiqueta + 1)
    -- Graphviz calcula algo corto el ancho de las etiquetas HTML: más margen
    s = inicio .. '[' .. atributos .. ', margin="0.12,0.02"]' .. fin
  end
  if not macro then
    return s
  end
  local resto = atributos:gsub('class%s*=%s*"?[%w_]+"?%s*,?', '', 1):match('^[%s,]*(.-)[%s,]*$')
  if macro == 'huerfano' then
    -- El bloque repite el estilo discontinuo para la vista previa del
    -- editor, que no conoce las macros; aquí manda el estilo del filtro
    for _, clave in ipairs({ 'style', 'color', 'fontcolor', 'fillcolor' }) do
      resto = resto:gsub('%f[%w]' .. clave .. '%s*=%s*"[^"]*"%s*,?', '')
        :gsub('%f[%w]' .. clave .. '%s*=%s*[%w#.]+%s*,?', '')
    end
    resto = resto:match('^[%s,]*(.-)[%s,]*$')
  end
  local extra = resto ~= '' and (', ' .. resto) or ''
  if macro == 'ref' then
    return inicio .. '[' .. REF .. extra .. ']' .. fin
  elseif macro == 'huerfano' and inicio:find('->') then
    return inicio .. '[' .. HUERFANO_ARISTA .. extra .. ']' .. fin
  elseif macro == 'refs' then
    -- Lista de referencias de un commit, como en git tree:
    -- "HEAD -> main, origin/main, v1.0.0". Cada una va en su color.
    local texto = resto:match('label%s*=%s*"(.-)"') or ''
    resto = resto:gsub('label%s*=%s*"[^"]*"%s*,?', '', 1):match('^[%s,]*(.-)[%s,]*$')
    extra = resto ~= '' and (', ' .. resto) or ''
    local partes = {}
    for ref in (texto .. ','):gmatch('%s*(.-)%s*,') do
      local html = ref:gsub('%s*%->%s*', ' → '):gsub('[^ →]+', function(nombre)
        local color = nombre == 'HEAD' and COLORES.head
          or nombre:match('^v%d') and COLORES.etiqueta
          or nombre:find('/') and COLORES.remota
          or COLORES.rama
        return '<FONT COLOR="' .. color .. '">' .. nombre .. '</FONT>'
      end)
      table.insert(partes, html)
    end
    return inicio .. '[' .. referencia(FLECHA) .. ', label=<<B>' .. table.concat(partes, ', ') .. '</B>>' .. extra .. ']' .. fin
  elseif REFERENCIAS[macro] then
    -- La negrita se pone con una etiqueta HTML: así se mantiene la fuente
    local texto = resto:match('label%s*=%s*"(.-)"') or inicio:match('^%s*(.-)%s*$')
    resto = resto:gsub('label%s*=%s*"[^"]*"%s*,?', '', 1):match('^[%s,]*(.-)[%s,]*$')
    extra = resto ~= '' and (', ' .. resto) or ''
    texto = texto:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;')
    return inicio .. '[' .. MACROS[macro] .. ', label=<<B>' .. texto .. '</B>>' .. extra .. ']' .. fin
  elseif MACROS[macro] then
    return inicio .. '[' .. MACROS[macro] .. extra .. ']' .. fin
  end
  return s
end

-- Apila los clusters de arriba abajo en el orden en que se escriben: una
-- flecha invisible lleva de las puntas de cada cluster (commits sin hijos)
-- al primer commit del anterior, que así queda encima.
local function apilar_clusters(originales)
  local clusters, actual = {}, nil
  for _, s in ipairs(originales) do
    local nombre = s:match('subgraph%s+(cluster[%w_]*)')
    if nombre then
      actual = { nodos = {}, con_hijos = {} }
      table.insert(clusters, actual)
    elseif actual then
      local id, atributos = s:match('^%s*([%w_]+)%s*%[(.-)%]%s*$')
      local clase = atributos and atributos:match('class%s*=%s*"?([%w_]+)"?')
      if id and id ~= 'node' and id ~= 'edge' and id ~= 'graph'
        and (not clase or clase == 'huerfano') then
        table.insert(actual.nodos, id)
      end
      local cadena = s:match('^([^%[]*)')
      if cadena:find('->') and not s:find('class%s*=%s*"?ref') then
        local nodos = {}
        for n in (cadena .. '->'):gmatch('(.-)%->') do
          table.insert(nodos, n:match('^%s*(.-)%s*$'))
        end
        for i = 1, #nodos - 1 do
          actual.con_hijos[nodos[i]] = true
        end
      end
    end
  end
  local salida = {}
  for i = 2, #clusters do
    local encima = clusters[i - 1].nodos[1]
    for _, n in ipairs(clusters[i].nodos) do
      if encima and not clusters[i].con_hijos[n] then
        table.insert(salida, n .. ' -> ' .. encima .. ' [style=invis, weight=0];')
      end
    end
  end
  return table.concat(salida, '\n')
end

local function expandir(cuerpo)
  local sentencias, originales, cluster = {}, {}, ''
  for linea in (cuerpo .. '\n'):gmatch('(.-)\r?\n') do
    for s in (linea .. ';'):gmatch('([^;]*);') do
      table.insert(originales, s)
      -- Los estilos por defecto del bloque (node [...]) solo sirven para la
      -- vista previa del editor: aquí manda el estilo común
      if s:match('^%s*node%s*%[') then
        s = ''
      end
      cluster = s:match('subgraph%s+(cluster[%w_]*)') or cluster
      s = expandir_sentencia(s, cluster)
      if s:find('%S') then
        -- Tras una llave de apertura no puede ir ";"
        table.insert(sentencias, s:find('{%s*$') and s or (s .. ';'))
      end
    end
  end
  -- Los «antes y después» solo se apilan en los historiales (de abajo arriba)
  local apilados = cuerpo:find('rankdir%s*=%s*"?BT') and apilar_clusters(originales) or ''
  return table.concat(sentencias, '\n') .. '\n' .. apilados
end

-- Ancho del texto en Word y en el PDF, en puntos. Las figuras más anchas
-- se reducen para que quepan.
local ANCHO_MAXIMO = 430

-- En la web (HTML), el SVG va dentro de la página: así no depende de
-- ficheros aparte y el CSS de la web lo puede adaptar al modo oscuro. Se
-- quitan la cabecera XML y los <title> (que Graphviz pone con el nombre
-- interno de cada nodo y el navegador mostraría al pasar el ratón), y los
-- id se prefijan con el hash del diagrama para que no se repitan entre los
-- diagramas de una misma página.
local function svg_en_linea(svg, alt, prefijo)
  local function atributo(texto)
    return (texto:gsub('&', '&amp;'):gsub('"', '&quot;'):gsub('<', '&lt;'):gsub('>', '&gt;'))
  end
  svg = svg:gsub('<%?xml.-%?>', '')
    :gsub('<!DOCTYPE.->', '')
    :gsub('<!%-%-.-%-%->', '')
    :gsub('<title>.-</title>', '')
    :gsub('(%sid=")', '%1' .. prefijo .. '-')
    :gsub('url%(#', 'url(#' .. prefijo .. '-')
    :gsub('(href=")#', '%1#' .. prefijo .. '-')
    :gsub('<svg', '<svg class="diagrama" role="img" aria-label="' .. atributo(alt) .. '"', 1)
  return svg:match('^%s*(.-)%s*$')
end

function CodeBlock(bloque)
  if not bloque.classes:includes('dot') then
    return nil
  end

  local cuerpo = bloque.text:match('^%s*digraph[^{]*{(.*)}%s*$')
  if not cuerpo then
    error('El diagrama que empieza por «' .. bloque.text:match('^[^\n]*')
      .. '» no es un grafo de la forma "digraph { … }"')
  end
  local fuente = 'digraph G {\n' .. PREAMBULO .. expandir(cuerpo) .. '\n}\n'
  local ok, svg = pcall(pandoc.pipe, 'dot', { '-Tsvg' }, fuente)
  if not ok then
    local primera = bloque.text:match('^[^\n]*')
    error('Graphviz no ha podido generar el diagrama que empieza por «'
      .. primera .. '»:\n' .. tostring(svg))
  end

  local pie = bloque.attributes.caption or ''
  local alt = bloque.attributes.alt or pie

  if FORMAT:match('html') then
    local contenido = svg_en_linea(svg, alt, 'd' .. pandoc.sha1(fuente):sub(1, 8))
    return pandoc.Figure(
      pandoc.Plain({ pandoc.RawInline('html', contenido) }),
      pandoc.Blocks(pie ~= '' and { pandoc.Plain(pandoc.read(pie, 'markdown-smart').blocks[1].content) } or {}),
      pandoc.Attr(bloque.identifier, { 'diagrama' })
    )
  end

  local nombre = 'diagramas/' .. pandoc.sha1(fuente) .. '.svg'
  pandoc.mediabag.insert(nombre, 'image/svg+xml', svg)
  local atributos = {}
  local ancho = tonumber(svg:match('<svg[^>]-width="([%d.]+)pt"'))
  if ancho and ancho > ANCHO_MAXIMO then
    atributos.width = '100%'
  end

  local imagen = pandoc.Image(pandoc.Inlines(alt), nombre, '', pandoc.Attr('', {}, atributos))
  -- Sin la extensión smart, para que «git reset --hard» no se convierta
  -- en «git reset –hard»: en el pie no se pueden poner acentos graves
  return pandoc.Figure(
    pandoc.Plain({ imagen }),
    pandoc.Blocks(pie ~= '' and { pandoc.Plain(pandoc.read(pie, 'markdown-smart').blocks[1].content) } or {}),
    pandoc.Attr(bloque.identifier)
  )
end
