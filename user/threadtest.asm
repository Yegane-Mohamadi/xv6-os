
user/_threadtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <acquire_print_lock>:
#define STACK_SIZE 100

// قفل ساده user-space با استفاده از atomic operations
volatile int print_lock = 0;

void acquire_print_lock() {
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
    while (__sync_lock_test_and_set(&print_lock, 1)) {
   6:	00001717          	auipc	a4,0x1
   a:	02a70713          	addi	a4,a4,42 # 1030 <print_lock>
   e:	4685                	li	a3,1
  10:	87b6                	mv	a5,a3
  12:	0cf727af          	amoswap.w.aq	a5,a5,(a4)
  16:	2781                	sext.w	a5,a5
  18:	ffe5                	bnez	a5,10 <acquire_print_lock+0x10>
        // spin
    }
}
  1a:	6422                	ld	s0,8(sp)
  1c:	0141                	addi	sp,sp,16
  1e:	8082                	ret

0000000000000020 <release_print_lock>:

void release_print_lock() {
  20:	1141                	addi	sp,sp,-16
  22:	e422                	sd	s0,8(sp)
  24:	0800                	addi	s0,sp,16
    __sync_lock_release(&print_lock);
  26:	00001797          	auipc	a5,0x1
  2a:	00a78793          	addi	a5,a5,10 # 1030 <print_lock>
  2e:	0f50000f          	fence	iorw,ow
  32:	0807a02f          	amoswap.w	zero,zero,(a5)
}
  36:	6422                	ld	s0,8(sp)
  38:	0141                	addi	sp,sp,16
  3a:	8082                	ret

000000000000003c <my_thread>:
    int thread_id;
    uint64 start_number;
};

