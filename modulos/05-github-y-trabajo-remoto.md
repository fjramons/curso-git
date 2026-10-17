# Módulo 5: GitHub y trabajo remoto

Hasta ahora, nuestro libro vive sólo en tu ordenador: si el disco falla, se pierde todo, y nadie más puede leerlo ni colaborar en él. En este módulo vamos a subirlo a GitHub. Para ello configuraremos primero una conexión segura con SSH, después enlazaremos el repositorio local con uno remoto y, por último, aprenderemos a sincronizar los cambios en las dos direcciones.

Si todavía no tienes cuenta en GitHub, créala en [github.com](https://github.com) con el mismo correo que configuraste en el apartado 1.4.

## 5.1 Autenticación segura mediante SSH

Para que GitHub sepa que eres tú quien sube los cambios, se usan **claves SSH**. Una clave SSH es una pareja de ficheros:

- La **clave privada** se queda en tu ordenador y no se comparte nunca con nadie.
- La **clave pública** se sube a GitHub. Con ella, GitHub puede comprobar que quien se conecta tiene la clave privada correspondiente, sin que esta viaje por la red.

Gracias a este mecanismo no tendrás que escribir usuario y contraseña cada vez que te conectes. El proceso tiene cuatro pasos: crear la pareja de claves, añadirla al agente SSH, subir la clave pública a GitHub y comprobar la conexión.

Empezamos por crear la pareja de claves. GitHub recomienda el algoritmo Ed25519, que genera claves más cortas y seguras:

```bash
# Creación de claves
ssh-keygen -t ed25519 -C "tuemail@dominio.com"
```

Ed25519 funciona en Linux, en macOS y en Windows con Git Bash. Sólo algunos sistemas muy antiguos o equipos de empresa con restricciones de seguridad no lo admiten; en ese caso, crea en su lugar una clave RSA de 4096 bits:

```bash
ssh-keygen -t rsa -b 4096 -C "tuemail@dominio.com"
```

`ssh-keygen` te preguntará dónde guardar la clave: pulsa Intro para aceptar la ruta por defecto (`~/.ssh/id_ed25519`, o `~/.ssh/id_rsa` si usaste RSA). Después te pedirá una frase de contraseña (_passphrase_), que protege la clave privada por si alguien accede a tu ordenador. Es muy recomendable ponerla.

Ahora bien, escribir esa frase en cada conexión resultaría pesado. Para evitarlo, añadimos la clave al **agente SSH**, un programa que la mantiene desbloqueada durante la sesión. Arrancamos el agente y le añadimos la clave:

```bash
# Arranque del agente e inclusión de la clave
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

Si usaste RSA, la ruta es `~/.ssh/id_rsa`. En macOS puedes añadir `--apple-use-keychain` a `ssh-add` para que el llavero del sistema recuerde la frase de contraseña.

El siguiente paso es subir la clave pública a GitHub. Para ello, muestra su contenido y cópialo entero (empieza por `ssh-ed25519` o `ssh-rsa`):

```bash
cat ~/.ssh/id_ed25519.pub
```

Fíjate en que el fichero termina en `.pub`, porque es la clave pública. En GitHub, ve a tu foto de perfil → _Settings_ → _SSH and GPG keys_ → _New SSH key_, pon un título que identifique tu ordenador (por ejemplo, _Portátil personal_), pega la clave y pulsa _Add SSH key_.

Sólo queda comprobar que la conexión funciona:

```bash
ssh -T git@github.com
```

La primera vez, SSH te preguntará si confías en el servidor `github.com`: escribe `yes`. Si todo está bien, verás:

```text
Hi tu-usuario! You've successfully authenticated, but GitHub does not provide shell access.
```

Si algún paso falla o usas un sistema con particularidades, la guía [Conectar a GitHub con SSH](https://docs.github.com/es/authentication/connecting-to-github-with-ssh) de la documentación de GitHub explica cada paso para Linux, macOS y Windows, y cómo resolver los errores más comunes.

## 5.2 Conectar el repositorio local con el remoto y primer push

Con la autenticación resuelta, necesitamos un repositorio en GitHub donde subir el libro. En GitHub, pulsa el botón _+_ de la esquina superior derecha → _New repository_. Llámalo `manual-git`, elige si será público o privado y **no marques** ninguna opción para añadir README, `.gitignore` o licencia: todo eso ya existe en local, y lo que necesitamos es un repositorio remoto vacío. Pulsa _Create repository_.

GitHub muestra entonces una página con instrucciones. Asegúrate de que está seleccionada la opción _SSH_ y copia la URL, que tiene esta forma: `git@github.com:tu-usuario/manual-git.git`.

Ahora volvemos a la terminal para decirle a nuestro repositorio dónde está su copia en GitHub, es decir, para añadirlo como **remoto**. Un remoto es una copia del repositorio en otro sitio, identificada con un nombre corto que, por convención, en el caso del remoto principal es `origin`:

```bash
cd ~/proyectos/manual-git
git remote add origin <url_ssh_repositorio_github>
git remote -v
```

`git remote -v` muestra la URL de `origin` dos veces: una para descargar (_fetch_) y otra para subir (_push_). Con el remoto configurado, ya podemos subir la rama `main`:

```bash
git push -u origin main
```

La opción `-u` (`--set-upstream`) enlaza la rama `main` local con `main` en `origin`, para que en el futuro Git sepa adónde subir y de dónde bajar sin tener que indicárselo. Si recargas la página del repositorio en GitHub, verás allí el README, los capítulos y todo el historial.

Falta un detalle: `git push` no sube las etiquetas por defecto, así que la `v0.1.0` que creamos en el módulo 3 se ha quedado en local. La subimos aparte:

```bash
git push --tags
```

A partir de ahora, cada vez que hagas commits nuevos en `main`, para subirlos bastará con:

```bash
git push
```

## 5.3 Sincronización de cambios desde el remoto (fetch y pull)

Los cambios no siempre se hacen desde tu ordenador: pueden venir de otra persona, de otro equipo o de la propia web de GitHub. Para ver cómo se traen a la copia local, vamos a crear un cambio que sólo exista en GitHub. Abre el `README.md` en la web, pulsa el icono del lápiz (_Edit this file_) y añade al final:

```markdown
Este libro se publica en GitHub.
```

Pulsa _Commit changes_, deja el mensaje propuesto y confirma. Ya tenemos el escenario: GitHub tiene un commit que nuestro repositorio local no conoce. Antes de traerlo, queremos averiguar qué ha cambiado sin modificar los ficheros locales, y para eso se usa `git fetch`:

```bash
git fetch
git status
git tree
```

La salida de `git tree` empieza así:

```text
* 71d265c (origin/main) Update README.md
*   09f9e15 (HEAD -> main) Merge branch 'capitulo-historial'
...
```

`git fetch` descarga los commits nuevos del remoto, pero no toca la rama local. Por eso `git status` avisa de que `main` está _behind_ (por detrás) de `origin/main` en un commit, y `git tree` muestra `origin/main` un paso por delante de `main`. `origin/main` es una rama de seguimiento, es decir, la copia local de cómo estaba `main` en GitHub en la última sincronización. En los diagramas aparece en morado:

```{.dot caption="Después de git fetch, origin/main va un commit por delante de main" alt="origin/main apunta al commit Update README.md hecho en GitHub, y main y HEAD al commit anterior"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; m2 [label="09f9e15 Merge branch 'capitulo-historial'"]; w1 [label="71d265c Update README.md"]
  e -> m2 -> w1
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]; om [class=remota label="origin/main"]
  { rank=same; w1 -> om [class=ref dir=back] }
  { rank=same; m2 -> main -> HEAD [class=ref dir=back] }
}
```

Una vez revisado, lo que queremos es incorporar ese commit a nuestra rama local. Para eso se usa `git pull`, que equivale a un `git fetch` seguido de un `git merge`:

```bash
git pull
```

El README local ya tiene la línea nueva y `main` ha avanzado hasta `origin/main`, como en un fast-forward. Todo ha ido bien porque en local no había cambios, pero en la práctica es frecuente que los dos lados avancen a la vez. Vamos a provocar esa situación: haremos un cambio en GitHub y, sin descargarlo, otro distinto en local. Empezamos por GitHub: edita otra vez el `README.md` en la web y añade una línea más:

```markdown
Puedes leerlo en la carpeta `capitulos`.
```

Sin descargar ese cambio, añade en local un párrafo al final de `capitulos/03-ramas.md`, separado de la lista por una línea en blanco (si no, Markdown lo une a la última viñeta):

```markdown
Las ramas son baratas: crear una sólo cuesta unos pocos bytes.
```

Ahora guardamos el cambio local en un commit e intentamos traer el de GitHub como antes:

```bash
git add -A
git commit -m "Amplía el capítulo 3"
git pull
```

Esta vez `git pull` falla con el mensaje _Need to specify how to reconcile divergent branches_. Ya tenemos el escenario que buscábamos: las dos ramas han divergido, porque cada una tiene un commit que la otra no tiene, y Git quiere saber si debe unirlas con un merge o con un rebase (el rebase se explica en el módulo 7). Para ver la situación, consultamos el historial:

```bash
git tree
```

```text
* 7f7f300 (HEAD -> main) Amplía el capítulo 3
| * 65f4e2c (origin/main) Update README.md
|/
* 71d265c Update README.md
...
```

`main` y `origin/main` salen del mismo commit, pero cada una tiene un commit propio, como muestra el diagrama:

```{.dot caption="main y origin/main han divergido" alt="Del primer commit Update README.md salen dos commits: Amplía el capítulo 3, con main y HEAD, y un segundo Update README.md, con origin/main"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=a]; a1 [label="71d265c Update README.md" group=a]; a2 [label="7f7f300 Amplía el capítulo 3" group=a]; a3 [label="65f4e2c Update README.md" group=remota]
  e -> a1 -> a2; a1 -> a3
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]; om [class=remota label="origin/main"]
  { rank=same; HEAD -> main -> a2 [class=ref dir=forward] }
  { rank=same; a3 -> om [class=ref dir=back] }
  { rank=same; a2 -> a3 [style=invis] }
}
```

La primera vez hay que elegir, y nosotros optaremos por el comportamiento clásico, el merge:

```bash
# Configuración habitual si Git lo solicita la primera vez
git config pull.rebase false
git pull
```

Git crea un commit de fusión y abre el editor para que confirmes el mensaje. Guarda y cierra el editor, y consulta de nuevo el historial:

```bash
git tree
```

```text
*   1fcd879 (HEAD -> main) Merge branch 'main' of github.com:tu-usuario/manual-git
|\
| * 65f4e2c (origin/main) Update README.md
* | 7f7f300 Amplía el capítulo 3
|/
* 71d265c Update README.md
...
```

Como se ve en la salida y en el diagrama, es la misma situación que la del apartado 4.2, sólo que con `origin/main` en lugar de otra rama local:

```{.dot caption="git pull crea un commit de fusión que une las dos historias" alt="Un commit de fusión une Amplía el capítulo 3 y el segundo Update README.md. main y HEAD apuntan a la fusión, y origin/main sigue en el segundo Update README.md"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=d]; d1 [label="71d265c Update README.md" group=d]; d2 [label="7f7f300 Amplía el capítulo 3" group=d]; d3 [label="65f4e2c Update README.md" group=remota]; d4 [label="1fcd879 Merge branch 'main' of\ngithub.com:tu-usuario/manual-git" group=d]
  e -> d1 -> d2 -> d4; d1 -> d3 -> d4
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]; om [class=remota label="origin/main"]
  { rank=same; d4 -> main -> HEAD [class=ref dir=back] }
  { rank=same; d3 -> om [class=ref dir=back] }
  { rank=same; d2 -> d3 [style=invis] }
}
```

Si quieres aplicar esta preferencia a todos tus repositorios, añade `--global` al `git config`. Por último, subimos el resultado, con lo que `origin/main` también pasa a apuntar al commit de fusión:

```bash
git push
```

## 5.4 Clonar un repositorio remoto en local

Hasta ahora hemos seguido el camino de subir un repositorio que ya existía en local. El camino contrario es **clonar**: descargar un repositorio de GitHub completo, con todo su historial y con el remoto `origin` ya configurado. Es lo que harás para trabajar en el libro desde otro ordenador o para empezar a colaborar en un proyecto ajeno.

Como seguramente no tienes un segundo ordenador a mano, vamos a simularlo clonando el libro en otra carpeta, que haremos pasar por un «portátil». Desde la página del repositorio, pulsa el botón verde _Code_, elige _SSH_ y copia la URL:

```bash
cd ~/proyectos
git clone <url_ssh_repositorio> manual-git-portatil
cd manual-git-portatil
```

El último argumento de `git clone` es opcional e indica el nombre de la carpeta. Sin él, Git usaría el nombre del repositorio (`manual-git`), que en nuestro caso ya existe. Comprobemos que tenemos el libro completo:

```bash
ls
git tree
```

Fíjate en que no hay carpeta `dist`: estaba en el `.gitignore`, así que nunca se subió, y cualquiera que clone el repositorio puede generar el libro con `./build.sh`. Para ver cómo viaja un cambio de una copia a otra, vamos a hacer uno desde el «portátil». Añade este párrafo al final de `capitulos/04-historial.md`:

```markdown
Con `git reflog` se pueden recuperar commits que ya no aparecen en el historial.
```

Y súbelo a GitHub con su commit:

```bash
git add -A
git commit -m "Amplía el capítulo 4 con reflog"
git push
```

El cambio ya está en GitHub, pero no en el «ordenador principal». Volvemos a él y lo descargamos:

```bash
cd ~/proyectos/manual-git
git pull
```

Con esto, las dos copias están sincronizadas a través de GitHub:

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

Como muestra el diagrama, ninguna copia local habla directamente con la otra: cada una se sincroniza con GitHub. Puedes borrar la carpeta `manual-git-portatil` cuando quieras, porque el libro está a salvo en GitHub y en tu carpeta principal.
