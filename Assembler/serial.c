#include "serial.h"

void printPorts()
{
	// COMPort * ports = NULL;
	// int numOfPorts = 0;
	// getComPorts(&ports, &numOfPorts);
	// printf("Found ports:\r");
	// for(int i = 0; i < numOfPorts; i++)
	// {
	// 	printPortOption(&ports[i], i);
	// }

	int size;

	char ** ports = getComList(&size);

	for (int i = 0; i < size; i++)
	{
		printf("%s\n", ports[i]);
		free(ports[i]);
	}
	free(ports);
}
