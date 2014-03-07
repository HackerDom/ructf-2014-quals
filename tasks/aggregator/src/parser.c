#include <sys/stat.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>
#include <stdio.h>
#include <dirent.h>

#include "parser.h"

#define SZ_PLAYERS 16
#define SZ_LOG_LINE 256
#define SZ_MAX_PATH 256

void parse_line(char *line, struct player_info players[], float *level_time)
{
	char *pch, *pname;
	int player_id, victim_id;

	pch = strtok(line, "\t");
	*level_time = atof(pch);
	pch = strtok(NULL, "\t");
	if (pch == NULL)
		return;
	if (!strcmp(pch, "player"))
	{
		pch = strtok(NULL, "\t");
		if (!strcmp(pch, "Connect"))
		{
			pname = strtok(NULL, "\t");
			pch = strtok(NULL, "\t");
			player_id = atoi(pch);
			strcpy(players[player_id].name, pname);
			players[player_id].time_seconds = *level_time;
		}
		else if (!strcmp(pch, "Disconnect"))
		{
			pch = strtok(NULL, "\t");
			player_id = atoi(pch);
			players[player_id].time_seconds -= *level_time;
		}
	}
	else if (!strcmp(pch, "kill"))
	{
		pch = strtok(NULL, "\t");
		player_id = atoi(pch);
		strtok(NULL, "\t"); //weapon
		pch = strtok(NULL, "\t");
		victim_id = atoi(pch);
		players[player_id].kill_list = realloc(players[player_id].kill_list, 
			(players[player_id].kills + 1) * SZ_NAME);
		strcpy(players[player_id].kill_list[players[player_id].kills++], players[victim_id].name);
		players[victim_id].death_list = realloc(players[victim_id].death_list, 
			(players[victim_id].deaths + 1) * SZ_NAME);
		strcpy(players[victim_id].death_list[players[victim_id].deaths++], players[player_id].name);
	}
	else if (!strcmp(pch, "suicide"))
	{
		pch = strtok(NULL, "\t");
		player_id = atoi(pch);
		players[player_id].death_list = realloc(players[player_id].death_list, 
			(players[player_id].deaths + 1) * SZ_NAME);
		strcpy(players[player_id].death_list[players[player_id].deaths++], players[player_id].name);
	}
}

void parse_file(const char *path, GHashTable *stats)
{
	FILE *f;
	struct player_info players[SZ_PLAYERS];
	char line[SZ_LOG_LINE];
	float level_time;
	struct player_info *pplayer;
	int i;

	memset(players, 0, sizeof(players));
	f = fopen(path, "r");

	while (!feof(f))
	{
		fgets(line, sizeof(line), f);
		parse_line(line, players, &level_time);
	}
	for (i = 0; i < SZ_PLAYERS; i++)
	{
		if (players[i].time_seconds < 0)
			players[i].time_seconds *= -1;
		else
			players[i].time_seconds = level_time - players[i].time_seconds;
		pplayer = g_hash_table_lookup(stats, players[i].name);
		if (!pplayer)
		{
			pplayer = calloc(sizeof(struct player_info), 1);
			strcpy(pplayer->name, players[i].name);
			g_hash_table_insert(stats, strdup(players[i].name), pplayer);
		}
		pplayer->kill_list = realloc(pplayer->kill_list, (pplayer->kills + players[i].kills) * SZ_NAME);
		memcpy((char *)pplayer->kill_list + pplayer->kills * SZ_NAME, players[i].kill_list, players[i].kills * SZ_NAME);
		pplayer->kills += players[i].kills;
		pplayer->death_list = realloc(pplayer->death_list, (pplayer->deaths + players[i].deaths) * SZ_NAME);
		memcpy((char *)pplayer->death_list + pplayer->deaths * SZ_NAME, players[i].death_list, players[i].deaths * SZ_NAME);
		pplayer->deaths += players[i].deaths;

		pplayer->time_seconds += players[i].time_seconds;
		pplayer->kdr = pplayer->deaths == 0 ? 0 : (float)pplayer->kills / pplayer->deaths;
	}

	fclose(f);
}

struct player_info *parse_files(const char dirs[][SZ_PATH], int dir_count, int *player_count)
{
	int i;
	struct stat file_stat;
	GHashTable *stats;
	GHashTableIter iter;
	gpointer key, value;
	struct player_info *players;
	DIR *dir;
	struct dirent *ent;
	char full_path[SZ_MAX_PATH];

	stats = g_hash_table_new(g_str_hash, g_str_equal);

	debug("Have %d dirs", dir_count);
	for (i = 0; i < dir_count; i++)
	{
		dir = opendir(dirs[i]);
		debug("Searching dir %s", dirs[i]);
		if (!dir || !strcmp(dirs[i], "ctf"))
			continue;
		while ((ent = readdir(dir)) != NULL)
		{
			sprintf(full_path, "%s/%s", dirs[i], ent->d_name);
			if (lstat(full_path, &file_stat) < 0)
			{
				error("Can't stat %s", full_path);
				continue;
			}
			if (!S_ISREG(file_stat.st_mode))
				continue;
			debug("Parsing %s", full_path);
			parse_file(full_path, stats);
		}
	}
	closedir(dir);

	*player_count = g_hash_table_size(stats);
	players = malloc(*player_count * sizeof(struct player_info));
	i = 0;
	g_hash_table_iter_init(&iter, stats);
	while (g_hash_table_iter_next(&iter, &key, &value))
	{
		players[i++] = *(struct player_info *)value;
	}
	
	g_hash_table_destroy(stats);

	return players;
}