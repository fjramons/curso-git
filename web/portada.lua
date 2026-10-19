-- Rejilla de módulos de la portada de la web (index.qmd). Rellena el bloque
-- vacío «::: {.modulos-portada}» con una tarjeta por cada módulo y anexo de
-- la carpeta de los módulos (modulos/ en español y modules/ en inglés), en
-- el orden de su número. Cada tarjeta muestra el título de nivel 1 del
-- fichero partido por los dos puntos: «Módulo 4» encima y «Ramificación
-- (branches) y fusiones» debajo. Así la portada no repite los títulos y no
-- hay que tocarla al añadir o renombrar un módulo.

local CARPETAS = { 'modulos', 'modules' }

local function leer(ruta)
  local f = io.open(ruta, 'r')
  if not f then
    return nil
  end
  local texto = f:read('a')
  f:close()
  return texto
end

-- Título de nivel 1 del fichero, como texto
local function titulo(ruta)
  local texto = leer(ruta)
  if not texto then
    return nil
  end
  local documento = pandoc.read(texto, 'markdown')
  for _, bloque in ipairs(documento.blocks) do
    if bloque.t == 'Header' and bloque.level == 1 then
      return pandoc.utils.stringify(bloque.content)
    end
  end
  return nil
end

local function tarjetas(raiz)
  for _, carpeta in ipairs(CARPETAS) do
    local ruta = pandoc.path.join({ raiz, carpeta })
    local ok, ficheros = pcall(pandoc.system.list_directory, ruta)
    if ok then
      table.sort(ficheros)
      local elementos = {}
      for _, fichero in ipairs(ficheros) do
        -- El 00 es el prefacio, que ya está en la portada
        if fichero:match('^%d%d%-.*%.md$') and not fichero:match('^00%-') then
          local texto = titulo(pandoc.path.join({ ruta, fichero }))
          if texto then
            local numero, nombre = texto:match('^(.-):%s*(.+)$')
            local contenido = {
              pandoc.Span(numero or '', { class = 'tarjeta-numero' }),
              pandoc.Span(nombre or texto, { class = 'tarjeta-titulo' }),
            }
            local enlace = pandoc.Link(contenido, carpeta .. '/' .. fichero)
            table.insert(elementos, { pandoc.Plain({ enlace }) })
          end
        end
      end
      return pandoc.BulletList(elementos)
    end
  end
  return nil
end

function Div(bloque)
  if bloque.classes:includes('modulos-portada') then
    local entrada = quarto.doc.input_file or ''
    local lista = tarjetas(pandoc.path.directory(entrada))
    if lista then
      bloque.content = { lista }
      return bloque
    end
  end
end
