// gcc soft-reset.c -o soft-reset

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

#define MULTILINE(...) #__VA_ARGS__

int main() {
    int res;
    char exepath[1024];

    res = readlink("/proc/self/exe", exepath, sizeof(exepath) - 1);
    if (res <= 0) strcpy(exepath, "soft-reset");
    else exepath[res] = 0;

    if (setuid(0) != 0) {
        printf("Root is required for soft-reset. Please run:\nsudo chown root:root '%s' && sudo chmod 6711 '%s'\n",
            exepath, exepath
        );
        return -1;
    }
    res = system(MULTILINE(
systemctl stop docker &&
sync &&
/sbin/sysctl vm.drop_caches=3 &&
/sbin/swapoff -a &&
/sbin/swapon -a &&
systemctl start docker
    ));
    return (res != 0 ? 1 : 0);
}
