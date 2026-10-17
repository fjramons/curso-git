# Módulo 6: Trabajo colaborativo y open source

Hasta ahora, nuestro libro tiene un único autor. En este módulo vamos a abrir la puerta a otras personas con el flujo que se usa en casi todos los proyectos de código abierto: alguien hace una copia del proyecto en su cuenta (_fork_), propone cambios (_pull request_) y la persona responsable los revisa y los acepta. Después veremos cómo mantener esa copia al día y, para terminar, repasaremos la sintaxis Markdown con la que está escrito el libro.

## 6.1 Forks y pull requests

Para este apartado necesitas un compañero o compañera. Uno hará de **autor** (el dueño del repositorio `manual-git`) y el otro de **colaborador**, que va a escribir el capítulo 5 del libro del autor. Después podéis intercambiar los papeles.

Si haces el curso por tu cuenta, puedes crear una segunda cuenta de GitHub para el colaborador. Ten en cuenta que GitHub no permite usar la misma clave SSH en dos cuentas, así que la segunda cuenta necesitará su propia clave (repite el apartado 5.1 con otro nombre de fichero).

Antes de empezar, conviene entender el problema que resuelven los forks. Un colaborador no tiene permiso para hacer `push` al repositorio del autor, así que necesita otro sitio donde guardar su trabajo. Ese sitio es el **fork**: una copia completa de un repositorio ajeno dentro de su propia cuenta de GitHub, donde sí puede escribir. Desde el fork, el colaborador propone sus cambios al repositorio original mediante un **pull request** (PR), es decir, una petición para que el autor revise los cambios y, si le parecen bien, los fusione.

El recorrido completo tiene tres etapas: el colaborador crea el fork y escribe el capítulo en él, abre el pull request y, por último, el autor lo revisa y lo fusiona. Empezamos por el lado del colaborador.

**Colaborador**: entra en el repositorio del autor (`https://github.com/<autor>/manual-git`) y pulsa el botón _Fork_ de la parte superior derecha. Acepta las opciones por defecto y pulsa _Create fork_. En unos segundos tendrás `https://github.com/<colaborador>/manual-git`, con todo el historial del libro del autor.

Para trabajar en el fork necesitas una copia local, así que clónalo (a él, no al repositorio del autor) con la URL SSH del botón _Code_. Conviene hacerlo en una carpeta con otro nombre, para no confundirlo con tu propio libro:

```bash
cd ~/proyectos
git clone <url_de_tu_fork> manual-git-fork
cd manual-git-fork
```

Cuando se colabora, es una buena práctica no trabajar directamente en `main`, sino en una rama con un nombre descriptivo. De este modo el PR contiene sólo ese trabajo y tu `main` se mantiene igual que el del autor:

```bash
git switch -c capitulo-github
```

En esa rama, escribe el capítulo 5 en `capitulos/05-github.md`:

```markdown
# GitHub

GitHub es una plataforma que aloja repositorios de Git en la nube y añade herramientas para colaborar.

- Un **remoto** es una copia del repositorio en otro sitio, como GitHub.
- `git push` sube los commits al remoto y `git pull` los descarga.
- Un **fork** es una copia de un repositorio ajeno en tu cuenta.
- Un **pull request** es una propuesta de cambios para que otra persona la revise.
```

Antes de proponer el cambio, comprueba que el libro sigue generándose bien con `./build.sh`. Después, guarda y sube tu trabajo como siempre:

```bash
git add -A
git commit -m "Mi aportación colaborativa: capítulo 5 sobre GitHub"
git push -u origin capitulo-github
```

Como la rama es nueva, `-u` la crea en tu fork y la enlaza. Si el colaborador hubiera trabajado directamente en `main`, bastaría con `git push`.

El capítulo ya está en el fork, pero todavía no en el libro del autor: para que llegue allí hay que abrir el pull request. En la página de tu fork en GitHub aparece ahora un aviso amarillo, _capitulo-github had recent pushes_; pulsa _Compare & pull request_. GitHub muestra qué se va a fusionar y dónde:

- **base repository**: `<autor>/manual-git`, rama `main`. Es el destino.
- **head repository**: `<colaborador>/manual-git`, rama `capitulo-github`. Es el origen.

Escribe un título claro (_Añade el capítulo 5 sobre GitHub_) y una descripción que explique qué aporta el cambio, y pulsa _Create pull request_.

Ahora la pelota está en el tejado del autor.

**Autor**: en tu repositorio, la pestaña _Pull requests_ muestra el PR nuevo. Ábrelo y revísalo:

- La pestaña _Files changed_ muestra el diff del cambio. Puedes pulsar el `+` que aparece junto a cualquier línea para dejar un comentario.
- Con el botón _Review changes_ puedes aprobar el PR (_Approve_), pedir cambios (_Request changes_) o sólo comentar.

Si pides cambios, el colaborador puede hacerlos en su rama `capitulo-github`, hacer commit y `git push`, y los commits nuevos se añadirán automáticamente al mismo PR, sin necesidad de abrir otro.

