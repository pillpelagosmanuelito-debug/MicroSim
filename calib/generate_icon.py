"""
Genera el icono de MicroSim: un chip/microcontrolador con pines,
sobre una placa oscura, con una pista de cobre cian y un LED indicador
ambar encendido -- siguiendo la paleta de lib/theme/app_theme.dart.
No reutiliza ningun icono de las apps anteriores de la fabrica.
"""
from PIL import Image, ImageDraw

SIZE = 1024
PLACA_OSCURA = (13, 17, 23, 255)
PLACA_PANEL = (22, 27, 34, 255)
CIAN = (88, 211, 247, 255)
AMBAR = (255, 194, 75, 255)
VERDE = (63, 224, 143, 255)

img = Image.new("RGBA", (SIZE, SIZE), PLACA_OSCURA)
draw = ImageDraw.Draw(img)

# Pistas de cobre de fondo (lineas finas tipo PCB)
paso = 128
for x in range(paso, SIZE, paso):
    draw.line([(x, 0), (x, SIZE)], fill=(*CIAN[:3], 18), width=3)
for y in range(paso, SIZE, paso):
    draw.line([(0, y), (SIZE, y)], fill=(*CIAN[:3], 18), width=3)

# Cuerpo del chip (cuadrado central redondeado)
margen = 300
draw.rounded_rectangle(
    [margen, margen, SIZE - margen, SIZE - margen],
    radius=40,
    fill=PLACA_PANEL,
    outline=CIAN,
    width=8,
)

# Pines alrededor del chip (arriba/abajo/izq/der)
n_pines = 5
pin_largo = 70
pin_grosor = 14
inicio = margen + 40
fin = SIZE - margen - 40
paso_pin = (fin - inicio) / (n_pines - 1)

for i in range(n_pines):
    x = inicio + i * paso_pin
    # arriba
    draw.rectangle([x - pin_grosor / 2, margen - pin_largo, x + pin_grosor / 2, margen], fill=CIAN)
    # abajo
    draw.rectangle([x - pin_grosor / 2, SIZE - margen, x + pin_grosor / 2, SIZE - margen + pin_largo], fill=CIAN)
    y = inicio + i * paso_pin
    # izquierda
    draw.rectangle([margen - pin_largo, y - pin_grosor / 2, margen, y + pin_grosor / 2], fill=CIAN)
    # derecha
    draw.rectangle([SIZE - margen, y - pin_grosor / 2, SIZE - margen + pin_largo, y + pin_grosor / 2], fill=CIAN)

# Nucleo interior (representa la CPU) con un LED indicador ambar
nucleo_margen = margen + 130
draw.rounded_rectangle(
    [nucleo_margen, nucleo_margen, SIZE - nucleo_margen, SIZE - nucleo_margen],
    radius=20,
    fill=PLACA_OSCURA,
    outline=(*VERDE[:3], 160),
    width=4,
)

# LED indicador (circulo ambar con resplandor) en la esquina del nucleo
led_cx = SIZE - nucleo_margen - 60
led_cy = nucleo_margen + 60
led_r = 34
draw.ellipse(
    [led_cx - led_r - 14, led_cy - led_r - 14, led_cx + led_r + 14, led_cy + led_r + 14],
    fill=(*AMBAR[:3], 70),
)
draw.ellipse([led_cx - led_r, led_cy - led_r, led_cx + led_r, led_cy + led_r], fill=AMBAR)

img.save("/home/claude/build/microsim/assets/icon/icon.png")
print("Icono generado:", img.size)
