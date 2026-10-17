# Módulo 4: Ramificación (branches) y fusiones

Hasta ahora, el trabajo ha avanzado en línea recta, con todos los commits en la rama `main`. Las **ramas** permiten abrir líneas de trabajo paralelas: escribir un capítulo nuevo sin tocar la versión estable del libro, probar ideas o trabajar varias personas a la vez. En este módulo se escriben capítulos en ramas, se fusionan, se resuelve un conflicto y se aparca trabajo a medias.

## 4.1 Creación y movimiento entre ramas

Una rama no es más que un puntero con nombre a un commit, que avanza cada vez que haces un commit en ella. `main` es una rama como cualquier otra. El capítulo 3, dedicado precisamente a las ramas, se escribirá en una rama propia. Créala:

```bash
git branch capitulo-ramas
```

Si ejecutas `git branch` sin argumentos verás la lista de ramas, con un asterisco en la actual. Las dos ramas apuntan al mismo commit y la rama actual sigue siendo `main`, porque crear una rama no implica cambiar a ella:

```{.dot caption="Rama recién creada: dos ramas en el mismo commit" alt="main y capitulo-ramas apuntan al mismo commit, y HEAD apunta a main"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c5 [label="Añade el origen de Git al capítulo 1"]; c6 [label="Explica en el README cómo\ngenerar el libro"]
  e -> c5 -> c6
  node [shape=plaintext, group=""]
  main [class=rama]; cr [class=rama label="capitulo-ramas"]; HEAD [class=head]; v010 [class=etiqueta label="v0.1.0"]
  { rank=same; c6 -> main -> HEAD [class=ref dir=back] }
  { rank=same; cr -> c6 [class=ref dir=forward] }
  { rank=same; c5 -> v010 [class=ref dir=back] }
}
```

Para cambiar de rama se usa `git switch`:

```bash
git switch capitulo-ramas
```

Crea ahora `capitulos/03-ramas.md`:

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

En `git tree` verás que `capitulo-ramas` está un commit por delante de `main`. Al hacer el commit, la rama actual (la que señala `HEAD`) avanza hasta él y las demás se quedan donde estaban:

```{.dot caption="capitulo-ramas avanza con el commit y main se queda atrás" alt="capitulo-ramas apunta al commit del capítulo 3, HEAD apunta a capitulo-ramas y main apunta al commit anterior"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c5 [label="Añade el origen de Git al capítulo 1"]; c6 [label="Explica en el README cómo\ngenerar el libro"]; c7 [label="Añade el capítulo 3: ramas"]
  e -> c5 -> c6 -> c7
  node [shape=plaintext, group=""]
  main [class=rama]; cr [class=rama label="capitulo-ramas"]; HEAD [class=head]; v010 [class=etiqueta label="v0.1.0"]
  { rank=same; c7 -> cr -> HEAD [class=ref dir=back] }
  { rank=same; c6 -> main [class=ref dir=back] }
  { rank=same; c5 -> v010 [class=ref dir=back] }
}
```

Comprueba que las ramas son independientes volviendo a `main`:

```bash
git switch main
ls capitulos
```

El capítulo 3 no está: solo existe en su rama. Un atajo muy común es `git switch -c <nombre>`, que crea la rama y cambia a ella en un solo paso. En documentación antigua verás `git checkout <rama>` y `git checkout -b <rama>`, que hacen lo mismo.

## 4.2 Fusión de ramas (merge)

El capítulo 3 está terminado, así que toca incorporarlo al libro. Para fusionar, sitúate en la rama que recibe los cambios (`main`) e indica la rama que quieres traer:

```bash
# Desde la rama principal (receptora)
git merge capitulo-ramas
```

La salida dice _Fast-forward_. Como `main` no había avanzado desde la creación de la rama, Git no necesita mezclar nada ni crear ningún commit: simplemente adelanta `main` hasta el último commit de `capitulo-ramas`. Ahora `ls capitulos` muestra los tres capítulos.

```{.dot caption="Fusión fast-forward: main solo avanza" alt="Antes, main apunta al commit anterior al del capítulo 3. Después, main y capitulo-ramas apuntan al commit del capítulo 3"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  subgraph cluster_antes {
    label="Antes"
    a6 [label="Explica en el README cómo\ngenerar el libro"]; a7 [label="Añade el capítulo 3: ramas"]
    a6 -> a7
    node [shape=plaintext, group=""]
    main1 [class=rama label="main"]; cr1 [class=rama label="capitulo-ramas"]; head1 [class=head label="HEAD"]
    { rank=same; a7 -> cr1 [class=ref dir=back] }
    { rank=same; a6 -> main1 -> head1 [class=ref dir=back] }
  }
  subgraph cluster_despues {
    label="Después"
    d6 [label="Explica en el README cómo\ngenerar el libro"]; d7 [label="Añade el capítulo 3: ramas"]
    d6 -> d7
    node [shape=plaintext, group=""]
    main2 [class=rama label="main"]; cr2 [class=rama label="capitulo-ramas"]; head2 [class=head label="HEAD"]
    { rank=same; d7 -> main2 -> head2 [class=ref dir=back] }
    { rank=same; cr2 -> d7 [class=ref dir=forward] }
  }
}
```

Si las dos ramas hubieran avanzado por separado, Git crearía un **commit de fusión** (_merge commit_) con dos padres, que une ambas historias. El siguiente apartado muestra ese caso.

## 4.3 Resolución de conflictos

