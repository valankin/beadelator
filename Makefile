# Compiler
CC = clang

# Directories
SRC_DIR = src
INCLUDE_DIR = $(SRC_DIR)/include

# Homebrew prefix for libpng and sdl2
LIBPNG_HOME := $(shell brew --prefix libpng)
SDL2_HOME := $(shell brew --prefix sdl2)

# Compiler flags
CFLAGS = -I$(INCLUDE_DIR) -I$(LIBPNG_HOME)/include -I$(SDL2_HOME)/include
LDFLAGS = -L$(LIBPNG_HOME)/lib -L$(SDL2_HOME)/lib -lpng -lz -lSDL2

# Source files
SRC = main.c $(SRC_DIR)/image_loader.c $(SRC_DIR)/display.c $(SRC_DIR)/process.c

# Output executable
OUT = main

# Default target
all: $(OUT)

# Compile the program
$(OUT): $(SRC)
	$(CC) $(CFLAGS) -o $(OUT) $(SRC) $(LDFLAGS)

# Clean up the build
clean:
	rm -f $(OUT)

# Phony targets
.PHONY: all clean
