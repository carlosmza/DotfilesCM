# Quickshell Configuration

Panel lateral para Hyprland (Wayland) basado en Quickshell.

## Estructura del Proyecto

```
quickshell/
├── shell.qml              # Punto de entrada del shell
├── assets/                # Recursos estáticos (actualmente vacío)
├── config/                # Configuración global
│   ├── theme/
│   │   ├── Colors.qml     # Singleton que lee el tema desde JSON
│   │   └── current.json  # Enlace simbólico al tema activo
│   └── fonts/
│       ├── Fonts.qml      # Carga de fuentes personalizadas
│       ├── qmldir         # Directorio de módulos QML
│       └── *.ttf|*.otf    # Fuentes (Poppins, Lato, etc.)
├── ui/
│   ├── layout/
│   │   ├── TopBar.qml     # Barra superior (deshabilitada)
│   │   └── LeftBar.qml    # Barra lateral principal (activa)
│   ├── components/        # Componentes integrados en la barra
│   │   ├── Workspaces.qml # Indicadores de workspaces
│   │   ├── Window.qml     # Vista previa de ventana activa
│   │   ├── Clock.qml      # Reloj digital
│   │   ├── Battery.qml   # Indicador de batería
│   │   └── Wifi.qml      # Indicador de WiFi
│   ├── popups/            # Menús emergentes
│   │   ├── WifiMenu.qml   # Menú de WiFi
│   │   └── Power.qml      # Menú de energía
│   ├── widgets/           # Widgets independientes
│   │   ├── ClockWidget.qml
│   │   └── PowerMenu.qml
│   └── animations/
│       └── AnimatedReveal.qml # Animaciones de aparición
├── services/              # Servicios del sistema
│   ├── BrightnessPopup.qml
│   └── VolumePopup.qml
└── dev/                   # Herramientas de desarrollo
    ├── DevBox.qml
    ├── DevReadJson.qml
    └── DevPopup.qml
```

## Sistema de Temas

El tema se define en un archivo JSON con formato Base16. El archivo `config/theme/Colors.qml` es un Singleton que:

1. Lee `current.json` (enlace simbólico a un tema en `system-themes/themes/`)
2. Expone los colores como propiedades globales `Colors.palette.base00` - `Colors.palette.base0F`
3. Observa cambios en el archivo y recarga automáticamente

### Paleta Base16

| Clave    | Uso típico              |
|----------|------------------------|
| base00   | Fondo principal        |
| base01   | Fondo alternativo     |
| base02   | Fondo sutil            |
| base03   | Comentarios/sutil      |
| base04   | Texto secundario       |
| base05   | Texto principal        |
| base06   | Texte destacado        |
| base07   | Texte en claro         |
| base08   | Rojo (errores)         |
| base09   | Naranja (warnings)    |
| base0A   | Amarillo               |
| base0B   | Verde                  |
| base0C   | Cian                   |
| base0D   | Azul                   |
| base0E   | Púrpura                |
| base0F   | Magenta                |

## IPC

El shell expone un handler IPC llamado `colores` que permite recargar el tema:

```bash
quickshell ipc call colores recargar
```

Esto se utiliza desde `apply-theme.sh` en los dotfiles al cambiar de tema.

## Componentes Principales

### LeftBar

Panel lateral que contiene:
- **Workspaces**: Iconos de workspaces activos
- **Window**: Miniatura de la ventana enfocada
- **Clock**: Reloj con formato HH:MM
- **Battery**: Indicador de batería con popup
- **Wifi**: Indicador de conexión con popup

Cada componente que tiene popup crea un `PopupWindow` separado con `AnimatedReveal` para animaciones suaves.

## Desarrollo

Los archivos en `dev/` son herramientas de desarrollo y prueba:
- `DevBox.qml`: Caja de pruebas
- `DevReadJson.qml`: Lector de JSON de desarrollo
- `DevPopup.qml`: Popup de desarrollo

## Dependencias

- Quickshell
- QtQuick 2.15
- Sistema de temas Base16 (generado por los scripts de dotfiles)