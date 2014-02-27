from sys import argv
from os.path import basename

from struct import unpack, pack
import zlib
from array import array


def __makeCRCtable():
    global crcTable

    for n in range(256):
        c = n
        for k in range(8):
            if c & 1:
                c = 0xedb88320 ^ (c >> 1)
            else:
                c = c >> 1
        crcTable.append(c)

def __getCRC(data):
    global crcTable

    c = 0xffffffff
    for n in range(len(data)):
        c = crcTable[(c ^ data[n]) & 0xff] ^ (c >> 8)

    return c ^ 0xffffffff

def __unfilterPNGImageData():
    global image_width
    global image_height
    global image_bpp
    global image_data
    global filter_types

    scanline_size = (image_width * image_bpp) >> 3
    scanline_shift = 0
    if image_bpp <= 8:
        a_shift = 1
    else:
        a_shift = image_bpp >> 3

    curr_scanline = [0 for i in range(scanline_size)]
    res = []

    for line in range(image_height):
        scanline = image_data[scanline_shift : scanline_shift + scanline_size + 1]
        scanline_shift += scanline_size + 1

        prev_scanline = curr_scanline
        filter_type = scanline[0]
        curr_scanline = scanline[1:]

        filter_types.append(filter_type)

        for index in range(scanline_size):
            x = curr_scanline[index]

            if filter_type == 0:
                res.append(x)
            elif filter_type == 1:
                if index < a_shift:
                    a = 0
                else:
                    a = curr_scanline[index - a_shift]

                res.append((x + a) % 256)
            elif filter_type == 2:
                b = prev_scanline[index]

                res.append((x + b) % 256)
            elif filter_type == 3:
                if index < a_shift:
                    a = 0
                else:
                    a = curr_scanline[index - a_shift]
                b = prev_scanline[index]

                res.append((x + ((a + b) >> 1)) % 256)
            elif filter_type == 4:
                if index < a_shift:
                    a = 0
                else:
                    a = curr_scanline[index - a_shift]
                b = prev_scanline[index]
                if index < a_shift:
                    c = 0
                else:
                    c = prev_scanline[index - a_shift]

                p = a + b - c
                pa = abs(p - a)
                pb = abs(p - b)
                pc = abs(p - c)

                if pa <= pb and pa <= pc:
                    pr = a
                elif pb <= pc:
                    pr = b
                else:
                    pr = c

                res.append((x + pr) % 256)

    image_data = res

def __filterPNGImageData():
    global image_width
    global image_height
    global image_bpp
    global image_data_remapped
    global filter_types

    scanline_size = (image_width * image_bpp) >> 3
    scanline_shift = 0
    if image_bpp <= 8:
        a_shift = 1
    else:
        a_shift = image_bpp >> 3

    curr_scanline = [0 for i in range(scanline_size)]
    res = array('B')

    for line in range(image_height):
        prev_scanline = curr_scanline
        curr_scanline = image_data_remapped[scanline_shift : scanline_shift + scanline_size]
        scanline_shift += scanline_size

        filter_type = filter_types[line]
        res.append(filter_type)

        for index in range(scanline_size):
            x = curr_scanline[index]

            if filter_type == 0:
                res.append(x)
            elif filter_type == 1:
                if index < a_shift:
                    a = 0
                else:
                    a = curr_scanline[index - a_shift]

                res.append((x - a) % 256)
            elif filter_type == 2:
                b = prev_scanline[index]

                res.append((x - b) % 256)
            elif filter_type == 3:
                if index < a_shift:
                    a = 0
                else:
                    a = curr_scanline[index - a_shift]
                b = prev_scanline[index]

                res.append((x - ((a + b) >> 1)) % 256)
            elif filter_type == 4:
                if index < a_shift:
                    a = 0
                else:
                    a = curr_scanline[index - a_shift]
                b = prev_scanline[index]
                if index < a_shift:
                    c = 0
                else:
                    c = prev_scanline[index - a_shift]

                p = a + b - c
                pa = abs(p - a)
                pb = abs(p - b)
                pc = abs(p - c)

                if pa <= pb and pa <= pc:
                    pr = a
                elif pb <= pc:
                    pr = b
                else:
                    pr = c

                res.append((x - pr) % 256)

    image_data_remapped = res.tobytes()


