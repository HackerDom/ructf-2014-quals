#ifndef PARSER_H
#define PARSER_H

#include "print.h"

#define starts_with(x, y) !strncmp(x, y, strlen(y))

#define SZ_NAME 32

struct player_info
{
	char name[SZ_NAME];
	int kills;
	int deaths;
	float kdr;
	int time_seconds;
	char (*kill_list)[SZ_NAME];
	char (*death_list)[SZ_NAME];
};

struct player_info *parse_files(const char dirs[][SZ_PATH], int dir_count, int *player_count);

#endif