#include "winSerial.h"


BOOL getComPorts(COMPort ** foundPorts, int * length)
{
	//Create a "device information set" for the specified GUID
	HDEVINFO hDevInfoSet = SetupDiGetClassDevs(&GUID_DEVINTERFACE_COMPORT, NULL, NULL, DIGCF_PRESENT | DIGCF_DEVICEINTERFACE);
	if (hDevInfoSet == INVALID_HANDLE_VALUE)
		return FALSE;

	//Finally do the enumeration
	BOOL bMoreItems = TRUE;
	int nIndex = 0;
	SP_DEVINFO_DATA devInfo;
	// Default buffer size I guess...
	*foundPorts = malloc(sizeof(COMPort) * 1024);
	int num = 0;
	while (bMoreItems && num < 1024)
	{
		//Enumerate the current device
		devInfo.cbSize = sizeof(SP_DEVINFO_DATA);
		bMoreItems = SetupDiEnumDeviceInfo(hDevInfoSet, nIndex, &devInfo);
		if (bMoreItems)
		{
			//Did we find a serial port for this device
			BOOL bAdded = FALSE;

			//Get the registry key which stores the ports settings
			HKEY deviceKey = SetupDiOpenDevRegKey(hDevInfoSet, &devInfo, DICS_FLAG_GLOBAL, 0, DIREG_DEV, KEY_QUERY_VALUE);
			if (deviceKey != INVALID_HANDLE_VALUE)
			{
				int nPort = 0;
				if (QueryRegistryPortName(deviceKey, &nPort))
				{
					(*foundPorts)[num].port = nPort;

					bAdded = TRUE;
				}
			}

			//If the port was a serial port, then also try to get its friendly name
			if (bAdded)
			{
				unsigned char * byFriendlyName;
				if (QueryDeviceDescription(hDevInfoSet, &devInfo, &byFriendlyName))
				{
					(*foundPorts)[num].friendly_name = byFriendlyName;
				}
				num++;
			}
		}

		++nIndex;
	}

	*length = num;

	//Free up the "device information set" now that we are finished with it
	SetupDiDestroyDeviceInfoList(hDevInfoSet);

	//Return the success indicator
	return TRUE;
}


BOOL QueryRegistryPortName(HKEY deviceKey, int * nPort)
{
	//What will be the return value from the method (assume the worst)
	BOOL bAdded = FALSE;

	//Read in the name of the port
	LPTSTR pszPortName = NULL;
	if (RegQueryValueString(deviceKey, _T("PortName"), &pszPortName))
	{
		//If it looks like "COMX" then
		//add it to the array which will be returned
		size_t nLen = _tcslen(pszPortName);
		if (nLen > 3)
		{
			if ((_tcsnicmp(pszPortName, _T("COM"), 3) == 0) && isdigit(*(pszPortName + 3)))
			{
				//Work out the port number
				*nPort = _ttoi(pszPortName + 3);

				bAdded = TRUE;
			}
		}
		LocalFree(pszPortName);
	}

	return bAdded;
}

BOOL RegQueryValueString(HKEY key, LPCTSTR lpValueName, LPTSTR* pszValue)
{
	//Initialize the output parameter
	*pszValue = NULL;

	//First query for the size of the registry value 
	ULONG nChars = 0;
	LSTATUS nStatus = RegQueryValueEx(key, lpValueName, NULL, NULL, NULL, &nChars);
	if (nStatus != ERROR_SUCCESS)
	{
		SetLastError(nStatus);
		return FALSE;
	}

	//Allocate enough bytes for the return value
	DWORD dwAllocatedSize = ((nChars + 1) * sizeof(TCHAR)); //+1 is to allow us to null terminate the data if required
	*pszValue = (LPTSTR)(LocalAlloc(LMEM_FIXED, dwAllocatedSize));
	if (*pszValue == NULL)
		return FALSE;


	DWORD dwType = 0;
	ULONG nBytes = dwAllocatedSize;
	(*pszValue)[0] = _T('\0');
	nStatus = RegQueryValueEx(key, lpValueName, NULL, &dwType, (LPBYTE)(*pszValue), &nBytes);
	if (nStatus != ERROR_SUCCESS)
	{
		LocalFree(*pszValue);
		*pszValue = NULL;
		SetLastError(nStatus);
		return FALSE;
	}
	if ((dwType != REG_SZ) && (dwType != REG_EXPAND_SZ))
	{
		LocalFree(*pszValue);
		*pszValue = NULL;
		SetLastError(ERROR_INVALID_DATA);
		return FALSE;
	}
	if ((nBytes % sizeof(TCHAR)) != 0)
	{
		LocalFree(*pszValue);
		*pszValue = NULL;
		SetLastError(ERROR_INVALID_DATA);
		return FALSE;
	}
	if ((*pszValue)[(nBytes / sizeof(TCHAR)) - 1] != _T('\0'))
	{
		//Forcibly null terminate the data ourselves
		(*pszValue)[(nBytes / sizeof(TCHAR))] = _T('\0');
	}

	return TRUE;
}

