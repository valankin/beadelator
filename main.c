#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <process.h>
#include <image_loader.h>
#include "display.h"


/**
 * @brief Main function to read and display a PNG file.
 *
 * This function takes a PNG file path as an argument, reads the file, processes it,
 * and displays the original and processed (grayscale) images side by side.
 *
 * @param argc The number of command-line arguments.
 * @param argv The array of command-line arguments.
 * @return int Returns 0 on successful execution, exits with an error code otherwise.
 */
int main(int argc, char* argv[])
{
    if (argc != 2)
    {
        fprintf(stderr, "Usage: %s <file.png>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    
    const char* filename = argv[1];

    // Read
    int width, height, rowbytes;
    png_bytep* original_row_pointers = read_png_file(filename, &width, &height, &rowbytes);


    png_bytep* processed_row_pointers = copy_image(original_row_pointers, height, rowbytes);


    convert_to_grayscale(processed_row_pointers, width, height);

    

    display_images(original_row_pointers, processed_row_pointers, width, height);
    return 0;
}
