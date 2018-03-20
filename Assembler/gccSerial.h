#ifndef GCCSERIAL_H_
#define GCCSERIAL_H_

#include <stdlib.h>
#include <dirent.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <linux/serial.h>
#include <libgen.h>
#include <errno.h>
#include <string.h>

// Credit to https://stackoverflow.com/questions/6947413/how-to-open-read-and-write-from-serial-port-in-c
// Also credit to https://stackoverflow.com/questions/2530096/how-to-find-all-serial-devices-ttys-ttyusb-on-linux-without-opening-them


typedef struct COMPort {
	char * friendly_name;
} COMPort;

int connectToComPort(COMPort * port);

int writeDataToPort(int fd, short * instructions, int number_of_instructions);

int disconnectFromComPort(int fd);

int getComPorts(COMPort ** foundPorts, int * length);

void printPortOption(COMPort *, int num);

int initialize(int fd);


int register_comport( char ** comList, char * dir, int * n, char ** comList8250, int * pos_8250);

void probe_serial8250_comports(char ** comList, int * size_of_com_list, char ** comList8250, int size_of_8250_com_list);

char * get_driver(char * tty);

int set_interface_attribs (int fd, int speed, int parity);

int set_blocking (int fd, int should_block);

#endif
