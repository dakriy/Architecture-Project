#ifndef SERIAL_H_
#define SERIAL_H_

#ifdef _WIN32
#define FILEDESCRIPTOR HANDLE
#include "winSerial.h"
#else
#define FILEDESCRIPTOR int
#include "gccSerial.h"
#endif

FILEDESCRIPTOR getWantedDevice();

void disconnect(FILEDESCRIPTOR fd);

int writeInstructions(FILEDESCRIPTOR fd, short * instructions, int number_of_instructions);

#endif
