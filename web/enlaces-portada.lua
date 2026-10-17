-- La portada de la web (index.qmd) incluye el prefacio, que está en la
-- carpeta de los módulos (modulos/ en español y modules/ en inglés) y enlaza
-- a los módulos con rutas relativas a esa carpeta
-- (01-introducción-y-primeros-pasos.md). En la portada, que está en la raíz
-- del proyecto, esas rutas se prefijan con la carpeta de los módulos.

local CARPETAS = { 'modulos', 'modules' }

local function existe(ruta)
  local f = io.open(ruta, 'r')
  if f then
    f:close()
    return true
  end
  return false
end

function Link(enlace)
  local entrada = quarto.doc.input_file or ''
  if entrada:match('index%.qmd$') and enlace.target:match('^%d%d%-[^/:]*%.md') then
    local raiz = pandoc.path.directory(entrada)
    local fichero = enlace.target:match('^[^#]*')
    for _, carpeta in ipairs(CARPETAS) do
      if existe(pandoc.path.join({ raiz, carpeta, fichero })) then
        enlace.target = carpeta .. '/' .. enlace.target
        return enlace
      end
    end
  end
end
