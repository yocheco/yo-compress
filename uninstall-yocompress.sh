#!/bin/bash



echo "=== Desinstalador de Yocompress ==="

# Pregunta de confirmación
read -p "¿Estás seguro de que deseas desinstalar Yocompress? (s/n): " confirm
confirm=${confirm:-"n"}
if [[ "$confirm" != "s" && "$confirm" != "S" ]]; then
    echo "Desinstalación cancelada."
    exit 0
fi

# Eliminar el comando global
if [[ -f /usr/local/bin/yocompress ]]; then
    echo "Eliminando el comando 'yocompress'..."
    sudo rm -f /usr/local/bin/yocompress
    echo "Comando 'yocompress' eliminado correctamente."
else
    echo "El comando 'yocompress' no se encontró en /usr/local/bin."
fi

# Pregunta sobre dependencias
read -p "¿Deseas eliminar las dependencias instaladas (webp, ImageMagick)? (s/n): " remove_deps
confirm=${confirm:-"n"}
if [[ "$remove_deps" == "s" || "$remove_deps" == "S" ]]; then
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
            echo "Eliminando dependencias para $OS..."
            sudo apt remove -y webp imagemagick
            sudo apt autoremove -y
            ;;
        fedora|centos|rhel)
            echo "Eliminando dependencias para $OS..."
            sudo dnf remove -y libwebp-tools ImageMagick
            ;;
        arch)
            echo "Eliminando dependencias para Arch Linux..."
            sudo pacman -Rns --noconfirm libwebp imagemagick
            ;;
        opensuse)
            echo "Eliminando dependencias para openSUSE..."
            sudo zypper remove -y libwebp-tools ImageMagick
            ;;
        darwin)
            echo "Eliminando dependencias para macOS..."
            if command -v brew &>/dev/null; then
                brew uninstall webp imagemagick
            else
                echo "Homebrew no está instalado. No se pueden eliminar las dependencias."
            fi
            ;;
        *)
            echo "Sistema operativo no soportado. Por favor elimina 'webp' e 'imagemagick' manualmente."
            ;;
    esac
    echo "Dependencias eliminadas."
else
    echo "Dependencias no eliminadas."
fi

echo "Yocompress se desinstaló correctamente."
