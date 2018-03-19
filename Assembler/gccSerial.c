#include "gccSerial.h"

char * get_driver(char * tty) {
	char dev[] = "/device";
	char driver[] = "/driver";
    struct stat st;
    char * devicedir = (char*)malloc(sizeof(dev) + sizeof(driver) + strlen(tty) + 1);

	// Initialize the c string
	devicedir[0] = '\0';
	strcat(devicedir, tty);

    // Append '/device' to the tty-path
    strcat(devicedir, dev);

    // Stat the devicedir and handle it if it is a symlink
    if (lstat(devicedir, &st)==0 && S_ISLNK(st.st_mode)) {
        char buffer[1024];
        memset(buffer, 0, sizeof(buffer));

        // Append '/driver' and return basename of the target
        strcat(devicedir, driver);
        if (readlink(devicedir, buffer, sizeof(buffer)) > 0) {
			free(devicedir);
			return basename(buffer);
		}
    }
	free(devicedir);
    return "";
}

int register_comport( char ** comList, char * dir, int * n, char ** comList8250, int * pos_8250) {
    // Get the driver the device is using
    char * driver = get_driver(dir);

	char dev[] = "/dev/";

    // Skip devices without a driver
    if (strlen(driver) > 0) {
		char * base = basename(dir);
        char * devfile = (char *) malloc(sizeof(dev) + strlen(base) + 1);
		devfile[0] = '\0';
		strcat(devfile, dev);
		strcat(devfile, base);
		if (strcmp(driver, "serial8250") == 0)
		{
			comList8250[(*pos_8250)++] = devfile;
		}
		else {
			comList[(*n)++] = devfile;
		}
		return 1;
    }
	return 0;
}

void probe_serial8250_comports(char ** comList, int * size_of_com_list, char ** comList8250, int size_of_8250_com_list) {
    struct serial_struct serinfo;

	for (int i = 0; i < size_of_8250_com_list; i++)
	{
		int fd = open(comList8250[i], O_RDWR | O_NONBLOCK | O_NOCTTY);
		if (fd >= 0) {
            // Get serial_info
            if (ioctl(fd, TIOCGSERIAL, &serinfo)==0) {
                // If device type is no PORT_UNKNOWN we accept the port
                if (serinfo.type != PORT_UNKNOWN)
				{
					comList[(*size_of_com_list)++] = comList8250[i];
				}
				else {
					free(comList8250[i]);
				}
            }
            close(fd);
        }
	}
}

int getComPorts(COMPort ** foundPorts, int * length) {
    int n;
    struct dirent **namelist;
    char ** comList;
	char ** comList8250;
    char sysdir[] = "/sys/class/tty/";

    // Scan through /sys/class/tty - it contains all tty-devices in the system
    n = scandir(sysdir, &namelist, NULL, NULL);
	int comListNum = 0;
	int comList8250Num = 0;
	comList = (char **)malloc(sizeof(char *) * n);
	comList8250 = (char **)malloc(sizeof(char *) * n);
    if (n < 0)
        perror("scandir");
    else {
        while (n--) {
            if (strcmp(namelist[n]->d_name,"..") && strcmp(namelist[n]->d_name,".")) {

                // Construct full absolute file path
                char * devicedir = (char*)malloc(strlen(sysdir) + strlen(namelist[n]->d_name) + 1);
				devicedir[0] = '\0';
				strcat(devicedir, sysdir);
				strcat(devicedir, namelist[n]->d_name);

                // Register the device
                register_comport(comList, devicedir, &comListNum, comList8250, &comList8250Num);

				free(devicedir);
            }
            free(namelist[n]);
        }
        free(namelist);
    }

    // Only non-serial8250 has been added to comList without any further testing
    // serial8250-devices must be probe to check for validity
    probe_serial8250_comports(comList, &comListNum, comList8250, comList8250Num);

	free(comList8250);

	*length = comListNum;

	*foundPorts = malloc(sizeof(COMPort) * comListNum);

	for (int i = 0; i < comListNum; i++)
	{
		(*foundPorts)[i].friendly_name = comList[i];
	}

    // Return true
    return 1;
}


int set_interface_attribs (int fd, int speed, int parity)
{
        struct termios tty;
        memset (&tty, 0, sizeof tty);
        if (tcgetattr (fd, &tty) != 0)
        {
            return 0;
        }

        cfsetospeed (&tty, speed);
        cfsetispeed (&tty, speed);

        tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8;     // 8-bit chars
        // disable IGNBRK for mismatched speed tests; otherwise receive break
        // as \000 chars
        tty.c_iflag &= ~IGNBRK;         // disable break processing
        tty.c_lflag = 0;                // no signaling chars, no echo,
                                        // no canonical processing
        tty.c_oflag = 0;                // no remapping, no delays
        tty.c_cc[VMIN]  = 0;            // read doesn't block
        tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

        tty.c_iflag &= ~(IXON | IXOFF | IXANY); // shut off xon/xoff ctrl

        tty.c_cflag |= (CLOCAL | CREAD);// ignore modem controls,
                                        // enable reading
        tty.c_cflag &= ~(PARENB | PARODD);      // shut off parity
        tty.c_cflag |= parity;
        tty.c_cflag &= ~CSTOPB;
        tty.c_cflag &= ~CRTSCTS;

        if (tcsetattr (fd, TCSANOW, &tty) != 0)
        {
			return 0;
        }
        return 1;
}

int set_blocking (int fd, int should_block)
{
        struct termios tty;
        memset (&tty, 0, sizeof tty);
        if (tcgetattr (fd, &tty) != 0)
        {
        	return 0;
        }

        tty.c_cc[VMIN]  = should_block ? 1 : 0;
        tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

        if (tcsetattr (fd, TCSANOW, &tty) != 0)
            return 0;
		return 1;
}

int writeDataToPort(int fd, short * instructions, int number_of_instructions)
{
	unsigned char * buffer = (unsigned char *) malloc(sizeof(short) * number_of_instructions);
	for(int i = 0; i < number_of_instructions; i++)
	{
		buffer[2*i] = (instructions[i] & 0xFF00) >> 8;
		buffer[2*i+1] = (instructions[i] & 0x00FF);
	}

	if(write(fd, buffer, sizeof(short) * number_of_instructions) != (sizeof(short) * number_of_instructions))
	{
		printf("Did not write the total amount\n");
		exit(EXIT_FAILURE);
	}

	free(buffer);
	return 1;
}

int connectToComPort(COMPort * port)
{
	int fd = open(port->friendly_name, O_RDWR | O_NOCTTY | O_SYNC | O_NONBLOCK);
	if (fd < 0)
	{
		printf("error %d opening %s: %s\n", errno, port->friendly_name, strerror (errno));
		exit(EXIT_FAILURE);
	}
	return fd;
}

int initialize(int fd)
{
	// set speed to 115200 bps, 8n1 (no parity) and no blocking
	return set_interface_attribs(fd, B115200, 0) & set_blocking(fd, 0);
}

int disconnectFromComPort(int file)
{
	if (close(file) < 0)
		return 0;
	return 1;
}

void printPortOption(COMPort * p, int num)
{
	printf("%d: %s\n", num, (char *)p->friendly_name);
}
