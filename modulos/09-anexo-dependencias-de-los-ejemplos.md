# Anexo: dependencias de los ejemplos

Las herramientas de este anexo **no son necesarias para usar Git ni GitHub**. Sólo se usan en el ejemplo que recorre el curso: el script `build.sh` del apartado 2.5 convierte el Manual de Git, escrito en Markdown, a Word, PDF y HTML. Si sólo te interesa Git, puedes saltarte este anexo y leer los apartados del libro sin generarlo.

En GitHub no hace falta instalar nada: en el módulo 8, el CI instala estas mismas herramientas en sus propias máquinas para publicar cada versión del libro.

## Qué se instala y para qué

- **Pandoc**: un conversor universal de documentos. Lee los capítulos en Markdown y genera el `.docx` y el `.html`. Es imprescindible para el ejemplo.
- **Typst** (opcional): un motor de composición tipográfica que Pandoc usa para generar el PDF. Se ha elegido en lugar de LaTeX, la opción clásica, porque es un único programa pequeño y fácil de instalar, mientras que una instalación de LaTeX ocupa varios GB. Si no instalas Typst, `build.sh` muestra un aviso y genera igualmente el Word y el HTML.

## Instalación

En **Linux** (Debian/Ubuntu):

```bash
sudo apt update
sudo apt install pandoc
```

La versión de Pandoc de los repositorios de tu distribución puede ser antigua. Si `build.sh` da errores, instala la última desde la [página de descargas de Pandoc](https://pandoc.org/installing.html).

Typst no está en los repositorios de Debian ni de Ubuntu. La forma más sencilla de instalarlo es descargar el programa oficial desde su [página de releases](https://github.com/typst/typst/releases): es un único fichero que no necesita gestor de paquetes ni permisos de administrador. Estos comandos descargan la última versión, la descomprimen y la copian en `~/.local/bin`, la carpeta habitual para los programas de tu usuario:

```bash
curl -LO https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz
tar -xf typst-x86_64-unknown-linux-musl.tar.xz
mkdir -p ~/.local/bin
mv typst-x86_64-unknown-linux-musl/typst ~/.local/bin/
```

Si tu equipo tiene un procesador ARM (por ejemplo, una Raspberry Pi), cambia `x86_64` por `aarch64` en las dos primeras líneas. Si después `typst --version` dice que no encuentra el programa, `~/.local/bin` no está en tu `PATH`. En Ubuntu se añade automáticamente al iniciar sesión si la carpeta existe, así que basta con cerrar la sesión y volver a entrar. En otras distribuciones, añade `export PATH="$HOME/.local/bin:$PATH"` al final de tu `~/.bashrc`.

Otras formas de instalar Typst en Linux:

- Con [Homebrew para Linux](https://docs.brew.sh/Homebrew-on-Linux), si ya lo usas: `brew install typst`.
- Con el gestor de paquetes de las distribuciones que lo incluyen, como Arch Linux: `sudo pacman -S typst`.
- Con snap: `sudo snap install typst`.
- Compilándolo con las herramientas de Rust: `cargo install --locked typst-cli`.

En **macOS**, con [Homebrew](https://brew.sh):

```bash
brew install pandoc typst
```

En **Windows**, desde PowerShell:

```powershell
winget install --id JohnMacFarlane.Pandoc -e
winget install --id Typst.Typst -e
```

## Comprobación

Cierra y vuelve a abrir la terminal (Git Bash en Windows) y comprueba que las dos herramientas responden:

```bash
pandoc --version
typst --version
```

Cada comando muestra la versión instalada. Si `typst --version` falla y no quieres el PDF, puedes seguir adelante sin problema.

Para abrir el libro generado necesitarás también un programa que lea `.docx`, como Microsoft Word o LibreOffice, y un visor de PDF. El `index.html` se abre con cualquier navegador.
