# Módulo 3: Viajes en el tiempo y puntos de guardado

El historial de commits no es solo un registro: es una máquina del tiempo. Este módulo explica cómo visitar versiones anteriores del libro, cómo deshacer commits enteros, ya sea borrándolos de la rama (y recuperándolos en caso de arrepentimiento) o anulándolos con un commit nuevo, y cómo marcar versiones importantes con etiquetas.

## 3.1 Navegar a estados anteriores del proyecto

Imagina que quieres ver cómo era el libro cuando solo tenía el capítulo 1. Primero, busca ese commit en el historial:

```bash
git tree
```

```text
* 5e7b3a2 (HEAD -> main) Añade el origen de Git al capítulo 1
* 9d1c4f8 Añade el script de generación del libro con Pandoc
* 3f2a1b9 Añade el capítulo 2: primeros comandos
* 8c4d2e7 Añade el capítulo 1: qué es Git
* 1a9f0c3 Añade el README del libro
```

Tus identificadores serán distintos. Copia el del commit _Añade el capítulo 1: qué es Git_ y viaja a él con `git checkout`:

```bash
git checkout <id_del_commit>
```

Git mostrará un aviso sobre _detached HEAD_ (HEAD desacoplado). Significa que `HEAD`, el puntero que indica la posición actual, ya no apunta a una rama sino directamente a un commit antiguo. Es un modo de consulta: puedes mirar todo lo que quieras. Compruébalo:

```bash
ls capitulos
git tree
```

En `capitulos` solo está `01-que-es-git.md`, y tampoco existen `build.sh` ni `metadata.yaml`: los ficheros han vuelto exactamente al estado de aquel commit. En `git tree` verás que `HEAD` está en el commit antiguo y `main` sigue en el más reciente:

```{.dot caption="HEAD desacoplado: HEAD apunta a un commit, no a una rama" alt="Cinco commits. main apunta al último y HEAD apunta directamente al commit del capítulo 1"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  c1 [label="1a9f0c3 Añade el README del libro"]; c2 [label="8c4d2e7 Añade el capítulo 1: qué es Git"]; c3 [label="3f2a1b9 Añade el capítulo 2: primeros comandos"]; c4 [label="9d1c4f8 Añade el script de generación\ndel libro con Pandoc"]; c5 [label="5e7b3a2 Añade el origen de Git al capítulo 1"]
  c1 -> c2 -> c3 -> c4 -> c5
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]
  { rank=same; c5 -> main [class=ref dir=back] }
  { rank=same; c2 -> HEAD [class=ref dir=back] }
}
```

Para volver al presente, cambia de nuevo a la rama `main`:

```bash
git checkout main
```

Todo vuelve a estar como antes. Si en modo _detached HEAD_ haces cambios y commits, no se pierden en ese momento, pero no pertenecen a ninguna rama y acabarán desapareciendo. Si quieres conservarlos, crea una rama antes de salir (se explica en el módulo 4).

## 3.2 Eliminar cambios permanentemente (`reset --hard`) y recuperar el historial (`reflog`)

A veces no basta con mirar el pasado: hace falta volver a él y olvidar lo que vino después. Para provocar una situación así, reescribe el capítulo 2 con un contenido malo y guárdalo en un commit.

```bash
echo "# Capítulo en obras" > capitulos/02-primeros-comandos.md
git add -A
git commit -m "Reescribe el capítulo 2"
```

Al releerlo, resulta que la versión anterior era mejor. Busca con `git tree` el identificador del commit anterior al malo (_Añade el origen de Git al capítulo 1_) y mueve la rama `main` a ese punto:

```bash
git reset --hard <id_del_commit>
```

`git reset --hard` mueve la rama actual al commit indicado y deja el directorio de trabajo exactamente como estaba en ese commit. El capítulo 2 recupera su contenido y el commit malo deja de aparecer en `git tree`. Es una operación peligrosa: los cambios que no estaban guardados en ningún commit se pierden para siempre. Además, solo conviene usarla con commits que todavía no has compartido con nadie. El apartado 3.3 explica la alternativa para los que ya están compartidos.

