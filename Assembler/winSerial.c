#include "winSerial.h"


HRESULT getComPorts(COMPort ** foundPorts, int * length)
{
	// Initialize COM. ------------------------------------------ 

	BSTR resource = SysAllocString(L"\\\\.\\root\\cimv2");
	BSTR SerialPort = SysAllocString(L"Win32_SerialPort");
	BSTR DeviceID = SysAllocString(L"DeviceID");
	BSTR COM = SysAllocString(L"COM");
	BSTR Name = SysAllocString(L"Name");

	HRESULT hr = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);
	if (FAILED(hr))
		return hr;

	//Create the WBEM locator
	IWbemLocator * pLocator = NULL;
	hr = CoCreateInstance(&CLSID_WbemLocator, NULL, CLSCTX_INPROC_SERVER, &IID_IWbemLocator, (LPVOID *)&pLocator);
	if (FAILED(hr))
		return hr;

	IWbemServices * pServices = NULL;
	hr = pLocator->lpVtbl->ConnectServer(pLocator, resource, NULL, NULL, 0, 0, 0, 0, &pServices);
	if (FAILED(hr))
		return hr;

	//Execute the query
	IEnumWbemClassObject * pClassObject;
	hr = pServices->lpVtbl->CreateInstanceEnum(pServices, SerialPort, WBEM_FLAG_RETURN_WBEM_COMPLETE, NULL, &pClassObject);
	if (FAILED(hr))
		return hr;


	//Now enumerate all the ports
	hr = WBEM_S_NO_ERROR;

	//The final Next will return WBEM_S_FALSE
	// Change this to while maybe
	if(hr == WBEM_S_NO_ERROR)
	{
		ULONG uReturned = 0;
		IWbemClassObject * apObj[100];
		hr = pClassObject->lpVtbl->Next(pClassObject, WBEM_INFINITE, 10, apObj, &uReturned);
		*length = uReturned;
		if (SUCCEEDED(hr))
		{
			*foundPorts = malloc(sizeof(COMPort) * uReturned);
			for (ULONG n = 0; n < uReturned; n++)
			{
				VARIANT varProperty1;
				HRESULT hrGet = apObj[n]->lpVtbl->Get(apObj[n], DeviceID, 0, &varProperty1, NULL, NULL);
				if (SUCCEEDED(hrGet) && (varProperty1.vt == VT_BSTR) && (wcslen(varProperty1.bstrVal) > 3))
				{
					//If it looks like "COMX" then add it to the array which will be returned
					if ((_wcsnicmp(varProperty1.bstrVal, COM, 3) == 0) && isdigit(varProperty1.bstrVal[3]))
					{
						//Work out the port number
						int nPort = _wtoi(&(varProperty1.bstrVal[3]));

						//Also get the friendly name of the port
						VARIANT varProperty2;

						if (SUCCEEDED(apObj[n]->lpVtbl->Get(apObj[n], Name, 0, &varProperty2, NULL, NULL)) && (varProperty2.vt == VT_BSTR))
						{
							(*foundPorts)[n].friendly_name = varProperty2.bstrVal;
							(*foundPorts)[n].port = nPort;
						}
						VariantClear(&varProperty2);
					}

					VariantClear(&varProperty1);
				}
				apObj[n]->lpVtbl->Release(apObj[n]);
			}
		}
	}

	pClassObject->lpVtbl->Release(pClassObject);
	pServices->lpVtbl->Release(pServices);
	pLocator->lpVtbl->Release(pLocator);
	SysFreeString(resource);
	SysFreeString(SerialPort);
	SysFreeString(DeviceID);
	SysFreeString(COM);
	SysFreeString(Name);
	CoUninitialize();
	return S_OK;
}



HANDLE connectToComPort(COMPort * port)
{
	HANDLE hComm;
	char * buff = malloc(sizeof(char) * 3);
	snprintf(buff, 3, "%d", port->port);
	hComm = CreateFile(strcat("\\\\.\\COM", buff),                //port name
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
	printf(L"%d: %S\r\n", num, p->friendly_name);
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
	printf("\n   Setting DCB Structure Successfull\n");
	printf("\n       Baudrate = %d", dcbSerialParams.BaudRate);
	printf("\n       ByteSize = %d", dcbSerialParams.ByteSize);
	printf("\n       StopBits = %d", dcbSerialParams.StopBits);
	printf("\n       Parity   = %d", dcbSerialParams.Parity);
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

BOOL writeDataToPort(HANDLE hComm, char* data, DWORD numberOfElements)
{
	DWORD  dNoOfBytesWritten = 0;          // Number of bytes written to the port

	return WriteFile(hComm,               // Handle to the Serialport
		data,            // Data to be written to the port 
		numberOfElements,   // No of bytes to write into the port
		&dNoOfBytesWritten,  // No of bytes written to the port
		NULL);
}
