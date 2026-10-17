#!/usr/bin/env python3
"""Comprueba que la edición en inglés (en/modules/) sigue a la española (modulos/).

Empareja los módulos por su número (NN-…) y, en cada pareja, compara lo que
no cambia al traducir: los títulos (nivel y numeración «N.M»), el número de
bloques de código de cada lenguaje, el número de diagramas y los hashes de
los commits, que son los mismos en los dos idiomas. Si algo no coincide, lo
muestra y termina con error. No revisa el texto: sirve para detectar
apartados, salidas o diagramas que faltan o sobran en la traducción.

Uso: scripts/comprobar-traduccion.py (desde cualquier carpeta)
"""

import re
import sys
from collections import Counter
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
ES = RAIZ / "modulos"
EN = RAIZ / "en" / "modules"

APERTURA = re.compile(r"^(`{3,})(.*)$")
TITULO = re.compile(r"^(#{1,6})\s+(\S+)")
HASH = re.compile(r"\b[0-9a-f]{7}\b")


def analizar(fichero):
    """Devuelve los títulos, los bloques por lenguaje y los hashes."""
    titulos, bloques, hashes = [], Counter(), Counter()
    cierre = None
    for linea in fichero.read_text(encoding="utf-8").splitlines():
        hashes.update(HASH.findall(linea))
        if cierre:
            if linea.strip() == cierre:
                cierre = None
            continue
        abre = APERTURA.match(linea)
        if abre:
            cierre = abre.group(1)
            info = abre.group(2).strip()
            # ```{.dot caption="…"} es un diagrama; ```bash, un bloque bash
            lenguaje = re.match(r"\{?\.?([\w-]*)", info).group(1) or "(sin lenguaje)"
            bloques[lenguaje] += 1
            continue
        titulo = TITULO.match(linea)
        if titulo:
            nivel, primera = titulo.groups()
            # Se compara la numeración (2.1, 3.2.1); los títulos sin número
            # (los de nivel 1 y los de los anexos) sólo cuentan por su nivel.
            numero = primera if re.fullmatch(r"\d+(\.\d+)*", primera) else ""
            titulos.append(f"{nivel} {numero}".strip())
    return titulos, bloques, hashes


def por_numero(carpeta):
    return {f.name[:2]: f for f in sorted(carpeta.glob("[0-9][0-9]-*.md"))}


def main():
    es, en = por_numero(ES), por_numero(EN)
    errores = []
    for numero in sorted(es.keys() | en.keys()):
        if numero not in en:
            errores.append(f"{es[numero].name}: falta la traducción en en/modules/")
            continue
        if numero not in es:
            errores.append(f"{en[numero].name}: no tiene módulo en español")
            continue
        pareja = f"{es[numero].name} ↔ {en[numero].name}"
        t_es, b_es, h_es = analizar(es[numero])
        t_en, b_en, h_en = analizar(en[numero])
        if t_es != t_en:
            errores.append(f"{pareja}: los títulos no coinciden\n  es: {t_es}\n  en: {t_en}")
        if b_es != b_en:
            errores.append(f"{pareja}: los bloques de código no coinciden\n  es: {dict(b_es)}\n  en: {dict(b_en)}")
        if h_es != h_en:
            faltan = h_es - h_en
            sobran = h_en - h_es
            errores.append(f"{pareja}: los hashes no coinciden\n  faltan en inglés: {dict(faltan)}\n  sobran en inglés: {dict(sobran)}")

    if errores:
        print("La edición en inglés no sigue a la española:\n", file=sys.stderr)
        print("\n".join(errores), file=sys.stderr)
        sys.exit(1)
    print(f"Traducción al día: {len(es)} módulos con la misma estructura en los dos idiomas")


if __name__ == "__main__":
    main()