// تابع اجراشده توسط هر ترد
void *my_thread(void *arg) {
  3c:	7179                	addi	sp,sp,-48
  3e:	f406                	sd	ra,40(sp)
  40:	f022                	sd	s0,32(sp)
  42:	ec26                	sd	s1,24(sp)
  44:	e84a                	sd	s2,16(sp)
  46:	e44e                	sd	s3,8(sp)
  48:	1800                	addi	s0,sp,48
  4a:	84aa                	mv	s1,a0
  4c:	4929                	li	s2,10
    struct thread_data *data = (struct thread_data *)arg;
    for (int i = 0; i < 10; ++i) {
        data->start_number++;

        acquire_print_lock();
        printf("thread %d: %lu\n", data->thread_id, data->start_number);
  4e:	00001997          	auipc	s3,0x1
  52:	95298993          	addi	s3,s3,-1710 # 9a0 <malloc+0x100>
        data->start_number++;
  56:	649c                	ld	a5,8(s1)
  58:	0785                	addi	a5,a5,1
  5a:	e49c                	sd	a5,8(s1)
        acquire_print_lock();
  5c:	fa5ff0ef          	jal	0 <acquire_print_lock>
        printf("thread %d: %lu\n", data->thread_id, data->start_number);
  60:	6490                	ld	a2,8(s1)
  62:	408c                	lw	a1,0(s1)
  64:	854e                	mv	a0,s3
  66:	786000ef          	jal	7ec <printf>
        release_print_lock();
  6a:	fb7ff0ef          	jal	20 <release_print_lock>

        sleep(0); // تحریک زمان‌بند
  6e:	4501                	li	a0,0
  70:	3e4000ef          	jal	454 <sleep>
    for (int i = 0; i < 10; ++i) {
  74:	397d                	addiw	s2,s2,-1
  76:	fe0910e3          	bnez	s2,56 <my_thread+0x1a>
    }
    return (void *)data->start_number;
}
  7a:	6488                	ld	a0,8(s1)
  7c:	70a2                	ld	ra,40(sp)
  7e:	7402                	ld	s0,32(sp)
  80:	64e2                	ld	s1,24(sp)
  82:	6942                	ld	s2,16(sp)
  84:	69a2                	ld	s3,8(sp)
  86:	6145                	addi	sp,sp,48
  88:	8082                	ret

000000000000008a <main>:

int main(int argc, char *argv[]) {
  8a:	7179                	addi	sp,sp,-48
  8c:	f406                	sd	ra,40(sp)
  8e:	f022                	sd	s0,32(sp)
  90:	ec26                	sd	s1,24(sp)
  92:	e84a                	sd	s2,16(sp)
  94:	e44e                	sd	s3,8(sp)
  96:	1800                	addi	s0,sp,48
    // داده‌های هر ترد
    static struct thread_data data1 = {1, 100};
    static struct thread_data data2 = {2, 200};
    static struct thread_data data3 = {3, 300};

    int tid1 = thread(my_thread, (int *)(stack1 + STACK_SIZE), (void *)&data1);
  98:	00001617          	auipc	a2,0x1
  9c:	f6860613          	addi	a2,a2,-152 # 1000 <data1.4>
  a0:	00001597          	auipc	a1,0x1
  a4:	13058593          	addi	a1,a1,304 # 11d0 <stack2.3>
  a8:	00000517          	auipc	a0,0x0
  ac:	f9450513          	addi	a0,a0,-108 # 3c <my_thread>
  b0:	3b4000ef          	jal	464 <thread>
  b4:	89aa                	mv	s3,a0
    acquire_print_lock();
  b6:	f4bff0ef          	jal	0 <acquire_print_lock>
    printf("NEW THREAD CREATED 1\n");
  ba:	00001517          	auipc	a0,0x1
  be:	8f650513          	addi	a0,a0,-1802 # 9b0 <malloc+0x110>
  c2:	72a000ef          	jal	7ec <printf>
    release_print_lock();
  c6:	f5bff0ef          	jal	20 <release_print_lock>

    int tid2 = thread(my_thread, (int *)(stack2 + STACK_SIZE), (void *)&data2);
  ca:	00001617          	auipc	a2,0x1
  ce:	f4660613          	addi	a2,a2,-186 # 1010 <data2.2>
  d2:	00001597          	auipc	a1,0x1
  d6:	28e58593          	addi	a1,a1,654 # 1360 <stack3.1>
  da:	00000517          	auipc	a0,0x0
  de:	f6250513          	addi	a0,a0,-158 # 3c <my_thread>
  e2:	382000ef          	jal	464 <thread>
  e6:	892a                	mv	s2,a0
    acquire_print_lock();
  e8:	f19ff0ef          	jal	0 <acquire_print_lock>
    printf("NEW THREAD CREATED 2\n");
  ec:	00001517          	auipc	a0,0x1
  f0:	8dc50513          	addi	a0,a0,-1828 # 9c8 <malloc+0x128>
  f4:	6f8000ef          	jal	7ec <printf>
    release_print_lock();
  f8:	f29ff0ef          	jal	20 <release_print_lock>

    int tid3 = thread(my_thread, (int *)(stack3 + STACK_SIZE), (void *)&data3);
  fc:	00001617          	auipc	a2,0x1
 100:	f2460613          	addi	a2,a2,-220 # 1020 <data3.0>
 104:	00001597          	auipc	a1,0x1
 108:	3ec58593          	addi	a1,a1,1004 # 14f0 <base>
 10c:	00000517          	auipc	a0,0x0
 110:	f3050513          	addi	a0,a0,-208 # 3c <my_thread>
 114:	350000ef          	jal	464 <thread>
 118:	84aa                	mv	s1,a0
    acquire_print_lock();
 11a:	ee7ff0ef          	jal	0 <acquire_print_lock>
    printf("NEW THREAD CREATED 3\n");
 11e:	00001517          	auipc	a0,0x1
 122:	8c250513          	addi	a0,a0,-1854 # 9e0 <malloc+0x140>
 126:	6c6000ef          	jal	7ec <printf>
    release_print_lock();
 12a:	ef7ff0ef          	jal	20 <release_print_lock>

    jointhread(tid1);
 12e:	854e                	mv	a0,s3
 130:	33c000ef          	jal	46c <jointhread>
    jointhread(tid2);
 134:	854a                	mv	a0,s2
 136:	336000ef          	jal	46c <jointhread>
    jointhread(tid3);
 13a:	8526                	mv	a0,s1
 13c:	330000ef          	jal	46c <jointhread>

    acquire_print_lock();
 140:	ec1ff0ef          	jal	0 <acquire_print_lock>
    printf("DONE\n");
 144:	00001517          	auipc	a0,0x1
 148:	8b450513          	addi	a0,a0,-1868 # 9f8 <malloc+0x158>
 14c:	6a0000ef          	jal	7ec <printf>
    release_print_lock();
 150:	ed1ff0ef          	jal	20 <release_print_lock>

    exit(0);
 154:	4501                	li	a0,0
 156:	26e000ef          	jal	3c4 <exit>

000000000000015a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 15a:	1141                	addi	sp,sp,-16
 15c:	e406                	sd	ra,8(sp)
 15e:	e022                	sd	s0,0(sp)
 160:	0800                	addi	s0,sp,16
  extern int main();
  main();
 162:	f29ff0ef          	jal	8a <main>
  exit(0);
 166:	4501                	li	a0,0
 168:	25c000ef          	jal	3c4 <exit>

000000000000016c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 172:	87aa                	mv	a5,a0
 174:	0585                	addi	a1,a1,1
 176:	0785                	addi	a5,a5,1
 178:	fff5c703          	lbu	a4,-1(a1)
 17c:	fee78fa3          	sb	a4,-1(a5)
 180:	fb75                	bnez	a4,174 <strcpy+0x8>
    ;
  return os;
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret

0000000000000188 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 188:	1141                	addi	sp,sp,-16
 18a:	e422                	sd	s0,8(sp)
 18c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 18e:	00054783          	lbu	a5,0(a0)
 192:	cb91                	beqz	a5,1a6 <strcmp+0x1e>
 194:	0005c703          	lbu	a4,0(a1)
 198:	00f71763          	bne	a4,a5,1a6 <strcmp+0x1e>
    p++, q++;
 19c:	0505                	addi	a0,a0,1
 19e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1a0:	00054783          	lbu	a5,0(a0)
 1a4:	fbe5                	bnez	a5,194 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1a6:	0005c503          	lbu	a0,0(a1)
}
 1aa:	40a7853b          	subw	a0,a5,a0
 1ae:	6422                	ld	s0,8(sp)
 1b0:	0141                	addi	sp,sp,16
 1b2:	8082                	ret

00000000000001b4 <strlen>:

uint
strlen(const char *s)
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e422                	sd	s0,8(sp)
 1b8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ba:	00054783          	lbu	a5,0(a0)
 1be:	cf91                	beqz	a5,1da <strlen+0x26>
 1c0:	0505                	addi	a0,a0,1
 1c2:	87aa                	mv	a5,a0
 1c4:	86be                	mv	a3,a5
 1c6:	0785                	addi	a5,a5,1
 1c8:	fff7c703          	lbu	a4,-1(a5)
 1cc:	ff65                	bnez	a4,1c4 <strlen+0x10>
 1ce:	40a6853b          	subw	a0,a3,a0
 1d2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1d4:	6422                	ld	s0,8(sp)
 1d6:	0141                	addi	sp,sp,16
 1d8:	8082                	ret
  for(n = 0; s[n]; n++)
 1da:	4501                	li	a0,0
 1dc:	bfe5                	j	1d4 <strlen+0x20>

00000000000001de <memset>:

void*
memset(void *dst, int c, uint n)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1e4:	ca19                	beqz	a2,1fa <memset+0x1c>
 1e6:	87aa                	mv	a5,a0
 1e8:	1602                	slli	a2,a2,0x20
 1ea:	9201                	srli	a2,a2,0x20
 1ec:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1f0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1f4:	0785                	addi	a5,a5,1
 1f6:	fee79de3          	bne	a5,a4,1f0 <memset+0x12>
  }
  return dst;
}
 1fa:	6422                	ld	s0,8(sp)
 1fc:	0141                	addi	sp,sp,16
 1fe:	8082                	ret

