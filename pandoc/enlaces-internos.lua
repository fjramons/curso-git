-- Convierte los enlaces entre módulos (p. ej. 09-anexo-….md) en enlaces
-- internos del documento. Requiere --file-scope, que prefija los ids de los
-- títulos con "modulos__<fichero>__".

local function fichero_de(id)
  return id:match('^modulos__(.-%.md)__')
end

function Pandoc(doc)
  -- Primer título de cada módulo: destino de los enlaces al fichero completo
  local primer_titulo = {}
  doc:walk({
    Header = function(h)
      local f = fichero_de(h.identifier)
      if f and not primer_titulo[f] then
        primer_titulo[f] = h.identifier
      end
    end,
  })

  return doc:walk({
    Link = function(link)
      local f, ancla = link.target:match('^([^/:#]+%.md)#?(.*)$')
      if f and primer_titulo[f] then
        if ancla ~= '' then
          link.target = '#modulos__' .. f .. '__' .. ancla
        else
          link.target = '#' .. primer_titulo[f]
        end
        return link
      end
    end,
  })
end
