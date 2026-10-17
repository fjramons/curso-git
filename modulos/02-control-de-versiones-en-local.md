# Módulo 2: Control de versiones en local (bases de Git)

En este módulo, la carpeta `manual-git` se convierte en un repositorio de Git y el libro recibe sus primeros capítulos. Se presentan el ciclo básico de trabajo (modificar, preparar y confirmar), la forma de deshacer cambios, la lectura del historial y la generación del libro en Word con Pandoc.

## 2.1 Inicialización de un repositorio

Un **repositorio** es una carpeta cuyo historial controla Git. El punto de partida es la carpeta vacía creada en el módulo anterior:

```bash
cd ~/proyectos/manual-git
```

Todo libro necesita una presentación, así que crea un fichero `README.md` vacío, que rellenarás enseguida. Después, indica a Git que empiece a controlar la carpeta:

```bash
touch README.md
git init
```

`git init` crea una carpeta oculta `.git` donde Git guardará todo el historial. Puedes verla con `ls -a`. No la toques a mano: si la borras, pierdes el historial completo del proyecto.

Por motivos históricos, Git puede llamar `master` a la rama principal. Hoy lo habitual (y lo que usa GitHub) es llamarla `main`, así que conviene renombrarla:

```bash
git branch -M main
```

Si quieres que todos tus repositorios nuevos empiecen directamente con `main`, ejecuta una vez `git config --global init.defaultBranch main`. Ahora consulta a Git el estado del repositorio:

```bash
git status
```

`git status` será el comando que más uses. La salida indica que la rama actual es `main`, que todavía no hay commits y que `README.md` es un fichero _untracked_ (sin seguimiento): Git lo ve, pero aún no lo controla.

## 2.2 Ciclo de vida de los ficheros: área de staging y commits

En Git, un cambio pasa por tres zonas:

1. **Directorio de trabajo**: los ficheros tal y como los ves y editas.
2. **Área de staging** (o _índice_): una zona intermedia donde se prepara lo que se guardará en el siguiente commit.
3. **Repositorio**: el historial de commits, guardado en `.git`.

`git add` lleva cambios del directorio de trabajo al staging, y `git commit` guarda en el repositorio todo lo que haya en el staging. Esta separación permite decidir qué cambios van juntos en cada commit, aunque hayas modificado muchos ficheros a la vez.

```{.dot caption="Las tres zonas de Git" alt="El directorio de trabajo pasa al staging con git add, y el staging pasa al repositorio con git commit"}
digraph {
  rankdir=LR
  node [shape=box]
  trabajo [class=zona label="Directorio de trabajo"]
  staging [class=zona label="Staging"]
  repo [class=zona label="Repositorio (.git)"]
  trabajo -> staging [class=accion label="  git add  "]
  staging -> repo [class=accion label="  git commit  "]
}
```

