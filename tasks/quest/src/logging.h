#ifndef LOGGING_H
#define LOGGING_H

void info(const char *format, ...);
void error(const char *format, ...);

#ifdef DEBUG
#define debug(format, ...) info(format, ##__VA_ARGS__)
#else
#define debug(format, ...) ((void)0)
#endif

#endif