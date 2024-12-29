#!/bin/bash

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
