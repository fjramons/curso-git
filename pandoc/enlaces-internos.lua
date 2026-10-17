-- Convierte los enlaces entre módulos (p. ej. 09-anexo-….md) en enlaces
-- internos del documento. Requiere --file-scope, que prefija los ids de los
-- títulos con la ruta del fichero, con «__» en lugar de «/»:
-- "modulos__<fichero>__" en español y "en__modules__<fichero>__" en inglés.

local function fichero_de(id)
  return id:match('^(.-%.md)__')
end

function Pandoc(doc)
  -- Primer título de cada módulo: destino de los enlaces al fichero completo.
  -- Se indexa por el nombre del fichero, sin la carpeta.
  local primer_titulo, prefijo = {}, {}
  doc:walk({
    Header = function(h)
      local ruta = fichero_de(h.identifier)
      if ruta then
        local carpeta, f = ruta:match('^(.*__)(.-%.md)$')
        if not f then
          carpeta, f = '', ruta
        end
        if not primer_titulo[f] then
          primer_titulo[f] = h.identifier
          prefijo[f] = carpeta
        end
      end
    end,
  })

  return doc:walk({
    Link = function(link)
      local f, ancla = link.target:match('^([^/:#]+%.md)#?(.*)$')
      if f and primer_titulo[f] then
        if ancla ~= '' then
          link.target = '#' .. prefijo[f] .. f .. '__' .. ancla
        else
          link.target = '#' .. primer_titulo[f]
        end
        return link
      end
    end,
  })
end
