#ifndef WINSERIAL_H_
#define WINSERIAL_H_
#define BUFFER_SIZE 100
#include <Windows.h>

//Other includes
#include <tchar.h>
#include <setupapi.h>
#include <stdio.h>
#pragma comment (lib, "Setupapi.lib")


// Source for how to do this
// http://xanthium.in/Serial-Port-Programming-using-Win32-API

// Also HUGEEE credit to these guys
// http://www.naughter.com/enumser.html

typedef struct COMPort {
	unsigned char * friendly_name;
	int port;
} COMPort;

BOOL getComPorts(COMPort **, int *);

BOOL QueryRegistryPortName(HKEY deviceKey, int * nPort);

BOOL RegQueryValueString(HKEY key, LPCTSTR lpValueName, LPTSTR * pszValue);

BOOL QueryDeviceDescription(HDEVINFO hDevInfoSet, SP_DEVINFO_DATA * devInfo, unsigned char ** byFriendlyName);

HANDLE connectToComPort(COMPort *);

int setParameters(HANDLE);

int setTimeouts(HANDLE);

BOOL writeDataToPort(HANDLE fd, short * instructions, int number_of_instructions);

BOOL disconnectFromComPort(HANDLE);

void printPortOption(COMPort *, int);

#endif