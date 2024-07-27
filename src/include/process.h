//
// Created by Yuri Valankin on 17.07.2024.
//

#ifndef PROCESS_H
#define PROCESS_H

#include <png.h>
#include <stdlib.h>
png_bytep* copy_image(png_bytep* original_row_pointers, int height, int rowbytes);
void convert_to_grayscale(png_bytep *row_pointers, int width, int height);


#endif //PROCESS_H
