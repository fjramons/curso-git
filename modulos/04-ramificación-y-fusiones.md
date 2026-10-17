# Módulo 4: Ramificación (branches) y fusiones

Hasta ahora, nuestro trabajo ha avanzado en línea recta, con todos los commits en la rama `main`. Las **ramas** permiten abrir líneas de trabajo paralelas, ya sea para escribir un capítulo nuevo sin tocar la versión estable del libro, para probar ideas o para que trabajen varias personas a la vez. En este módulo vamos a escribir capítulos en ramas y a fusionarlas, a resolver nuestro primer conflicto y a aparcar trabajo a medias cuando surja algo urgente.

Las ramas se entienden mucho mejor viéndolas moverse. Si quieres practicar más allá del libro, [Learn Git Branching](https://learngitbranching.js.org/?locale=es_ES) propone ejercicios interactivos en español que dibujan el historial a cada comando que escribes, desde los primeros commits hasta el rebase del módulo 7.

## 4.1 Creación y movimiento entre ramas

Una rama no es más que un puntero con nombre a un commit, que avanza cada vez que se hace un commit en ella, y `main` es una rama como cualquier otra. Para verlo con nuestro libro, vamos a escribir el capítulo 3, dedicado precisamente a las ramas, en una rama propia. Empezamos por crearla:

```bash
git branch capitulo-ramas
git tree
```

```text
* 852e4f5 (HEAD -> main, capitulo-ramas) Explica en el README cómo generar el libro
* 7bbac28 (tag: v0.1.0) Revert "Reescribe el capítulo 2"
...
```

Las dos ramas apuntan al mismo commit, pero la rama actual sigue siendo `main` (`HEAD -> main`), porque crear una rama no implica cambiar a ella. Recuerda que tus identificadores serán distintos de los del ejemplo. Si ejecutas `git branch` sin argumentos, verás además la lista de ramas, con un asterisco en la actual:

```{.dot caption="Rama recién creada: dos ramas en el mismo commit" alt="main y capitulo-ramas apuntan al mismo commit, y HEAD apunta a main"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c5 [label="7bbac28 Revert \"Reescribe el capítulo 2\""]; c6 [label="852e4f5 Explica en el README cómo\ngenerar el libro"]
  e -> c5 -> c6
  node [shape=plaintext, group=""]
  main [class=rama]; cr [class=rama label="capitulo-ramas"]; HEAD [class=head]; v010 [class=etiqueta label="v0.1.0"]
  { rank=same; c6 -> main -> HEAD [class=ref dir=back] }
  { rank=same; cr -> c6 [class=ref dir=forward] }
  { rank=same; c5 -> v010 [class=ref dir=back] }
}
```

Para trabajar en la rama nueva tenemos que cambiar a ella, y para eso se usa `git switch`:

```bash
git switch capitulo-ramas
```

Ya en `capitulo-ramas`, crea `capitulos/03-ramas.md` con este contenido:

```markdown
# Ramas

Una rama es una línea de trabajo independiente. Permite desarrollar cambios sin afectar a la rama principal, `main`, hasta que estén terminados.

- `git branch <nombre>` crea una rama.
- `git switch <nombre>` cambia a esa rama.
- `git merge <nombre>` fusiona esa rama con la actual.
```

Y guárdalo con un commit en la rama nueva:

```bash
git add -A
git commit -m "Añade el capítulo 3: ramas"
```

Lo normal es que una rama reúna varios commits antes de darse por terminada, así que vamos a seguir escribiendo en ella. Añade al final de la lista del capítulo una línea más:

```markdown
- `git branch` muestra las ramas, con un asterisco en la actual.
```

Y guárdala en un segundo commit, también en la rama:

```bash
git add -A
git commit -m "Añade al capítulo 3 cómo listar las ramas"
git tree
```

```text
* cf013da (HEAD -> capitulo-ramas) Añade al capítulo 3 cómo listar las ramas
* 3b59d7e Añade el capítulo 3: ramas
* 852e4f5 (main) Explica en el README cómo generar el libro
* 7bbac28 (tag: v0.1.0) Revert "Reescribe el capítulo 2"
...
```

En la salida se ve que `capitulo-ramas` está dos commits por delante de `main`. Esto ocurre porque, al hacer un commit, sólo avanza la rama actual (la que señala `HEAD`), mientras que las demás se quedan donde estaban. Como la historia sigue siendo una línea recta, `git tree` todavía dibuja todos los commits en una sola columna; en el diagrama, en cambio, colocamos los de la rama a la derecha para que se vea la línea de trabajo que sale de `main`:

```{.dot caption="capitulo-ramas avanza con sus commits y main se queda atrás" alt="Del commit del README, donde está main, sale una línea a la derecha con los dos commits del capítulo 3. capitulo-ramas y HEAD apuntan al último"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; c5 [label="7bbac28 Revert \"Reescribe el capítulo 2\"" group=main]; c6 [label="852e4f5 Explica en el README cómo\ngenerar el libro" group=main]; c7 [label="3b59d7e Añade el capítulo 3: ramas" group=ramas]; c8 [label="cf013da Añade al capítulo 3 cómo\nlistar las ramas" group=ramas]
  e -> c5 -> c6
  c6 -> c7 -> c8
  hueco1 [style=invis group=main label="852e4f5 Explica en el README cómo\ngenerar el libro"]; hueco2 [style=invis group=main label="852e4f5 Explica en el README cómo\ngenerar el libro"]
  c6 -> hueco1 -> hueco2 [style=invis]
  node [shape=plaintext, group=""]
  main [class=rama]; cr [class=rama label="capitulo-ramas"]; HEAD [class=head]; v010 [class=etiqueta label="v0.1.0"]
  { rank=same; hueco1 -> c7 [style=invis] }
  { rank=same; c8 -> cr -> HEAD [class=ref dir=back] }
  { rank=same; c6 -> main [class=ref dir=back] }
  { rank=same; c5 -> v010 [class=ref dir=back] }
}
```

Podemos comprobar que las ramas son de verdad independientes volviendo a `main` y mirando qué capítulos hay:

```bash
git switch main
ls capitulos
```

El capítulo 3 no está, porque sólo existe en su rama. Sin embargo, `main` no tiene por qué quedarse quieta mientras tanto: el libro sigue vivo y podemos seguir mejorándolo en ella. Supongamos que, mientras el capítulo 3 se escribe en su rama, nos damos cuenta de que al capítulo 2 le falta `git diff`. Añade este párrafo al final de `capitulos/02-primeros-comandos.md`, separado del anterior por una línea en blanco:

```markdown
Con `git diff` se ven los cambios que aún no se han guardado.
```

Y guárdalo con un commit, esta vez en `main`:

```bash
git add -A
git commit -m "Añade git diff al capítulo 2"
git tree
```

```text
* 112a731 (HEAD -> main) Añade git diff al capítulo 2
| * cf013da (capitulo-ramas) Añade al capítulo 3 cómo listar las ramas
| * 3b59d7e Añade el capítulo 3: ramas
|/
* 852e4f5 Explica en el README cómo generar el libro
* 7bbac28 (tag: v0.1.0) Revert "Reescribe el capítulo 2"
...
```

Ahora sí, `git tree` dibuja dos líneas que salen del mismo commit: a la izquierda, `main` con el commit del capítulo 2, y a la derecha, `capitulo-ramas` con los dos commits del capítulo 3. Cada rama tiene commits que la otra no tiene, y por eso se dice que las dos ramas han **divergido**. Cada una avanza por su cuenta, sin que lo que pasa en una afecte a la otra:

```{.dot caption="main y capitulo-ramas avanzan por separado" alt="Del commit del README salen dos líneas: a la izquierda, el commit del capítulo 2, con main y HEAD; a la derecha, los dos commits del capítulo 3, con capitulo-ramas"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; c5 [label="7bbac28 Revert \"Reescribe el capítulo 2\"" group=main]; c6 [label="852e4f5 Explica en el README cómo\ngenerar el libro" group=main]; c9 [label="112a731 Añade git diff al capítulo 2" group=main]; c7 [label="3b59d7e Añade el capítulo 3: ramas" group=ramas]; c8 [label="cf013da Añade al capítulo 3 cómo\nlistar las ramas" group=ramas]
  e -> c5 -> c6 -> c9
  c6 -> c7 -> c8
  node [shape=plaintext, group=""]
  main [class=rama]; cr [class=rama label="capitulo-ramas"]; HEAD [class=head]; v010 [class=etiqueta label="v0.1.0"]
  { rank=same; HEAD -> main -> c9 [class=ref dir=forward] }
  { rank=same; c9 -> c7 [style=invis] }
  { rank=same; c8 -> cr [class=ref dir=back] }
  { rank=same; c5 -> v010 [class=ref dir=back] }
}
```

Por cierto, un atajo muy común es `git switch -c <nombre>`, que crea la rama y cambia a ella en un solo paso. En documentación antigua verás también `git checkout <rama>` y `git checkout -b <rama>`, que hacen lo mismo.

## 4.2 Fusión de ramas (merge)

El capítulo 3 está terminado, así que toca incorporarlo al libro. Para fusionar dos ramas hay que situarse en la que recibe los cambios, en nuestro caso `main`, donde ya estamos, e indicar la rama que se quiere traer:

```bash
# Desde la rama principal (receptora)
git merge capitulo-ramas
```

Como las dos ramas han divergido, Git tiene que combinar sus cambios en un commit nuevo, así que abre el editor con un mensaje ya escrito, _Merge branch 'capitulo-ramas'_. Guarda y cierra el editor para aceptarlo, y verás esta salida:

```text
Merge made by the 'ort' strategy.
 capitulos/03-ramas.md | 8 ++++++++
 1 file changed, 8 insertions(+)
 create mode 100644 capitulos/03-ramas.md
```

La salida resume lo que ha llegado de la rama: el capítulo 3 completo, con lo que añadieron sus dos commits. Git no nos ha preguntado nada, porque cada rama había cambiado ficheros distintos, el capítulo 2 en `main` y el capítulo 3 en `capitulo-ramas`, y no había nada que decidir. Si ejecutas `ls capitulos`, verás los tres capítulos, y el capítulo 2 conserva el párrafo de `git diff`. Veamos ahora cómo ha quedado el historial:

```bash
git tree
```

```text
*   c1ecec8 (HEAD -> main) Merge branch 'capitulo-ramas'
|\
| * cf013da (capitulo-ramas) Añade al capítulo 3 cómo listar las ramas
| * 3b59d7e Añade el capítulo 3: ramas
* | 112a731 Añade git diff al capítulo 2
|/
* 852e4f5 Explica en el README cómo generar el libro
...
```

El commit nuevo es un **commit de fusión** (_merge commit_), y se distingue de los demás en que tiene dos padres: el último commit de `main` y el último de `capitulo-ramas`. Es el punto en el que las dos líneas de historia se vuelven a unir, como se ve en la salida y en el diagrama. `main` (y con ella `HEAD`) avanza hasta la fusión, mientras que `capitulo-ramas` se queda donde estaba:

```{.dot caption="El commit de fusión une main y capitulo-ramas" alt="El commit Merge branch capitulo-ramas tiene dos padres: el commit del capítulo 2 y el último del capítulo 3. main y HEAD apuntan a la fusión, y capitulo-ramas sigue en su último commit"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; c6 [label="852e4f5 Explica en el README cómo\ngenerar el libro" group=main]; c9 [label="112a731 Añade git diff al capítulo 2" group=main]; c7 [label="3b59d7e Añade el capítulo 3: ramas" group=ramas]; c8 [label="cf013da Añade al capítulo 3 cómo\nlistar las ramas" group=ramas]; m1 [label="c1ecec8 Merge branch 'capitulo-ramas'" group=main]
  e -> c6 -> c9 -> m1
  c6 -> c7 -> c8 -> m1
  node [shape=plaintext, group=""]
  main [class=rama]; cr [class=rama label="capitulo-ramas"]; HEAD [class=head]
  { rank=same; m1 -> main -> HEAD [class=ref dir=back] }
  { rank=same; c9 -> c7 [style=invis] }
  { rank=same; c8 -> cr [class=ref dir=back] }
}
```

No todas las fusiones crean un commit de fusión. Si hubiéramos fusionado la rama antes del commit del capítulo 2, con `main` todavía en el commit del README, como en el primer diagrama con los dos commits del capítulo 3, no habría habido nada que combinar, porque `main` no tenía ningún commit que la rama no tuviera. En ese caso, Git se limita a adelantar `main` hasta el último commit de la rama, sin crear ningún commit nuevo, y la salida de `git merge` dice _Fast-forward_ (avance rápido). Es lo que suele ocurrir cuando nadie ha tocado `main` mientras trabajábamos en una rama, y el historial queda en línea recta, como si los commits se hubieran hecho directamente en `main`.

En las dos fusiones, Git ha sabido mezclarlo todo sin ayuda. Falta ver qué ocurre cuando no puede, y eso es lo que haremos en el apartado siguiente.

## 4.3 Resolución de conflictos

Git sabe fusionar automáticamente cambios en ficheros distintos, como acabamos de ver, e incluso en partes distintas de un mismo fichero. Pero si dos ramas cambian las mismas líneas, Git no puede saber cuál es la buena y pide que alguien decida: es lo que se llama un **conflicto**. No hay comandos exclusivos para resolverlo: basta con editar el fichero en conflicto, guardarlo y finalizar el merge con `add` y `commit`.

Para ver un conflicto necesitamos dos ramas que cambien la misma línea de formas distintas, así que vamos a provocarlo: cambiaremos el título del libro en una rama nueva y, después, cambiaremos ese mismo título de otra manera en `main`. Además, la rama tendrá un segundo cambio que no choca con nada, para ver cómo Git separa lo que sabe fusionar de lo que no. Empezamos por la rama:

```bash
git switch -c cambio-titulo
```

En ella, edita `metadata.yaml` y cambia la línea del título por:

```yaml
title: Manual de Git para principiantes
```

Y guarda el cambio en un commit:

```bash
git add -A
git commit -m "Cambia el título del libro"
```

El título también aparece en la primera línea del `README.md`, así que lo cambiamos allí para que los dos coincidan:

```markdown
# Manual de Git para principiantes
```

Y lo guardamos en un segundo commit:

```bash
git add -A
git commit -m "Pone el título nuevo en el README"
```

Ahora volvemos a `main` para cambiar el título de `metadata.yaml` de otra forma:

```bash
git switch main
```

En `metadata.yaml`, cambia esta vez el título por:

```yaml
title: Manual práctico de Git
```

Y guárdalo también en un commit:

```bash
git add -A
git commit -m "Cambia el título a Manual práctico"
git tree
```

```text
* d75c28a (HEAD -> main) Cambia el título a Manual práctico
| * 0a7610b (cambio-titulo) Pone el título nuevo en el README
| * 4a61dfa Cambia el título del libro
|/
*   c1ecec8 Merge branch 'capitulo-ramas'
|\
| * cf013da (capitulo-ramas) Añade al capítulo 3 cómo listar las ramas
| * 3b59d7e Añade el capítulo 3: ramas
* | 112a731 Añade git diff al capítulo 2
...
```

Ya tenemos el escenario: las dos ramas han vuelto a divergir, como en el apartado anterior, pero esta vez el commit de `main` y el primero de `cambio-titulo` cambian la misma línea de `metadata.yaml`. El diagrama muestra la situación:

```{.dot caption="main y cambio-titulo han divergido" alt="De la fusión de capitulo-ramas salen dos líneas: a la izquierda, Cambia el título a Manual práctico, con main y HEAD; a la derecha, los dos commits de cambio-titulo"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; c9 [label="112a731 Añade git diff al capítulo 2" group=main]; c8 [label="cf013da Añade al capítulo 3 cómo\nlistar las ramas" group=ramas]; m1 [label="c1ecec8 Merge branch 'capitulo-ramas'" group=main]; t3 [label="d75c28a Cambia el título a Manual práctico" group=main]; t1 [label="4a61dfa Cambia el título del libro" group=titulo]; t2 [label="0a7610b Pone el título nuevo en el README" group=titulo]
  e -> c9 -> m1 -> t3
  e -> c8 -> m1
  m1 -> t1 -> t2
  node [shape=plaintext, group=""]
  main [class=rama]; ct [class=rama label="cambio-titulo"]; cr [class=rama label="capitulo-ramas"]; HEAD [class=head]
  { rank=same; HEAD -> main -> t3 [class=ref dir=forward] }
  { rank=same; t3 -> t1 [style=invis] }
  { rank=same; t2 -> ct [class=ref dir=back] }
  { rank=same; c9 -> c8 [style=invis] }
  { rank=same; c8 -> cr [class=ref dir=back] }
}
```

Lo que queremos ahora es integrar `cambio-titulo` en `main` y quedarnos con un único título. Veamos qué ocurre si intentamos fusionar la rama como en el apartado anterior:

```bash
git merge cambio-titulo
```

```text
Auto-merging metadata.yaml
CONFLICT (content): Merge conflict in metadata.yaml
Automatic merge failed; fix conflicts and then commit the result.
```

Git no sabe con qué título quedarse, así que el merge se queda a medias. Para ver en qué punto está, consultamos el estado:

```bash
git status
```

```text
On branch main
You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Changes to be committed:
        modified:   README.md

Unmerged paths:
  (use "git add <file>..." to mark resolution)
        both modified:   metadata.yaml
```

La salida separa los dos ficheros. `README.md` está en _Changes to be committed_: el cambio sólo venía de la rama, así que Git lo ha fusionado sin ayuda y lo ha dejado preparado para el commit. `metadata.yaml`, en cambio, está en _Unmerged paths_ como _both modified_, porque las dos ramas han cambiado la misma línea. Es decir, Git sólo nos pide ayuda con lo que no sabe mezclar. Si abres `metadata.yaml`, verás que ha marcado la zona en conflicto con las dos versiones:

```text
<<<<<<< HEAD
title: Manual práctico de Git
=======
title: Manual de Git para principiantes
>>>>>>> cambio-titulo
subtitle: Lo que aprendí en el curso de Git y GitHub
author: Tu Nombre
lang: es-ES
```

- Entre `<<<<<<< HEAD` y `=======` está la versión de la rama actual (`main`).
- Entre `=======` y `>>>>>>> cambio-titulo` está la versión de la rama que se está fusionando.

Resolver el conflicto consiste en dejar el fichero como queremos que quede y borrar las tres líneas de marcadores. Podemos quedarnos con la versión de la rama actual, con la de la rama que llega o con una mezcla de las dos. En este ejemplo nos quedamos con la de `cambio-titulo`, porque es el título que ya ha llegado al README con la fusión:

```yaml
title: Manual de Git para principiantes
subtitle: Lo que aprendí en el curso de Git y GitHub
```

Editores como VS Code muestran botones (_Accept Current_, _Accept Incoming_, _Accept Both_) que hacen esto por ti; en nuestro caso, el que corresponde es _Accept Incoming_. Cuando el fichero esté limpio, sólo queda marcarlo como resuelto añadiéndolo al staging y terminar el merge con un commit:

```bash
git add metadata.yaml
git commit
git tree
```

Como en el apartado anterior, `git commit` abre el editor con el mensaje _Merge branch 'cambio-titulo'_ ya escrito, así que basta con guardar y cerrar. Después, `git tree` muestra el resultado:

```text
*   cf02aa6 (HEAD -> main) Merge branch 'cambio-titulo'
|\
| * 0a7610b (cambio-titulo) Pone el título nuevo en el README
| * 4a61dfa Cambia el título del libro
* | d75c28a Cambia el título a Manual práctico
|/
*   c1ecec8 Merge branch 'capitulo-ramas'
|\
| * cf013da (capitulo-ramas) Añade al capítulo 3 cómo listar las ramas
| * 3b59d7e Añade el capítulo 3: ramas
* | 112a731 Añade git diff al capítulo 2
...
```

Las dos líneas de historia se unen en el nuevo commit de fusión, cuyos padres son el commit del título en `main` y el último de `cambio-titulo`. En el historial de `main`, el resultado tiene la misma forma que la fusión del apartado anterior; la diferencia es que esta vez hemos tenido que decidir nosotros una parte del contenido:

```{.dot caption="El commit de fusión une main y cambio-titulo después de resolver el conflicto" alt="El commit Merge branch cambio-titulo tiene dos padres: Cambia el título a Manual práctico y Pone el título nuevo en el README. main y HEAD apuntan a la fusión"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; c9 [label="112a731 Añade git diff al capítulo 2" group=main]; c8 [label="cf013da Añade al capítulo 3 cómo\nlistar las ramas" group=ramas]; m1 [label="c1ecec8 Merge branch 'capitulo-ramas'" group=main]; t3 [label="d75c28a Cambia el título a Manual práctico" group=main]; t1 [label="4a61dfa Cambia el título del libro" group=titulo]; t2 [label="0a7610b Pone el título nuevo en el README" group=titulo]; m2 [label="cf02aa6 Merge branch 'cambio-titulo'" group=main]
  e -> c9 -> m1 -> t3 -> m2
  e -> c8 -> m1
  m1 -> t1 -> t2 -> m2
  node [shape=plaintext, group=""]
  main [class=rama]; ct [class=rama label="cambio-titulo"]; cr [class=rama label="capitulo-ramas"]; HEAD [class=head]
  { rank=same; m2 -> main -> HEAD [class=ref dir=back] }
  { rank=same; t3 -> t1 [style=invis] }
  { rank=same; t2 -> ct [class=ref dir=back] }
  { rank=same; c9 -> c8 [style=invis] }
  { rank=same; c8 -> cr [class=ref dir=back] }
}
```

Si en mitad de un conflicto prefieres abandonar la fusión y volver a como estabas antes, puedes hacerlo con `git merge --abort`.

## 4.4 Guardado temporal de trabajo incompleto (stash)

Para este apartado vamos a reproducir una situación muy habitual: estamos a mitad de un trabajo y surge algo urgente en otra rama. El trabajo a medias será el capítulo 4, sobre el historial y los viajes en el tiempo, y la urgencia, una errata en el README. Empezamos el capítulo en su propia rama, con su título y un primer commit:

```bash
git switch -c capitulo-historial
echo "# Viajes en el tiempo" > capitulos/04-historial.md
git add -A
git commit -m "Empieza el capítulo 4: historial"
```

Seguimos escribiendo. Añade este párrafo al final de `capitulos/04-historial.md`, con una línea en blanco entre el título y el párrafo, pero esta vez no hagas commit:

```markdown
Con `git checkout <commit>` se puede visitar cualquier versión anterior del proyecto.
```

Ya tenemos el escenario: el párrafo nuevo es un cambio sin confirmar en la rama del capítulo. Supongamos que justo en este momento aparece una errata en el `README.md` de `main` que hay que corregir ya. El problema es que no conviene hacer un commit con el capítulo a medias, pero tampoco llevarnos esos cambios sin terminar a `main`. Lo que necesitamos es apartarlos un momento, y para eso existe el **stash**: un cajón donde aparcar los cambios no confirmados.

```bash
git stash
git status
```

`git status` dice que no hay nada que confirmar, porque los cambios están guardados en el stash y el directorio de trabajo ha quedado limpio. Si quieres, puedes ver lo que hay en el cajón:

```bash
git stash list
```

```text
stash@{0}: WIP on capitulo-historial: 7a2c9e1 Empieza el capítulo 4: historial
```

Con el capítulo a salvo, ya podemos atender la urgencia. Cambia a `main`, corrige la errata (por ejemplo, cambia _Libro escrito_ por _Libro práctico escrito_ en el `README.md`) y guarda la corrección:

```bash
git switch main
git add -A
git commit -m "Corrige el README"
```

Resuelta la errata, volvemos a la rama del capítulo y sacamos los cambios del cajón:

```bash
git switch capitulo-historial
git stash pop
```

`git stash pop` aplica los últimos cambios guardados y los quita del stash, de modo que el párrafo vuelve a estar donde lo dejamos. Ya podemos terminar el capítulo con su commit y fusionarlo en `main`:

```bash
git add -A
git commit -m "Termina el capítulo 4: historial"
git switch main
git merge capitulo-historial
```

Como `main` había avanzado con la corrección del README, esta vez no hay fast-forward: Git crea un commit de fusión y abre el editor para que confirmes su mensaje. Guarda y cierra el editor para terminar y consulta el historial:

```bash
git tree
```

```text
*   09f9e15 (HEAD -> main) Merge branch 'capitulo-historial'
|\
| * 89dcf4e (capitulo-historial) Termina el capítulo 4: historial
| * 7a2c9e1 Empieza el capítulo 4: historial
* | 8b182a8 Corrige el README
|/
*   cf02aa6 Merge branch 'cambio-titulo'
...
```

Fíjate en que el stash no deja rastro en el historial, donde sólo quedan los commits:

```{.dot caption="Fusión de capitulo-historial después de corregir el README en main" alt="De la fusión de cambio-titulo salen dos líneas: Corrige el README en main y los dos commits del capítulo 4 en capitulo-historial. Se unen en un commit de fusión, al que apunta main"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; m1 [label="cf02aa6 Merge branch 'cambio-titulo'" group=main]; r [label="8b182a8 Corrige el README" group=main]; h1 [label="7a2c9e1 Empieza el capítulo 4: historial" group=historial]; h2 [label="89dcf4e Termina el capítulo 4: historial" group=historial]; m2 [label="09f9e15 Merge branch 'capitulo-historial'" group=main]
  e -> m1 -> r -> m2
  m1 -> h1 -> h2 -> m2
  node [shape=plaintext, group=""]
  main [class=rama]; ch [class=rama label="capitulo-historial"]; HEAD [class=head]
  { rank=same; m2 -> main -> HEAD [class=ref dir=back] }
  { rank=same; h2 -> ch [class=ref dir=back] }
  { rank=same; r -> h1 [style=invis] }
}
```

A veces, sin embargo, se aparca algo que al final no hace falta. Para verlo, haz un cambio cualquiera en el `README.md`, guárdalo en el stash y descártalo:

```bash
git stash
git stash list
git stash drop
```

`git stash drop` elimina el último stash sin aplicarlo. Ten en cuenta, además, que por defecto `git stash` sólo guarda cambios en ficheros que Git ya controla; si también quieres guardar ficheros nuevos sin seguimiento, usa `git stash -u`.

## 4.5 Borrado de ramas finalizadas

Las ramas `capitulo-ramas`, `cambio-titulo` y `capitulo-historial` ya están fusionadas en `main`: su trabajo forma parte del libro y ya no las necesitamos. Las borramos para mantener el repositorio ordenado:

```bash
git branch -d capitulo-ramas
git branch -d cambio-titulo
git branch -d capitulo-historial
git tree
```

```text
*   09f9e15 (HEAD -> main) Merge branch 'capitulo-historial'
|\
| * 89dcf4e Termina el capítulo 4: historial
| * 7a2c9e1 Empieza el capítulo 4: historial
* | 8b182a8 Corrige el README
|/
*   cf02aa6 Merge branch 'cambio-titulo'
|\
| * 0a7610b Pone el título nuevo en el README
| * 4a61dfa Cambia el título del libro
* | d75c28a Cambia el título a Manual práctico
|/
*   c1ecec8 Merge branch 'capitulo-ramas'
|\
| * cf013da Añade al capítulo 3 cómo listar las ramas
| * 3b59d7e Añade el capítulo 3: ramas
* | 112a731 Añade git diff al capítulo 2
|/
* 852e4f5 Explica en el README cómo generar el libro
...
```

Borrar una rama no borra sus commits, que siguen en el historial de `main`: sólo desaparece el nombre de la rama, es decir, el puntero. Por seguridad, `git branch -d` se niega a borrar una rama cuyos cambios no se han fusionado; si de verdad quieres tirar ese trabajo, usa `git branch -D <nombre_rama>`.

Así queda el historial del módulo completo, ya sin las ramas:

```{.dot caption="Historial del módulo 4 después de borrar las ramas" alt="Historial del módulo: tres líneas de trabajo, la del capítulo 3, la del título y la del capítulo 4, salen de main y vuelven a ella en tres commits de fusión. Sólo quedan main y HEAD en el último commit"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; c6 [label="852e4f5 Explica en el README cómo\ngenerar el libro" group=main]; c9 [label="112a731 Añade git diff al capítulo 2" group=main]; c7 [label="3b59d7e Añade el capítulo 3: ramas" group=ramas]; c8 [label="cf013da Añade al capítulo 3 cómo\nlistar las ramas" group=ramas]; m1 [label="c1ecec8 Merge branch 'capitulo-ramas'" group=main]; t3 [label="d75c28a Cambia el título a Manual práctico" group=main]; t1 [label="4a61dfa Cambia el título del libro" group=titulo]; t2 [label="0a7610b Pone el título nuevo en el README" group=titulo]; m2 [label="cf02aa6 Merge branch 'cambio-titulo'" group=main]; r [label="8b182a8 Corrige el README" group=main]; h1 [label="7a2c9e1 Empieza el capítulo 4: historial" group=historial]; h2 [label="89dcf4e Termina el capítulo 4: historial" group=historial]; m3 [label="09f9e15 Merge branch 'capitulo-historial'" group=main]
  e -> c6 -> c9 -> m1 -> t3 -> m2 -> r -> m3
  c6 -> c7 -> c8 -> m1
  m1 -> t1 -> t2 -> m2
  m2 -> h1 -> h2 -> m3
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]
  { rank=same; m3 -> main -> HEAD [class=ref dir=back] }
  { rank=same; c9 -> c7 [style=invis] }
  { rank=same; t3 -> t1 [style=invis] }
  { rank=same; r -> h1 [style=invis] }
}
```

Nuestro libro ya tiene cuatro capítulos, pero sigue viviendo sólo en tu ordenador. En el siguiente módulo lo subiremos a GitHub.
