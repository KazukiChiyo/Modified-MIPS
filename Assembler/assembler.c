#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
typedef int bool;
#define true 1
#define false 0
#define MAX_TEXT 100
#define RED "\x1b[31m"
#define GREEN "\x1b[32m"
#define RESET "\x1b[0m"

const char binary[16][5] = {"0000", "0001", "0010", "0011",
                            "0100", "0101", "0110", "0111",
                            "1000", "1001", "1010", "1011",
                            "1100", "1101", "1110", "1111"};

const char hex [] = "0123456789abcdef";

const char regi[3][3] = {"i0", "i1", "i2"};
const char regf[3][3] = {"f0", "f1", "f2"};
const char regt[3][3] = {"t0", "t1", "t2"};

typedef union {
    float f;
    struct {
        unsigned int mantissa : 23;
        unsigned int exponent : 8;
        unsigned int sign : 1;
    } bin;
} ieee;

void removeSpace(char* source)
{
    char* i = source;
    char* j = source;
    while(*j != 0) {
    *i = *j++;
    if(*i != ' ' && *i != '\r' && *i != '\n') i++;
    }
    *i = 0;
}

void removeNewline(char* source) {
    char* i = source;
    char* j = source;
    while (*j != 0) {
        *i = *j++;
        if (*i != '\r' && *i != '\n') i++;
    }
    *i = 0;
}

void dectoBin(char* buffer, int digits) {
    int i = 0;
    int size = 0;
    int val = 0;
    int hex_idx = 0;
    const char* v;
    char newbuf[MAX_TEXT];
    for (i = 0; i < MAX_TEXT; i++) newbuf[i] = 0;
    size = strlen(buffer);
    if (buffer[0] == '-') {
        for (i = 1; i<size; i++) {
            val += (int)(buffer[size-i]-'0')*pow(10,i-1);
        }
        val = -val;
    }
    else {
        for (i = 0; i<size; i++) {
            val += (int)(buffer[size-i-1]-'0')*pow(10,i);
        }
    }
    for (i = 0; i < MAX_TEXT; i++) buffer[i] = 0;
    if (digits == 8) sprintf(newbuf, "%02x", (int8_t) val);
    else if (digits == 16) sprintf(newbuf, "%04x", (int16_t) val);
    else if (digits == 32) sprintf(newbuf, "%08x", val);
    for (i = 0; i < digits/4; i++) {
        v = strchr(hex, newbuf[i]);
        v[0] > 96 ? (hex_idx = v[0]-87) : (hex_idx = v[0]-48);
        strcat(buffer, binary[hex_idx]);
    }
}

void inttoHex(char* buffer, int val, int line) {
    int i;
    for (i = 0; i < MAX_TEXT; i++) buffer[i] = 0;
    int size = 0;
    if (line <= 0) return;
    else if (line <= 16) size = 1;
    else if (line <= 256) size = 2;
    else if (line <= 4096) size = 3;
    for (i = 0; i < MAX_TEXT; i++) buffer[i] = 0;
    if (size == 1) sprintf(buffer, "%x", val);
    else if (size == 2) sprintf(buffer, "%02x", val);
    else if (size == 3) sprintf(buffer, "%03x", val);
    for (i = 0; i < MAX_TEXT; i++) {
        if (buffer[i] >= 97 && buffer[i] <= 102) buffer[i] = buffer[i] - 32;
    }
}

int getBin(int n, int i, char* buffer){
    int k;
    int size = i;
    for (i = size - 1; i >= 0; i--) {
      k = n >> i;
      if (k & 1) buffer[size -1 - i] = '1';
      else buffer[size - 1 - i] = '0';
    }
}

void dectoFloat(char* source, char* fp) {
    int i;
    char* end;
    ieee var;
    var.f = strtod(source, &end);
    char temp[23];
    for (i = 0; i < 23; i++) temp[i] = 0;
    sprintf(temp, "%d", var.bin.sign);
    strncat(fp, temp, 1);
    getBin(var.bin.exponent, 8, temp);
    strncat(fp, temp, 8);
    getBin(var.bin.mantissa, 23, temp);
    strncat(fp, temp, 23);
}

int countlines(char *fname) {
    FILE *f = fopen(fname, "r");
    char c;
    int count = 0;
    if (f == NULL) {
        printf(RED "Source file missing" RESET "\n");
        return 0;
    }
    for (c = getc(f); c != EOF; c = getc(f)) {
        if (c == '\n') count++;
    }
    fclose(f);
    return count;
}