0000000000000200 <strchr>:

char*
strchr(const char *s, char c)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  for(; *s; s++)
 206:	00054783          	lbu	a5,0(a0)
 20a:	cb99                	beqz	a5,220 <strchr+0x20>
    if(*s == c)
 20c:	00f58763          	beq	a1,a5,21a <strchr+0x1a>
  for(; *s; s++)
 210:	0505                	addi	a0,a0,1
 212:	00054783          	lbu	a5,0(a0)
 216:	fbfd                	bnez	a5,20c <strchr+0xc>
      return (char*)s;
  return 0;
 218:	4501                	li	a0,0
}
 21a:	6422                	ld	s0,8(sp)
 21c:	0141                	addi	sp,sp,16
 21e:	8082                	ret
  return 0;
 220:	4501                	li	a0,0
 222:	bfe5                	j	21a <strchr+0x1a>

0000000000000224 <gets>:

char*
gets(char *buf, int max)
{
 224:	711d                	addi	sp,sp,-96
 226:	ec86                	sd	ra,88(sp)
 228:	e8a2                	sd	s0,80(sp)
 22a:	e4a6                	sd	s1,72(sp)
 22c:	e0ca                	sd	s2,64(sp)
 22e:	fc4e                	sd	s3,56(sp)
 230:	f852                	sd	s4,48(sp)
 232:	f456                	sd	s5,40(sp)
 234:	f05a                	sd	s6,32(sp)
 236:	ec5e                	sd	s7,24(sp)
 238:	1080                	addi	s0,sp,96
 23a:	8baa                	mv	s7,a0
 23c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 23e:	892a                	mv	s2,a0
 240:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 242:	4aa9                	li	s5,10
 244:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 246:	89a6                	mv	s3,s1
 248:	2485                	addiw	s1,s1,1
 24a:	0344d663          	bge	s1,s4,276 <gets+0x52>
    cc = read(0, &c, 1);
 24e:	4605                	li	a2,1
 250:	faf40593          	addi	a1,s0,-81
 254:	4501                	li	a0,0
 256:	186000ef          	jal	3dc <read>
    if(cc < 1)
 25a:	00a05e63          	blez	a0,276 <gets+0x52>
    buf[i++] = c;
 25e:	faf44783          	lbu	a5,-81(s0)
 262:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 266:	01578763          	beq	a5,s5,274 <gets+0x50>
 26a:	0905                	addi	s2,s2,1
 26c:	fd679de3          	bne	a5,s6,246 <gets+0x22>
    buf[i++] = c;
 270:	89a6                	mv	s3,s1
 272:	a011                	j	276 <gets+0x52>
 274:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 276:	99de                	add	s3,s3,s7
 278:	00098023          	sb	zero,0(s3)
  return buf;
}
 27c:	855e                	mv	a0,s7
 27e:	60e6                	ld	ra,88(sp)
 280:	6446                	ld	s0,80(sp)
 282:	64a6                	ld	s1,72(sp)
 284:	6906                	ld	s2,64(sp)
 286:	79e2                	ld	s3,56(sp)
 288:	7a42                	ld	s4,48(sp)
 28a:	7aa2                	ld	s5,40(sp)
 28c:	7b02                	ld	s6,32(sp)
 28e:	6be2                	ld	s7,24(sp)
 290:	6125                	addi	sp,sp,96
 292:	8082                	ret

0000000000000294 <stat>:

int
stat(const char *n, struct stat *st)
{
 294:	1101                	addi	sp,sp,-32
 296:	ec06                	sd	ra,24(sp)
 298:	e822                	sd	s0,16(sp)
 29a:	e04a                	sd	s2,0(sp)
 29c:	1000                	addi	s0,sp,32
 29e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a0:	4581                	li	a1,0
 2a2:	162000ef          	jal	404 <open>
  if(fd < 0)
 2a6:	02054263          	bltz	a0,2ca <stat+0x36>
 2aa:	e426                	sd	s1,8(sp)
 2ac:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2ae:	85ca                	mv	a1,s2
 2b0:	16c000ef          	jal	41c <fstat>
 2b4:	892a                	mv	s2,a0
  close(fd);
 2b6:	8526                	mv	a0,s1
 2b8:	134000ef          	jal	3ec <close>
  return r;
 2bc:	64a2                	ld	s1,8(sp)
}
 2be:	854a                	mv	a0,s2
 2c0:	60e2                	ld	ra,24(sp)
 2c2:	6442                	ld	s0,16(sp)
 2c4:	6902                	ld	s2,0(sp)
 2c6:	6105                	addi	sp,sp,32
 2c8:	8082                	ret
    return -1;
 2ca:	597d                	li	s2,-1
 2cc:	bfcd                	j	2be <stat+0x2a>

00000000000002ce <atoi>:

