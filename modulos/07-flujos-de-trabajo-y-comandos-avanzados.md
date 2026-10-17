# Módulo 7: Flujos de trabajo y comandos avanzados

Con el libro ya en GitHub y la primera colaboración integrada, ha llegado el momento de organizar el trabajo como en un proyecto profesional. En este módulo veremos qué aportan las interfaces gráficas frente a la terminal, cómo se organizan las ramas con un flujo de trabajo (GitFlow y GitHub flow), dos comandos que reescriben la historia (cherry-pick y rebase) y, por último, cómo deshacer un cambio que ya está en GitHub sin reescribirla (revert).

## 7.1 Interfaces gráficas (GUI) frente a la terminal

Todo lo que hemos hecho hasta ahora en la terminal se puede hacer también con programas gráficos. Estos son los más conocidos:

| Programa | Sistemas | Precio | Puntos fuertes |
| --- | --- | --- | --- |
| [GitHub Desktop](https://desktop.github.com) | Windows, macOS | Gratuito | Muy sencillo, integrado con GitHub (forks, PRs) |
| [GitKraken](https://www.gitkraken.com) | Windows, macOS, Linux | Gratuito para repositorios públicos | Gráfico de ramas muy visual, resolución de conflictos |
| [Sourcetree](https://www.sourcetreeapp.com) | Windows, macOS | Gratuito | Muy completo, expone casi todas las opciones de Git |
| VS Code (panel _Source Control_) | Windows, macOS, Linux | Gratuito | Integrado en el editor, ideal para escribir y confirmar sin cambiar de ventana |

Las interfaces gráficas resultan cómodas para las tareas visuales, como revisar un diff, preparar sólo algunas líneas de un fichero, explorar el gráfico de ramas o resolver un conflicto con botones. Sin embargo, todas usan por debajo los mismos conceptos que ya conoces: directorio de trabajo, staging, commits, ramas y remotos. Si no se entienden esos conceptos, una GUI sólo esconde lo que pasa; si se entienden, es una herramienta más.

Aun así, la terminal sigue siendo imprescindible: es lo único disponible en un servidor, es lo que usan toda la documentación y los sistemas de CI, y algunas operaciones (como el rebase interactivo) resultan más claras en ella. Un buen ejercicio es abrir la carpeta `~/proyectos/manual-git` con la GUI que prefieras e intentar reconocer en ella los commits, las ramas y las etiquetas de nuestro libro.

## 7.2 Flujos de trabajo: GitFlow y GitHub flow

Git permite organizar las ramas con total libertad, y precisamente por eso los equipos acuerdan un **flujo de trabajo**: unas reglas sobre qué ramas existen y cómo se mueven los cambios entre ellas. Los dos más conocidos son GitFlow y GitHub flow, y conviene conocer ambos aunque nuestro libro vaya a seguir sólo el segundo.

**GitFlow** está pensado para proyectos que publican versiones numeradas y tienen que mantener varias a la vez, como una aplicación de escritorio. Para ello usa estas ramas:

- `main`: sólo contiene versiones publicadas. Cada commit de `main` es una versión y lleva su etiqueta.
- `develop`: rama de integración donde se acumula el trabajo para la próxima versión.
- `feature/<nombre>`: una rama por cada funcionalidad nueva. Sale de `develop` y vuelve a `develop`.
- `release/<versión>`: prepara una versión (últimos retoques y número de versión). Sale de `develop` y se fusiona en `main` y en `develop`.
- `hotfix/<versión>`: corrige un error urgente en una versión publicada. Sale de `main` y se fusiona en `main` y en `develop`.

GitFlow lo propuso Vincent Driessen en 2010 en el artículo [A successful Git branching model](https://nvie.com/posts/a-successful-git-branching-model/) (en inglés), que sigue siendo la mejor descripción del flujo.

El diagrama muestra un esquema general de GitFlow, no el historial de nuestro libro. En él se ve cómo cada rama temporal sale de una rama permanente y vuelve a ella, mientras `main` sólo recibe versiones terminadas:

```{.dot caption="Esquema general de GitFlow" alt="main sólo recibe versiones. develop sale de main y recibe una funcionalidad. Una corrección urgente sale de main, crea la versión 1.0.1 y vuelve también a develop. La release 1.1 sale de develop, crea la versión 1.1 en main y vuelve a develop"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  m1 [label="Versión 1.0" group=main]; m2 [label="Versión 1.0.1" group=main]; m3 [label="Versión 1.1" group=main]
  h1 [label="hotfix: corrige un error urgente" group=hotfix]
  r1 [label="release: prepara la versión 1.1" group=release]
  d1 [label="Empieza el desarrollo" group=develop]; d2 [label="Integra la funcionalidad" group=develop]; d3 [label="Integra la corrección" group=develop]; d4 [label="Integra la versión 1.1" group=develop]
  f1 [label="feature: funcionalidad nueva" group=feature]
  m1 -> m2 -> m3
  m1 -> h1 -> m2
  m1 -> d1
  d1 -> paso [arrowhead=none headclip=false]; paso -> d2 [tailclip=false]
  d2 -> d3 -> d4
  d1 -> f1 -> d2
  h1 -> d3
  d3 -> r1 -> m3
  r1 -> d4
  node [shape=plaintext, group=""]
  develop [class=rama]; v10 [class=etiqueta label="v1.0"]; v101 [class=etiqueta label="v1.0.1"]; r3 [class=refs label="main, v1.1"]
  { rank=same; r3 -> m3 [class=ref dir=forward] }
  { rank=same; v101 -> m2 [class=ref dir=forward] }
  { rank=same; v10 -> m1 [class=ref dir=forward] }
  { rank=same; d4 -> develop [class=ref dir=back] }
  { rank=same; h1 -> d1 [style=invis] }
  paso [shape=point width=0.015 height=0.015 color="#4a5b70" fillcolor="#4a5b70" group=develop]
  { rank=same; m2 -> paso -> f1 [style=invis] }
  { rank=same; m3 -> d4 [style=invis] }
}
```

Como se aprecia en el diagrama, seguir GitFlow con comandos normales de Git exige muchas fusiones. Por eso existe una extensión, `git-flow`, que las automatiza con comandos como `git flow feature start` o `git flow release finish`. Es útil en equipos grandes con varias versiones en mantenimiento, pero añade ramas y pasos que un proyecto pequeño como el nuestro no necesita.

**GitHub flow** es la alternativa sencilla, y es el flujo que seguirá nuestro libro a partir de ahora. Sólo tiene una rama permanente, `main`, que siempre debe funcionar, y cada cambio sigue estos pasos:

1. Se crea una rama corta a partir de `main`, con un nombre que describe el cambio.
2. Se hacen commits en ella y se sube a GitHub.
3. Se abre un pull request para que otras personas revisen el cambio.
4. Cuando el pull request está aprobado, se fusiona en `main` y se borra la rama.

La documentación de GitHub lo describe en [GitHub flow](https://docs.github.com/es/get-started/using-github/github-flow).

En realidad, ya lo pusimos en práctica en el módulo 6 con el capítulo 5: la rama `capitulo-github`, su pull request y el commit de fusión que GitHub creó en `main`. Después de descargar la fusión con `git pull`, la parte de arriba de `git tree` en la copia del autor era esta:

```text
*   6dce13e (HEAD -> main, origin/main) Merge pull request #1 from <colaborador>/capitulo-github
|\
| * 7429b59 Mi aportación colaborativa: capítulo 5 sobre GitHub
|/
* 57c522f Amplía el capítulo 4 con reflog
...
```

El diagrama la dibuja con el commit de la rama a la derecha de `main`:

```{.dot caption="GitHub flow: el capítulo 5 llegó a main con un pull request" alt="Del commit Amplía el capítulo 4 con reflog sale el commit del capítulo 5, hecho en la rama capitulo-github. Un commit de fusión creado por el pull request lo une a main, donde están main, origin/main y HEAD"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; r [label="57c522f Amplía el capítulo 4 con reflog" group=main]; c5 [label="7429b59 Mi aportación colaborativa:\ncapítulo 5 sobre GitHub" group=rama]; pr [label="6dce13e Merge pull request #1 from\n<colaborador>/capitulo-github" group=main]
  e -> r
  r -> c5 -> pr
  paso [shape=point width=0.015 height=0.015 color="#4a5b70" fillcolor="#4a5b70" group=main]; hueco [style=invis label="" width=1.4]
  r -> paso [arrowhead=none headclip=false]; paso -> pr [tailclip=false]
  node [shape=plaintext, group=""]
  rpr [class=refs label="HEAD -> main, origin/main"]
  { rank=same; pr -> rpr [class=ref dir=back] }
  { rank=same; paso -> hueco -> c5 [style=invis] }
}
```

El repositorio del autor no tiene la rama `capitulo-github`, que sólo existió en el fork del colaborador, pero conserva su commit.

Vamos a escribir ahora el capítulo 6 del libro, dedicado precisamente a los flujos de trabajo, y lo haremos ya con GitHub flow: en una rama propia que integraremos con un pull request en nuestro propio repositorio. Para no partir de una versión desfasada, nos aseguramos primero de tener la última versión de `main` y, a continuación, creamos la rama:

```bash
cd ~/proyectos/manual-git
git switch main
git pull
git switch -c capitulo-flujos
```

En la rama nueva, crea `capitulos/06-flujos-de-trabajo.md` con este contenido:

```markdown
# Flujos de trabajo

Un flujo de trabajo son las reglas que sigue un equipo para usar las ramas.

- **GitFlow** usa dos ramas permanentes, `main` y `develop`, y ramas temporales para cada funcionalidad, cada versión y cada corrección urgente.
- **GitHub flow** usa una sola rama permanente, `main`. Cada cambio se hace en una rama corta y llega a `main` con un pull request.
```

Y guárdalo con un commit:

```bash
git add -A
git commit -m "Añade el capítulo 6: flujos de trabajo"
```

Con seis capítulos, el libro está listo para su primera versión completa, así que aprovechamos la misma rama para prepararla. Añade al final de `metadata.yaml` una línea con la versión, que Pandoc mostrará en la portada debajo del título:

```yaml
date: Versión 1.0.0
```

Guardamos este cambio en otro commit y subimos la rama a GitHub:

```bash
git add -A
git commit -m "Prepara la versión 1.0.0"
git push -u origin capitulo-flujos
```

Ahora toca abrir el pull request. En la página del repositorio en GitHub, pulsa _Compare & pull request_ en el aviso amarillo. Como la rama está en tu propio repositorio, esta vez no hace falta un fork: el pull request va de `capitulo-flujos` a `main` del mismo repositorio. Pulsa _Create pull request_ y, como no hay nadie más para revisarlo, fusiónalo tú mismo con _Merge pull request_ y _Confirm merge_. Por último, pulsa _Delete branch_ para borrar la rama en GitHub, que ya no hace falta.

En un equipo, otra persona revisaría el pull request antes de fusionarlo, como hicimos en el módulo 6. Aunque trabajes solo, cada pull request deja constancia del cambio y, en el módulo 8, servirá además para que GitHub revise automáticamente el libro antes de fusionarlo.

La fusión ya está en GitHub, pero todavía no en nuestra copia local. La traemos y borramos la rama, que ya está integrada en `main`:

```bash
git switch main
git pull --prune
git branch -d capitulo-flujos
```

La opción `--prune` borra también `origin/capitulo-flujos`, la rama de seguimiento de una rama que ya no existe en GitHub.

Sólo falta marcar la versión. En GitHub flow, las versiones se marcan con etiquetas en `main`, y en este caso usaremos una etiqueta anotada, que guarda autor, fecha y mensaje (apartado 3.4). La creamos y la subimos a GitHub:

```bash
git tag -a v1.0.0 -m "Versión 1.0.0"
git push origin v1.0.0
git tree
```

```text
*   5656f2f (HEAD -> main, tag: v1.0.0, origin/main) Merge pull request #N from tu-usuario/capitulo-flujos
|\
| * 6439eeb Prepara la versión 1.0.0
| * b8a12b2 Añade el capítulo 6: flujos de trabajo
|/
* 45a644f Mejora el README con el contenido y cómo colaborar
...
```

El diagrama muestra el resultado: los dos commits de la rama llegan a `main` con el commit de fusión del pull request, que lleva la etiqueta `v1.0.0`. `N` es el número que GitHub ha asignado al pull request:

```{.dot caption="La versión 1.0.0, publicada con GitHub flow" alt="Del commit Mejora el README salen los dos commits de la rama capitulo-flujos. El commit de fusión del pull request los une a main y lleva la etiqueta v1.0.0"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; p [label="45a644f Mejora el README con el\ncontenido y cómo colaborar" group=main]; c6 [label="b8a12b2 Añade el capítulo 6:\nflujos de trabajo" group=rama]; v [label="6439eeb Prepara la versión 1.0.0" group=rama]; pr [label="5656f2f Merge pull request #N from\ntu-usuario/capitulo-flujos" group=main]
  e -> p
  p -> c6 -> v -> pr
  paso1 [shape=point width=0.015 height=0.015 color="#4a5b70" fillcolor="#4a5b70" group=main]; paso2 [shape=point width=0.015 height=0.015 color="#4a5b70" fillcolor="#4a5b70" group=main]; hueco1 [style=invis label="" width=1.4]; hueco2 [style=invis label="" width=1.4]
  p -> paso1 [arrowhead=none headclip=false]; paso1 -> paso2 [arrowhead=none headclip=false tailclip=false]; paso2 -> pr [tailclip=false]
  node [shape=plaintext, group=""]
  rpr [class=refs label="HEAD -> main, origin/main, v1.0.0"]
  { rank=same; pr -> rpr [class=ref dir=back] }
  { rank=same; paso1 -> hueco1 -> c6 [style=invis] }
  { rank=same; paso2 -> hueco2 -> v [style=invis] }
}
```

## 7.3 Comandos avanzados: cherry-pick y rebase

**Cherry-pick** copia un commit concreto de otra rama en la rama actual, sin traer nada más. Resulta útil cuando una corrección se hizo en una rama pero también hace falta en otra.

Para verlo en acción necesitamos un commit valioso atrapado en una rama que todavía no se puede integrar. Vamos a provocar esa situación de una forma muy habitual: empezaremos el capítulo 7 en una rama nueva y, en mitad del trabajo, haremos en esa misma rama una corrección del capítulo 3 que, en realidad, debería llegar cuanto antes a `main`. Primero, empezamos el capítulo:

```bash
git switch -c capitulo-avanzados
echo "# Comandos avanzados" > capitulos/07-comandos-avanzados.md
git add -A
git commit -m "Empieza el capítulo 7"
```

Supongamos ahora que, mientras escribes, descubres una imprecisión en el capítulo 3. Lo natural es corregirla en el momento, en la misma rama: edita `capitulos/03-ramas.md` y cambia la última línea por una versión más precisa:

```markdown
Las ramas son baratas: Git guarda cada una en un fichero de sólo 41 bytes con el identificador de su último commit.
```

Guardamos la corrección en su propio commit y, como la vamos a necesitar enseguida, mostramos su identificador con `git log --oneline -1`, que enseña sólo el último commit:

```bash
git add -A
git commit -m "Precisa el tamaño de una rama en el capítulo 3"
git log --oneline -1
```

```text
8d5d3fd (HEAD -> capitulo-avanzados) Precisa el tamaño de una rama en el capítulo 3
```

Ya tenemos el escenario: la rama `capitulo-avanzados` contiene dos commits, el principio del capítulo 7 y la corrección del capítulo 3. Y aquí está el problema: la corrección debería llegar ya a `main`, pero el capítulo 7 está a medias y no puede ir con ella. Lo que queremos, por tanto, es llevar a `main` sólo ese commit, dejando el resto de la rama donde está. Eso es justo lo que hace cherry-pick, cuya sintaxis es `git cherry-pick <id_del_commit>`. Creamos una rama a partir de `main` y copiamos en ella sólo ese commit, que en el ejemplo es `8d5d3fd`:

```bash
# Traer un commit específico a la rama actual
git switch -c corrige-capitulo-3 main
git cherry-pick 8d5d3fd
git tree
```

Usa el identificador que aparezca en tu `git log`. La salida de `git tree` es esta:

```text
* 5ec836d (HEAD -> corrige-capitulo-3) Precisa el tamaño de una rama en el capítulo 3
| * 8d5d3fd (capitulo-avanzados) Precisa el tamaño de una rama en el capítulo 3
| * d52353a Empieza el capítulo 7
|/
*   5656f2f (tag: v1.0.0, origin/main, main) Merge pull request #N from tu-usuario/capitulo-flujos
...
```

El último argumento de `git switch -c` indica desde dónde se crea la rama: aquí, desde `main` y no desde la rama actual. `git tree` muestra un commit nuevo en `corrige-capitulo-3` con el mismo mensaje pero distinto identificador (`5ec836d` en lugar de `8d5d3fd`), porque cherry-pick no mueve el commit, sino que crea una copia. En el diagrama, la flecha discontinua une el original con su copia:

```{.dot caption="Cherry-pick: una copia de la corrección en una rama que sale de main" alt="De la fusión de la versión 1.0.0 salen dos ramas. En capitulo-avanzados están Empieza el capítulo 7 y la corrección del capítulo 3. En corrige-capitulo-3 hay una copia de esa corrección"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; pr [label="5656f2f Merge pull request #N from\ntu-usuario/capitulo-flujos" group=main]; s [label="d52353a Empieza el capítulo 7" group=avanzados]; c [label="8d5d3fd Precisa el tamaño de una rama\nen el capítulo 3" group=avanzados]; c2 [label="5ec836d Precisa el tamaño de una rama\nen el capítulo 3" group=corrige]
  e -> pr -> s -> c
  pr -> c2
  c -> c2 [class=copia constraint=false]
  hueco1 [style=invis group=main label="5656f2f Merge pull request #N from\ntu-usuario/capitulo-flujos"]; hueco2 [style=invis group=main label="5656f2f Merge pull request #N from\ntu-usuario/capitulo-flujos"]
  pr -> hueco1 -> hueco2 [style=invis]
  node [shape=plaintext, group=""]
  rpr [class=refs label="main, origin/main, v1.0.0"]; ca [class=rama label="capitulo-avanzados"]; cc [class=rama label="corrige-capitulo-3"]; HEAD [class=head]
  { rank=same; pr -> rpr [class=ref dir=back] }
  { rank=same; hueco1 -> s -> c2 [style=invis] }
  { rank=same; c2 -> cc -> HEAD [class=ref dir=back] }
  { rank=same; hueco2 -> c [style=invis] }
  { rank=same; c -> ca [class=ref dir=back] }
}
```

Si al aplicar el commit surge un conflicto, Git se detiene como en un merge. En ese caso puedes resolverlo y continuar con `git cherry-pick --continue`, o bien renunciar y volver al estado anterior con:

```bash
git cherry-pick --abort
```

La corrección ya está en su propia rama, lista para integrarse en `main` con GitHub flow, igual que hicimos en el apartado anterior. Primero, subimos la rama:

```bash
git push -u origin corrige-capitulo-3
```

En GitHub, abre el pull request, fusiónalo y borra la rama. Después, actualizamos la copia local:

```bash
git switch main
git pull --prune
git branch -d corrige-capitulo-3
```

**Rebase** es la alternativa a `merge` para integrar los cambios de una rama en otra. En lugar de crear un commit de fusión, toma los commits de la rama actual y los vuelve a aplicar, uno a uno, encima de la otra rama. El resultado es un historial lineal, como si el trabajo hubiera empezado después de los últimos cambios.

Para ver rebase necesitamos dos ramas que hayan divergido, y ya tenemos la mitad del camino recorrido: `main` ha avanzado con la fusión de la corrección, mientras que `capitulo-avanzados` sigue saliendo de la versión 1.0.0. Para que la divergencia se note más, vamos a seguir escribiendo el capítulo 7 con un par de commits. Volvemos primero a su rama:

```bash
git switch capitulo-avanzados
```

Añade al capítulo un párrafo sobre cherry-pick, separado del título por una línea en blanco:

```markdown
Con `git cherry-pick <commit>` se copia un commit concreto de otra rama en la rama actual.
```

Y guárdalo con su commit:

```bash
git add -A
git commit -m "Añade cherry-pick al capítulo 7"
```

A continuación, añade otro párrafo sobre rebase, también con una línea en blanco delante:

```markdown
Con `git rebase <rama>` se reaplican los commits de la rama actual encima de otra rama.
```

Lo guardamos con otro commit y miramos cómo ha quedado el historial:

```bash
git add -A
git commit -m "Añade rebase al capítulo 7"
git tree
```

```text
* ea70d95 (HEAD -> capitulo-avanzados) Añade rebase al capítulo 7
* d1dfabd Añade cherry-pick al capítulo 7
* 8d5d3fd Precisa el tamaño de una rama en el capítulo 3
* d52353a Empieza el capítulo 7
| * af8bb0b (origin/main, main) Merge pull request #N from tu-usuario/corrige-capitulo-3
|/|
| * 5ec836d Precisa el tamaño de una rama en el capítulo 3
|/
*   5656f2f (tag: v1.0.0) Merge pull request #N from tu-usuario/capitulo-flujos
...
```

Ya tenemos el escenario que buscábamos: `git tree` muestra que `main` y `capitulo-avanzados` han divergido. Por un lado, `main` tiene la fusión de la corrección; por otro, `capitulo-avanzados` tiene los commits del capítulo 7 y la corrección original:

```{.dot caption="main y capitulo-avanzados han divergido" alt="De la fusión de la versión 1.0.0 salen dos líneas. En main, la corrección del capítulo 3 llega con un pull request. En capitulo-avanzados están los commits del capítulo 7 y la corrección original"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  a0 [label="5656f2f Merge pull request #N from\ntu-usuario/capitulo-flujos" group=main]; ac [label="5ec836d Precisa el tamaño de una rama\nen el capítulo 3" group=corrige]; am [label="af8bb0b Merge pull request #N from\ntu-usuario/corrige-capitulo-3" group=main]
  a1 [label="d52353a Empieza el capítulo 7" group=a]; a2 [label="8d5d3fd Precisa el tamaño de una rama\nen el capítulo 3" group=a]; a3 [label="d1dfabd Añade cherry-pick al capítulo 7" group=a]; a4 [label="ea70d95 Añade rebase al capítulo 7" group=a]
  a0 -> ac -> am
  a0 -> a1 -> a2 -> a3 -> a4
  paso [shape=point width=0.015 height=0.015 color="#4a5b70" fillcolor="#4a5b70" group=main]; hueco [style=invis label="" width=1.4]
  a0 -> paso [arrowhead=none headclip=false]; paso -> am [tailclip=false]
  node [shape=plaintext, group=""]
  ram [class=refs label="main, origin/main"]; ca1 [class=rama label="capitulo-avanzados"]; head1 [class=head label="HEAD"]; v1a [class=etiqueta label="v1.0.0"]
  { rank=same; ram -> am [class=ref dir=forward] }
  { rank=same; a4 -> ca1 -> head1 [class=ref dir=back] }
  { rank=same; a0 -> v1a [class=ref dir=back] }
  { rank=same; paso -> hueco -> ac -> a1 [style=invis] }
  { rank=same; am -> a2 [style=invis] }
}
```

Queremos poner la rama al día con `main`, pero sin el commit de fusión que crearía un merge. Rebase, en cambio, reaplica los commits de la rama encima del último commit de `main`:

```bash
# Mover la rama actual sobre otra (rebase)
git rebase main
git tree
```

```text
* c7f2e18 (HEAD -> capitulo-avanzados) Añade rebase al capítulo 7
* 9a3d5f2 Añade cherry-pick al capítulo 7
* e41b07c Empieza el capítulo 7
*   af8bb0b (origin/main, main) Merge pull request #N from tu-usuario/corrige-capitulo-3
|\
| * 5ec836d Precisa el tamaño de una rama en el capítulo 3
|/
*   5656f2f (tag: v1.0.0) Merge pull request #N from tu-usuario/capitulo-flujos
...
```

Git avisa de que ha omitido un commit (_skipped previously applied commit_): la corrección del capítulo 3 ya está en `main` gracias al cherry-pick, así que no la vuelve a aplicar. Ahora el historial es una línea recta, con los tres commits del capítulo 7 después de la fusión de la corrección. Fíjate en que sus identificadores han cambiado (_Empieza el capítulo 7_, por ejemplo, ha pasado de `d52353a` a `e41b07c`): igual que cherry-pick, rebase crea copias nuevas de los commits. Los originales, en gris y con el contorno discontinuo en el diagrama, ya no están en ninguna rama, como el commit borrado con `reset` en el apartado 3.2.1:

```{.dot caption="La rama capitulo-avanzados después de git rebase main" alt="Las copias de los tres commits del capítulo 7 están encima de la fusión de la corrección. La corrección repetida desaparece y los commits originales quedan en gris, con el contorno discontinuo"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  d0 [label="5656f2f Merge pull request #N from\ntu-usuario/capitulo-flujos" group=main]; dc [label="5ec836d Precisa el tamaño de una rama\nen el capítulo 3" group=lado]; dm [label="af8bb0b Merge pull request #N from\ntu-usuario/corrige-capitulo-3" group=main]
  d1 [label="e41b07c Empieza el capítulo 7" group=lado]; d2 [label="9a3d5f2 Añade cherry-pick al capítulo 7" group=lado]; d3 [label="c7f2e18 Añade rebase al capítulo 7" group=lado]
  o1 [class=huerfano style="rounded,dashed" color=gray50 fontcolor=gray50 label="d52353a Empieza el capítulo 7" group=huerfanos]; o2 [class=huerfano style="rounded,dashed" color=gray50 fontcolor=gray50 label="8d5d3fd Precisa el tamaño de una rama\nen el capítulo 3" group=huerfanos]; o3 [class=huerfano style="rounded,dashed" color=gray50 fontcolor=gray50 label="d1dfabd Añade cherry-pick al capítulo 7" group=huerfanos]; o4 [class=huerfano style="rounded,dashed" color=gray50 fontcolor=gray50 label="ea70d95 Añade rebase al capítulo 7" group=huerfanos]
  dm -> d1 -> d2 -> d3
  d0 -> dc -> dm
  d0 -> o1 [class=huerfano style=dashed color=gray50]; o1 -> o2 [class=huerfano style=dashed color=gray50]; o2 -> o3 [class=huerfano style=dashed color=gray50]; o3 -> o4 [class=huerfano style=dashed color=gray50]
  paso1 [shape=point width=0.015 height=0.015 color="#4a5b70" fillcolor="#4a5b70" group=main]; hueco1 [style=invis label="" width=1.4]; hueco3 [style=invis group=main label="5656f2f Merge pull request #N from\ntu-usuario/capitulo-flujos"]; hueco4 [style=invis group=main label="5656f2f Merge pull request #N from\ntu-usuario/capitulo-flujos"]; hueco5 [style=invis group=main label="5656f2f Merge pull request #N from\ntu-usuario/capitulo-flujos"]
  d0 -> paso1 [arrowhead=none headclip=false]; paso1 -> dm [tailclip=false]
  dm -> hueco3 -> hueco4 -> hueco5 [style=invis]
  node [shape=plaintext, group=""]
  rdm [class=refs label="main, origin/main"]; ca2 [class=rama label="capitulo-avanzados"]; head2 [class=head label="HEAD"]; v1d [class=etiqueta label="v1.0.0"]
  { rank=same; rdm -> dm [class=ref dir=forward] }
  { rank=same; d0 -> v1d [class=ref dir=back] }
  { rank=same; paso1 -> hueco1 -> dc -> o1 [style=invis] }
  { rank=same; dm -> o2 [style=invis] }
  { rank=same; hueco3 -> d1 -> o3 [style=invis] }
  { rank=same; hueco4 -> d2 -> o4 [style=invis] }
  { rank=same; hueco5 -> d3 [style=invis] }
  { rank=same; d3 -> ca2 -> head2 [class=ref dir=back] }
}
```

El **rebase interactivo** va más allá: permite reordenar, editar, juntar o borrar commits antes de integrarlos. Nuestra rama nos ofrece un buen motivo para usarlo, porque los tres commits del capítulo 7 son pasos intermedios que no aportan nada al historial del libro. Lo ideal sería que el capítulo llegara a `main` como un único commit, así que vamos a juntarlos:

```bash
git rebase -i main
```

Git abre el editor con la lista de commits que se van a reaplicar, del más antiguo al más reciente:

```text
pick e41b07c Empieza el capítulo 7
pick 9a3d5f2 Añade cherry-pick al capítulo 7
pick c7f2e18 Añade rebase al capítulo 7
```

Para fundir los dos últimos con el anterior, cambia `pick` por `squash` (o simplemente `s`) en esas dos líneas:

```text
pick e41b07c Empieza el capítulo 7
squash 9a3d5f2 Añade cherry-pick al capítulo 7
squash c7f2e18 Añade rebase al capítulo 7
```

Guarda y cierra el editor. A continuación, Git abre otro editor con los tres mensajes, que se combinarán en uno: sustitúyelos por `Añade el capítulo 7: comandos avanzados`, guarda y cierra. Si ahora ejecutas `git tree`, verás un único commit para el capítulo.

Si un rebase se complica (por ejemplo, con conflictos en varios commits seguidos), puedes cancelarlo en cualquier momento y volver al estado anterior:

```bash
git rebase --abort
```

Con esto, el capítulo 7 está terminado y sólo queda integrarlo en `main` con GitHub flow, como la corrección. Subimos la rama:

```bash
git push -u origin capitulo-avanzados
```

En GitHub, abre el pull request, fusiónalo y borra la rama. Después, actualizamos la copia local:

```bash
git switch main
git pull --prune
git branch -d capitulo-avanzados
```

Antes de seguir, conviene recordar la regla de oro del rebase: **no hagas rebase de commits que ya hayas subido y que otras personas puedan estar usando**. Como rebase crea commits nuevos, las demás personas tendrían una historia distinta de la tuya. Úsalo, en cambio, para ordenar tu trabajo local antes de compartirlo, como acabamos de hacer: la rama `capitulo-avanzados` no se subió a GitHub hasta después del rebase. El capítulo [Reorganizar el trabajo realizado](https://git-scm.com/book/es/v2/Ramificaciones-en-Git-Reorganizar-el-Trabajo-Realizado) de _Pro Git_ explica con más detalle cómo funciona el rebase y cuándo conviene evitarlo. Y si lo que necesitas es deshacer commits que ya están en GitHub, tampoco sirven `rebase` ni `reset`: para eso está `revert`, que veremos en el apartado siguiente.

## 7.4 Deshacer cambios ya publicados (revert)

En el apartado 3.3 usamos `git revert` para anular un commit sin reescribir el historial. Entonces el libro sólo estaba en tu ordenador, y `reset` también habría servido. Ahora la situación es distinta: el libro está en GitHub, el colaborador del módulo 6 tiene su fork y puede haber otros clones, como el del «portátil» del apartado 5.4. En estas condiciones, `revert` es la única forma segura de deshacer un cambio que ya ha llegado a `main`.

Para comprobarlo necesitamos un error que ya esté publicado, así que vamos a fabricarlo siguiendo el camino completo de cualquier cambio: añadiremos al capítulo 6 un párrafo equivocado en una rama, lo integraremos con un pull request y lo traeremos a nuestra copia local. Empezamos por la rama:

```bash
git switch -c amplia-capitulo-6
```

En ella, añade al final de `capitulos/06-flujos-de-trabajo.md` este párrafo, separado de la lista por una línea en blanco:

```markdown
En GitHub flow, cada versión se prepara en una rama `develop` antes de llegar a `main`.
```

Guardamos el cambio y subimos la rama:

```bash
git add -A
git commit -m "Amplía el capítulo 6 con las versiones"
git push -u origin amplia-capitulo-6
```

En GitHub, abre el pull request, fusiónalo y borra la rama. Después, actualizamos la copia local:

```bash
git switch main
git pull --prune
git branch -d amplia-capitulo-6
```

Ya tenemos el escenario: el párrafo está en `main`, tanto en GitHub como en nuestra copia y, potencialmente, en las de los demás. Y al releer el capítulo publicado salta el error: en GitHub flow no hay rama `develop`, como explica el apartado 7.2, y las versiones se marcan con etiquetas en `main`. El párrafo sobra, y queremos quitarlo sin perjudicar a nadie que ya tenga una copia del libro.

Antes de ver la solución, merece la pena entender por qué `reset` no sirve aquí. Con un `git reset --hard` en `main`, el commit desaparecería de tu copia local, pero no de GitHub. `git push` se negaría a subir el resultado, porque `main` en GitHub tiene un commit que tu `main` ya no tiene, y sólo se podría forzar con `git push --force`. Eso reescribiría `main` en GitHub, y a partir de ese momento las copias de los demás serían incompatibles con la oficial:

- Quien ya tuviera el commit seguiría teniéndolo en su `main`. Para Git, ese commit sería trabajo suyo pendiente de subir, así que en su próximo `git pull` y `git push` el commit borrado volvería a GitHub, sin que esa persona supiera que alguien lo había quitado.
- Las ramas y los pull requests abiertos que partieran de ese commit lo llevarían dentro, y al fusionarlos lo traerían de vuelta.
- Para evitarlo, cada colaborador tendría que enterarse y rehacer su copia a mano, con su propio `reset`.

En un proyecto con varias personas, reescribir `main` rompe la colaboración. `revert`, en cambio, sólo añade un commit: para los demás es un cambio más, que les llega con su próximo `git pull` como cualquier otro. Por eso, con commits ya publicados no se usa `reset`, sino `revert`.

En GitHub flow, la corrección también es un cambio más, así que se hace en una rama y llega a `main` con un pull request. Creamos la rama y buscamos el commit que hay que deshacer:

```bash
git switch -c revierte-capitulo-6
git log --oneline -3
```

```text
a91d3f7 (HEAD -> revierte-capitulo-6, origin/main, main) Merge pull request #N from tu-usuario/amplia-capitulo-6
4f8a2c6 Amplía el capítulo 6 con las versiones
6b0e2d9 Merge pull request #N from tu-usuario/capitulo-avanzados
```

El último commit es la fusión del pull request, y justo debajo está el commit que añadió el párrafo, que es el que queremos deshacer. La sintaxis es `git revert <id_del_commit>`, y en el ejemplo su identificador es `4f8a2c6`:

```bash
git revert 4f8a2c6
```

Usa el identificador que aparezca en tu `git log`.

Como en el apartado 3.3, Git abre el editor con el mensaje propuesto:

```text
Revert "Amplía el capítulo 6 con las versiones"

This reverts commit 4f8a2c6d0e9b18a7c5f3e2d1b6a4c8f7e9d0b3a5.
```

Guarda y cierra el editor, y revisa el resultado:

```bash
git tree
```

```text
* 8a52213 (HEAD -> revierte-capitulo-6) Revert "Amplía el capítulo 6 con las versiones"
*   a91d3f7 (origin/main, main) Merge pull request #N from tu-usuario/amplia-capitulo-6
|\
| * 4f8a2c6 Amplía el capítulo 6 con las versiones
|/
*   6b0e2d9 Merge pull request #N from tu-usuario/capitulo-avanzados
...
```

El commit original y su fusión siguen en el historial, y encima de ellos está el commit que los anula, en la rama `revierte-capitulo-6`. Fíjate en que `main` y `origin/main` no han cambiado:

```{.dot caption="git revert anula un cambio ya publicado sin reescribir main" alt="Del commit de fusión del capítulo 7 sale el commit Amplía el capítulo 6 con las versiones, que llega a main con un pull request. Encima de esa fusión, en la rama revierte-capitulo-6, está el commit Revert que lo anula"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; m7 [label="6b0e2d9 Merge pull request #N from\ntu-usuario/capitulo-avanzados" group=main]; c [label="4f8a2c6 Amplía el capítulo 6\ncon las versiones" group=rama]; m [label="a91d3f7 Merge pull request #N from\ntu-usuario/amplia-capitulo-6" group=main]; r [label="8a52213 Revert \"Amplía el capítulo 6\ncon las versiones\"" group=rama]
  e -> m7
  m -> r
  m7 -> c -> m
  paso1 [shape=point width=0.015 height=0.015 color="#4a5b70" fillcolor="#4a5b70" group=main]; hueco1 [style=invis label="" width=1.4]; hueco2 [style=invis group=main label="6b0e2d9 Merge pull request #N from\ntu-usuario/capitulo-avanzados"]
  m7 -> paso1 [arrowhead=none headclip=false]; paso1 -> m [tailclip=false]
  m -> hueco2 [style=invis]
  node [shape=plaintext, group=""]
  rm [class=refs label="main, origin/main"]; rc [class=rama label="revierte-capitulo-6"]; HEAD [class=head]
  { rank=same; m -> rm [class=ref dir=back] }
  { rank=same; paso1 -> hueco1 -> c [style=invis] }
  { rank=same; hueco2 -> r [style=invis] }
  { rank=same; r -> rc -> HEAD [class=ref dir=back] }
}
```

La rama `revierte-capitulo-6` sólo añade un commit encima de `main`, de modo que integrarla no reescribe nada: para quien tenga una copia del libro, es un cambio más que llegará con su próximo `git pull`. La integramos con GitHub flow, como los cambios anteriores, empezando por subir la rama:

```bash
git push -u origin revierte-capitulo-6
```

En GitHub, abre el pull request, fusiónalo y borra la rama. Después, actualizamos la copia local:

```bash
git switch main
git pull --prune
git branch -d revierte-capitulo-6
```

El capítulo 6 vuelve a estar como antes del párrafo erróneo, y el historial de `main` cuenta con honestidad lo que pasó: el párrafo se añadió y después se anuló.

Hay un detalle que conviene aclarar: hemos revertido el commit de la rama, no la fusión del pull request. Es lo más sencillo cuando el pull request tiene un solo commit. Para deshacer de una vez un pull request con varios commits, se revierte su commit de fusión con `git revert -m 1 <id_de_la_fusión>`. La opción `-m 1` indica que se conservan los cambios del primer padre, `main`, y se anulan los que trajo la rama. GitHub ofrece lo mismo con un botón: en la página de un pull request fusionado, _Revert_ crea una rama con el revert de la fusión y abre un pull request nuevo para integrarlo.

Por último, si el commit que se revierte toca líneas que han cambiado después, `git revert` puede encontrar un conflicto, igual que un merge. En ese caso, resuélvelo como en el apartado 4.3 y continúa con `git revert --continue`, o bien renuncia y vuelve al estado anterior con:

```bash
git revert --abort
```

Para terminar, vamos a dejar escrito en el libro lo que acabamos de aprender. Como cualquier otro cambio, va en su propia rama:

```bash
git switch -c capitulo-7-revert
```

Añade al final de `capitulos/07-comandos-avanzados.md` este párrafo, separado del anterior por una línea en blanco:

```markdown
Con `git revert <commit>` se crea un commit nuevo que anula los cambios de otro. A diferencia de `git reset`, no reescribe el historial, así que es la forma de deshacer commits que ya se han compartido sin romper las copias de los demás.
```

Guardamos el cambio y subimos la rama:

```bash
git add -A
git commit -m "Añade revert al capítulo 7"
git push -u origin capitulo-7-revert
```

Una vez más, abre el pull request, fusiónalo y borra la rama en GitHub. Después, actualizamos la copia local:

```bash
git switch main
git pull --prune
git branch -d capitulo-7-revert
```

Nuestro libro ya tiene siete capítulos. En el siguiente módulo, GitHub se encargará de revisarlo en cada pull request y de publicar automáticamente cada versión.