void getData(char *fname) {
    FILE *in = fopen(fname, "r");
    FILE *out;
    char buffer[MAX_TEXT];
    int read = 0;
    out = fopen("data.asm", "w+");
    if (in == NULL) {
        printf(RED "Source file missing" RESET "\n");
        exit(1);
    }
    while (fgets(buffer, MAX_TEXT, in) != NULL) {
        if (!strncmp(buffer, "@data", 5)) {
            read = 1;
            continue;
        }
        else if (!strncmp(buffer, "@func", 5)) {
            read = 0;
            break;
        }
        if (read) fprintf(out, "%s", buffer);
    }
    printf(GREEN "data.asm created." RESET "\n");
    fclose(in);
    fclose(out);
}

void eraseSpace(char buffer[], char newbuf[]) {
	int i, j = 0;
	for (i = 0; i < MAX_TEXT && buffer[i]; i++) {
		if (buffer[i] != ' ' && buffer[i] != '\n' && buffer[i] != '\r') {
			newbuf[j] = buffer[i];
			j++;
		}
	}
	return;
}

void parseFunc(char buffer[], int off, int line) {
    int size = 0;
    char* pch1;
    char* pch2;
    int i;
    char num[17];
    for (i = 0; i < 10; i++) num[i] = 0;
    char reg_file[2];
    reg_file[0] = reg_file[1] = 0;
    char newbuf[MAX_TEXT];
    for (i = 0; i < MAX_TEXT; i++) newbuf[i] = 0;
    int reg_idx = 0;
    bool isFloat = false;
    int ctr = 0;
    char offset[MAX_TEXT];
    for (i = 0; i < MAX_TEXT; i++) offset[i] = 0;
    sprintf(offset, "%d", off);
	eraseSpace(buffer, newbuf);
	for (i = 0; i < MAX_TEXT; i++)
		buffer[i] = 0;
    sprintf(buffer, "mem_array[%d] <= ", line);
	if (!strncmp(newbuf,"pause",5)) //pse
		strncat(buffer, "opPSE(16'hffff);", 16);
    else if (!strncmp(newbuf, "ret", 3))  //ret
        strncat(buffer, "opRET(re);", 10);
    else if (!strncmp(newbuf, "add", 3) || !strncmp(newbuf, "sub", 3) || !strncmp(newbuf, "and", 3) || !strncmp(newbuf, "mul", 3) || !strncmp(newbuf, "sftl", 4) || !strncmp(newbuf, "sftr", 4) ||!strncmp(newbuf, "lr", 2) || !strncmp(newbuf, "sa", 2)) {
        if (!strncmp(newbuf, "addf", 4) || !strncmp(newbuf, "subf", 4) || !strncmp(newbuf, "andf", 4) || !strncmp(newbuf, "mulf", 4) || !strncmp(newbuf, "lrf", 3) || !strncmp(newbuf, "saf", 3))
            isFloat = true;
        pch1 = strchr(newbuf, '#');
        if (pch1 != NULL) { //addi or subi or andi or sftl or sftr or lr(f) or sa(f)
            if (!strncmp(newbuf, "add", 3)) strncat(buffer, "opADDi(", 7);
            else if (!strncmp(newbuf, "sub", 3)) strncat(buffer, "opSUBi(", 7);
            else if (!strncmp(newbuf, "and", 3)) strncat(buffer, "opANDi(", 7);
            else if (!strncmp(newbuf, "sftl", 4)) strncat(buffer, "opSFTL(", 7);
            else if (!strncmp(newbuf, "sftr", 4)) strncat(buffer, "opSFTR(", 7);
            else if (!strncmp(newbuf, "lr", 2))
                isFloat ? strncat(buffer, "opLRF(", 6) : strncat(buffer, "opLR(", 5);
            else if (!strncmp(newbuf, "sa", 2))
                isFloat ? strncat(buffer, "opSAF(", 6) : strncat(buffer, "opSA(", 5);
            pch2 = strchr(newbuf, '$');
            ctr = 0;
            while (pch2 != NULL && ctr <= 1) {
                reg_idx = pch2[2] - 48;
                strncat(buffer, regi[reg_idx], 2);
                strncat(buffer, ",", 1);
                pch2 = strchr(pch2+1, '$');
                ctr++;
            }
            for (i = 1; pch1[i] != 0 && pch1[i] != '\n' && pch1[i] != '\r'; i++)
                num[i-1] = pch1[i];
            dectoBin(num, 16);
            strncat(buffer, "16'b", 4);
            strncat(buffer, num, 16);
            strncat(buffer, ");", 2);
        }
        else { //add(f) or sub(f) or and(f) or mul(f)
            if (!strncmp(newbuf, "add", 3)) 
                isFloat ? strncat(buffer, "opADDF(", 7) : strncat(buffer, "opADD(", 6);
            else if (!strncmp(newbuf, "sub", 3)) 
                isFloat ? strncat(buffer, "opSUBF(", 7) : strncat(buffer, "opSUB(", 6);
            else if (!strncmp(newbuf, "and", 3)) 
                isFloat ? strncat(buffer, "opANDF(", 7) : strncat(buffer, "opAND(", 6); 
            else if (!strncmp(newbuf, "mul", 3)) 
                isFloat ? strncat(buffer, "opMULF(", 7) : strncat(buffer, "opMUL(", 6);
            pch2 = strchr(newbuf, '$');
            ctr = 0;
            while (pch2 != NULL && ctr <= 2) {
                reg_idx = pch2[2] - 48;
                isFloat ? strncat(buffer, regf[reg_idx], 2) : strncat(buffer, regi[reg_idx], 2);
                if (ctr != 2) strncat(buffer, ",", 1);
                pch2 = strchr(pch2+1, '$');
                ctr++;
            }
            strncat(buffer, ");", 2);
        }
    }
    else if (!strncmp(newbuf, "mvhi", 4) || !strncmp(newbuf, "mvlo", 4) || !strncmp(newbuf, "out", 3)) { //mvhi or mvlo or out
        if (!strncmp(newbuf, "mvhi", 4))
            strncat(buffer, "opMVHI(", 7);
        else if (!strncmp(newbuf, "mvlo", 4))
            strncat(buffer, "opMVLO(", 7);
        else if (!strncmp(newbuf, "out", 3))
            strncat(buffer, "opOUT(", 6);
        pch1 = strchr(newbuf, '$');
        strncpy(reg_file, pch1+1, 2);
        strncat(buffer, reg_file, 2);
        strncat(buffer, ");", 2);
    }
    else if (!strncmp(newbuf, "div", 3) || !strncmp(newbuf, "not", 3) || !strncmp(newbuf, "cmp", 3) || !strncmp(newbuf, "mv", 2)) { //div(f) or not or cmp(f) or mv(f)
        if (!strncmp(newbuf, "divf", 4) || !strncmp(newbuf, "cmpf", 4) || !strncmp(newbuf, "mvf", 3)) isFloat = true;
        if (!strncmp(newbuf, "div", 3))
            isFloat ? strncat(buffer, "opDIVF(", 7) : strncat(buffer, "opDIV(", 6);
        else if (!strncmp(newbuf, "not", 3))
            strncat(buffer, "opNOT(", 6);
        else if (!strncmp(newbuf, "cmp", 3))
            isFloat ? strncat(buffer, "opCMPF(", 7) : strncat(buffer, "opCMP(", 6);
        else if (!strncmp(newbuf, "mv", 2))
            isFloat ? strncat(buffer, "opMV(", 5) : strncat(buffer, "opMVF(", 6);
        pch1 = strchr(newbuf, '$');
        ctr = 0;
        while (pch1 != NULL && ctr <= 1) {
            reg_idx = pch1[2] - 48;
            isFloat ? strncat(buffer, regf[reg_idx], 2) : strncat(buffer, regi[reg_idx], 2);
            if (ctr != 1) strncat(buffer, ",", 1);
            pch1 = strchr(pch1+1, '$');
            ctr++;
        }
        strncat(buffer, ");", 2);
    }
    else if (!strncmp(newbuf, "rnd", 3)) { //rnd
        strncat(buffer, "opRND(", 6);
        pch1 = strchr(newbuf, '$');
        ctr = 0;
        while (pch1 != NULL && ctr <= 1) {
            reg_idx = pch1[2] - 48;
            if (ctr == 0) strncat(buffer, regi[reg_idx], 2);
            if (ctr == 1) strncat(buffer, regf[reg_idx], 2);
            if (ctr != 1) strncat(buffer, ",", 1);
            pch1 = strchr(pch1+1, '$');
            ctr++;
        }
        strncat(buffer, ");", 2);
    }
    else if (!strncmp(newbuf, "ld", 2)) { //ld(f)
        if (!strncmp(newbuf, "ldf", 3)) isFloat = true;
        isFloat ? strncat(buffer, "opLDF(", 6) : strncat(buffer, "opLD(", 5);
        pch1 = strchr(newbuf, '$');
        reg_idx = pch1[2] - 48;
        isFloat ? strncat(buffer, regf[reg_idx], 2) : strncat(buffer, regi[reg_idx], 2);
        strncat(buffer, ",16'b", 5);
        strcpy(num, offset);
        dectoBin(num, 16);
        strncat(buffer, num, 16);
        strncat(buffer, ");", 2);
    }
    else if (!strncmp(newbuf, "li", 2)) { //li
        strncat(buffer, "opLI(", 5);
        pch1 = strchr(newbuf, '#');
        pch2 = strchr(newbuf, '$');
        reg_idx = pch1[2] - 48;
        strncat(buffer, regi[reg_idx], 2);
        strncat(buffer, ",", 1);
        for (i = 1; pch1[i] != 0 && pch1[i] != '\n' && pch1[i] != '\r'; i++)
            num[i-1] = pch1[i];
        dectoBin(num, 16);
        strncat(buffer, "16'b", 4);
        strncat(buffer, num, 16);
        strncat(buffer, ");", 2);
    }
    else if (!strncmp(newbuf, "jsr", 3)) { //jsr
        strncat(buffer, "opJSR(", 6);
        pch1 = strchr(newbuf, '#');
        for (i = 1; pch1[i] != 0 && pch1[i] != '\n' && pch1[i] != '\r'; i++)
            num[i-1] = pch1[i];
        dectoBin(num, 16);
        strncat(buffer, "16'b", 4);
        strncat(buffer, num, 16);
        strncat(buffer, ");", 2);
    }
    else if (!strncmp(newbuf, "if", 2)) { //if
        strncat(buffer, "opIF(", 5);
        if (!strncmp(newbuf, "ifz", 3))
            strncat(buffer, "2'b00,", 6);
        else if (!strncmp(newbuf, "ifn", 3))
            strncat(buffer, "2'b11,", 6);
        else if (!strncmp(newbuf, "ifp", 3))
            strncat(buffer, "2'b01,", 6);
        pch1 = strchr(newbuf, '#');
        for (i = 1; pch1[i] != 0 && pch1[i] != '\n' && pch1[i] != '\r'; i++)
            num[i-1] = pch1[i];
        dectoBin(num, 16);
        strncat(buffer, "16'b", 4);
        strncat(buffer, num, 16);
        strncat(buffer, ");", 2);
    }
}

