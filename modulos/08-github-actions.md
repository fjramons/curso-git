# Módulo 8: GitHub Actions (automatización y CI/CD)

Hasta ahora, hemos revisado y generado el libro a mano. En este módulo vamos a dejar que GitHub se encargue de esas tareas: revisará la sintaxis de los capítulos en cada pull request, publicará una Release con el Word y el PDF y una web con la versión HTML cada vez que creemos una etiqueta de versión, y comprobará cada semana que los enlaces del libro siguen funcionando.

## 8.1 ¿Qué es GitHub Actions?

**GitHub Actions** es el sistema de automatización de GitHub. Ejecuta tareas en máquinas de GitHub cuando ocurre algo en el repositorio (un push, un pull request, una etiqueta nueva…) o en momentos programados. Se usa sobre todo para dos prácticas:

- **Integración continua** (_continuous integration_, CI): comprobar automáticamente cada cambio antes de integrarlo, con tests, compilación o revisiones de estilo. En nuestro libro, la revisión de la sintaxis Markdown.
- **Despliegue continuo** (_continuous deployment_, CD): publicar automáticamente el resultado cuando un cambio está listo. En nuestro libro, las Releases y la web.

Además, sirve para cualquier tarea repetitiva, como revisar enlaces, etiquetar issues o generar informes. Antes de escribir nuestro primer workflow, conviene conocer sus piezas:

- **Workflow**: un proceso automático, definido en un fichero YAML dentro de la carpeta `.github/workflows/` del repositorio.
- **Evento**: lo que dispara el workflow, como un `push`, un pull request, una etiqueta nueva o una hora programada.
- **Job**: un conjunto de pasos que se ejecuta en una máquina. Un workflow puede tener varios jobs, en paralelo o encadenados.
- **Step**: cada paso de un job. Puede ser un comando de terminal (`run`) o una **action** (`uses`), un bloque reutilizable que alguien ha publicado para una tarea común.
- **Runner**: la máquina virtual en la que se ejecuta un job. GitHub la crea limpia para cada ejecución y la destruye al terminar.