```{.dot caption="La rama main antes y después de git reset --hard" alt="Antes, main apunta al commit Reescribe el capítulo 2. Después, main apunta al commit anterior y Reescribe el capítulo 2 queda en gris, sin ninguna rama"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  subgraph cluster_antes {
    label="Antes"
    a4 [label="9d1c4f8 Añade el script de generación\ndel libro con Pandoc"]; a5 [label="5e7b3a2 Añade el origen de Git al capítulo 1"]; a6 [label="b4e8d61 Reescribe el capítulo 2"]
    a4 -> a5 -> a6
    node [shape=plaintext, group=""]
    main1 [class=rama label="main"]; head1 [class=head label="HEAD"]
    { rank=same; a6 -> main1 -> head1 [class=ref dir=back] }
  }
  subgraph cluster_despues {
    label="Después"
    d4 [label="9d1c4f8 Añade el script de generación\ndel libro con Pandoc"]; d5 [label="5e7b3a2 Añade el origen de Git al capítulo 1"]; d6 [class=huerfano label="b4e8d61 Reescribe el capítulo 2"]
    d4 -> d5; d5 -> d6 [class=huerfano]
    node [shape=plaintext, group=""]
    main2 [class=rama label="main"]; head2 [class=head label="HEAD"]
    { rank=same; d5 -> main2 -> head2 [class=ref dir=back] }
  }
}
```

Como se ve en el diagrama, el commit malo no se ha borrado: sigue guardado en el repositorio, pero ya no está en ninguna rama, y por eso `git tree` no lo muestra. Los commits en gris de los diagramas están en esta situación.

Ahora supón que cambias de opinión otra vez y quieres recuperar ese commit. No aparece en `git log`, pero Git sigue guardándolo. `git reflog` muestra todos los movimientos de `HEAD`, incluidos commits, checkouts y resets:

```bash
git reflog
```

```text
5e7b3a2 (HEAD -> main) HEAD@{0}: reset: moving to 5e7b3a2
b4e8d61 HEAD@{1}: commit: Reescribe el capítulo 2
5e7b3a2 (HEAD -> main) HEAD@{2}: checkout: moving from 8c4d2e7f1a6b9c03d5e2847a1f6c9b0e3d7a2f5c to main
...
```

Ahí está el commit _Reescribe el capítulo 2_. Cada línea es un movimiento, del más reciente al más antiguo: `HEAD@{2}` es la vuelta a `main` del apartado 3.1, en la que Git anota el identificador completo del commit del que venía. Para recuperar el commit malo, haz un `reset --hard` a su identificador:

```bash
git reset --hard <id_del_commit>
```

El commit vuelve a estar en `main`. Como en realidad ese commit sobraba, repite el primer `reset --hard` para dejar el libro bien:

```bash
git reset --hard HEAD~1
```

`HEAD~1` significa «el commit anterior a `HEAD`», así que no hace falta copiar el identificador. Comprueba con `git tree` que el último commit vuelve a ser _Añade el origen de Git al capítulo 1_.

Recuerda: `reflog` es local (no se sube a GitHub) y Git lo limpia pasados unos 90 días. Es una red de seguridad, no un sustituto de hacer commits.

## 3.3 Deshacer un commit sin reescribir el historial (`revert`)

`reset` hace que los commits desaparezcan de la rama: reescribe el historial. Mientras esos commits solo estén en tu ordenador no pasa nada, pero a partir del módulo 5 el libro estará en GitHub y otras personas tendrán copias del historial. Si un commit que ya tienen otras personas desaparece de tu rama, tu historia y la suya dejan de coincidir.

`git revert` deshace un commit de otra forma: crea un commit nuevo que aplica los cambios contrarios. El commit original sigue en el historial, y el nuevo lo anula. El historial solo crece, nunca se reescribe.

Para comparar las dos formas, repite el mismo error del apartado anterior:

```bash
echo "# Capítulo en obras" > capitulos/02-primeros-comandos.md
git add -A
git commit -m "Reescribe el capítulo 2"
```

Esta vez, deshazlo con `revert`. `HEAD` es el último commit, el que se quiere anular:

```bash
git revert HEAD
```

Git prepara el commit que deshace los cambios y abre el editor con un mensaje propuesto, debajo del cual hay unas líneas de comentario que empiezan por `#` y no se guardan:

```text
Revert "Reescribe el capítulo 2"

This reverts commit 7c1e5b8a3f9d2e6c4b1a0f8e7d5c3b2a9e6f4d10.
```

El mensaje indica qué commit se deshace, con su identificador completo. Guarda y cierra el editor sin cambiar nada. Si no quieres que se abra el editor, `git revert --no-edit HEAD` acepta directamente el mensaje propuesto. El capítulo 2 vuelve a tener su contenido, y `git tree` muestra los dos commits, el malo y el que lo anula:

