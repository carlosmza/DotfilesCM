#!/bin/bash
# Script para recargar todas las instancias de kitty con SIGUSR1
# Autor: Carlos Octavio Mendoza Jimenez
# Versión: 1.0

# Verificar que kitty está instalado
if ! command -v kitty &> /dev/null; then
    echo "❌ Error: kitty no está instalado o no está en PATH"
    exit 1
fi

# Obtener todos los PIDs de kitty usando pgrep
KITTY_PIDS=$(pgrep -x kitty)

# Verificar si hay instancias de kitty
if [ -z "$KITTY_PIDS" ]; then
    echo "❌ No hay instancias de kitty ejecutadas"
    exit 1
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
            ((RELOADED++))
        else
            echo "  ❌ Error recargando PID $PID"
        fi
    else
        echo "  ⚠️  PID $PID ya no existe (proceso finalizado)"
    fi
done

# Resumen final
echo ""
echo "📊 Resumen: ${RELOADED}/${NUM_INSTANCES} instancias recargadas exitosamente"

if [ $RELOADED -eq $NUM_INSTANCES ]; then
    exit 0
else
    exit 1
fi
