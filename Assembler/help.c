#include "help.h"

void printOption(const char * option, const char * message)
{
	printf("\t%s \t\t\t %s\n", option, message);
}

void printHelp(const char * name)
{
	printf("Welcome to the John Wilkes Booths Processer Assembler.\n\n");
	printf("Usage:\n");
	printf("\t%s [options] -o [<Output File Name>] -i [<Input File Name>]\n", name);
	printf("\nOptions:\n");
	printOption("-h", "Prints this screen.");
	printOption("-o", "Specifies the output file.");
	printOption("-i", "Specifies the input file.");
	printOption("-u", "Uploads the file onto the processor VIA a connected USB to Serial UART interface.");
	printOption("-n", "Suppresses output file.");
}

void checkPtr(void* ptr)
{
	if (ptr == NULL)
	{
		printf("There was an error allocating some memory. This is an extremely rare occurrence now days.\n");
		exit(EXIT_FAILURE);
	}
}

void syntaxError(char* message, unsigned char line)
{
	printf("INVALID SYNTAX!\n%s\nOn Instruction: %u\n", message, line + 1);
	exit(EXIT_FAILURE);
}
