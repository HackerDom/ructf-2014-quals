#include <stdio.h>
#include <malloc.h>

#include "level.h"
#include "logging.h"

void read_inventory(FILE *file, struct inv_item **inventory, int inv_count)
{
	*inventory = malloc(sizeof(struct inv_item) * inv_count);
	fread(*inventory, sizeof(struct inv_item), inv_count, file);
}

void read_options(FILE *file, struct loc_info *location)
{
	int i;

	debug("Loading options");

	debug("MALLOC %d", sizeof(struct loc_info) * location->header.opt_count);
	location->options = malloc(sizeof(struct loc_info) * location->header.opt_count);
	for (i = 0; i < location->header.opt_count; i++)
	{
		fread(&location->options[i].header, 1, sizeof(location->options[i].header), file);
		debug("Read header (%s, %d inv, to %d)", location->options[i].header.text, 
			location->options[i].header.inv_count, location->options[i].header.target);
		read_inventory(file, &location->options[i].inventory, location->options[i].header.inv_count);
	}
}

void read_locations(FILE *file, struct level_info *level)
{
	int i;

	debug("Loading locations");

	level->locations = malloc(sizeof(struct loc_info) * level->header.loc_count);
	for (i = 0; i < level->header.loc_count; i++)
	{
		fread(&level->locations[i].header, 1, sizeof(level->locations[i].header), file);
		debug("Read header (%d opt, %d inv, %s)", level->locations[i].header.opt_count, 
			level->locations[i].header.inv_count, level->locations[i].header.is_auto ? "auto" : "non-auto");
		read_options(file, &level->locations[i]);
		read_inventory(file, &level->locations[i].inventory, level->locations[i].header.inv_count);
	}
}

void load_level(const char *path, struct level_info *level)
{
	FILE *file;
	
	info("Loading level %s", path);

	file = fopen(path, "r");
	fread(&level->header, 1, sizeof(level->header), file);

	debug("Read header (%s, %s, %d locations, start loc %d)", 
		level->header.name, level->header.locked ? "locked" : "unlocked", level->header.loc_count, level->header.start_loc);

	read_locations(file, level);
	fclose(file);
}