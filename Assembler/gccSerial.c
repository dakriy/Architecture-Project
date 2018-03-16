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

char ** getComList(int * size) {
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

	*size = comListNum;

	free(comList8250);

    // Return the lsit of detected comports
    return comList;
}
