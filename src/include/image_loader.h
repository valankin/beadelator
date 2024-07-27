#ifndef IMAGE_LOADER_H
#define IMAGE_LOADER_H

#include <png.h>

// Function to read a PNG file
png_bytep* read_png_file(const char *filename, int *width, int *height, int *rowbytes);

// Function to convert image to grayscale
void convert_to_grayscale(png_bytep *row_pointers, int width, int height);

#endif // IMAGE_LOADER_H