El libro se escribe en **Markdown**, un formato de texto plano en el que unos pocos símbolos indican el formato: `#` para los títulos, `**` para la negrita, `-` para las listas… Su sintaxis se explica con detalle en el apartado 6.3, pero no hace falta esperar ni memorizarla: la _Markdown Guide_ (<https://www.markdownguide.org>) la explica paso a paso y su hoja de referencia (<https://www.markdownguide.org/cheat-sheet>) la resume en una página. Consúltala siempre que dudes de cómo dar formato a algo.

Abre `README.md` con tu editor (por ejemplo, `code README.md` si usas VS Code) y escribe una presentación del libro:

```markdown
# Manual de Git

Libro escrito en Markdown durante el curso de Git y GitHub.
```

Guarda el fichero, añádelo al staging y comprueba el estado:

```bash
git add README.md
git status
```

Ahora `README.md` aparece en verde, bajo _Changes to be committed_: está preparado. Guárdalo en el historial con un commit. El mensaje debe explicar brevemente qué cambia:

```bash
git commit -m "Añade el README del libro"
```

El repositorio ya tiene su primer commit. El siguiente paso es escribir el primer capítulo. Los capítulos vivirán en una carpeta `capitulos`, numerados para que se ordenen solos:

```bash
mkdir capitulos
code capitulos/01-que-es-git.md
```

Escribe este contenido (o tu propia versión, con lo que aprendiste en el módulo 1):

```markdown
# ¿Qué es Git?

Git es un sistema de control de versiones distribuido. Guarda el historial completo de un proyecto y permite volver a cualquier versión anterior.

GitHub es una plataforma web que aloja repositorios de Git y facilita la colaboración entre personas.
```

Esta vez se usa `git add -A`, que añade al staging todos los cambios del repositorio (ficheros nuevos, modificados y borrados), estés en la carpeta que estés. Es cómodo, pero revisa antes con `git status` que no se cuela nada que no quieras:

```bash
git add -A
git commit -m "Añade el capítulo 1: qué es Git"
```

En muchos tutoriales verás `git add .`. Hace lo mismo, pero solo con la carpeta actual y sus subcarpetas. Desde la raíz del repositorio el resultado es idéntico, pero dentro de una subcarpeta deja fuera los cambios del resto del proyecto. Úsalo solo cuando quieras limitar a propósito lo que preparas: por ejemplo, `cd capitulos` seguido de `git add .` para incluir solo los capítulos en el commit. En este curso se usa siempre `git add -A`.

El historial de commits se consulta con `git log`:

```bash
git log
```

Cada commit muestra un identificador único (un _hash_ de 40 caracteres como `a1b2c3d…`), el autor, la fecha y el mensaje. El más reciente aparece arriba. Si la lista es larga, muévete con las flechas y sal pulsando `q`.

## 2.3 Descartar cambios antes de guardar (checkout y reset)

Equivocarse es parte del trabajo. Para practicar cómo recuperar un fichero, estropea a propósito el capítulo 1. Este comando sobrescribe el fichero entero con una sola línea:

```bash
echo "Texto que he escrito sin querer" > capitulos/01-que-es-git.md
git status
```

`git status` muestra el fichero como _modified_ en rojo: el cambio está en el directorio de trabajo, pero no en el staging. Para descartarlo y recuperar la versión del último commit:

```bash
git checkout capitulos/01-que-es-git.md
```

Abre el fichero: vuelve a tener su contenido original. Cuidado, porque los cambios descartados así no se pueden recuperar.

Repite ahora el error, pero esta vez llega a añadirlo al staging:

```bash
echo "Texto que he escrito sin querer" > capitulos/01-que-es-git.md
git add capitulos/01-que-es-git.md
```

Para sacar el fichero del staging sin perder el cambio se usa `git reset HEAD`. `HEAD` es el nombre que da Git al commit en el que se encuentra el repositorio en ese momento:

```bash
git reset HEAD capitulos/01-que-es-git.md
git status
```

El fichero vuelve a aparecer en rojo: ya no está preparado, pero el cambio sigue en el directorio de trabajo. Descártalo del todo como antes:

```bash
git checkout capitulos/01-que-es-git.md
```

En las versiones modernas de Git verás que `git status` sugiere `git restore <fichero>` y `git restore --staged <fichero>`. Hacen exactamente lo mismo que `git checkout <fichero>` y `git reset HEAD <fichero>`, con nombres más claros. Puedes usar los que prefieras.

## 2.4 Personalización del historial y creación de alias

Para que el historial tenga algo más de contenido, añade un segundo capítulo con los comandos vistos hasta ahora. Crea `capitulos/02-primeros-comandos.md`:

````markdown
# Primeros comandos

Para crear un repositorio y guardar el primer cambio:

```bash
git init
git add README.md
git commit -m "Primer commit"
```

Con `git status` se ve el estado de los ficheros y con `git log`, el historial.
````

Y guárdalo con un commit:

```bash
git add -A
git commit -m "Añade el capítulo 2: primeros comandos"
```

`git log` muestra mucha información por commit. Algunas opciones lo hacen más visual. `--graph` dibuja las ramas como un gráfico a la izquierda:

```bash
git log --graph
```

`--pretty=oneline` muestra cada commit en una sola línea, con el hash completo:

```bash
git log --graph --pretty=oneline
```

Y esta es la combinación más útil en el día a día: `--decorate` indica dónde están las ramas y etiquetas, `--all` muestra todas las ramas (no solo la actual) y `--oneline` acorta el hash a 7 caracteres:

```bash
git log --graph --decorate --all --oneline
```

La salida será parecida a esta:

```text
* 3f2a1b9 (HEAD -> main) Añade el capítulo 2: primeros comandos
* 8c4d2e7 Añade el capítulo 1: qué es Git
* 1a9f0c3 Añade el README del libro
```

A lo largo del curso, el historial se dibuja en diagramas como este, que representa la misma salida:

```{.dot caption="Historial con tres commits en la rama main" alt="Tres commits encadenados, del README al capítulo 2. La rama main apunta al último y HEAD apunta a main"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  c1 [label="1a9f0c3 Añade el README del libro"]; c2 [label="8c4d2e7 Añade el capítulo 1: qué es Git"]; c3 [label="3f2a1b9 Añade el capítulo 2: primeros comandos"]
  c1 -> c2 -> c3
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]
  { rank=same; c3 -> main -> HEAD [class=ref dir=back] }
}
```

Cada caja es un commit, con su mensaje, y el más reciente está arriba, como en `git log`. Las flechas unen cada commit con el siguiente, en el orden en que se crearon. Internamente, cada commit guarda cuál es su commit anterior, su _padre_, y así se encadena el historial. A la derecha, en verde, está la rama `main`, un nombre que apunta al último commit, y `HEAD`, en naranja, indica dónde estás: en la rama `main`. Es lo que `git log` resume con `(HEAD -> main)`.

Escribir esto cada vez es tedioso, así que conviene crear un **alias**: un comando de Git propio que equivale a otro más largo. Se llamará `tree`:

```bash
git config --global alias.tree "log --graph --decorate --all --oneline"
```

A partir de ahora, `git tree` muestra el historial con este formato. Se usa durante todo el curso.

## 2.5 Ignorar ficheros no deseados (.gitignore)

Es hora de convertir el libro a Word. Para ello necesitas Pandoc (y Typst si quieres el PDF): si aún no los tienes, instálalos siguiendo el [Anexo: dependencias de los ejemplos](09-anexo-dependencias-de-los-ejemplos.md). Recuerda que no forman parte de Git: solo hacen falta para generar el libro. Primero, crea `metadata.yaml`, con los datos que Pandoc pondrá en la portada:

```yaml
title: Manual de Git
subtitle: Lo que aprendí en el curso de Git y GitHub
author: Tu Nombre
lang: es-ES
```

Después, crea el script `build.sh`, que genera el libro en tres formatos dentro de una carpeta `dist`:

```bash
#!/usr/bin/env bash
# Genera el Manual de Git en Word, PDF y HTML a partir de los capítulos
set -euo pipefail

VERSION="${1:-}"
NOMBRE="manual-git${VERSION:+-$VERSION}"
OPCIONES=(--metadata-file=metadata.yaml --toc)

mkdir -p dist

pandoc "${OPCIONES[@]}" capitulos/*.md -o "dist/$NOMBRE.docx"
echo "Generado dist/$NOMBRE.docx"

if command -v typst > /dev/null; then
  pandoc "${OPCIONES[@]}" capitulos/*.md --pdf-engine=typst -o "dist/$NOMBRE.pdf"
  echo "Generado dist/$NOMBRE.pdf"
else
  echo "Aviso: Typst no está instalado, así que no se genera el PDF" >&2
fi

pandoc "${OPCIONES[@]}" capitulos/*.md --standalone --embed-resources -o dist/index.html
echo "Generado dist/index.html"
```

Qué hace cada parte:

- `set -euo pipefail` detiene el script en cuanto falla cualquier comando, en lugar de seguir como si nada.
- `VERSION` es un argumento opcional. Si ejecutas `./build.sh v1.0.0`, los ficheros se llamarán `manual-git-v1.0.0.docx` y `manual-git-v1.0.0.pdf`. El módulo 8 lo utiliza para publicar versiones.
- `capitulos/*.md` toma todos los capítulos en orden alfabético. Por eso se numeran con dos cifras: `01`, `02`…
- `--toc` añade un índice al principio del libro.
- El PDF solo se genera si Typst está instalado. Si no, el script avisa y continúa.
- `index.html` es una versión web del libro en un único fichero, que se publica en GitHub Pages en el módulo 8.

Da permiso de ejecución al script y lánzalo:

```bash
chmod +x build.sh
./build.sh
```

Abre `dist/manual-git.docx` con Word o LibreOffice: ahí está tu libro, con portada, índice y los dos capítulos. Ahora mira qué piensa Git de todo esto:

```bash
git status
```

Git muestra como nuevos `metadata.yaml`, `build.sh` y la carpeta `dist/`. Los dos primeros son código fuente del libro y deben guardarse, pero `dist/` contiene ficheros generados: se pueden volver a crear en cualquier momento con `./build.sh`, ocupan espacio y cambian cada vez. No tiene sentido versionarlos.

Para eso existe el fichero `.gitignore`: una lista de rutas y patrones que Git debe ignorar. Créalo:

```bash
touch .gitignore
# A partir de aquí se edita el fichero añadiendo rutas o patrones, p. ej. *.log o .DS_Store
```

Abre `.gitignore` con tu editor y escribe:

```text
# Libro generado por build.sh
dist/

# Ficheros temporales de Word y LibreOffice
~$*.docx
.~lock.*

# Ficheros del sistema operativo
.DS_Store
Thumbs.db
```

Cada línea es un patrón: `dist/` ignora la carpeta completa, `*` es un comodín que equivale a cualquier texto y las líneas que empiezan por `#` son comentarios. Comprueba el efecto:

```bash
git status
```

`dist/` ha desaparecido de la lista. No hace falta escribir los `.gitignore` desde cero: GitHub mantiene en [github/gitignore](https://github.com/github/gitignore) plantillas para casi cualquier lenguaje, editor y sistema operativo, que puedes copiar y adaptar. Ahora sí, guarda el script, los metadatos y el propio `.gitignore`, que también debe versionarse para que se aplique en cualquier copia del proyecto:

```bash
git add -A
git commit -m "Añade el script de generación del libro con Pandoc"
```

## 2.6 Ver diferencias entre versiones

Antes de hacer un commit conviene revisar qué ha cambiado exactamente. Añade un párrafo al final de `capitulos/01-que-es-git.md`, separado del anterior por una línea en blanco, como todos los párrafos en Markdown:

```markdown
Git fue creado en 2005 por Linus Torvalds para desarrollar el núcleo de Linux.
```

Y pide a Git las diferencias:

```bash
git diff
```

La salida muestra el fichero modificado y, debajo, las líneas añadidas en verde con un `+` delante (las eliminadas aparecerían en rojo con un `-`). `git diff` compara el directorio de trabajo con el staging, así que si añades el cambio al staging y repites el comando, no verás nada. Para revisar lo que ya está preparado usa `--staged`:

```bash
git add -A
git diff
git diff --staged
```

Cuando estés conforme, guarda el cambio:

```bash
git commit -m "Añade el origen de Git al capítulo 1"
```

Ya sabes crear un repositorio, guardar cambios, deshacerlos, leer el historial y generar el libro. Con los comandos de este módulo se resuelve buena parte del trabajo diario con Git; si olvidas alguno, búscalo en la [hoja de referencia de Git](https://git-scm.com/cheat-sheet) del apartado 1.2. El siguiente módulo explica cómo viajar por ese historial.
