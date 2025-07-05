#include "../kernel/types.h"
#include "../user/user.h"

#define STACK_SIZE 1024

// قفل ساده user-space با استفاده از atomic operations
typedef struct {
  volatile int locked;
} lock_t;

void initlock(lock_t *lk) {
  lk->locked = 0;
}

void acquire(lock_t *lk) {
  while (__sync_lock_test_and_set(&lk->locked, 1) != 0)
    ; // spinlock
}

void release(lock_t *lk) {
  __sync_lock_release(&lk->locked);
}

lock_t printlock;

// تابعی که توسط هر ترد اجرا می‌شود
void* my_thread(void* arg) {
  int id = (int)(uint64)arg;
  for (int i = 0; i < 5; i++) {
    acquire(&printlock);
    printf("thread %d: iteration %d\n", id, i);
    release(&printlock);
  }
  return 0;
}

int main(int argc, char *argv[]) {
  initlock(&printlock);

  // تعریف استک‌ها
  static int stack1[STACK_SIZE];
  static int stack2[STACK_SIZE];
  static int stack3[STACK_SIZE];

  // ایجاد تردها
  int tid1 = thread(my_thread, stack1 + STACK_SIZE, (void *)1);
  int tid2 = thread(my_thread, stack2 + STACK_SIZE, (void *)2);
  int tid3 = thread(my_thread, stack3 + STACK_SIZE, (void *)3);

  // منتظر ماندن برای اتمام تردها
  jointhread(tid1);
  jointhread(tid2);
  jointhread(tid3);

  printf("All threads finished.\n");
  exit(0);
}
