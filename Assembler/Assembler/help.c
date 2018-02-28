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
	printOption("-h", "Prints this screen");
	printOption("-o", "Specifies the output file.");
	printOption("-i", "Specifies the input file.");
}