En este módulo veremos lo necesario para automatizar nuestro libro. Para todo lo demás, la [documentación de GitHub Actions](https://docs.github.com/es/actions) explica cada pieza con ejemplos.

El diagrama muestra cómo encajan estas piezas en el workflow que vamos a construir a lo largo del módulo:

```{.dot caption="Piezas de un workflow de GitHub Actions" alt="Un evento, como un push o un pull request, dispara el workflow ci.yml. El workflow tiene dos jobs, lint y release, cada uno en su propio runner y con su lista de steps. release empieza cuando lint ha terminado"}
digraph {
  rankdir=TB
  compound=true
  newrank=true
  labelloc=t
  node [shape=box]
  evento [class=zona label="Evento: push, pull request, etiqueta…"]
  subgraph cluster_workflow {
    label="Workflow: .github/workflows/ci.yml"
    subgraph cluster_lint {
      label="Job lint (runner Ubuntu)"
      l1 [class=zona label="Step: descarga el repositorio"]
      l2 [class=zona label="Step: revisa la sintaxis"]
      l1 -> l2 [class=accion]
    }
    subgraph cluster_release {
      label="Job release (otro runner Ubuntu)"
      r1 [class=zona label="Step: instala Pandoc y Typst"]
      r2 [class=zona label="Step: genera el libro"]
      r3 [class=zona label="Step: crea la Release"]
      r1 -> r2 -> r3 [class=accion]
    }
  }
  evento -> l1 [class=accion lhead=cluster_workflow]
  { rank=same; l1 -> r1 [class=accion label="  después  " ltail=cluster_lint lhead=cluster_release] }
}
```

GitHub ofrece runners con Ubuntu (`ubuntu-latest`), Windows (`windows-latest`) y macOS (`macos-latest`), y cada job elige el suyo. Linux es el más rápido y el que se usa casi siempre, mientras que Windows y macOS sirven para probar programas en esos sistemas. En los repositorios públicos, los runners estándar son gratuitos y sin límite de minutos. En los privados, en cambio, cada cuenta tiene una cantidad de minutos gratuitos al mes, y los runners de Windows y macOS gastan esos minutos más deprisa que los de Linux.

## 8.2 Creación del primer workflow

Como cualquier cambio del libro, el CI se prepara en una rama, siguiendo GitHub flow. Partimos de la última versión de `main` y creamos la rama:

```bash
cd ~/proyectos/manual-git
git switch main
git pull
git switch -c ci
```

Los workflows se guardan en la carpeta `.github/workflows/` del repositorio, un fichero YAML por workflow. GitHub ejecuta todos los que encuentra en esa carpeta, y el nombre del fichero es libre. Creamos el primero:

```bash
mkdir -p .github/workflows
code .github/workflows/ci.yml
```

Para empezar, este primer workflow sólo revisará la sintaxis de los ficheros Markdown. Escribe este contenido:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  lint:
    name: Revisar la sintaxis Markdown
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: DavidAnson/markdownlint-cli2-action@v24
        with:
          globs: "**/*.md"
```

En los dos apartados siguientes veremos qué significa cada línea, así que todavía no hagas commit.

## 8.3 Estructura y sintaxis básica de un workflow

YAML es un formato de texto para datos estructurados, pensado para que lo escriban personas. Para leer y escribir workflows basta con conocer tres reglas:

- Cada línea `clave: valor` define un dato. El valor puede ser un texto, un número o un bloque de líneas más sangradas.
- La sangría indica qué va dentro de qué. Se hace siempre con espacios, nunca con tabuladores, y todas las líneas de un mismo nivel deben tener la misma sangría.
- Las líneas que empiezan por `-` son elementos de una lista. `[main]` es la misma lista escrita en una sola línea, y `#` empieza un comentario.

Con eso ya podemos leer nuestro workflow. Sus claves principales son:

- `name`: el nombre del workflow, el que aparece en la pestaña _Actions_ de GitHub.
- `on`: los eventos que lo disparan. Aquí, un `push` a `main` (lo que ocurre al fusionar un pull request) y cualquier pull request, cada vez que se abre o se actualiza.
- `jobs`: los jobs del workflow. `lint` es el identificador del job, el que se usa para referirse a él desde otros jobs, y `name` su nombre visible.
- `runs-on`: el runner en el que se ejecuta el job.
- `steps`: la lista de pasos, que se ejecutan en orden. Si uno falla, los siguientes no se ejecutan y el job termina con error.

No hace falta recordar todas las claves posibles: la [sintaxis de flujos de trabajo](https://docs.github.com/es/actions/reference/workflows-and-actions/workflow-syntax) de la documentación de GitHub las describe todas.

## 8.4 Uso de actions de GitHub y de la comunidad (Marketplace)

Los dos pasos del job usan `uses`, que ejecuta una action. Una action es un bloque reutilizable publicado en un repositorio de GitHub, y se indica con la forma `propietario/repositorio@versión`. En el [Marketplace](https://github.com/marketplace?type=actions) hay miles, para casi cualquier tarea, así que antes de usar una conviene comprobar quién la publica (las de GitHub están en la organización `actions`, y las de empresas verificadas llevan una insignia), que esté mantenida y que tenga buena documentación. Estas son las dos que usamos:

- `actions/checkout@v7`, publicada por GitHub, descarga el repositorio en el runner. Como el runner empieza vacío, casi todos los workflows empiezan con este paso.
- `DavidAnson/markdownlint-cli2-action@v24`, publicada por el autor de markdownlint, ejecuta [markdownlint](https://github.com/DavidAnson/markdownlint), una herramienta que comprueba que los ficheros Markdown siguen unas reglas de estilo.

`with` pasa parámetros a la action, y cada action documenta los suyos en la página de su repositorio. En nuestro caso, `globs` indica qué ficheros revisar: todos los `.md` del repositorio, en cualquier carpeta.

La versión que sigue a `@` es una etiqueta del repositorio de la action. Una etiqueta como `@v7` sigue automáticamente la última versión 7.x, que recibe correcciones sin cambios incompatibles, y es lo que recomienda la documentación oficial. En proyectos con requisitos de seguridad estrictos se fija, en su lugar, el identificador completo del commit de la action (`@<sha>`), para que nadie pueda cambiar lo que se ejecuta.

Falta decirle a markdownlint qué reglas aplicar. Se configuran en un fichero `.markdownlint.jsonc` en la raíz del repositorio, que crearemos con este contenido:

```jsonc
{
  // Párrafos en una sola línea, sin límite de longitud
  "MD013": false,
  // Cursivas con _
  "MD049": { "style": "underscore" },
  // Viñetas con -
  "MD004": { "style": "dash" }
}
```

Por defecto, markdownlint aplica unas 50 reglas (títulos rodeados de líneas en blanco, bloques de código con lenguaje, un solo título de nivel 1, etc.). Este fichero desactiva el límite de longitud de línea y fija el estilo de cursivas y viñetas de nuestro libro. Si tienes [Node.js](https://nodejs.org) instalado, puedes ejecutar la misma revisión en local con `npx markdownlint-cli2 "**/*.md"`.

Con los dos ficheros listos, los guardamos y subimos la rama:

```bash
git add -A
git commit -m "Añade el CI con la revisión de sintaxis"
git push -u origin ci
```

Ahora abre el pull request en GitHub, como en el apartado 7.2. Esta vez notarás algo nuevo: al final de la página, junto al botón _Merge pull request_, aparece una sección de comprobaciones (_checks_) con _CI / Revisar la sintaxis Markdown_, que muestra un círculo amarillo mientras se ejecuta y un check verde al terminar. La pestaña _Checks_ del pull request muestra el detalle. Esta es la gran ventaja del CI en un pull request: antes de fusionar, cualquiera ve si el cambio cumple las reglas del proyecto.

Fusiona el pull request y borra la rama en GitHub. Después, actualizamos la copia local:

```bash
git switch main
git pull --prune
git branch -d ci
```

Al fusionar, el push a `main` dispara de nuevo el workflow, de modo que en la pestaña _Actions_ del repositorio verás dos ejecuciones: la del pull request y la de `main`.

## 8.5 Ejecución de scripts y comandos en la máquina virtual

Con la revisión automática en marcha, el siguiente paso es publicar cada versión del libro sin intervención manual. Lo que queremos es que, al subir una etiqueta como `v1.1.0`, GitHub genere el Word y el PDF y los adjunte a una Release. Como siempre, preparamos el cambio en una rama nueva:

```bash
git switch -c publicacion
```

Abre `.github/workflows/ci.yml`. Primero hay que añadir las etiquetas de versión a los eventos, para que el workflow también se ejecute al subir una etiqueta que empiece por `v`:

```yaml
on:
  push:
    branches: [main]
    tags: ["v*"]
  pull_request:
```

Después, añade al final un segundo job, `release`, al mismo nivel que `lint`:

```yaml
  release:
    name: Generar y publicar la release
    if: startsWith(github.ref, 'refs/tags/v')
    needs: lint
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v7
      - uses: pandoc/actions/setup@v1
      - uses: typst-community/setup-typst@v5
      - name: Generar el libro
        run: bash build.sh "$GITHUB_REF_NAME"
      - name: Crear la release
        env:
          GH_TOKEN: ${{ github.token }}
        run: gh release create "$GITHUB_REF_NAME" dist/*.docx dist/*.pdf --title "Manual de Git $GITHUB_REF_NAME" --generate-notes
```

A diferencia de `lint`, este job usa `run`, que ejecuta comandos en la terminal del runner (bash, en Ubuntu), igual que en tu ordenador. Veamos qué hace cada paso:

- Los tres primeros preparan la máquina: descargan el repositorio e instalan Pandoc y Typst con sus actions oficiales. Es lo mismo que se hace a mano en el anexo de dependencias, pero de forma automática.
- `Generar el libro` ejecuta el mismo `build.sh` del apartado 2.5, y `name` da a ese paso un nombre legible en los registros. Se lanza con `bash build.sh` en lugar de `./build.sh` para no depender del permiso de ejecución, que se pierde si alguien edita el script desde Windows.
- `Crear la release` usa `gh`, la CLI oficial de GitHub, que viene instalada en los runners. Crea una Release con el nombre de la etiqueta y le adjunta el `.docx` y el `.pdf`, mientras que `--generate-notes` escribe automáticamente las notas con los cambios y los pull requests desde la versión anterior.

Para hacer su trabajo, los comandos usan información del evento:

- `$GITHUB_REF_NAME` es una variable de entorno que GitHub define en todos los runners. Cuando el evento es una etiqueta, contiene su nombre (por ejemplo, `v1.1.0`), así que los ficheros se llamarán `manual-git-v1.1.0.docx` y `manual-git-v1.1.0.pdf`.
- `${{ github.token }}` es una _expresión_, es decir, algo que GitHub sustituye por su valor antes de ejecutar el paso. En este caso, un token temporal que permite a `gh` actuar sobre el repositorio. `env` lo pasa al paso como variable de entorno, que es donde `gh` lo busca.

Por último, las dos claves nuevas del principio del job controlan cuándo se ejecuta:

- `if` pone una condición: el job sólo se ejecuta si el evento es una etiqueta que empieza por `v`. En un push a `main` o en un pull request, aparece como omitido (_skipped_).
- `needs: lint` encadena los jobs: `release` espera a que `lint` termine bien. Así, nunca se publica un libro con errores de sintaxis. Sin `needs`, los dos jobs se ejecutarían a la vez.

Nos queda el bloque `permissions`, que veremos en el apartado siguiente junto con el último job del workflow.

## 8.6 Configuración de permisos y publicación en GitHub Pages

Cada ejecución recibe un token temporal, el mismo de `${{ github.token }}`, con el que el workflow actúa sobre el repositorio. `permissions` limita lo que puede hacer ese token, y es una buena práctica de seguridad darle sólo lo imprescindible: si una action se comportara mal, no podría hacer más daño que el que permiten sus permisos. Los permisos se pueden definir para todo el workflow y ampliar en cada job. Empezamos por el permiso global de sólo lectura, que va debajo de `on`, antes de `jobs`:

```yaml
permissions:
  contents: read
```

El job `release` amplía ese permiso con `contents: write`, porque necesita crear la Release.

El último job publicará la versión HTML del libro en **GitHub Pages**, el servicio de alojamiento web gratuito de GitHub. Pages sirve sitios estáticos (HTML, CSS, JavaScript e imágenes, sin base de datos ni código de servidor) en una dirección como `https://<usuario>.github.io/<repositorio>/`. El contenido puede salir directamente de una rama del repositorio o, como en nuestro caso, de un workflow que genera los ficheros y los despliega. Se usa mucho para documentación, blogs y páginas de proyectos.

La publicación tiene dos partes. Primero, añade al final de los pasos de `release` uno que empaquete la carpeta `dist`, donde `build.sh` deja el `index.html`, como la web que se publicará:

```yaml
      - uses: actions/upload-pages-artifact@v5
        with:
          path: dist
```

Y después, añade al final del fichero el job `pages`, que se encarga del despliegue:

```yaml
  pages:
    name: Publicar la web en GitHub Pages
    needs: release
    runs-on: ubuntu-latest
    permissions:
      pages: write
      id-token: write
    concurrency:
      group: pages
      cancel-in-progress: false
    environment:
      name: github-pages
      url: ${{ steps.despliegue.outputs.page_url }}
    steps:
      - id: despliegue
        uses: actions/deploy-pages@v5
```

Este job espera a `release` y despliega en GitHub Pages el paquete que acaba de subir. Tiene tres detalles que conviene entender:

- Necesita los permisos `pages: write`, para publicar, e `id-token: write`, con el que Pages comprueba que el despliegue viene de este workflow.
- Se ejecuta en el entorno (_environment_) `github-pages`, que GitHub crea al activar Pages. La línea `url` hace que la dirección de la web aparezca en el resumen de la ejecución: `steps.despliegue.outputs.page_url` es un dato que devuelve el paso con `id: despliegue`.
- `concurrency` evita que haya dos despliegues de Pages a la vez: si se publican dos etiquetas seguidas, el segundo despliegue espera en cola y el que está en marcha no se cancela.

`release` y `pages` van en dos jobs separados porque son dos tareas distintas: publicar ficheros descargables (la Release) y desplegar un sitio web (Pages). El diagrama muestra cómo se encadenan los tres jobs según el evento:

```{.dot caption="Jobs del workflow CI según el evento" alt="Un push a main o un pull request sólo ejecuta lint, y release y pages se omiten. Una etiqueta v ejecuta lint, después release y después pages"}
digraph {
  rankdir=LR
  node [shape=box]
  cambio [class=zona label="Push a main\no pull request"]
  etiqueta [class=zona label="Etiqueta v*\n(por ejemplo, v1.1.0)"]
  lint1 [class=zona label="lint"]
  omitidos [class=nota label="release y pages\nse omiten (if)"]
  lint2 [class=zona label="lint"]
  release [class=zona label="release:\nWord, PDF y Release"]
  pages [class=zona label="pages:\nweb en GitHub Pages"]
  cambio -> lint1 [class=accion]
  lint1 -> omitidos [class=accion style=dashed]
  etiqueta -> lint2 [class=accion]
  lint2 -> release [class=accion label="  needs  "]
  release -> pages [class=accion label="  needs  "]
}
```

Con todas las piezas en su sitio, el fichero completo queda así:

```yaml
name: CI

on:
  push:
    branches: [main]
    tags: ["v*"]
  pull_request:

permissions:
  contents: read

jobs:
  lint:
    name: Revisar la sintaxis Markdown
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: DavidAnson/markdownlint-cli2-action@v24
        with:
          globs: "**/*.md"

  release:
    name: Generar y publicar la release
    if: startsWith(github.ref, 'refs/tags/v')
    needs: lint
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v7
      - uses: pandoc/actions/setup@v1
      - uses: typst-community/setup-typst@v5
      - name: Generar el libro
        run: bash build.sh "$GITHUB_REF_NAME"
      - name: Crear la release
        env:
          GH_TOKEN: ${{ github.token }}
        run: gh release create "$GITHUB_REF_NAME" dist/*.docx dist/*.pdf --title "Manual de Git $GITHUB_REF_NAME" --generate-notes
      - uses: actions/upload-pages-artifact@v5
        with:
          path: dist

  pages:
    name: Publicar la web en GitHub Pages
    needs: release
    runs-on: ubuntu-latest
    permissions:
      pages: write
      id-token: write
    concurrency:
      group: pages
      cancel-in-progress: false
    environment:
      name: github-pages
      url: ${{ steps.despliegue.outputs.page_url }}
    steps:
      - id: despliegue
        uses: actions/deploy-pages@v5
```

Lo guardamos y lo integramos con GitHub flow:

```bash
git add -A
git commit -m "Publica cada versión como Release y en GitHub Pages"
git push -u origin publicacion
```

Abre el pull request. En las comprobaciones verás que `lint` pasa y que `release` y `pages` aparecen como omitidos, justo lo que esperábamos, porque el evento es un pull request y no una etiqueta. Fusiónalo y borra la rama en GitHub. Después, actualizamos la copia local:

```bash
git switch main
git pull --prune
git branch -d publicacion
```

Antes de publicar la primera versión hay que activar Pages en el repositorio. En GitHub, ve a _Settings_ → _Pages_ y, en _Build and deployment_ → _Source_, elige **GitHub Actions**.

Hay, además, un detalle que suele pillar por sorpresa. Al activar Pages, GitHub crea el entorno `github-pages` con una regla de protección que sólo permite desplegar desde la rama por defecto, pero nuestro workflow despliega desde etiquetas, así que hay que permitirlas. Para ello, ve a _Settings_ → _Environments_ → _github-pages_ y, en _Deployment branches and tags_, pulsa _Add deployment branch or tag rule_, elige _Ref type: Tag_, escribe el patrón `v*` y guarda. Sin esta regla, el job de Pages fallaría con un mensaje de que la etiqueta no puede desplegar en `github-pages`.

Por cierto, los permisos de escritura también permiten que un workflow haga commits en el repositorio, por ejemplo para regenerar un fichero de estadísticas y subirlo. Se hace con `contents: write` y una action como [`stefanzweifel/git-auto-commit-action`](https://github.com/stefanzweifel/git-auto-commit-action), que hace commit y push de los cambios que haya dejado el job. Los commits hechos con el token del workflow no disparan otros workflows, y así se evita que un workflow que hace commits se dispare a sí mismo sin fin. Nuestro libro no necesita commits automáticos, pero conviene conocer la técnica.

## 8.7 Programación de tareas recurrentes (cron)

Algunas tareas no dependen de los cambios del repositorio. Los enlaces del libro a páginas externas, por ejemplo, pueden dejar de funcionar sin que nadie toque el libro, simplemente porque la otra web cambia o desaparece. Para detectarlo necesitamos un workflow que se ejecute solo, cada cierto tiempo, y que nos avise si encuentra enlaces rotos. Lo preparamos en una rama:

```bash
git switch -c enlaces
code .github/workflows/enlaces.yml
```

Y le damos este contenido:

```yaml
name: Enlaces

on:
  schedule:
    # Todos los lunes a las 06:00 (UTC)
    - cron: "0 6 * * 1"
  workflow_dispatch:

permissions:
  contents: read
  issues: write

jobs:
  enlaces:
    name: Revisar los enlaces
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - name: Comprobar los enlaces
        id: lychee
        uses: lycheeverse/lychee-action@v2
        with:
          args: --no-progress "./**/*.md"
          fail: false
      - name: Abrir un issue si hay enlaces rotos
        if: steps.lychee.outputs.exit_code != 0
        env:
          GH_TOKEN: ${{ github.token }}
        run: gh issue create --title "Enlaces rotos" --body-file lychee/out.md
```

La novedad está en el evento `schedule`, que ejecuta el workflow en los momentos que indica una expresión **cron**, formada por cinco campos separados por espacios:

| Campo | Valores | En `0 6 * * 1` |
| --- | --- | --- |
| Minuto | 0-59 | 0 |
| Hora | 0-23 | 6 |
| Día del mes | 1-31 | cualquiera (`*`) |
| Mes | 1-12 | cualquiera (`*`) |
| Día de la semana | 0-6 (0 es domingo) | 1 (lunes) |

Así, `0 0 * * *` sería todos los días a medianoche y `*/15 * * * *`, cada 15 minutos. Para comprobar una expresión antes de usarla, escríbela en [crontab.guru](https://crontab.guru/), que la traduce a lenguaje natural (en inglés). Además, hay que tener en cuenta varias particularidades de `schedule`:

- Las horas son siempre UTC, no la hora local.
- Sólo se ejecuta el workflow de la rama por defecto (`main`).
- En momentos de mucha carga, la ejecución puede retrasarse unos minutos.
- En los repositorios públicos, GitHub desactiva los workflows programados si el repositorio pasa 60 días sin actividad.

El segundo evento, `workflow_dispatch`, permite lanzar el workflow a mano con un botón en la web, sin esperar al lunes, lo que resulta muy útil para probarlo.

En cuanto al job, sus tres pasos trabajan en cadena:

- [lychee](https://github.com/lycheeverse/lychee), un comprobador de enlaces, revisa todos los ficheros Markdown y escribe un informe en `lychee/out.md`. `fail: false` evita que el job termine con error cuando encuentra enlaces rotos, porque el objetivo es avisar, no marcar el repositorio en rojo.
- `id: lychee` da un nombre al paso, y con él el siguiente puede leer sus resultados (_outputs_). `steps.lychee.outputs.exit_code` es el código de salida de lychee, que es distinto de 0 si ha encontrado enlaces rotos.
- Sólo en ese caso, `gh issue create` abre un issue con el informe como descripción. Por eso el workflow pide el permiso `issues: write`.

El diagrama resume el recorrido:

```{.dot caption="Workflow de revisión semanal de enlaces" alt="Cada lunes a las 6:00 UTC, o al pulsar Run workflow, lychee revisa los enlaces. Si hay enlaces rotos, se abre un issue con el informe; si no, el workflow termina sin hacer nada más"}
digraph {
  rankdir=LR
  node [shape=box]
  lunes [class=zona label="Cada lunes\n06:00 UTC"]
  boton [class=zona label="Botón\nRun workflow"]
  lychee [class=zona label="lychee revisa\nlos enlaces"]
  pregunta [class=zona label="¿Enlaces rotos?"]
  issue [class=zona label="Abre un issue\ncon el informe"]
  fin [class=nota label="Termina sin\nhacer nada más"]
  lunes -> lychee [class=accion]
  boton -> lychee [class=accion]
  lychee -> pregunta [class=accion]
  pregunta -> issue [class=accion label="  sí  "]
  pregunta -> fin [class=accion label="  no  "]
}
```

Mientras no se corrijan los enlaces, cada lunes se abrirá un issue nuevo. Cuando los arregles, cierra el issue desde su página o desde el pull request con la corrección, escribiendo `Closes #<número>` en su descripción.

Como siempre, lo integramos con GitHub flow:

```bash
git add -A
git commit -m "Revisa los enlaces cada semana"
git push -u origin enlaces
```

Abre el pull request, fusiónalo y borra la rama. Después, actualizamos la copia local:

```bash
git switch main
git pull --prune
git branch -d enlaces
```

## 8.8 Supervisión y depuración de los workflows

La pestaña _Actions_ del repositorio reúne todas las ejecuciones. A la izquierda están los workflows (_CI_ y _Enlaces_) y, en el centro, la lista de ejecuciones con su estado: un círculo amarillo si está en marcha, un check verde si ha terminado bien y una cruz roja si ha fallado. Al abrir una ejecución se ven sus jobs, unidos por flechas según `needs`, y al abrir un job, el registro (_log_) de cada paso, con la misma salida que verías en la terminal del runner.

Un buen primer ejercicio es probar el workflow de enlaces sin esperar al lunes. En _Actions_, elige _Enlaces_ a la izquierda y pulsa _Run workflow_ → _Run workflow_. Cuando termine, abre el job y despliega el paso _Comprobar los enlaces_: el registro enumera cada enlace revisado y su resultado. Si alguno estuviera roto, verías también el issue nuevo en la pestaña _Issues_.

Lo más interesante, sin embargo, es ver qué ocurre cuando algo falla. Para ello vamos a introducir un error a propósito en una rama de prueba: una viñeta con asterisco al final de `capitulos/05-github.md`, que incumple la regla MD004. Empezamos por la rama:

```bash
git switch -c prueba-ci
```

Añade al final del capítulo 5 esta viñeta:

```markdown
* Una viñeta con el estilo equivocado.
```

Y súbela como si fuera un cambio normal:

```bash
git add -A
git commit -m "Añade una viñeta al capítulo 5"
git push -u origin prueba-ci
```

Ya tenemos el escenario: un pull request con un error que el CI debería detectar. Abre el pull request y verás que esta vez la comprobación termina con una cruz roja, que el pull request avisa de que hay comprobaciones fallidas y que GitHub te envía un correo. Lo que queremos ahora es averiguar qué ha fallado. Pulsa _Details_ junto a la comprobación (o abre la pestaña _Checks_ del pull request) y despliega el paso de markdownlint: el registro indica el fichero, la línea y la regla incumplida (`MD004/ul-style`). Con esa información, quien envió el cambio sabe exactamente qué corregir antes de que se fusione.

Además de leer el registro, desde la página de la ejecución puedes:

- Pulsar _Re-run jobs_ para repetir la ejecución, entera (_Re-run all jobs_) o sólo los jobs que han fallado (_Re-run failed jobs_). Es útil cuando el fallo es puntual (un servidor que no respondía, por ejemplo) y no del código.
- Activar _Enable debug logging_ al repetirla, para que el registro muestre más detalle.

Como la viñeta era sólo una prueba, cierra el pull request sin fusionarlo (_Close pull request_) y borra la rama en GitHub. Después, borramos también la rama local, esta vez con `-D`, porque sus cambios no se han fusionado:

```bash
git switch main
git pull --prune
git branch -D prueba-ci
```

En los proyectos con varias personas, conviene impedir que se fusione un pull request con la comprobación en rojo. Se configura en _Settings_ → _Rules_ → _Rulesets_ → _New ruleset_ → _New branch ruleset_: se aplica a la rama por defecto (`main`) y se activa la regla _Require status checks to pass before merging_ con la comprobación del CI.

## 8.9 Publicar una versión

Ha llegado el momento de comprobar que todo funciona de principio a fin publicando la versión 1.1.0, que incluye el capítulo 7 y la automatización. Aprovecharemos además para que el `README.md` muestre una insignia (_badge_) con el estado del CI. Preparamos la versión en una rama:

```bash
git switch -c version-1.1.0
```

Cambia en `metadata.yaml` la línea `date` a `Versión 1.1.0` y añade debajo del título del `README.md` esta línea, separada del título por una línea en blanco (sustituye `<usuario>` por tu usuario de GitHub):

```markdown
![CI](https://github.com/<usuario>/manual-git/actions/workflows/ci.yml/badge.svg)
```

Guardamos los cambios y subimos la rama:

```bash
git add -A
git commit -m "Prepara la versión 1.1.0"
git push -u origin version-1.1.0
```

Abre el pull request, fusiónalo cuando la comprobación esté en verde y borra la rama. Después, actualizamos la copia local, creamos la etiqueta de la versión en `main` y la subimos, que es lo que pondrá en marcha la publicación:

```bash
git switch main
git pull --prune
git branch -d version-1.1.0
git tag -a v1.1.0 -m "Versión 1.1.0"
git push origin v1.1.0
```

Vuelve a la pestaña _Actions_. Verás una ejecución de _CI_ para la etiqueta `v1.1.0` con los tres jobs encadenados: _Revisar la sintaxis Markdown_, _Generar y publicar la release_ y _Publicar la web en GitHub Pages_. Cuando terminen, podrás comprobar el resultado en tres sitios:

- En la portada del repositorio, en el lateral derecho, aparece la sección _Releases_ con _Manual de Git v1.1.0_. Si la abres, verás que tiene adjuntos `manual-git-v1.1.0.docx` y `manual-git-v1.1.0.pdf`, listos para descargar, y unas notas generadas automáticamente con los cambios.
- En el job de Pages (o en _Settings_ → _Pages_) aparece la dirección de la web: `https://<usuario>.github.io/manual-git/`. Ábrela y verás el libro completo en HTML, con su índice.
- La insignia del README muestra _passing_ en verde.

La etiqueta `v1.0.0` no generó ninguna Release porque se subió antes de crear el workflow. A partir de ahora, en cambio, cada etiqueta de versión que subas a GitHub generará automáticamente su Release y actualizará la web.

Con esto hemos recorrido juntos el ciclo completo: escribir en local con Git, colaborar en GitHub, organizar el trabajo con un flujo de ramas y publicar automáticamente. El Manual de Git que has escrito resume todo lo que has aprendido, y cualquiera puede descargarlo, leerlo en la web o proponerte mejoras. Cuando necesites recordar un comando o profundizar en un tema, el [Anexo: referencias útiles](10-anexo-referencias-útiles.md) recopila todos los recursos citados en el curso.