void getFunc(char *fname) {
    FILE *in = fopen(fname, "r");
    FILE *out;
    char buffer[MAX_TEXT];
    int i;
    for (i = 0; i < MAX_TEXT; i++) buffer[i] = 0;
    int read = 0;
    out = fopen("func.asm", "w+");
    if (in == NULL) {
        printf(RED "Source file missing" RESET "\n");
        exit(1);
    }
    while (fgets(buffer, MAX_TEXT, in) != NULL) {
        if (buffer[MAX_TEXT-1] != 0) buffer[MAX_TEXT-1] = 0;
        if (!strncmp(buffer, "@func", 5)) {
            read = 1;
            continue;
        }
        else if (!strncmp(buffer, "@end", 4)) {
            read = 0;
            break;
        }
        if (read) fprintf(out, "%s", buffer);
    }
    printf(GREEN "func.asm created." RESET "\n");
    fclose(in);
    fclose(out);
}

void parseData(char buffer[], int line) {
    int i, j = 0, flag = 0;
    int idx = 0;
    int size = 0;
    int val = 0;
    int hex_idx = 0;
    char fp[33];
    for (i = 0; i < 33; i++) fp[i] = 0;
    char num[10];
    for (i = 0; i < 10; i++) num[i] = 0;
    char newbuf[MAX_TEXT];
    const char* v;
    for (i = 0; i < MAX_TEXT; i++)
        newbuf[i] = 0;
    eraseSpace(buffer, newbuf);
    for (i = 0; i < MAX_TEXT; i++) buffer[i] = 0;
    sprintf(buffer, "mem_array[%d] <= 32'b", line);
    if (!strncmp(newbuf,"int:",4)) {
        for (i = 0; newbuf[i] != 0; i++) {
            if (flag && newbuf[i] != '\n' && newbuf[i] != '\r') {
                num[j] = newbuf[i];
                j++;
            }
            if (newbuf[i] == '#')
                flag = 1;
        }
        size = strlen(num);
        if (num[0] == '-') {
            for (i = 1; i<size; i++) {
                val += (int)(num[size-i]-'0')*pow(10,i-1);
            }
            val = -val;
        }
        else {
            for (i = 0; i<size; i++) {
                val += (int)(num[size-i-1]-'0')*pow(10,i);
            }
        }
        sprintf(newbuf, "%08x", val);
        for (i = 0; i < 8; i++) {
            v = strchr(hex, newbuf[i]);
            v[0] > 96 ? (hex_idx = v[0]-87) : (hex_idx = v[0]-48);
            strcat(buffer, binary[hex_idx]);
        }
        strncat(buffer, ";", 1);
    }
    else if (!strncmp(newbuf, "float:", 6)) {
        v = strchr(newbuf, '#');
        for (i = 1; v[i] != 0; i++) num[i-1] = v[i];
        if (num[9]) num[9] = 0;
        dectoFloat(num, fp);
        strcat(buffer, fp);
        strncat(buffer, ";", 1);
    }
}

