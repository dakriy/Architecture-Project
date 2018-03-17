#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "help.h"
#include "assembler.h"
#include "serial.h"

char * getFileContents(char * file)
{
	char * buffer;
	long length;
	FILE * f = NULL;
	if (file != NULL) f = fopen(file, "r");

	if (f)
	{
		fseek(f, 0, SEEK_END);
		length = ftell(f);
		fseek(f, 0, SEEK_SET);
		buffer = malloc(length + 1u);
		checkPtr(buffer);
		if (buffer)
		{
			size_t read_count = fread(buffer, 1, length, f);
			buffer[read_count] = '\0';
		}
		fclose(f);
	}
	else
	{
		perror("File could not be opened.");
		exit(EXIT_FAILURE);
	}

	return buffer;
}

void outputToFile(char * fileName, instruction * data, unsigned short instructionCount)
{
	FILE * f = fopen(fileName, "wb");
	if (f)
	{
		if(fseek(f, 0, SEEK_SET) != 0)
		{
			printf("Something went wrong when creating the assembly file.\n");
			exit(EXIT_FAILURE);
		}

		for (int i = 0; i < instructionCount; i++)
		{
			unsigned char buff[2];
			// Make sure I don't get screwed over by big/little endianness
			// LATER EDIT: I'm getting screwed by it anyway...
			buff[0] = (data[i] & 0xFF00) >> 8;
			buff[1] = (data[i] & 0xFF);
			if(fwrite(buff, sizeof(char), sizeof buff, f) != sizeof(instruction))
			{
				perror("Error writing to file");
				exit(EXIT_FAILURE);
			}
		}

		fclose(f);
	}
	else
	{
		perror("Error creating file");
		exit(EXIT_FAILURE);
	}

}

char * setOutputFileName(char * outputFile, char * inputFile)
{
	if (outputFile == NULL)
	{
		// Copy input file if they didn't specify one
		outputFile = strdup(inputFile);
		char * end = outputFile + strlen(outputFile) - 1;
		char * pos = end;
		char extension[] = ".out";
		char * new_str;
		while (pos > outputFile && *pos != '.') pos--;

		if (pos != outputFile) // File extension on the input file
			*pos = '\0'; // Turn that period into null!

		// Just to make sure we're long enough. Doing it this way to make things faster, and who cares about a few bytes of extra memory used these days? With all these Electron apps like Slack, and don't even get me started on Chrome... Not to leave out other browsers, but looking at you Google Chrome. While I'm on the subject, my Visual Studio is using half a gig of memory just sitting here. That's like twice as much as PUBG right? /s </rant>
		new_str = malloc(strlen(outputFile) + strlen(extension) + 1);
		checkPtr(new_str);

		new_str[0] = '\0';   // ensures the memory is an empty string becuase malloc can return rubbish lol
		strcat(new_str, outputFile);
		strcat(new_str, extension);

		free(outputFile);
		outputFile = new_str;
	}
	return outputFile;
}

bool uploadToProcessor(FILEDESCRIPTOR fd, instruction * machineCode, unsigned short instructionCount)
{
	return writeInstructions(fd, machineCode, instructionCount);
}

// Just call the program with the input and output files
int main(int argc, const char* argv[])
{
	char * inputFile = NULL;
	char * outputFile = NULL;
	int upload = FALSE;
	FILEDESCRIPTOR outputDeviceFD = NULL;
	for (size_t optind = 1; optind < argc && argv[optind][0] == '-'; optind++) {
		switch (argv[optind][1]) {
		case 'o':
			if (optind + 1 >= argc || argv[optind+1][0] == '-')
			{
				printf("Must specify a file!");
				exit(EXIT_FAILURE);
			}
			outputFile = strdup(argv[optind + 1]);
			optind++;
			break;
		case 'i':
			if (optind + 1 >= argc || argv[optind + 1][0] == '-')
			{
				printf("Must specify a file!");
				exit(EXIT_FAILURE);
			}
			inputFile = strdup(argv[optind + 1]);
			optind++;
			break;
		case 'h':
			printHelp(argv[0]);
			break;
		case 'u':
			outputDeviceFD = getWantedDevice();
			if (!initDevice(outputDeviceFD))
			{
				printf("Error when intitializing output device.\n");
				disconnectFromComPort(outputDeviceFD);
				upload = FALSE;
			}
			else
			{
				upload = TRUE;
			}
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
		exit(EXIT_FAILURE);
	}

	char * file = getFileContents(inputFile);
	if (!upload || outputFile != NULL)
		outputFile = setOutputFileName(outputFile, inputFile);

	unsigned short instructionCount;

	// Assemble it
	instruction * machineCode = assemble(file, &instructionCount);

	if (outputFile != NULL) // Write to the output file.
		outputToFile(outputFile, machineCode, instructionCount);
	if (upload)
	{
		if(!uploadToProcessor(outputDeviceFD, machineCode, instructionCount))
		{
			printf("Failed to upload all of the instructions.\n");
		}
		disconnectFromComPort(outputDeviceFD);
	}

	free(machineCode);
	free(file);
	free(inputFile);
	free(outputFile);
	exit(EXIT_SUCCESS);
}