Cuando todo esté bien, pulsa _Merge pull request_ y después _Confirm merge_. El botón tiene una flecha con tres opciones: _Create a merge commit_ (la habitual, que conserva todos los commits y crea un commit de fusión), _Squash and merge_ (junta todos los commits del PR en uno solo) y _Rebase and merge_ (coloca los commits encima de `main` sin commit de fusión). De momento, usaremos la primera.

El capítulo 5 ya forma parte del libro en GitHub. Para tenerlo también en local, el autor sólo tiene que descargarlo:

```bash
cd ~/proyectos/manual-git
git pull
```

Si quieres repetir este proceso con un proyecto real, el repositorio [First Contributions](https://github.com/firstcontributions/first-contributions) está pensado precisamente para hacer un primer pull request: explica paso a paso, también en español, cómo hacer un fork, un cambio y un pull request que alguien revisará de verdad.

## 6.2 Sincronización de forks (Sync fork) y resolución de conflictos en la web

Un fork es una copia independiente, así que cuando el repositorio original avanza, el fork no se actualiza solo. Ahora mismo, sin ir más lejos, la rama `main` del fork del colaborador no tiene el commit de fusión del PR ni los cambios que el autor haya hecho después. Antes de empezar una contribución nueva, el colaborador debe poner su fork al día; si no, trabajará sobre una versión antigua y tendrá más conflictos.

Para verlo, vamos a hacer que el original avance todavía un poco más. El **autor** hace un cambio en su libro: por ejemplo, edita `capitulos/01-que-es-git.md` desde la web de GitHub, añade una línea al final y confirma el commit en `main`:

```markdown
Git es software libre y gratuito.
```

Ya tenemos el escenario: el repositorio del autor tiene varios commits que el fork no tiene, y queremos ponerlo al día.

**Colaborador**: entra en la página de tu fork. Encima de la lista de ficheros verás un mensaje como _This branch is 3 commits behind `<autor>/manual-git:main`_ (el commit del capítulo 5, el commit de fusión del PR y el cambio del autor). Pulsa el botón _Sync fork_ y después _Update branch_, y GitHub copiará en el `main` de tu fork los commits nuevos del original. Todo este proceso se hace en la web, sin necesidad de la terminal.

Tu fork en GitHub ya está al día, pero tu copia local todavía no. La actualizamos como con cualquier otro cambio remoto y, de paso, borramos la rama del capítulo, que ya está fusionada:

```bash
cd ~/proyectos/manual-git-fork
git switch main
git pull
git branch -d capitulo-github
```

Si prefieres sincronizar desde la terminal sin pasar por la web, añade el repositorio original como un segundo remoto, al que por convención se llama `upstream`, y descarga sus cambios:

```bash
git remote add upstream <url_ssh_repositorio_del_autor>
git fetch upstream
git merge upstream/main
git push
```

Como se ve, el colaborador trabaja con tres copias del libro. El diagrama resume cómo viajan los cambios entre ellas:

```{.dot caption="Repositorio del autor, fork y copia local del colaborador" alt="El fork se crea desde el repositorio del autor y se pone al día con Sync fork. La copia local sube cambios al fork con git push y los baja con git pull o con git fetch upstream. Los cambios vuelven al repositorio del autor con un pull request"}
digraph {
  rankdir=TB; nodesep=1.2; ranksep=0.7
  autor [class=repo label="<autor>/manual-git\n(upstream)"]
  fork [class=repo label="<colaborador>/manual-git\n(origin)"]
  local [class=repo label="manual-git-fork\n(copia local)"]
  { rank=same; autor; fork }
  autor -> fork [class=accion label="Fork\nSync fork"]
  fork -> autor [class=accion label="Pull request"]
  fork -> local [class=accion label="git pull "]
  local -> fork [class=accion label=" git push"]
  autor -> local [class=accion label="git fetch upstream  "]
}
```

Los cambios del colaborador sólo llegan al repositorio del autor a través de un pull request, porque el colaborador no tiene permiso para escribir en él.

**Conflictos en un PR**. Queda un último caso por ver: qué ocurre si, mientras un PR está abierto, alguien cambia en `main` las mismas líneas que el PR. En esa situación GitHub no puede fusionarlo automáticamente. Para provocarla, el colaborador crea una rama nueva en su fork, cambia la línea `title:` de `metadata.yaml` y abre un PR; mientras tanto, el autor cambia esa misma línea en su `main` desde la web.

Con esto, en la página del PR, en lugar del botón verde de merge, aparece el mensaje _This branch has conflicts that must be resolved_. Lo que queremos es resolver el conflicto sin salir de GitHub, y si es sencillo, podemos hacerlo: el botón _Resolve conflicts_ abre un editor web con el fichero en conflicto y los mismos marcadores del apartado 4.3 (`<<<<<<<`, `=======` y `>>>>>>>`):

1. Edita el fichero hasta dejarlo como debe quedar y borra los marcadores.
2. Pulsa _Mark as resolved_ (si hay varios ficheros en conflicto, repite con cada uno).
3. Pulsa _Commit merge_. GitHub crea un commit de fusión en la rama del PR y el botón de merge vuelve a estar disponible. El autor ya puede fusionar el PR como en el apartado 6.1.

Si el conflicto es complejo, en cambio, GitHub te pedirá que lo resuelvas en local: trae la rama a tu ordenador, haz `git merge main` (o `git merge upstream/main` desde un fork), resuelve el conflicto como en el apartado 4.3 y haz `git push`.

## 6.3 Uso de Markdown (README.md)

**Markdown** es un lenguaje de marcado ligero: texto plano con unos pocos símbolos que indican el formato. Es fácil de leer incluso sin convertir, funciona muy bien con Git (los diffs muestran exactamente qué ha cambiado, cosa que no ocurre con un `.docx`) y GitHub lo muestra con formato automáticamente. Por eso el `README.md` es la portada de cualquier repositorio, y por eso nuestro libro está escrito en Markdown.

Como ocurre con los comandos de Git, no hace falta memorizar la sintaxis: la [Markdown Guide](https://www.markdownguide.org/) explica cada elemento con ejemplos y su [hoja de referencia](https://www.markdownguide.org/cheat-sheet/) los resume en una página.

Esta es la sintaxis que más usarás:

````markdown
# Título de nivel 1

## Título de nivel 2

### Título de nivel 3

Un párrafo es un bloque de texto. Se separa del siguiente con una línea en blanco.

Texto en **negrita**, en _cursiva_ y `código en línea`.

- Elemento de una lista
- Otro elemento
  - Elemento anidado (con dos espacios delante)

1. Primer paso
2. Segundo paso

[Texto del enlace](https://git-scm.com)

![Texto alternativo de la imagen](https://git-scm.com/images/logo.png)

> Una cita o una nota destacada.

```bash
git status
```

| Comando | Para qué sirve |
| --- | --- |
| `git add` | Prepara cambios |
| `git commit` | Guarda cambios |
````

Conviene tener en cuenta algunos detalles:

- Los títulos estructuran el documento. En el libro, cada capítulo empieza con un único título de nivel 1 (`#`), que Pandoc convierte en un capítulo y usa para construir el índice.
- Indica siempre el lenguaje de los bloques de código (`bash`, `yaml`, `markdown`…). GitHub y Pandoc lo usan para colorear la sintaxis.
- GitHub añade extras a Markdown, como listas de tareas (`- [ ] Pendiente` y `- [x] Hecho`) y avisos (`> [!NOTE]`). Pandoc también tiene los suyos, como las notas al pie (`Texto[^1]` y, más abajo, `[^1]: Contenido de la nota`). Úsalos con cuidado si quieres que el texto se vea igual en los dos sitios. Los extras de GitHub se explican en [Escritura en GitHub](https://docs.github.com/es/get-started/writing-on-github), dentro de su documentación.

Vamos a aplicarlo para que el `README.md` del libro sea una buena portada.

**Autor**: antes de editar, trae a tu copia local los commits que hiciste en la web en el apartado anterior. Si no lo haces, tu `main` y el de GitHub divergirán y GitHub rechazará el `git push`:

```bash
cd ~/proyectos/manual-git
git pull
```

Con la copia al día, sustituye el contenido de tu `README.md` por este:

````markdown
# Manual de Git

Libro práctico sobre Git y GitHub, escrito en Markdown durante el curso de Git y GitHub.

## Contenido

1. ¿Qué es Git?
2. Primeros comandos
3. Ramas
4. Viajes en el tiempo
5. GitHub

## Cómo generar el libro

Necesitas [Pandoc](https://pandoc.org) y, si quieres el PDF, [Typst](https://typst.app). Ejecuta:

```bash
./build.sh
```

El libro se genera en la carpeta `dist` en formato Word, PDF y HTML.

## Cómo colaborar

1. Haz un fork de este repositorio.
2. Crea una rama para tu cambio.
3. Abre un pull request con una descripción de lo que aportas.
````

Y guarda el cambio y súbelo:

```bash
git add -A
git commit -m "Mejora el README con el contenido y cómo colaborar"
git push
```

Si abres el repositorio en GitHub, verás el README con formato debajo de la lista de ficheros. Mientras escribes, puedes ver una vista previa de cualquier fichero Markdown en VS Code con `Ctrl+Shift+V` (`Cmd+Shift+V` en macOS).

Además del README, los proyectos de código abierto suelen tener un fichero `LICENSE` con la licencia, que indica qué pueden hacer otras personas con el contenido: copiarlo, modificarlo, publicarlo… Sin licencia, nadie tiene permiso legal para reutilizar el proyecto, aunque sea público. Nuestro libro no la necesita, pero si publicas un proyecto propio, [choosealicense.com](https://choosealicense.com/), de GitHub, te ayudará a elegir la adecuada.