BOOL QueryDeviceDescription(HDEVINFO hDevInfoSet, SP_DEVINFO_DATA * devInfo, unsigned char ** byFriendlyName)
{
	DWORD dwType = 0;
	DWORD dwSize = 0;
	//Query initially to get the buffer size required
	if (!SetupDiGetDeviceRegistryProperty(hDevInfoSet, devInfo, SPDRP_DEVICEDESC, &dwType, NULL, 0, &dwSize))
	{
		if (GetLastError() != ERROR_INSUFFICIENT_BUFFER)
			return FALSE;
	}

	*byFriendlyName = malloc(dwSize);

	if (!(*byFriendlyName))
	{
		SetLastError(ERROR_OUTOFMEMORY);
		return FALSE;
	}

	return SetupDiGetDeviceRegistryProperty(hDevInfoSet, devInfo, SPDRP_DEVICEDESC, &dwType, *byFriendlyName, dwSize, &dwSize) && (dwType == REG_SZ);
}



HANDLE connectToComPort(COMPort * port)
{
	HANDLE hComm;
	char comdef[] = "\\\\.\\COM";
	// 3 for a com port up to 999 and the extra 1 for the null terminator
	char * buff = calloc(strlen(comdef) + 4, sizeof(char));
	strcat(buff, comdef);
	snprintf(buff + strlen(comdef), 4, "%d", port->port);
	hComm = CreateFile(buff,                //port name
		GENERIC_READ | GENERIC_WRITE, //Read/Write
		0,                            // No Sharing
		NULL,                         // No Security
		OPEN_EXISTING,// Open existing port only
		0,            // Non Overlapped I/O
		NULL);        // Null for Comm Devices

	if (hComm == INVALID_HANDLE_VALUE)
		printf("Error in opening serial port");
	else
		printf("opening serial port successful");
	free(buff);
	return hComm;
}

BOOL disconnectFromComPort(HANDLE port)
{
	return CloseHandle(port);//Closing the Serial Port
}

void printPortOption(COMPort* p, int num)
{
	printf("%d: COM%d, %s\r\n", num, p->port, (char *)p->friendly_name);
}

BOOL initialize(HANDLE fd)
{
	return setParameters(fd) & setTimeouts(fd);
}

int setParameters(HANDLE hComm)
{
	DCB dcbSerialParams = { 0 };                        // Initializing DCB structure
	dcbSerialParams.DCBlength = sizeof(dcbSerialParams);

	BOOL Status = GetCommState(hComm, &dcbSerialParams);     //retreives  the current settings

	if (Status == FALSE)
	{
		printf("\n   Error! in GetCommState()");
		return FALSE;
	}

	dcbSerialParams.BaudRate = CBR_9600;      // Setting BaudRate = 9600
	dcbSerialParams.ByteSize = 8;             // Setting ByteSize = 8
	dcbSerialParams.StopBits = ONESTOPBIT;    // Setting StopBits = 1
	dcbSerialParams.Parity = NOPARITY;      // Setting Parity = None 

	Status = SetCommState(hComm, &dcbSerialParams);  //Configuring the port according to settings in DCB 

	if (Status == FALSE)
	{
		printf("\n   Error! in Setting DCB Structure");
		return FALSE;
	}
	return TRUE;
}

int setTimeouts(HANDLE hComm)
{
	COMMTIMEOUTS timeouts = { 0 };

	timeouts.ReadIntervalTimeout = 50;
	timeouts.ReadTotalTimeoutConstant = 50;
	timeouts.ReadTotalTimeoutMultiplier = 10;
	timeouts.WriteTotalTimeoutConstant = 50;
	timeouts.WriteTotalTimeoutMultiplier = 10;

	return SetCommTimeouts(hComm, &timeouts);
}

BOOL writeDataToPort(HANDLE hComm, short * instructions, int number_of_instructions)
{
	DWORD  dNoOfBytesWritten = 0;          // Number of bytes written to the port


	unsigned char * buffer = (unsigned char *)malloc(sizeof(short) * number_of_instructions);
	for (int i = 0; i < number_of_instructions; i++)
	{
		buffer[2 * i] = (instructions[i] & 0xFF00) >> 8;
		buffer[2 * i + 1] = (instructions[i] & 0x00FF);
	}

	BOOL retval = WriteFile(hComm,               // Handle to the Serialport
		buffer,            // Data to be written to the port 
		sizeof(short)*number_of_instructions,   // No of bytes to write into the port
		&dNoOfBytesWritten,  // No of bytes written to the port
		NULL);
	free(buffer);
	return retval;
}
