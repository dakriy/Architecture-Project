#ifndef ASSEMBLER_H_   /* Include guard */
#define ASSEMBLER_H_

#include <stddef.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

// Register definitions
#define PC 0x0
#define R1 0x1
#define R2 0x2
#define R3 0x3
#define R4 0x4
#define R5 0x5
#define R7 0x7

// Instruction opcode definitions

// R-type
#define ADD 0x00
#define AND 0x01
#define OR 0x02
#define MOV 0x03


// I-type
#define SLL 0x04
#define SLA 0x05
#define SR 0x06
#define NEG 0x07
#define ANDI 0x08
#define ADDI 0x09
#define ORI 0xA
#define LOADI 0xB

// J-type
#define J 0xC
#define JZ 0xD

#define TRUE 1
#define FALSE 0
typedef int bool;

const short OPCODE_LENGTH = 4;
const short REGISTER_ADDRESS_LENGTH = 3;
const short IMMEDIATE_VALUE_LENGTH = 9;
const short MAXIMUM_IMMEDATE_VALUE = 255;
const short MINIMUM_IMMEDATE_VALUE = -255;
const int MAX_INSTRUCTIONS = 128;
const short INSTRUCTION_LENGTH = 2;

// Takes a null terminated string and turns it into a byte string of machine code
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
 * returns a 0 if a whole line is a comment
 * returns 1 otherwise
 */
bool trimComments(char * str);

/*
* Gets the next line in a giant c string.
* The returned string does need to be free'd
*/
char * getNextLine(char * str, const char * start,const char* found_pos);


#endif // ASSEMBLER_H_
