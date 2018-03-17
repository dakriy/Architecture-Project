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


	printf("Please select a com port:\n");
	for (int i = 0; i < size; i++)
	{
		printf("%d: %s\n", i + 1, ports[i]);
	}
	int num;
	scanf("%d", &num);

	if (num > size)
	{
		printf("Bad selection\n");
		exit(EXIT_FAILURE);
	}

	int fd;

	if(fd = connectToComPort(ports[num - 1]) < 0)
	{
		printf("Unable to open port.\n");
		exit(EXIT_FAILURE);
	}

	short s = 0x4849;

	writeDataToPort(fd, &s, 1);


	for (int i = 0; i < size; i++)
		free(ports[i]);

	free(ports);

	disconnectFromComPort(fd);
}
