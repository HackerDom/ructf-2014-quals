#ifndef LEVEL_H
#define LEVEL_H

#include "inventory.h"

#define SZ_DESC 512
#define SZ_LOC_OPTS 16
#define SZ_OPTION 64

#pragma pack(push, 1)

struct level_info
{
	struct
	{
		char name[64];
		char locked;
		int loc_count;
		int start_loc;
	} header;
	struct loc_info
	{
		struct
		{
			int opt_count;
			int inv_count;
			char is_auto;
			char desc[SZ_DESC];
		} header;
		struct opt_info
		{
			struct
			{
				int inv_count;
				int target;
				char text[SZ_OPTION];
			} header;
			struct inv_item *inventory;
		} *options;
		struct inv_item *inventory;
	} *locations;
};

void load_level(const char *path, struct level_info *info);

#endif