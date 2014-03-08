#include <stdio.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <sys/stat.h> 
#include <netinet/in.h>
#include <dirent.h>
#include <string.h>
#include <stdlib.h>

#include "print.h"

#define HINT_SIDE 16
#define SZ_HINT (HINT_SIDE * HINT_SIDE)

char hint[SZ_HINT];

void draw_hint(char *canvas, const char *user_data)
{
	int fore, back, new_fore, new_back, i, length;
	unsigned char color;
	char escape[16];
	char symbol;
	char *canvas_ptr;

	length = strlen(user_data);
	symbol = user_data[0];
	fore = back = -1;
	canvas_ptr = canvas;
	for (i = 0; i < SZ_HINT; i++)
	{
		color = hint[i] ^ user_data[i % length];
		new_fore = color & 7;
		new_back = (color >> 3) & 7;
		if (new_fore != fore || new_back != back)
		{
			if (new_fore != fore && new_back != back)
				sprintf(escape, "\e[3%d;4%dm", new_fore, new_back);
			else if (new_fore != fore)
				sprintf(escape, "\e[3%dm", new_fore);
			else
				sprintf(escape, "\e[4%dm", new_back);
			memcpy(canvas_ptr, escape, strlen(escape));
			canvas_ptr += strlen(escape);
		}
		fore = new_fore;
		back = new_back;
		*(canvas_ptr++) = symbol;
		if ((i + 1) % HINT_SIDE == 0)
		{
			fore = 7;
			back = 0;
			sprintf(escape, "\e[0m\n");
			memcpy(canvas_ptr, escape, strlen(escape));
			canvas_ptr += strlen(escape);
		}
	}
}
  
void check_flag(int sockfd, const char *input)
{
	char hint_image[HINT_SIDE * 5 + SZ_HINT * 9 + SZ_HINT];
	char *flag = hint_image + sizeof(hint_image) - SZ_HINT;
	FILE *f;

	memset(hint_image, 0, sizeof(hint_image));

	f = fopen("flag", "r");
	fgets(flag, SZ_HINT, f);
	fclose(f);

	if (!strcmp(flag, input))
	{
		output(sockfd, "This is definintely not an incorrect one!\n");
		return;
	}
	output(sockfd, "How pathetic. Here, have a hint:\n");
	draw_hint(hint_image, input);
	output(sockfd, hint_image);
}

void process_client(int sockfd)
{
	char buffer[SZ_HINT * 2];

	output(sockfd, "So, what do you think the flag is?\n");
	output(sockfd, "> ");
	memset(buffer, 0, sizeof(buffer));
	read(sockfd, buffer, SZ_HINT);

	check_flag(sockfd, buffer);

	shutdown(sockfd, SHUT_WR);

	close(sockfd);
}

void load_hint(const char *path)
{
	FILE *f;

	f = fopen(path, "r");
	fread(hint, 1, SZ_HINT, f);
	fclose(f);
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
	const int port = 16712;
	const char *path = "hint";
	load_hint(path);
	start_listener(port);
}