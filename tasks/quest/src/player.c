#include <string.h>

#include "player.h"
#include "level.h"
#include "colors.h"
#include "inventory.h"
#include "logging.h"

void add_inventory(struct player_info *player, struct inv_item *item)
{
	int i;

	for (i = 0; i < SZ_INV; i++)
	{
		if (!strcmp(player->inventory[i].name, item->name))
		{
			player->inventory[i].count += item->count;
			return;
		}
	}
	for (i = 0; i < SZ_INV; i++)
	{
		if (player->inventory[i].count == 0)
		{
			player->inventory[i] = *item;
			return;
		}
	}
}

int check_inventory(struct player_info *player, struct inv_item *item)
{
	int i;

	for (i = 0; i < SZ_INV; i++)
	{
		if (!strcmp(player->inventory[i].name, item->name) && player->inventory[i].count >= item->count)
			return 1;
	}
	return 0;
}

void get_options(struct opt_info **options, struct player_info *player, int *option_count)
{
	int i, j;
	int fit;

	*option_count = 0;
	for (i = 0; i < player->location->header.opt_count; i++)
	{
		fit = 1;
		for (j = 0; j < player->location->options[i].header.inv_count; j++)
		{
			if (!check_inventory(player, &player->location->options[i].inventory[j]))
			{
				fit = 0;
				break;
			}
		}
		if (!fit)
			continue;
		options[(*option_count)++] = &player->location->options[i];
	}
}

void insert_name(char *text, const char *name)
{
	char *sub, *prev_sub;
	char new_buf[SZ_DISPLAY_TEXT];
	memset(new_buf, 0, sizeof(new_buf));

	debug("Inserting name %s", name);

	sub = prev_sub = text;
	while ((sub = strstr(sub, "%n")) != NULL)
	{
		strncat(new_buf, prev_sub, sub - prev_sub);
		strcat(new_buf, BOLD);
		strcat(new_buf, name);
		strcat(new_buf, NORMAL);
		sub += 2;
		prev_sub = sub;
	}
	strncat(new_buf, prev_sub, strlen(text) + text - prev_sub);

	strcpy(text, new_buf);
}

void render_description(char *buffer, struct player_info *player)
{
	strcpy(buffer, player->location->header.desc);
	insert_name(buffer, player->name);
}

void render_options(char option_text[][SZ_OPTION], struct player_info *player, int *option_count)
{
	struct opt_info *options[SZ_LOC_OPTS];
	int i;

	debug("Rendering options");

	if (player->location->header.is_auto)
	{
		*option_count = 0;
		return;
	}

	get_options(options, player, option_count);

	debug("Got options");

	for (i = 0; i < *option_count; i++)
	{
		strcpy(option_text[i], options[i]->header.text);
		insert_name(option_text[i], player->name);
	}
}

void enter_location(struct player_info *player, struct loc_info *location)
{
	int i, option;

	debug("Entering location (%d opt, %d inv)", location->header.opt_count, location->header.inv_count);

	debug("Player inv list:");
	for (i = 0; i < SZ_INV; i++)
	{
		if (player->inventory[i].count > 0)
			debug("%d: %s (%d)", i, player->inventory[i].name, player->inventory[i].count);
	}

	player->location = location;
	for (i = 0; i < location->header.inv_count; i++)
	{
		add_inventory(player, &location->inventory[i]);
	}
}

void init_player(struct player_info *player, struct level_info *level)
{
	debug("Initializing player on level %s", level->header.name);

	player->level = level;
	memset(player->inventory, 0, sizeof(player->inventory));
	enter_location(player, &level->locations[level->header.start_loc]);
}

int process_transition(struct player_info *player, int option)
{
	struct opt_info *options[SZ_LOC_OPTS];
	int option_count;

	get_options(options, player, &option_count);
	if (option < 0 || option >= option_count)
		return 1;
	if (options[option]->header.target < 0)
		return 0;
	enter_location(player, &player->level->locations[options[option]->header.target]);
	return 1;
}