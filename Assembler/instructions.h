#ifndef INSTRUCTIONS_H_   /* Include guard */
#define INSTRUCTIONS_H_

// Define instruction types
// Each type HAS to be 2 bytes
// Fields are gaurnteed to be laid out in memory in the same order as you define them.

typedef struct RType {
	unsigned char opcode : 4;
	unsigned char reg1 : 4;
	unsigned char reg2 : 4;
	unsigned char addressMode : 2;
	unsigned char padding : 2;
} RType;

typedef struct IType {
	unsigned char opcode : 4;
	unsigned char reg : 4;
	char immediate;
} IType;

typedef struct JType {
	unsigned short opcode : 4;
	unsigned short immediate : 12;
} JType;

typedef short instruction;

instruction rtoin(RType r);
instruction itoin(IType i);
instruction jtoin(JType j);

#endif
