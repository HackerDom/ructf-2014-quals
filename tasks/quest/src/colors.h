#ifndef COLORS_H
#define COLORS_H

#define BLACK 0
#define RED 1
#define GREEN 2
#define YELLOW 3
#define BLUE 4
#define MAGENTA 5
#define CYAN 6
#define WHITE 7

#define color(c) "\e[3"#c"m"
#define colored(c, x) color(c) #x color(7)

#define BOLD "\e[1m"
#define NORMAL "\e[0m"
#define bold(x) BOLD #x NORMAL

#endif