# Módulo 6: Trabajo colaborativo y open source

Hasta ahora, el libro tiene un único autor. Este módulo abre la puerta a otras personas con el flujo que se usa en casi todos los proyectos de código abierto: alguien hace una copia del proyecto en su cuenta (_fork_), propone cambios (_pull request_) y la persona responsable los revisa y los acepta. También explica cómo mantener esa copia al día y repasa la sintaxis Markdown con la que está escrito el libro.

## 6.1 Forks y pull requests

Para este apartado necesitas un compañero o compañera. Uno hará de **autor** (el dueño del repositorio `manual-git`) y otro de **colaborador**, que va a escribir el capítulo 5 del libro del autor. Después podéis intercambiar los papeles.

Si haces el curso por tu cuenta, puedes crear una segunda cuenta de GitHub para el colaborador. Ten en cuenta que GitHub no permite usar la misma clave SSH en dos cuentas, así que la segunda cuenta necesitará su propia clave (repite el apartado 5.1 con otro nombre de fichero).

Un colaborador no tiene permiso para hacer `push` al repositorio del autor. Por eso existen los **forks**: un fork es una copia completa de un repositorio ajeno dentro de tu propia cuenta de GitHub, donde sí puedes escribir. Desde el fork, propones tus cambios al repositorio original mediante un **pull request** (PR): una petición para que el autor revise tus cambios y, si le parecen bien, los fusione.

**Colaborador**: entra en el repositorio del autor (`https://github.com/<autor>/manual-git`) y pulsa el botón _Fork_ de la parte superior derecha. Acepta las opciones por defecto y pulsa _Create fork_. En unos segundos tendrás `https://github.com/<colaborador>/manual-git`, con todo el historial del libro del autor.

Ahora clona tu fork (no el repositorio del autor) con la URL SSH del botón _Code_. Clónalo en una carpeta con otro nombre para no confundirlo con tu propio libro:

```bash
cd ~/proyectos
git clone <url_de_tu_fork> manual-git-fork
cd manual-git-fork
```

Es una buena práctica no trabajar directamente en `main` cuando se colabora, sino en una rama con un nombre descriptivo. Así el PR contiene solo ese trabajo y tu `main` se mantiene igual que el del autor:

```bash
git switch -c capitulo-github
```

Escribe el capítulo 5 en `capitulos/05-github.md`:

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

Ahora, en la página de tu fork en GitHub aparece un aviso amarillo: _capitulo-github had recent pushes_. Pulsa _Compare & pull request_. GitHub muestra qué se va a fusionar y dónde:

- **base repository**: `<autor>/manual-git`, rama `main`. Es el destino.
- **head repository**: `<colaborador>/manual-git`, rama `capitulo-github`. Es el origen.

Escribe un título claro (_Añade el capítulo 5 sobre GitHub_) y una descripción que explique qué aporta el cambio. Pulsa _Create pull request_.

**Autor**: en tu repositorio, la pestaña _Pull requests_ muestra el PR nuevo. Ábrelo y revísalo:

- La pestaña _Files changed_ muestra el diff del cambio. Puedes pulsar el `+` que aparece junto a cualquier línea para dejar un comentario.
- Con el botón _Review changes_ puedes aprobar el PR (_Approve_), pedir cambios (_Request changes_) o solo comentar.

Si pides cambios, el colaborador puede hacerlos en su rama `capitulo-github`, hacer commit y `git push`: los commits nuevos se añaden automáticamente al mismo PR. No hace falta abrir otro.

Cuando todo esté bien, pulsa _Merge pull request_ y después _Confirm merge_. El botón tiene una flecha con tres opciones: _Create a merge commit_ (la habitual, que conserva todos los commits y crea un commit de fusión), _Squash and merge_ (junta todos los commits del PR en uno solo) y _Rebase and merge_ (coloca los commits encima de `main` sin commit de fusión). De momento, usa la primera.

El capítulo 5 ya forma parte del libro en GitHub. Para tenerlo también en local, el autor lo descarga:

```bash
cd ~/proyectos/manual-git
git pull
```

## 6.2 Sincronización de forks (Sync fork) y resolución de conflictos en la web

Un fork es una copia independiente: cuando el repositorio original avanza, el fork no se actualiza solo. Ahora mismo, la rama `main` del fork del colaborador no tiene el commit de fusión del PR ni los cambios que el autor haya hecho después. Antes de empezar una contribución nueva, el colaborador debe poner su fork al día, o trabajará sobre una versión antigua y tendrá más conflictos.

Para verlo, el **autor** hace un cambio en su libro. Por ejemplo, edita `capitulos/01-que-es-git.md` desde la web de GitHub, añade una línea al final y confirma el commit en `main`:

