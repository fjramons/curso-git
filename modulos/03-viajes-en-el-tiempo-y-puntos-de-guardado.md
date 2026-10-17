# Módulo 3: Viajes en el tiempo y puntos de guardado

El historial de commits no es sólo un registro de lo que hemos hecho: es una máquina del tiempo. En este módulo vamos a aprovecharla de tres formas. Primero visitaremos versiones anteriores del libro sin cambiar nada; después veremos dos maneras de deshacer un commit entero, ya sea borrándolo de la rama (con la posibilidad de recuperarlo si nos arrepentimos) o anulándolo con un commit nuevo; y, por último, marcaremos con una etiqueta la primera versión del libro para poder volver a ella siempre que queramos.

## 3.1 Navegar a estados anteriores del proyecto

Empecemos por lo más sencillo: mirar el pasado sin tocarlo. Supongamos que queremos ver cómo era el libro cuando sólo tenía el capítulo 1, antes de que llegaran el capítulo 2 y el script de Pandoc. Para viajar a ese momento necesitamos saber a qué commit corresponde, así que lo buscamos en el historial:

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

El que nos interesa es el del commit _Añade el capítulo 1: qué es Git_, que en el ejemplo es `8c4d2e7`. La sintaxis es `git checkout <id_del_commit>`, que lleva el proyecto a ese commit:

```bash
git checkout 8c4d2e7
```

Tus identificadores serán distintos de los del ejemplo, así que usa el que aparezca en tu `git tree`.

Git responde con un aviso sobre _detached HEAD_ (HEAD desacoplado). No es un error: significa que `HEAD`, el puntero que indica dónde estamos, ya no apunta a una rama sino directamente a un commit antiguo. Es un modo de consulta en el que podemos mirar todo lo que queramos, así que comprobemos que de verdad hemos viajado al pasado:

```bash
ls capitulos
git tree
```

```text
* 5e7b3a2 (main) Añade el origen de Git al capítulo 1
* 9d1c4f8 Añade el script de generación del libro con Pandoc
* 3f2a1b9 Añade el capítulo 2: primeros comandos
* 8c4d2e7 (HEAD) Añade el capítulo 1: qué es Git
* 1a9f0c3 Añade el README del libro
```

En `capitulos` sólo queda `01-que-es-git.md`, y tampoco existen `build.sh` ni `metadata.yaml`: los ficheros han vuelto exactamente al estado de aquel commit. `git tree`, por su parte, muestra que `HEAD` está en el commit antiguo mientras `main` sigue en el más reciente, que es lo que refleja el diagrama:

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

Una vez satisfecha la curiosidad, volvemos al presente cambiando de nuevo a la rama `main`:

```bash
git checkout main
```

Todo vuelve a estar como antes. Conviene saber, eso sí, que este modo sirve para mirar y no para trabajar: si en _detached HEAD_ haces cambios y commits, no se pierden en ese momento, pero no pertenecen a ninguna rama y acabarán desapareciendo. Si quieres conservarlos, crea una rama antes de salir (lo veremos en el módulo 4).

## 3.2 Eliminar cambios permanentemente (`reset --hard`)

A veces no basta con mirar el pasado: hace falta volver a él y olvidar lo que vino después. Para verlo necesitamos primero un error del que arrepentirnos, así que vamos a fabricarlo a propósito: sustituiremos el capítulo 2 por un contenido provisional y lo guardaremos en un commit, como si fuera un cambio de verdad.

```bash
echo "# Capítulo en obras" > capitulos/02-primeros-comandos.md
git add -A
git commit -m "Reescribe el capítulo 2"
```

Ya tenemos el escenario. Si ejecutas `git tree`, verás el commit malo encima de todos los demás:

```text
* b4e8d61 (HEAD -> main) Reescribe el capítulo 2
* 5e7b3a2 Añade el origen de Git al capítulo 1
* 9d1c4f8 Añade el script de generación del libro con Pandoc
* 3f2a1b9 Añade el capítulo 2: primeros comandos
* 8c4d2e7 Añade el capítulo 1: qué es Git
* 1a9f0c3 Añade el README del libro
```

