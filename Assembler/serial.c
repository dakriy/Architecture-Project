#include "serial.h"

void printPorts()
{
	COMPort * ports = NULL;
	int numOfPorts = 0;
	getComPorts(&ports, &numOfPorts);
	printf("Found ports:\r");
	for(int i = 0; i < numOfPorts; i++)
	{
		printPortOption(&ports[i], i);
	}
}
