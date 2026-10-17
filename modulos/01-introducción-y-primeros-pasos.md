# Módulo 1: Introducción y primeros pasos

En este curso vamos a aprender Git y GitHub construyendo un proyecto real: un **Manual de Git** escrito en Markdown. Cada concepto nuevo que veamos se incorporará al libro y, al final, un script lo convertirá a Word, PDF y HTML con Pandoc, mientras GitHub publica cada versión automáticamente.

Este primer módulo prepara el terreno. Veremos qué son Git y GitHub, cómo instalar Git, cómo moverse por la terminal y cómo configurar la identidad con la que firmaremos nuestros commits.

## 1.1 ¿Qué es Git y qué es GitHub?

Quien trabaja en un documento o en un proyecto de software acaba, tarde o temprano, con ficheros como `libro-final.docx`, `libro-final-v2.docx` y `libro-final-AHORA-SÍ.docx`. Un **sistema de control de versiones** resuelve este problema: guarda un historial completo de los cambios, indica quién cambió qué y cuándo, y permite volver a cualquier punto anterior.

**Git** es el sistema de control de versiones más usado del mundo, y tiene tres características que conviene conocer desde el principio:

- **Es local**: funciona entero en tu ordenador, sin conexión a internet. El historial completo vive en una carpeta oculta `.git` dentro de tu proyecto.
- **Es distribuido**: cada copia del proyecto tiene el historial completo, no sólo la última versión. No hay un servidor central imprescindible.
- **Trabaja con instantáneas**: cada vez que guardas (lo que se llama _hacer un commit_), Git toma una foto del estado de todos los ficheros del proyecto.

**GitHub**, por su parte, es una plataforma web que aloja repositorios de Git en la nube. Además de guardar una copia de tu proyecto, añade todo lo necesario para colaborar: gestión de usuarios y permisos, revisión de cambios (_pull requests_), incidencias (_issues_), automatización (_GitHub Actions_) y publicación de webs (_GitHub Pages_). La tabla resume las diferencias:

| | Git | GitHub |
| --- | --- | --- |
| Qué es | Programa de control de versiones | Plataforma web de alojamiento |
| Dónde funciona | En tu ordenador | En internet |
| Necesita conexión | No | Sí |
| Alternativas | Mercurial, SVN | GitLab, Bitbucket, Gitea (todas usan Git) |

Siguiendo esta distinción, en los módulos 2 a 4 trabajaremos sólo con Git, en local, y a partir del módulo 5 subiremos el libro a GitHub.

## 1.2 Instalación de Git y comprobación de versiones

Lo primero es instalar Git con el método de tu sistema operativo.

En **Linux** (Debian/Ubuntu):

```bash
sudo apt update
sudo apt install git
```

