# Git y GitHub, más allá del código

_Controla tus versiones, colabora sin miedo y automatiza tu trabajo._ Por fjramons.

Curso práctico de Git y GitHub basado en la construcción de un proyecto real de principio a fin: un **Manual de Git** escrito en Markdown. Cada capítulo del libro recoge lo aprendido en el curso, un script lo convierte a Word, PDF y HTML con Pandoc, y GitHub Actions publica automáticamente cada versión como una Release y como una web en GitHub Pages.

El curso se puede leer en la web, en <https://fjramons.github.io/curso-git/>, y descargar en PDF y Word desde la [última versión publicada](https://github.com/fjramons/curso-git/releases/latest).

_English edition_: the course is also available in English as _Git and GitHub, Beyond the Code_, on the web at <https://fjramons.github.io/curso-git/en/> and as PDF and Word in the same [releases](https://github.com/fjramons/curso-git/releases/latest). Its source is in [`en/`](en/).

## Módulos

El curso empieza con un [prefacio](modulos/00-prefacio.md) que explica a quién va dirigido, por qué Git y GitHub son útiles también fuera del desarrollo de software y cómo está organizado.

1. [Introducción y primeros pasos](modulos/01-introducción-y-primeros-pasos.md): qué son Git y GitHub, instalación, terminal y configuración.
2. [Control de versiones en local](modulos/02-control-de-versiones-en-local.md): repositorio, staging, commits, deshacer cambios, `.gitignore` y el script del libro.
3. [Viajes en el tiempo y puntos de guardado](modulos/03-viajes-en-el-tiempo-y-puntos-de-guardado.md): checkout, reset, revert, reflog y etiquetas.
4. [Ramificación y fusiones](modulos/04-ramificación-y-fusiones.md): ramas, merge, conflictos y stash.
5. [GitHub y trabajo remoto](modulos/05-github-y-trabajo-remoto.md): SSH, push, fetch, pull y clone.
6. [Trabajo colaborativo y open source](modulos/06-trabajo-colaborativo-y-open-source.md): forks, pull requests, sincronización y Markdown.
7. [Flujos de trabajo y comandos avanzados](modulos/07-flujos-de-trabajo-y-comandos-avanzados.md): GUIs, GitFlow, GitHub flow, cherry-pick, rebase y revert.
8. [GitHub Actions](modulos/08-github-actions.md): integración y despliegue continuos, workflows, actions del Marketplace, permisos, tareas programadas, GitHub Pages y publicación de versiones.
9. [Anexo: dependencias de los ejemplos](modulos/09-anexo-dependencias-de-los-ejemplos.md): instalación de Pandoc y Typst, necesarios sólo para generar el libro.
10. [Anexo: referencias útiles](modulos/10-anexo-referencias-útiles.md): recopilación de los recursos citados en el curso (Git, GitHub, Markdown y GitHub Actions).

## Qué se construye

Al terminar el curso tendrás en GitHub un repositorio `manual-git` con esta estructura:

```text
manual-git/
├── README.md
├── metadata.yaml
├── build.sh
├── .gitignore
├── .markdownlint.jsonc
├── capitulos/
│   ├── 01-que-es-git.md
│   ├── 02-primeros-comandos.md
│   ├── 03-ramas.md
│   ├── 04-historial.md
│   ├── 05-github.md
│   ├── 06-flujos-de-trabajo.md
│   └── 07-comandos-avanzados.md
└── .github/
    └── workflows/
        ├── ci.yml
        └── enlaces.yml
```

- `capitulos/` contiene el libro, un fichero Markdown por capítulo.
- `build.sh` genera el libro en Word, PDF y HTML con Pandoc.
- `.github/workflows/ci.yml` revisa la sintaxis Markdown en cada cambio y, al crear una etiqueta de versión, publica una Release con el Word y el PDF, y la versión HTML en GitHub Pages.
- `.github/workflows/enlaces.yml` comprueba cada semana que los enlaces del libro siguen funcionando y abre un issue si alguno falla.

## Requisitos

