#ifndef _RC4_H_
#define _RC4_H_
#include <windows.h>

void l_swap_byte(BYTE *a, BYTE *b) {
	BYTE t = *a;
	*a = *b;
	*b = t;
}

VOID rc4_crypt(LPBYTE pbData, DWORD dwDataLen, LPCSTR key)
{
	BYTE x, y, state[256];
	DWORD i, i2;

	for (i = 0; i < 256; i++) 
	{
		state[(BYTE)i] = (BYTE)i;
	}

	for (i2 = i = x = y = 0; i < 256; i++)
	{
		y = ((BYTE)key[i2++] + state[i] + y) & 0xFF;
		l_swap_byte(&state[i], &state[y]);
		if (key[i2] == 0)
		{
			i2 = 0;
		}
	}

	for (i = x = y = 0; i < dwDataLen; i++)
	{
		x = (x + 1) & 0xFF;
		y = (state[x] + y) & 0xFF;
		l_swap_byte(&state[x], &state[y]);
		pbData[i] ^= state[(BYTE)((BYTE)state[x]+(BYTE)state[y])];
	}
}

VOID rc4_crypt(LPVOID lpData, DWORD dwSize, LPCSTR lpszKey)
{
	rc4_crypt((LPBYTE) lpData, dwSize, lpszKey);
}
#endif