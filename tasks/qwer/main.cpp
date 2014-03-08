#include <vector>

#include <cstring>
#include <cstdio>

class TPost
{
    char Title[256];
    char Content[256];
    public:
    virtual char* GetTitle() const { return (char*)Title; }
    virtual char* GetContent() const { return (char*)Content; }
};

TPost Posts[12];

int main()
{
    unsigned int NotesCount;
    char Username[256];
    printf("Your name? ");
    fgets(Username, 256, stdin);
    printf("Sup %s\nWelcome to notes service\n", Username);
    printf("How many notes save? ");
    scanf("%d", &NotesCount);
    if (NotesCount > 12)
    {
        printf("Free version support only 12 notes!\n");
        return 1;
    }
    for (size_t i = 0; i < NotesCount; ++i)
    {
        printf("Title? ");
        scanf("%s", Posts[i].GetTitle());
        printf("Content? ");
        scanf("%s", Posts[i].GetContent());
    }
    printf("View your notes.\n");
    for (size_t i = 0; i < NotesCount; ++i)
    {
        printf("%s:%s\n", Posts[i].GetTitle(), Posts[i].GetContent());
    }
    return 0;
}