Git sabe fusionar automáticamente cambios en ficheros distintos, e incluso en partes distintas de un mismo fichero. Pero si dos ramas cambian las mismas líneas, Git no puede saber cuál es la buena y pide que alguien decida: es un **conflicto**. No hay comandos exclusivos para esto: se edita el fichero en conflicto, se guarda y se finaliza el merge con `add` y `commit`.

Para provocar uno, cambia el título del libro de dos formas distintas. Primero, en una rama nueva:

```bash
git switch -c cambio-titulo
```

Edita `metadata.yaml` y cambia la línea del título por:

```yaml
title: Manual de Git para principiantes
```

```bash
git add -A
git commit -m "Cambia el título del libro"
```

Vuelve ahora a `main` y cambia la misma línea de otra forma:

```bash
git switch main
```

```yaml
title: Manual práctico de Git
```

```bash
git add -A
git commit -m "Cambia el título a Manual práctico"
```

Ahora las dos ramas han divergido: cada una tiene un commit que la otra no tiene, y los dos cambian la misma línea.

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

Intenta fusionar la rama:

```bash
git merge cambio-titulo
```

```text
Auto-merging metadata.yaml
CONFLICT (content): Merge conflict in metadata.yaml
Automatic merge failed; fix conflicts and then commit the result.
```

El merge se queda a medias. `git status` muestra `metadata.yaml` en _both modified_. Abre el fichero: Git ha marcado la zona en conflicto con las dos versiones:

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

Para resolverlo, deja el fichero como quieres que quede y borra las tres líneas de marcadores. Puedes quedarte con una versión, con la otra o con una mezcla de las dos. En este ejemplo, la solución es una mezcla:

```yaml
title: Manual práctico de Git para principiantes
subtitle: Lo que aprendí en el curso de Git y GitHub
```

Editores como VS Code muestran botones (_Accept Current_, _Accept Incoming_, _Accept Both_) que hacen esto por ti. Cuando el fichero esté limpio, márcalo como resuelto añadiéndolo al staging y termina el merge con un commit:

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

Si en mitad de un conflicto prefieres abandonar la fusión y volver a como estabas antes, usa `git merge --abort`.

## 4.4 Guardado temporal de trabajo incompleto (stash)

Toca escribir el capítulo 4, sobre el historial y los viajes en el tiempo. Crea una rama, empieza el capítulo con su título y haz un primer commit:

```bash
git switch -c capitulo-historial
echo "# Viajes en el tiempo" > capitulos/04-historial.md
git add -A
git commit -m "Empieza el capítulo 4: historial"
```

Sigue escribiendo y añade este párrafo al final de `capitulos/04-historial.md`, con una línea en blanco entre el título y el párrafo:

```markdown
Con `git checkout <commit>` se puede visitar cualquier versión anterior del proyecto.
```

A mitad del trabajo aparece una errata en el `README.md` de `main` que hay que corregir ya. No conviene hacer un commit con el capítulo a medias, pero tampoco llevar esos cambios sin terminar a `main`. Para eso existe el **stash**: un cajón donde aparcar los cambios no confirmados.

```bash
git stash
git status
```

`git status` dice que no hay nada que confirmar: los cambios están guardados en el stash y el directorio de trabajo está limpio. Puedes ver lo que hay en el cajón:

```bash
git stash list
```

```text
stash@{0}: WIP on capitulo-historial: 7a2c9e1 Empieza el capítulo 4: historial
```

Cambia ahora a `main`, corrige la errata (por ejemplo, cambia _Libro escrito_ por _Libro práctico escrito_ en el `README.md`) y guárdala:

```bash
git switch main
git add -A
git commit -m "Corrige el README"
```

Vuelve a la rama del capítulo y saca los cambios del cajón:

```bash
git switch capitulo-historial
git stash pop
```

`git stash pop` aplica los últimos cambios guardados y los quita del stash. Termina el capítulo, haz el commit y fusiónalo en `main`:

```bash
git add -A
git commit -m "Termina el capítulo 4: historial"
git switch main
git merge capitulo-historial
```

Como `main` había avanzado con la corrección del README, esta vez Git crea un commit de fusión y abre el editor para que confirmes su mensaje. Guarda y cierra el editor para terminar. El stash no deja rastro en el historial: solo quedan los commits.

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

A veces se aparca algo que al final no hace falta. Haz un cambio cualquiera en el `README.md`, guárdalo en el stash y descártalo:

```bash
git stash
git stash list
git stash drop
```

`git stash drop` elimina el último stash sin aplicarlo. Ten en cuenta que, por defecto, `git stash` solo guarda cambios en ficheros que Git ya controla. Si también quieres guardar ficheros nuevos sin seguimiento, usa `git stash -u`.

## 4.5 Borrado de ramas finalizadas

Las ramas `capitulo-ramas`, `cambio-titulo` y `capitulo-historial` ya están fusionadas en `main`: su trabajo forma parte del libro y ya no hacen falta. Bórralas para mantener el repositorio ordenado:

```bash
git branch -d capitulo-ramas
git branch -d cambio-titulo
git branch -d capitulo-historial
git tree
```

Borrar una rama no borra sus commits: siguen en el historial de `main`. Solo desaparece el nombre de la rama, el puntero. Por seguridad, `git branch -d` se niega a borrar una rama cuyos cambios no se han fusionado. Si de verdad quieres tirar ese trabajo, usa `git branch -D <nombre_rama>`.

Este es el historial del módulo completo, ya sin las ramas:

```{.dot caption="Historial del módulo 4 después de borrar las ramas" alt="Historial con el capítulo 3, las dos fusiones y los commits de las ramas borradas. Solo quedan main y HEAD en el último commit"}
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

El libro ya tiene cuatro capítulos. En el siguiente módulo se sube a GitHub.
