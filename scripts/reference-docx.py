#!/usr/bin/env python3
"""Genera el reference.docx del Word a partir del de Pandoc.

Uso: reference-docx.py <salida.docx>

Cambia sobre la plantilla por defecto de Pandoc:

- Página A4, como el PDF, para que la portada ocupe lo mismo en cualquier
  programa.
- Portada parecida a la del PDF (pandoc/portada.lua): el título más abajo,
  el subtítulo con un filete debajo, el autor y, al pie de la página, la
  línea de date con la versión o la fecha.
- Estilos de las entradas del índice (TOC1 a TOC3), que portada.lua rellena
  de antemano.
- Bloques de código como en el PDF (pandoc/estilo-pdf.typ): las órdenes y
  el contenido de ficheros con fondo y filete a la izquierda («Source Code»),
  y las salidas de comandos con un borde fino («Salida», que aplica
  pandoc/codigo-word.lua).
- Número de página centrado al pie, como en el PDF, salvo en la portada,
  que cuenta pero no lo muestra.
- updateFields, para que Word ofrezca actualizar el índice al abrir el
  documento y añada los números de página.
"""

import os
import re
import subprocess
import sys
import zipfile

OSCURO = '1d2733'
GRIS = '4a5b70'

# Medidas en veinteavos de punto (twips) y tamaños en medios puntos
ESTILOS = {
    'Title': f'''<w:style w:type="paragraph" w:styleId="Title">
    <w:name w:val="Title" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" />
    <w:link w:val="TitleChar" /><w:uiPriority w:val="10" /><w:qFormat />
    <w:pPr><w:spacing w:before="3400" w:after="120" w:line="240" w:lineRule="auto" /><w:jc w:val="left" /></w:pPr>
    <w:rPr><w:rFonts w:asciiTheme="majorHAnsi" w:eastAsiaTheme="majorEastAsia" w:hAnsiTheme="majorHAnsi" w:cstheme="majorBidi" />
    <w:b /><w:bCs /><w:color w:val="{OSCURO}" /><w:sz w:val="60" /><w:szCs w:val="60" /></w:rPr>
  </w:style>''',
    'Subtitle': f'''<w:style w:type="paragraph" w:styleId="Subtitle">
    <w:name w:val="Subtitle" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" />
    <w:link w:val="SubtitleChar" /><w:uiPriority w:val="11" /><w:qFormat />
    <w:pPr><w:pBdr><w:bottom w:val="single" w:sz="12" w:space="10" w:color="{GRIS}" /></w:pBdr>
    <w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto" /><w:jc w:val="left" /></w:pPr>
    <w:rPr><w:color w:val="{GRIS}" /><w:sz w:val="30" /><w:szCs w:val="30" /></w:rPr>
  </w:style>''',
    'Author': f'''<w:style w:type="paragraph" w:customStyle="1" w:styleId="Author">
    <w:name w:val="Author" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:qFormat />
    <w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="0" w:after="0" /><w:jc w:val="left" /></w:pPr>
    <w:rPr><w:color w:val="{GRIS}" /><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr>
  </w:style>''',
    'Date': f'''<w:style w:type="paragraph" w:styleId="Date">
    <w:name w:val="Date" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:qFormat />
    <w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="6000" w:after="0" /><w:jc w:val="left" /></w:pPr>
    <w:rPr><w:color w:val="{GRIS}" /><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr>
  </w:style>''',
}

# Entradas del índice: los módulos en negrita y los apartados sangrados
INDICE = ''.join(f'''<w:style w:type="paragraph" w:styleId="TOC{n}">
    <w:name w:val="toc {n}" /><w:basedOn w:val="Normal" /><w:next w:val="Normal" />
    <w:uiPriority w:val="39" /><w:unhideWhenUsed />
    <w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9016" /></w:tabs>
    <w:spacing w:before="{120 if n == 1 else 0}" w:after="60" /><w:ind w:left="{(n - 1) * 360}" /></w:pPr>
    <w:rPr>{'<w:b /><w:bCs />' if n == 1 else ''}</w:rPr>
  </w:style>''' for n in (1, 2, 3))

# Bloques de código, con los colores de estilo-pdf.typ. Los bordes del color
# del fondo (o blancos) dejan margen por dentro, arriba, abajo y a la derecha.
CODIGO_FONDO = 'f3f6fa'
CODIGO_FILETE = GRIS
SALIDA_BORDE = 'c5ced8'


def bloque(id_, nombre, bordes, fondo=''):
    return f'''<w:style w:type="paragraph" w:customStyle="1" w:styleId="{id_}">
    <w:name w:val="{nombre}" /><w:basedOn w:val="Normal" /><w:link w:val="VerbatimChar" />
    <w:pPr><w:wordWrap w:val="off" /><w:pBdr>{bordes}</w:pBdr>{fondo}
    <w:spacing w:before="220" w:after="260" w:line="240" w:lineRule="auto" /><w:ind w:left="200" w:right="140" /></w:pPr>
  </w:style>'''


