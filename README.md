# Yocompress

**Yocompress** es una herramienta para comprimir imágenes en formatos JPEG y PNG a WebP con calidad configurable. Está diseñada para ser sencilla de usar y compatible con múltiples sistemas operativos.

---

## 🚀 Instalación

### Requisitos

- Un sistema operativo basado en Linux o macOS.
- Dependencias: `webp` e `imagemagick` (el instalador las configura automáticamente).

### Instalación Automática

1. Abre una terminal y ejecuta este comando:
   ```bash
   curl -fsSL https://github.com/<tu-usuario>/yocompress/raw/main/install-yocompress.sh | bash
   ```

Esto hará lo siguiente:

- Detectará tu sistema operativo.
- Instalará las dependencias necesarias.
- Configurará el comando global `yocompress`.

2. Verifica que la instalación fue exitosa ejecutando:

```bash
yocompress --help
```

---

## 📢 Uso

### Comprimir Imágenes

1. Coloca las imágenes JPEG/PNG en un directorio.
2. Ejecuta:

```bash
yocompress <directorio>
```

3. Se generarán las versiones comprimidas en WebP en el mismo directorio.

### Opciones Interactivas

Durante la ejecución, se te pedirá que configures las calidades:

- **JPEG Quality**: Calidad de compresión para imágenes JPEG (valor predeterminado: 85).
- **PNG Quality**: Calidad de compresión para imágenes PNG (valor predeterminado: 95).
- **Alpha Quality**: Calidad para el canal alfa en imágenes PNG (valor predeterminado: 95).

---

## 🧼 Desinstalación

### Desinstalador Automático

1. Descarga y ejecuta el desinstalador:

```bash
curl -fsSL https://github.com/<tu-usuario>/yocompress/raw/main/uninstall-yocompress.sh | bash
```

Esto eliminará:

- El comando `yocompress`.
- Opcionalmente, las dependencias (`webp` e `imagemagick`).

2. Sigue las instrucciones para confirmar la desinstalación.

---

## Desarrollo

### Archivos

- **`webp-convert.sh`**: Script principal que realiza la compresión de imágenes.
- **`install-yocompress.sh`**: Script de instalación automática.
- **`uninstall-yocompress.sh`**: Script de desinstalación.

### Contribuir

1. Clona el repositorio:

```bash
git clone https://github.com/<tu-usuario>/yocompress.git
```

2. Realiza los cambios y envía un pull request.

---

## Compatibilidad

### Sistemas Operativos Soportados

- **Ubuntu/Debian**: Usa `apt` para instalar dependencias.
- **Fedora/RHEL/CentOS**: Usa `dnf`.
- **Arch Linux**: Usa `pacman`.
- **openSUSE**: Usa `zypper`.
- **macOS**: Usa `brew` (requiere Homebrew instalado).

---

## Ejemplo Práctico

### Directorio con Imágenes

Supongamos que tienes un directorio `imagenes` con los siguientes archivos:

```bash
imagenes/
├── foto1.jpg
├── foto2.png
├── documento.pdf
```

Al ejecutar:

```bash
yocompress imagenes
```

Obtendrás:

```bash
imagenes/
├── foto1.jpg
├── foto1.webp
├── foto2.png
├── foto2.webp
```

---

## Preguntas Frecuentes

### 1. ¿Qué pasa si mi sistema no está soportado?

Puedes instalar manualmente las dependencias:

- **webp**: Herramienta para convertir imágenes a WebP.
- **imagemagick**: Herramienta para manipular imágenes.

Después, puedes usar `yocompress` normalmente.

### 2. ¿Puedo personalizar las calidades predeterminadas?

Sí, puedes modificar los valores interactivos que se piden durante la ejecución del script.

---

## Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` para más información.
