#!/usr/bin/env python3
"""
Script para convertir texto con acordes a un documento .docx con formato profesional.
Mejoras:
- Ruta de salida personalizable (absoluta o relativa)
- Corrección en la aplicación del estilo "Acorde"
- Interlineado sencillo (sin espacios extra)
"""
"""
Mejoras necesarias:
    - No eliminar: coro x1 y variantess
    - Eliminar lineas en blanco (pueden ser producto del punto anterior)
"""

import sys
import subprocess
import re
import os
from pathlib import Path
from docxtpl import DocxTemplate
from docx.shared import Pt
from docx.enum.text import WD_LINE_SPACING

# ------------------------------------------------------------
# CONFIGURACIÓN - AJUSTA SEGÚN TU PLANTILLA
# ------------------------------------------------------------
# PLANTILLA_PATH = "plantilla.docx"  # Ruta a tu plantilla
PLANTILLA_PATH = "/home/carlosm/Piano/Template.docx"  # Ruta a tu archivo plantilla.docx
ESTILO_ACORDE = "Acorde"           # Nombre exacto del estilo de carácter
PATH_OUTPUT = "/home/carlosm/Piano/"
# ------------------------------------------------------------
# def es_linea_acordes(linea):
#     tokens = linea.strip().split()
#     if not tokens:
#         return False
#     valid = 0
#     for t in tokens:
#         if re.match(r'^[A-G][#b]?(m|maj7|sus4|dim|aug)?\d*$', t):
#             valid += 1
#     return valid / len(tokens) > 0.4
#
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
    
    return porcentaje > 0.4

def limpiar_texto_entrada(texto):
    lineas = texto.splitlines()
    # print("lineas.plitlines", lineas)

    patrones_ruido = [
        r'^\d+(\.\d+)?/\d+',   # rating
        r'^\d+$',              # números
        r'enviado por',
        r'corregir',
        r'desconocido',
        r'^[a-z0-9]{6,}$',
    ]

    lineas_limpias = []
    ignorar = False
    patron_ruido = re.compile("|".join(patrones_ruido), re.IGNORECASE)
    print("patrones_ruido", patron_ruido)

    for linea in lineas:
        l = linea.strip()

        # detectar inicio real de canción
        if re.match(r'(?i)^(intro|estrofa|verso|coro|precoro|puente)', l):
            ignorar = True

        if ignorar:
            # conservar solo primeras 2 líneas útiles (título + artista)
            if l and not patron_ruido.search(l):
                lineas_limpias.append(l)
            continue

        # ya estamos en contenido real
        if not patron_ruido.search(l):
            lineas_limpias.append(linea)

    return "\n".join(lineas_limpias)

def obtener_portapapeles():
    try:
        resultado = subprocess.run(['wl-paste', '-p'], capture_output=True, text=True, check=True)
        return resultado.stdout
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Error encontrando wl-paste -p")
        sys.exit(1)

def parsear_cancion(texto):
    """Parsea el texto plano de una canción con acordes."""
    lineas = texto.strip().splitlines()
    print("Lineas:", lineas)
    if not lineas:
        return None

    # Título y artista
    titulo_linea = lineas[0].strip()
    titulo = titulo_linea
    artista = lineas[1].strip()
    
    match = re.search(r'\(([^)]+)\)$', titulo_linea)
    if match:
        artista = match.group(1).strip()
        titulo = re.sub(r'\s*\([^)]+\)$', '', titulo_linea).strip()
    else:
        match = re.search(r'[-–—]\s*(.+)$', titulo_linea)
        if match:
            artista = match.group(1).strip()
            titulo = re.sub(r'\s*[-–—]\s*.+$', '', titulo_linea).strip()

    # Secciones
    secciones = []
    seccion_actual = {"name": "", "lines": []}
    patron_seccion = re.compile(r'^(ESTROFA|CORO|PRECORO|PUENTE|INTRO|OUTRO|VERSO|REFRÁN|ESTRIBILLO)(?:\s+(\d+))?', re.IGNORECASE)

    i = 1
    while i < len(lineas):
        # linea = lineas[i].strip()
        linea = lineas[i].rstrip("\n")  # NO strip()
        if not linea:
            if seccion_actual["name"] or seccion_actual["lines"]:
                secciones.append(seccion_actual)
                seccion_actual = {"name": "", "lines": []}
            i += 1
            continue

        match_sec = patron_seccion.match(linea.upper())
        if match_sec:
            if seccion_actual["name"] or seccion_actual["lines"]:
                secciones.append(seccion_actual)
            nombre_base = match_sec.group(1).capitalize()
            numero = match_sec.group(2)
            nombre_seccion = f"{nombre_base} {numero}" if numero else nombre_base
            seccion_actual = {"name": nombre_seccion, "lines": []}
            i += 1
            continue

        # Detectar línea de acordes (mayúsculas, espacios, slashes, números, #, b)
        es_linea_a = esLineaAcordes(linea)

        if es_linea_a:
            # print(f"Acordes:{linea}")

            # acordes = linea
            acordes = linea.replace(" ", "\u00A0")
            letra = ""
            if i + 1 < len(lineas) and lineas[i+1].strip():
                letra = lineas[i+1].strip()
                i += 1
            seccion_actual["lines"].append({"chords": acordes, "lyrics": letra})
        else:
            seccion_actual["lines"].append({"chords": "", "lyrics": linea})
        i += 1

    if seccion_actual["name"] or seccion_actual["lines"]:
        secciones.append(seccion_actual)

    if not secciones:
        secciones = [{"name": "", "lines": []}]
        for linea in lineas[1:]:
            if linea.strip():
                secciones[0]["lines"].append({"chords": "", "lyrics": linea.strip()})

    return {
        "title": titulo,
        "artist": artista,
        "sections": secciones
    }