void writeData(char *fname, int n, int funcCount) {
    FILE *in;
    FILE *out;
    int i;
    char buffer[MAX_TEXT];
	for(i = 0;i < MAX_TEXT;i++) buffer[i] = 0;
    out = fopen("data.dat", "w");
    if ((in = fopen(fname, "r")) == NULL) {
        printf(RED "Source code missing" RESET "\n");
        exit(1);
    }
    for (i = 0; i < n; i++) {
        if (fgets(buffer, MAX_TEXT, in) != NULL) {
            if (buffer[MAX_TEXT-1] != 0) buffer[MAX_TEXT-1] = 0;
            parseData(buffer, i + funcCount);
            fprintf(out, "%s\n", buffer);
        }
    }
        printf(GREEN "data.dat created." RESET "\n");
        fclose(in);
        fclose(out);
        remove(fname);
}

void writeFunc(char *fname, int table[], int n) {
    FILE *in;
    FILE *out;
    int i;
    char buffer[MAX_TEXT];
	for(i = 0;i < MAX_TEXT;i++) buffer[i] = 0;
    out = fopen("func.dat", "w");
    if ((in = fopen(fname, "r")) == NULL) {
        printf(RED "Source code missing" RESET "\n");
        exit(1);
    }
    for (i = 0; i < n; i++) {
        if (fgets(buffer, MAX_TEXT, in) != NULL) {
			if(buffer[MAX_TEXT-1] != 0) buffer[MAX_TEXT-1] = 0;
            parseFunc(buffer, table[i], i);
            fprintf(out, "%s\n", buffer);
        }
    }
    printf(GREEN "func.dat created." RESET "\n");
    fclose(in);
    fclose(out);
    remove(fname);
}

