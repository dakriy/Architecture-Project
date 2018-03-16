#ifndef SERIAL_H_
#define SERIAL_H_

#ifdef _WIN32
#include "winSerial.h"
#else
#include "gccSerial.h"
#endif

void printPorts();
#endif