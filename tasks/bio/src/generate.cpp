#include <iostream>
#include <string>
#include <cstdlib>
#include <ctime>
#include <list>
#include <map>

typedef unsigned int ui32;
typedef unsigned long long ui64;

struct info {
    ui32 count;
    ui32 start;

    info () : count (0), start (0) { }
    info (ui32 start) : count (1), start (start) { }

    void inc () { ++ count; }
};

inline bool equals (const std::string & s, ui32 a, ui32 b, ui32 k) {
    for (int i = 0; i < k; ++ i)
        if (s[a + i] != s[b + i])
            return false;

    return true;
}

std::string solve (const std::string & s, int k) {
    const ui32 p = 31;

    ui64 x = 1;
    ui64 h = 0;
    for (int i = 0; i < k; ++ i) {
        h = h * p + s[i];
        x *= p;
    }

    std::map <ui64, std::list <info>> index;
    for (int i = k; i < s.size (); ++ i) {
        // if (! (i % 1048576)) std::cerr << '.';

        if (index.count (h)) {
            bool found = false;

            for (auto & it : index[h])
                if (equals (s, it.start, i - k, k)) {
                    it.inc ();
                    found = true;
                    break;
                }

            if (! found)
                index[h].push_back (info (i - k));
        }
        else
            index[h].push_back (info (i - k));

        if (i != s.size ())
            h = h * p + s[i] - s[i - k] * x;
    }

    info ans;

    for (const auto & it : index)
        for (const auto & jt : it.second) {
            if (jt.count > 1)
                std::cerr << jt.count << " : '" << s.substr (jt.start, k) << "'" << std::endl;

            if (ans.count < jt.count)
                ans = jt;
        }

    return s.substr (ans.start, k);
}

int main (int argc, char ** argv) {
    const char * abc = "ACTG";
    
    if (argc < 3) {
        std::cerr << "Not enough arguments" << std::endl;
        return 1;
    }

    int n = std::atoi (argv[1]);
    int k = std::atoi (argv[2]);

    std::srand (time (NULL));

    std::string s (n, 'x');
    std::string u (k, 'x');
    for (auto & it : u)
        it = abc[rand () % 4];

    int i = 0;
    while (i + k < n) {
        int j = i + rand () % (n - i);
        for (int p = 0; p < k; ++ p)
            s [j + p] = u [p];
        i = j;
    }

    for (auto & it : s)
        if (it == 'x')
            it = abc[rand () % 4];

    std::cout << s; 
    std::cerr << solve (s, k);

    return 0;
}
