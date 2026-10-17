-- La portada de la web (index.qmd) incluye el prefacio, que está en
-- modulos/ y enlaza a los módulos con rutas relativas a esa carpeta
-- (01-introducción-y-primeros-pasos.md). En la portada, que está en la raíz
-- del proyecto, esas rutas se prefijan con modulos/.

function Link(enlace)
  local entrada = quarto.doc.input_file or ''
  if entrada:match('index%.qmd$') and enlace.target:match('^%d%d%-[^/:]*%.md') then
    enlace.target = 'modulos/' .. enlace.target
    return enlace
  end
end
