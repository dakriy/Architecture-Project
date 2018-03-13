#ifndef STRUCTS_H_   /* Include guard */
#define STRUCTS_H_

#ifdef _WIN32
#define strdup _strdup
#endif

// I like my bools
#define TRUE 1
#define FALSE 0
typedef unsigned char bool;

// Register definitions
typedef enum REGISTERS
{
	R0 = 0x0,
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
	SRL = 0x4,
	SRA = 0x5,
	SL = 0x6,
	NOT = 0x7,
	ANDI = 0x8,
	ADDI = 0x9,
	ORI = 0xA,
	LOADI = 0xB,

	// J-type
	JZ = 0xC,
	J = 0xD
} OPCODES;


typedef struct Label
{
	char * label;
	unsigned char location;
} Label;

typedef struct LabelMention
{
	char * label;
	unsigned char location;
	bool isOffset;
} LabelMention;

typedef struct node {
	struct Label * data;
	struct LabelMention * mention;
	struct node* next;
} node;

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
