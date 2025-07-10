#include "../kernel/types.h"
#include "../kernel/param.h"
#include "../user/user.h"

#define STACK_SIZE 100

// قفل ساده user-space با استفاده از atomic operations
volatile int print_lock = 0;

void acquire_print_lock() {
    while (__sync_lock_test_and_set(&print_lock, 1)) {
        // spin
    }
}

void release_print_lock() {
    __sync_lock_release(&print_lock);
}

// ساختار داده‌ی ترد
struct thread_data {
    int thread_id;
    uint64 start_number;
};

// تابع اجراشده توسط هر ترد
void *my_thread(void *arg) {
    struct thread_data *data = (struct thread_data *)arg;
    for (int i = 0; i < 10; ++i) {
        data->start_number++;

        acquire_print_lock();
        printf("thread %d: %lu\n", data->thread_id, data->start_number);
        release_print_lock();

        sleep(0); // تحریک زمان‌بند
    }
    return (void *)data->start_number;
}

int main(int argc, char *argv[]) {
    static int stack1[STACK_SIZE];
    static int stack2[STACK_SIZE];
    static int stack3[STACK_SIZE];

    // داده‌های هر ترد
    static struct thread_data data1 = {1, 100};
    static struct thread_data data2 = {2, 200};
    static struct thread_data data3 = {3, 300};

    int tid1 = thread(my_thread, (int *)(stack1 + STACK_SIZE), (void *)&data1);
    acquire_print_lock();
    printf("NEW THREAD CREATED 1\n");
    release_print_lock();

    int tid2 = thread(my_thread, (int *)(stack2 + STACK_SIZE), (void *)&data2);
    acquire_print_lock();
    printf("NEW THREAD CREATED 2\n");
    release_print_lock();

    int tid3 = thread(my_thread, (int *)(stack3 + STACK_SIZE), (void *)&data3);
    acquire_print_lock();
    printf("NEW THREAD CREATED 3\n");
    release_print_lock();

    jointhread(tid1);
    jointhread(tid2);
    jointhread(tid3);

    acquire_print_lock();
    printf("DONE\n");
    release_print_lock();

    exit(0);
}
