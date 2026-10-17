# Módulo 4: Ramificación (branches) y fusiones

Hasta ahora, nuestro trabajo ha avanzado en línea recta, con todos los commits en la rama `main`. Las **ramas** permiten abrir líneas de trabajo paralelas, ya sea para escribir un capítulo nuevo sin tocar la versión estable del libro, para probar ideas o para que trabajen varias personas a la vez. En este módulo vamos a escribir capítulos en ramas y a fusionarlas, a resolver nuestro primer conflicto y a aparcar trabajo a medias cuando surja algo urgente.

Las ramas se entienden mucho mejor viéndolas moverse. Si quieres practicar más allá del libro, [Learn Git Branching](https://learngitbranching.js.org/?locale=es_ES) propone ejercicios interactivos en español que dibujan el historial a cada comando que escribes, desde los primeros commits hasta el rebase del módulo 7.

## 4.1 Creación y movimiento entre ramas

Una rama no es más que un puntero con nombre a un commit, que avanza cada vez que se hace un commit en ella, y `main` es una rama como cualquier otra. Para verlo con nuestro libro, vamos a escribir el capítulo 3, dedicado precisamente a las ramas, en una rama propia. Empezamos por crearla:

```bash
git branch capitulo-ramas
```

Si ejecutas `git branch` sin argumentos, verás la lista de ramas con un asterisco en la actual. Las dos ramas apuntan al mismo commit, pero la rama actual sigue siendo `main`, porque crear una rama no implica cambiar a ella:

```{.dot caption="Rama recién creada: dos ramas en el mismo commit" alt="main y capitulo-ramas apuntan al mismo commit, y HEAD apunta a main"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c5 [label="Revert \"Reescribe el capítulo 2\""]; c6 [label="Explica en el README cómo\ngenerar el libro"]
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
git tree
```

En `git tree` verás que `capitulo-ramas` está un commit por delante de `main`. Esto ocurre porque, al hacer un commit, sólo avanza la rama actual (la que señala `HEAD`), mientras que las demás se quedan donde estaban:

```{.dot caption="capitulo-ramas avanza con el commit y main se queda atrás" alt="capitulo-ramas apunta al commit del capítulo 3, HEAD apunta a capitulo-ramas y main apunta al commit anterior"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c5 [label="Revert \"Reescribe el capítulo 2\""]; c6 [label="Explica en el README cómo\ngenerar el libro"]; c7 [label="Añade el capítulo 3: ramas"]
  e -> c5 -> c6 -> c7
  node [shape=plaintext, group=""]
  main [class=rama]; cr [class=rama label="capitulo-ramas"]; HEAD [class=head]; v010 [class=etiqueta label="v0.1.0"]
  { rank=same; c7 -> cr -> HEAD [class=ref dir=back] }
  { rank=same; c6 -> main [class=ref dir=back] }
  { rank=same; c5 -> v010 [class=ref dir=back] }
}
```

Podemos comprobar que las ramas son de verdad independientes volviendo a `main` y mirando qué capítulos hay:

```bash
git switch main
ls capitulos
```

El capítulo 3 no está, porque sólo existe en su rama. Por cierto, un atajo muy común es `git switch -c <nombre>`, que crea la rama y cambia a ella en un solo paso. En documentación antigua verás también `git checkout <rama>` y `git checkout -b <rama>`, que hacen lo mismo.

## 4.2 Fusión de ramas (merge)

El capítulo 3 está terminado, así que toca incorporarlo al libro. Para fusionar dos ramas hay que situarse en la que recibe los cambios, en nuestro caso `main`, e indicar la rama que se quiere traer:

```bash
# Desde la rama principal (receptora)
git merge capitulo-ramas
```

La salida dice _Fast-forward_, y tiene una explicación sencilla: como `main` no había avanzado desde que se creó la rama, Git no necesita mezclar nada ni crear ningún commit, así que simplemente adelanta `main` hasta el último commit de `capitulo-ramas`. Si ahora ejecutas `ls capitulos`, verás los tres capítulos. Comparado con el último diagrama del apartado anterior, la única diferencia es que `main` (y con ella `HEAD`) ha subido hasta el commit del capítulo 3, donde ya estaba `capitulo-ramas`:

```{.dot caption="Después de la fusión fast-forward, main alcanza a capitulo-ramas" alt="main, HEAD y capitulo-ramas apuntan al commit del capítulo 3. La etiqueta v0.1.0 sigue en el commit Revert"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c5 [label="Revert \"Reescribe el capítulo 2\""]; c6 [label="Explica en el README cómo\ngenerar el libro"]; c7 [label="Añade el capítulo 3: ramas"]
  e -> c5 -> c6 -> c7
  node [shape=plaintext, group=""]
  r [class=refs label="HEAD -> main, capitulo-ramas"]; v010 [class=etiqueta label="v0.1.0"]
  { rank=same; c7 -> r [class=ref dir=back] }
  { rank=same; c5 -> v010 [class=ref dir=back] }
}
```

Si las dos ramas hubieran avanzado por separado, en cambio, Git crearía un **commit de fusión** (_merge commit_) con dos padres, que une ambas historias. Veremos ese caso en el apartado siguiente.

## 4.3 Resolución de conflictos

Git sabe fusionar automáticamente cambios en ficheros distintos, e incluso en partes distintas de un mismo fichero. Pero si dos ramas cambian las mismas líneas, Git no puede saber cuál es la buena y pide que alguien decida: es lo que se llama un **conflicto**. No hay comandos exclusivos para resolverlo: basta con editar el fichero en conflicto, guardarlo y finalizar el merge con `add` y `commit`.

Para ver un conflicto necesitamos dos ramas que cambien la misma línea de formas distintas, así que vamos a provocarlo: cambiaremos el título del libro en una rama nueva y, después, cambiaremos ese mismo título de otra manera en `main`. Empezamos por la rama:

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

Ahora volvemos a `main` para cambiar esa misma línea de otra forma:

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
```

Ya tenemos el escenario: las dos ramas han divergido, porque cada una tiene un commit que la otra no tiene, y los dos commits cambian la misma línea. El diagrama muestra la situación:

```{.dot caption="main y cambio-titulo han divergido" alt="Del commit del capítulo 3 salen dos commits que cambian el título: uno en main y otro en cambio-titulo"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c7 [label="Añade el capítulo 3: ramas" group=main]; t2 [label="Cambia el título a Manual práctico" group=main]; t1 [label="Cambia el título del libro"]
  e -> c7 -> t2
  c7 -> t1
  node [shape=plaintext, group=""]
  main [class=rama]; ct [class=rama label="cambio-titulo"]; cr [class=rama label="capitulo-ramas"]; HEAD [class=head]
  { rank=same; HEAD -> main -> t2 [class=ref dir=forward] }
  { rank=same; t2 -> t1 [style=invis] }
  { rank=same; t1 -> ct [class=ref dir=back] }
  { rank=same; c7 -> cr [class=ref dir=back] }
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

Git no sabe con qué título quedarse, así que el merge se queda a medias y `git status` muestra `metadata.yaml` en _both modified_. Si abres el fichero, verás que Git ha marcado la zona en conflicto con las dos versiones:

```text
<<<<<<< HEAD
title: Manual práctico de Git
=======
title: Manual de Git para principiantes
>>>>>>> cambio-titulo
subtitle: Lo que aprendí en el curso de Git y GitHub
```

- Entre `<<<<<<< HEAD` y `=======` está la versión de la rama actual (`main`).
- Entre `=======` y `>>>>>>> cambio-titulo` está la versión de la rama que se está fusionando.

Resolver el conflicto consiste en dejar el fichero como queremos que quede y borrar las tres líneas de marcadores. Podemos quedarnos con una versión, con la otra o con una mezcla de las dos; en este ejemplo, optamos por la mezcla:

```yaml
title: Manual práctico de Git para principiantes
subtitle: Lo que aprendí en el curso de Git y GitHub
```

Editores como VS Code muestran botones (_Accept Current_, _Accept Incoming_, _Accept Both_) que hacen esto por ti. Cuando el fichero esté limpio, sólo queda marcarlo como resuelto añadiéndolo al staging y terminar el merge con un commit:

```bash
git add metadata.yaml
git commit -m "Resolución de conflicto durante merge"
git tree
```

Ahora `git tree` muestra las dos líneas de historia uniéndose en el commit de fusión. A diferencia de los demás, este commit tiene dos padres: el último commit de `main` y el de `cambio-titulo`.

```{.dot caption="El commit de fusión une las dos líneas de historia" alt="El commit de resolución del conflicto tiene dos padres, los dos commits que cambian el título. main apunta a él"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c7 [label="Añade el capítulo 3: ramas" group=main]; t2 [label="Cambia el título a Manual práctico" group=main]; t1 [label="Cambia el título del libro"]; m [label="Resolución de conflicto\ndurante merge" group=main]
  e -> c7 -> t2 -> m
  c7 -> t1 -> m
  node [shape=plaintext, group=""]
  main [class=rama]; ct [class=rama label="cambio-titulo"]; cr [class=rama label="capitulo-ramas"]; HEAD [class=head]
  { rank=same; m -> main -> HEAD [class=ref dir=back] }
  { rank=same; t2 -> t1 [style=invis] }
  { rank=same; t1 -> ct [class=ref dir=back] }
  { rank=same; c7 -> cr [class=ref dir=back] }
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

Como `main` había avanzado con la corrección del README, esta vez no hay fast-forward: Git crea un commit de fusión y abre el editor para que confirmes su mensaje. Guarda y cierra el editor para terminar. Fíjate en que el stash no deja rastro en el historial, donde sólo quedan los commits:

```{.dot caption="Fusión de capitulo-historial después de corregir el README en main" alt="Del commit de resolución del conflicto salen dos líneas: Corrige el README en main y los dos commits del capítulo 4 en capitulo-historial. Se unen en un commit de fusión, al que apunta main"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; m1 [label="Resolución de conflicto\ndurante merge" group=main]; r [label="Corrige el README" group=main]; h1 [label="7a2c9e1 Empieza el capítulo 4: historial"]; h2 [label="Termina el capítulo 4: historial"]; m2 [label="Merge branch 'capitulo-historial'" group=main]
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

Borrar una rama no borra sus commits, que siguen en el historial de `main`: sólo desaparece el nombre de la rama, es decir, el puntero. Por seguridad, `git branch -d` se niega a borrar una rama cuyos cambios no se han fusionado; si de verdad quieres tirar ese trabajo, usa `git branch -D <nombre_rama>`.

Así queda el historial del módulo completo, ya sin las ramas:

```{.dot caption="Historial del módulo 4 después de borrar las ramas" alt="Historial con el capítulo 3, las dos fusiones y los commits de las ramas borradas. Sólo quedan main y HEAD en el último commit"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c6 [label="Explica en el README cómo\ngenerar el libro" group=main]; c7 [label="Añade el capítulo 3: ramas" group=main]; t2 [label="Cambia el título a Manual práctico" group=main]; t1 [label="Cambia el título del libro"]; m1 [label="Resolución de conflicto\ndurante merge" group=main]; r [label="Corrige el README" group=main]; h1 [label="Empieza el capítulo 4: historial"]; h2 [label="Termina el capítulo 4: historial"]; m2 [label="Merge branch 'capitulo-historial'" group=main]
  e -> c6 -> c7 -> t2 -> m1 -> r -> m2
  c7 -> t1 -> m1
  m1 -> h1 -> h2 -> m2
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]
  { rank=same; m2 -> main -> HEAD [class=ref dir=back] }
  { rank=same; t2 -> t1 [style=invis] }
  { rank=same; r -> h1 [style=invis] }
}
```

Nuestro libro ya tiene cuatro capítulos, pero sigue viviendo sólo en tu ordenador. En el siguiente módulo lo subiremos a GitHub.
