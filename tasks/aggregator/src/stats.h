#ifndef STATS_H
#define STATS_H

#include "print.h"

void show_help(int sockfd);
void show_rating(int sockfd, const char dirs[][SZ_PATH], int dir_count);
void show_summary(int sockfd, const char dirs[][SZ_PATH], int dir_count, const char *name);
void show_stats(int sockfd, const char dirs[][SZ_PATH], int dir_count, const char *name);

#endif