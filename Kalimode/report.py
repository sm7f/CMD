import sys
from PIL import Image
from reportlab.pdfgen import canvas

def extract_raster_images(data):
    images = []
    i = 0

    while i < len(data) - 10:
        # GS v 0 (modo raster)
        if data[i] == 0x1D and data[i+1] == 0x76 and data[i+2] == 0x30:
            m = data[i+3]     # modo
            xL = data[i+4]
            xH = data[i+5]
            yL = data[i+6]
            yH = data[i+7]

            width_bytes = xL + (xH << 8)
            height = yL + (yH << 8)
            bitmap_size = width_bytes * height

            start = i + 8
            end = start + bitmap_size

            bitmap = data[start:end]

            # Converter para imagem monocromática
            width_px = width_bytes * 8

            img = Image.frombytes("1", (width_px, height), bitmap)

            # Elgin imprime invertido (branco=1, preto=0)
            img = img.point(lambda p: 255 - p)

            images.append(img)

            i = end
        else:
            i += 1

    return images

def assemble_pdf(images, pdf_path):
    c = canvas.Canvas(pdf_path)

    y_offset = 800

    for img in images:
        img_path = "temp_img.bmp"
        img.save(img_path)

        c.drawImage(img_path, 10, y_offset - img.height)
        y_offset -= img.height + 20

        if y_offset < 0:
            c.showPage()
            y_offset = 800

    c.save()
    print(f"PDF gerado com sucesso: {pdf_path}")

if __name__ == "__main__":
    prn = sys.argv[1]
    pdf = sys.argv[2]

    with open(prn, "rb") as f:
        data = f.read()

    imgs = extract_raster_images(data)

    if not imgs:
        print("Nenhuma imagem raster encontrada! Verifique se o PRN foi capturado corretamente.")
        sys.exit(0)

    assemble_pdf(imgs, pdf)
