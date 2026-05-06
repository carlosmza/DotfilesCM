# Introducción
Me he encontrado en el punto de querer tener muchos wallpapers y colorschemes en mi SO y tener la opción de cambiar estos de una manera sencilla,
para ello he comenzado teniendo la opción de DARK / LIGHT, esto no ha sido suficiente para mi necesidad de tener muchos colorschemes así que al
enterarme que puedo extraer toda una paleta de colores de un wallpaper he decidido realizar un script el cual lo haga de manera automática y yo solo
tenga que ver que combinación de: (wallpaper - colorschemes - mode) es la que mejor me guste

## Creación de Colorscheme
1. Ingresar un wallpaper a WALLDIR
2. Se generará la paleta de colores correspondiente y se le asignará **mode**
3. Apartir de la paleta de colores se generarán archivos de configuración de cada app:
[x] Rofi
[] Mako
[] Kitty
[] Oh-My-Posh
[] Waybar

## Elección de Elementos
Es importante que la última combinación usada (wallpaper - colorschemes - mode) se carge al reiniciar el SO, existen 3 menús importantes para la
elección de estilo:
[] Wallpaper-Switcher
[] Colorscheme-Switcher
[] Mode-Switcher
    [] Presets-Switcher

### Wallpaper-Switcher
Elegirá el wallpaper deseado sin modificar nada más que la imagen en pantalla

### Colorscheme-Switcher
Elegirá el esquema de colores usado en menús y terminal, no modificará nada más

### Mode-Switcher
Elegirá entre Dark / Light útil para el Navegador Web

#### Presets-Switcher
Será la combinación de Wallpaper-Switcher, Colorscheme-Switcher y Mode-Switcher, al elegir un wallpaper se usará automáticamente su Colorscheme y Mode
correspondientes.
