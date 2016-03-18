#include <stdio.h>
#include <fcntl.h>

int main(void)
{
    printf("O_RDONLY = 0%o, %d, 0x%x\n", O_RDONLY, O_RDONLY, O_RDONLY);
    printf("O_WRONLY = 0%o, %d, 0x%x\n", O_WRONLY, O_WRONLY, O_WRONLY);
    printf("O_CREAT  = 0%o, %d, 0x%x\n", O_CREAT, O_CREAT, O_CREAT);
    printf("O_APPEND = 0%o, %d, 0x%x\n", O_APPEND, O_APPEND, O_APPEND);
    printf("O_SYNC = 0%o, %d, 0x%x\n", O_SYNC, O_SYNC, O_SYNC);
    printf("O_FSYNC = 0%o, %d, 0x%x\n", O_FSYNC, O_FSYNC, O_FSYNC);
    printf("O_ASYNC = 0%o, %d, 0x%x\n", O_ASYNC, O_ASYNC, O_ASYNC);
    printf("0644 = 0%o, %d, 0x%X\n", 0644, 0644, 0644);
    printf("0755 = 0%o, %d, 0x%X\n", 0755, 0755, 0755);
    return 0;
}

