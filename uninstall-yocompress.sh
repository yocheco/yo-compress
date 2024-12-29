#!/bin/bash

# Incluir el archivo de animaciones
source ./animations.sh

echo "=== Desinstalador de Yocompress ==="

# Eliminar el comando global
if [[ -f /usr/local/bin/yocompress ]]; then
    (sudo rm -f /usr/local/bin/yocompress) &>/dev/null &
    show_spinner_message $! "Eliminando el comando 'yocompress'"
else
    echo "El comando 'yocompress' no se encontró en /usr/local/bin."
fi

# Detectar sistema operativo y eliminar dependencias
echo "Detectando sistema operativo..."
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$ID
else
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
fi

echo "Sistema operativo detectado: $OS"

case "$OS" in
    ubuntu|debian)
        show_spinner_message $! "Eliminando dependencias para $OS"
        (sudo apt remove -y webp imagemagick && sudo apt autoremove -y) &>/dev/null &
        
        ;;
    fedora|centos|rhel)
        show_spinner_message $! "Eliminando dependencias para $OS"
        (sudo dnf remove -y libwebp-tools ImageMagick) &>/dev/null &
        ;;
    arch)
        show_spinner_message $! "Eliminando dependencias para Arch Linux..."
        (sudo pacman -Rns --noconfirm libwebp imagemagick) &>/dev/null &
        ;;
    opensuse)
        show_spinner_message $! "Eliminando dependencias para openSUSE..."
        (sudo zypper remove -y libwebp-tools ImageMagick) &>/dev/null &
        ;;
    darwin)
        show_spinner_message $! "Eliminando dependencias para macOS..."
        if command -v brew &>/dev/null; then
            (brew uninstall webp imagemagick) &>/dev/null &
        else
            echo "Homebrew no está instalado. No se pueden eliminar las dependencias."
        fi
        ;;
    *)
        echo "Sistema operativo no soportado. Por favor elimina 'webp' e 'imagemagick' manualmente."
        ;;
esac

# Eliminar carpeta de logs
LOG_DIR="/var/log/yocompress"
if [[ -d "$LOG_DIR" ]]; then
    show_spinner_message $! "Eliminando carpeta de logs en $LOG_DIR"
    (sudo rm -rf "$LOG_DIR") &>/dev/null &
else
    echo "La carpeta de logs no se encontró en $LOG_DIR."
fi

echo "Yocompress se desinstaló correctamente."
