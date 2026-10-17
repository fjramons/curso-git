#!/usr/bin/env bash
# Genera el curso en Word, PDF y HTML a partir de los módulos
set -euo pipefail

cd "$(dirname "$0")/.."

# Opciones comunes a los dos idiomas y a los dos formatos
OPCIONES=(
  --file-scope
  --lua-filter=pandoc/diagramas.lua
  --lua-filter=pandoc/enlaces-internos.lua
  --lua-filter=pandoc/saltos-de-pagina.lua
)
VERSION="${1:-}"

# Los diagramas se generan con Graphviz: sin él, el curso queda incompleto
if ! command -v dot > /dev/null; then
  echo "Error: Graphviz no está instalado y hace falta para los diagramas" >&2
  exit 1
fi
# El reference.docx del Word (portada e índice) se genera con Python
if ! command -v python3 > /dev/null; then
  echo "Error: Python 3 no está instalado y hace falta para el Word" >&2
  exit 1
fi
# Sin rsvg-convert, el Word lleva los diagramas solo en SVG, sin copia en PNG
if ! command -v rsvg-convert > /dev/null; then
  echo "Aviso: rsvg-convert no está instalado, así que el Word no lleva copia en PNG de los diagramas" >&2
fi

mkdir -p outputs

TEMPORAL="$(mktemp -d)"
trap 'rm -rf "$TEMPORAL"' EXIT
python3 scripts/reference-docx.py "$TEMPORAL/reference.docx"

# Genera el Word y el PDF de un idioma. Con versión (p. ej. v1.0.0), nombre
# convencional para las releases; sin versión, fecha y hora delante del
# nombre para las copias locales. La portada del Word y del PDF muestra la
# versión o, sin ella, la fecha.
#   generar <metadatos> <carpeta de módulos> <nombre con versión> <nombre local> <«Versión»> <«Borrador del» y fecha>
generar() {
  local metadatos="$1" modulos="$2" nombre edicion
  if [[ -n "$VERSION" ]]; then
    nombre="$3-$VERSION"
    edicion="$5 ${VERSION#v}"
  else
    nombre="$(date +%Y%m%d_%H%M) $4"
    edicion="$6"
  fi
  # Portada e índice del Word y del PDF (pandoc/portada.lua). La web se
  # genera aparte con Quarto y tiene su propia portada y navegación.
  local libro=(
    "${OPCIONES[@]}"
    --metadata-file="$metadatos"
    --metadata="date=$edicion"
    --lua-filter=pandoc/portada.lua
  )

  pandoc "${libro[@]}" "$modulos"/*.md --reference-doc="$TEMPORAL/reference.docx" \
    --lua-filter=pandoc/codigo-word.lua -o "outputs/$nombre.docx"
  echo "Generado outputs/$nombre.docx"

  if command -v typst > /dev/null; then
    pandoc "${libro[@]}" "$modulos"/*.md --pdf-engine=typst \
      --include-in-header=pandoc/estilo-pdf.typ -o "outputs/$nombre.pdf"
    echo "Generado outputs/$nombre.pdf"
  fi
}

if ! command -v typst > /dev/null; then
  echo "Aviso: Typst no está instalado, así que no se genera el PDF" >&2
fi
generar pandoc/metadata.yaml modulos git-y-github-mas-alla-del-codigo \
  "Git y GitHub, más allá del código" "Versión" "Borrador del $(date +%d/%m/%Y)"
# La edición en inglés, traducida de la española, está en en/
generar en/metadata.yaml en/modules git-and-github-beyond-the-code \
  "Git and GitHub, Beyond the Code" "Version" "Draft of $(date +%Y-%m-%d)"

# La web: un libro de Quarto con una página por módulo, en outputs/web, y
# la edición en inglés en outputs/web/en. El inglés va después, porque
# quarto render vacía outputs/web antes de generar el español.
if command -v quarto > /dev/null; then
  quarto render --quiet
  echo "Generado outputs/web/index.html"
  quarto render en --quiet
  echo "Generado outputs/web/en/index.html"
else
  echo "Aviso: Quarto no está instalado, así que no se genera la web" >&2
fi
