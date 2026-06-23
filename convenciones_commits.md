# Convenciones de Commits (Conventional Commits)

Este documento sirve como referencia rápida para la estandarización de los mensajes de commit en los repositorios de Git. Basado en la especificación de Conventional Commits.

## Estructura General

<tipo>(<alcance opcional>): <descripción corta en presente/imperativo>

[Cuerpo del mensaje - Opcional]

[Pie de página - Opcional]

---

## Tipos de Commits Principales (Afectan la versión del software)

* feat:     Añadir una nueva característica o funcionalidad al sistema (Incremento MINOR).
* fix:      Corregir un error (bug) en el código (Incremento PATCH).

## Tipos de Commits Secundarios (Mantenimiento y desarrollo)

* docs:     Cambios exclusivos en la documentación (ej. README.md, comentarios del código).
* style:    Cambios de formato que no afectan el significado del código (espacios, sangrías, punto y coma, etc.).
* refactor: Modificaciones al código que no corrigen errores ni añaden funcionalidades (optimización interna).
* perf:     Cambios en el código orientados estrictamente a mejorar el rendimiento/velocidad.
* test:     Añadir nuevos tests o corregir pruebas unitarias/de integración existentes.
* build:    Cambios que afectan al sistema de construcción o dependencias externas (ej. config de npm, poetry, make).
* ci:       Modificaciones en archivos y scripts de configuración de Integración/Despliegue Continuo (ej. GitHub Actions).
* chore:    Tareas rutinarias o de administración que no alteran el código de producción ni los tests (ej. .gitignore).

---

## Reglas de Oro y Buenas Prácticas

1. Modo Imperativo: Escribir la descripción como si fuera una orden (ej. 'feat: add filter' en lugar de 'added filter').
2. Minúsculas: Comenzar la descripción corta con minúscula justo después del espacio posterior a los dos puntos.
3. Brevedad: Intentar que la primera línea no supere los 50-72 caracteres.
4. Cambios de Ruptura (Breaking Changes): Agregar un signo de exclamación antes de los dos puntos si el cambio rompe la compatibilidad (ej. 'feat!: change auth system').
