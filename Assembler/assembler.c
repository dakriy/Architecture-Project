#include "assembler.h"
#include "help.h"

node* labelListHead = NULL;

node* mentionLabelListHead = NULL;

callback mentionCallback = traverseMention;

callback labelCallback = traverseLabels;

LabelMention * currentMention = NULL;

bool breakTraverse = FALSE;

instruction * machineCode = NULL;

const char * instructionIdentifiers[] = {
	"add",
	"and",
	"or",
	"mov",

	"srl",
	"sra",
	"sl",
	"not",
	"andi",
	"addi",
	"ori",
	"loadi",

	"jz",
	"j",

	"", // Empty so that opcodes match up to the instruction
	"",
	"nop",
};

const char * registerIdentifiers[] = {
	"r0",
	"r1",
	"r2",
	"r3",
	"r4",
	"r5",
	"r6",
	"r7",
	"r8",
	"r9",
	"r10",
	"r11",
	"r12",
	"r13",
	"r14",
	"r15",
};

instruction instructionToMachineCode(char* line, unsigned char lineNum)
{
	char * iterator1 = line;
	char * iterator2 = line;

	unsigned short lineLength = strlen(line);

	// Make the whole thing lowercase
	for (; *iterator1; ++iterator1) *iterator1 = tolower(*iterator1);

	// Reset the iterator
	iterator1 = line;

	// Get the instruction identifier
	while (iterator2 < line + lineLength && !isspace(*iterator2)) iterator2++;

	if (iterator2 < line + lineLength)
	{
		*iterator2 = '\0';
		iterator2++;
	}

	if(strcmp("", line) == 0)
	{
		syntaxError("Unknown syntax error.", lineNum);
	}

	unsigned char instruction_index;
	for (instruction_index = 0; instruction_index < NUMBER_OF_INSTRUCTIONS; instruction_index++)
		if (strcmp(iterator1, instructionIdentifiers[instruction_index]) == 0)
			break;
	if (instruction_index == NUMBER_OF_INSTRUCTIONS)
	{
		syntaxError("Unknown Instruction!", lineNum);
	}

	instruction inst = {.O = 0};

	if (instruction_index < ITYPE_INDEX) // Instruction is a R type
	{
		RType instruc;
		instruc.opcode = (OPCODES)instruction_index;
		instruc.padding = 0;

		// TODO: Finish MOV instruction.

		instruc.addressMode = 0;

		// Getting first operand
		iterator1 = iterator2;
		while (*iterator2 && *iterator2 != ',') iterator2++;
		if (! *iterator2) syntaxError("Invalid Operand", lineNum);

		*iterator2 = '\0';
		if(iterator2 < line + lineLength) {
			iterator2++;
		}
		else {
			syntaxError("Second Operand Not Found", lineNum);
		}


		// Looking for the operand in registry
		iterator1 = trimWhiteSpace(iterator1);
		unsigned char register_index;
		for(register_index = 0; register_index < NUMBER_OF_REGISTERS; register_index++)
			if(strcmp(iterator1, registerIdentifiers[register_index]) == 0)
				break;

		// Throw error for unknown input
		if(register_index == NUMBER_OF_REGISTERS)
	 		syntaxError("Unknown Register Identifier", lineNum);

		// Store first operand
		instruc.reg1 = (REGISTERS)register_index;

		iterator1 = iterator2;
		iterator1 = trimWhiteSpace(iterator1);
		for(register_index = 0; register_index < NUMBER_OF_REGISTERS; register_index++)
			if(strcmp(iterator1, registerIdentifiers[register_index]) == 0)
				break;
		// Throw error for unknown input
		if(register_index == NUMBER_OF_REGISTERS)
			syntaxError("Unknown Register Identifier", lineNum);

		// Store second operand
		instruc.reg2 = (REGISTERS)register_index;

		inst.R = instruc;

	} else if (instruction_index < JTYPE_INDEX || instruction_index == JZ)
	{ // instruction is a I type or a JZ which has the same signature as an I type

		// TODO: Make sure the NOT isntruction works

		IType instruc;
		instruc.opcode = (OPCODES)instruction_index;

		// Getting first operand
		iterator1 = iterator2;
		while (*iterator2 && *iterator2 != ',') iterator2++;
		if (! *iterator2 && instruction_index != NOT) syntaxError("Invalid Operand", lineNum);

		// Getting Second Operand
		*iterator2 = '\0';
		if(iterator2 < line + lineLength) {
			iterator2++;
		}
		else if (instruction_index == NOT) {
			instruc.immediate = 16;
		}
		else {
			syntaxError("Second Operand Not Found", lineNum);
		}


		// Looking for the operand in registry
		iterator1 = trimWhiteSpace(iterator1);
		unsigned char register_index;
		for(register_index = 0; register_index < NUMBER_OF_REGISTERS; register_index++)
			if(strcmp(iterator1, registerIdentifiers[register_index]) == 0)
				break;

		// Throw error for unknown input
		if(register_index == NUMBER_OF_REGISTERS)
	 		syntaxError("Unknown Register Identifier", lineNum);

		// Store operand
		instruc.reg = (REGISTERS)register_index;

		iterator1 = iterator2;
		iterator1 = trimWhiteSpace(iterator1);

		// Get label if jump instruction
		if (instruction_index == JZ)
		{
			// Save the mention onto the mention list.
			LabelMention * mention = (LabelMention*)malloc(sizeof(LabelMention));
			checkPtr(mention);

			mention->location = lineNum;

			mention->isOffset = TRUE;

			mention->label = malloc(sizeof(char) * (strlen(iterator1) + 1));

			checkPtr(mention->label);

			mention->label[strlen(iterator1)] = '\0';

			memcpy(mention->label, iterator1, strlen(iterator1));

			if (mentionLabelListHead == NULL)
				mentionLabelListHead = create_m(mention, NULL);
			else
				append_m(mentionLabelListHead, mention);
			instruc.immediate = 0;
		} else if (instruction_index == NOT)
		{
			// Nothing
		} else
		{
			// Check if the immediate value is a number
			for (unsigned short i = 0; i < strlen(iterator1); i++) {
				if (i == 0 && iterator1[i] == '-') continue;
				if (!isdigit(iterator1[i]))
					syntaxError("Unknown character entered, only enter numbers", lineNum);
			}
			// Grab immediate value as a string and convert to int
			int immediate = atoi(iterator1);
			// Check if immediate value is within the bounds of -127 and 127
			if (immediate > 127 || immediate < -127)
				syntaxError("Immediate Value Out Of Bounds: -127 to 127", lineNum);
			// Store immediate value
			instruc.immediate = immediate;
		}

		inst.I = instruc;

	} else if(instruction_index < OTYPE_INDEX)
	{ // Instruction is a J type
		JType instruc;

		instruc.immediate = 0;

		instruc.opcode = (OPCODES)instruction_index;

		iterator1 = iterator2;

		iterator1 = trimWhiteSpace(iterator1);

		LabelMention * mention = (LabelMention*)malloc(sizeof(LabelMention));
		checkPtr(mention);

		mention->location = lineNum;

		mention->isOffset = FALSE;

		mention->label = malloc(sizeof(char) * (strlen(iterator1) + 1));

		checkPtr(mention->label);

		mention->label[strlen(iterator1)] = '\0';

		memcpy(mention->label, iterator1, strlen(iterator1));

		if (mentionLabelListHead == NULL)
			mentionLabelListHead = create_m(mention, NULL);
		else
			append_m(mentionLabelListHead, mention);

		inst.J = instruc;
	} else
	{ // Instruction is a pseudo instruction
		// NOP is the only pseudo instruction at this point, so...
		inst.O = 0;
	}

	return inst;
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
	{ // We got a label
		char * backCheck = pos;

		while (backCheck > line)
		{
			if(isspace(*backCheck))
			{
				syntaxError("Invalid label syntax!", line_index);
			}
			backCheck--;
		}


		Label * label = (Label*)malloc(sizeof(Label));

		checkPtr(label);

		label->label = (char*)malloc(sizeof(char*) * (pos - line + 1));

		checkPtr(label->label);

		memcpy(label->label, line, pos - line);

		label->label[pos - line] = '\0';

		label->location = line_index;

		pos++;

		while(pos < line + strlen(line) && isspace(*pos)) pos++;

		newLine = malloc(sizeof(char) * (line + strlen(line) - pos + 1));

		checkPtr(newLine);

		memcpy(newLine, pos, (line + strlen(line) - pos + 1));

		if (labelListHead == NULL)
			labelListHead = create(label, NULL);
		else
			append(labelListHead, label);
	}

	return newLine;
}

