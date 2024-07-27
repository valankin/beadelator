#ifndef DISPLAY_H
#define DISPLAY_H

#include <png.h>

// Function to display images using SDL2
void display_images(png_bytep* original_row_pointers, png_bytep* processed_row_pointers, int width, int height);
#endif // DISPLAY_H
