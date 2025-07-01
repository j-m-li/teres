/*
 *                          cod5.com computer
 *
 *                      17 may MMXXI PUBLIC DOMAIN
 *           The author disclaims copyright to this source code.
 *
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

void print_bits(FILE *out, int hex)
{
	int n, i;

	if (hex >= '0' && hex <= '9')
	{
		n = hex - '0';
	}
	else if (hex >= 'a' && hex <= 'f')
	{
		n = hex - 'a' + 10;
	}
	else
	{
		printf("ERROR\n");
		exit(-1);
	}
	for (i = 3; i >= 0; i--)
	{
		if (n & 0x8)
		{
			fprintf(out, "1");
		}
		else
		{
			fprintf(out, "0");
		}
		n = n << 1;
	}
}

char a(char c)
{
	if (c >= '0' && c <= '9')
	{
		return c - '0' + 'A';
	}
	else if (c >= 'A' && c <= 'F')
	{
		return c - 'A' + 10 + 'A';
	}
	else if (c >= 'a' && c <= 'f')
	{
		return c - 'a' + 10 + 'A';
	}
	return ' ';
}
int main(int argc, char *argv[])
{
	FILE *in;
	FILE *out0;
	FILE *out1;
	FILE *out2;
	FILE *out3;
	FILE *outf;
	char buf[1024];
	int dump = 0;
	char *inst;
	char *p;
	char *label;
	int line;
	int next = 0;

	in = fopen(argv[1], "rb");
	outf = fopen(argv[2], "w+b");
	sprintf(buf, "%s%d", argv[2], 0);
	out0 = fopen(buf, "w+b");
	sprintf(buf, "%s%d", argv[2], 1);
	out1 = fopen(buf, "w+b");
	sprintf(buf, "%s%d", argv[2], 2);
	out2 = fopen(buf, "w+b");
	sprintf(buf, "%s%d", argv[2], 3);
	out3 = fopen(buf, "w+b");

	while (fgets(buf, sizeof(buf), in))
	{
		if (dump)
		{
			inst = strstr(buf, ":");
			label = strstr(buf, ">:");
			if (label)
			{
				fprintf(outf, "/* (%c%c%c%c%c%c%c%c) %s */",
						a(buf[0]), a(buf[1]), a(buf[2]), a(buf[3]),
						a(buf[4]), a(buf[5]), a(buf[6]), a(buf[7]),
						buf);
			}
			else if (inst)
			{
				inst[0] = '\0';
				line = (int)strtol(buf, NULL, 16);
				while (next < line)
				{
					fprintf(outf, "\t'h%04x: O_dat <= 32'h00000000; /*         nop */\n", next);
					print_bits(out3, '0');
					print_bits(out3, '0');
					print_bits(out2, '0');
					print_bits(out2, '0');
					print_bits(out1, '0');
					print_bits(out1, '0');
					print_bits(out0, '0');
					print_bits(out0, '0');

					fwrite("\n", 1, 1, out0);
					fwrite("\n", 1, 1, out1);
					fwrite("\n", 1, 1, out2);
					fwrite("\n", 1, 1, out3);
					next += 4;
				}
				inst++;
				while (*inst && isspace(*inst))
				{
					inst++;
				}
				inst[11] = '\0';
				print_bits(out3, inst[0]);
				print_bits(out3, inst[1]);
				print_bits(out2, inst[3]);
				print_bits(out2, inst[4]);
				print_bits(out1, inst[6]);
				print_bits(out1, inst[7]);
				print_bits(out0, inst[9]);
				print_bits(out0, inst[10]);
				fprintf(out0, "\n");
				fprintf(out1, "\n");
				fprintf(out2, "\n");
				fprintf(out3, "\n");
				p = inst + 12;
				while (*p && *p != '\n' && *p != '\r')
				{
					p++;
				}
				*p = '\0';
				fprintf(outf, "\t'h%04x: O_dat <= 32'h%c%c%c%c%c%c%c%c; /*%s (%c%c%c%c%c%c%c%c)*/\n",
						line,
						inst[9], inst[10], inst[6], inst[7], inst[3],
						inst[4], inst[0], inst[1], inst + 12,
						a(inst[9]), a(inst[10]), a(inst[6]), a(inst[7]), a(inst[3]),
						a(inst[4]), a(inst[0]), a(inst[1]));
				/*
				fprintf(outf, "//ram['h%04x] <= 8'h%c%c; //%s",
					line, inst[6], inst[7], inst + 9);
				fprintf(outf, "//ram['h%04x] <= 8'h%c%c;\n",
					line+1, inst[4], inst[5]);
				fprintf(outf, "//ram['h%04x] <= 8'h%c%c;\n",
					line+2, inst[2], inst[3]);
				fprintf(outf, "//ram['h%04x] <= 8'h%c%c;\n",
					line+3, inst[0], inst[1]);
					*/
				next = line + 4;
			}
		}
		if (!dump)
		{
			if (strstr(buf, "00000000 ") && strstr(buf, ">:"))
			{
				fprintf(outf, "/* %s */", buf);
				dump = 1;
			}
		}
	}
	fwrite("\n", 1, 1, out0);
	fwrite("\n", 1, 1, out1);
	fwrite("\n", 1, 1, out2);
	fwrite("\n", 1, 1, out3);
	fclose(in);
	fclose(out0);
	fclose(out1);
	fclose(out2);
	fclose(out3);
	/*
	fprintf(outf, "$readmemb(\"rom.v0\", ram0);\n", (next - 4) / 4);
	fprintf(outf, "$readmemb(\"rom.v1\", ram1);\n", (next - 4) / 4);
	fprintf(outf, "$readmemb(\"rom.v2\", ram2);\n", (next - 4) / 4);
	fprintf(outf, "$readmemb(\"rom.v3\", ram3);\n", (next - 4) / 4);
*/
	fclose(outf);
	return 0;
}
