#ifndef STRUCTS_H_   /* Include guard */
#define STRUCTS_H_

#ifdef _WIN32
#define strdup _strdup
#endif

// I like my bools
#define TRUE 1
#define FALSE 0
typedef int bool;

typedef short instruction;

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

typedef void(*callback)(node* data);
#endif
