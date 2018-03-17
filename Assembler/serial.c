#include "serial.h"

void printPorts()
{
	
//	int size;
//
//	char ** ports = getComList(&size);
//
//
//	printf("Please select a com port:\n");
//	for (int i = 0; i < size; i++)
//	{
//		printf("%d: %s\n", i + 1, ports[i]);
//	}
//	int num;
//	scanf("%d", &num);
//
//	if (num > size)
//	{
//		printf("Bad selection\n");
//		exit(EXIT_FAILURE);
//	}
//
//	int fd;
//
//	if(fd = connectToComPort(ports[num - 1]) < 0)
//	{
//		printf("Unable to open port.\n");
//		exit(EXIT_FAILURE);
//	}
//
//	short s = 0x4849;
//
//	writeDataToPort(fd, &s, 1);
//
//
//	for (int i = 0; i < size; i++)
//		free(ports[i]);
//
//	free(ports);
//
//	disconnectFromComPort(fd);
}

FILEDESCRIPTOR getWantedDevice()
{
	COMPort * ports = NULL;
	int numOfPorts = 0;
	getComPorts(&ports, &numOfPorts);

	if (numOfPorts > 0)
		printf("Please select a com port:\n");
	else
		printf("No COM ports found.\n");

	for (int i = 0; i < numOfPorts; i++)
	{
		printPortOption(&ports[i], i + 1);
	}
	int num;
	scanf("%d", &num);

	if (num > numOfPorts)
	{
		printf("Bad selection\n");
		exit(EXIT_FAILURE);
	}

	FILEDESCRIPTOR fd = connectToComPort(&ports[num - 1]);
	
	if (fd < 0)
	{
		printf("Unable to open the device. Try another one?\n");
		exit(EXIT_FAILURE);
	}


	for (int i = 0; i < numOfPorts; i++)
	{
		free(ports[i].friendly_name);
	}
	free(ports);
	return fd;
}

void disconnect(FILEDESCRIPTOR fd)
{
	disconnectFromComPort(fd);
}

int writeInstructions(FILEDESCRIPTOR fd, short* instructions, int number_of_instructions)
{
	return writeDataToPort(fd, instructions, number_of_instructions);
}
