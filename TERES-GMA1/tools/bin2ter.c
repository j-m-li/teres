/*
 *                          cod5.com computer
 *
 *                      03 Jully MMXXIV PUBLIC DOMAIN
 *           The author disclaims copyright to this source code.
 *
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>


int max3 = 1;


unsigned int b2t(int v) {
    unsigned int t = 0;
    int n = max3;
    int next;
    while (n > 0) {
       next = n / 3;
       t <<= 2;
       if (v == 0) {

       } else if (v > n / 2) {
           
            v -= n;
            t |= 0x1;
            
        } else if (v < -(n /2)) {
            v += n;
            t |= 0x2;
            
        }
        n = next;
    }

    return t;
}

int main(int argc, char *argv[])
{
	FILE *outf;
    int i;
    int n;
    int t3;
	if (argc < 3) {
        fprintf(stderr, "USAGE: %s b2t.v t2b.v\n", argv[0]);
        exit(-1);
    }
	outf = fopen(argv[1], "w+b");
	
    for (i = 0; i < 15; i++) {
            max3 *= 3;
    }
    printf("max3: %d\n", max3);
    n = 5;
    t3 = 1;
    for (i = 0; i < n; i++) {
        t3 *= 3;
    }
    for (i = -31; i < 32; i++) {
        fprintf(outf, "\t'h%04x: O_dat <= 8'h%02x; // %d \n", i & 0x3F, b2t(i), i);
    }
	fclose(outf);

    outf = fopen(argv[2], "w+b");
    for (i = -31; i <= t3 && i < 32; i++) {
        fprintf(outf, "\t'h%04x: O_dat <= 6'h%02x; // %d\n", b2t(i), i & 0x3F, i);
    }
    
    fclose(outf);
	return 0;
}
