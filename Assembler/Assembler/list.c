#include "list.h"

node* create(Label * data, node* next)
{
	node* new_node = (node*)malloc(sizeof(node));
	checkPtr(new_node);

	new_node->data = data;
	new_node->next = next;

	return new_node;
}

node* prepend(node* head, Label * data)
{
	node* new_node = create(data, head);
	head = new_node;
	return head;
}

node* append(node* head, Label * data)
{
	if (head == NULL)
		return NULL;
	/* go to the last node */
	node *cursor = head;
	while (cursor->next != NULL)
		cursor = cursor->next;

	/* create a new node */
	node* new_node = create(data, NULL);
	cursor->next = new_node;

	return head;
}

node* insert_after(node *head, Label * data, node* prev)
{
	if (head == NULL || prev == NULL)
		return NULL;
	/* find the prev node, starting from the first node*/
	node *cursor = head;
	while (cursor != prev)
		cursor = cursor->next;

	if (cursor != NULL)
	{
		node* new_node = create(data, cursor->next);
		cursor->next = new_node;
		return head;
	}
	else
	{
		return NULL;
	}
}

node* insert_before(node *head, Label * data, node* nxt)
{
	if (nxt == NULL || head == NULL)
		return NULL;

	if (head == nxt)
	{
		head = prepend(head, data);
		return head;
	}

	/* find the prev node, starting from the first node*/
	node *cursor = head;
	while (cursor != NULL)
	{
		if (cursor->next == nxt)
			break;
		cursor = cursor->next;
	}

	if (cursor != NULL)
	{
		node* new_node = create(data, cursor->next);
		cursor->next = new_node;
		return head;
	}
	else
	{
		return NULL;
	}
}

void traverse(node* head, callback f)
{
	node* cursor = head;
	while (cursor != NULL)
	{
		f(cursor);
		cursor = cursor->next;
	}
}


node* remove_front(node* head)
{
	if (head == NULL)
		return NULL;
	node *front = head;
	head = head->next;
	front->next = NULL;
	/* is this the last node in the list */
	if (front == head)
		head = NULL;
	free(front->data->label);
	free(front->data);
	free(front);
	return head;
}


node* remove_back(node* head)
{
	if (head == NULL)
		return NULL;

	node *cursor = head;
	node *back = NULL;
	while (cursor->next != NULL)
	{
		back = cursor;
		cursor = cursor->next;
	}

	if (back != NULL)
		back->next = NULL;

	/* if this is the last node in the list*/
	if (cursor == head)
		head = NULL;


	free(cursor->data->label);
	free(cursor->data);
	free(cursor);

	return head;
}

node* remove_any(node* head, node* nd)
{
	if (nd == NULL)
		return NULL;
	/* if the node is the first node */
	if (nd == head)
		return remove_front(head);

	/* if the node is the last node */
	if (nd->next == NULL)
		return remove_back(head);

	/* if the node is in the middle */
	node* cursor = head;
	while (cursor != NULL)
	{
		if (cursor->next == nd)
			break;
		cursor = cursor->next;
	}

	if (cursor != NULL)
	{
		node* tmp = cursor->next;
		cursor->next = tmp->next;
		tmp->next = NULL;

		free(tmp->data->label);
		free(tmp->data);
		free(tmp);
	}
	return head;

}

node* search(node* head, char * data)
{
	node *cursor = head;
	while (cursor != NULL)
	{
		if (strcmp(cursor->data->label, data))
			return cursor;
		cursor = cursor->next;
	}
	return NULL;
}


void dispose(node *head)
{
	node *cursor, *tmp;

	if (head != NULL)
	{
		cursor = head->next;
		head->next = NULL;
		while (cursor != NULL)
		{
			tmp = cursor->next;

			free(cursor->data->label);
			free(cursor->data);
			free(cursor);
			cursor = tmp;
		}
	}
}


int count(node *head)
{
	node *cursor = head;
	int c = 0;
	while (cursor != NULL)
	{
		c++;
		cursor = cursor->next;
	}
	return c;
}

node* reverse(node* head)
{
	node* prev = NULL;
	node* current = head;
	node* next;
	while (current != NULL)
	{
		next = current->next;
		current->next = prev;
		prev = current;
		current = next;
	}
	head = prev;
	return head;
}