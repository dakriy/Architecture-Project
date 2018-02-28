#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "help.h"
#include "assembler.h"

#ifdef _WIN32
#define strdup _strdup
#endif

#ifdef _WIN64
#define strdup _strdup
#endif

char * getFileContents(char * file)
{
	char * buffer = 0;
	long length;
	FILE * f = fopen(file, "rb");

	if (f)
	{
		fseek(f, 0, SEEK_END);
		length = ftell(f);
		fseek(f, 0, SEEK_SET);
		buffer = malloc(length);
		if (buffer)
		{
			fread(buffer, 1, length, f);
		}
		fclose(f);
	}
	if (buffer)
		return buffer;
	else
		return NULL;
}

// Just call the program with the input and output files 
int main(int argc, const char* argv[])
{
	char * inputFile = NULL;
	char * outputFile = NULL;
	for (size_t optind = 1; optind < argc && argv[optind][0] == '-'; optind++) {
		switch (argv[optind][1]) {
		case 'o':
			if (optind + 1 >= argc || argv[optind+1][0] == '-')
			{
				printf("Must specify a file!");
				exit(EXIT_FAILURE);
			}
			outputFile = strdup(argv[optind + 1]);
			break;
		case 'i':
			if (optind + 1 >= argc || argv[optind + 1][0] == '-')
			{
				printf("Must specify a file!");
				exit(EXIT_FAILURE);
			}
			inputFile = strdup(argv[optind + 1]);
			break;
		case 'h':
			printHelp(argv[0]);
			break;
		default:
			printHelp(argv[0]);
			exit(EXIT_FAILURE);
		}
	}

	if (inputFile == NULL)
	{
		printf("An input file is required!\n");
		printHelp(argv[0]);
		exit(EXIT_SUCCESS);
	}

	char * file = getFileContents(outputFile);
	if (file == NULL)
	{
		printf("File could not be read!\n");
		exit(EXIT_FAILURE);
	}



	free(file);
	free(inputFile);
	free(outputFile);
	exit(EXIT_SUCCESS);
}
