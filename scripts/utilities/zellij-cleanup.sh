#!/usr/bin/env bash

# Script para limpiar sesiones de Zellij auto-generadas (patrón word-random)
# Mantiene sesiones con nombre manual (patrón Nombre-Sesion)

LOG_FILE="/home/carlosm/.local/log/zellij-cleanup.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Iniciando limpieza de sesiones Zellij auto-generadas..."

# Obtener lista de sesiones sin formato
SESSIONS=$(zellij list-sessions --no-formatting 2>/dev/null)

if [ -z "$SESSIONS" ] || [ "$SESSIONS" = "No active sessions" ]; then
    log "No hay sesiones activas para limpiar."
    exit 0
fi

log "Sesiones encontradas:"
echo "$SESSIONS" | while IFS= read -r line; do
    log "  - $line"
done

# Patrón para sesiones auto-generadas: word-random (minúsculas, guión, minúsculas)
# Patrón para mantener: Nombre-Sesion (capitalizado, guión, capitalizado)
DELETED_COUNT=0
KEPT_COUNT=0

while IFS= read -r line; do
    # Extraer nombre de sesión (primera columna)
    SESSION_NAME=$(echo "$line" | awk '{print $1}')
    
    if [[ -z "$SESSION_NAME" ]]; then
        continue
    fi
    
    # Verificar si es sesión auto-generada (palabra-minúscula-guión-palabra-minúscula)
    if [[ "$SESSION_NAME" =~ ^[a-z]+-[a-z]+$ ]]; then
        log "Eliminando sesión auto-generada: $SESSION_NAME"
        if zellij delete-session --force "$SESSION_NAME" 2>/dev/null; then
            log "  -> Eliminada correctamente"
            ((DELETED_COUNT++))
        else
            log "  -> Error al eliminar"
        fi
    else
        log "Manteniendo sesión manual: $SESSION_NAME"
        ((KEPT_COUNT++))
    fi
done < <(echo "$SESSIONS" | tail -n +2)

log "Limpieza completada. Eliminadas: $DELETED_COUNT, Mantenidas: $KEPT_COUNT"