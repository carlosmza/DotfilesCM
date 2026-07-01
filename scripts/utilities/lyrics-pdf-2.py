import re
import subprocess
import sys
import os
from docxtpl import DocxTemplate
from pathlib import Path
from docx.enum.text import WD_LINE_SPACING
from docx.shared import Pt


PATRON_SECCION = re.compile(
    r'^(ESTROFA|CORO|PRECORO|PUENTE|INTRO|OUTRO|VERSO|REFRÁN|ESTRIBILLO|INTERLUDIO|INTERLUDE|INSTRUMENTAL|INTERMEDIO):?\s*(\d+)?',
    re.IGNORECASE
)
# PATRON_INICIO = re.compile(r'intro')

def obtenerPortapapeles():
    try:
        resultado = subprocess.run(['wl-paste', '-p'], capture_output=True, text=True, check=True)
        return resultado.stdout
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Error encontrando wl-paste -p")
        sys.exit(1)

def limpiarTexto(texto):
    lineas = texto.split("\n")
    titulo = "title"
    autor = "autor"
    indx = -1  # Bandera: no encontrado
    
    for i, linea in enumerate(lineas):  # 🎯 Mejor: usa enumerate
        linea_strip = linea.strip()
        if re.search(PATRON_SECCION, linea_strip) or esLineaAcordes(linea):
            print(f"---------------Inicio de la cancion:\n{linea}")
            indx = i
            print(f"indx{indx}")
            break  # Salir apenas encuentres
    
    if indx != -1 and indx != 0:  # Solo si encontró
        print(f"Delete:0-{indx-1}")
        lineas[0:indx-1] = []
    else:
        print("Return lineas noModify")
    
    return lineas, titulo, autor


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

def procesar_a_docx(texto_limpio, titulo, autor, plantilla_path, salida_path):
    datos = {
        "title": titulo,
        "artist": autor,
        "sections": []
    }
    
    current_section = None
    current_lines = []
    current_chords = None
    hay_contenido = False  # Para saber si hubo alguna línea de acordes/letra
    
    for linea in texto_limpio:
        linea_stripped = linea.strip()
        if not linea_stripped:
            continue

        # Detectar sección (con dos puntos opcionales)
        match_seccion = PATRON_SECCION.match(linea_stripped)
        if match_seccion:
            # Guardar sección anterior, vaciando acordes pendientes
            if current_chords is not None:
                current_lines.append({
                    "chords": current_chords,
                    "lyrics": ""
                })
                current_chords = None
            if current_section and current_lines:
                datos["sections"].append({
                    "name": current_section,
                    "lines": current_lines
                })
                current_lines = []
            
            nombre_seccion = match_seccion.group(1)
            numero = match_seccion.group(2)
            current_section = f"{nombre_seccion} {numero}" if numero else nombre_seccion
            current_chords = None
            hay_contenido = True
            continue
        
        # Línea de acordes
        if esLineaAcordes(linea):
            # Si aún no hay sección, creamos una por defecto
            if current_section is None:
                current_section = "Canción"  # Nombre genérico
            if current_chords is not None:
                current_lines.append({
                    "chords": current_chords,
                    "lyrics": ""
                })
            current_chords = linea_stripped
            hay_contenido = True
            continue
        
        # Línea de letra
        if current_section is None:
            # Si llega letra sin sección, creamos sección por defecto
            current_section = "Canción"
        # Si hay acordes pendientes, los agregamos con esta letra
        current_lines.append({
            "chords": current_chords or "",
            "lyrics": linea_stripped
        })
        current_chords = None
        hay_contenido = True

    # Al terminar, guardar acordes pendientes
    if current_chords is not None:
        current_lines.append({
            "chords": current_chords,
            "lyrics": ""
        })
    # Guardar última sección
    if current_section and current_lines:
        datos["sections"].append({
            "name": current_section,
            "lines": current_lines
        })
    
    # Si no se encontró ninguna sección pero hay contenido, crear una sección genérica
    if not datos["sections"] and hay_contenido:
        datos["sections"].append({
            "name": "Canción",
            "lines": current_lines  # current_lines ya debe tener lo recolectado
        })
    
    generar_docx(datos, salida_path, plantilla_path)

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

if __name__ == "__main__":
    plantilla_path = "/home/carlosm/Piano/Template.docx"  # Ruta a tu archivo plantilla.docx

    texto = obtenerPortapapeles()
    print("---------------------texto_limpio:", texto)
    texto_limpio, titulo, autor = limpiarTexto(texto)
    for i, linea in enumerate(texto_limpio):
        temp = linea.strip()
        if re.search(PATRON_SECCION, temp):
            print(f"[:{linea}")
        elif esLineaAcordes(linea):
            print(f"-:{linea}")
        else:
            print(f"{i}:{linea}")
    nombre_archivo = f"{titulo}-{autor}".replace(" ", "-")
    salida_path = f"/home/carlosm/Piano/{nombre_archivo}.docx"
    print("-------------Procesando a docx")
    procesar_a_docx(texto_limpio, titulo, autor, plantilla_path, salida_path)
    ajustar_interlineado(salida_path)
    subprocess.run(['notify-send', 'Canción generada:', salida_path])