El diagrama muestra la parte de arriba de ese historial, con `main` y `HEAD` en el commit malo:

```{.dot caption="El commit malo es el último de main" alt="Tres commits. El último, Reescribe el capítulo 2, tiene encima main y HEAD"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c4 [label="9d1c4f8 Añade el script de generación\ndel libro con Pandoc"]; c5 [label="5e7b3a2 Añade el origen de Git al capítulo 1"]; c6 [label="b4e8d61 Reescribe el capítulo 2"]
  e -> c4 -> c5 -> c6
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]
  { rank=same; c6 -> main -> HEAD [class=ref dir=back] }
}
```

Supongamos que, al releer el capítulo, decidimos que la versión anterior era mucho mejor y que ese commit no debería haber existido nunca. Lo que queremos, por tanto, es que `main`, y con ella `HEAD`, retroceda un commit hasta _Añade el origen de Git al capítulo 1_, y que los ficheros vuelvan a estar como en ese commit.

Ese es justo el trabajo de `git reset --hard`, que mueve la rama actual al commit que se le indica y deja el directorio de trabajo exactamente como estaba en ese commit. Su sintaxis es `git reset --hard <id_del_commit>`, así que sólo necesitamos el identificador del commit al que queremos volver. En el ejemplo, según la salida de `git tree` y el diagrama, es `5e7b3a2`:

```bash
git reset --hard 5e7b3a2
```

Tu identificador será distinto: usa el que aparezca en tu `git tree` junto a _Añade el origen de Git al capítulo 1_. El capítulo 2 ha recuperado su contenido, y para ver qué ha pasado con el historial volvemos a consultarlo:

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

`main` y `HEAD` están ahora en `5e7b3a2`, y el commit malo ha desaparecido de la lista: a todos los efectos, lo hemos borrado. El diagrama muestra cómo queda el historial:

```{.dot caption="Después de git reset --hard, el commit malo ha desaparecido de main" alt="main y HEAD apuntan al commit Añade el origen de Git al capítulo 1, que vuelve a ser el último"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c4 [label="9d1c4f8 Añade el script de generación\ndel libro con Pandoc"]; c5 [label="5e7b3a2 Añade el origen de Git al capítulo 1"]
  e -> c4 -> c5
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]
  { rank=same; c5 -> main -> HEAD [class=ref dir=back] }
}
```

`git reset --hard` es una operación potente, pero también peligrosa: los cambios que no estaban guardados en ningún commit se pierden para siempre. Además, sólo conviene usarla con commits que todavía no hemos compartido con nadie; en el apartado 3.3 veremos la alternativa para los que ya están compartidos.

Como curiosidad, el commit borrado no ha desaparecido del todo: Git lo conserva oculto durante un tiempo, y eso permite recuperarlo si lo hemos borrado por accidente. Lo veremos en el apartado avanzado que sigue, pero en el día a día basta con pensar que `reset --hard` borra los commits.

