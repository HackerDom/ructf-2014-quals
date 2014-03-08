#include <stdlib.h>
#include <glib.h>
#include <malloc.h>
#include <string.h>

#include "stats.h"
#include "print.h"
#include "parser.h"

#define min(a, b) ((a) < (b) ? (a) : (b))

#define SZ_KILLTOP 5

struct player_stats
{
	char name[SZ_NAME];
	int kills;
	int deaths;
	float kdr;
	int time_seconds;
	char kill_top[SZ_KILLTOP][SZ_NAME];
	char killed_by_top[SZ_KILLTOP][SZ_NAME];
};

struct sort_item
{
	char key[SZ_NAME];
	int value;
};

int sort_item_comparer(struct sort_item *a, struct sort_item *b)
{
	return b->value - a->value;
}

inline int *make_int(int value)
{
	int *addr;

	addr = malloc(sizeof(int));
	*addr = value;
	return addr;
}

void calc_stats(const struct player_info *players, int player_count, const char *name, struct player_stats *stats)
{
	GHashTable *kill_map, *killed_by_map;
	GHashTableIter iter;
	gpointer key, value;
	int i, item_count;
	const struct player_info *player;
	struct sort_item *items;

	kill_map = g_hash_table_new(g_str_hash, g_str_equal);
	killed_by_map = g_hash_table_new(g_str_hash, g_str_equal);

	g_hash_table_insert(kill_map, strdup(name), make_int(0));
	g_hash_table_insert(killed_by_map, strdup(name), make_int(0));

	memset(stats, 0, sizeof(struct player_stats));
	strcpy(stats->name, name);
	player = NULL;
	for (i = 0; i < player_count; i++)
	{
		if (strcmp(name, players[i].name))
			continue;
		player = &players[i];
		break;
	}
	if (player != NULL)
	{
		stats->kills = player->kills;
		stats->deaths = player->deaths;
		stats->kdr = player->kdr;
		stats->time_seconds = player->time_seconds;

		for (i = 0; i < player->kills; i++)
		{
			value = g_hash_table_lookup(kill_map, player->kill_list[i]);
			if (!value)
				g_hash_table_insert(kill_map, strdup(player->kill_list[i]), make_int(1));
			else
				g_hash_table_replace(kill_map, strdup(player->kill_list[i]), make_int(*(int *)value + 1));
		}
		for (i = 0; i < player->deaths; i++)
		{
			value = g_hash_table_lookup(killed_by_map, player->death_list[i]);
			if (!value)
				g_hash_table_insert(killed_by_map, strdup(player->death_list[i]), make_int(1));
			else
				g_hash_table_replace(killed_by_map, strdup(player->death_list[i]), make_int(*(int *)value + 1));
		}
	}
	item_count = g_hash_table_size(kill_map);
	items = malloc(item_count * sizeof(struct sort_item));
	i = 0;
	g_hash_table_iter_init(&iter, kill_map);
	while (g_hash_table_iter_next(&iter, &key, &value))
	{
		strcpy(items[i].key, key);
		items[i].value = *(int *)value;
		i++;
	}
	qsort(items, item_count, sizeof(struct sort_item), (__compar_fn_t)sort_item_comparer);
	for (i = 0; i < min(item_count, SZ_KILLTOP); i++)
		strcpy(stats->kill_top[i], items[i].key);
	free(items);

	item_count = g_hash_table_size(killed_by_map);
	items = malloc(item_count * sizeof(struct sort_item));
	i = 0;
	g_hash_table_iter_init(&iter, killed_by_map);
	while (g_hash_table_iter_next(&iter, &key, &value))
	{
		strcpy(items[i].key, key);
		items[i].value = *(int *)value;
		i++;
	}
	qsort(items, item_count, sizeof(struct sort_item), (__compar_fn_t)sort_item_comparer);
	for (i = 0; i < min(item_count, SZ_KILLTOP); i++)
		strcpy(stats->killed_by_top[i], items[i].key);
	free(items);

	g_hash_table_destroy(kill_map);
	g_hash_table_destroy(killed_by_map);
}

void show_help(int sockfd)
{
	output(sockfd, "Available commands:\n");
	output(sockfd, "help\t-- show this message\n");
	output(sockfd, "quit\t-- quit\n");
	output(sockfd, "rating\t-- show player rating\n");
	output(sockfd, "summary <player_name>\t-- show the main stats of the player\n");
	output(sockfd, "stats <player_name>\t-- show all the stats of the player\n");
}

int rating_compare(struct player_info *a, struct player_info *b)
{
	return a->kdr < b->kdr ? 1 : (a->kdr > b->kdr ? -1 : 0);
}

void show_rating(int sockfd, const char dirs[][SZ_PATH], int dir_count)
{
	struct player_info *players;
	int count, i;

	players = parse_files(dirs, dir_count, &count);
	qsort(players, count, sizeof(struct player_info), (__compar_fn_t)rating_compare);

	output(sockfd, "%16s\t%16s\t%16s\t%16s\n", "name", "total kills", "total deaths", "kills to deaths");
	for (i = 0; i < count; i++)
		output(sockfd, "%16s\t%16d\t%16d\t%16.2f\n", players[i].name, players[i].kills, players[i].deaths, players[i].kdr);

	free(players);
}

void show_summary(int sockfd, const char dirs[][SZ_PATH], int dir_count, const char *name)
{
	struct player_info *players;
	struct player_stats stats;
	int count, i;

	players = parse_files(dirs, dir_count, &count);
	calc_stats(players, count, name, &stats);

	output(sockfd, "name:\t%s\n", stats.name);
	output(sockfd, "total kills:\t%d\n", stats.kills);
	output(sockfd, "total deaths:\t%d\n", stats.deaths);
	output(sockfd, "kills to deaths:\t%f\n", stats.kdr);
}

void show_stats(int sockfd, const char dirs[][SZ_PATH], int dir_count, const char *name)
{
	struct player_info *players;
	struct player_stats stats;
	int count, i;

	players = parse_files(dirs, dir_count, &count);
	calc_stats(players, count, name, &stats);

	output(sockfd, "name:\t%s\n", stats.name);
	output(sockfd, "total kills:\t%d\n", stats.kills);
	output(sockfd, "total deaths:\t%d\n", stats.deaths);
	output(sockfd, "kills to deaths:\t%f\n", stats.kdr);
	output(sockfd, "total playing time:\t%f hours\n", stats.time_seconds / 3600.0f);
	output(sockfd, "kill top:\n");
	for (i = 0; i < SZ_KILLTOP; i++)
	{
		output(sockfd, stats.kill_top[i]);
		output(sockfd, "\n");
	}
	output(sockfd, "killed by top:\n");
	for (i = 0; i < SZ_KILLTOP; i++)
	{
		output(sockfd, stats.killed_by_top[i]);
		output(sockfd, "\n");
	}
}