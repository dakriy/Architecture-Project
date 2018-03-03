#ifndef ASSEMBLER_H_   /* Include guard */
#define ASSEMBLER_H_

#include <stddef.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>

// I like my bools
#define TRUE 1
#define FALSE 0
typedef int bool;

#define OPCODE_LENGTH 4
#define REGISTER_ADDRESS_LENGTH 4
#define IMMEDIATE_VALUE_LENGTH 8
#define MAXIMUM_IMMEDATE_VALUE 127
#define MINIMUM_IMMEDATE_VALUE -127
#define MAX_INSTRUCTIONS 128
#define INSTRUCTION_LENGTH 2


// Register definitions
enum REGISTERS
{
	PC = 0x0,
	R1 = 0x1,
	R2 = 0x2,
	R3 = 0x3,
	R4 = 0x4,
	R5 = 0x5,
	R7 = 0x7,
	R8 = 0x8,
	R9 = 0x9,
	R10 = 0xA,
	R11 = 0xB,
	R12 = 0xC,
	R13 = 0xD,
	R14 = 0xE,
	R15 = 0xF,
};

// Instruction opcode definitions
enum OPCODES
{
	// R-type
	ADD = 0x00,
	AND = 0x01,
	OR = 0x02,
	MOV = 0x03,

	// I-type
	SLL = 0x04,
	SLA = 0x05,
	SR = 0x06,
	NEG = 0x07,
	ANDI = 0x08,
	ADDI = 0x09,
	ORI = 0xA,
	LOADI = 0xB,

	// J-type
	J = 0xC,
	JZ = 0xD,

	// Other
	NOP = 0xF
};

/*
 * Takes a null terminated string and turns it into a byte string of machine code
 */
char* instructionToMachineCode(char *);

/*
 * Note: This function returns a pointer to a substring of the original string.
 * If the given string was allocated dynamically, the caller must not overwrite
 * that pointer with the returned value, since the original pointer must be
 * deallocated using the same allocator with which it was allocated.  The return
 * value must NOT be deallocated using free() etc.
 */
char* trimWhiteSpace(char*);

/*
 * Takes a whole assembly c string and returns the machine code
 */
char* assemble(char* assembly);


/*
 * Puts a null terminater behind comments
 * returns a 0 if a whole line is a comment and no further processing is needed
 * returns 1 if it needs to be parsed as an instruction
 */
bool trimComments(char * str);

/*
* Gets the next line in a giant c string.
* The returned string does need to be free'd
*/
char * getNextLine(char * str, const char * start,const char** found_pos);

#endif // ASSEMBLER_H_
