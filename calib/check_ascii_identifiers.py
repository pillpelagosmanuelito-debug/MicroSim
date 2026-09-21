"""
Verifica que ningun identificador/palabra clave de Dart en lib/ o test/
contenga caracteres no-ASCII (tildes, enies, etc.). Las tildes son
correctas SOLO dentro de strings y comentarios (texto en espanol que el
usuario ve), nunca en nombres de clases/variables/funciones -- un
identificador con tilde no compila.

Leccion aplicada del post-mortem de CircuitLab Academy (ver
docs/03_Arquitectura_Tecnica.md): "Los identificadores de Dart deben
ser ASCII... conviene verificarlo con un script antes de entregar."
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CARPETAS = ['lib', 'test']


def quitar_strings_y_comentarios(codigo):
    resultado = []
    i = 0
    n = len(codigo)
    while i < n:
        c = codigo[i]
        # comentario de linea
        if c == '/' and i + 1 < n and codigo[i + 1] == '/':
            while i < n and codigo[i] != '\n':
                i += 1
            continue
        # comentario de bloque
        if c == '/' and i + 1 < n and codigo[i + 1] == '*':
            i += 2
            while i + 1 < n and not (codigo[i] == '*' and codigo[i + 1] == '/'):
                i += 1
            i += 2
            continue
        # string triple-quoted '''...''' (usado en sample_programs.dart)
        if codigo[i:i + 3] == "'''":
            i += 3
            while codigo[i:i + 3] != "'''" and i < n:
                i += 1
            i += 3
            continue
        # string simple o doble
        if c in ('"', "'"):
            quote = c
            i += 1
            while i < n and codigo[i] != quote:
                if codigo[i] == '\\':
                    i += 1
                i += 1
            i += 1
            continue
        resultado.append(c)
        i += 1
    return ''.join(resultado)


def revisar_archivo(path):
    with open(path, encoding='utf-8') as f:
        codigo = f.read()
    sin_strings = quitar_strings_y_comentarios(codigo)
    no_ascii = [ch for ch in sin_strings if ord(ch) > 127]
    return no_ascii


def main():
    problemas = []
    for carpeta in CARPETAS:
        base = os.path.join(ROOT, carpeta)
        for dirpath, _, files in os.walk(base):
            for fn in files:
                if not fn.endswith('.dart'):
                    continue
                path = os.path.join(dirpath, fn)
                no_ascii = revisar_archivo(path)
                if no_ascii:
                    problemas.append((path, no_ascii))

    if problemas:
        print('SE ENCONTRARON CARACTERES NO-ASCII FUERA DE STRINGS/COMENTARIOS:')
        for path, chars in problemas:
            rel = os.path.relpath(path, ROOT)
            print(f'  - {rel}: {chars}')
        sys.exit(1)
    else:
        total = sum(
            len(files)
            for carpeta in CARPETAS
            for _, _, files in os.walk(os.path.join(ROOT, carpeta))
        )
        print(f'OK: ningun identificador con caracteres no-ASCII (revisados {total} archivos/entradas en lib/ y test/).')


if __name__ == '__main__':
    main()
