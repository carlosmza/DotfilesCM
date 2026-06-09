import re

def esLineaAcordes(linea):
    """
    Detecta si una línea contiene acordes (versión mejorada).
    
    Soporta:
    - Acordes simples: A, C#, Dm
    - Extensiones: maj7, sus4, add9, dim, aug
    - Inversiones: E/G#, A/F#
    - Secuencias: B-E-B/G#
    
    Args:
        linea (str): Línea a validar
    
    Returns:
        bool: True si >40% son acordes válidos
    """
    # Normalizar: guiones → espacios
    linea_procesada = linea.replace("-", " ")
    tokens = linea_procesada.strip().split()
    
    if not tokens:
        return False
    
    # 🎯 Regex COMPLETA para acordes modernos
    patron = r'''
        ^[A-G]              # Nota base
        [#b]?               # Accidente (#, b o nada)
        (?:                 # Tipo de acorde (no-capturador)
            m(?:aj[79]|m)?  # m, maj7, maj9, mm (menor menor)
            |maj[79]        # maj7, maj9
            |sus[24]        # sus2, sus4
            |dim|aug|add    # Otros tipos
            |°|Ø|∆          # Símbolos alternativos
        )?
        (?:[0-9]{1,2})?     # Extensión numérica (7, 9, 11, 13)
        (?:\/[A-G][#b]?)?   # Inversión: /nota_bass
        $
    '''
    
    valid = 0
    for token in tokens:
        if not token:  # Ignorar vacíos
            continue
        
        # Usar VERBOSE para regex compleja
        if re.match(patron, token, re.VERBOSE | re.IGNORECASE):
            valid += 1
    
    porcentaje = valid / len([t for t in tokens if t])
    
    return porcentaje > 0.33

PATRON_SECCION = re.compile(
    r'^(ESTROFA|CORO|PRECORO|PUENTE|INTRO|OUTRO|VERSO|REFRÁN|ESTRIBILLO|INTERLUDIO|INTERLUDE)(?:\s+(\d+))?',
    re.IGNORECASE
)

pruebas = [" Intro ", "Interlude ", " Intro: F  - Am - C - G",  "Interlude: C - F  - Am - C - F"]

for i, p in enumerate(pruebas):
    if esLineaAcordes(p):
        print(f"-:{p}")
    elif re.search(PATRON_SECCION, p):
        print(f"[:{p}")
    else:
        print(f"{i}:{p}")

