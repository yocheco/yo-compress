#!/bin/bash

# Definir la carpeta de salida
output_dir="./compressed"
# Directory argument
directory="./"
# Ruta para logs
LOG_DIR="/var/log/yocompress"
LOG_FILE="$LOG_DIR/yocompress.log"

# Mostrar ayuda si se invoca con --help
if [[ "$1" == "--help" ]]; then
    echo "Uso: yocompress [directorio]"
    echo ""
    echo "Opciones:"
    echo "  --help                Muestra este mensaje de ayuda."
    echo ""
    echo "Descripción:"
    echo "  Este script convierte imágenes en un directorio al formato WebP."
    echo "  También crea versiones comprimidas de las imágenes JPEG y PNG."
    echo ""
    echo "Ejemplo:"
    echo "  yocompress /ruta/al/directorio"
    echo ""
    exit 0
fi

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


# Crear la carpeta de salida (eliminarla si ya existe)
if [[ -d "$output_dir" ]]; then
    (rm -rf "$output_dir") &>/dev/null &
    show_spinner_message $! "Limpiando carpeta de salida"
fi

(mkdir -p "$output_dir") &>/dev/null &
show_spinner_message $! "Creando carpeta para imágenes comprimidas"

# Crear el archivo de log
if [[ ! -f "$LOG_FILE" ]]; then
    echo "=== Registro de Yocompress ===" > "$LOG_FILE"
fi
# Agregar registro de inicio
echo "=== Inicio del script Yocompress: $(date) ===" >> "$LOG_FILE"

# Solicitar valores de calidad de forma interactiva
read -p "Enter JPEG quality (0-100, default 85): " jpeg_quality
jpeg_quality=${jpeg_quality:-85}

read -p "Enter PNG quality (0-100, default 95): " png_quality
png_quality=${png_quality:-95}

read -p "Enter alpha quality (0-100, default 95): " alpha_quality
alpha_quality=${alpha_quality:-95}

# Procesar imágenes JPEG
# converting JPEG images
(find "$directory" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) \
-exec bash -c '
jpeg_quality=$jpeg_quality
input_file="$0"
output_dir="./compressed"
webp_path="$output_dir/$(basename "$input_file" | sed 's/\.[^.]*$/.webp/')"
jpg_path="$output_dir/$(basename "$input_file" | sed 's/\.[^.]*$/.jpg/')"
if [ ! -f "$webp_path" ]; then 
  echo "$webp_path image ok";
  cwebp -quiet -q '"$jpeg_quality"' "$0" -o "$webp_path";
  convert "$0" -quality '"$jpeg_quality"' "$jpg_path";
fi;' {} \;) &>/dev/null
show_spinner_message $! "Procesando imágenes JPEG"

# Procesar imágenes PNG
(find "$directory" -type f -iname "*.png" \
-exec bash -c '
png_quality=$png_quality
alpha_quality=$alpha_quality
input_file="$0"
output_dir="./compressed"
webp_path="$output_dir/$(basename "$input_file" | sed 's/\.[^.]*$/.webp/')"
jpg_path="$output_dir/$(basename "$input_file" | sed 's/\.[^.]*$/.jpg/')"
start_time=$(date "+%Y-%m-%d %H:%M:%S")
LOG_DIR="/var/log/yocompress"
LOG_FILE="$LOG_DIR/yocompress.log"
if [ ! -f "$webp_path" ]; then 
  echo "$webp_path image ok";
  echo "[$start_time] Procesando $input_file...";
  cwebp -quiet -alpha_q '"$alpha_quality"' -q '"$png_quality"' "$0" -o "$webp_path";
  convert "$0" -quality '"$png_quality"' "$jpg_path";
fi;' {} \;) >> $LOG_FILE
show_spinner_message $! "Procesando imágenes PNG"

echo "=== Fin del script Yocompress: $(date) ===" >> "$LOG_FILE"
echo "Imágenes comprimidas guardadas en: $output_dir"
