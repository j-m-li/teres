/*
 *                          cod5.com computer
 *
 *                      02 Jully MMXXIV PUBLIC DOMAIN
 *           The author disclaims copyright to this source code.
 *
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

struct opcode {
    char name[8];
    char t4[5];
    int flags;
};

struct opcode ops[] = {
    {"add", "----", 0},
    {"sub", "----", 0},
    {"ld", "----", 0},
    {"st", "----", 0},
    {"ldia", "----", 1},
    {"ldib", "----", 1},
    {"swap", "----", 0},
    {"push", "----", 0},
    {"pop", "----", 0},
    {"call", "----", 0},
    {"ret", "----", 0},
    {"shift", "----", 0},
    {"xor", "----", 0},
    {"cons", "----", 0},
    {"any", "----", 0},
    {"slt", "----", 0},
    {"pushr", "----", 0},
    {"popr", "----", 0},
    {"beq", "----", 0},
    {"bne", "----", 0},
    {"jmp", "----", 0},
    {"nop", "----", 0},
    {0}
};

void bin2ter(int v, char *buf) 
{
    int i, j;
    int n = 1;
    int next;
    for (i = 0; i < 15; i++) {
        n *= 3;
    }
    j = 12 + 3;
    buf[j+4] = '\0';
    for (i = 15; i >= 0; i--) {
        next = n / 3;
        switch(i) {
        case 11:
            j = 8 + 2;
            buf[j+4] = ',';
            break;
        case 7:
            j = 4 + 1;
            buf[j+4] = ',';
            break;
        case 3:
            j = 0;
            buf[j+4] = ',';
            break;
        }
        
        if (v == (n/2)) {
            v -= n;
            buf[j] = '+';
        } else if (v == -(n/2)) {
            v += n;
            buf[j] = '-';
        } else {
            buf[j] = '0';
        }
        j++;
        n = next;
    }
    printf("'%s'", buf);
}

char *add_t4(FILE *outf, char *str, int *offset, unsigned int *val) 
{
    unsigned int v = 0;
    int ok = 1;
    while (isspace(*str)) {
        str++;
    }
    while (*str) {
        switch (*str) {
        case '+':
            v <<= 2;
            v |= 0x01;
            break;
        case '-':
            v <<= 2;
            v |= 0x02;
            break;
        case '0':
            v <<= 2;
            v |= 0x00;
            break;
        case ',':
            ok = 0;
            break;
        default:
            if (isspace(*str)) {
                while (isspace(*str)) {
                    str++;
                }
                ok = 0;
            } else {
                fprintf(stderr, "Error in constant\n");
                while (*str) {
                    str++;
                }
                return str;
            }
        }
        if (!ok) {
            break;
        }
        str++;
    }
    switch(*offset & 0x3) {
    case 0:
        *val = v;
        break;
    case 1:
        *val |= (v << 8);
        break;
    case 2:
        *val |= (v << 16);
        break;
    case 3:
        *val |= (v << 24);
        fprintf(outf, "\t'h%04x: O_dat <= 32'h%08x; \n", (*offset) & ~0x3, *val);
        *val = 0;
        break;
    }
    *offset += 1;
    return str;
}

int add_opcode(FILE *outf, char *str, int *offset, unsigned int *val) 
{
    char *s;
    char *n;
    int v;
    char buf[20];
    struct opcode *op = ops;
    while (op->name[0]) {
        s = str;
        n = op->name;
        while (*s == *n) {
                n++;
                s++;
        }
        if (isspace(*s) || *s == ';') {
            add_t4(outf, op->t4, offset, val);
            if (op->flags & 1) {
                while (isspace(*s)) {
                    s++;
                }
                if (*s == '\0' || *s == ';') {
                    return -1;
                }
                if ((*s >= '0' && *s <= '9') || *s == '-') {
                    v = atoi(s);
                    bin2ter(v, buf);
                    add_t4(outf, buf, offset, val);
                    add_t4(outf, buf+4, offset, val);
                    add_t4(outf, buf+8, offset, val);
                    add_t4(outf, buf+12, offset, val);
                }
            }
            return 0;
        }
        op++;
    }
    return -1;
}
int main(int argc, char *argv[])
{
	FILE *in;
	FILE *outf;
    unsigned int val;
	char buf[1024];
	char *inst;
	int line;
    int offset;

	if (argc < 4 || strcmp(argv[2], "-o")) {
        fprintf(stderr, "USAGE: %s file.asm -o code.v\n", argv[0]);
        exit(-1);
    }
	in = fopen(argv[1], "rb");
	outf = fopen(argv[3], "w+b");
	

    line = 0;
    offset = 0;
    val = 0;
	while (fgets(buf, sizeof(buf), in))
	{
        line++;
        inst = buf;
        while (isspace(*inst)) {
            inst++;
        }
        if (*inst == '\0') {

        } else if (!memcmp(inst, ".t4", 3) && isspace(inst[3])) {
            inst = add_t4(outf, inst+4, &offset, &val);
            while (*inst == ',') {
                inst = add_t4(outf, inst+1, &offset, &val);
            }
        } else if (*inst == ';') {
        } else if (!memcmp(inst, ".org", 4) && isspace(inst[4])) {
            inst += 4;
            while (isspace(*inst)) {
                inst++;
            }    
            int o = atoi(inst);
            if (o < offset) {
                fprintf(stderr, "error in .org offset at line(%d) %d < %d\n", line, o, offset);
                exit(-1);
            }
            while (o > offset) {
                add_t4(outf, "0000", &offset, &val);
            }
        } else {
            if (add_opcode(outf, inst, &offset, &val)) {
                fprintf(stderr, "syntax error at line(%d)\n", line);
                exit(-1);
            }
        }		
	}
	switch(offset & 0x3) {
    case 0:
        break;
    case 1:
    case 2:
    case 3:
        fprintf(outf, "\t'h%04x: O_dat <= 32'h%08x; \n", offset & ~0x3, val);
        break;
    }
	fclose(in);
	fclose(outf);
	return 0;
}
