#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>

#include "print.h"
#include "stats.h"
#include "parser.h"

#define MAX_INPUT 1000
#define SZ_INPUT 1024

char log_dirs[][SZ_PATH] = {
	"server",
	"sniperserver",
	"instagib",
	"ctf"
};
int log_dir_count = 4;

enum
{
	CMD_NONE = 0,
	CMD_QUIT,
	CMD_STATS,
	CMD_SUMMARY,
	CMD_HELP,
	CMD_RATING
};

void truncate_output(char *data)
{
	strcpy(data + MAX_OUTPUT, "...\n(Output is too long, truncated)\n");
}

void truncate_name(char *name)
{
	name[SZ_NAME - 1] = 0;
}

void chop(char *text)
{
	char *end;

	end = strpbrk(text, "\r\n");
	if (end != NULL)
		*end = 0;
}

int parse_command(const char *command, char *arg)
{
	char *arg_pos;

	if (starts_with(command, "quit"))
		return CMD_QUIT;
	if (starts_with(command, "help"))
		return CMD_HELP;
	if (starts_with(command, "rating"))
		return CMD_RATING;

	arg_pos = strchr(command, ' ');
	if (arg_pos == NULL)
		return CMD_NONE;
	strcpy(arg, arg_pos + 1);
	chop(arg);
	if (starts_with(command, "stats"))
		return CMD_STATS;
	if (starts_with(command, "summary"))
		return CMD_SUMMARY;
	return CMD_NONE;
}

int receive_command(int sockfd, char *arg)
{
	int bytes_read;
	char buffer[SZ_INPUT];

	memset(buffer, 0, sizeof(buffer));
	bytes_read = read(sockfd, buffer, MAX_INPUT);

	debug("Read %d bytes", bytes_read);

	return bytes_read == 0 ? CMD_QUIT : parse_command(buffer, arg);
}

void process_client(int sockfd)
{
	char arg_buffer[SZ_INPUT];
	int cmd;
	int error_code;
	int opt_size;

	debug("Processing client...");

	while (1)
	{
		output(sockfd, "> ");
		cmd = receive_command(sockfd, arg_buffer);
		truncate_name(arg_buffer);
		switch (cmd)
		{
		case CMD_QUIT:
			return;
		case CMD_NONE:
		case CMD_HELP:
			show_help(sockfd);
			break;
		case CMD_RATING:
			show_rating(sockfd, (const char (*)[SZ_PATH])log_dirs, log_dir_count);
			break;
		case CMD_SUMMARY:
			show_summary(sockfd, (const char (*)[SZ_PATH])log_dirs, log_dir_count, arg_buffer);
			break;
		case CMD_STATS:
			show_stats(sockfd, (const char (*)[SZ_PATH])log_dirs, log_dir_count, arg_buffer);
			break;
		}
	}
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
	const int port = 16711;
	start_listener(port);
}

