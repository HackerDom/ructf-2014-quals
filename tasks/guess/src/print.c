#include <stdarg.h>
#include <stdio.h>
#include <string.h>

#include "print.h"

void info(const char *format, ...)
{
	va_list args;

	va_start(args, format);
	vfprintf(stdout, format, args);
	printf("\n");
	va_end(args);
}

void error(const char *format, ...)
{
	va_list args;

	va_start(args, format);
	vfprintf(stderr, format, args);
	fprintf(stderr, "\n");
	va_end(args);
}

void output(int sockfd, const char *format, ...)
{
	va_list args;
	char buffer[SZ_OUTPUT];

	va_start(args, format);
	vsnprintf(buffer, SZ_OUTPUT, format, args);
	write(sockfd, buffer, strlen(buffer));
	va_end(args);
}