En **macOS**, con [Homebrew](https://brew.sh):

```bash
brew install git
```

Si no usas Homebrew, macOS te ofrecerá instalar Git junto con las herramientas de desarrollo de Apple la primera vez que escribas `git` en la terminal.

En **Windows**, desde PowerShell:

```powershell
winget install --id Git.Git -e
```

También puedes descargar el instalador desde [git-scm.com](https://git-scm.com/downloads).

El instalador de Git para Windows incluye **Git Bash**, una terminal que entiende los mismos comandos que Linux y macOS. Por eso, si usas Windows, abre siempre Git Bash para seguir el curso: así todos los comandos funcionarán igual.

Una vez instalado, cierra y vuelve a abrir la terminal para que reconozca el programa nuevo, y comprueba que Git responde:

```bash
git --version
git -v
```

Los dos comandos son equivalentes y muestran algo como `git version 2.43.0`. Si en lugar de eso ves `command not found`, la instalación no ha funcionado o la terminal no se ha reiniciado.

Git tiene cientos de opciones, así que es normal no recordarlas. Cuando te pase, puedes pedir ayuda al propio Git:

```bash
git --help
git -h
```

Los dos muestran los comandos más comunes de Git, agrupados por tarea. También puedes pedir la ayuda de un comando concreto, por ejemplo `git commit -h` (resumen breve) o `git help commit` (manual completo).

Ahora bien, que Git tenga cientos de opciones no significa que haya que aprenderlas todas. A lo largo del curso veremos muchos comandos, pero no hace falta memorizarlos: lo importante es entender qué hace cada uno y cuándo conviene usarlo. Unos pocos (`git status`, `git add`, `git commit`, `git log`, `git switch`, `git pull` y `git push`) se usan a diario y acabarás sabiéndolos de memoria sin proponértelo. Del resto basta con saber que existen y para qué sirven; la sintaxis exacta se consulta cuando hace falta, igual que hacen los profesionales.

Para esas consultas tienes a mano estas referencias, cuyas direcciones conviene guardar en los marcadores del navegador:

- **Hoja de referencia de Git** (_cheat sheet_), en <https://git-scm.com/cheat-sheet>. Reúne en una sola página los comandos más habituales, agrupados por tarea. Tenla abierta o imprímela mientras sigues el curso.
- **Web oficial de Git**, en <https://git-scm.com>. Incluye la documentación de cada comando, en <https://git-scm.com/docs>, y el libro gratuito _Pro Git_, traducido al español, en <https://git-scm.com/book/es/v2>, para profundizar en cualquier tema.
- **Documentación de GitHub**, en <https://docs.github.com/es>. Explica en español todo lo que ofrece GitHub (<https://github.com>): cuentas, repositorios, pull requests, GitHub Actions… Será útil a partir del módulo 5.

Estas y el resto de referencias que aparecen en el curso están recopiladas en el [Anexo: referencias útiles](10-anexo-referencias-útiles.md).

Con esto ya tienes todo lo necesario para usar Git. Para seguir el ejemplo del curso, en el que el libro se convierte a Word, PDF y HTML, necesitarás además dos herramientas que no tienen nada que ver con Git: **Pandoc** y, opcionalmente, **Typst**. Instálalas siguiendo el [Anexo: dependencias de los ejemplos](09-anexo-dependencias-de-los-ejemplos.md) antes de llegar al apartado 2.5.

## 1.3 Navegación básica por la terminal

Git se puede usar desde interfaces gráficas, pero en este curso trabajaremos en la terminal, porque es donde se entiende de verdad lo que pasa y es lo que encontrarás en cualquier servidor o documentación. Antes de empezar con Git, por tanto, conviene moverse con soltura por las carpetas del equipo, y para ello bastan unos pocos comandos:

```bash
ls
cd <carpeta>
cd ..
pwd
mkdir <carpeta>
clear
```

- `ls`: lista el contenido de la carpeta actual.
- `cd <carpeta>`: entra en una carpeta.
- `cd ..`: sube a la carpeta padre.
- `pwd`: muestra la ruta de la carpeta en la que estás.
- `mkdir <carpeta>`: crea una carpeta nueva.
- `clear`: limpia la pantalla.

Vamos a ponerlos en práctica creando la carpeta donde vivirá nuestro libro. Empezamos en la carpeta personal (`~`) y comprobamos dónde estamos:

```bash
cd ~
pwd
```

La salida será algo como `/home/tu-usuario` en Linux, `/Users/tu-usuario` en macOS o `/c/Users/tu-usuario` en Git Bash. A continuación, creamos una carpeta `proyectos` para todos tus trabajos y, dentro de ella, la carpeta del libro:

```bash
mkdir proyectos
cd proyectos
mkdir manual-git
ls
```

`ls` muestra la carpeta `manual-git` recién creada. Entramos en ella y comprobamos la ruta:

```bash
cd manual-git
pwd
```

La salida termina en `proyectos/manual-git`, que será nuestra carpeta de trabajo durante todo el curso. Para practicar un poco más, sube un nivel y vuelve a entrar:

```bash
cd ..
pwd
cd manual-git
clear
```

Por último, un truco que te ahorrará mucho tiempo: escribe las primeras letras de una carpeta y pulsa la tecla Tab para que la terminal complete el nombre.

## 1.4 Configuración inicial del usuario (global)

Cada commit lleva la firma de su autor, formada por un nombre y un correo electrónico, así que antes de empezar hay que decirle a Git quién eres. Conviene usar el mismo correo con el que te registrarás (o ya estás registrado) en GitHub, porque así GitHub podrá asociar tus commits a tu cuenta:

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tuemail@dominio.com"
```

La opción `--global` guarda la configuración para todos los repositorios de tu usuario, en el fichero `~/.gitconfig`, de modo que sólo hay que hacerlo una vez por ordenador. Si en algún proyecto concreto necesitas otra identidad (por ejemplo, el correo del trabajo), basta con ejecutar los mismos comandos sin `--global` dentro de ese proyecto.

Para terminar, comprobamos que la configuración se ha guardado:

```bash
git config --global --list
```

Deberías ver tus datos en las líneas `user.name` y `user.email`. Con esto, todo está listo para crear nuestro primer repositorio.
