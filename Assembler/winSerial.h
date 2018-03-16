#ifndef WINSERIAL_H_
#define WINSERIAL_H_
#define BUFFER_SIZE 100
#include <Windows.h>
#include <Wbemidl.h>
#include <Wbemcli.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
# pragma comment(lib, "wbemuuid.lib")

// Source for how to do this
// http://xanthium.in/Serial-Port-Programming-using-Win32-API

typedef struct COMPort {
	BSTR friendly_name;
	int port;
} COMPort;

HRESULT getComPorts(COMPort **, int *);

HANDLE connectToComPort(COMPort *);

int setParameters(HANDLE);

int setTimeouts(HANDLE);

BOOL writeDataToPort(HANDLE, char *, DWORD);

BOOL disconnectFromComPort(HANDLE);

void printPortOption(COMPort *, int);

#endif