void traverseMention(node* n)
{
	currentMention = n->mention;

	breakTraverse = FALSE;

	traverse(labelListHead, labelCallback);

	if(!breakTraverse)
		syntaxError("Unknown label", currentMention->location);
}

void traverseLabels(node* n)
{
	if(breakTraverse)
		return;

	Label * label = n->data;

	if (currentMention == NULL)
	{
		printf("Label mention or label was added with no data. This is definitely a problem.\n");

		exit(EXIT_FAILURE);
	}

	if (strcmp(currentMention->label, label->label) == 0)
	{ // We found the label counter part
		if(currentMention->isOffset)
		{
			short location = label->location - currentMention->location;

			if (abs(location) > 127)
				syntaxError("Conditional jump label too far away, use j for larger distances.", currentMention->location);

			machineCode[currentMention->location].I.immediate = (char)location;
		} else
			 machineCode[currentMention->location].J.immediate = label->location;

		breakTraverse = TRUE;
	}

}

instruction* assemble(char* assembly, unsigned short * instructionCount)
{
	machineCode = (instruction *)malloc(sizeof(instruction)*MAX_INSTRUCTIONS);

	checkPtr(machineCode);

	instruction * machineCodePos = machineCode;

	/*
	 * The general idea here is to trim the whitespace
	 * then trim the comments, then labels,
	 * then pass them to instructionToMachine,
	 * one line at a time
	 */
	char * found_pos = assembly;
	unsigned char instruction_count = 0;
	for (char * line = getNextLine(assembly, found_pos, (const char **)&found_pos); line != NULL; line = getNextLine(assembly, found_pos, (const char **)&found_pos))
	{
		char * trimmed = trimWhiteSpace(line);
		if(trimComments(trimmed))
		{
			// Parse labels
			char * lineWithNoLabels = parseLabelsInLine(trimmed, instruction_count);
			if(lineWithNoLabels != NULL)
			{
				char * sanitized = trimWhiteSpace(lineWithNoLabels);
				if (strcmp(sanitized, "") == 0)
				{
					free(lineWithNoLabels);
					continue;
				}

				trimmed = sanitized;
			}

			// Parse instruction, instructions at this point should have no sorrounding spaces or anything like that, just pure, clean, instruction goodness
			instruction newMachineCode = instructionToMachineCode(trimmed, instruction_count);

			// Append instruction onto the instruction stack
			*machineCodePos = newMachineCode;

			// Increase instruction count
			machineCodePos += sizeof(instruction);
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

	// Go through all of the labels and replace
	traverse(mentionLabelListHead, mentionCallback);

	dispose(mentionLabelListHead);

	dispose(labelListHead);

	*instructionCount = instruction_count;

	return machineCode;
}
