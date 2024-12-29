#!/bin/bash

# Nombre del instalador: install-yocompress.sh

# Función para mostrar una animación de spinner
show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    tput civis  # Ocultar cursor
    while ps -p $pid &>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c] Procesando...  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\r"
    done
    tput cnorm  # Restaurar cursor
    echo " [✔] Hecho"
}


# Función para mostrar un spinner con texto personalizado
show_spinner_message() {
    local pid=$1
    local message=$2
    local delay=0.1
    local spinstr='|/-\'
    tput civis  # Ocultar cursor
    while ps -p $pid &>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c] %s  " "$spinstr" "$message"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\r"
    done
    tput cnorm  # Restaurar cursor
    echo " [✔] $message completado."
}


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
            (sudo apt update -qq && sudo apt install -y webp imagemagick -qq) &>/dev/null &
            show_spinner_message $! "Instalando dependencias"
            ;;
        fedora|centos|rhel)
            echo "Instalando dependencias para $OS..."
            (sudo dnf install -y libwebp-tools ImageMagick -q) &>/dev/null &
            show_spinner_message $! "Instalando dependencias"
            ;;
        arch)
            echo "Instalando dependencias para Arch Linux..."
            (sudo pacman -S --noconfirm libwebp imagemagick) &>/dev/null &
            show_spinner_message $! "Instalando dependencias"
            ;;
        opensuse)
            echo "Instalando dependencias para openSUSE..."
            (sudo zypper install -y libwebp-tools ImageMagick) &>/dev/null &
            show_spinner_message $! "Instalando dependencias"
            ;;
        darwin)
            echo "Instalando dependencias para macOS..."
            if ! command -v brew &>/dev/null; then
                echo "Homebrew no está instalado. Instálalo primero desde https://brew.sh"
                exit 1
            fi
            (brew install webp imagemagick) &>/dev/null &
            show_spinner_message $! "Instalando dependencias"
            ;;
        *)
            echo "Sistema operativo no soportado. Por favor instala 'webp' e 'imagemagick' manualmente."
            exit 1
            ;;
    esac
}

install_dependencies

# Crear carpeta de logs
LOG_DIR="/var/log/yocompress"
LOG_FILE="$LOG_DIR/yocompress.log"

# Crear carpeta de logs
show_spinner_message $! "Creando carpeta de logs en $LOG_DIR"
if [[ ! -d "$LOG_DIR" ]]; then
    sudo mkdir -p "$LOG_DIR"
    sudo chmod 755 "$LOG_DIR"
    sudo chown $SUDO_USER:$SUDO_USER "$LOG_DIR"
fi

# Crear archivo de logs
show_spinner_message $! "Creando archivo de logs en $LOG_FILE"
if [[ ! -f "$LOG_FILE" ]]; then
    sudo touch "$LOG_FILE"
    sudo chmod 644 "$LOG_FILE"
    sudo chown $SUDO_USER:$SUDO_USER "$LOG_FILE"
fi

# Descargar el script desde un repositorio remoto publico
SCRIPT_URL="https://raw.githubusercontent.com/yocheco/yo-compress/main/webp-convert.sh"
SCRIPT_NAME="webp-convert.sh"

(curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_NAME") &>/dev/null &
show_spinner_message $! "Descargando script 'webp-convert.sh' desde el repositorio"
if [[ $? -ne 0 ]]; then
    echo "Error: No se pudo descargar el script desde $SCRIPT_URL."
    exit 1
fi

# Crear un directorio temporal
TEMP_DIR=$(mktemp -d)

# Copiar el script al directorio temporal
cp "$SCRIPT_NAME" "$TEMP_DIR"

# Hacer que el script sea ejecutable
chmod +x "$TEMP_DIR/$SCRIPT_NAME"

# Mover el script a /usr/local/bin con el nombre "yocompress"
show_spinner_message $! "Configurando el comando 'yocompress'"
sudo mv "$TEMP_DIR/$SCRIPT_NAME" /usr/local/bin/yocompress

# Limpiar el directorio temporal
rm -rf "$TEMP_DIR"
rm -f "$SCRIPT_NAME"

# Verificar si el comando yocompress está disponible y ejecutarlo con --help
if command -v yocompress &>/dev/null; then
    echo "El comando 'yocompress' se instaló correctamente y está listo para usarse."
    echo "Ejecutando 'yocompress --help':"
    yocompress --help
else
    echo "Error: No se pudo instalar el comando 'yocompress'."
    exit 1
fi
