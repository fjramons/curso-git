-- Empieza cada módulo (título de nivel 1) en una página nueva, en el Word
-- y en el PDF. La web es un documento continuo y no cambia.
--
-- En el PDF el salto es «débil»: si la página ya está vacía, no se añade
-- otra en blanco.

local SALTO = {
  docx = pandoc.RawBlock('openxml', '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'),
  typst = pandoc.RawBlock('typst', '#pagebreak(weak: true)'),
}

function Header(titulo)
  local salto = SALTO[FORMAT]
  if salto and titulo.level == 1 then
    return { salto, titulo }
  end
end