if __name__ == '__main__':
    argc = len(argv)
    if argc < 3:
        print('Usage: {0} dest_image src_image'.format(basename(argv[0])))
        print('\tdest_image: PNG, indexed-color, no interlace')
        print('\tsrc_image: BMP, 16x16@24bit, truecolor')
        quit(1)


    crcTable = []

    image_width = 0
    image_height = 0
    image_bpp = 0
    image_data = b''
    image_data_remapped = []

    filter_types = []


    print("reading dest image...")
    dest_image = open(argv[1], 'rb')

    signature = dest_image.read(8)
    if signature != b'\x89\x50\x4E\x47\x0D\x0A\x1A\x0A':
        dest_image.close()
        print('dest_image type is not PNG!!')
        quit(2)

    chunkData = dest_image.read(25)[8:17]
    image_width, image_height, image_bpp = unpack('>IIB', chunkData)

    zlibDecompressor = zlib.decompressobj()
    while True:
        preamble = dest_image.read(8)
        chunkLength = unpack('>I', preamble[:4])[0]
        chunkType = preamble[4:]

        tail = dest_image.read(chunkLength + 4)
        chunkData = tail[:chunkLength]

        if chunkType == b'IDAT':
            image_data += zlibDecompressor.decompress(chunkData)
        elif chunkType == b'IEND':
            break
        elif chunkType == b'PLTE':
            old_palette = [unpack('>3B', chunkData[i*3 : i*3 + 3]) for i in range(chunkLength // 3)]

    image_data += zlibDecompressor.flush()
    dest_image.close()

    __unfilterPNGImageData()


    print("reading source image...")
    src_image = open(argv[2], 'rb')

    signature = src_image.read(2)
    if signature != b'BM':
        src_image.close()
        print('src_image type is not BMP!!')
        quit(3)

    src_image.seek(54)
    palette_data = b''

    for i in range(16):
        chunkData = src_image.read(48)
        palette_data = chunkData + palette_data
    src_image.close()

    new_palette = []
    for i in range(256):
        a = list(unpack('<3B', palette_data[i*3 : i*3 + 3]))
        a.reverse()
        new_palette.append(tuple(a))


    print("remapping color indexes...")
    for position in range(len(image_data)):
        color = old_palette[image_data[position]]
        image_data_remapped.append(new_palette.index(color))
    # import random
    # for position in range(len(image_data)):
    #     color = old_palette[image_data[position]]
    #     if color == (255, 255, 255):
    #         index = -1
    #         while index == -1:
    #             try:
    #                 index = new_palette.index(color, random.randrange(256))
    #             except ValueError:
    #                 pass
    #         image_data_remapped.append(index)
    #     else:
    #         image_data_remapped.append(new_palette.index(color))


    print("writing a new image...")
    __filterPNGImageData()
    __makeCRCtable()

    dest_image = open("result.png", 'wb')
    dest_image.write(b'\x89\x50\x4E\x47\x0D\x0A\x1A\x0A')

    chunkData = pack('>IIBBBBB', image_width, image_height, image_bpp, 3, 0, 0, 0)
    dest_image.write(b'\x00\x00\x00\x0DIHDR' + chunkData + __getCRC(b'IHDR' + chunkData).to_bytes(4, byteorder='big'))

    chunkData = array('B')
    for color in new_palette:
        chunkData.extend(color)
    chunkData = b'PLTE' + chunkData.tobytes()
    dest_image.write((len(chunkData) - 4).to_bytes(4, byteorder='big') + chunkData + __getCRC(chunkData).to_bytes(4, byteorder='big'))

    chunkData = b'IDAT' + zlib.compress(image_data_remapped, 9)
    dest_image.write((len(chunkData) - 4).to_bytes(4, byteorder='big') + chunkData + __getCRC(chunkData).to_bytes(4, byteorder='big'))

    dest_image.write(b'\x00\x00\x00\x00IEND\xAE\x42\x60\x82')
    dest_image.close()

    print("done!!")
