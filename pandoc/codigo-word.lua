-- Salidas de comandos (bloques text) en el Word, con su propio estilo
-- («Salida», definido en scripts/reference-docx.py), como en el PDF. Pandoc
-- escribe todos los bloques de código con el estilo «Source Code» e ignora
-- custom-style en ellos, así que este filtro escribe las salidas a mano.
-- build.sh sólo lo usa al generar el Word.
--
-- Como en el PDF, los bloques de hasta seis líneas no se parten entre dos
-- páginas.

local LINEAS_SIN_PARTIR = 6

local function xml(texto)
  return (texto:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'))
end

function CodeBlock(bloque)
  if bloque.classes[1] ~= 'text' then
    return nil
  end
  local lineas = {}
  for linea in (bloque.text .. '\n'):gmatch('(.-)\n') do
    lineas[#lineas + 1] = '<w:r><w:rPr><w:rStyle w:val="VerbatimChar"/></w:rPr><w:t xml:space="preserve">'
      .. xml(linea) .. '</w:t></w:r>'
  end
  local sin_partir = #lineas <= LINEAS_SIN_PARTIR and '<w:keepLines/>' or ''
  return pandoc.RawBlock('openxml', string.format(
    '<w:p><w:pPr><w:pStyle w:val="Salida"/>%s</w:pPr>%s</w:p>',
    sin_partir, table.concat(lineas, '<w:r><w:br/></w:r>')))
end
