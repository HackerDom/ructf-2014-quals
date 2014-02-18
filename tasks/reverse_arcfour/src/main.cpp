#include <windows.h>
#include <stdio.h>
#include "rc4.h"

#define FLAG_LEN 32

// .rdata section
const char *fake_flag = "oh_nasty_boy!you_hacked_me:(hehe";
char *user_pass;

int check_pass() {
	char crypted_flag[] = {
		'\xAE', '\xAF', '\xB7', '\x34', '\xDB', '\x7C', '\x28', '\x1F', '\x7A', '\x7F', '\x8C', '\x94', '\x2E', '\xF9', '\x69', '\x24',
		'\x9F', '\x7D', '\x27', '\xC1', '\xC4', '\x09', '\x45', '\x7F', '\x75', '\xEE', '\x45', '\x97', '\x8D', '\xAF', '\x79', '\x1F',
		'\x00'
	};
	char key[] = {
		'\x86', '\xde', '\x9a', '\xf8', '\xdf', '\xf5', '\x85', '\xe9', '\xdd', '\x85', '\xef', '\x00' // 0h,NiC3_k3Y ^ 0xb6
	};
	unsigned char BeingDebugged = 0;
	int old_eax, old_esp;
	// obfuctated IsDebuggerPresent
	__asm {
		mov old_eax, eax
		mov old_esp, esp

		mov eax, 2200h           ; eax = 00002200
		ror eax, 69h             ; eax = 00000011
		xor eax, 9               ; eax = 00000018
		push dword ptr fs:[eax]  ; [esp] = TIB
		add dword ptr [esp], 16h ; [esp] = TIB + 16h
		xor eax, 3Eh             ; eax = 00000026
		pop esp                  ; esp = TIB + 16h
		xor esp, eax             ; esp = TIB.PEB
		pop esp                  ; esp = PEB
		shr eax, 4               ; eax = 00000002
		add esp, eax             ; esp = PEB.BeingDebugged
		pop eax                  ; eax = value of BeingDebugged
		mov BeingDebugged, al

		mov eax, old_eax
		mov esp, old_esp
	}
	for (unsigned int i = 0; i < sizeof(key) - 1; ++i) {
		key[i] ^= BeingDebugged;
	}
	rc4_crypt(user_pass, FLAG_LEN, key);

	for (int i = 0; i < FLAG_LEN; ++i) {
		if (user_pass[i] != crypted_flag[i]) return 0;
	}
	return 1;
}

#include <string>
int main(int argc, char **argv)
{
	/*
	char flag[] = "623ca3408f971883ccf6180eab2b3cf5";
	rc4_crypt(flag, FLAG_LEN, "0h,NiC3_k3Y");
	FILE *f = fopen("crypted_flag", "wb");
	fwrite(flag, 1, FLAG_LEN, f);
	fclose(f);
	return 0;
	/**/
	//argv[1] = "623ca3408f971883ccf6180eab2b3cf5";
	if (argc != 2) return 0;
	if (lstrlenA(argv[1]) != FLAG_LEN) return 0;
	user_pass = argv[1];

	int result = 0;
	 __try {
		 __asm {
			mov ecx, [argv]
			mov edx, [ecx+4]
			push edx;
			// ud2
			nop;
			nop;
			mov eax, fake_flag;
			push eax;
			call ds:lstrcmpA;
			and eax, 1;
			xor al, 1;
			mov result, eax;
		}
	} __except(GetExceptionCode() == EXCEPTION_ILLEGAL_INSTRUCTION ? 
			EXCEPTION_EXECUTE_HANDLER : EXCEPTION_CONTINUE_SEARCH)
	{
		__asm {
			call check_pass;    // mov eax, 0xD11E3A; в hxd потом заменю на B8 3A 1E D1 00 по смещению 6C8, иначе визуалка не вставит функцию в exe
			xor eax, 0x910EEA;
			jz lbl_ret;
			push lbl_call_eax;
			add [esp], 3;
		lbl_ret:
			ret;
		lbl_call_eax:
			mov eax, 0xD0FF5B21; // call eax
			mov result, eax;
		}
	}
	puts(result == 1 ? "good job, put flag into system" : "nope...");
	//printf("%s", result ? "good job, put flag into system" : "nope...");
}