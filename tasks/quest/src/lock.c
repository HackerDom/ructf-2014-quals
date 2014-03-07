#include <stdio.h>
#include <unistd.h>

#include "level.h"

void print_usage()
{
	printf("Usage: lock <level>\n");
}

void main(int argc, char **argv)
{
	struct level_info level;
	FILE *f;

	if (argc == 0 || access(argv[1], F_OK) < 0)
	{
		print_usage();
		return;
	}
	f = fopen(argv[1], "r+");
	fread(&level.header, 1, sizeof(level.header), f);
	if (level.header.locked)
	{
		printf("Level is already locked, unlocking...\n");
		level.header.locked = 0;
	}
	else
	{
		printf("Level is unlocked, locking...\n");
		level.header.locked = 1;
	}
	fseek(f, 0, SEEK_SET);
	fwrite(&level.header, 1, sizeof(level.header), f);
	fclose(f);
}