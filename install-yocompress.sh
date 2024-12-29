#!/bin/bash

# Nombre del instalador: install-yocompress.sh

echo "=== Instalador de Yocompress ==="
echo "Detectando sistema operativo..."

# Detectar el sistema operativo
if [[ -f /etc/os-release ]]; then
    # Leer información del sistema operativo
    . /etc/os-release
    OS=$ID
else
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
fi

echo "Sistema operativo detectado: $OS"

# Instalar dependencias según el sistema operativo
install_dependencies() {
    case "$OS" in
        ubuntu|debian)
            echo "Instalando dependencias para $OS..."
            sudo apt update
            sudo apt install -y webp imagemagick
            ;;
        fedora|centos|rhel)
            echo "Instalando dependencias para $OS..."
            sudo dnf install -y libwebp-tools ImageMagick
            ;;
        arch)
            echo "Instalando dependencias para Arch Linux..."
            sudo pacman -S --noconfirm libwebp imagemagick
            ;;
        opensuse)
            echo "Instalando dependencias para openSUSE..."
            sudo zypper install -y libwebp-tools ImageMagick
            ;;
        darwin)
            echo "Instalando dependencias para macOS..."
            if ! command -v brew &>/dev/null; then
                echo "Homebrew no está instalado. Instálalo primero desde https://brew.sh"
                exit 1
            fi
            brew install webp imagemagick
            ;;
        *)
            echo "Sistema operativo no soportado. Por favor instala 'webp' e 'imagemagick' manualmente."
            exit 1
            ;;
    esac
}

install_dependencies

# Copiar el script al directorio global
echo "Configurando el comando 'yocompress'..."
SCRIPT_NAME="webp-convert.sh"

# Verificar si el script existe en el directorio actual
if [[ ! -f "$SCRIPT_NAME" ]]; then
    echo "Error: No se encontró el script '$SCRIPT_NAME' en el directorio actual."
    exit 1
fi

# Crear un directorio temporal
TEMP_DIR=$(mktemp -d)

# Copiar el script al directorio temporal
cp "$SCRIPT_NAME" "$TEMP_DIR"

# Hacer que el script sea ejecutable
chmod +x "$TEMP_DIR/$SCRIPT_NAME"

# Mover el script a /usr/local/bin con el nombre "yocompress"
sudo mv "$TEMP_DIR/$SCRIPT_NAME" /usr/local/bin/yocompress

# Limpiar el directorio temporal
rm -rf "$TEMP_DIR"

# Verificar si el comando yocompress está disponible
if command -v yocompress &>/dev/null; then
    echo "El comando 'yocompress' se instaló correctamente y está listo para usarse."
    echo "Ejemplo de uso: yocompress <directorio>"
else
    echo "Error: No se pudo instalar el comando 'yocompress'."
    exit 1
fi
