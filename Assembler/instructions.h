#ifndef INSTRUCTIONS_H_   /* Include guard */
#define INSTRUCTIONS_H_

// Define instruction types
// Each type HAS to be 2 bytes
// Fields are gaurnteed to be laid out in memory in the same order as you define them.

typedef struct RType {
	unsigned short opcode : 4;
	unsigned short reg1 : 4;
	unsigned short reg2 : 4;
	unsigned short addressMode : 2;
	unsigned short padding : 2;
} RType;

typedef struct IType {
	unsigned short opcode : 4;
	unsigned short reg : 4;
	short immediate : 8;
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
