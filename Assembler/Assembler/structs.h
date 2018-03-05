#ifndef STRUCTS_H_   /* Include guard */
#define STRUCTS_H_

#ifdef _WIN32
#define strdup _strdup
#endif

// I like my bools
#define TRUE 1
#define FALSE 0
typedef int bool;

// Register definitions
typedef enum REGISTERS
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
} REGISTERS;

// Instruction opcode definitions
typedef enum OPCODES
{
	// R-type
	ADD = 0x0,
	AND = 0x1,
	OR = 0x2,
	MOV = 0x3,

	// I-type
	SLL = 0x4,
	SLA = 0x5,
	SR = 0x6,
	NEG = 0x7,
	ANDI = 0x8,
	ADDI = 0x9,
	ORI = 0xA,
	LOADI = 0xB,
	JZ = 0xC,

	// J-type
	J = 0xD,

	// Other
	NOP = 0xF
} OPCODES;


typedef struct Label
{
	unsigned char location;
	char * label;
} Label;

typedef struct LabelMention
{
	char * label;
	unsigned char instruction;
	// Bit offset
	unsigned char offset;

} LabelMention;

typedef struct node {
	struct Label * data;
	struct LabelMention * mention;
	struct node* next;
} node;

// Define instruction types

typedef struct RType {
	OPCODES opcode : 4;
	REGISTERS reg1 : 4;
	REGISTERS reg2 : 4;
	unsigned short padding : 4;
} RType ;

typedef struct IType {
	OPCODES opcode : 4;
	REGISTERS reg : 4;
	unsigned short immediate : 8;
} IType;

typedef struct JType {
	OPCODES opcode : 4;
	unsigned short immediate : 12;
} JType;

typedef union instruction
{
	RType R;
	IType I;
	JType J;
	// OType/direct accessor
	unsigned short O;
} instruction;

typedef void(*callback)(node* data);

#endif
