#ifndef ASSEMBLER_H_   /* Include guard */
#define ASSEMBLER_H_

#include <stddef.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include "list.h"

extern const char * instructionIdentifiers[];
extern const char * registerIdentifiers[];
extern node* labelListHead;
extern node* mentionLabelListHead;
extern callback mentionCallback, labelCallback;
extern LabelMention * currentMention;
extern bool breakTraverse;
extern instruction * machineCode;


#define OPCODE_LENGTH 4
#define REGISTER_ADDRESS_LENGTH 4
#define IMMEDIATE_VALUE_LENGTH CHAR_BIT
#define MAXIMUM_IMMEDATE_VALUE SCHAR_MAX
#define MINIMUM_IMMEDATE_VALUE SCHAR_MIN
#define MAX_INSTRUCTIONS 65536
#define NUMBER_OF_INSTRUCTIONS (sizeof(instructionIdentifiers) / sizeof(char *))
#define NUMBER_OF_REGISTERS (sizeof(registerIdentifiers) / sizeof(char *))
#define RTYPE_INDEX 0
#define ITYPE_INDEX 4
#define JTYPE_INDEX 13
#define OTYPE_INDEX 15


/*
 * Takes a null terminated string and turns it into a byte string of machine code
 */
instruction instructionToMachineCode(char *, unsigned char lineNum);

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
instruction* assemble(char* assembly, unsigned short * instructionCount);

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

/*
 * Parses labels off of lines.
 * The returned string needs to be free'd
 * Returns NULL if there were no labels
 */
char* parseLabelsInLine(char * line, unsigned char line_index);

/*
 * Label mention list traversal callback
 */
void traverseMention(node * n);

/*
 * Label list traversal callback
 */
void traverseLabels(node * n);

#endif // ASSEMBLER_H_
