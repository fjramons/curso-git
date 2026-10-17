# Módulo 1: Introducción y primeros pasos

Este curso enseña Git y GitHub mediante la construcción de un proyecto real: un **Manual de Git** escrito en Markdown. Cada concepto nuevo se incorpora al libro y, al final, un script lo convierte a Word, PDF y HTML con Pandoc, mientras GitHub publica cada versión automáticamente.

Este primer módulo prepara el terreno: qué son Git y GitHub, cómo instalar Git, cómo moverse por la terminal y cómo configurar la identidad del autor de los commits.

## 1.1 ¿Qué es Git y qué es GitHub?

Quien trabaja en un documento o en un proyecto de software acaba tarde o temprano con ficheros como `libro-final.docx`, `libro-final-v2.docx` y `libro-final-AHORA-SÍ.docx`. Un **sistema de control de versiones** resuelve este problema: guarda un historial completo de los cambios, indica quién cambió qué y cuándo, y permite volver a cualquier punto anterior.

**Git** es el sistema de control de versiones más usado del mundo. Tiene tres características que conviene conocer desde el principio:

- **Es local**: funciona entero en tu ordenador, sin conexión a internet. El historial completo vive en una carpeta oculta `.git` dentro de tu proyecto.
- **Es distribuido**: cada copia del proyecto tiene el historial completo, no solo la última versión. No hay un servidor central imprescindible.
- **Trabaja con instantáneas**: cada vez que guardas (lo que se llama _hacer un commit_) Git toma una foto del estado de todos los ficheros del proyecto.

**GitHub** es una plataforma web que aloja repositorios de Git en la nube. Además de guardar una copia de tu proyecto, añade todo lo necesario para colaborar: gestión de usuarios y permisos, revisión de cambios (_pull requests_), incidencias (_issues_), automatización (_GitHub Actions_) y publicación de webs (_GitHub Pages_).

| | Git | GitHub |
| --- | --- | --- |
| Qué es | Programa de control de versiones | Plataforma web de alojamiento |
| Dónde funciona | En tu ordenador | En internet |
| Necesita conexión | No | Sí |
| Alternativas | Mercurial, SVN | GitLab, Bitbucket, Gitea (todas usan Git) |

Los módulos 2 a 4 trabajan solo con Git, en local. A partir del módulo 5, el libro se sube a GitHub.

## 1.2 Instalación de Git y comprobación de versiones

Instala Git con el método de tu sistema operativo.

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

El instalador de Git para Windows incluye **Git Bash**, una terminal que entiende los mismos comandos que Linux y macOS. A partir de ahora, si usas Windows, abre siempre Git Bash para seguir el curso: todos los comandos funcionarán igual.

Cierra y vuelve a abrir la terminal para que reconozca el programa nuevo, y comprueba que Git está instalado:

```bash
git --version
git -v
```

Los dos comandos son equivalentes y muestran algo como `git version 2.43.0`. Si en lugar de eso ves `command not found`, la instalación no ha funcionado o la terminal no se ha reiniciado.

Git tiene cientos de opciones. Cuando no recuerdes una, pide ayuda al propio Git:

```bash
git --help
git -h
```

Los dos muestran los comandos más comunes de Git agrupados por tarea. También puedes pedir la ayuda de un comando concreto, por ejemplo `git commit -h` (resumen breve) o `git help commit` (manual completo).

Que Git tenga cientos de opciones no significa que haya que aprenderlas todas. A lo largo del curso verás muchos comandos, pero no hace falta memorizarlos: lo importante es entender qué hace cada uno y cuándo conviene usarlo. Unos pocos (`git status`, `git add`, `git commit`, `git log`, `git switch`, `git pull` y `git push`) se usan a diario y acabarás sabiéndolos de memoria sin proponértelo. Del resto basta con saber que existen y para qué sirven; la sintaxis exacta se consulta cuando hace falta, igual que hacen los profesionales.

Para esas consultas tienes estas referencias. Guarda sus direcciones en los marcadores del navegador:

- **Hoja de referencia de Git** (_cheat sheet_), en <https://git-scm.com/cheat-sheet>. Reúne en una sola página los comandos más habituales, agrupados por tarea. Tenla abierta o imprímela mientras sigues el curso.
- **Web oficial de Git**, en <https://git-scm.com>. Incluye la documentación de cada comando, en <https://git-scm.com/docs>, y el libro gratuito _Pro Git_, traducido al español, en <https://git-scm.com/book/es/v2>, para profundizar en cualquier tema.
- **Documentación de GitHub**, en <https://docs.github.com/es>. Explica en español todo lo que ofrece GitHub (<https://github.com>): cuentas, repositorios, pull requests, GitHub Actions… Será útil a partir del módulo 5.

Estas y el resto de referencias que aparecen en el curso están recopiladas en el [Anexo: referencias útiles](10-anexo-referencias-útiles.md).

Con esto ya tienes todo lo necesario para usar Git. Para seguir el ejemplo del curso, en el que el libro se convierte a Word, PDF y HTML, necesitarás además dos herramientas que no tienen nada que ver con Git: **Pandoc** y, opcionalmente, **Typst**. Instálalas siguiendo el [Anexo: dependencias de los ejemplos](09-anexo-dependencias-de-los-ejemplos.md) antes de llegar al apartado 2.5.

## 1.3 Navegación básica por la terminal

Git se puede usar desde interfaces gráficas, pero este curso trabaja en la terminal: es donde se entiende de verdad lo que pasa y es lo que encontrarás en cualquier servidor o documentación. Antes de empezar con Git, conviene moverse con soltura por las carpetas del equipo.

Estos son los comandos esenciales:

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

Con ellos vas a crear la carpeta donde vivirá el libro. Empieza en tu carpeta personal (`~`) y comprueba dónde estás:

```bash
cd ~
pwd
```

La salida será algo como `/home/tu-usuario` en Linux, `/Users/tu-usuario` en macOS o `/c/Users/tu-usuario` en Git Bash. Crea ahora una carpeta `proyectos` para todos tus trabajos y, dentro de ella, la carpeta del libro:

```bash
mkdir proyectos
cd proyectos
mkdir manual-git
ls
```

`ls` muestra la carpeta `manual-git` recién creada. Entra en ella y comprueba la ruta:

```bash
cd manual-git
pwd
```

La salida termina en `proyectos/manual-git`. Esta será la carpeta de trabajo durante todo el curso. Para practicar, sube un nivel y vuelve a entrar:

```bash
cd ..
pwd
cd manual-git
clear
```

Un truco que te ahorrará mucho tiempo: escribe las primeras letras de una carpeta y pulsa la tecla Tab para que la terminal complete el nombre.

## 1.4 Configuración inicial del usuario (global)

Cada commit lleva la firma de su autor: un nombre y un correo electrónico. Antes de empezar, hay que indicarle a Git quién eres. Usa el mismo correo con el que te registrarás (o ya estás registrado) en GitHub, así GitHub podrá asociar tus commits a tu cuenta:

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tuemail@dominio.com"
```

La opción `--global` guarda la configuración para todos los repositorios de tu usuario, en el fichero `~/.gitconfig`. Solo hay que hacerlo una vez por ordenador. Si en algún proyecto concreto necesitas otra identidad (por ejemplo, el correo del trabajo), ejecuta los mismos comandos sin `--global` dentro de ese proyecto.

Comprueba que la configuración se ha guardado:

```bash
git config --global --list
```

Deberías ver tus datos en las líneas `user.name` y `user.email`. Todo está listo para crear el primer repositorio.