void getTable(int table[], int dataLine, int funcLine) {
    FILE *d;
    FILE *f;
    int i, j, k;
    int sum = 0;
    char currSym;
    char dataBuf[MAX_TEXT];
    int read = 0;
    for (i = 0; i < MAX_TEXT; i++) dataBuf[i] = 0;
    char funcBuf[MAX_TEXT];
    for (i = 0; i < MAX_TEXT; i++) funcBuf[i] = 0;
    if ((d = fopen("data.asm", "r")) == NULL) {
        printf(RED "Source code missing" RESET "\n");
        exit(1);
    }
    if ((f = fopen("func.asm", "r")) == NULL) {
        printf(RED "Source code missing" RESET "\n");
        exit(1);
    }
    for (i = 0; i < dataLine; i++) {
        rewind(f);
        if (fgets(dataBuf, MAX_TEXT, d) != NULL) {
            removeSpace(dataBuf);
            currSym = 0;
            for (k = 0; dataBuf[k] != 0; k++) {
                if (dataBuf[k] == ':') {
                    currSym = dataBuf[k+1];
                    break;
                }
            }
            for (j = 0; j < funcLine; j++) {
                if (fgets(funcBuf, MAX_TEXT, f) != NULL) {
                    removeSpace(funcBuf);
                    if (!strncmp(funcBuf,"ld",2) || !strncmp(funcBuf, "ldf",3)) {
                        for (k = 0; funcBuf[k] != 0; k++) {
                            if (funcBuf[k] == ',') {
                                if (funcBuf[k+1] == currSym)
                                    table[j] = funcLine - j + i-1;
                            }
                        }

                    }
                }
            }
        }
    }
    printf(GREEN "Symbol table generated." RESET "\n");
    fclose(d);
    fclose(f);
}

int countNum(char* buffer, char target) {
    char* pch = strchr(buffer, target);
    int ctr = 0;
    while (pch != NULL) {
        pch = strchr(pch+1, target);
        ctr++;
    }
    return ctr;
}

