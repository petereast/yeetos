#include "kernel.h"

#include <stddef.h>
#include <stdint.h>

uint16_t terminal_make_char(char c, char colour) {
	return (colour << 8) | c;
}

uint16_t* video_mem = (uint16_t*) VGA_TEXT_MODE_ADDR;

void terminal_initialise() {
	for (int h = 0; h < VGA_HEIGHT; h ++) {
		for (int w = 0; w < VGA_WIDTH; w ++) {
			video_mem[h * VGA_WIDTH + w] = terminal_make_char(' ', 0x30);
		}
	}

}

size_t strlen(const char* str)  {
	size_t len = 0;
	while(str[len]) {
		len ++;
	}

	return len;
}

// Start writing text mode to 0xb7fff
int currentLine = 0;
void println(char* input) {
	// Loop over the string, copying each char to the text mode buffer until we see a null char
	int idx = 0;

	// Each char is 2 bytes
	int currentLineStart = 0xB8000 + (2 * VGA_WIDTH * currentLine++);

	char current;
	while ((current = input[idx]) != 0) {
		// TODO: Handle the \n and other characters.
		char *addr = (char*) currentLineStart + (idx * 2);
		char *col = (char*) currentLineStart + (idx * 2) + 1;
		*addr = current;
		*col = 0x30;

		idx++;
	}

}

void kernel_main() {
	terminal_initialise();
	// If we write to 0xB8000, we can write text to the screen, let's give this a go!
	println("YeetOS 0.1 - github.com/petereast/yeetos");
	println("---");
	println("Hello world!");
	println("This is a new line");
	println("this is a really lon string that will be longer than 80 chars in the strings yooooooooooooooooooooooo");
}