- Un ordenador con Linux, macOS o Windows. En Windows se usa Git Bash, que se instala con Git.
- Una cuenta gratuita en [GitHub](https://github.com), a partir del módulo 5.
- Un editor de texto. Los ejemplos usan [VS Code](https://code.visualstudio.com) (comando `code`), pero sirve cualquiera.
- Para generar el libro en local, Pandoc y, opcionalmente, Typst (ver el anexo). No son necesarios para aprender Git.
- Para el módulo 6, idealmente, un compañero o compañera con quien colaborar.

## Generar el curso

Este repositorio funciona como el ejemplo del curso: los módulos están en Markdown, un script los convierte a Word y PDF con Pandoc, y GitHub Actions los revisa y los publica. La única diferencia es la web: el ejemplo genera una sola página HTML con Pandoc, y este repositorio genera con [Quarto](https://quarto.org) una web tipo libro, con una página por módulo, un índice lateral, un buscador y modo claro y oscuro.

```text
curso-git/
├── README.md
├── LICENSE
├── .gitignore
├── .markdownlint.jsonc
├── .github/workflows/ci.yml
├── _quarto.yml
├── index.qmd
├── en/
│   ├── _quarto.yml
│   ├── index.qmd
│   ├── metadata.yaml
│   └── modules/
│       ├── 00-preface.md
│       ├── ...
│       └── 10-appendix-useful-references.md
├── modulos/
│   ├── 00-prefacio.md
│   ├── 01-introducción-y-primeros-pasos.md
│   ├── ...
│   ├── 09-anexo-dependencias-de-los-ejemplos.md
│   └── 10-anexo-referencias-útiles.md
├── pandoc/
│   ├── metadata.yaml
│   ├── diagramas.lua
│   ├── enlaces-internos.lua
│   ├── estilo-pdf.typ
│   ├── portada.lua
│   └── saltos-de-pagina.lua
├── web/
│   ├── cabecera.html
│   ├── enlaces-portada.lua
│   ├── idiomas.lua
│   ├── portada.lua
│   ├── estilo.scss
│   ├── oscuro.scss
│   ├── resaltado-claro.theme
│   ├── resaltado-oscuro.theme
│   └── tema.html
├── scripts/
│   ├── build.sh
│   ├── comprobar-traduccion.py
│   └── reference-docx.py
└── outputs/
    └── .gitkeep
```

- `modulos/` contiene el curso. Los ficheros se ordenan por su número, que es el orden en el que aparecen en el documento generado. Para añadir un módulo basta con crear un fichero nuevo con el número que le corresponda.
- `pandoc/metadata.yaml` define el título, el subtítulo, el autor y el idioma del documento, y `pandoc/enlaces-internos.lua` convierte los enlaces entre módulos en enlaces dentro del documento.
- `pandoc/diagramas.lua` convierte los diagramas del historial, escritos en texto dentro de los módulos, en imágenes SVG (ver [Diagramas](#diagramas)).
- `pandoc/estilo-pdf.typ` da estilo a los bloques de código del PDF: fondo y filete para las órdenes y el contenido de ficheros, borde fino para las salidas de comandos (bloques `text`) y sangría en la continuación de las líneas largas.
- `pandoc/saltos-de-pagina.lua` empieza cada módulo en una página nueva en el Word y en el PDF.
- `pandoc/codigo-word.lua` da a las salidas de comandos (bloques `text`) del Word su propio estilo, con borde fino, para distinguirlas de las órdenes, que llevan fondo y filete como en el PDF.
- `pandoc/portada.lua` añade al Word y al PDF una portada, con el autor y la versión o la fecha de generación, y un índice en página aparte. La web tiene su propia portada (`index.qmd`) y su propio índice de navegación.
- `_quarto.yml` define la web: el orden de los módulos y de los anexos, la barra lateral, el pie de página y el estilo. `index.qmd` es su portada, con los botones para empezar y descargar el curso, una tarjeta por módulo y el prefacio. En la web, `pandoc/diagramas.lua` inserta cada diagrama como SVG dentro de la página. La carpeta `web/` contiene:
  - `estilo.scss`, el estilo de la web, comentado por secciones (texto, código, diagramas, tablas, portada, barra lateral, navegación, móvil y accesibilidad), y `oscuro.scss`, los colores del modo oscuro. Los diagramas tienen colores fijos, los mismos del Word y del PDF, y `oscuro.scss` los cambia uno a uno por sus equivalentes para el fondo oscuro, así que, si cambias un color en `pandoc/diagramas.lua`, cámbialo también allí.
  - `cabecera.html`, que carga las fuentes de Google Fonts (sólo los pesos que usa el estilo) y pone el icono de la pestaña.
  - `resaltado-claro.theme` y `resaltado-oscuro.theme`, los colores del código: los temas de GitHub que trae Quarto, con los colores que no llegaban al contraste AA corregidos.
  - `portada.lua`, que rellena las tarjetas de la portada con el título de cada módulo y anexo, y `enlaces-portada.lua`, que corrige en la portada los enlaces del prefacio a los módulos.
- `en/` contiene la edición en inglés (ver [Edición en inglés](#edición-en-inglés)).
- `web/idiomas.lua` enlaza cada página de la web con la misma página en el otro idioma, y `web/tema.html` pone en la barra lateral los botones del modo claro u oscuro y del cambio de idioma.
- `scripts/build.sh` genera el curso en `outputs/`, en los dos idiomas.
- `scripts/comprobar-traduccion.py` comprueba que la edición en inglés tiene la misma estructura que la española.
- `scripts/reference-docx.py` prepara la plantilla del Word a partir de la de Pandoc: página A4, estilos de la portada y del índice, número de página al pie (salvo en la portada), bloques de código como los del PDF, y el aviso para que Word actualice el índice (y añada los números de página) al abrir el documento. `build.sh` la genera en cada ejecución, así que no se guarda en Git.
- `outputs/` sólo guarda en Git el fichero `.gitkeep`, para que la carpeta exista. Todo lo que se genera dentro está en el `.gitignore`.

### En local

Instala Pandoc y, para el PDF, Typst (ver el [anexo](modulos/09-anexo-dependencias-de-los-ejemplos.md)). La plantilla del Word necesita Python 3, que ya viene con Linux y macOS (en Windows: `winget install Python.Python.3.12`). Los diagramas necesitan además Graphviz y, para que el Word incluya una copia en PNG para los programas que no muestran SVG, `rsvg-convert`:

- Linux (Debian/Ubuntu): `sudo apt install graphviz librsvg2-bin`
- macOS: `brew install graphviz librsvg`
- Windows: `winget install Graphviz.Graphviz`. `rsvg-convert` es opcional: sin él, el Word lleva sólo los SVG, que Word muestra sin problemas.

Para la web hace falta Quarto, que es opcional: sin él, el script genera el Word y el PDF y avisa de que no genera la web. Quarto trae su propio Pandoc, así que no interfiere con el que genera el Word y el PDF. Se puede instalar de varias formas (ver la [guía de instalación](https://quarto.org/docs/get-started/)):

- En cualquier sistema con [uv](https://docs.astral.sh/uv/): `uv tool install quarto-cli`. Se instala sin permisos de administrador, se actualiza con `uv tool upgrade quarto-cli` y se desinstala con `uv tool uninstall quarto-cli`. Con pipx es igual: `pipx install quarto-cli`.
- Linux (Debian/Ubuntu): descarga el `.deb` de la [última versión](https://github.com/quarto-dev/quarto-cli/releases/latest) e instálalo con `sudo apt install ./quarto-X.Y.Z-linux-amd64.deb`. Hay también un `.rpm` para Fedora y un `.tar.gz` que se puede descomprimir en cualquier carpeta sin permisos de administrador, con un enlace a `bin/quarto` en `~/.local/bin`.
- macOS: `brew install --cask quarto`, o el `.pkg` de la última versión.
- Windows: `winget install --id Posit.Quarto`, o el `.msi` de la última versión.

Para comprobar que Quarto funciona, ejecuta `quarto check`.

Después, ejecuta desde cualquier carpeta:

```bash
scripts/build.sh
```

El script genera en `outputs/` estos ficheros, con la fecha y la hora de generación delante del nombre:

- `YYYYMMDD_HHmm Git y GitHub, más allá del código.docx`
- `YYYYMMDD_HHmm Git y GitHub, más allá del código.pdf` (sólo si Typst está instalado)
- `YYYYMMDD_HHmm Git and GitHub, Beyond the Code.docx` y `.pdf`, la edición en inglés.
- `web/`, la versión web del curso (sólo si Quarto está instalado), con la edición en inglés en `web/en/`, que se puede revisar en local como se explica en [Ver la web en local](#ver-la-web-en-local).

Si le pasas una versión, el script usa un nombre convencional asociado a esa versión, que es lo que hace el CI al publicar una Release:

```bash
scripts/build.sh v1.0.0
```

Genera `git-y-github-mas-alla-del-codigo-v1.0.0.docx` y `.pdf`, `git-and-github-beyond-the-code-v1.0.0.docx` y `.pdf`, y la web en `outputs/web/`.

### Ver la web en local

Para revisar la web antes de publicarla, lo más cómodo es la vista previa de Quarto. Ejecuta esta orden desde la raíz del repositorio:

```bash
quarto preview --port 4321
```

Quarto genera la web, la sirve en <http://localhost:4321/> y la abre en el navegador (con `--no-browser` no la abre). La edición en inglés es un proyecto de Quarto aparte, que se revisa igual con `quarto preview en --port 4322`. El botón de cambio de idioma lleva a la otra edición generada en `outputs/web`, así que, para probarlo, lo más cómodo es ejecutar `scripts/build.sh` y servir esa carpeta con `python3 -m http.server 4321 --directory outputs/web`. Mientras está en marcha, vigila los ficheros: si cambias un módulo, `_quarto.yml` o los estilos de `web/`, vuelve a generar la página y el navegador la recarga solo. Para pararla, pulsa `Ctrl+C` en la terminal.

También puedes abrir directamente `outputs/web/index.html` después de ejecutar `scripts/build.sh`, aunque así el buscador no funciona, porque el navegador no deja que una página abierta como fichero cargue el índice de búsqueda.

### En GitHub

El workflow `.github/workflows/ci.yml` hace dos cosas:

- En cada push y en cada pull request, revisa la sintaxis de todos los ficheros Markdown con markdownlint, usando las reglas de `.markdownlint.jsonc`.
- Al subir una etiqueta que empieza por `v`, comprueba que la edición en inglés sigue a la española, genera el curso en los dos idiomas con el nombre de la etiqueta, crea una Release con los cuatro ficheros adjuntos (Word y PDF en español y en inglés) y publica la web de los dos idiomas en GitHub Pages.

Para publicar una versión:

```bash
git tag v1.0.0
git push origin v1.0.0
```

El workflow instala Graphviz, `rsvg-convert` y Quarto antes de generar el curso, y publica en GitHub Pages el contenido de `outputs/web/`.

Antes de la primera publicación hay que activar Pages en _Settings_ → _Pages_ → _Source_: **GitHub Actions**, y permitir las etiquetas `v*` en _Settings_ → _Environments_ → _github-pages_, como se explica en el apartado 8.6.

## Edición en inglés

La edición en inglés, _Git and GitHub, Beyond the Code_, está en `en/` y se traduce de la española, que es la principal: los cambios se discuten y se escriben primero en `modulos/` y después se trasladan a `en/modules/`. Cada módulo inglés lleva el mismo número que el español (`04-ramificación-y-fusiones.md` ↔ `04-branching-and-merging.md`) y conserva sus apartados, su numeración, sus bloques de código y sus diagramas.

El ejemplo del libro también está traducido (el repositorio se llama `git-handbook`, los capítulos están en `chapters/`, las ramas y los commits van en inglés), pero los hashes son los mismos que en español, así que el historial tiene exactamente la misma forma en las dos ediciones.

Para comprobar que la traducción está al día:

```bash
scripts/comprobar-traduccion.py
```

El script compara cada pareja de módulos (títulos, bloques de código, diagramas y hashes) y avisa si algo falta o sobra. El CI lo ejecuta antes de publicar una Release, de modo que no se puede publicar una versión con la traducción desfasada.

La web inglesa es un proyecto de Quarto aparte (`en/_quarto.yml`) que se publica en `/curso-git/en/` y comparte con la española los filtros de `pandoc/` y el estilo de `web/`. Cada página tiene un botón que lleva a la misma página en el otro idioma.

## Diagramas

Los diagramas del historial se escriben dentro de los módulos, en bloques de código `dot` (el lenguaje de [Graphviz](https://graphviz.org)). Al generar el curso, `pandoc/diagramas.lua` les aplica los colores y el estilo común y los convierte en SVG, que se ven igual en Word, PDF y HTML. Cada bloque es un grafo de Graphviz completo, así que la vista previa del editor dibuja la misma disposición, aunque sin colores. En la vista previa de GitHub se ve el código, no el dibujo.

````markdown
```{.dot caption="Pie de la figura" alt="Descripción para lectores de pantalla"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  c1 [label="Añade el README del libro"]; c2 [label="Añade el capítulo 1: qué es Git"]
  c1 -> c2
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]
  { rank=same; c2 -> main -> HEAD [class=ref dir=back] }
}
```
````

- Las tres primeras líneas son iguales en todos los diagramas del historial: dibujan de abajo arriba, como `git tree`, con los commits en caja y alineados. El filtro ignora las líneas `node [...]` y aplica su propio estilo.
- Cada nodo con caja es un commit, con su mensaje completo en `label` (`\n` parte una línea larga). Se escribe `padre -> hijo`, y la flecha va del commit anterior al siguiente. Si el texto del apartado muestra el hash de un commit (en una salida de `git log`, `git reflog`, etc.), la etiqueta empieza por ese hash (`label="5e7b3a2 Añade…"`) y el filtro lo escribe en gris; si no, el commit va sin hash. Cada diagrama va precedido de la salida de `git tree` en ese punto del ejemplo (cortada con `...` si el historial es largo), así que casi todos los commits llevan su hash.
- Las referencias se declaran después de `node [shape=plaintext, group=""]`, con `class=rama`, `class=remota`, `class=head` o `class=etiqueta`, y salen como texto en color. `{ rank=same; c2 -> main -> HEAD [class=ref dir=back] }` las coloca en la fila de su commit, a la derecha, con las flechas hacia el commit. Para ponerlas a la izquierda se escriben al revés y con `dir=forward`: `{ rank=same; HEAD -> main -> c2 [class=ref dir=forward] }`.
- Cuando dos commits de ramas distintas quedan en la misma fila, `{ rank=same; a -> b [style=invis] }` fija que `a` vaya a la izquierda de `b`. Las referencias del commit de la izquierda se ponen a su izquierda, para que no queden entre las dos ramas.
- `group=<nombre>` alinea en columna los commits de cada rama cuando hay varias. `main` (o la rama permanente del esquema) va en una columna recta a la izquierda (`group=main`) y cada rama sale en una columna a su derecha, con su propio `group`, aunque `git tree` la dibuje todavía en la misma columna porque la historia sea lineal.
- Si una fila tiene un commit de rama pero ninguno de `main`, Graphviz tiende a meter la rama en la columna de `main`. Para evitarlo, se pone en esa fila un nodo invisible en la columna de `main`:
  - Si la línea de `main` no pasa por esa fila, basta con un nodo invisible con la misma etiqueta que el commit de `main` que tiene debajo: `hueco1 [style=invis group=main label="…"]`, unido a él con flechas invisibles (`c6 -> hueco1 -> hueco2 [style=invis]`) y colocado a la izquierda del commit de la rama con `{ rank=same; hueco1 -> c7 [style=invis] }`.
  - Si la línea de `main` sí pasa por esa fila (su commit siguiente está más arriba), la flecha se parte en dos tramos que pasan por un punto diminuto, y a su lado va un nodo invisible ancho que empuja la rama a la derecha: `paso [shape=point width=0.015 height=0.015 color="#4a5b70" fillcolor="#4a5b70" group=main]; hueco [style=invis label="" width=1.4]`, `r -> paso [arrowhead=none headclip=false]; paso -> pr [tailclip=false]` y `{ rank=same; paso -> hueco -> c5 [style=invis] }`. El punto, del color de las flechas, tapa la pequeña separación entre los dos tramos.
- Las filas `rank=same` que sólo ordenan nodos (`[style=invis]`) van separadas de las que colocan referencias (`[class=ref …]`), porque los atributos de una fila se aplican a todas sus flechas.
- `class=huerfano` marca en gris un commit que no está en ninguna rama (o la flecha que lleva a él), y `class=copia` une un commit con su copia (cherry-pick, rebase). El filtro dibuja esos commits con el contorno discontinuo. Para que la vista previa del editor, que no conoce las macros, también lo muestre, el bloque repite el estilo: `o1 [class=huerfano style="rounded,dashed" color=gray50 fontcolor=gray50 label="…"]` y `c -> o1 [class=huerfano style=dashed color=gray50]`. El filtro ignora esos atributos y aplica los suyos.
- `class=nota` es texto sin caja, como el `…` que indica que hay commits anteriores, `class=repo` y `class=accion` sirven para los diagramas de repositorios remotos, y `class=zona` dibuja un recuadro rectangular que no es un commit, como las zonas de Git en 2.2.
- El curso no usa figuras de «antes y después»: cada estado del historial es un diagrama propio, colocado justo después del comando que lo produce. El filtro aún admite dos `subgraph cluster_… { label="Antes" … }`, que apila en el orden en que se escriben, con las referencias de cada cluster dentro de él.

La lista completa de macros está al principio de `pandoc/diagramas.lua`. Cada diagrama debe coincidir con lo que `git tree` muestra en ese punto del ejemplo.

## Licencia

Copyright © 2026 fjramons.

Este curso se distribuye bajo la licencia [GNU Affero General Public License v3.0](LICENSE) (AGPL-3.0). Puedes copiarlo, modificarlo y redistribuirlo, también en un servicio web, siempre que mantengas esta misma licencia y pongas el código fuente de tu versión a disposición de quien la use.
