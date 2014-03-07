#include <stdio.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <sys/stat.h> 
#include <netinet/in.h>
#include <dirent.h>
#include <string.h>
#include <stdlib.h>

#include "libtelnet.h"
#include "level.h"
#include "player.h"
#include "logging.h"
#include "colors.h"

#define min(a, b) ((a) < (b) ? (a) : (b))

#define SZ_LEVELS 16
#define SZ_RECV 1024
#define SZ_MAX_PATH 256

struct client_info
{
	int sockfd;
	enum
	{
		STATE_NONE = 0,
		STATE_LOGIN,
		STATE_MENU,
		STATE_GAME
	} state;
	telnet_t *telnet;
	int selected_option;
	char input_buffer[SZ_RECV];
	int input_length;
	struct player_info player;
	struct level_info *level;
};

char levels_banner[1024];
static const char banner[] = 
	"                     " bold(Welcome to RuCTF Quest Server!) "\n"
	"\n"
	"  We are happy to present you our set of interactive adventure stories.\n";
static const char name_prompt[] = "Please introduce yourself: ";

struct level_info levels[SZ_LEVELS];
int level_count;

void load_banner(const char *path)
{
	FILE *file;

	file = fopen(path, "r");
	fread(levels_banner, 1, sizeof(levels_banner), file);
	fclose(file);
}

void load_levels(const char *path)
{
	DIR *level_dir;
	struct dirent *ent;
	int level_index;
	struct stat file_stat;
	char full_path[SZ_MAX_PATH];

	info("Loading levels...");
	
	level_dir = opendir(path);
	level_index = 0;
	while ((ent = readdir(level_dir)) != NULL && level_index < SZ_LEVELS)
	{
		sprintf(full_path, "%s/%s", path, ent->d_name);
		if (lstat(full_path, &file_stat) < 0)
		{
			error("Can't stat %s", full_path);
			continue;
		}
		if (!S_ISREG(file_stat.st_mode))
			continue;
		if (!strcmp(ent->d_name, "banner.txt"))
			load_banner(full_path);
		else
			load_level(full_path, &levels[level_index++]);
	}
	level_count = level_index;
	closedir(level_dir);
}

int receive_input(struct client_info *client)
{
	int bytes_read;

	while (1)
	{
		memset(client->input_buffer, 0, SZ_RECV);
		bytes_read = read(client->sockfd, client->input_buffer, SZ_RECV);

		debug("Read %d bytes", bytes_read);

		telnet_recv(client->telnet, client->input_buffer, bytes_read);

		if (client->input_length > 0)
			return client->input_length;
	}
}

void chop(char *text)
{
	char *end;

	end = strpbrk(text, "\r\n");
	if (end != NULL)
		*end = 0;
}

void process_login(struct client_info *client, const char *name, int length)
{
	memcpy(client->player.name, name, min(length, MAX_NAME));
	chop(client->player.name);
}

void process_option(struct client_info *client, const char *item, int length)
{
	client->selected_option = atoi(item);
}

void render_menu(char *buffer, int option_count, char options[][SZ_OPTION], int can_quit)
{
	int i;
	char option_buf[SZ_OPTION];
	
	for (i = 0; i < option_count; i++)
	{
		debug("render_menu: %s", options[i]);
		sprintf(option_buf, "(" bold(%d) ") %s\n", i + 1, options[i]);
		strcat(buffer, option_buf);
	}
	if (can_quit)
		strcat(buffer, "(" bold(-1) ") Quit\n");
}

void render_location(char *buffer, struct player_info *player)
{
	char options[SZ_LOC_OPTS][SZ_OPTION];
	int option_count;

	debug("Rendering location");

	render_description(buffer, player);
	if (strlen(buffer) > 0)
		strcat(buffer, "\n\n");
	if (!player->location->header.is_auto)
	{
		render_options(options, player, &option_count);
		render_menu(buffer, option_count, options, 0);
	}
}

void game_loop(struct client_info *client, int level)
{
	char text_buf[SZ_DISPLAY_TEXT];
	memset(text_buf, 0, sizeof(text_buf));
	int next;

	init_player(&client->player, &levels[level]);

	debug("Entering game loop...");

	do
	{
		render_location(text_buf, &client->player);
		telnet_printf(client->telnet, "%s", text_buf);
		if (client->player.location->header.is_auto)
		{
			next = process_transition(&client->player, 0);
			continue;
		}
		receive_input(client);
		next = process_transition(&client->player, client->selected_option - 1);
	}
	while (next);
}

