#ifndef HELP_H_   /* Include guard */
#define HELP_H_
#include <stdio.h>
#include <stdlib.h>


/*
 * Exit program because of a syntax error of some sort.
 * Will not return after this gets called.
 * THIS WILL EXIT THE PROGRAM RIGHT THEN AND THERE!
 */
void syntaxError(char * message, unsigned char line);
/*
 * Prints help option with normalized formatting.
 */
void printOption(const char * option, const char * message);

/*
 * Prints the help screen.
 */
void printHelp(const char * name);

/*
 * Makes sure pointers were allocated correctly.
 */
void checkPtr(void * ptr);

#endif // HELP_H_