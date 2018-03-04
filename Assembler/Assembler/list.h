#ifndef LIST_H_   /* Include guard */
#define LIST_H_

#include <stdlib.h>
#include <string.h>
#include "help.h"
#include "assembler.h"

typedef struct node {
	Label * data = NULL;
	struct node* next = NULL;
} node;

typedef void(*callback)(node* data);

/*
 * create a new node
 * initialize the data and next field
 *
 * return the newly created node
 */
node* create(Label * data, node* next);

/*
 * add a new node at the beginning of the list
 */
node* prepend(node* head, Label * data);

/*
 * add a new node at the end of the list
 */
node* append(node* head, Label * data);

/*
 * insert a new node after the prev node
 */
node* insert_after(node *head, Label * data, node* prev);

/*
 * insert a new node before the nxt node
 */
node* insert_before(node *head, Label * data, node* nxt);

/*
 * Search for a specific node with input data
 * 
 * return the first matched node that stores the input data,
 * otherwise return NULL
 */
node* search(node* head, char* data);

/*
 * traverse the linked list
 */
void traverse(node* head, callback f);

/*
 * sort the linked list using insertion sort
 */
node* reverse(node* head);

/*
 * return the number of elements in the list
 */
int count(node *head);

/*
 * remove node from the front of list
 */
node* remove_front(node* head);

/*
 * remove node from the back of the list
 */
node* remove_back(node* head);

/*
 * remove a node from the list
 */
node* remove_any(node* head, node* nd);

/*
 * remove all element of the list
 * Will clear all labels too.
 */
void dispose(node *head);

#endif // LIST_H_