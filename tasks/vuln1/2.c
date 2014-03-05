#include <stdio.h> 
#include <stdlib.h>

int hash_code(const char *s, int len) {
	int h = 0;
	int i = 0;
	for (i = 0; i < len; i++) {
		h = 31*h + s[i];
	}
	return h;
}

int pass_correct(const char *pass, int len) {
	return hash_code(pass, len) == 0xb3a084;
} 

int main(int argc, char **argv)
{
	char pass[25];
	short pass_len;
	char *salt = "fd3ae9b2";
	if (argc != 2) {
		printf("usage: %s password\n", argv[0]);
		return;
	}
	pass_len = strlen(argv[1]);
	if (pass_len <= 16) {
		sprintf(pass, "%s%s", argv[1], salt);
		if (pass_correct(pass, pass_len + strlen(salt))) {
			printf("Password is correct.");
		} else {
			printf("Access denied.");
		}
	}
}
