# Módulo 7: Flujos de Trabajo y Comandos Avanzados

Este módulo organiza el trabajo del libro como en un proyecto profesional: qué aportan las interfaces gráficas, cómo se organizan las ramas con un flujo de trabajo (GitFlow y GitHub flow) y dos comandos que reescriben la historia (cherry-pick y rebase).

## 7.1 Interfaces Gráficas (GUI) vs Terminal

Todo lo hecho en la terminal se puede hacer también con programas gráficos. Estos son los más conocidos:

| Programa | Sistemas | Precio | Puntos fuertes |
| --- | --- | --- | --- |
| [GitHub Desktop](https://desktop.github.com) | Windows, macOS | Gratuito | Muy sencillo, integrado con GitHub (forks, PRs) |
| [GitKraken](https://www.gitkraken.com) | Windows, macOS, Linux | Gratuito para repositorios públicos | Gráfico de ramas muy visual, resolución de conflictos |
| [Sourcetree](https://www.sourcetreeapp.com) | Windows, macOS | Gratuito | Muy completo, expone casi todas las opciones de Git |
| VS Code (panel _Source Control_) | Windows, macOS, Linux | Gratuito | Integrado en el editor, ideal para escribir y confirmar sin cambiar de ventana |

Las interfaces gráficas son cómodas para tareas visuales: revisar un diff, preparar solo algunas líneas de un fichero, explorar el gráfico de ramas o resolver un conflicto con botones. Pero todas usan por debajo los mismos conceptos que ya conoces: directorio de trabajo, staging, commits, ramas y remotos. Si no entiendes esos conceptos, una GUI solo esconde lo que pasa; si los entiendes, es una herramienta más.

La terminal sigue siendo imprescindible: es lo único disponible en un servidor, es lo que usa toda la documentación y los sistemas de CI, y algunas operaciones (como el rebase interactivo) son más claras en ella. Un buen ejercicio es abrir la carpeta `~/proyectos/manual-git` con la GUI que prefieras y reconocer en ella los commits, ramas y etiquetas del libro.

## 7.2 Flujos de Trabajo: GitFlow y GitHub Flow

Git permite organizar las ramas con total libertad, y por eso los equipos acuerdan un **flujo de trabajo**: unas reglas sobre qué ramas existen y cómo se mueven los cambios entre ellas. Los dos más conocidos son GitFlow y GitHub flow.

**GitFlow** está pensado para proyectos que publican versiones numeradas y tienen que mantener varias a la vez, como una aplicación de escritorio. Usa estas ramas:

- `main`: solo contiene versiones publicadas. Cada commit de `main` es una versión y lleva su etiqueta.
- `develop`: rama de integración donde se acumula el trabajo para la próxima versión.
- `feature/<nombre>`: una rama por cada funcionalidad nueva. Sale de `develop` y vuelve a `develop`.
- `release/<versión>`: prepara una versión (últimos retoques y número de versión). Sale de `develop` y se fusiona en `main` y en `develop`.
- `hotfix/<versión>`: corrige un error urgente en una versión publicada. Sale de `main` y se fusiona en `main` y en `develop`.

El diagrama muestra un esquema general de GitFlow, no el historial del libro. Cada rama temporal sale de una rama permanente y vuelve a ella, y `main` solo recibe versiones terminadas:

```{.dot caption="Esquema general de GitFlow" alt="main solo recibe versiones. develop sale de main y recibe una funcionalidad. Una corrección urgente sale de main, crea la versión 1.0.1 y vuelve también a develop. La release 1.1 sale de develop, crea la versión 1.1 en main y vuelve a develop"}
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
  m1 -> d1 -> d2 -> d3 -> d4
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
  hueco [style=invis label="" group=develop]
  d1 -> hueco [style=invis]
  { rank=same; m2 -> hueco -> f1 [style=invis] }
  { rank=same; m3 -> d4 [style=invis] }
}
```

Seguir GitFlow con comandos normales de Git exige muchas fusiones, así que existe una extensión, `git-flow`, que las automatiza con comandos como `git flow feature start` o `git flow release finish`. Es útil en equipos grandes con varias versiones en mantenimiento, pero añade ramas y pasos que un proyecto pequeño no necesita.

**GitHub flow** es la alternativa sencilla, y es el flujo que sigue el libro a partir de ahora. Solo tiene una rama permanente, `main`, que siempre debe funcionar, y cada cambio sigue estos pasos:

1. Se crea una rama corta a partir de `main`, con un nombre que describe el cambio.
2. Se hacen commits en ella y se sube a GitHub.
3. Se abre un pull request para que otras personas revisen el cambio.
4. Cuando el pull request está aprobado, se fusiona en `main` y se borra la rama.

Es lo que se hizo en el módulo 6 con el capítulo 5: la rama `capitulo-github`, su pull request y el commit de fusión que GitHub creó en `main`. Así quedó el historial del autor después de descargar la fusión con `git pull`:

```{.dot caption="GitHub flow: el capítulo 5 llegó a main con un pull request" alt="Del commit Amplía el capítulo 4 con reflog sale el commit del capítulo 5, hecho en la rama capitulo-github. Un commit de fusión creado por el pull request lo une a main, donde están main, origin/main y HEAD"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; r [label="Amplía el capítulo 4 con reflog"]; c5 [label="Mi aportación colaborativa:\ncapítulo 5 sobre GitHub" group=rama]; pr [label="Merge pull request #1 from\n<colaborador>/capitulo-github"]
  e -> r -> pr
  r -> c5 -> pr
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]; om [class=remota label="origin/main"]
  { rank=same; pr -> main -> HEAD [class=ref dir=back] }
  { rank=same; om -> pr [class=ref dir=forward] }
}
```

El repositorio del autor no tiene la rama `capitulo-github`, que solo existió en el fork del colaborador, pero conserva su commit.

El capítulo 6 del libro, sobre flujos de trabajo, se escribe ya con GitHub flow, en una rama que se integra con un pull request en tu propio repositorio. Asegúrate de partir de la última versión de `main` y crea la rama:

```bash
cd ~/proyectos/manual-git
git switch main
git pull
git switch -c capitulo-flujos
```

Crea `capitulos/06-flujos-de-trabajo.md`:

```markdown
# Flujos de trabajo

Un flujo de trabajo son las reglas que sigue un equipo para usar las ramas.

- **GitFlow** usa dos ramas permanentes, `main` y `develop`, y ramas temporales para cada funcionalidad, cada versión y cada corrección urgente.
- **GitHub flow** usa una sola rama permanente, `main`. Cada cambio se hace en una rama corta y llega a `main` con un pull request.
```

Guárdalo con un commit:

```bash
git add -A
git commit -m "Añade el capítulo 6: flujos de trabajo"
```

Con seis capítulos, el libro está listo para su primera versión completa. Añade al final de `metadata.yaml` una línea con la versión, que Pandoc mostrará en la portada debajo del título:

```yaml
date: Versión 1.0.0
```

Guarda el cambio en otro commit y sube la rama a GitHub:

```bash
git add -A
git commit -m "Prepara la versión 1.0.0"
git push -u origin capitulo-flujos
```

En la página del repositorio en GitHub, pulsa _Compare & pull request_ en el aviso amarillo. Como la rama está en tu propio repositorio, no hace falta un fork: el pull request va de `capitulo-flujos` a `main` del mismo repositorio. Pulsa _Create pull request_ y, como no hay nadie más para revisarlo, fusiónalo tú mismo con _Merge pull request_ y _Confirm merge_. Después pulsa _Delete branch_ para borrar la rama en GitHub, que ya no hace falta.

En un equipo, otra persona revisaría el pull request antes de fusionarlo, como en el módulo 6. Aunque trabajes solo, cada pull request deja constancia del cambio y, en el módulo 8, servirá para que GitHub revise automáticamente el libro antes de fusionarlo.

Trae la fusión a tu copia local y borra la rama, que ya está integrada en `main`:

```bash
git switch main
git pull --prune
git branch -d capitulo-flujos
```

La opción `--prune` borra también `origin/capitulo-flujos`, la rama de seguimiento de una rama que ya no existe en GitHub.

En GitHub flow, las versiones se marcan con etiquetas en `main`. Crea una etiqueta anotada para la versión 1.0.0, que guarda autor, fecha y mensaje (apartado 3.3), y súbela a GitHub:

```bash
git tag -a v1.0.0 -m "Versión 1.0.0"
git push origin v1.0.0
git tree
```

El diagrama muestra el resultado. Los dos commits de la rama llegan a `main` con el commit de fusión del pull request, que lleva la etiqueta `v1.0.0`. `N` es el número que GitHub ha asignado al pull request:

```{.dot caption="La versión 1.0.0, publicada con GitHub flow" alt="Del commit Mejora el README salen los dos commits de la rama capitulo-flujos. El commit de fusión del pull request los une a main y lleva la etiqueta v1.0.0"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; p [label="Mejora el README con el\ncontenido y cómo colaborar"]; c6 [label="Añade el capítulo 6:\nflujos de trabajo" group=rama]; v [label="Prepara la versión 1.0.0" group=rama]; pr [label="Merge pull request #N from\ntu-usuario/capitulo-flujos"]
  e -> p -> pr
  p -> c6 -> v -> pr
  node [shape=plaintext, group=""]
  rpr [class=refs label="HEAD -> main, origin/main, v1.0.0"]
  { rank=same; pr -> rpr [class=ref dir=back] }
}
```

## 7.3 Comandos Avanzados: Cherry Pick y Rebase

**Cherry-pick** copia un commit concreto de otra rama en la rama actual, sin traer nada más. Es útil cuando una corrección se hizo en una rama pero también hace falta en otra.

Para verlo, empieza el capítulo 7 en una rama nueva:

```bash
git switch -c capitulo-avanzados
echo "# Comandos avanzados" > capitulos/07-comandos-avanzados.md
git add -A
git commit -m "Empieza el capítulo 7"
```

Mientras escribes, descubres una imprecisión en el capítulo 3. Corrígela en la misma rama: edita `capitulos/03-ramas.md` y cambia la última línea por una versión más precisa:

```markdown
Las ramas son baratas: Git guarda cada una en un fichero de solo 41 bytes con el identificador de su último commit.
```

```bash
git add -A
git commit -m "Precisa el tamaño de una rama en el capítulo 3"
git log --oneline -1
```

`git log --oneline -1` muestra solo el último commit: copia su identificador. La corrección debería llegar ya a `main`, pero el capítulo 7 está a medias y no puede ir con ella. Cherry-pick resuelve el problema: crea una rama a partir de `main` y copia en ella solo ese commit:

```bash
# Traer un commit específico a la rama actual
git switch -c corrige-capitulo-3 main
git cherry-pick <id_del_commit>
git tree
```

El último argumento de `git switch -c` indica desde dónde se crea la rama: aquí, desde `main` y no desde la rama actual. `git tree` muestra un commit nuevo en `corrige-capitulo-3` con el mismo mensaje pero distinto identificador: cherry-pick no mueve el commit, crea una copia. En el diagrama, la flecha discontinua une el original con su copia:

```{.dot caption="Cherry-pick: una copia de la corrección en una rama que sale de main" alt="De la fusión de la versión 1.0.0 salen dos ramas. En capitulo-avanzados están Empieza el capítulo 7 y la corrección del capítulo 3. En corrige-capitulo-3 hay una copia de esa corrección"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; pr [label="Merge pull request #N from\ntu-usuario/capitulo-flujos"]; s [label="Empieza el capítulo 7" group=avanzados]; c [label="Precisa el tamaño de una rama\nen el capítulo 3" group=avanzados]; c2 [label="Precisa el tamaño de una rama\nen el capítulo 3"]
  e -> pr -> s -> c
  pr -> c2
  c -> c2 [class=copia]
  node [shape=plaintext, group=""]
  rpr [class=refs label="main, origin/main, v1.0.0"]; ca [class=rama label="capitulo-avanzados"]; cc [class=rama label="corrige-capitulo-3"]; HEAD [class=head]
  { rank=same; pr -> rpr [class=ref dir=back] }
  { rank=same; ca -> c [class=ref dir=forward] }
  { rank=same; c2 -> cc -> HEAD [class=ref dir=back] }
  { rank=same; s -> c2 [style=invis] }
}
```

Si al aplicar el commit hay un conflicto, Git se detiene como en un merge. Puedes resolverlo y continuar con `git cherry-pick --continue`, o renunciar y volver al estado anterior con:

```bash
git cherry-pick --abort
```

Integra la corrección en `main` con GitHub flow, como en el apartado anterior. Primero, sube la rama:

```bash
git push -u origin corrige-capitulo-3
```

En GitHub, abre el pull request, fusiónalo y borra la rama. Después, actualiza tu copia local:

```bash
git switch main
git pull --prune
git branch -d corrige-capitulo-3
```

**Rebase** es la alternativa a `merge` para integrar los cambios de una rama en otra. En lugar de crear un commit de fusión, toma los commits de tu rama y los vuelve a aplicar, uno a uno, encima de la otra rama. El resultado es un historial lineal, como si hubieras empezado tu trabajo después de los últimos cambios.

Para verlo, vuelve al capítulo 7 y añade un párrafo sobre cherry-pick, con su commit:

```bash
git switch capitulo-avanzados
```

```markdown
Con `git cherry-pick <commit>` se copia un commit concreto de otra rama en la rama actual.
```

```bash
git add -A
git commit -m "Añade cherry-pick al capítulo 7"
```

Y otro sobre rebase, con su commit:

```markdown
Con `git rebase <rama>` se reaplican los commits de la rama actual encima de otra rama.
```

```bash
git add -A
git commit -m "Añade rebase al capítulo 7"
git tree
```

Mientras tanto, `main` ha avanzado con la fusión de la corrección, así que `git tree` muestra que `main` y `capitulo-avanzados` han divergido. Un merge crearía un commit de fusión; rebase, en cambio, reaplica los commits de la rama encima del último commit de `main`:

```bash
# Mover la rama actual sobre otra (Rebase)
git rebase main
git tree
```

Git avisa de que ha omitido un commit (_skipped previously applied commit_): la corrección del capítulo 3 ya está en `main` gracias al cherry-pick, así que no la vuelve a aplicar. Ahora el historial es una línea recta: los tres commits del capítulo 7 están después de la fusión de la corrección. Fíjate en que sus identificadores han cambiado: igual que cherry-pick, rebase crea copias nuevas de los commits. Los originales, en gris en el diagrama, ya no están en ninguna rama, como el commit descartado con `reset` en el apartado 3.2.

```{.dot caption="La rama capitulo-avanzados antes y después de git rebase main" alt="Antes, la rama capitulo-avanzados sale de la fusión de la versión 1.0.0, en paralelo a la corrección que llegó a main con un pull request. Después, las copias de los tres commits del capítulo 7 están encima de esa fusión, la corrección repetida desaparece y los originales quedan en gris"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  subgraph cluster_antes {
    label="Antes"
    a0 [label="Merge pull request #N from\ntu-usuario/capitulo-flujos"]; ac [label="Precisa el tamaño de una rama\nen el capítulo 3" group=mainA]; am [label="Merge pull request #N from\ntu-usuario/corrige-capitulo-3" group=mainA]
    a1 [label="Empieza el capítulo 7" group=a]; a2 [label="Precisa el tamaño de una rama\nen el capítulo 3" group=a]; a3 [label="Añade cherry-pick al capítulo 7" group=a]; a4 [label="Añade rebase al capítulo 7" group=a]
    a0 -> am
    a0 -> ac -> am
    a0 -> a1 -> a2 -> a3 -> a4
    node [shape=plaintext, group=""]
    ram [class=refs label="main, origin/main"]; ca1 [class=rama label="capitulo-avanzados"]; head1 [class=head label="HEAD"]
    { rank=same; ram -> am [class=ref dir=forward] }
    { rank=same; a4 -> ca1 -> head1 [class=ref dir=back] }
    { rank=same; ac -> a1 [style=invis] }
    { rank=same; am -> a2 [style=invis] }
  }
  subgraph cluster_despues {
    label="Después"
    d0 [label="Merge pull request #N from\ntu-usuario/capitulo-flujos"]; dc [label="Precisa el tamaño de una rama\nen el capítulo 3" group=lado]; dm [label="Merge pull request #N from\ntu-usuario/corrige-capitulo-3"]
    d1 [label="e41b07c Empieza el capítulo 7"]; d2 [label="9a3d5f2 Añade cherry-pick al capítulo 7"]; d3 [label="c7f2e18 Añade rebase al capítulo 7"]
    o1 [class=huerfano label="Empieza el capítulo 7"]; o2 [class=huerfano label="Precisa el tamaño de una rama\nen el capítulo 3"]; o3 [class=huerfano label="Añade cherry-pick al capítulo 7"]; o4 [class=huerfano label="Añade rebase al capítulo 7"]
    d0 -> dm -> d1 -> d2 -> d3
    d0 -> dc -> dm
    d0 -> o1 [class=huerfano]; o1 -> o2 [class=huerfano]; o2 -> o3 [class=huerfano]; o3 -> o4 [class=huerfano]
    node [shape=plaintext, group=""]
    rdm [class=refs label="main, origin/main"]; ca2 [class=rama label="capitulo-avanzados"]; head2 [class=head label="HEAD"]
    { rank=same; rdm -> dm [class=ref dir=forward] }
    { rank=same; d3 -> ca2 -> head2 [class=ref dir=back] }
    { rank=same; dc -> o1 [style=invis] }
    { rank=same; dm -> o2 [style=invis] }
  }
}
```

El **rebase interactivo** va más allá: permite reordenar, editar, juntar o borrar commits antes de integrarlos. Los tres commits del capítulo 7 son pasos intermedios que no aportan nada al historial del libro, así que conviene juntarlos en uno:

```bash
git rebase -i main
```

Git abre el editor con la lista de commits que se van a reaplicar, del más antiguo al más reciente:

```text
pick e41b07c Empieza el capítulo 7
pick 9a3d5f2 Añade cherry-pick al capítulo 7
pick c7f2e18 Añade rebase al capítulo 7
```

Cambia `pick` por `squash` (o simplemente `s`) en las dos últimas líneas, para fundirlas con la anterior:

```text
pick e41b07c Empieza el capítulo 7
squash 9a3d5f2 Añade cherry-pick al capítulo 7
squash c7f2e18 Añade rebase al capítulo 7
```

Guarda y cierra el editor. Git abre otro editor con los tres mensajes para que escribas el mensaje del commit combinado: déjalo como `Añade el capítulo 7: comandos avanzados`, guarda y cierra. `git tree` muestra ahora un único commit para el capítulo.

Si un rebase se complica (por ejemplo, con conflictos en varios commits seguidos), puedes cancelarlo en cualquier momento y volver al estado anterior:

```bash
git rebase --abort
```

El capítulo 7 está terminado. Intégralo en `main` con GitHub flow, como la corrección: sube la rama, abre el pull request, fusiónalo y borra la rama en GitHub. Después, actualiza tu copia local:

```bash
git push -u origin capitulo-avanzados
```

```bash
git switch main
git pull --prune
git branch -d capitulo-avanzados
```

La regla de oro del rebase: **no hagas rebase de commits que ya hayas subido y que otras personas puedan estar usando**. Como rebase crea commits nuevos, las demás personas tendrían una historia distinta de la tuya. Úsalo para ordenar tu trabajo local antes de compartirlo, como aquí: la rama `capitulo-avanzados` no se subió a GitHub hasta después del rebase.

El libro ya tiene siete capítulos. En el siguiente módulo, GitHub se encargará de revisarlo en cada pull request y de publicar automáticamente cada versión.
