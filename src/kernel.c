#include "kernel.h"

// Start writing text mode to 0xb8000
int currentLine = 0;
void println(char* input) {
	// Loop over the string, copying each char to the text mode buffer until we see a null char
	int idx = 0;

	// Each char is 2 bytes
	int currentLineStart = 0xB8000 + (2* 80 * currentLine++);

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
	// If we write to 0xB8000, we can write text to the screen, let's give this a go!
	println("YeetOS 0.1 - github.com/petereast/yeetos");
	println("---");
	println("Hello world!");
	println("This is a new line");
}
