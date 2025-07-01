
#include <Windows.h>
#include <stdio.h>

void list_ports() 
{
	char buf[50];
	char path[5000]; 
	

	for (int i = 0; i < 255; i++) 
	{
		sprintf_s(buf, sizeof(buf), "COM%d", i);
		if (QueryDosDeviceA(buf, path, 5000)) {
			printf("%s found\n", buf);
		}
	}
}

int main(int argc, char *argv[])
{
	HANDLE h, inh;
	DCB con;
	COMMTIMEOUTS to;
	char buf[256];
	int len = 0;
	int c;
	INPUT_RECORD irec;
	DWORD cc;
	
	inh = GetStdHandle(STD_INPUT_HANDLE);

	h = CreateFileA(argv[1], GENERIC_READ | GENERIC_WRITE,
		0, NULL, OPEN_EXISTING, 0, NULL);
	if (h == INVALID_HANDLE_VALUE) {
		printf("Cannot open %s\n", argv[1]);
		list_ports();
		exit(-1);
	}
	BuildCommDCBA("baud=115200 parity=N data=8 stop=1", & con);
	/*GetCommState(h, &con);
	con.BaudRate = 115200;
	con.ByteSize = 8;
	con.StopBits = 1;
	con.fOutxCtsFlow = 0;*/
	SetCommState(h, &con);
	GetCommTimeouts(h, &to);
	to.ReadIntervalTimeout = 1;
	to.ReadTotalTimeoutMultiplier = 0;
	to.ReadTotalTimeoutConstant = 1;
	to.WriteTotalTimeoutMultiplier = 0;
	to.WriteTotalTimeoutConstant = 1;
	SetCommTimeouts(h, &to);
	printf("Press ESC to exit.\n");
	do {
		if (ReadFile(h, buf, sizeof(buf) - 1, &len, NULL)) {
			buf[len] = 0;
			printf("%s", buf);
		}
		
		cc = 0;
		irec.EventType = 0;
		GetNumberOfConsoleInputEvents(inh, &cc);
		if (cc > 0) {
			ReadConsoleInputA(inh, &irec, 1, &cc);
			if ((irec.EventType == KEY_EVENT && ((irec.Event).KeyEvent).bKeyDown)) {
				WriteFile(h, &(irec.Event.KeyEvent.uChar.AsciiChar), 1, &cc, NULL);
				printf("%c", irec.Event.KeyEvent.uChar.AsciiChar);
				if (irec.Event.KeyEvent.uChar.AsciiChar == '\r') {
					printf("\n");
				}
			}
		}
		else if (len == 0) {
			Sleep(10);
		}
		
	} while (irec.Event.KeyEvent.wVirtualKeyCode != 27);

	CloseHandle(inh);
	CloseHandle(h);
	printf("\n---> END\n");
	return 0;
}