int checkSyntax(char buffer[], int line) {
    int errorCount = 0;
    char* pch1;
    char* pch2;
    int i;
    char newbuf[MAX_TEXT];
    for (i = 0; i < MAX_TEXT; i++) newbuf[i] = 0;
    int reg_idx = 0;
    int ctr = 0;
    int flagCount = 0;
	eraseSpace(buffer, newbuf);
    removeNewline(buffer);
    if (!strncmp(newbuf, "@", 1)) return 0;
    else if (!strncmp(newbuf, "int", 3) || !strncmp(newbuf, "float", 5)) {
        flagCount = countNum(newbuf, ':');
        if (flagCount != 1) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Missing \':\'\n\n");
            errorCount++;
        }
        flagCount = countNum(newbuf, '#');
        if (flagCount != 1) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Incorrect number of constants used. 1 is  specified, but %d are provided.\n\n", flagCount);
            errorCount++;
        }
    }
	else if (!strncmp(newbuf, "pause", 5)) { //pse
        if (newbuf[5] != 0) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Syntax error: Did you mean: pause\n\n");
            errorCount++;
        }
    }
    else if (!strncmp(newbuf, "ret", 5)) { //ret
        if (newbuf[3] != 0) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Syntax error: Did you mean: ret\n\n");
            errorCount++;
        }
    }
    else if (!strncmp(newbuf, "add", 3) || !strncmp(newbuf, "sub", 3) || !strncmp(newbuf, "and", 3) || !strncmp(newbuf, "mul", 3) || !strncmp(newbuf, "sftl", 4) || !strncmp(newbuf, "sftr", 4) || !strncmp(newbuf, "lr", 2) || !strncmp(newbuf, "sa", 2)) {
        pch1 = strchr(newbuf, '#');
        if (pch1 != NULL) { //addi or subi or andi or sftl or sftr
            flagCount = countNum(newbuf, ',');
            if (flagCount != 2) {
                printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
                printf("Missing \',\'\n\n");
                errorCount++;
            }
            flagCount = countNum(newbuf, '$');
            if (flagCount != 2) {
                printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
                printf("Incorrect number of registers used. 2 are specified, but %d are provided.\n\n", flagCount);
                errorCount++;
            }
            flagCount = countNum(newbuf, '#');
            if (flagCount != 1) {
                printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
                printf("Incorrect number of constants used. 1 is specified, but %d are provided.\n\n", flagCount);
                errorCount++;
            }
            pch2 = strchr(newbuf, '$');
            ctr = 0;
            while (pch2 != NULL && ctr <= 1) {
                reg_idx = pch2[2] - 48;
                if (reg_idx < 0 || reg_idx > 2) {
                    printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
                    printf("Invalid register %c%c\n\n", pch2[1], pch2[2]);
                    errorCount++;
                }
                pch2 = strchr(pch2+1, '$');
                ctr++;
            }
            if (pch1[1] == 0 || pch1[1] == '\n' || pch1[1] == '\r') {
                printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
                printf("No number specified after \'#\'\n\n");
                errorCount++;
            }
        }
        else { //add(f) or sub(f) or and(f) or mul(f)
            flagCount = countNum(newbuf, ',');
            if (flagCount != 2) {
                printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
                printf("Missing \',\'\n\n");
                errorCount++;
            }
            flagCount = countNum(newbuf, '$');
            if (flagCount != 3) {
                printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
                printf("Incorrect number of registers used. 3 are specified, but %d are provided.\n\n", flagCount);
                errorCount++;
            }
            flagCount = countNum(newbuf, '#');
            if (flagCount != 0) {
                printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
                printf("Incorrect number of constants used. None are specified, but %d are provided.\n\n", flagCount);
                errorCount++;
            }
            pch2 = strchr(newbuf, '$');
            ctr = 0;
            while (pch2 != NULL && ctr <= 2) {
                reg_idx = pch2[2] - 48;
                if (reg_idx < 0 || reg_idx > 2) {
                    printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
                    printf("Invalid register %c%c\n\n", pch2[1], pch2[2]);
                    errorCount++;
                }
                pch2 = strchr(pch2+1, '$');
                ctr++;
            }
        }
    }
    else if (!strncmp(newbuf, "mvhi", 4) || !strncmp(newbuf, "mvlo", 4) || !strncmp(newbuf, "out", 3)) { //mvhi or mvlo or out
        flagCount = countNum(newbuf, ',');
        if (flagCount != 0) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Missing \',\'\n\n");
            errorCount++;
        }
        flagCount = countNum(newbuf, '$');
        if (flagCount != 1) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Incorrect number of registers used. 1 is specified, but %d are provided.\n\n", flagCount);
            errorCount++;
        }
        flagCount = countNum(newbuf, '#');
        if (flagCount != 0) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Incorrect number of constants used. None are specified, but %d are provided.\n\n", flagCount);
            errorCount++;
        }
        pch1 = strchr(newbuf, '$');
        if (pch1 != NULL) {
            reg_idx = pch1[2] - 48;
            if (reg_idx < 0 || reg_idx > 2) {
                printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
                printf("Invalid register %c%c\n\n", pch1[1], pch1[2]);
                errorCount++;
            }
        }
    }
    else if (!strncmp(newbuf, "div", 3) || !strncmp(newbuf, "not", 3) || !strncmp(newbuf, "cmp", 3) || !strncmp(newbuf, "mv", 2) || !strncmp(newbuf, "rnd", 3)) { //div(f) or not or cmp(f) or mv(f) or rnd
        flagCount = countNum(newbuf, ',');
        if (flagCount != 1) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Missing \',\'\n\n");
            errorCount++;
        }
        flagCount = countNum(newbuf, '$');
        if (flagCount != 2) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Incorrect number of registers used. 2 are specified, but %d are provided.\n\n", flagCount);
            errorCount++;
        }
        flagCount = countNum(newbuf, '#');
        if (flagCount != 0) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Incorrect number of constants used. None are specified, but %d are provided.\n\n", flagCount);
            errorCount++;
        }
        pch1 = strchr(newbuf, '$');
        ctr = 0;
        while (pch1 != NULL && ctr <= 1) {
            reg_idx = pch1[2] - 48;
            if (reg_idx < 0 || reg_idx > 2) {
                printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
                printf("Invalid register %c%c\n\n", pch1[1], pch1[2]);
                errorCount++;
            }
            pch1 = strchr(pch1+1, '$');
            ctr++;
        }
    }
    else if (!strncmp(newbuf, "li", 2)) { //li
        flagCount = countNum(newbuf, ',');
        if (flagCount != 1) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Missing \',\'\n\n");
            errorCount++;
        }
        flagCount = countNum(newbuf, '$');
        if (flagCount != 1) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Incorrect number of registers used. 1 is specified, but %d are provided.\n\n", flagCount);
            errorCount++;
        }
        flagCount = countNum(newbuf, '#');
        if (flagCount != 1) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Incorrect number of constants used. 1 is specified, but %d are provided.\n\n", flagCount);
            errorCount++;
        }
        pch1 = strchr(newbuf, '$');
        if (pch1 != NULL) {
            reg_idx = pch1[2] - 48;
            if (reg_idx < 0 || reg_idx > 2) {
                printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
                printf("Invalid register %c%c\n\n", pch1[1], pch1[2]);
                errorCount++;
            }
        }
    }
    else if (!strncmp(newbuf, "ld", 2)) { //ld
        flagCount = countNum(newbuf, ',');
        if (flagCount != 1) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Missing \',\'\n\n");
            errorCount++;
        }
        flagCount = countNum(newbuf, '$');
        if (flagCount != 1) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Incorrect number of registers used. 1 is specified, but %d are provided.\n\n", flagCount);
            errorCount++;
        }
        flagCount = countNum(newbuf, '#');
        if (flagCount != 0) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Incorrect number of constants used. None are specified, but %d are provided.\n\n", flagCount);
            errorCount++;
        }
        pch1 = strchr(newbuf, '$');
        if (pch1 != NULL) {
            reg_idx = pch1[2] - 48;
            if (reg_idx < 0 || reg_idx > 2) {
                printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
                printf("Invalid register %c%c\n\n", pch1[1], pch1[2]);
                errorCount++;
            }
        }
        pch1 = strchr(newbuf, ',');
        if (pch1 != NULL) {
            if (pch1[2] != 0 && pch1[2] != '\n' && pch1[2] != '\r') {
                printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
                printf("Variable label length is more than 1 char.\n\n");
                errorCount++;
            }
        }
    }
    else if (!strncmp(newbuf, "jsr", 3)) { //jsr
        flagCount = countNum(newbuf, ',');
        if (flagCount != 0) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Contains extra \',\'\n\n");
            errorCount++;
        }
        flagCount = countNum(newbuf, '$');
        if (flagCount != 0) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Incorrect number of registers used. None are specified, but %d are provided.\n\n", flagCount);
            errorCount++;
        }
        flagCount = countNum(newbuf, '#');
        if (flagCount != 1) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Incorrect number of constants used. 1 is specified, but %d are provided.\n\n", flagCount);
            errorCount++;
        }
    }
    else if (!strncmp(newbuf, "if", 2)) { //if
        flagCount = countNum(newbuf, ',');
        if (flagCount != 0) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Contains extra \',\'\n\n");
            errorCount++;
        }
        flagCount = countNum(newbuf, '$');
        if (flagCount != 0) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Incorrect number of registers used. None are specified, but %d are provided.\n\n", flagCount);
            errorCount++;
        }
        flagCount = countNum(newbuf, '#');
        if (flagCount != 1) {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Incorrect number of constants used. 1 is specified, but %d are provided.\n\n", flagCount);
            errorCount++;
        }
        if (newbuf[2] != 'n' && newbuf[2] != 'z' && newbuf[2] != 'p') {
            printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
            printf("Invalid syntax if%c\n\n", newbuf[2]);
            errorCount++;
        }
    }
    else { //unknown instruction
        printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
        printf("Unknown instruction \'%s\'\n\n", buffer);
        errorCount++;
    }
    if(pch1 = strchr(newbuf, ';')) { //terminal ';'
        printf(RED "Error" RESET ": In line %d: %s\n", line, buffer);
        printf("Instruction terminates with \';\'\n\n");
        errorCount++;
    }
    return errorCount;
}

