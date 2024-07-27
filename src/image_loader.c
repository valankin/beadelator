#include "image_loader.h"
#include <stdio.h>
#include <stdlib.h>

/**
 * @brief Reads a PNG file and returns the image data.
 *
 * This function reads a PNG file and returns the image width, height, row bytes, and raw pixel data.
 *
 * @param filename The path to the PNG file to be read.
 * @param width Pointer to an integer to store the width of the image.
 * @param height Pointer to an integer to store the height of the image.
 * @param rowbytes Pointer to an integer to store the number of bytes in a row.
 * @return png_bytep* Pointer to the raw pixel data.
 */
png_bytep* read_png_file(const char *filename, int *width, int *height, int *rowbytes) {
    FILE *fp = fopen(filename, "rb");
    if (!fp) {
        perror("File could not be opened for reading");
        exit(EXIT_FAILURE);
    }

    unsigned char header[8];
    fread(header, 1, 8, fp);
    if (png_sig_cmp(header, 0, 8)) {
        fprintf(stderr, "File is not recognized as a PNG file\n");
        fclose(fp);
        exit(EXIT_FAILURE);
    }

    png_structp png = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    if (!png) {
        fprintf(stderr, "png_create_read_struct failed\n");
        fclose(fp);
        exit(EXIT_FAILURE);
    }

    png_infop info = png_create_info_struct(png);
    if (!info) {
        fprintf(stderr, "png_create_info_struct failed\n");
        png_destroy_read_struct(&png, NULL, NULL);
        fclose(fp);
        exit(EXIT_FAILURE);
    }

    if (setjmp(png_jmpbuf(png))) {
        fprintf(stderr, "Error during init_io\n");
        png_destroy_read_struct(&png, &info, NULL);
        fclose(fp);
        exit(EXIT_FAILURE);
    }

    png_init_io(png, fp);
    png_set_sig_bytes(png, 8);

    png_read_info(png, info);

    *width = png_get_image_width(png, info);
    *height = png_get_image_height(png, info);
    png_byte color_type = png_get_color_type(png, info);
    png_byte bit_depth = png_get_bit_depth(png, info);

    if (bit_depth == 16)
        png_set_strip_16(png);

    if (color_type == PNG_COLOR_TYPE_PALETTE)
        png_set_palette_to_rgb(png);

    if (color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8)
        png_set_expand_gray_1_2_4_to_8(png);

    if (png_get_valid(png, info, PNG_INFO_tRNS))
        png_set_tRNS_to_alpha(png);

    if (color_type == PNG_COLOR_TYPE_RGB ||
        color_type == PNG_COLOR_TYPE_GRAY ||
        color_type == PNG_COLOR_TYPE_PALETTE)
        png_set_filler(png, 0xFF, PNG_FILLER_AFTER);

    if (color_type == PNG_COLOR_TYPE_GRAY ||
        color_type == PNG_COLOR_TYPE_GRAY_ALPHA)
        png_set_gray_to_rgb(png);

    png_read_update_info(png, info);

    *rowbytes = png_get_rowbytes(png, info);

    if (setjmp(png_jmpbuf(png))) {
        fprintf(stderr, "Error during read_image\n");
        png_destroy_read_struct(&png, &info, NULL);
        fclose(fp);
        exit(EXIT_FAILURE);
    }

    png_bytep *row_pointers = (png_bytep*)malloc(sizeof(png_bytep) * (*height));
    for (int y = 0; y < (*height); y++) {
        row_pointers[y] = (png_byte*)malloc(*rowbytes);
    }

    png_read_image(png, row_pointers);

    png_destroy_read_struct(&png, &info, NULL);
    fclose(fp);
    return row_pointers;
}