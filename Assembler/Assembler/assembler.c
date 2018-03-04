#include "assembler.h"
#include "help.h"


instruction instructionToMachineCode(char* instruction)
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

	pos--;

	// Trim trailing whitespace
	while (pos > str && isspace((unsigned char)*pos)) pos--;

	// Empty line, return false so it won't get parsed
	if (pos == str) return FALSE;

	// Write new null terminator
	*(pos + 1) = 0;

	return TRUE;
}

char* getNextLine(char* str, const char* start, const char** found_pos)
{
	// If we are at the end of the string, return a null as there are no more lines.
	if (start >= str + strlen(str) - 1) return NULL;
	
	// If the next line is a new line we don't even wanna care about it so we skip the first char and move on.
	while (start[0] == '\n') start++;

	const char * pos = start;

	// Get next line
	while (pos < str + strlen(str) && *pos != '\n') pos++;
	*found_pos = pos;

	// Plus 1 because 0 index
	char * line = (char *)malloc(sizeof(char) * (pos - start + 1));
	checkPtr(line);

	// Copy over the line to the new string
	memcpy(line, start, pos - start);

	// Null terminate the c-string
	line[pos - start] = '\0';

	return line;
}

char* parseLabelsInLine(char* line, unsigned char line_index)
{
	char * newLine = NULL;
	char * pos = line;
	while (pos < line + strlen(line) && *pos != ':') pos++;
	
	if (*pos == ':')
	{
		Label * label = (Label*)malloc(sizeof(Label));

		label->label = (char*)malloc(sizeof(char*) * (pos - line + 1));

		checkPtr(label->label);

		memcpy(label->label, line, pos - line);

		label->label[pos - line] = '\0';

		label->location = line_index;

		pos++;

		while(pos < line + strlen(line) && isspace(pos)) pos++;

		newLine = malloc(sizeof(char) * (line + strlen(line) - pos));

		checkPtr(newLine);

		memcpy(newLine, pos, (line + strlen(line) - pos));
		
		if (labelListHead == NULL)
			labelListHead = create(label, NULL);
		else
			append(label, labelListHead);
	}

	return newLine;
}

instruction* assemble(char* assembly)
{
	instruction * machineCode = (instruction *)malloc(sizeof(instruction)*MAX_INSTRUCTIONS);
	checkPtr(machineCode);
	instruction * machineCodePos = machineCode;

	
	/*
	 * The general idea here is to trim the whitespace
	 * then trim the comments, then labels,
	 * then pass them to instructionToMachine,
	 * one line at a time
	 */
	char * found_pos = assembly;
	int instruction_count = 0;
	for (char * line = getNextLine(assembly, found_pos, &found_pos); line != NULL; line = getNextLine(assembly, found_pos, &found_pos))
	{
		// TODO: Labels aren't parsed yet. Probably parse them here as they are at the beginning of lines. So just check the line for a colon in it, save the instruction count in like a struct, so that we can run a pass after this replacing all label symbols with their code position
		char * trimmed = trimWhiteSpace(line);
		if(trimComments(trimmed))
		{

			char * lineWithNoLabels = parseLabelInLine(trimmed, instruction_count);
			if (lineWithNoLabels != NULL)
			{
				trimmed = lineWithNoLabels;
			}

			instruction newMachineCode = instructionToMachineCode(trimmed);

			// Change this if we decide NOP to be all 0's
			if((void *)newMachineCode != NULL)
			{
				*machineCodePos = newMachineCode;

				machineCodePos += sizeof(instruction);
			}

			instruction_count++;

			if (instruction_count > MAX_INSTRUCTIONS)
			{
				printf("Too many instructions!\n");
				exit(EXIT_FAILURE);
			}

			free(lineWithNoLabels);
		}
		free(line);
	}


	return machineCode;
}