void telnet_event_handler(telnet_t *telnet, telnet_event_t *event, void *user_data)
{
	struct client_info *client = (struct client_info *)user_data;

	debug("New telnet event: %d", event->type);

	client->input_length = 0;
	switch (event->type)
	{
		case TELNET_EV_DATA:
			client->input_length = event->data.size;
			switch (client->state)
			{
				case STATE_GAME:
				case STATE_MENU:
					process_option(client, event->data.buffer, event->data.size);
					break;
				case STATE_LOGIN:
					process_login(client, event->data.buffer, event->data.size);
					break;
			}
			break;
		case TELNET_EV_SEND:
			write(client->sockfd, event->data.buffer, event->data.size);
			break;
		case TELNET_EV_ERROR:
			error("Telnet error: %s", event->error.msg);
			break;
	}
}

void send_banner(struct client_info *client)
{
	telnet_printf(client->telnet, "%s\n", banner);
}

void login_player(struct client_info *client)
{
	client->state = STATE_LOGIN;
	telnet_printf(client->telnet, "%s", name_prompt);
	receive_input(client);
}

void render_main_menu(char *buffer)
{
	int i;
	char options[SZ_LEVELS][SZ_OPTION];
	
	strcat(buffer, "\n\n");
	strcat(buffer, levels_banner);
	strcat(buffer, "\nSelect level:\n\n");

	debug("render_main_menu");
	for (i = 0; i < level_count; i++)
	{
		debug("render_main_menu: %s", levels[i].header.name);
		sprintf(options[i], 
			levels[i].header.locked 
				? "%s " colored(RED,(Locked!)) : "%s", levels[i].header.name);
	}
	debug("first option: %s (%p)", options[0], options[0]);
	render_menu(buffer, level_count, options, 1);
}

int main_menu(struct client_info *client)
{
	char menu_buf[SZ_DISPLAY_TEXT];
	memset(menu_buf, 0, sizeof(menu_buf));
	
	client->state = STATE_MENU;

	render_main_menu(menu_buf);
	
	debug("Displaying menu to %s", client->player.name);

	telnet_printf(client->telnet, "%s", menu_buf);
	receive_input(client);
	
	return client->selected_option;
}

static const telnet_telopt_t telopts[] = {
	{ TELNET_TELOPT_ECHO,      TELNET_WONT, TELNET_DONT },
	{ TELNET_TELOPT_TTYPE,     TELNET_WONT, TELNET_DONT },
	{ TELNET_TELOPT_COMPRESS2, TELNET_WONT, TELNET_DONT },
	{ TELNET_TELOPT_ZMP,       TELNET_WONT, TELNET_DONT },
	{ TELNET_TELOPT_MSSP,      TELNET_WONT, TELNET_DONT },
	{ TELNET_TELOPT_BINARY,    TELNET_WILL, TELNET_DONT },
	{ TELNET_TELOPT_NAWS,      TELNET_WONT, TELNET_DONT },
	{ -1, 0, 0 }
};
  
void process_client(int sockfd)
{
	struct client_info client;
	memset(&client, 0, sizeof(client));

	debug("Processing client...");

	client.sockfd = sockfd;
	client.telnet = telnet_init(telopts, telnet_event_handler, 0, &client);

	debug("Telnet initialized");

	send_banner(&client);
	login_player(&client);

	info("Login successful: %s", client.player.name);

	while (1)
	{
		int level = main_menu(&client);
		if (level == -1)
			break;
		level--;
		if (level < 0 || level >= level_count || levels[level].header.locked)
			continue;

		game_loop(&client, level);
	}

	info("Goodbye to %s", client.player.name);

	telnet_free(client.telnet);
}

void start_listener(int port)
{
	int sockfd, newsockfd, clilen, pid;
    struct sockaddr_in serv_addr, cli_addr;

    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) 
    {
    	error("Can't create listener socket");
        exit(1);
    }
    int yes = 1;
	if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int)) == -1)
	{
		error("Can't setsockopt");
        exit(1);
	}
    bzero((char *)&serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = INADDR_ANY;
    serv_addr.sin_port = htons(port);
	
    if (bind(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0)
    {
    	error("Can't bind listener socket");
		exit(1);
    }
	
    listen(sockfd, 5);
    clilen = sizeof(cli_addr);
    while (1) 
    {
    	info("Waiting for clients...");

        newsockfd = accept(sockfd, (struct sockaddr *)&cli_addr, &clilen);

    	info("Accepting new client");

        if (newsockfd < 0)
        {
        	error("Can't accept client");
            exit(1);
        }
		
        pid = fork();
        if (pid < 0)
        {
        	error("Can't fork");
			exit(1);
        }
        if (pid == 0)  
        {
            close(sockfd);
            process_client(newsockfd);
            exit(0);
        }
        else
        {
            close(newsockfd);
        }
    }
}

void main()
{
	const int port = 16710;
	const char *path = "levels";
	load_levels(path);
	start_listener(port);
}

