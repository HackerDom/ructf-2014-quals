#ifndef PLAYER_H
#define PLAYER_H

#include "level.h"
#include "inventory.h"

#define SZ_INV 16
#define MAX_NAME 60

#define SZ_DISPLAY_TEXT 1024

struct player_info
{
	char name[64];
	struct level_info *level;
	struct loc_info *location;
	struct inv_item inventory[SZ_INV];
};

void render_description(char *buffer, struct player_info *player);
void render_options(char options[][SZ_OPTION], struct player_info *player, int *option_count);
void init_player(struct player_info *player, struct level_info *level);
int process_transition(struct player_info *player, int option);

#endif