def generar_docx(datos, salida, plantilla_path):
    """Genera el archivo .docx aplicando el estilo correcto a los acordes."""
    if not Path(plantilla_path).exists():
        print(f"Error: No se encontró la plantilla en '{plantilla_path}'")
        sys.exit(1)

    # Crear directorio de salida si no existe
    Path(salida).parent.mkdir(parents=True, exist_ok=True)

    doc = DocxTemplate(plantilla_path)
    
    # Construir contexto para la plantilla
    context = {
        "title": datos["title"],
        "artist": datos["artist"] if datos["artist"] else "",
        "sections": []
    }

    for sec in datos["sections"]:
        lines_data = []
        for line in sec["lines"]:
            if line["chords"]:
               lines_data.append({
                "chords": line["chords"],
                "lyrics": line["lyrics"]
                }) 
        context["sections"].append({
            "name": sec["name"],
            "lines": lines_data
        })

    # Renderizar y guardar
    doc.render(context)
    doc.save(salida)
    print(f"✅ Documento generado: {os.path.abspath(salida)}")

def ajustar_interlineado(docx_path):
    """
    Post-procesamiento para ajustar el interlineado a sencillo.
    Esto asegura que no haya espacios extra entre líneas.
    """
    from docx import Document
    
    doc = Document(docx_path)
    
    for paragraph in doc.paragraphs:
        # Configurar interlineado sencillo
        # paragraph.paragraph_format.line_spacing = Pt(12)  # 12pt = sencillo
        paragraph.paragraph_format.line_spacing_rule = WD_LINE_SPACING.SINGLE
        paragraph.paragraph_format.space_before = Pt(0)
        paragraph.paragraph_format.space_after = Pt(0)
    
    # Guardar con el mismo nombre
    doc.save(docx_path)
    print("   📏 Interlineado ajustado a sencillo")

def main():

    print("📋 Leyendo texto del portapapeles...")
    texto = obtener_portapapeles()
    if not texto.strip():
        print("Error: No hay texto en el portapapeles.")
        sys.exit(1)
    print(texto)

    print("Limpiando texto...")
    texto = limpiar_texto_entrada(texto)
    print(texto)

    print("✍️  Parseando canción...")
    datos_cancion = parsear_cancion(texto)
    if not datos_cancion:
        print("Error: No se pudo parsear el texto.")
        sys.exit(1)

    print(f"   Título: {datos_cancion['title']}")
    if datos_cancion['artist']:
        print(f"   Artista: {datos_cancion['artist']}")
    print(f"   Secciones: {len(datos_cancion['sections'])}")

        # Procesar argumento de salida
    if PATH_OUTPUT:
        # salida = sys.argv[1]
        salida = PATH_OUTPUT
        if datos_cancion['artist']:
            salida  += datos_cancion['title'].replace(" ", "-")
        if datos_cancion['artist']:
            salida += "-"
            salida += datos_cancion['artist'].replace(" ", "-")
        if not salida.endswith('.docx'):
            salida += '.docx'
    else:
        salida = "/home/carlosm/Piano/cancion_generada.docx"
    # print(f"salida{salida}")

    print("📄 Generando documento...")
    generar_docx(datos_cancion, salida, PLANTILLA_PATH)

    print("🔧 Ajustando formato...")
    ajustar_interlineado(salida)

    subprocess.run(['notify-send', 'Canción generada:', salida])


    print("✨ ¡Listo!")

if __name__ == "__main__":
    main()
