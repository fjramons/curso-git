# Módulo 5: GitHub y Trabajo Remoto

El libro vive solo en tu ordenador: si el disco falla, se pierde todo, y nadie más puede leerlo ni colaborar. En este módulo se sube a GitHub: se configura una conexión segura con SSH, se enlaza el repositorio local con uno remoto y se sincronizan cambios en las dos direcciones.

Si todavía no tienes cuenta en GitHub, créala en [github.com](https://github.com) con el mismo correo que configuraste en el apartado 1.4.

## 5.1 Autenticación segura mediante SSH

Para que GitHub sepa que eres tú quien sube cambios, se usan **claves SSH**. Una clave SSH es una pareja de ficheros:

- La **clave privada** se queda en tu ordenador y no se comparte nunca con nadie.
- La **clave pública** se sube a GitHub. Con ella, GitHub puede comprobar que quien se conecta tiene la clave privada correspondiente, sin que esta viaje por la red.

Así no tendrás que escribir usuario y contraseña cada vez que te conectes.

Primero, crea la pareja de claves. GitHub recomienda el algoritmo Ed25519, que genera claves más cortas y seguras:

```bash
# Creación de claves
ssh-keygen -t ed25519 -C "tuemail@dominio.com"
```

Ed25519 funciona en Linux, en macOS y en Windows con Git Bash. Solo algunos sistemas muy antiguos o equipos de empresa con restricciones de seguridad no lo admiten; en ese caso, crea en su lugar una clave RSA de 4096 bits:

```bash
ssh-keygen -t rsa -b 4096 -C "tuemail@dominio.com"
```

`ssh-keygen` te preguntará dónde guardar la clave: pulsa Intro para aceptar la ruta por defecto (`~/.ssh/id_ed25519`, o `~/.ssh/id_rsa` si usaste RSA). Después te pedirá una frase de contraseña (_passphrase_) que protege la clave privada por si alguien accede a tu ordenador. Es muy recomendable ponerla.

Para no tener que escribir la frase de contraseña en cada conexión, añade la clave al **agente SSH**, un programa que la mantiene desbloqueada durante la sesión. Arranca el agente y añádele la clave:

```bash
# Comprobación e inclusión en el agente
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

Si usaste RSA, la ruta es `~/.ssh/id_rsa`. En macOS puedes añadir `--apple-use-keychain` a `ssh-add` para que el llavero del sistema recuerde la frase de contraseña.

Ahora sube la clave pública a GitHub. Muestra su contenido y cópialo entero (empieza por `ssh-ed25519` o `ssh-rsa`):

```bash
cat ~/.ssh/id_ed25519.pub
```

Fíjate en que el fichero termina en `.pub`: es la clave pública. En GitHub, ve a tu foto de perfil → _Settings_ → _SSH and GPG keys_ → _New SSH key_, pon un título que identifique tu ordenador (por ejemplo, _Portátil personal_), pega la clave y pulsa _Add SSH key_.

Comprueba que la conexión funciona:

```bash
ssh -T git@github.com
```

La primera vez, SSH te preguntará si confías en el servidor `github.com`: escribe `yes`. Si todo está bien, verás:

```text
Hi tu-usuario! You've successfully authenticated, but GitHub does not provide shell access.
```

## 5.2 Conectar repositorio local con remoto y primer Push

En GitHub, pulsa el botón _+_ de la esquina superior derecha → _New repository_. Llámalo `manual-git`, elige si será público o privado y **no marques** ninguna opción para añadir README, `.gitignore` o licencia: todo eso ya existe en local y hace falta un repositorio remoto vacío. Pulsa _Create repository_.

GitHub muestra una página con instrucciones. Asegúrate de que está seleccionada la opción _SSH_ y copia la URL, que tiene esta forma: `git@github.com:tu-usuario/manual-git.git`.

Vuelve a la terminal, a tu repositorio, y añade el repositorio de GitHub como **remoto**. Un remoto es una copia del repositorio en otro sitio, identificada con un nombre corto. Por convención, el remoto principal se llama `origin`:

```bash
cd ~/proyectos/manual-git
git remote add origin <url_ssh_repositorio_github>
git remote -v
```

`git remote -v` muestra la URL de `origin` dos veces: una para descargar (_fetch_) y otra para subir (_push_). Sube ahora la rama `main`:

```bash
git push -u origin main
```

La opción `-u` (`--set-upstream`) enlaza la rama `main` local con `main` en `origin`, para que en el futuro Git sepa adónde subir y de dónde bajar sin tener que indicárselo. Recarga la página del repositorio en GitHub: ahí están el README, los capítulos y todo el historial.

`git push` no sube las etiquetas por defecto. Para subir la `v0.1.0` creada en el módulo 3:

```bash
git push --tags
```

A partir de ahora, cada vez que hagas commits nuevos en `main`, para subirlos basta con:

```bash
# Para siguientes subidas basta con:
git push
```

## 5.3 Sincronización de cambios desde remoto (Fetch y Pull)

Los cambios no siempre se hacen desde tu ordenador. Para comprobarlo, edita el libro directamente en GitHub: abre el `README.md` en la web, pulsa el icono del lápiz (_Edit this file_) y añade al final:

```markdown
Este libro se publica en GitHub.
```

Pulsa _Commit changes_, deja el mensaje propuesto y confirma. Ahora GitHub tiene un commit que tu repositorio local no conoce. Para averiguarlo sin modificar los ficheros locales se usa `git fetch`:

```bash
git fetch
git status
git tree
```

`git fetch` descarga los commits nuevos del remoto pero no toca la rama local. `git status` avisa de que `main` está _behind_ (por detrás) de `origin/main` en un commit, y `git tree` muestra `origin/main` un paso por delante de `main`. `origin/main` es una rama de seguimiento: la copia local de cómo estaba `main` en GitHub en la última sincronización. En los diagramas aparece en morado:

```{.dot caption="Después de git fetch, origin/main va un commit por delante de main" alt="origin/main apunta al commit Update README.md hecho en GitHub, y main y HEAD al commit anterior"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; m2 [label="Merge branch 'capitulo-historial'"]; w1 [label="Update README.md"]
  e -> m2 -> w1
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]; om [class=remota label="origin/main"]
  { rank=same; w1 -> om [class=ref dir=back] }
  { rank=same; m2 -> main -> HEAD [class=ref dir=back] }
}
```

Para incorporar esos cambios a la rama local se usa `git pull`, que es un `git fetch` seguido de un `git merge`:

```bash
git pull
```

El README local ya tiene la línea nueva y `main` ha avanzado hasta `origin/main`, como en un fast-forward. Todo ha ido bien porque en local no había cambios. El siguiente paso muestra qué pasa cuando los dos lados avanzan a la vez. Edita otra vez el `README.md` en GitHub y añade una línea más:

```markdown
Puedes leerlo en la carpeta `capitulos`.
```

Y, sin descargar ese cambio, añade en local una línea al final de `capitulos/03-ramas.md` y haz un commit:

```markdown
Las ramas son baratas: crear una solo cuesta unos pocos bytes.
```

```bash
git add -A
git commit -m "Amplía el capítulo 3"
git pull
```

Esta vez `git pull` falla con el mensaje _Need to specify how to reconcile divergent branches_: las dos ramas han divergido y Git quiere saber si debe unirlas con un merge o con un rebase (el rebase se explica en el módulo 7). La primera vez hay que elegir. Elige el comportamiento clásico, el merge:

```bash
# Configuración habitual si Git lo solicita la primera vez
git config pull.rebase false
git pull
```

Git crea un commit de fusión y abre el editor para que confirmes el mensaje. Es la misma situación que la del apartado 4.3, pero con `origin/main` en lugar de otra rama local:

```{.dot caption="git pull con historias divergentes crea un commit de fusión" alt="Antes, main tiene el commit Amplía el capítulo 3 y origin/main un segundo commit Update README.md, ambos hijos del primer Update README.md. Después, main apunta a un commit de fusión que une los dos"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  subgraph cluster_antes {
    label="Antes"
    a1 [label="Update README.md" group=a]; a2 [label="Amplía el capítulo 3" group=a]; a3 [label="Update README.md"]
    a1 -> a2; a1 -> a3
    node [shape=plaintext, group=""]
    main1 [class=rama label="main"]; head1 [class=head label="HEAD"]; om1 [class=remota label="origin/main"]
    { rank=same; head1 -> main1 -> a2 [class=ref dir=forward] }
    { rank=same; a3 -> om1 [class=ref dir=back] }
    { rank=same; a2 -> a3 [style=invis] }
  }
  subgraph cluster_despues {
    label="Después"
    d1 [label="Update README.md" group=d]; d2 [label="Amplía el capítulo 3" group=d]; d3 [label="Update README.md"]; d4 [label="Merge branch 'main' of\ngithub.com:tu-usuario/manual-git" group=d]
    d1 -> d2 -> d4; d1 -> d3 -> d4
    node [shape=plaintext, group=""]
    main2 [class=rama label="main"]; head2 [class=head label="HEAD"]; om2 [class=remota label="origin/main"]
    { rank=same; d4 -> main2 -> head2 [class=ref dir=back] }
    { rank=same; d3 -> om2 [class=ref dir=back] }
    { rank=same; d2 -> d3 [style=invis] }
  }
}
```

Si quieres aplicar esta preferencia a todos tus repositorios, añade `--global` al `git config`. Por último, sube el resultado, con lo que `origin/main` también pasa a apuntar al commit de fusión:

```bash
git push
```

## 5.4 Clonar repositorios remotos a local

Hasta ahora, el camino ha sido subir un repositorio que ya existía en local. El camino contrario es **clonar**: descargar un repositorio de GitHub completo, con todo su historial, y con el remoto `origin` ya configurado. Es lo que harás para trabajar en el libro desde otro ordenador, o para empezar a colaborar en un proyecto ajeno.

Para simular un segundo ordenador, clona el libro en otra carpeta. Desde la página del repositorio, pulsa el botón verde _Code_, elige _SSH_ y copia la URL:

```bash
cd ~/proyectos
git clone <url_ssh_repositorio> manual-git-portatil
cd manual-git-portatil
```

El último argumento de `git clone` es opcional: indica el nombre de la carpeta. Sin él, Git usaría el nombre del repositorio (`manual-git`), que ya existe. Comprueba que tienes el libro completo:

```bash
ls
git tree
```

Fíjate en que no hay carpeta `dist`: estaba en el `.gitignore`, así que nunca se subió. Cualquiera que clone el repositorio puede generar el libro con `./build.sh`. Haz un cambio desde el "portátil": añade una línea al final de `capitulos/04-historial.md` y súbela:

```markdown
Con `git reflog` se pueden recuperar commits que ya no aparecen en el historial.
```

```bash
git add -A
git commit -m "Amplía el capítulo 4 con reflog"
git push
```

Vuelve al "ordenador principal" y descarga el cambio:

```bash
cd ~/proyectos/manual-git
git pull
```

Ya tienes las dos copias sincronizadas a través de GitHub:

```{.dot caption="Dos copias locales sincronizadas a través de GitHub" alt="manual-git-portatil sube los cambios a GitHub con git push, y manual-git los descarga con git pull"}
digraph {
  rankdir=LR
  port [class=repo label="manual-git-portatil"]
  gh [class=repo label="GitHub: manual-git"]
  pc [class=repo label="manual-git"]
  port -> gh [class=accion label="  git push  "]
  gh -> pc [class=accion label="  git pull  "]
}
```

Ninguna copia local habla directamente con la otra: cada una se sincroniza con GitHub. Puedes borrar la carpeta `manual-git-portatil` cuando quieras: el libro está a salvo en GitHub y en tu carpeta principal.
