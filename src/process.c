//
// Created by Yuri Valankin on 17.07.2024.
//
#include <string.h>

#include "process.h"



png_bytep* copy_image(png_bytep* original_row_pointers, int height, int rowbytes)
{
    png_bytep* processed_row_pointers = (png_bytep*)malloc(sizeof(png_bytep) * height);

    for (int y = 0; y < height; y++)
    {
        processed_row_pointers[y] = (png_byte*)malloc(rowbytes);
        memcpy(processed_row_pointers[y], original_row_pointers[y], rowbytes);
    }

    return processed_row_pointers;
}


/**
 * @brief Converts the image to grayscale.
 *
 * This function converts the given image data to grayscale.
 *
 * @param row_pointers The image data to be converted.
 * @param width The width of the image.
 * @param height The height of the image.
 */
void convert_to_grayscale(png_bytep *row_pointers, int width, int height) {
    for (int y = 0; y < height; y++) {
        png_bytep row = row_pointers[y];
        for (int x = 0; x < width; x++) {
            png_bytep px = &(row[x * 4]);
            uint8_t gray = 0.2126 * px[0] + 0.7152 * px[1] + 0.0722 * px[2];
            px[0] = gray;
            px[1] = gray;
            px[2] = gray;
        }
    }
}
