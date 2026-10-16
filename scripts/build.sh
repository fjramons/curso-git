#!/usr/bin/env bash
# Genera el curso en Word, PDF y HTML a partir de los módulos
set -euo pipefail

cd "$(dirname "$0")/.."

# Con versión (p. ej. v1.0.0), nombre convencional para las releases.
# Sin versión, fecha y hora delante del nombre para las copias locales.
VERSION="${1:-}"
if [[ -n "$VERSION" ]]; then
  NOMBRE="curso-de-git-y-github-$VERSION"
else
  NOMBRE="$(date +%Y%m%d_%H%M) Curso de Git y GitHub"
fi
OPCIONES=(
  --metadata-file=pandoc/metadata.yaml
  --toc
  --file-scope
  --lua-filter=pandoc/diagramas.lua
  --lua-filter=pandoc/enlaces-internos.lua
)

# Los diagramas se generan con Graphviz: sin él, el curso queda incompleto
if ! command -v dot > /dev/null; then
  echo "Error: Graphviz no está instalado y hace falta para los diagramas" >&2
  exit 1
fi
# Sin rsvg-convert, el Word lleva los diagramas solo en SVG, sin copia en PNG
if ! command -v rsvg-convert > /dev/null; then
  echo "Aviso: rsvg-convert no está instalado, así que el Word no lleva copia en PNG de los diagramas" >&2
fi

mkdir -p outputs

pandoc "${OPCIONES[@]}" modulos/*.md -o "outputs/$NOMBRE.docx"
echo "Generado outputs/$NOMBRE.docx"

if command -v typst > /dev/null; then
  pandoc "${OPCIONES[@]}" modulos/*.md --pdf-engine=typst -o "outputs/$NOMBRE.pdf"
  echo "Generado outputs/$NOMBRE.pdf"
else
  echo "Aviso: Typst no está instalado, así que no se genera el PDF" >&2
fi

pandoc "${OPCIONES[@]}" modulos/*.md --standalone --embed-resources -o outputs/index.html
echo "Generado outputs/index.html"
