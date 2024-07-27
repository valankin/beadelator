#include "display.h"
#include "image_loader.h"
#include <SDL2/SDL.h>
#include <stdio.h>
#include <stdlib.h>

/**
 * @brief Initializes SDL2 and displays the PNG images.
 *
 * This function initializes SDL2 and creates a window to display the original
 * and processed (grayscale) PNG images side by side.
 *
 * @param original_row_pointers
 * @param processed_row_pointers
 * @param width
 * @param height
 */
void display_images(png_bytep* original_row_pointers, png_bytep* processed_row_pointers, int width, int height)
{
    if (SDL_Init(SDL_INIT_VIDEO) != 0)
    {
        fprintf(stderr, "SDL_Init Error: %s\n", SDL_GetError());
        exit(EXIT_FAILURE);
    }


    SDL_Window* win = SDL_CreateWindow("PNG Viewer", 100, 100, width * 2, height, SDL_WINDOW_SHOWN);
    if (win == NULL)
    {
        fprintf(stderr, "SDL_CreateWindow Error: %s\n", SDL_GetError());
        SDL_Quit();
        exit(EXIT_FAILURE);
    }

    SDL_Renderer* ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (ren == NULL)
    {
        SDL_DestroyWindow(win);
        fprintf(stderr, "SDL_CreateRenderer Error: %s\n", SDL_GetError());
        SDL_Quit();
        exit(EXIT_FAILURE);
    }

    SDL_Texture* original_tex = SDL_CreateTexture(ren, SDL_PIXELFORMAT_ABGR8888, SDL_TEXTUREACCESS_STATIC, width,
                                                  height);
    SDL_Texture* processed_tex = SDL_CreateTexture(ren, SDL_PIXELFORMAT_ABGR8888, SDL_TEXTUREACCESS_STATIC, width,
                                                   height);

    if (original_tex == NULL || processed_tex == NULL)
    {
        SDL_DestroyRenderer(ren);
        SDL_DestroyWindow(win);
        fprintf(stderr, "SDL_CreateTexture Error: %s\n", SDL_GetError());
        SDL_Quit();
        exit(EXIT_FAILURE);
    }

    uint32_t* original_pixels = (uint32_t*)malloc(sizeof(uint32_t) * width * height);
    uint32_t* processed_pixels = (uint32_t*)malloc(sizeof(uint32_t) * width * height);

    for (int y = 0; y < height; y++)
    {
        memcpy(original_pixels + y * width, original_row_pointers[y], width * 4);
        memcpy(processed_pixels + y * width, processed_row_pointers[y], width * 4);
        free(original_row_pointers[y]);
        free(processed_row_pointers[y]);
    }
    free(original_row_pointers);
    free(processed_row_pointers);

    SDL_UpdateTexture(original_tex, NULL, original_pixels, width * sizeof(uint32_t));
    SDL_UpdateTexture(processed_tex, NULL, processed_pixels, width * sizeof(uint32_t));

    SDL_RenderClear(ren);
    SDL_Rect original_rect = {0, 0, width, height};
    SDL_Rect processed_rect = {width, 0, width, height};
    SDL_RenderCopy(ren, original_tex, NULL, &original_rect);
    SDL_RenderCopy(ren, processed_tex, NULL, &processed_rect);
    SDL_RenderPresent(ren);

    free(original_pixels);
    free(processed_pixels);

    SDL_Event e;
    int quit = 0;
    while (!quit)
    {
        while (SDL_PollEvent(&e))
        {
            if (e.type == SDL_QUIT)
            {
                quit = 1;
            }
        }
    }

    SDL_DestroyTexture(original_tex);
    SDL_DestroyTexture(processed_tex);
    SDL_DestroyRenderer(ren);
    SDL_DestroyWindow(win);
    SDL_Quit();
}
