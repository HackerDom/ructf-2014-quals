#ifndef PRINT_H
#define PRINT_H

#define SZ_OUTPUT 4096

void info(const char *format, ...);
void error(const char *format, ...);
void output(int sockfd, const char *format, ...);

#ifdef DEBUG
#define debug(format, ...) info(format, ##__VA_ARGS__)
#else
#define debug(format, ...) ((void)0)
#endif

#endif