```markdown
Git es software libre y gratuito.
```

**Colaborador**: entra en la página de tu fork. Encima de la lista de ficheros verás un mensaje como _This branch is 3 commits behind `<autor>/manual-git:main`_ (el commit del capítulo 5, el commit de fusión del PR y el cambio del autor). Pulsa el botón _Sync fork_ y después _Update branch_. GitHub copia en el `main` de tu fork los commits nuevos del original. Este proceso es solo web: no hace falta la terminal.

Tu fork en GitHub ya está al día, pero tu copia local todavía no. Descárgalo como cualquier otro cambio remoto y, de paso, borra la rama del capítulo, que ya está fusionada:

```bash
cd ~/proyectos/manual-git-fork
git switch main
git pull
git branch -d capitulo-github
```

Si quieres sincronizar desde la terminal sin pasar por la web, añade el repositorio original como un segundo remoto, al que por convención se llama `upstream`, y descarga sus cambios:

```bash
git remote add upstream <url_ssh_repositorio_del_autor>
git fetch upstream
git merge upstream/main
git push
```

El colaborador trabaja así con tres copias del libro. El diagrama resume cómo viajan los cambios entre ellas:

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

Los cambios del colaborador solo llegan al repositorio del autor a través de un pull request, porque el colaborador no tiene permiso para escribir en él.

**Conflictos en un PR**. Si mientras un PR está abierto alguien cambia en `main` las mismas líneas que el PR, GitHub no puede fusionarlo automáticamente. Para verlo, el colaborador crea una rama nueva en su fork, cambia la línea `title:` de `metadata.yaml` y abre un PR. Mientras tanto, el autor cambia esa misma línea en su `main` desde la web.

En la página del PR, en lugar del botón verde de merge, aparece el mensaje _This branch has conflicts that must be resolved_. Si el conflicto es sencillo, GitHub ofrece un botón _Resolve conflicts_ que abre un editor web con el fichero en conflicto y los mismos marcadores del apartado 4.3 (`<<<<<<<`, `=======` y `>>>>>>>`):

1. Edita el fichero hasta dejarlo como debe quedar y borra los marcadores.
2. Pulsa _Mark as resolved_ (si hay varios ficheros en conflicto, repite con cada uno).
3. Pulsa _Commit merge_. GitHub crea un commit de fusión en la rama del PR y el botón de merge vuelve a estar disponible. El autor ya puede fusionar el PR como en el apartado 6.1.

Si el conflicto es complejo, GitHub te pedirá que lo resuelvas en local: trae la rama a tu ordenador, haz `git merge main` (o `git merge upstream/main` desde un fork), resuelve el conflicto como en el apartado 4.3 y haz `git push`.

## 6.3 Uso de Markdown (README.md)

**Markdown** es un lenguaje de marcado ligero: texto plano con unos pocos símbolos que indican el formato. Es fácil de leer incluso sin convertir, funciona muy bien con Git (los diffs muestran exactamente qué ha cambiado, cosa que no ocurre con un `.docx`) y GitHub lo muestra con formato automáticamente. Por eso el `README.md` es la portada de cualquier repositorio, y por eso el libro está escrito en Markdown.

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

Algunos detalles importantes:

- Los títulos estructuran el documento. En el libro, cada capítulo empieza con un único título de nivel 1 (`#`), que Pandoc convierte en un capítulo y usa para construir el índice.
- Indica siempre el lenguaje de los bloques de código (`bash`, `yaml`, `markdown`…). GitHub y Pandoc lo usan para colorear la sintaxis.
- GitHub añade extras a Markdown, como listas de tareas (`- [ ] Pendiente` y `- [x] Hecho`) y avisos (`> [!NOTE]`). Pandoc también tiene los suyos, como las notas al pie (`Texto[^1]` y, más abajo, `[^1]: Contenido de la nota`). Úsalos con cuidado si quieres que el texto se vea igual en los dos sitios.

Ahora toca aplicarlo para que el `README.md` del libro sea una buena portada. **Autor**: antes de editar, trae a tu copia local los commits que hiciste en la web en el apartado anterior. Si no, tu `main` y el de GitHub divergirán y GitHub rechazará el `git push`:

```bash
cd ~/proyectos/manual-git
git pull
```

Después, sustituye el contenido de tu `README.md` por este:

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

Guarda el cambio y súbelo:

```bash
git add -A
git commit -m "Mejora el README con el contenido y cómo colaborar"
git push
```

Abre el repositorio en GitHub y verás el README con formato debajo de la lista de ficheros. Mientras escribes, puedes ver una vista previa de cualquier fichero Markdown en VS Code con `Ctrl+Shift+V` (`Cmd+Shift+V` en macOS).
