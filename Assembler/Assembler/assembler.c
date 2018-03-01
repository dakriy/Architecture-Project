#include "assembler.h"


char* instructionToMachineCode(char* instruction)
{
	short instructionPos = 0;

	for (instructionPos = 0; instructionPos < strlen(instruction); instructionPos++)
	{
		if (instruction[instructionPos] == ' ')
			break;
		// Looking for breaks in instructions. "Spaces"
	}

	// TODO: Actually parse instructions

	return NULL;
}

char* trimWhiteSpace(char* str)
{
	char *end;

	// Trim leading space
	while (isspace((unsigned char)*str)) str++;

	if (*str == 0)  // All spaces?
		return str;

	// Trim trailing space
	end = str + strlen(str) - 1;
	while (end > str && isspace((unsigned char)*end)) end--;

	// Write new null terminator
	*(end + 1) = 0;

	return str;
}

bool trimComments(char * str)
{

	// Whole line is a comment
	if (str[0] == '#')
	{
		str[0] = '\0';
		return FALSE;
	}

	char *end = str + strlen(str) - 1;
	char *pos = str;

	// Go until end or until we hit a comment
	while (pos < end && *pos != '#') pos++;

	// No comments in the line
	if (pos == end) return TRUE;

	// Trim trailing whitespace
	while (pos > str && isspace((unsigned char)*pos)) pos--;

	// Empty line, return false so it won't get parsed
	if (pos == str) return FALSE;

	// Write new null terminator
	*(pos + 1) = 0;

	return TRUE;
}

char* getNextLine(char* str, const char* start, const char* found_pos)
{
	// If we are at the end of the string, return a null as there are no more lines.
	if (start == str + strlen(str) - 1) return NULL;
	
	// If the next line is a new line we don't even wanna care about it so we skip the first char and move on.
	while (start[0] == '\n') start++;

	const char * pos = start;

	// Get next line
	while (pos < str + strlen(str) && *pos != '\n') pos++;
	found_pos = pos;

	// Plus 1 because 0 index
	char * line = (char *)malloc(sizeof(char) * (pos - start + 1));

	// Copy over the line to the new string
	int cpy_pos;
	for (cpy_pos = 0; cpy_pos < (pos - start); cpy_pos++)
	{
		line[cpy_pos] = start[cpy_pos];
	}

	// Null terminate the c-string
	line[cpy_pos + 1] = '\0';

	return line;
}

char* assemble(char* assembly)
{
	char * machineCode = (char *)malloc(INSTRUCTION_LENGTH*MAX_INSTRUCTIONS);

	/*
	 * The general idea here is to trim the whitespace
	 * then trim the comments, then pass them to
	 * instructionToMachine, one line at a time
	 */
	char * found_pos = assembly;
	int instruction_count = 0;
	// TODO: Error out if the dudes program is more than 128 instructions
	for (char * line = assembly; line != NULL; line = getNextLine(assembly, found_pos, found_pos))
	{
		char * trimmed = trimWhiteSpace(line);
		if(trimComments(trimmed))
		{
			instruction_count++;
			// TODO: Add the machine code into the machineCode variable
			char * newMachineCode = instructionToMachineCode(trimmed);
		}

		free(line);
	}


	return machineCode;
}
