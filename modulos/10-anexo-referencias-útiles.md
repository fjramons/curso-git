# Anexo: referencias útiles

Este anexo recopila los recursos citados a lo largo del curso, agrupados por tema. Como se explica en el apartado 1.2, no hace falta memorizar cada comando: basta con entender qué hace y saber dónde consultarlo. Cada recurso lleva su dirección, para que puedas copiarla también desde el PDF o el Word, y entre paréntesis el apartado en el que se cita.

## Git

- **Web oficial de Git (<https://git-scm.com>)**: descargas para todos los sistemas operativos (1.2).
- **Hoja de referencia de Git (<https://git-scm.com/cheat-sheet>)**: los comandos más habituales en una sola página. Es la consulta rápida para el día a día (1.2).
- **Documentación de Git (<https://git-scm.com/docs>)**: el manual de referencia de cada comando y de todas sus opciones, el mismo que muestra `git help <comando>` (1.2).
- **_Pro Git_ (<https://git-scm.com/book/es/v2>)**: libro completo y gratuito sobre Git, traducido al español. Es el texto de referencia para profundizar en cualquier tema (1.2 y 7.3).
- **Oh Shit, Git!?! (<https://ohshitgit.com/es>)**: soluciones a los errores más habituales, en español (3.2).
- **Learn Git Branching (<https://learngitbranching.js.org/?locale=es_ES>)**: ejercicios interactivos y visuales para practicar con ramas, fusiones y rebase (módulo 4).
- **Versionado semántico (<https://semver.org/lang/es/>)**: el formato `MAYOR.MENOR.PARCHE` de las etiquetas de versión (3.4).

## GitHub

- **GitHub (<https://github.com>)**: la plataforma donde se aloja el libro (módulo 5).
- **Documentación de GitHub (<https://docs.github.com/es>)**: la referencia de todo lo que ofrece GitHub, en español (1.2).
- **Conectar a GitHub con SSH (<https://docs.github.com/es/authentication/connecting-to-github-with-ssh>)**: creación de claves y solución de problemas de conexión (5.1).
- **First Contributions (<https://github.com/firstcontributions/first-contributions>)**: un proyecto pensado para practicar el primer pull request en un repositorio real (6.1).
- **Choose a License (<https://choosealicense.com>)**: ayuda para elegir la licencia de un proyecto de código abierto (6.3).
- **github/gitignore (<https://github.com/github/gitignore>)**: plantillas de `.gitignore` para casi cualquier lenguaje, editor y sistema operativo (2.5).
- **GitHub flow (<https://docs.github.com/es/get-started/using-github/github-flow>)**: el flujo de trabajo que sigue el libro desde el módulo 7 (7.2).
- **A successful Git branching model (<https://nvie.com/posts/a-successful-git-branching-model/>)**: el artículo original de GitFlow, en inglés (7.2).
- **Interfaces gráficas**: GitHub Desktop (<https://desktop.github.com>), GitKraken (<https://www.gitkraken.com>) y Sourcetree (<https://www.sourcetreeapp.com>) (7.1).

## Markdown

- **Markdown Guide (<https://www.markdownguide.org>)**: guía completa de la sintaxis Markdown, con ejemplos (2.2 y 6.3).
- **Hoja de referencia de Markdown (<https://www.markdownguide.org/cheat-sheet/>)**: la sintaxis básica y la extendida en una sola página (2.2 y 6.3).
- **Escritura en GitHub (<https://docs.github.com/es/get-started/writing-on-github>)**: los extras de Markdown que añade GitHub, como las listas de tareas y los avisos (6.3).
- **markdownlint (<https://github.com/DavidAnson/markdownlint>)**: las reglas de estilo que revisa el CI del libro (8.4).

## GitHub Actions

- **Documentación de GitHub Actions (<https://docs.github.com/es/actions>)**: guías y referencia de workflows, eventos, jobs y runners (8.1).
- **Sintaxis de flujos de trabajo (<https://docs.github.com/es/actions/reference/workflows-and-actions/workflow-syntax>)**: todas las claves que admite un fichero de workflow (8.3).
- **Marketplace de GitHub Actions (<https://github.com/marketplace?type=actions>)**: el catálogo de actions publicadas por GitHub y por la comunidad (8.4).
- **crontab.guru (<https://crontab.guru>)**: comprueba y traduce a lenguaje natural las expresiones cron (8.7).
- **git-auto-commit-action (<https://github.com/stefanzweifel/git-auto-commit-action>)**: action para que un workflow haga commits en el repositorio (8.6).
- **lychee (<https://github.com/lycheeverse/lychee>)**: comprobador de enlaces rotos (8.7).

## Herramientas del ejemplo

Estas herramientas no forman parte de Git ni de GitHub: solo se usan para generar el libro (ver el [Anexo: dependencias de los ejemplos](09-anexo-dependencias-de-los-ejemplos.md)).

- **Pandoc (<https://pandoc.org>)**: convierte el libro de Markdown a Word, PDF y HTML (2.5).
- **Typst (<https://typst.app>)**: el motor que usa Pandoc para generar el PDF (2.5).
- **Homebrew (<https://brew.sh>)**: gestor de paquetes para macOS y Linux (1.2).
- **Node.js (<https://nodejs.org>)**: necesario para ejecutar markdownlint en local (8.4).
