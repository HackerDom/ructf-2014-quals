#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef int bool; 
#define false 0
#define true 1
/*
bool GenAnswer(int port, char* msg)
{
	char res [1000];
	char maze [256][256];
	char hash [256*256][50];
	FILE *fl_maze, *fl_hash;

	if(port < 0 && port > 256*256 - 1)
		return false;
	
	//Считали maze из файлика	
	fl_maze = fopen("maze", "r");
	char ch;
	int i = 0, j = 0;
	while (!feof(fl_maze))
	{
		ch = getc(fl_maze);
		if (ch != '\n')
		{
			maze[i][j] = ch;
			i++;
			if(i == 256)
			{
				i = 0;
				j++;
			}
		}	
	}	
	fclose(fl_maze);
	
	//Считали hase из файлика
	char word [50];
	i = 0;
	fl_hash = fopen("hashs", "r");
	while(!feof(fl_hash))
	{
		fgets(hash[i], 50, fl_hash);
		hash[i][strlen(hash[i])-1] = 0;
		i++;
	}
	fclose(fl_hash);

	//Получили ответ
	if(strcmp(msg, hash[port]) != 0)
		return false;
	else
	{
		i = port / 256;
		j = port % 256;
		
		if(maze[i][j] != ' ')
			return false;
			
		*res = "Hello, stranger!";
	//	if(i != 0 && maze[i][j] == ' ')
	//		*res = strcat( *res, strcat("\nYou can go to Left with password: ", hash[port - 1]));
			*res = hash[port - 1];
		if(i!= 255 && maze[i][j] == ' ')
			*res = strcat( *res, strcat("\nYou can go to Rigth with password: ", hash[port + 1]));
	//	if(j != 0 && maze[i][j] == ' ')
	//		*res* = strcat( *res, strcat("\nYou can go to Up with password: ", hash[port - 256]));
		if(j != 255 && maze[i][j] == ' ')
			*res = strcat( *res, strcat("\nYou can go to Down with password: ", hash[port + 256])); 	
		return true;
	}	
		
	//printf("!%s!", hash[256*256-1]);
	//snprintf(res, sizeof(res)+30, "%d_%s", port, msg);
	
}*/

#define MAZE_SIZE 256

char maze [MAZE_SIZE][MAZE_SIZE];
char hashes [MAZE_SIZE * MAZE_SIZE][50];
	
void init()
{
	FILE *fl_maze, *fl_hash;
	
	//Считали maze из файлика	
	fl_maze = fopen("mazemap", "r");
	char ch;
	int i = 0, j = 0;
	while (!feof(fl_maze))
	{
		ch = getc(fl_maze);
		if (ch != '\n')
		{
			maze[i][j] = ch;
			j++;
			if(j == MAZE_SIZE)
			{
				j = 0;
				i++;
			}
		}	
	}	
	fclose(fl_maze);

	//Считали hase из файлика
	char word [50];
	i = 0;
	fl_hash = fopen("hashs", "r");
	while(!feof(fl_hash))
	{
		fgets(hashes[i], 50, fl_hash);
		hashes[i][strlen(hashes[i]) - 1] = 0;
		i++;
	}
	fclose(fl_hash);
}

char* GetAnswer(int port, const char* message)
{
	int port_i = port / MAZE_SIZE;
	int port_j = port % MAZE_SIZE;

	const int RESULT_SIZE = 2000;
	char* result = malloc(RESULT_SIZE * sizeof(char));
	result[0] = 0;

	if (maze[port_i][port_j] != ' ')
	{
		// TODO
		return result;
	}

	if(port == 1024)
	{
		result = strcat(result, "Hello stranger!\nYou can go down(1280) with password: ");
		result = strcat(result, hashes[port + MAZE_SIZE]);
		result = strcat(result, "\nYou can go right(1025) with password: ");
		result = strcat(result, hashes[port + 1]);
		return result;
	}
	if(port == 65535)
	{
		result = strcat(result, "Congratulations! Flag is ");
		result = strcat(result, hashes[port]);
		return result;
	}

	result = strcat(result, "Next step");
	if (port_i != 0 && maze[port_i - 1][port_j] != ' ')
	{
		result = strcat(result, "\nYou can go left with password: ");
		result = strcat(result, hashes[port - 1]);
	}
	if (port_i != MAZE_SIZE - 1 && maze[port_i + 1][port_j] != ' ')
	{
		result = strcat(result, "\nYou can go rigth with password: ");
		result = strcat(result, hashes[port + 1]);
	}
	if (port_j != 0 && maze[port_i][port_j - 1] != ' ')
	{
		result = strcat(result, "\nYou can go up with password: ");
		result = strcat(result, hashes[port - MAZE_SIZE]);
	}
	if (port_j != MAZE_SIZE - 1 && maze[port_i][port_j + 1] != ' ')
	{
		result = strcat(result, "\nYou can go down with password: ");
		result = strcat(result, hashes[port + MAZE_SIZE]);
	}
	
	return result;
}

bool isRequestValid(const int port, char* message)
{
	if (message == NULL || strlen(message) != 30)
	{
		fprintf(stderr, "Invalid request length\n");
		return false;
	}

	int port_i = port / MAZE_SIZE;
	int port_j = port % MAZE_SIZE;

	fprintf(stderr, "port = %d, %s != %s, maze[] = %c.\n", port, message, hashes[port], maze[port_i][port_j]);
	
	return maze[port_i][port_j] == ' ' && strcmp(message, hashes[port]) == 0; 
}

void main_()
{
	init();

	char* message = "b47rk42yr3r438i73znzz05o0gyxl6";

	int i;
	for (i = 1100; i <= 1101; ++i)
	{
		if (! isRequestValid(i, message))
		{
			fprintf(stderr, "Non-valid request\n");
			printf("Non-valid request\n");
		}
		else
		{
			char* answer = GetAnswer(i, message);
			printf("%s\n", answer);
			free(answer);
		}
	}
}