```{.dot caption="git revert añade un commit que anula el anterior" alt="Después del commit Añade el origen de Git al capítulo 1 están el commit Reescribe el capítulo 2 y el commit Revert que lo anula. main y HEAD apuntan al commit Revert"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c5 [label="5e7b3a2 Añade el origen de Git al capítulo 1"]; c6 [label="7c1e5b8 Reescribe el capítulo 2"]; c7 [label="Revert \"Reescribe el capítulo 2\""]
  e -> c5 -> c6 -> c7
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]
  { rank=same; c7 -> main -> HEAD [class=ref dir=back] }
}
```

Compáralo con el diagrama del apartado 3.2: allí el commit malo quedaba en gris, fuera de la rama, y aquí sigue en `main`, con otro commit encima que lo anula. Para comprobar que el contenido es el mismo que antes del error, compara el estado actual con el de dos commits atrás (`HEAD~2`), como en el apartado 2.6:

```bash
git diff HEAD~2
```

No muestra nada: los ficheros son idénticos a los del commit _Añade el origen de Git al capítulo 1_.

| | `git reset --hard` | `git revert` |
| --- | --- | --- |
| Qué hace | Mueve la rama a un commit anterior | Crea un commit que anula otro |
| Historial | Se reescribe: los commits desaparecen de la rama | Se conserva: solo se añade un commit |
| Cuándo usarlo | Con commits que solo están en tu ordenador | Con commits que ya has compartido |

La regla práctica es sencilla: si nadie más tiene el commit, puedes usar `reset`; si ya lo has compartido, usa `revert`. En el apartado 7.4 se usa `revert` para deshacer un cambio que ya ha llegado a GitHub.

## 3.4 Etiquetas (tags) para marcar versiones importantes

El libro ya tiene dos capítulos y un script que lo genera: es un buen momento para declarar un primer borrador. Las **etiquetas** (_tags_) ponen un nombre fijo a un commit concreto, normalmente un número de versión. A diferencia de una rama, una etiqueta no se mueve cuando haces commits nuevos.

El curso usa el formato habitual de [versionado semántico](https://semver.org/lang/es/) con una `v` delante: `v0.1.0`. Crea la etiqueta en el commit actual:

```bash
git tag v0.1.0
```

Para ver la lista de etiquetas:

```bash
git tag
```

Las etiquetas también aparecen en `git tree`, junto al commit al que apuntan. Para poder ver la diferencia entre versiones, haz un cambio después de la etiqueta. Añade al `README.md` una sección que explique cómo generar el libro:

````markdown
## Cómo generar el libro

Necesitas Pandoc (y, opcionalmente, Typst para el PDF). Ejecuta:

```bash
./build.sh
```

El libro se genera en la carpeta `dist`.
````

Y guarda el cambio:

```bash
git add -A
git commit -m "Explica en el README cómo generar el libro"
```

`main` ha avanzado con el commit nuevo, pero la etiqueta, en ocre en el diagrama, se queda en su commit:

```{.dot caption="La etiqueta v0.1.0 se queda fija cuando main avanza" alt="La etiqueta v0.1.0 apunta al commit Revert Reescribe el capítulo 2, y main y HEAD al commit siguiente"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c4 [label="Reescribe el capítulo 2"]; c5 [label="Revert \"Reescribe el capítulo 2\""]; c6 [label="Explica en el README cómo\ngenerar el libro"]
  e -> c4 -> c5 -> c6
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]; v010 [class=etiqueta label="v0.1.0"]
  { rank=same; c6 -> main -> HEAD [class=ref dir=back] }
  { rank=same; c5 -> v010 [class=ref dir=back] }
}
```

Ahora imagina que alguien te pide el libro exactamente como estaba en la versión `v0.1.0`. Basta con viajar a la etiqueta y generar el libro desde allí, pasando la versión al script:

```bash
git checkout tags/v0.1.0
./build.sh v0.1.0
```

En `dist` tienes ahora `manual-git-v0.1.0.docx` (y el PDF, si tienes Typst). Al cambiar de versión, Git no toca los ficheros que no controla, como los de `dist/`, que además está en el `.gitignore`: los ficheros generados se conservan. Vuelve al presente:

```bash
git checkout main
```

Las etiquetas creadas así son _ligeras_: solo un nombre que apunta a un commit. Git también admite etiquetas _anotadas_, que guardan autor, fecha y un mensaje (`git tag -a v0.1.0 -m "Primer borrador"`). En el módulo 7 se usan etiquetas anotadas para marcar cada versión del libro, y en el módulo 8 GitHub las usará para publicarlas automáticamente.