Por otra parte, cuando algo sale mal con Git lo más probable es que a muchas personas les haya pasado antes. La web [Oh Shit, Git!?!](https://ohshitgit.com/es), en español, recoge las situaciones más habituales (un commit en la rama equivocada, un mensaje mal escrito, un fichero olvidado…) y el comando exacto para arreglar cada una.

### 3.2.1 Avanzado: recuperar un commit borrado (`reflog`)

Este apartado es avanzado, así que puedes saltártelo en una primera lectura y volver a él el día que borres por error un commit que sí querías. Al terminarlo, el libro quedará exactamente igual que al empezar.

Hemos dicho que `reset --hard` borra el commit, pero en realidad no es así. Lo que hace es mover la rama: el commit _Reescribe el capítulo 2_ sigue guardado en el repositorio, con todo su contenido, sólo que ya no hay ninguna rama que llegue hasta él. Como `git log` y `git tree` sólo muestran los commits a los que se llega desde una rama o desde `HEAD`, el commit sigue ahí, pero oculto y perdido. El diagrama muestra la situación real, con ese commit en gris y con el contorno discontinuo, que es como dibujaremos en el curso los commits que han quedado fuera de toda rama:

```{.dot caption="El commit borrado sigue en el repositorio, fuera de toda rama" alt="main y HEAD apuntan al commit Añade el origen de Git al capítulo 1. El commit Reescribe el capítulo 2 sigue encima, en gris, con el contorno discontinuo y sin ninguna rama"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c4 [label="9d1c4f8 Añade el script de generación\ndel libro con Pandoc"]; c5 [label="5e7b3a2 Añade el origen de Git al capítulo 1"]; c6 [class=huerfano style="rounded,dashed" color=gray50 fontcolor=gray50 label="b4e8d61 Reescribe el capítulo 2"]
  e -> c4 -> c5; c5 -> c6 [class=huerfano style=dashed color=gray50]
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]
  { rank=same; c5 -> main -> HEAD [class=ref dir=back] }
}
```

Que el commit siga guardado abre una puerta interesante. Supongamos que cambiamos de opinión y queremos recuperarlo. El problema es que ya no aparece ni en `git log` ni en `git tree`, así que no tenemos a mano su identificador. Para encontrarlo recurrimos a `git reflog`, que muestra todos los movimientos de `HEAD`, incluidos los commits, los checkouts y los resets:

```bash
git reflog
```

```text
5e7b3a2 (HEAD -> main) HEAD@{0}: reset: moving to 5e7b3a2
b4e8d61 HEAD@{1}: commit: Reescribe el capítulo 2
5e7b3a2 (HEAD -> main) HEAD@{2}: checkout: moving from 8c4d2e7f1a6b9c03d5e2847a1f6c9b0e3d7a2f5c to main
...
```

Ahí está el commit _Reescribe el capítulo 2_. Cada línea es un movimiento, del más reciente al más antiguo: `HEAD@{0}` es el reset que acabamos de hacer, `HEAD@{1}` es el commit perdido y `HEAD@{2}` es la vuelta a `main` del apartado 3.1, en la que Git anota el identificador completo del commit del que veníamos. Con el identificador del commit perdido en la mano (`b4e8d61` en el ejemplo, el commit gris del diagrama), recuperarlo es tan sencillo como hacer otro `reset --hard`, esta vez hacia él:

```bash
git reset --hard b4e8d61
```

Como antes, usa el identificador que aparezca en tu `reflog`. El commit vuelve a estar en `main`, como en el primer diagrama del apartado, lo que demuestra que el reset no lo había destruido. Como en realidad ese commit sobraba, terminamos repitiendo el primer `reset --hard` para dejar el libro como estaba, aunque esta vez sin necesidad de copiar ningún identificador:

```bash
git reset --hard HEAD~1
```

`HEAD~1` significa «el commit anterior a `HEAD`», que es justo adonde queremos llevar la rama. Si ejecutas `git tree`, verás que el último commit vuelve a ser _Añade el origen de Git al capítulo 1_.

Eso sí, esta red de seguridad tiene límites. El `reflog` es local (no se sube a GitHub), y un commit perdido sólo se conserva mientras el `reflog` lo recuerda: por defecto, Git olvida esas entradas a los 30 días (las del resto de movimientos, a los 90) y después elimina los commits perdidos en su limpieza periódica. Recuperar un commit con `reflog` es un recurso para accidentes, no un sustituto de hacer commits.

## 3.3 Deshacer un commit sin reescribir el historial (`revert`)

`reset` resuelve el problema haciendo que los commits desaparezcan de la rama, es decir, reescribiendo el historial. Mientras esos commits sólo estén en nuestro ordenador no pasa nada, pero a partir del módulo 5 el libro estará en GitHub y otras personas tendrán copias del historial. Si un commit que ya tienen otras personas desaparece de nuestra rama, nuestra historia y la suya dejan de coincidir.

`git revert` deshace un commit de otra forma: en lugar de borrarlo, crea un commit nuevo que aplica los cambios contrarios. El commit original sigue en el historial y el nuevo lo anula, de modo que el historial sólo crece y nunca se reescribe.

La mejor manera de apreciar la diferencia es enfrentarse al mismo problema que en el apartado anterior y resolverlo de la otra forma. Así que vamos a repetir el error tal cual, con el mismo contenido y el mismo mensaje:

```bash
echo "# Capítulo en obras" > capitulos/02-primeros-comandos.md
git add -A
git commit -m "Reescribe el capítulo 2"
```

Estamos de nuevo en el punto de partida: el último commit de `main` vacía el capítulo 2 y queremos deshacerlo. La diferencia es que esta vez queremos hacerlo sin que el commit desaparezca del historial, como si ya lo hubiéramos compartido. Como el commit que queremos anular es el último, nos basta con `HEAD` para referirnos a él:

```bash
git revert HEAD
```

Git prepara el commit que deshace los cambios y abre el editor con un mensaje propuesto. Debajo del mensaje verás unas líneas de comentario que empiezan por `#` y que no se guardan:

```text
Revert "Reescribe el capítulo 2"

This reverts commit 7c1e5b8a3f9d2e6c4b1a0f8e7d5c3b2a9e6f4d10.
```

El mensaje indica qué commit se deshace, con su identificador completo, así que podemos aceptarlo tal cual: guarda y cierra el editor sin cambiar nada. Si prefieres que no se abra el editor, `git revert --no-edit HEAD` acepta directamente el mensaje propuesto. El capítulo 2 vuelve a tener su contenido, y para ver qué ha pasado con el historial lo consultamos de nuevo:

```bash
git tree
```

```text
* 7bbac28 (HEAD -> main) Revert "Reescribe el capítulo 2"
* 7c1e5b8 Reescribe el capítulo 2
* 5e7b3a2 Añade el origen de Git al capítulo 1
* 9d1c4f8 Añade el script de generación del libro con Pandoc
* 3f2a1b9 Añade el capítulo 2: primeros comandos
* 8c4d2e7 Añade el capítulo 1: qué es Git
* 1a9f0c3 Añade el README del libro
```

A diferencia de lo que pasaba con `reset`, `git tree` muestra los dos commits, el malo y el que lo anula:

```{.dot caption="git revert añade un commit que anula el anterior" alt="Después del commit Añade el origen de Git al capítulo 1 están el commit Reescribe el capítulo 2 y el commit Revert que lo anula. main y HEAD apuntan al commit Revert"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c5 [label="5e7b3a2 Añade el origen de Git al capítulo 1"]; c6 [label="7c1e5b8 Reescribe el capítulo 2"]; c7 [label="7bbac28 Revert \"Reescribe el capítulo 2\""]
  e -> c5 -> c6 -> c7
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]
  { rank=same; c7 -> main -> HEAD [class=ref dir=back] }
}
```

Si comparamos este diagrama con el del apartado 3.2, la diferencia salta a la vista: allí el commit malo desaparecía de la rama, y aquí sigue en `main`, con otro commit encima que lo anula. Sólo queda comprobar que el contenido es el mismo que antes del error, y para ello comparamos el estado actual con el de dos commits atrás (`HEAD~2`), como en el apartado 2.6:

```bash
git diff HEAD~2
```

`git diff` no muestra nada, lo que confirma que los ficheros son idénticos a los del commit _Añade el origen de Git al capítulo 1_. La tabla resume las dos formas de deshacer un commit que hemos visto:

| | `git reset --hard` | `git revert` |
| --- | --- | --- |
| Qué hace | Mueve la rama a un commit anterior | Crea un commit que anula otro |
| Historial | Se reescribe: los commits desaparecen de la rama | Se conserva: sólo se añade un commit |
| Cuándo usarlo | Con commits que sólo están en tu ordenador | Con commits que ya has compartido |

De todo esto se desprende una regla práctica sencilla: si nadie más tiene el commit, puedes usar `reset`; si ya lo has compartido, usa `revert`. En el apartado 7.4 volveremos a `revert` para deshacer un cambio que ya habrá llegado a GitHub.

## 3.4 Etiquetas (tags) para marcar versiones importantes

Después de tanto ir y venir, el libro ya tiene dos capítulos y un script que lo genera, así que es un buen momento para declarar un primer borrador al que poder volver siempre que haga falta. Para eso están las **etiquetas** (_tags_), que ponen un nombre fijo a un commit concreto, normalmente un número de versión. A diferencia de una rama, una etiqueta no se mueve cuando se hacen commits nuevos.

En el curso usaremos el formato habitual del [versionado semántico](https://semver.org/lang/es/) con una `v` delante, así que nuestro primer borrador será la `v0.1.0`. La creamos en el commit actual:

```bash
git tag v0.1.0
```

Y podemos ver la lista de etiquetas del repositorio con:

```bash
git tag
```

Las etiquetas también aparecen en `git tree`, junto al commit al que apuntan. Sin embargo, mientras el libro no avance es difícil apreciar qué las distingue de una rama, así que vamos a seguir trabajando más allá de la `v0.1.0`. Añade al `README.md` una sección que explique cómo generar el libro:

````markdown
## Cómo generar el libro

Necesitas Pandoc (y, opcionalmente, Typst para el PDF). Ejecuta:

```bash
./build.sh
```

El libro se genera en la carpeta `dist`.
````

Y guarda el cambio con un commit:

```bash
git add -A
git commit -m "Explica en el README cómo generar el libro"
git tree
```

```text
* 852e4f5 (HEAD -> main) Explica en el README cómo generar el libro
* 7bbac28 (tag: v0.1.0) Revert "Reescribe el capítulo 2"
* 7c1e5b8 Reescribe el capítulo 2
* 5e7b3a2 Añade el origen de Git al capítulo 1
* 9d1c4f8 Añade el script de generación del libro con Pandoc
* 3f2a1b9 Añade el capítulo 2: primeros comandos
* 8c4d2e7 Añade el capítulo 1: qué es Git
* 1a9f0c3 Añade el README del libro
```

La salida y el diagrama muestran justo lo que queríamos ver: `main` ha avanzado con el commit nuevo, pero la etiqueta, en ocre en el diagrama, se ha quedado en su commit:

```{.dot caption="La etiqueta v0.1.0 se queda fija cuando main avanza" alt="La etiqueta v0.1.0 apunta al commit Revert Reescribe el capítulo 2, y main y HEAD al commit siguiente"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c4 [label="7c1e5b8 Reescribe el capítulo 2"]; c5 [label="7bbac28 Revert \"Reescribe el capítulo 2\""]; c6 [label="852e4f5 Explica en el README cómo\ngenerar el libro"]
  e -> c4 -> c5 -> c6
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]; v010 [class=etiqueta label="v0.1.0"]
  { rank=same; c6 -> main -> HEAD [class=ref dir=back] }
  { rank=same; c5 -> v010 [class=ref dir=back] }
}
```

Ahí está la utilidad de las etiquetas. Imagina que alguien te pide el libro exactamente como estaba en la versión `v0.1.0`. Desde entonces el README ha cambiado, pero no hace falta buscar el commit en el historial ni recordar su identificador: basta con viajar a la etiqueta y generar el libro desde allí, pasando la versión al script:

```bash
git checkout tags/v0.1.0
./build.sh v0.1.0
```

En `dist` encontrarás ahora `manual-git-v0.1.0.docx` (y el PDF, si tienes Typst). Puede sorprender que los ficheros generados sigan ahí al cambiar de versión, pero tiene explicación: Git no toca los ficheros que no controla, como los de `dist/`, que además está en el `.gitignore`. Con el documento ya generado, volvemos al presente:

```bash
git checkout main
```

Las etiquetas que hemos creado así son _ligeras_: sólo un nombre que apunta a un commit. Git también admite etiquetas _anotadas_, que guardan además autor, fecha y un mensaje (`git tag -a v0.1.0 -m "Primer borrador"`). En el módulo 7 usaremos etiquetas anotadas para marcar cada versión del libro, y en el módulo 8 GitHub se servirá de ellas para publicarlas automáticamente.
