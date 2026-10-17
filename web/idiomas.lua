-- Enlace de cada página de la web a la misma página en el otro idioma. El
-- español está en la raíz (index.qmd y modulos/) y el inglés en en/
-- (en/index.qmd y en/modules/). Los módulos se emparejan por su número
-- (01-…); si la página aún no existe en el otro idioma, se enlaza su
-- portada. El enlace va en la cabecera como
-- <link rel="alternate" hreflang="…">, con una ruta relativa para que
-- funcione igual en GitHub Pages y en local, y web/tema.html lo usa para el
-- botón de cambio de idioma.

local function buscar(carpeta, numero)
  local ok, ficheros = pcall(pandoc.system.list_directory, carpeta)
  if not ok then
    return nil
  end
  table.sort(ficheros)
  for _, f in ipairs(ficheros) do
    if f:match('^' .. numero .. '%-.*%.md$') then
      return f
    end
  end
end

function Meta(meta)
  local entrada = quarto.doc.input_file or ''
  local raiz, idioma, href, otra
  local carpeta = pandoc.path.directory(entrada)
  local fichero = pandoc.path.filename(entrada)
  local numero = fichero:match('^(%d%d)%-')

  if pandoc.path.filename(carpeta) == 'modules' then
    -- Módulo en inglés: en/modules/NN-….md
    raiz, idioma = pandoc.path.directory(pandoc.path.directory(carpeta)), 'es'
    otra = buscar(pandoc.path.join({ raiz, 'modulos' }), numero)
    href = otra and ('../../modulos/' .. otra:gsub('%.md$', '.html')) or '../../index.html'
  elseif pandoc.path.filename(carpeta) == 'modulos' then
    -- Módulo en español: modulos/NN-….md
    raiz, idioma = pandoc.path.directory(carpeta), 'en'
    otra = buscar(pandoc.path.join({ raiz, 'en', 'modules' }), numero)
    href = otra and ('../en/modules/' .. otra:gsub('%.md$', '.html')) or '../en/index.html'
  elseif fichero == 'index.qmd' and pandoc.path.filename(carpeta) == 'en' then
    idioma, href = 'es', '../index.html'
  elseif fichero == 'index.qmd' then
    idioma, href = 'en', 'en/index.html'
  else
    return nil
  end

  local enlace = pandoc.RawBlock('html',
    string.format('<link rel="alternate" hreflang="%s" href="%s">', idioma, href))
  local cabecera = meta['header-includes']
  if cabecera == nil then
    cabecera = pandoc.MetaList({})
  elseif cabecera.t ~= 'MetaList' then
    cabecera = pandoc.MetaList({ cabecera })
  end
  cabecera:insert(pandoc.MetaBlocks({ enlace }))
  meta['header-includes'] = cabecera
  return meta
end