CODIGO = (
    bloque('SourceCode', 'Source Code',
           f'<w:top w:val="single" w:sz="4" w:space="5" w:color="{CODIGO_FONDO}" />'
           f'<w:left w:val="single" w:sz="20" w:space="8" w:color="{CODIGO_FILETE}" />'
           f'<w:bottom w:val="single" w:sz="4" w:space="5" w:color="{CODIGO_FONDO}" />'
           f'<w:right w:val="single" w:sz="4" w:space="6" w:color="{CODIGO_FONDO}" />',
           f'<w:shd w:val="clear" w:color="auto" w:fill="{CODIGO_FONDO}" />')
    + bloque('Salida', 'Salida',
             ''.join(f'<w:{lado} w:val="single" w:sz="5" w:space="{espacio}" w:color="{SALIDA_BORDE}" />'
                     for lado, espacio in (('top', 5), ('left', 8), ('bottom', 5), ('right', 6))))
)

# A4 con márgenes de 2,54 cm. El pie normal lleva el número de página y el
# de la primera página (titlePg), que es la portada, va vacío.
PAGINA = ('<w:sectPr><w:footerReference w:type="default" r:id="rIdPiePagina" />'
          '<w:footerReference w:type="first" r:id="rIdPiePortada" />'
          '<w:pgSz w:w="11906" w:h="16838" />'
          '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"'
          ' w:header="708" w:footer="708" w:gutter="0" /><w:titlePg /></w:sectPr>')

PIE = ('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
       '<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:p>'
       '<w:pPr><w:jc w:val="center" /></w:pPr>{}</w:p></w:ftr>')
NUMERO = (f'<w:r><w:rPr><w:color w:val="{GRIS}" /><w:sz w:val="20" /></w:rPr><w:fldChar w:fldCharType="begin" /></w:r>'
          '<w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
          '<w:r><w:fldChar w:fldCharType="separate" /></w:r>'
          f'<w:r><w:rPr><w:color w:val="{GRIS}" /><w:sz w:val="20" /></w:rPr><w:t>1</w:t></w:r>'
          '<w:r><w:fldChar w:fldCharType="end" /></w:r>')
PIES = {
    'word/footer1.xml': ('rIdPiePagina', PIE.format(NUMERO)),
    'word/footer2.xml': ('rIdPiePortada', PIE.format('')),
}
TIPO_PIE = 'application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml'
RELACION_PIE = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer'


def estilos(xml):
    for id_, estilo in ESTILOS.items():
        patron = re.compile(rf'<w:style [^>]*w:styleId="{id_}".*?</w:style>', re.S)
        xml, n = patron.subn(lambda _: estilo, xml)
        if n != 1:
            sys.exit(f'Error: el estilo {id_} no está en el reference.docx de Pandoc')
    return xml.replace('</w:styles>', INDICE + CODIGO + '</w:styles>')


def ajustes(xml):
    # updateFields va antes de footnotePr, endnotePr, compat y rsids
    return re.sub(r'(<w:(?:footnotePr|endnotePr|compat|rsids)\b)',
                  r'<w:updateFields w:val="true" />\1', xml, count=1)


def documento(xml):
    xml = re.sub(r'<w:sectPr\b.*?</w:sectPr>', '', xml, flags=re.S)
    return xml.replace('</w:body>', PAGINA + '</w:body>')


def tipos(xml):
    nuevos = ''.join(f'<Override PartName="/{f}" ContentType="{TIPO_PIE}" />' for f in PIES)
    return xml.replace('</Types>', nuevos + '</Types>')


def relaciones(xml):
    nuevas = ''.join(f'<Relationship Type="{RELACION_PIE}" Id="{id_}" Target="{f.removeprefix("word/")}" />'
                     for f, (id_, _) in PIES.items())
    return xml.replace('</Relationships>', nuevas + '</Relationships>')


CAMBIOS = {
    'word/styles.xml': estilos,
    'word/settings.xml': ajustes,
    'word/document.xml': documento,
    '[Content_Types].xml': tipos,
    'word/_rels/document.xml.rels': relaciones,
}


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    salida = sys.argv[1]
    original = salida + '.pandoc'
    subprocess.run(['pandoc', '-o', original, '--print-default-data-file', 'reference.docx'], check=True)
    with zipfile.ZipFile(original) as zin, zipfile.ZipFile(salida, 'w', zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            datos = zin.read(item)
            if item.filename in CAMBIOS:
                datos = CAMBIOS[item.filename](datos.decode('utf-8')).encode('utf-8')
            zout.writestr(item, datos)
        for fichero, (_, contenido) in PIES.items():
            zout.writestr(fichero, contenido)
    os.remove(original)


if __name__ == '__main__':
    main()