void checkError(char* filename) {
	FILE* f;
	if ((f = fopen(filename, "r")) == NULL) {
        printf(RED "Source code missing" RESET "\n");
        exit(1);
    }
    int i, j, k;
    int errorCount = 0;
    int except = 0;
    char buffer[MAX_TEXT];
    for (i = 0; i < MAX_TEXT; i++) buffer[i] = 0;
    int dataLine = countlines(filename);
    for (i = 1; i <= dataLine; i++) {
        if (fgets(buffer, MAX_TEXT, f) == NULL) {
         	printf(RED "Cannot read file" RESET "\n");
         	exit(1);
        }
        errorCount += checkSyntax(buffer, i);
    }
    if (errorCount != 0) {
        (errorCount == 1) ? printf("%d error generated.\n", errorCount) : printf("%d errors generated.\n", errorCount);
        exit(1);
    }
}

void mergeFile(char* fname1, char* fname2, char* fname3) {
    FILE * fptr1;
	if ((fptr1 = fopen(fname1, "r")) == NULL) {
        printf(RED "Source code missing" RESET "\n");
        exit(1);
    }
    FILE * fptr2;
    if ((fptr2 = fopen(fname2, "r")) == NULL) {
        printf(RED "Source code missing" RESET "\n");
        exit(1);
    }
    FILE * out = fopen(fname3, "w+");
    char c = fgetc(fptr1);
    while(c != EOF) {
        fputc(c, out);
        c = fgetc(fptr1);
    }
    c = fgetc(fptr2);
    while (c != EOF) {
        fputc(c, out);
        c = fgetc(fptr2);
    }
    fclose(fptr1);
    fclose(fptr2);
    fclose(out);
    remove(fname1);
    remove(fname2);
}