int
atoi(const char *s)
{
 2ce:	1141                	addi	sp,sp,-16
 2d0:	e422                	sd	s0,8(sp)
 2d2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2d4:	00054683          	lbu	a3,0(a0)
 2d8:	fd06879b          	addiw	a5,a3,-48
 2dc:	0ff7f793          	zext.b	a5,a5
 2e0:	4625                	li	a2,9
 2e2:	02f66863          	bltu	a2,a5,312 <atoi+0x44>
 2e6:	872a                	mv	a4,a0
  n = 0;
 2e8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2ea:	0705                	addi	a4,a4,1
 2ec:	0025179b          	slliw	a5,a0,0x2
 2f0:	9fa9                	addw	a5,a5,a0
 2f2:	0017979b          	slliw	a5,a5,0x1
 2f6:	9fb5                	addw	a5,a5,a3
 2f8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2fc:	00074683          	lbu	a3,0(a4)
 300:	fd06879b          	addiw	a5,a3,-48
 304:	0ff7f793          	zext.b	a5,a5
 308:	fef671e3          	bgeu	a2,a5,2ea <atoi+0x1c>
  return n;
}
 30c:	6422                	ld	s0,8(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret
  n = 0;
 312:	4501                	li	a0,0
 314:	bfe5                	j	30c <atoi+0x3e>

0000000000000316 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 316:	1141                	addi	sp,sp,-16
 318:	e422                	sd	s0,8(sp)
 31a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 31c:	02b57463          	bgeu	a0,a1,344 <memmove+0x2e>
    while(n-- > 0)
 320:	00c05f63          	blez	a2,33e <memmove+0x28>
 324:	1602                	slli	a2,a2,0x20
 326:	9201                	srli	a2,a2,0x20
 328:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 32c:	872a                	mv	a4,a0
      *dst++ = *src++;
 32e:	0585                	addi	a1,a1,1
 330:	0705                	addi	a4,a4,1
 332:	fff5c683          	lbu	a3,-1(a1)
 336:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 33a:	fef71ae3          	bne	a4,a5,32e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 33e:	6422                	ld	s0,8(sp)
 340:	0141                	addi	sp,sp,16
 342:	8082                	ret
    dst += n;
 344:	00c50733          	add	a4,a0,a2
    src += n;
 348:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 34a:	fec05ae3          	blez	a2,33e <memmove+0x28>
 34e:	fff6079b          	addiw	a5,a2,-1
 352:	1782                	slli	a5,a5,0x20
 354:	9381                	srli	a5,a5,0x20
 356:	fff7c793          	not	a5,a5
 35a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 35c:	15fd                	addi	a1,a1,-1
 35e:	177d                	addi	a4,a4,-1
 360:	0005c683          	lbu	a3,0(a1)
 364:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 368:	fee79ae3          	bne	a5,a4,35c <memmove+0x46>
 36c:	bfc9                	j	33e <memmove+0x28>

000000000000036e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 36e:	1141                	addi	sp,sp,-16
 370:	e422                	sd	s0,8(sp)
 372:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 374:	ca05                	beqz	a2,3a4 <memcmp+0x36>
 376:	fff6069b          	addiw	a3,a2,-1
 37a:	1682                	slli	a3,a3,0x20
 37c:	9281                	srli	a3,a3,0x20
 37e:	0685                	addi	a3,a3,1
 380:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 382:	00054783          	lbu	a5,0(a0)
 386:	0005c703          	lbu	a4,0(a1)
 38a:	00e79863          	bne	a5,a4,39a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 38e:	0505                	addi	a0,a0,1
    p2++;
 390:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 392:	fed518e3          	bne	a0,a3,382 <memcmp+0x14>
  }
  return 0;
 396:	4501                	li	a0,0
 398:	a019                	j	39e <memcmp+0x30>
      return *p1 - *p2;
 39a:	40e7853b          	subw	a0,a5,a4
}
 39e:	6422                	ld	s0,8(sp)
 3a0:	0141                	addi	sp,sp,16
 3a2:	8082                	ret
  return 0;
 3a4:	4501                	li	a0,0
 3a6:	bfe5                	j	39e <memcmp+0x30>

00000000000003a8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3a8:	1141                	addi	sp,sp,-16
 3aa:	e406                	sd	ra,8(sp)
 3ac:	e022                	sd	s0,0(sp)
 3ae:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3b0:	f67ff0ef          	jal	316 <memmove>
}
 3b4:	60a2                	ld	ra,8(sp)
 3b6:	6402                	ld	s0,0(sp)
 3b8:	0141                	addi	sp,sp,16
 3ba:	8082                	ret

00000000000003bc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3bc:	4885                	li	a7,1
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3c4:	4889                	li	a7,2
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <wait>:
.global wait
wait:
 li a7, SYS_wait
 3cc:	488d                	li	a7,3
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3d4:	4891                	li	a7,4
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <read>:
.global read
read:
 li a7, SYS_read
 3dc:	4895                	li	a7,5
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <write>:
.global write
write:
 li a7, SYS_write
 3e4:	48c1                	li	a7,16
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <close>:
.global close
close:
 li a7, SYS_close
 3ec:	48d5                	li	a7,21
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3f4:	4899                	li	a7,6
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <exec>:
.global exec
exec:
 li a7, SYS_exec
 3fc:	489d                	li	a7,7
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <open>:
.global open
open:
 li a7, SYS_open
 404:	48bd                	li	a7,15
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 40c:	48c5                	li	a7,17
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 414:	48c9                	li	a7,18
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 41c:	48a1                	li	a7,8
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <link>:
.global link
link:
 li a7, SYS_link
 424:	48cd                	li	a7,19
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 42c:	48d1                	li	a7,20
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 434:	48a5                	li	a7,9
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <dup>:
.global dup
dup:
 li a7, SYS_dup
 43c:	48a9                	li	a7,10
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 444:	48ad                	li	a7,11
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 44c:	48b1                	li	a7,12
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 454:	48b5                	li	a7,13
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 45c:	48b9                	li	a7,14
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <thread>:
.global thread
thread:
 li a7, SYS_thread
 464:	48d9                	li	a7,22
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <jointhread>:
.global jointhread
jointhread:
 li a7, SYS_jointhread
 46c:	48dd                	li	a7,23
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 474:	1101                	addi	sp,sp,-32
 476:	ec06                	sd	ra,24(sp)
 478:	e822                	sd	s0,16(sp)
 47a:	1000                	addi	s0,sp,32
 47c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 480:	4605                	li	a2,1
 482:	fef40593          	addi	a1,s0,-17
 486:	f5fff0ef          	jal	3e4 <write>
}
 48a:	60e2                	ld	ra,24(sp)
 48c:	6442                	ld	s0,16(sp)
 48e:	6105                	addi	sp,sp,32
 490:	8082                	ret

