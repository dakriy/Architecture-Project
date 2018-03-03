#ifndef HELP_H_   /* Include guard */
#define HELP_H_
#include <stdio.h>
#include <stdlib.h>

void printOption(const char * option, const char * message);
void printHelp(const char * name);
void checkPtr(void * ptr);

#endif // HELP_H_