void getSv(char* source, char* dest, int size) {
    int i;
    char newbuf[MAX_TEXT];
    for(i = 0; i < MAX_TEXT; i++) newbuf[i] = 0;
    char buffer[MAX_TEXT];
    for(i = 0; i < MAX_TEXT; i++) buffer[i] = 0;
    FILE * in1;
    if ((in1 = fopen("system1.dat", "r")) == NULL) {
        printf(RED "Source file missing" RESET "\n");
        exit(1);
    }
    FILE * in2;
    if ((in2 = fopen(source, "r")) == NULL) {
        printf(RED "Source file missing" RESET "\n");
        exit(1);
    }
    FILE * in3;
    if ((in3 = fopen("system2.dat", "r")) == NULL) {
        printf(RED "Source file missing" RESET "\n");
        exit(1);
    }
    FILE * out = fopen(dest, "w+");
    char c = fgetc(in1);
    while(c != EOF) {
        fputc(c, out);
        c = fgetc(in1);
    }
    c = fgetc(in2);
    while (c != EOF) {
        fputc(c, out);
        c = fgetc(in2);
    }
    fprintf(out, "        for (integer i = %d; i <= size - 1; i = i + 1)\n", size);
    c = fgetc(in3);
    while (c != EOF) {
        fputc(c, out);
        c = fgetc(in3);
    }
    fclose(in1);
    fclose(in2);
    fclose(in3);
    fclose(out);
    printf(GREEN "%s generated." RESET " Line count: %d. Memory usage: %d Bytes.\n", dest, size, 32*size);
    remove(source);
}

int main() {
    int i;
    char filename[MAX_TEXT];
    int status;
    printf("Removing conflicting executable files ...\n");
    status = remove("memory.sv");
    if (status == 0) printf("Conflicting file removed.\n");
    else printf("No conflicting files detected.\n");
    printf("===========================\n");
    printf("Enter source code name: ");
    scanf("%s", filename);
    checkError(filename);
    getData(filename);
    int dataLine = countlines("data.asm");
    getFunc(filename);
    int funcLine = countlines("func.asm");
    int table[funcLine];
    for (i = 0; i < funcLine; i++) table[i] = 0;
    getTable(table, dataLine, funcLine);
    writeData("data.asm", dataLine, funcLine);
    writeFunc("func.asm", table, funcLine);
    mergeFile("func.dat", "data.dat", "memory.dat");
    getSv("memory.dat", "memory.sv", dataLine + funcLine);
    return 0;
}
