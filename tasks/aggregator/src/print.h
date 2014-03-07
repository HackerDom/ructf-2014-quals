#ifndef PRINT_H
#define PRINT_H

#define MAX_OUTPUT 2000
#define SZ_OUTPUT 2048

#define SZ_PATH 64

void info(const char *format, ...);
void error(const char *format, ...);
void output(int sockfd, const char *format, ...);

#ifdef DEBUG
#define debug(format, ...) info(format, ##__VA_ARGS__)
#else
#define debug(format, ...) ((void)0)
#endif

#endif