0000000000000492 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 492:	7139                	addi	sp,sp,-64
 494:	fc06                	sd	ra,56(sp)
 496:	f822                	sd	s0,48(sp)
 498:	f426                	sd	s1,40(sp)
 49a:	0080                	addi	s0,sp,64
 49c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 49e:	c299                	beqz	a3,4a4 <printint+0x12>
 4a0:	0805c963          	bltz	a1,532 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4a4:	2581                	sext.w	a1,a1
  neg = 0;
 4a6:	4881                	li	a7,0
 4a8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4ac:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4ae:	2601                	sext.w	a2,a2
 4b0:	00000517          	auipc	a0,0x0
 4b4:	55850513          	addi	a0,a0,1368 # a08 <digits>
 4b8:	883a                	mv	a6,a4
 4ba:	2705                	addiw	a4,a4,1
 4bc:	02c5f7bb          	remuw	a5,a1,a2
 4c0:	1782                	slli	a5,a5,0x20
 4c2:	9381                	srli	a5,a5,0x20
 4c4:	97aa                	add	a5,a5,a0
 4c6:	0007c783          	lbu	a5,0(a5)
 4ca:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4ce:	0005879b          	sext.w	a5,a1
 4d2:	02c5d5bb          	divuw	a1,a1,a2
 4d6:	0685                	addi	a3,a3,1
 4d8:	fec7f0e3          	bgeu	a5,a2,4b8 <printint+0x26>
  if(neg)
 4dc:	00088c63          	beqz	a7,4f4 <printint+0x62>
    buf[i++] = '-';
 4e0:	fd070793          	addi	a5,a4,-48
 4e4:	00878733          	add	a4,a5,s0
 4e8:	02d00793          	li	a5,45
 4ec:	fef70823          	sb	a5,-16(a4)
 4f0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4f4:	02e05a63          	blez	a4,528 <printint+0x96>
 4f8:	f04a                	sd	s2,32(sp)
 4fa:	ec4e                	sd	s3,24(sp)
 4fc:	fc040793          	addi	a5,s0,-64
 500:	00e78933          	add	s2,a5,a4
 504:	fff78993          	addi	s3,a5,-1
 508:	99ba                	add	s3,s3,a4
 50a:	377d                	addiw	a4,a4,-1
 50c:	1702                	slli	a4,a4,0x20
 50e:	9301                	srli	a4,a4,0x20
 510:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 514:	fff94583          	lbu	a1,-1(s2)
 518:	8526                	mv	a0,s1
 51a:	f5bff0ef          	jal	474 <putc>
  while(--i >= 0)
 51e:	197d                	addi	s2,s2,-1
 520:	ff391ae3          	bne	s2,s3,514 <printint+0x82>
 524:	7902                	ld	s2,32(sp)
 526:	69e2                	ld	s3,24(sp)
}
 528:	70e2                	ld	ra,56(sp)
 52a:	7442                	ld	s0,48(sp)
 52c:	74a2                	ld	s1,40(sp)
 52e:	6121                	addi	sp,sp,64
 530:	8082                	ret
    x = -xx;
 532:	40b005bb          	negw	a1,a1
    neg = 1;
 536:	4885                	li	a7,1
    x = -xx;
 538:	bf85                	j	4a8 <printint+0x16>

