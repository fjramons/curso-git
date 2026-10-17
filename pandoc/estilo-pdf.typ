// Estilo de los bloques de código en el PDF. scripts/build.sh incluye este
// fichero en la cabecera del documento Typst solo al generar el PDF.
//
// - Órdenes y contenido de ficheros (bash, yaml, markdown…): fondo gris
//   azulado y filete a la izquierda, con los colores de los diagramas.
// - Salidas de comandos (bloques text): fondo blanco y borde fino, para
//   distinguir lo que escribe el lector de lo que responde la terminal.
// - Una línea demasiado larga continúa con sangría (la suya más cuatro
//   caracteres), para que no parezca una línea nueva. Nunca se guioniza.
// - Los bloques cortos no se parten entre dos páginas.

#let codigo-fondo = rgb("#f3f6fa")
#let codigo-filete = rgb("#4a5b70")
#let salida-borde = rgb("#c5ced8")

#show raw.where(block: true): it => {
  let salida = it.lang == "text"
  block(
    width: 100%,
    inset: (x: 9pt, y: 7pt),
    above: 1.1em,
    below: 1.3em,
    radius: if salida { 3pt } else { (right: 3pt) },
    fill: if salida { white } else { codigo-fondo },
    stroke: if salida { 0.6pt + salida-borde } else { (left: 2.5pt + codigo-filete) },
    breakable: it.lines.len() > 6,
    context {
      // Cada línea es un párrafo, con el mismo interlineado que el bloque
      let ancho = measure("0").width
      set par(justify: false)
      set text(hyphenate: false)
      for linea in it.lines {
        let sangria = linea.text.len() - linea.text.trim(at: start).len()
        block(above: par.leading, below: par.leading, par(
          hanging-indent: (sangria + 4) * ancho,
          if linea.text == "" [#sym.zws] else { linea },
        ))
      }
    },
  )
}

// Índice: cada módulo en negrita y separado del anterior, y sus apartados
// debajo, sin negrita. La portada y el índice los añade portada.lua.
#show outline.entry.where(level: 1): set block(above: 1.1em)
#show outline.entry.where(level: 1): set text(weight: "bold")
