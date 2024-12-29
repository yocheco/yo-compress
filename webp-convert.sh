#!/bin/bash

# Definir la versión del script
VERSION="0.0.2"
# URL del repositorio remoto donde se aloja el script
REMOTE_URL="https://raw.githubusercontent.com/yocheco/yo-compress/main/webp-convert.sh"
# Definir la carpeta de salida
output_dir="./compressed"
# Directory argument
directory="./"
# Ruta para logs
LOG_DIR="/var/log/yocompress"
LOG_FILE="$LOG_DIR/yocompress.log"

# Funciones
# =======================================   
# =======================================
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

# Función para actualizar el script
update_script() {
    echo "Comprobando actualizaciones..."
    echo "=== 🚀 Inicio de actualización: $(date) ===" >> "$LOG_FILE"
    temp_file=$(mktemp)

    # Descargar la última versión del script
    (
        curl -fsSL "$REMOTE_URL" -o "$temp_file"
    ) &>/dev/null &
    show_spinner_message $! "Descargando la última versión"

    if [[ -s "$temp_file" ]]; then
        echo "Actualizando el script..."
        (
            sudo mv "$temp_file" "$(command -v yocompress)"
            sudo chmod +x "$(command -v yocompress)"
        ) &>/dev/null &
        show_spinner_message $! "Reemplazando el archivo del script"
        echo "El script se actualizó correctamente a la última versión."
        echo "[$(date)] El script se actualizó correctamente a la última versión." >> "$LOG_FILE"
        echo "=== 🏁 Fin de actualización: $(date) ===" >> "$LOG_FILE"
         yocompress --version  # Mostrar la versión actualizada
    else
        echo "Error: No se pudo descargar la actualización. Verifica tu conexión o la URL del repositorio."
        echo "[$(date)] Error durante la actualización. No se pudo descargar el script." >> "$LOG_FILE"
        rm -f "$temp_file"
        exit 1
    fi
}

# Mostrar ayuda si se invoca con --help
# =======================================
# =======================================
if [[ "$1" == "--help" ]]; then
    echo "Uso: yocompress [directorio]"
    echo ""
    echo "Opciones:"
    echo "  --help                Muestra este mensaje de ayuda."
    echo "  --logs                Muestra el contenido del archivo de logs."
    echo "  --version             Muestra la versión del script."
    echo "  --update              Actualiza el script a la última versión."
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

# Mostrar los logs si se pasa la opción --logs
# =======================================
# =======================================
if [[ "$1" == "--logs" ]]; then
    if [[ -f "$LOG_FILE" ]]; then
        echo "=== Mostrando logs de Yo-compress ==="
        cat "$LOG_FILE"
    else
        echo "No se encontró el archivo de logs en: $LOG_FILE"
    fi
    exit 0
fi


# Mostrar la versión si se invoca con --version
# =======================================
# =======================================
if [[ "$1" == "--version" ]]; then
    echo "Yo-compress versión $VERSION"
    exit 0
fi



# Actualizar el script si se invoca con --update
# =======================================
# =======================================
if [[ "$1" == "--update" ]]; then
    update_script
    exit 0
fi

# Crear la carpeta de salida (eliminarla si ya existe)
if [[ -d "$output_dir" ]]; then
    (rm -rf "$output_dir") &>/dev/null &
    show_spinner_message $! "Limpiando carpeta de salida"
fi

(mkdir -p "$output_dir") &>/dev/null &
show_spinner_message $! "Creando carpeta para imágenes comprimidas"

# Crear el archivo de log
if [[ ! -f "$LOG_FILE" ]]; then
    echo "=== Registro de Yo-compress ===" > "$LOG_FILE"
fi
# Agregar registro de inicio
echo "=== 🚀 Inicio del script Yo-compress: $(date) ===" >> "$LOG_FILE"

# Solicitar valores de calidad de forma interactiva
read -p "Enter JPEG quality (0-100, default 85): " jpeg_quality
jpeg_quality=${jpeg_quality:-85}

read -p "Enter PNG quality (0-100, default 95): " png_quality
png_quality=${png_quality:-95}

read -p "Enter alpha quality (0-100, default 95): " alpha_quality
alpha_quality=${alpha_quality:-95}

# Procesar imágenes JPEG
(find "$directory" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) \
-exec bash -c '
jpeg_quality=$jpeg_quality
input_file="$0"
output_dir="./compressed"
webp_path="$output_dir/$(basename "$input_file" | sed 's/\.[^.]*$/.webp/')"
jpg_path="$output_dir/$(basename "$input_file" | sed 's/\.[^.]*$/.jpg/')"
LOG_FILE="/var/log/yocompress/yocompress.log"

if [ ! -f "$webp_path" ]; then 
  original_size=$(du -b "$input_file" | cut -f1)
  
  # Convertir a WebP
  cwebp -quiet -q '"$jpeg_quality"' "$input_file" -o "$webp_path"
  
  # Comprimir a JPEG
  convert "$input_file" -quality '"$jpeg_quality"' "$jpg_path"
  
  compressed_size=$(du -b "$webp_path" | cut -f1)
  reduction=$((original_size - compressed_size))
  reduction_percent=$((100 * reduction / original_size))
  
  # Mostrar y guardar en log
  echo "Archivo: $(basename "$input_file") -> Reducido en $reduction bytes ($reduction_percent%)"
  echo "[$(date)] Archivo: $(basename "$input_file") -> Reducido en $reduction bytes ($reduction_percent%)" >> "$LOG_FILE"
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
LOG_FILE="/var/log/yocompress/yocompress.log"

if [ ! -f "$webp_path" ]; then 
  original_size=$(du -b "$input_file" | cut -f1)
  
  # Convertir a WebP
  cwebp -quiet -alpha_q '"$alpha_quality"' -q '"$png_quality"' "$input_file" -o "$webp_path"
  
  # Comprimir a JPEG
  convert "$input_file" -quality '"$png_quality"' "$jpg_path"
  
  compressed_size=$(du -b "$webp_path" | cut -f1)
  reduction=$((original_size - compressed_size))
  reduction_percent=$((100 * reduction / original_size))
  
  # Mostrar y guardar en log
  echo "Archivo: $(basename "$input_file") -> Reducido en $reduction bytes ($reduction_percent%)"
  echo "[$(date)] Archivo: $(basename "$input_file") -> Reducido en $reduction bytes ($reduction_percent%)" >> "$LOG_FILE"
fi;' {} \;) &>/dev/null
show_spinner_message $! "Procesando imágenes PNG"

echo "=== 🏁 Fin del script Yo-compress: $(date) ===" >> "$LOG_FILE"
echo "Imágenes comprimidas guardadas en: $output_dir"
