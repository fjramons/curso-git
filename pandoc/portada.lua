-- Portada e índice del Word y del PDF. La web no los lleva: build.sh le
-- pasa --toc para que tenga su índice de navegación, y a este filtro no le
-- afecta.
--
-- - PDF: portada propia en su página (título, subtítulo, filete, autor y la
--   línea de date con la versión), sin número de página, y el índice en una
--   página aparte. Se quitan title, subtitle, author y date de los metadatos
--   para que la plantilla de Pandoc no dibuje su bloque de título, y el
--   título y el autor del documento se fijan aquí.
-- - Word: la portada es el bloque de título de Pandoc (así el título sigue
--   en las propiedades del fichero), con los estilos del reference.docx que
--   genera scripts/reference-docx.py, seguida de un salto de página y del
--   índice. El índice va relleno con enlaces a los títulos, para que se vea
--   en cualquier programa, y Word ofrece actualizarlo al abrir el documento
--   para añadir los números de página.
-- El estilo del índice del PDF está en estilo-pdf.typ.

local TITULO_INDICE = 'Índice'

local function typst(inlines)
  return inlines and pandoc.write(pandoc.Pandoc({ pandoc.Plain(inlines) }), 'typst'):gsub('%s+$', '') or ''
end

-- En la portada, el título se parte tras la primera coma («Git y GitHub,
-- / más allá del código») en lugar de dejar una palabra sola en la segunda
-- línea.
local function partir_titulo(inlines)
  local partido = inlines:clone()
  for i = 1, #partido - 1 do
    if partido[i].t == 'Str' and partido[i].text:match(',$') and partido[i + 1].t == 'Space' then
      partido[i + 1] = pandoc.LineBreak()
      break
    end
  end
  return partido
end

local function portada_typst(meta, profundidad)
  return string.format([[
#set document(title: [%s], author: "%s")
#page(numbering: none)[
  #set par(justify: false)
  #v(1fr)
  #text(size: 30pt, weight: "bold", fill: rgb("#1d2733"), hyphenate: false)[%s]
  #v(0.4em)
  #text(size: 15pt, fill: rgb("#4a5b70"), hyphenate: false)[%s]
  #v(1em)
  #line(length: 100%%, stroke: 1.5pt + rgb("#4a5b70"))
  #v(0.8em)
  #text(size: 13pt, fill: rgb("#4a5b70"))[%s]
  #v(2fr)
  #text(size: 11pt, fill: rgb("#4a5b70"))[%s]
]
#outline(title: [%s], depth: %d)
]], typst(meta.title), pandoc.utils.stringify(meta.author or ''):gsub('["\\]', '\\%0'),
    typst(partir_titulo(meta.title)), typst(meta.subtitle), typst(meta.author), typst(meta.date),
    TITULO_INDICE, profundidad)
end

-- Marcador que el escritor docx de Pandoc pone en cada título: «_» y el id
-- si sólo tiene letras, números y «_» y cabe en los 40 caracteres de Word,
-- y si no, «_» y un resumen SHA-1 (es el caso de los ids de --file-scope,
-- que llevan «.md»).
local function marcador_docx(id)
  if not id:gsub('_', ''):find('[%p%s]') and utf8.len(id) <= 39 then
    return '_' .. id
  end
  return '_' .. pandoc.utils.sha1(id):sub(2)
end

local function xml(texto)
  return (texto:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'))
end

-- El índice va relleno de antemano con un enlace a cada título, para que
-- se vea en cualquier programa. Word lo regenera al actualizar el campo
-- (y entonces añade los números de página).
local function indice_docx(blocks, profundidad)
  local entradas = {}
  for _, b in ipairs(blocks) do
    if b.t == 'Header' and b.level <= profundidad and b.identifier ~= '' then
      entradas[#entradas + 1] = string.format(
        '<w:p><w:pPr><w:pStyle w:val="TOC%d"/></w:pPr><w:hyperlink w:anchor="%s" w:history="1"><w:r><w:t xml:space="preserve">%s</w:t></w:r></w:hyperlink></w:p>',
        b.level, marcador_docx(b.identifier), xml(pandoc.utils.stringify(b.content)))
    end
  end
  return string.format([[
<w:p><w:r><w:br w:type="page"/></w:r></w:p>
<w:sdt><w:sdtPr><w:docPartObj><w:docPartGallery w:val="Table of Contents"/><w:docPartUnique/></w:docPartObj></w:sdtPr><w:sdtContent>
<w:p><w:pPr><w:pStyle w:val="TOCHeading"/></w:pPr><w:r><w:t xml:space="preserve">%s</w:t></w:r></w:p>
<w:p><w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/><w:instrText xml:space="preserve">TOC \o "1-%d" \h \z \u</w:instrText><w:fldChar w:fldCharType="separate"/></w:r></w:p>
%s
<w:p><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>
</w:sdtContent></w:sdt>]], TITULO_INDICE, profundidad, table.concat(entradas, '\n'))
end

function Pandoc(doc)
  local profundidad = tonumber(pandoc.utils.stringify(doc.meta['toc-depth'] or '2')) or 2
  if FORMAT == 'typst' then
    doc.blocks:insert(1, pandoc.RawBlock('typst', portada_typst(doc.meta, profundidad)))
    doc.meta.title, doc.meta.subtitle, doc.meta.author, doc.meta.date = nil, nil, nil, nil
  elseif FORMAT == 'docx' then
    doc.blocks:insert(1, pandoc.RawBlock('openxml', indice_docx(doc.blocks, profundidad)))
    doc.meta.title = partir_titulo(doc.meta.title)
  else
    return nil
  end
  return doc
end