000000000000053a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 53a:	711d                	addi	sp,sp,-96
 53c:	ec86                	sd	ra,88(sp)
 53e:	e8a2                	sd	s0,80(sp)
 540:	e0ca                	sd	s2,64(sp)
 542:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 544:	0005c903          	lbu	s2,0(a1)
 548:	26090863          	beqz	s2,7b8 <vprintf+0x27e>
 54c:	e4a6                	sd	s1,72(sp)
 54e:	fc4e                	sd	s3,56(sp)
 550:	f852                	sd	s4,48(sp)
 552:	f456                	sd	s5,40(sp)
 554:	f05a                	sd	s6,32(sp)
 556:	ec5e                	sd	s7,24(sp)
 558:	e862                	sd	s8,16(sp)
 55a:	e466                	sd	s9,8(sp)
 55c:	8b2a                	mv	s6,a0
 55e:	8a2e                	mv	s4,a1
 560:	8bb2                	mv	s7,a2
  state = 0;
 562:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 564:	4481                	li	s1,0
 566:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 568:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 56c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 570:	06c00c93          	li	s9,108
 574:	a005                	j	594 <vprintf+0x5a>
        putc(fd, c0);
 576:	85ca                	mv	a1,s2
 578:	855a                	mv	a0,s6
 57a:	efbff0ef          	jal	474 <putc>
 57e:	a019                	j	584 <vprintf+0x4a>
    } else if(state == '%'){
 580:	03598263          	beq	s3,s5,5a4 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 584:	2485                	addiw	s1,s1,1
 586:	8726                	mv	a4,s1
 588:	009a07b3          	add	a5,s4,s1
 58c:	0007c903          	lbu	s2,0(a5)
 590:	20090c63          	beqz	s2,7a8 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 594:	0009079b          	sext.w	a5,s2
    if(state == 0){
 598:	fe0994e3          	bnez	s3,580 <vprintf+0x46>
      if(c0 == '%'){
 59c:	fd579de3          	bne	a5,s5,576 <vprintf+0x3c>
        state = '%';
 5a0:	89be                	mv	s3,a5
 5a2:	b7cd                	j	584 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5a4:	00ea06b3          	add	a3,s4,a4
 5a8:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5ac:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5ae:	c681                	beqz	a3,5b6 <vprintf+0x7c>
 5b0:	9752                	add	a4,a4,s4
 5b2:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5b6:	03878f63          	beq	a5,s8,5f4 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 5ba:	05978963          	beq	a5,s9,60c <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5be:	07500713          	li	a4,117
 5c2:	0ee78363          	beq	a5,a4,6a8 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5c6:	07800713          	li	a4,120
 5ca:	12e78563          	beq	a5,a4,6f4 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5ce:	07000713          	li	a4,112
 5d2:	14e78a63          	beq	a5,a4,726 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 5d6:	07300713          	li	a4,115
 5da:	18e78a63          	beq	a5,a4,76e <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5de:	02500713          	li	a4,37
 5e2:	04e79563          	bne	a5,a4,62c <vprintf+0xf2>
        putc(fd, '%');
 5e6:	02500593          	li	a1,37
 5ea:	855a                	mv	a0,s6
 5ec:	e89ff0ef          	jal	474 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 5f0:	4981                	li	s3,0
 5f2:	bf49                	j	584 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5f4:	008b8913          	addi	s2,s7,8
 5f8:	4685                	li	a3,1
 5fa:	4629                	li	a2,10
 5fc:	000ba583          	lw	a1,0(s7)
 600:	855a                	mv	a0,s6
 602:	e91ff0ef          	jal	492 <printint>
 606:	8bca                	mv	s7,s2
      state = 0;
 608:	4981                	li	s3,0
 60a:	bfad                	j	584 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 60c:	06400793          	li	a5,100
 610:	02f68963          	beq	a3,a5,642 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 614:	06c00793          	li	a5,108
 618:	04f68263          	beq	a3,a5,65c <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 61c:	07500793          	li	a5,117
 620:	0af68063          	beq	a3,a5,6c0 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 624:	07800793          	li	a5,120
 628:	0ef68263          	beq	a3,a5,70c <vprintf+0x1d2>
        putc(fd, '%');
 62c:	02500593          	li	a1,37
 630:	855a                	mv	a0,s6
 632:	e43ff0ef          	jal	474 <putc>
        putc(fd, c0);
 636:	85ca                	mv	a1,s2
 638:	855a                	mv	a0,s6
 63a:	e3bff0ef          	jal	474 <putc>
      state = 0;
 63e:	4981                	li	s3,0
 640:	b791                	j	584 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 642:	008b8913          	addi	s2,s7,8
 646:	4685                	li	a3,1
 648:	4629                	li	a2,10
 64a:	000ba583          	lw	a1,0(s7)
 64e:	855a                	mv	a0,s6
 650:	e43ff0ef          	jal	492 <printint>
        i += 1;
 654:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 656:	8bca                	mv	s7,s2
      state = 0;
 658:	4981                	li	s3,0
        i += 1;
 65a:	b72d                	j	584 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 65c:	06400793          	li	a5,100
 660:	02f60763          	beq	a2,a5,68e <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 664:	07500793          	li	a5,117
 668:	06f60963          	beq	a2,a5,6da <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 66c:	07800793          	li	a5,120
 670:	faf61ee3          	bne	a2,a5,62c <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 674:	008b8913          	addi	s2,s7,8
 678:	4681                	li	a3,0
 67a:	4641                	li	a2,16
 67c:	000ba583          	lw	a1,0(s7)
 680:	855a                	mv	a0,s6
 682:	e11ff0ef          	jal	492 <printint>
        i += 2;
 686:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 688:	8bca                	mv	s7,s2
      state = 0;
 68a:	4981                	li	s3,0
        i += 2;
 68c:	bde5                	j	584 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 68e:	008b8913          	addi	s2,s7,8
 692:	4685                	li	a3,1
 694:	4629                	li	a2,10
 696:	000ba583          	lw	a1,0(s7)
 69a:	855a                	mv	a0,s6
 69c:	df7ff0ef          	jal	492 <printint>
        i += 2;
 6a0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a2:	8bca                	mv	s7,s2
      state = 0;
 6a4:	4981                	li	s3,0
        i += 2;
 6a6:	bdf9                	j	584 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 6a8:	008b8913          	addi	s2,s7,8
 6ac:	4681                	li	a3,0
 6ae:	4629                	li	a2,10
 6b0:	000ba583          	lw	a1,0(s7)
 6b4:	855a                	mv	a0,s6
 6b6:	dddff0ef          	jal	492 <printint>
 6ba:	8bca                	mv	s7,s2
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	b5d9                	j	584 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c0:	008b8913          	addi	s2,s7,8
 6c4:	4681                	li	a3,0
 6c6:	4629                	li	a2,10
 6c8:	000ba583          	lw	a1,0(s7)
 6cc:	855a                	mv	a0,s6
 6ce:	dc5ff0ef          	jal	492 <printint>
        i += 1;
 6d2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d4:	8bca                	mv	s7,s2
      state = 0;
 6d6:	4981                	li	s3,0
        i += 1;
 6d8:	b575                	j	584 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6da:	008b8913          	addi	s2,s7,8
 6de:	4681                	li	a3,0
 6e0:	4629                	li	a2,10
 6e2:	000ba583          	lw	a1,0(s7)
 6e6:	855a                	mv	a0,s6
 6e8:	dabff0ef          	jal	492 <printint>
        i += 2;
 6ec:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ee:	8bca                	mv	s7,s2
      state = 0;
 6f0:	4981                	li	s3,0
        i += 2;
 6f2:	bd49                	j	584 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 6f4:	008b8913          	addi	s2,s7,8
 6f8:	4681                	li	a3,0
 6fa:	4641                	li	a2,16
 6fc:	000ba583          	lw	a1,0(s7)
 700:	855a                	mv	a0,s6
 702:	d91ff0ef          	jal	492 <printint>
 706:	8bca                	mv	s7,s2
      state = 0;
 708:	4981                	li	s3,0
 70a:	bdad                	j	584 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 70c:	008b8913          	addi	s2,s7,8
 710:	4681                	li	a3,0
 712:	4641                	li	a2,16
 714:	000ba583          	lw	a1,0(s7)
 718:	855a                	mv	a0,s6
 71a:	d79ff0ef          	jal	492 <printint>
        i += 1;
 71e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 720:	8bca                	mv	s7,s2
      state = 0;
 722:	4981                	li	s3,0
        i += 1;
 724:	b585                	j	584 <vprintf+0x4a>
 726:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 728:	008b8d13          	addi	s10,s7,8
 72c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 730:	03000593          	li	a1,48
 734:	855a                	mv	a0,s6
 736:	d3fff0ef          	jal	474 <putc>
  putc(fd, 'x');
 73a:	07800593          	li	a1,120
 73e:	855a                	mv	a0,s6
 740:	d35ff0ef          	jal	474 <putc>
 744:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 746:	00000b97          	auipc	s7,0x0
 74a:	2c2b8b93          	addi	s7,s7,706 # a08 <digits>
 74e:	03c9d793          	srli	a5,s3,0x3c
 752:	97de                	add	a5,a5,s7
 754:	0007c583          	lbu	a1,0(a5)
 758:	855a                	mv	a0,s6
 75a:	d1bff0ef          	jal	474 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 75e:	0992                	slli	s3,s3,0x4
 760:	397d                	addiw	s2,s2,-1
 762:	fe0916e3          	bnez	s2,74e <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 766:	8bea                	mv	s7,s10
      state = 0;
 768:	4981                	li	s3,0
 76a:	6d02                	ld	s10,0(sp)
 76c:	bd21                	j	584 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 76e:	008b8993          	addi	s3,s7,8
 772:	000bb903          	ld	s2,0(s7)
 776:	00090f63          	beqz	s2,794 <vprintf+0x25a>
        for(; *s; s++)
 77a:	00094583          	lbu	a1,0(s2)
 77e:	c195                	beqz	a1,7a2 <vprintf+0x268>
          putc(fd, *s);
 780:	855a                	mv	a0,s6
 782:	cf3ff0ef          	jal	474 <putc>
        for(; *s; s++)
 786:	0905                	addi	s2,s2,1
 788:	00094583          	lbu	a1,0(s2)
 78c:	f9f5                	bnez	a1,780 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 78e:	8bce                	mv	s7,s3
      state = 0;
 790:	4981                	li	s3,0
 792:	bbcd                	j	584 <vprintf+0x4a>
          s = "(null)";
 794:	00000917          	auipc	s2,0x0
 798:	26c90913          	addi	s2,s2,620 # a00 <malloc+0x160>
        for(; *s; s++)
 79c:	02800593          	li	a1,40
 7a0:	b7c5                	j	780 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 7a2:	8bce                	mv	s7,s3
      state = 0;
 7a4:	4981                	li	s3,0
 7a6:	bbf9                	j	584 <vprintf+0x4a>
 7a8:	64a6                	ld	s1,72(sp)
 7aa:	79e2                	ld	s3,56(sp)
 7ac:	7a42                	ld	s4,48(sp)
 7ae:	7aa2                	ld	s5,40(sp)
 7b0:	7b02                	ld	s6,32(sp)
 7b2:	6be2                	ld	s7,24(sp)
 7b4:	6c42                	ld	s8,16(sp)
 7b6:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7b8:	60e6                	ld	ra,88(sp)
 7ba:	6446                	ld	s0,80(sp)
 7bc:	6906                	ld	s2,64(sp)
 7be:	6125                	addi	sp,sp,96
 7c0:	8082                	ret

00000000000007c2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7c2:	715d                	addi	sp,sp,-80
 7c4:	ec06                	sd	ra,24(sp)
 7c6:	e822                	sd	s0,16(sp)
 7c8:	1000                	addi	s0,sp,32
 7ca:	e010                	sd	a2,0(s0)
 7cc:	e414                	sd	a3,8(s0)
 7ce:	e818                	sd	a4,16(s0)
 7d0:	ec1c                	sd	a5,24(s0)
 7d2:	03043023          	sd	a6,32(s0)
 7d6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7da:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7de:	8622                	mv	a2,s0
 7e0:	d5bff0ef          	jal	53a <vprintf>
}
 7e4:	60e2                	ld	ra,24(sp)
 7e6:	6442                	ld	s0,16(sp)
 7e8:	6161                	addi	sp,sp,80
 7ea:	8082                	ret

00000000000007ec <printf>:

void
printf(const char *fmt, ...)
{
 7ec:	711d                	addi	sp,sp,-96
 7ee:	ec06                	sd	ra,24(sp)
 7f0:	e822                	sd	s0,16(sp)
 7f2:	1000                	addi	s0,sp,32
 7f4:	e40c                	sd	a1,8(s0)
 7f6:	e810                	sd	a2,16(s0)
 7f8:	ec14                	sd	a3,24(s0)
 7fa:	f018                	sd	a4,32(s0)
 7fc:	f41c                	sd	a5,40(s0)
 7fe:	03043823          	sd	a6,48(s0)
 802:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 806:	00840613          	addi	a2,s0,8
 80a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 80e:	85aa                	mv	a1,a0
 810:	4505                	li	a0,1
 812:	d29ff0ef          	jal	53a <vprintf>
}
 816:	60e2                	ld	ra,24(sp)
 818:	6442                	ld	s0,16(sp)
 81a:	6125                	addi	sp,sp,96
 81c:	8082                	ret

000000000000081e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 81e:	1141                	addi	sp,sp,-16
 820:	e422                	sd	s0,8(sp)
 822:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 824:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 828:	00001797          	auipc	a5,0x1
 82c:	8107b783          	ld	a5,-2032(a5) # 1038 <freep>
 830:	a02d                	j	85a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 832:	4618                	lw	a4,8(a2)
 834:	9f2d                	addw	a4,a4,a1
 836:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 83a:	6398                	ld	a4,0(a5)
 83c:	6310                	ld	a2,0(a4)
 83e:	a83d                	j	87c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 840:	ff852703          	lw	a4,-8(a0)
 844:	9f31                	addw	a4,a4,a2
 846:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 848:	ff053683          	ld	a3,-16(a0)
 84c:	a091                	j	890 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 84e:	6398                	ld	a4,0(a5)
 850:	00e7e463          	bltu	a5,a4,858 <free+0x3a>
 854:	00e6ea63          	bltu	a3,a4,868 <free+0x4a>
{
 858:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 85a:	fed7fae3          	bgeu	a5,a3,84e <free+0x30>
 85e:	6398                	ld	a4,0(a5)
 860:	00e6e463          	bltu	a3,a4,868 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 864:	fee7eae3          	bltu	a5,a4,858 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 868:	ff852583          	lw	a1,-8(a0)
 86c:	6390                	ld	a2,0(a5)
 86e:	02059813          	slli	a6,a1,0x20
 872:	01c85713          	srli	a4,a6,0x1c
 876:	9736                	add	a4,a4,a3
 878:	fae60de3          	beq	a2,a4,832 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 87c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 880:	4790                	lw	a2,8(a5)
 882:	02061593          	slli	a1,a2,0x20
 886:	01c5d713          	srli	a4,a1,0x1c
 88a:	973e                	add	a4,a4,a5
 88c:	fae68ae3          	beq	a3,a4,840 <free+0x22>
    p->s.ptr = bp->s.ptr;
 890:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 892:	00000717          	auipc	a4,0x0
 896:	7af73323          	sd	a5,1958(a4) # 1038 <freep>
}
 89a:	6422                	ld	s0,8(sp)
 89c:	0141                	addi	sp,sp,16
 89e:	8082                	ret

00000000000008a0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8a0:	7139                	addi	sp,sp,-64
 8a2:	fc06                	sd	ra,56(sp)
 8a4:	f822                	sd	s0,48(sp)
 8a6:	f426                	sd	s1,40(sp)
 8a8:	ec4e                	sd	s3,24(sp)
 8aa:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ac:	02051493          	slli	s1,a0,0x20
 8b0:	9081                	srli	s1,s1,0x20
 8b2:	04bd                	addi	s1,s1,15
 8b4:	8091                	srli	s1,s1,0x4
 8b6:	0014899b          	addiw	s3,s1,1
 8ba:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8bc:	00000517          	auipc	a0,0x0
 8c0:	77c53503          	ld	a0,1916(a0) # 1038 <freep>
 8c4:	c915                	beqz	a0,8f8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c8:	4798                	lw	a4,8(a5)
 8ca:	08977a63          	bgeu	a4,s1,95e <malloc+0xbe>
 8ce:	f04a                	sd	s2,32(sp)
 8d0:	e852                	sd	s4,16(sp)
 8d2:	e456                	sd	s5,8(sp)
 8d4:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8d6:	8a4e                	mv	s4,s3
 8d8:	0009871b          	sext.w	a4,s3
 8dc:	6685                	lui	a3,0x1
 8de:	00d77363          	bgeu	a4,a3,8e4 <malloc+0x44>
 8e2:	6a05                	lui	s4,0x1
 8e4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8e8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ec:	00000917          	auipc	s2,0x0
 8f0:	74c90913          	addi	s2,s2,1868 # 1038 <freep>
  if(p == (char*)-1)
 8f4:	5afd                	li	s5,-1
 8f6:	a081                	j	936 <malloc+0x96>
 8f8:	f04a                	sd	s2,32(sp)
 8fa:	e852                	sd	s4,16(sp)
 8fc:	e456                	sd	s5,8(sp)
 8fe:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 900:	00001797          	auipc	a5,0x1
 904:	bf078793          	addi	a5,a5,-1040 # 14f0 <base>
 908:	00000717          	auipc	a4,0x0
 90c:	72f73823          	sd	a5,1840(a4) # 1038 <freep>
 910:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 912:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 916:	b7c1                	j	8d6 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 918:	6398                	ld	a4,0(a5)
 91a:	e118                	sd	a4,0(a0)
 91c:	a8a9                	j	976 <malloc+0xd6>
  hp->s.size = nu;
 91e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 922:	0541                	addi	a0,a0,16
 924:	efbff0ef          	jal	81e <free>
  return freep;
 928:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 92c:	c12d                	beqz	a0,98e <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 92e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 930:	4798                	lw	a4,8(a5)
 932:	02977263          	bgeu	a4,s1,956 <malloc+0xb6>
    if(p == freep)
 936:	00093703          	ld	a4,0(s2)
 93a:	853e                	mv	a0,a5
 93c:	fef719e3          	bne	a4,a5,92e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 940:	8552                	mv	a0,s4
 942:	b0bff0ef          	jal	44c <sbrk>
  if(p == (char*)-1)
 946:	fd551ce3          	bne	a0,s5,91e <malloc+0x7e>
        return 0;
 94a:	4501                	li	a0,0
 94c:	7902                	ld	s2,32(sp)
 94e:	6a42                	ld	s4,16(sp)
 950:	6aa2                	ld	s5,8(sp)
 952:	6b02                	ld	s6,0(sp)
 954:	a03d                	j	982 <malloc+0xe2>
 956:	7902                	ld	s2,32(sp)
 958:	6a42                	ld	s4,16(sp)
 95a:	6aa2                	ld	s5,8(sp)
 95c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 95e:	fae48de3          	beq	s1,a4,918 <malloc+0x78>
        p->s.size -= nunits;
 962:	4137073b          	subw	a4,a4,s3
 966:	c798                	sw	a4,8(a5)
        p += p->s.size;
 968:	02071693          	slli	a3,a4,0x20
 96c:	01c6d713          	srli	a4,a3,0x1c
 970:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 972:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 976:	00000717          	auipc	a4,0x0
 97a:	6ca73123          	sd	a0,1730(a4) # 1038 <freep>
      return (void*)(p + 1);
 97e:	01078513          	addi	a0,a5,16
  }
}
 982:	70e2                	ld	ra,56(sp)
 984:	7442                	ld	s0,48(sp)
 986:	74a2                	ld	s1,40(sp)
 988:	69e2                	ld	s3,24(sp)
 98a:	6121                	addi	sp,sp,64
 98c:	8082                	ret
 98e:	7902                	ld	s2,32(sp)
 990:	6a42                	ld	s4,16(sp)
 992:	6aa2                	ld	s5,8(sp)
 994:	6b02                	ld	s6,0(sp)
 996:	b7f5                	j	982 <malloc+0xe2>
