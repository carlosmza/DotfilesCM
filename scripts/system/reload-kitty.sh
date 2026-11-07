#!/usr/bin/env bash
# Script para recargar todas las instancias de kitty con SIGUSR1
# Autor: Carlos Octavio Mendoza Jimenez
# Versión: 1.1
#
# Contrato de salida (se llama desde apply-theme.sh con `set -e`):
#   exit 0 = nada que recargar o recarga parcial → el flujo de cambio de tema continúa
#   exit 1 = había instancias y ninguna pudo recargarse

# Verificar que kitty está instalado
if ! command -v kitty &> /dev/null; then
    echo "Aviso: kitty no está instalado — nada que recargar."
    exit 0
fi

# Obtener todos los PIDs de kitty usando pgrep
KITTY_PIDS=$(pgrep -x kitty || true)

# Sin instancias en ejecución no es un error (nada que recargar)
if [[ -z "$KITTY_PIDS" ]]; then
    echo "Aviso: no hay instancias de kitty en ejecución — nada que recargar."
    exit 0
fi

# Contar número de instancias
NUM_INSTANCES=$(echo "$KITTY_PIDS" | wc -l)

echo "🔄 Recargando ${NUM_INSTANCES} instancia(s) de kitty..."

# Recargar todas las instancias
RELOADED=0
for PID in $KITTY_PIDS; do
    # Verificar que el proceso aún existe
    if kill -0 $PID 2>/dev/null; then
        # Enviar señal SIGUSR1 para recargar configuración
        if kill -SIGUSR1 $PID 2>/dev/null; then
            echo "  ✅ Instancia PID $PID recargada correctamente"
            RELOADED=$((RELOADED + 1))
        else
            echo "  ⚠️  Error recargando PID $PID"
        fi
    else
        echo "  ⚠️  PID $PID ya no existe (proceso finalizado)"
    fi
done

# Resumen final
echo ""
echo "📊 Resumen: ${RELOADED}/${NUM_INSTANCES} instancias recargadas exitosamente"

if [[ "$RELOADED" -eq 0 ]]; then
    echo "❌ Error: no se pudo recargar ninguna instancia de kitty" >&2
    exit 1
fi

exit 0
