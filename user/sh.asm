
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <strstr>:
int fork1(void);  // Fork but panics on failure.
void panic(char*);
struct cmd *parsecmd(char*);
void runcmd(struct cmd*) __attribute__((noreturn));
//تابعی که خودمون تعریف کردیم
char* strstr(const char *haystack, const char *needle) {
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
  if (!*needle) return (char*)haystack;
       6:	0005c783          	lbu	a5,0(a1)
       a:	cf95                	beqz	a5,46 <strstr+0x46>

  for (; *haystack; haystack++) {
       c:	00054783          	lbu	a5,0(a0)
      10:	eb91                	bnez	a5,24 <strstr+0x24>
      n++;
    }
    if (!*n)
      return (char*)haystack;
  }
  return 0;
      12:	4501                	li	a0,0
      14:	a80d                	j	46 <strstr+0x46>
    if (!*n)
      16:	0007c783          	lbu	a5,0(a5)
      1a:	c795                	beqz	a5,46 <strstr+0x46>
  for (; *haystack; haystack++) {
      1c:	0505                	addi	a0,a0,1
      1e:	00054783          	lbu	a5,0(a0)
      22:	c38d                	beqz	a5,44 <strstr+0x44>
    while (*h && *n && *h == *n) {
      24:	00054703          	lbu	a4,0(a0)
    const char *n = needle;
      28:	87ae                	mv	a5,a1
    const char *h = haystack;
      2a:	862a                	mv	a2,a0
    while (*h && *n && *h == *n) {
      2c:	db65                	beqz	a4,1c <strstr+0x1c>
      2e:	0007c683          	lbu	a3,0(a5)
      32:	ca91                	beqz	a3,46 <strstr+0x46>
      34:	fee691e3          	bne	a3,a4,16 <strstr+0x16>
      h++;
      38:	0605                	addi	a2,a2,1
      n++;
      3a:	0785                	addi	a5,a5,1
    while (*h && *n && *h == *n) {
      3c:	00064703          	lbu	a4,0(a2)
      40:	f77d                	bnez	a4,2e <strstr+0x2e>
      42:	bfd1                	j	16 <strstr+0x16>
  return 0;
      44:	4501                	li	a0,0
}
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret

000000000000004c <getcmd>:
  exit(0);
}

int
getcmd(char *buf, int nbuf)
{
      4c:	1101                	addi	sp,sp,-32
      4e:	ec06                	sd	ra,24(sp)
      50:	e822                	sd	s0,16(sp)
      52:	e426                	sd	s1,8(sp)
      54:	e04a                	sd	s2,0(sp)
      56:	1000                	addi	s0,sp,32
      58:	84aa                	mv	s1,a0
      5a:	892e                	mv	s2,a1
  write(2, "$yeganeh-navid ", 15);
      5c:	463d                	li	a2,15
      5e:	00001597          	auipc	a1,0x1
      62:	2f258593          	addi	a1,a1,754 # 1350 <malloc+0x102>
      66:	4509                	li	a0,2
      68:	53b000ef          	jal	da2 <write>
  memset(buf, 0, nbuf);
      6c:	864a                	mv	a2,s2
      6e:	4581                	li	a1,0
      70:	8526                	mv	a0,s1
      72:	32b000ef          	jal	b9c <memset>
  gets(buf, nbuf);
      76:	85ca                	mv	a1,s2
      78:	8526                	mv	a0,s1
      7a:	369000ef          	jal	be2 <gets>
  if(buf[0] == 0) // EOF
      7e:	0004c503          	lbu	a0,0(s1)
      82:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
      86:	40a00533          	neg	a0,a0
      8a:	60e2                	ld	ra,24(sp)
      8c:	6442                	ld	s0,16(sp)
      8e:	64a2                	ld	s1,8(sp)
      90:	6902                	ld	s2,0(sp)
      92:	6105                	addi	sp,sp,32
      94:	8082                	ret

0000000000000096 <panic>:
  exit(0);
}

void
panic(char *s)
{
      96:	1141                	addi	sp,sp,-16
      98:	e406                	sd	ra,8(sp)
      9a:	e022                	sd	s0,0(sp)
      9c:	0800                	addi	s0,sp,16
      9e:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
      a0:	00001597          	auipc	a1,0x1
      a4:	2c058593          	addi	a1,a1,704 # 1360 <malloc+0x112>
      a8:	4509                	li	a0,2
      aa:	0c6010ef          	jal	1170 <fprintf>
  exit(1);
      ae:	4505                	li	a0,1
      b0:	4d3000ef          	jal	d82 <exit>

00000000000000b4 <fork1>:
}

int
fork1(void)
{
      b4:	1141                	addi	sp,sp,-16
      b6:	e406                	sd	ra,8(sp)
      b8:	e022                	sd	s0,0(sp)
      ba:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
      bc:	4bf000ef          	jal	d7a <fork>
  if(pid == -1)
      c0:	57fd                	li	a5,-1
      c2:	00f50663          	beq	a0,a5,ce <fork1+0x1a>
    panic("fork");
  return pid;
}
      c6:	60a2                	ld	ra,8(sp)
      c8:	6402                	ld	s0,0(sp)
      ca:	0141                	addi	sp,sp,16
      cc:	8082                	ret
    panic("fork");
      ce:	00001517          	auipc	a0,0x1
      d2:	2a250513          	addi	a0,a0,674 # 1370 <malloc+0x122>
      d6:	fc1ff0ef          	jal	96 <panic>

00000000000000da <runcmd>:
{
      da:	711d                	addi	sp,sp,-96
      dc:	ec86                	sd	ra,88(sp)
      de:	e8a2                	sd	s0,80(sp)
      e0:	1080                	addi	s0,sp,96
  if(cmd == 0)
      e2:	c505                	beqz	a0,10a <runcmd+0x30>
      e4:	e4a6                	sd	s1,72(sp)
      e6:	e0ca                	sd	s2,64(sp)
      e8:	fc4e                	sd	s3,56(sp)
      ea:	84aa                	mv	s1,a0
  switch(cmd->type){
      ec:	4118                	lw	a4,0(a0)
      ee:	4795                	li	a5,5
      f0:	02e7e763          	bltu	a5,a4,11e <runcmd+0x44>
      f4:	00056783          	lwu	a5,0(a0)
      f8:	078a                	slli	a5,a5,0x2
      fa:	00001717          	auipc	a4,0x1
      fe:	3be70713          	addi	a4,a4,958 # 14b8 <malloc+0x26a>
     102:	97ba                	add	a5,a5,a4
     104:	439c                	lw	a5,0(a5)
     106:	97ba                	add	a5,a5,a4
     108:	8782                	jr	a5
     10a:	e4a6                	sd	s1,72(sp)
     10c:	e0ca                	sd	s2,64(sp)
     10e:	fc4e                	sd	s3,56(sp)
     110:	f852                	sd	s4,48(sp)
     112:	f456                	sd	s5,40(sp)
     114:	f05a                	sd	s6,32(sp)
     116:	ec5e                	sd	s7,24(sp)
    exit(1);
     118:	4505                	li	a0,1
     11a:	469000ef          	jal	d82 <exit>
     11e:	f852                	sd	s4,48(sp)
     120:	f456                	sd	s5,40(sp)
     122:	f05a                	sd	s6,32(sp)
     124:	ec5e                	sd	s7,24(sp)
    panic("runcmd");
     126:	00001517          	auipc	a0,0x1
     12a:	25250513          	addi	a0,a0,594 # 1378 <malloc+0x12a>
     12e:	f69ff0ef          	jal	96 <panic>
    if(ecmd->argv[0] == 0)
     132:	00853983          	ld	s3,8(a0)
     136:	02098063          	beqz	s3,156 <runcmd+0x7c>
    if(strcmp(ecmd->argv[0], "echo") == 0) {
     13a:	00001597          	auipc	a1,0x1
     13e:	24658593          	addi	a1,a1,582 # 1380 <malloc+0x132>
     142:	854e                	mv	a0,s3
     144:	203000ef          	jal	b46 <strcmp>
     148:	892a                	mv	s2,a0
     14a:	e561                	bnez	a0,212 <runcmd+0x138>
        for(int i = 1; ecmd->argv[i]; i++) {
     14c:	6888                	ld	a0,16(s1)
     14e:	c91d                	beqz	a0,184 <runcmd+0xaa>
     150:	01848993          	addi	s3,s1,24
     154:	a819                	j	16a <runcmd+0x90>
     156:	f852                	sd	s4,48(sp)
     158:	f456                	sd	s5,40(sp)
     15a:	f05a                	sd	s6,32(sp)
     15c:	ec5e                	sd	s7,24(sp)
      exit(1);
     15e:	4505                	li	a0,1
     160:	423000ef          	jal	d82 <exit>
      total_len += 1;
     164:	0017891b          	addiw	s2,a5,1
        for(int i = 1; ecmd->argv[i]; i++) {
     168:	09a1                	addi	s3,s3,8
    total_len += strlen(ecmd->argv[i]);
     16a:	209000ef          	jal	b72 <strlen>
     16e:	00a907bb          	addw	a5,s2,a0
     172:	0007871b          	sext.w	a4,a5
    if(ecmd->argv[i+1])  // فاصله‌ها بین کلمات هم باید حساب شن
     176:	0009b503          	ld	a0,0(s3)
     17a:	f56d                	bnez	a0,164 <runcmd+0x8a>
      if(total_len > 512) {
     17c:	20000793          	li	a5,512
     180:	02e7c863          	blt	a5,a4,1b0 <runcmd+0xd6>
     184:	f852                	sd	s4,48(sp)
     186:	f456                	sd	s5,40(sp)
     188:	f05a                	sd	s6,32(sp)
     18a:	ec5e                	sd	s7,24(sp)
     18c:	04c1                	addi	s1,s1,16
        if(strstr(ecmd->argv[i], "os"))
     18e:	00001a17          	auipc	s4,0x1
     192:	212a0a13          	addi	s4,s4,530 # 13a0 <malloc+0x152>
          printf("%s", ecmd->argv[i]);
     196:	00001b97          	auipc	s7,0x1
     19a:	222b8b93          	addi	s7,s7,546 # 13b8 <malloc+0x16a>
          printf("\033[1;34m%s\033[0m", ecmd->argv[i]);
     19e:	00001a97          	auipc	s5,0x1
     1a2:	20aa8a93          	addi	s5,s5,522 # 13a8 <malloc+0x15a>
          printf(" ");
     1a6:	00001b17          	auipc	s6,0x1
     1aa:	21ab0b13          	addi	s6,s6,538 # 13c0 <malloc+0x172>
     1ae:	a025                	j	1d6 <runcmd+0xfc>
     1b0:	f852                	sd	s4,48(sp)
     1b2:	f456                	sd	s5,40(sp)
     1b4:	f05a                	sd	s6,32(sp)
     1b6:	ec5e                	sd	s7,24(sp)
        printf("Message too long\n");
     1b8:	00001517          	auipc	a0,0x1
     1bc:	1d050513          	addi	a0,a0,464 # 1388 <malloc+0x13a>
     1c0:	7db000ef          	jal	119a <printf>
        exit(0);
     1c4:	4501                	li	a0,0
     1c6:	3bd000ef          	jal	d82 <exit>
          printf("%s", ecmd->argv[i]);
     1ca:	85ca                	mv	a1,s2
     1cc:	855e                	mv	a0,s7
     1ce:	7cd000ef          	jal	119a <printf>
     1d2:	a005                	j	1f2 <runcmd+0x118>
     1d4:	04a1                	addi	s1,s1,8
      for(int i = 1; ecmd->argv[i]; i++) {
     1d6:	89a6                	mv	s3,s1
     1d8:	0004b903          	ld	s2,0(s1)
     1dc:	02090263          	beqz	s2,200 <runcmd+0x126>
        if(strstr(ecmd->argv[i], "os"))
     1e0:	85d2                	mv	a1,s4
     1e2:	854a                	mv	a0,s2
     1e4:	e1dff0ef          	jal	0 <strstr>
     1e8:	d16d                	beqz	a0,1ca <runcmd+0xf0>
          printf("\033[1;34m%s\033[0m", ecmd->argv[i]);
     1ea:	85ca                	mv	a1,s2
     1ec:	8556                	mv	a0,s5
     1ee:	7ad000ef          	jal	119a <printf>
        if(ecmd->argv[i+1])
     1f2:	0089b783          	ld	a5,8(s3)
     1f6:	dff9                	beqz	a5,1d4 <runcmd+0xfa>
          printf(" ");
     1f8:	855a                	mv	a0,s6
     1fa:	7a1000ef          	jal	119a <printf>
     1fe:	bfd9                	j	1d4 <runcmd+0xfa>
      printf("\n");
     200:	00001517          	auipc	a0,0x1
     204:	19850513          	addi	a0,a0,408 # 1398 <malloc+0x14a>
     208:	793000ef          	jal	119a <printf>
      exit(0);
     20c:	4501                	li	a0,0
     20e:	375000ef          	jal	d82 <exit>
    exec(ecmd->argv[0], ecmd->argv);
     212:	00848593          	addi	a1,s1,8
     216:	854e                	mv	a0,s3
     218:	3a3000ef          	jal	dba <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     21c:	6490                	ld	a2,8(s1)
     21e:	00001597          	auipc	a1,0x1
     222:	1aa58593          	addi	a1,a1,426 # 13c8 <malloc+0x17a>
     226:	4509                	li	a0,2
     228:	749000ef          	jal	1170 <fprintf>
    break;
     22c:	a239                	j	33a <runcmd+0x260>
    close(rcmd->fd);
     22e:	5148                	lw	a0,36(a0)
     230:	37b000ef          	jal	daa <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     234:	508c                	lw	a1,32(s1)
     236:	6888                	ld	a0,16(s1)
     238:	38b000ef          	jal	dc2 <open>
     23c:	00054963          	bltz	a0,24e <runcmd+0x174>
     240:	f852                	sd	s4,48(sp)
     242:	f456                	sd	s5,40(sp)
     244:	f05a                	sd	s6,32(sp)
     246:	ec5e                	sd	s7,24(sp)
    runcmd(rcmd->cmd);
     248:	6488                	ld	a0,8(s1)
     24a:	e91ff0ef          	jal	da <runcmd>
     24e:	f852                	sd	s4,48(sp)
     250:	f456                	sd	s5,40(sp)
     252:	f05a                	sd	s6,32(sp)
     254:	ec5e                	sd	s7,24(sp)
      fprintf(2, "open %s failed\n", rcmd->file);
     256:	6890                	ld	a2,16(s1)
     258:	00001597          	auipc	a1,0x1
     25c:	18058593          	addi	a1,a1,384 # 13d8 <malloc+0x18a>
     260:	4509                	li	a0,2
     262:	70f000ef          	jal	1170 <fprintf>
      exit(1);
     266:	4505                	li	a0,1
     268:	31b000ef          	jal	d82 <exit>
    if(fork1() == 0)
     26c:	e49ff0ef          	jal	b4 <fork1>
     270:	e901                	bnez	a0,280 <runcmd+0x1a6>
     272:	f852                	sd	s4,48(sp)
     274:	f456                	sd	s5,40(sp)
     276:	f05a                	sd	s6,32(sp)
     278:	ec5e                	sd	s7,24(sp)
      runcmd(lcmd->left);
     27a:	6488                	ld	a0,8(s1)
     27c:	e5fff0ef          	jal	da <runcmd>
     280:	f852                	sd	s4,48(sp)
     282:	f456                	sd	s5,40(sp)
     284:	f05a                	sd	s6,32(sp)
     286:	ec5e                	sd	s7,24(sp)
    wait(0);
     288:	4501                	li	a0,0
     28a:	301000ef          	jal	d8a <wait>
    runcmd(lcmd->right);
     28e:	6888                	ld	a0,16(s1)
     290:	e4bff0ef          	jal	da <runcmd>
    if(pipe(p) < 0)
     294:	fa840513          	addi	a0,s0,-88
     298:	2fb000ef          	jal	d92 <pipe>
     29c:	02054b63          	bltz	a0,2d2 <runcmd+0x1f8>
    if(fork1() == 0){
     2a0:	e15ff0ef          	jal	b4 <fork1>
     2a4:	e129                	bnez	a0,2e6 <runcmd+0x20c>
     2a6:	f852                	sd	s4,48(sp)
     2a8:	f456                	sd	s5,40(sp)
     2aa:	f05a                	sd	s6,32(sp)
     2ac:	ec5e                	sd	s7,24(sp)
      close(1);
     2ae:	4505                	li	a0,1
     2b0:	2fb000ef          	jal	daa <close>
      dup(p[1]);
     2b4:	fac42503          	lw	a0,-84(s0)
     2b8:	343000ef          	jal	dfa <dup>
      close(p[0]);
     2bc:	fa842503          	lw	a0,-88(s0)
     2c0:	2eb000ef          	jal	daa <close>
      close(p[1]);
     2c4:	fac42503          	lw	a0,-84(s0)
     2c8:	2e3000ef          	jal	daa <close>
      runcmd(pcmd->left);
     2cc:	6488                	ld	a0,8(s1)
     2ce:	e0dff0ef          	jal	da <runcmd>
     2d2:	f852                	sd	s4,48(sp)
     2d4:	f456                	sd	s5,40(sp)
     2d6:	f05a                	sd	s6,32(sp)
     2d8:	ec5e                	sd	s7,24(sp)
      panic("pipe");
     2da:	00001517          	auipc	a0,0x1
     2de:	10e50513          	addi	a0,a0,270 # 13e8 <malloc+0x19a>
     2e2:	db5ff0ef          	jal	96 <panic>
    if(fork1() == 0){
     2e6:	dcfff0ef          	jal	b4 <fork1>
     2ea:	e515                	bnez	a0,316 <runcmd+0x23c>
     2ec:	f852                	sd	s4,48(sp)
     2ee:	f456                	sd	s5,40(sp)
     2f0:	f05a                	sd	s6,32(sp)
     2f2:	ec5e                	sd	s7,24(sp)
      close(0);
     2f4:	2b7000ef          	jal	daa <close>
      dup(p[0]);
     2f8:	fa842503          	lw	a0,-88(s0)
     2fc:	2ff000ef          	jal	dfa <dup>
      close(p[0]);
     300:	fa842503          	lw	a0,-88(s0)
     304:	2a7000ef          	jal	daa <close>
      close(p[1]);
     308:	fac42503          	lw	a0,-84(s0)
     30c:	29f000ef          	jal	daa <close>
      runcmd(pcmd->right);
     310:	6888                	ld	a0,16(s1)
     312:	dc9ff0ef          	jal	da <runcmd>
    close(p[0]);
     316:	fa842503          	lw	a0,-88(s0)
     31a:	291000ef          	jal	daa <close>
    close(p[1]);
     31e:	fac42503          	lw	a0,-84(s0)
     322:	289000ef          	jal	daa <close>
    wait(0);
     326:	4501                	li	a0,0
     328:	263000ef          	jal	d8a <wait>
    wait(0);
     32c:	4501                	li	a0,0
     32e:	25d000ef          	jal	d8a <wait>
    break;
     332:	a021                	j	33a <runcmd+0x260>
    if(fork1() == 0)
     334:	d81ff0ef          	jal	b4 <fork1>
     338:	c901                	beqz	a0,348 <runcmd+0x26e>
     33a:	f852                	sd	s4,48(sp)
     33c:	f456                	sd	s5,40(sp)
     33e:	f05a                	sd	s6,32(sp)
     340:	ec5e                	sd	s7,24(sp)
  exit(0);
     342:	4501                	li	a0,0
     344:	23f000ef          	jal	d82 <exit>
     348:	f852                	sd	s4,48(sp)
     34a:	f456                	sd	s5,40(sp)
     34c:	f05a                	sd	s6,32(sp)
     34e:	ec5e                	sd	s7,24(sp)
      runcmd(bcmd->cmd);
     350:	6488                	ld	a0,8(s1)
     352:	d89ff0ef          	jal	da <runcmd>

0000000000000356 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     356:	1101                	addi	sp,sp,-32
     358:	ec06                	sd	ra,24(sp)
     35a:	e822                	sd	s0,16(sp)
     35c:	e426                	sd	s1,8(sp)
     35e:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     360:	0a800513          	li	a0,168
     364:	6eb000ef          	jal	124e <malloc>
     368:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     36a:	0a800613          	li	a2,168
     36e:	4581                	li	a1,0
     370:	02d000ef          	jal	b9c <memset>
  cmd->type = EXEC;
     374:	4785                	li	a5,1
     376:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     378:	8526                	mv	a0,s1
     37a:	60e2                	ld	ra,24(sp)
     37c:	6442                	ld	s0,16(sp)
     37e:	64a2                	ld	s1,8(sp)
     380:	6105                	addi	sp,sp,32
     382:	8082                	ret

0000000000000384 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     384:	7139                	addi	sp,sp,-64
     386:	fc06                	sd	ra,56(sp)
     388:	f822                	sd	s0,48(sp)
     38a:	f426                	sd	s1,40(sp)
     38c:	f04a                	sd	s2,32(sp)
     38e:	ec4e                	sd	s3,24(sp)
     390:	e852                	sd	s4,16(sp)
     392:	e456                	sd	s5,8(sp)
     394:	e05a                	sd	s6,0(sp)
     396:	0080                	addi	s0,sp,64
     398:	8b2a                	mv	s6,a0
     39a:	8aae                	mv	s5,a1
     39c:	8a32                	mv	s4,a2
     39e:	89b6                	mv	s3,a3
     3a0:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3a2:	02800513          	li	a0,40
     3a6:	6a9000ef          	jal	124e <malloc>
     3aa:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3ac:	02800613          	li	a2,40
     3b0:	4581                	li	a1,0
     3b2:	7ea000ef          	jal	b9c <memset>
  cmd->type = REDIR;
     3b6:	4789                	li	a5,2
     3b8:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     3ba:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     3be:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     3c2:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     3c6:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     3ca:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     3ce:	8526                	mv	a0,s1
     3d0:	70e2                	ld	ra,56(sp)
     3d2:	7442                	ld	s0,48(sp)
     3d4:	74a2                	ld	s1,40(sp)
     3d6:	7902                	ld	s2,32(sp)
     3d8:	69e2                	ld	s3,24(sp)
     3da:	6a42                	ld	s4,16(sp)
     3dc:	6aa2                	ld	s5,8(sp)
     3de:	6b02                	ld	s6,0(sp)
     3e0:	6121                	addi	sp,sp,64
     3e2:	8082                	ret

00000000000003e4 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     3e4:	7179                	addi	sp,sp,-48
     3e6:	f406                	sd	ra,40(sp)
     3e8:	f022                	sd	s0,32(sp)
     3ea:	ec26                	sd	s1,24(sp)
     3ec:	e84a                	sd	s2,16(sp)
     3ee:	e44e                	sd	s3,8(sp)
     3f0:	1800                	addi	s0,sp,48
     3f2:	89aa                	mv	s3,a0
     3f4:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3f6:	4561                	li	a0,24
     3f8:	657000ef          	jal	124e <malloc>
     3fc:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3fe:	4661                	li	a2,24
     400:	4581                	li	a1,0
     402:	79a000ef          	jal	b9c <memset>
  cmd->type = PIPE;
     406:	478d                	li	a5,3
     408:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     40a:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     40e:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     412:	8526                	mv	a0,s1
     414:	70a2                	ld	ra,40(sp)
     416:	7402                	ld	s0,32(sp)
     418:	64e2                	ld	s1,24(sp)
     41a:	6942                	ld	s2,16(sp)
     41c:	69a2                	ld	s3,8(sp)
     41e:	6145                	addi	sp,sp,48
     420:	8082                	ret

0000000000000422 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     422:	7179                	addi	sp,sp,-48
     424:	f406                	sd	ra,40(sp)
     426:	f022                	sd	s0,32(sp)
     428:	ec26                	sd	s1,24(sp)
     42a:	e84a                	sd	s2,16(sp)
     42c:	e44e                	sd	s3,8(sp)
     42e:	1800                	addi	s0,sp,48
     430:	89aa                	mv	s3,a0
     432:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     434:	4561                	li	a0,24
     436:	619000ef          	jal	124e <malloc>
     43a:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     43c:	4661                	li	a2,24
     43e:	4581                	li	a1,0
     440:	75c000ef          	jal	b9c <memset>
  cmd->type = LIST;
     444:	4791                	li	a5,4
     446:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     448:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     44c:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     450:	8526                	mv	a0,s1
     452:	70a2                	ld	ra,40(sp)
     454:	7402                	ld	s0,32(sp)
     456:	64e2                	ld	s1,24(sp)
     458:	6942                	ld	s2,16(sp)
     45a:	69a2                	ld	s3,8(sp)
     45c:	6145                	addi	sp,sp,48
     45e:	8082                	ret

0000000000000460 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     460:	1101                	addi	sp,sp,-32
     462:	ec06                	sd	ra,24(sp)
     464:	e822                	sd	s0,16(sp)
     466:	e426                	sd	s1,8(sp)
     468:	e04a                	sd	s2,0(sp)
     46a:	1000                	addi	s0,sp,32
     46c:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     46e:	4541                	li	a0,16
     470:	5df000ef          	jal	124e <malloc>
     474:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     476:	4641                	li	a2,16
     478:	4581                	li	a1,0
     47a:	722000ef          	jal	b9c <memset>
  cmd->type = BACK;
     47e:	4795                	li	a5,5
     480:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     482:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     486:	8526                	mv	a0,s1
     488:	60e2                	ld	ra,24(sp)
     48a:	6442                	ld	s0,16(sp)
     48c:	64a2                	ld	s1,8(sp)
     48e:	6902                	ld	s2,0(sp)
     490:	6105                	addi	sp,sp,32
     492:	8082                	ret

0000000000000494 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     494:	7139                	addi	sp,sp,-64
     496:	fc06                	sd	ra,56(sp)
     498:	f822                	sd	s0,48(sp)
     49a:	f426                	sd	s1,40(sp)
     49c:	f04a                	sd	s2,32(sp)
     49e:	ec4e                	sd	s3,24(sp)
     4a0:	e852                	sd	s4,16(sp)
     4a2:	e456                	sd	s5,8(sp)
     4a4:	e05a                	sd	s6,0(sp)
     4a6:	0080                	addi	s0,sp,64
     4a8:	8a2a                	mv	s4,a0
     4aa:	892e                	mv	s2,a1
     4ac:	8ab2                	mv	s5,a2
     4ae:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     4b0:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     4b2:	00002997          	auipc	s3,0x2
     4b6:	b5698993          	addi	s3,s3,-1194 # 2008 <whitespace>
     4ba:	00b4fc63          	bgeu	s1,a1,4d2 <gettoken+0x3e>
     4be:	0004c583          	lbu	a1,0(s1)
     4c2:	854e                	mv	a0,s3
     4c4:	6fa000ef          	jal	bbe <strchr>
     4c8:	c509                	beqz	a0,4d2 <gettoken+0x3e>
    s++;
     4ca:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     4cc:	fe9919e3          	bne	s2,s1,4be <gettoken+0x2a>
     4d0:	84ca                	mv	s1,s2
  if(q)
     4d2:	000a8463          	beqz	s5,4da <gettoken+0x46>
    *q = s;
     4d6:	009ab023          	sd	s1,0(s5)
  ret = *s;
     4da:	0004c783          	lbu	a5,0(s1)
     4de:	00078a9b          	sext.w	s5,a5
  switch(*s){
     4e2:	03c00713          	li	a4,60
     4e6:	06f76463          	bltu	a4,a5,54e <gettoken+0xba>
     4ea:	03a00713          	li	a4,58
     4ee:	00f76e63          	bltu	a4,a5,50a <gettoken+0x76>
     4f2:	cf89                	beqz	a5,50c <gettoken+0x78>
     4f4:	02600713          	li	a4,38
     4f8:	00e78963          	beq	a5,a4,50a <gettoken+0x76>
     4fc:	fd87879b          	addiw	a5,a5,-40
     500:	0ff7f793          	zext.b	a5,a5
     504:	4705                	li	a4,1
     506:	06f76b63          	bltu	a4,a5,57c <gettoken+0xe8>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     50a:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     50c:	000b0463          	beqz	s6,514 <gettoken+0x80>
    *eq = s;
     510:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     514:	00002997          	auipc	s3,0x2
     518:	af498993          	addi	s3,s3,-1292 # 2008 <whitespace>
     51c:	0124fc63          	bgeu	s1,s2,534 <gettoken+0xa0>
     520:	0004c583          	lbu	a1,0(s1)
     524:	854e                	mv	a0,s3
     526:	698000ef          	jal	bbe <strchr>
     52a:	c509                	beqz	a0,534 <gettoken+0xa0>
    s++;
     52c:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     52e:	fe9919e3          	bne	s2,s1,520 <gettoken+0x8c>
     532:	84ca                	mv	s1,s2
  *ps = s;
     534:	009a3023          	sd	s1,0(s4)
  return ret;
}
     538:	8556                	mv	a0,s5
     53a:	70e2                	ld	ra,56(sp)
     53c:	7442                	ld	s0,48(sp)
     53e:	74a2                	ld	s1,40(sp)
     540:	7902                	ld	s2,32(sp)
     542:	69e2                	ld	s3,24(sp)
     544:	6a42                	ld	s4,16(sp)
     546:	6aa2                	ld	s5,8(sp)
     548:	6b02                	ld	s6,0(sp)
     54a:	6121                	addi	sp,sp,64
     54c:	8082                	ret
  switch(*s){
     54e:	03e00713          	li	a4,62
     552:	02e79163          	bne	a5,a4,574 <gettoken+0xe0>
    s++;
     556:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     55a:	0014c703          	lbu	a4,1(s1)
     55e:	03e00793          	li	a5,62
      s++;
     562:	0489                	addi	s1,s1,2
      ret = '+';
     564:	02b00a93          	li	s5,43
    if(*s == '>'){
     568:	faf702e3          	beq	a4,a5,50c <gettoken+0x78>
    s++;
     56c:	84b6                	mv	s1,a3
  ret = *s;
     56e:	03e00a93          	li	s5,62
     572:	bf69                	j	50c <gettoken+0x78>
  switch(*s){
     574:	07c00713          	li	a4,124
     578:	f8e789e3          	beq	a5,a4,50a <gettoken+0x76>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     57c:	00002997          	auipc	s3,0x2
     580:	a8c98993          	addi	s3,s3,-1396 # 2008 <whitespace>
     584:	00002a97          	auipc	s5,0x2
     588:	a7ca8a93          	addi	s5,s5,-1412 # 2000 <symbols>
     58c:	0324fd63          	bgeu	s1,s2,5c6 <gettoken+0x132>
     590:	0004c583          	lbu	a1,0(s1)
     594:	854e                	mv	a0,s3
     596:	628000ef          	jal	bbe <strchr>
     59a:	e11d                	bnez	a0,5c0 <gettoken+0x12c>
     59c:	0004c583          	lbu	a1,0(s1)
     5a0:	8556                	mv	a0,s5
     5a2:	61c000ef          	jal	bbe <strchr>
     5a6:	e911                	bnez	a0,5ba <gettoken+0x126>
      s++;
     5a8:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     5aa:	fe9913e3          	bne	s2,s1,590 <gettoken+0xfc>
  if(eq)
     5ae:	84ca                	mv	s1,s2
    ret = 'a';
     5b0:	06100a93          	li	s5,97
  if(eq)
     5b4:	f40b1ee3          	bnez	s6,510 <gettoken+0x7c>
     5b8:	bfb5                	j	534 <gettoken+0xa0>
    ret = 'a';
     5ba:	06100a93          	li	s5,97
     5be:	b7b9                	j	50c <gettoken+0x78>
     5c0:	06100a93          	li	s5,97
     5c4:	b7a1                	j	50c <gettoken+0x78>
     5c6:	06100a93          	li	s5,97
  if(eq)
     5ca:	f40b13e3          	bnez	s6,510 <gettoken+0x7c>
     5ce:	b79d                	j	534 <gettoken+0xa0>

00000000000005d0 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     5d0:	7139                	addi	sp,sp,-64
     5d2:	fc06                	sd	ra,56(sp)
     5d4:	f822                	sd	s0,48(sp)
     5d6:	f426                	sd	s1,40(sp)
     5d8:	f04a                	sd	s2,32(sp)
     5da:	ec4e                	sd	s3,24(sp)
     5dc:	e852                	sd	s4,16(sp)
     5de:	e456                	sd	s5,8(sp)
     5e0:	0080                	addi	s0,sp,64
     5e2:	8a2a                	mv	s4,a0
     5e4:	892e                	mv	s2,a1
     5e6:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     5e8:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     5ea:	00002997          	auipc	s3,0x2
     5ee:	a1e98993          	addi	s3,s3,-1506 # 2008 <whitespace>
     5f2:	00b4fc63          	bgeu	s1,a1,60a <peek+0x3a>
     5f6:	0004c583          	lbu	a1,0(s1)
     5fa:	854e                	mv	a0,s3
     5fc:	5c2000ef          	jal	bbe <strchr>
     600:	c509                	beqz	a0,60a <peek+0x3a>
    s++;
     602:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     604:	fe9919e3          	bne	s2,s1,5f6 <peek+0x26>
     608:	84ca                	mv	s1,s2
  *ps = s;
     60a:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     60e:	0004c583          	lbu	a1,0(s1)
     612:	4501                	li	a0,0
     614:	e991                	bnez	a1,628 <peek+0x58>
}
     616:	70e2                	ld	ra,56(sp)
     618:	7442                	ld	s0,48(sp)
     61a:	74a2                	ld	s1,40(sp)
     61c:	7902                	ld	s2,32(sp)
     61e:	69e2                	ld	s3,24(sp)
     620:	6a42                	ld	s4,16(sp)
     622:	6aa2                	ld	s5,8(sp)
     624:	6121                	addi	sp,sp,64
     626:	8082                	ret
  return *s && strchr(toks, *s);
     628:	8556                	mv	a0,s5
     62a:	594000ef          	jal	bbe <strchr>
     62e:	00a03533          	snez	a0,a0
     632:	b7d5                	j	616 <peek+0x46>

0000000000000634 <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     634:	711d                	addi	sp,sp,-96
     636:	ec86                	sd	ra,88(sp)
     638:	e8a2                	sd	s0,80(sp)
     63a:	e4a6                	sd	s1,72(sp)
     63c:	e0ca                	sd	s2,64(sp)
     63e:	fc4e                	sd	s3,56(sp)
     640:	f852                	sd	s4,48(sp)
     642:	f456                	sd	s5,40(sp)
     644:	f05a                	sd	s6,32(sp)
     646:	ec5e                	sd	s7,24(sp)
     648:	1080                	addi	s0,sp,96
     64a:	8a2a                	mv	s4,a0
     64c:	89ae                	mv	s3,a1
     64e:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     650:	00001a97          	auipc	s5,0x1
     654:	dc0a8a93          	addi	s5,s5,-576 # 1410 <malloc+0x1c2>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     658:	06100b13          	li	s6,97
      panic("missing file for redirection");
    switch(tok){
     65c:	03c00b93          	li	s7,60
  while(peek(ps, es, "<>")){
     660:	a00d                	j	682 <parseredirs+0x4e>
      panic("missing file for redirection");
     662:	00001517          	auipc	a0,0x1
     666:	d8e50513          	addi	a0,a0,-626 # 13f0 <malloc+0x1a2>
     66a:	a2dff0ef          	jal	96 <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     66e:	4701                	li	a4,0
     670:	4681                	li	a3,0
     672:	fa043603          	ld	a2,-96(s0)
     676:	fa843583          	ld	a1,-88(s0)
     67a:	8552                	mv	a0,s4
     67c:	d09ff0ef          	jal	384 <redircmd>
     680:	8a2a                	mv	s4,a0
  while(peek(ps, es, "<>")){
     682:	8656                	mv	a2,s5
     684:	85ca                	mv	a1,s2
     686:	854e                	mv	a0,s3
     688:	f49ff0ef          	jal	5d0 <peek>
     68c:	c525                	beqz	a0,6f4 <parseredirs+0xc0>
    tok = gettoken(ps, es, 0, 0);
     68e:	4681                	li	a3,0
     690:	4601                	li	a2,0
     692:	85ca                	mv	a1,s2
     694:	854e                	mv	a0,s3
     696:	dffff0ef          	jal	494 <gettoken>
     69a:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     69c:	fa040693          	addi	a3,s0,-96
     6a0:	fa840613          	addi	a2,s0,-88
     6a4:	85ca                	mv	a1,s2
     6a6:	854e                	mv	a0,s3
     6a8:	dedff0ef          	jal	494 <gettoken>
     6ac:	fb651be3          	bne	a0,s6,662 <parseredirs+0x2e>
    switch(tok){
     6b0:	fb748fe3          	beq	s1,s7,66e <parseredirs+0x3a>
     6b4:	03e00793          	li	a5,62
     6b8:	02f48263          	beq	s1,a5,6dc <parseredirs+0xa8>
     6bc:	02b00793          	li	a5,43
     6c0:	fcf491e3          	bne	s1,a5,682 <parseredirs+0x4e>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     6c4:	4705                	li	a4,1
     6c6:	20100693          	li	a3,513
     6ca:	fa043603          	ld	a2,-96(s0)
     6ce:	fa843583          	ld	a1,-88(s0)
     6d2:	8552                	mv	a0,s4
     6d4:	cb1ff0ef          	jal	384 <redircmd>
     6d8:	8a2a                	mv	s4,a0
      break;
     6da:	b765                	j	682 <parseredirs+0x4e>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     6dc:	4705                	li	a4,1
     6de:	60100693          	li	a3,1537
     6e2:	fa043603          	ld	a2,-96(s0)
     6e6:	fa843583          	ld	a1,-88(s0)
     6ea:	8552                	mv	a0,s4
     6ec:	c99ff0ef          	jal	384 <redircmd>
     6f0:	8a2a                	mv	s4,a0
      break;
     6f2:	bf41                	j	682 <parseredirs+0x4e>
    }
  }
  return cmd;
}
     6f4:	8552                	mv	a0,s4
     6f6:	60e6                	ld	ra,88(sp)
     6f8:	6446                	ld	s0,80(sp)
     6fa:	64a6                	ld	s1,72(sp)
     6fc:	6906                	ld	s2,64(sp)
     6fe:	79e2                	ld	s3,56(sp)
     700:	7a42                	ld	s4,48(sp)
     702:	7aa2                	ld	s5,40(sp)
     704:	7b02                	ld	s6,32(sp)
     706:	6be2                	ld	s7,24(sp)
     708:	6125                	addi	sp,sp,96
     70a:	8082                	ret

000000000000070c <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     70c:	7159                	addi	sp,sp,-112
     70e:	f486                	sd	ra,104(sp)
     710:	f0a2                	sd	s0,96(sp)
     712:	eca6                	sd	s1,88(sp)
     714:	e0d2                	sd	s4,64(sp)
     716:	fc56                	sd	s5,56(sp)
     718:	1880                	addi	s0,sp,112
     71a:	8a2a                	mv	s4,a0
     71c:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     71e:	00001617          	auipc	a2,0x1
     722:	cfa60613          	addi	a2,a2,-774 # 1418 <malloc+0x1ca>
     726:	eabff0ef          	jal	5d0 <peek>
     72a:	e915                	bnez	a0,75e <parseexec+0x52>
     72c:	e8ca                	sd	s2,80(sp)
     72e:	e4ce                	sd	s3,72(sp)
     730:	f85a                	sd	s6,48(sp)
     732:	f45e                	sd	s7,40(sp)
     734:	f062                	sd	s8,32(sp)
     736:	ec66                	sd	s9,24(sp)
     738:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     73a:	c1dff0ef          	jal	356 <execcmd>
     73e:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     740:	8656                	mv	a2,s5
     742:	85d2                	mv	a1,s4
     744:	ef1ff0ef          	jal	634 <parseredirs>
     748:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     74a:	008c0913          	addi	s2,s8,8
     74e:	00001b17          	auipc	s6,0x1
     752:	ceab0b13          	addi	s6,s6,-790 # 1438 <malloc+0x1ea>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     756:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     75a:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     75c:	a815                	j	790 <parseexec+0x84>
    return parseblock(ps, es);
     75e:	85d6                	mv	a1,s5
     760:	8552                	mv	a0,s4
     762:	170000ef          	jal	8d2 <parseblock>
     766:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     768:	8526                	mv	a0,s1
     76a:	70a6                	ld	ra,104(sp)
     76c:	7406                	ld	s0,96(sp)
     76e:	64e6                	ld	s1,88(sp)
     770:	6a06                	ld	s4,64(sp)
     772:	7ae2                	ld	s5,56(sp)
     774:	6165                	addi	sp,sp,112
     776:	8082                	ret
      panic("syntax");
     778:	00001517          	auipc	a0,0x1
     77c:	ca850513          	addi	a0,a0,-856 # 1420 <malloc+0x1d2>
     780:	917ff0ef          	jal	96 <panic>
    ret = parseredirs(ret, ps, es);
     784:	8656                	mv	a2,s5
     786:	85d2                	mv	a1,s4
     788:	8526                	mv	a0,s1
     78a:	eabff0ef          	jal	634 <parseredirs>
     78e:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     790:	865a                	mv	a2,s6
     792:	85d6                	mv	a1,s5
     794:	8552                	mv	a0,s4
     796:	e3bff0ef          	jal	5d0 <peek>
     79a:	ed15                	bnez	a0,7d6 <parseexec+0xca>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     79c:	f9040693          	addi	a3,s0,-112
     7a0:	f9840613          	addi	a2,s0,-104
     7a4:	85d6                	mv	a1,s5
     7a6:	8552                	mv	a0,s4
     7a8:	cedff0ef          	jal	494 <gettoken>
     7ac:	c50d                	beqz	a0,7d6 <parseexec+0xca>
    if(tok != 'a')
     7ae:	fd9515e3          	bne	a0,s9,778 <parseexec+0x6c>
    cmd->argv[argc] = q;
     7b2:	f9843783          	ld	a5,-104(s0)
     7b6:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     7ba:	f9043783          	ld	a5,-112(s0)
     7be:	04f93823          	sd	a5,80(s2)
    argc++;
     7c2:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     7c4:	0921                	addi	s2,s2,8
     7c6:	fb799fe3          	bne	s3,s7,784 <parseexec+0x78>
      panic("too many args");
     7ca:	00001517          	auipc	a0,0x1
     7ce:	c5e50513          	addi	a0,a0,-930 # 1428 <malloc+0x1da>
     7d2:	8c5ff0ef          	jal	96 <panic>
  cmd->argv[argc] = 0;
     7d6:	098e                	slli	s3,s3,0x3
     7d8:	9c4e                	add	s8,s8,s3
     7da:	000c3423          	sd	zero,8(s8)
  cmd->eargv[argc] = 0;
     7de:	040c3c23          	sd	zero,88(s8)
     7e2:	6946                	ld	s2,80(sp)
     7e4:	69a6                	ld	s3,72(sp)
     7e6:	7b42                	ld	s6,48(sp)
     7e8:	7ba2                	ld	s7,40(sp)
     7ea:	7c02                	ld	s8,32(sp)
     7ec:	6ce2                	ld	s9,24(sp)
  return ret;
     7ee:	bfad                	j	768 <parseexec+0x5c>

00000000000007f0 <parsepipe>:
{
     7f0:	7179                	addi	sp,sp,-48
     7f2:	f406                	sd	ra,40(sp)
     7f4:	f022                	sd	s0,32(sp)
     7f6:	ec26                	sd	s1,24(sp)
     7f8:	e84a                	sd	s2,16(sp)
     7fa:	e44e                	sd	s3,8(sp)
     7fc:	1800                	addi	s0,sp,48
     7fe:	892a                	mv	s2,a0
     800:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     802:	f0bff0ef          	jal	70c <parseexec>
     806:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     808:	00001617          	auipc	a2,0x1
     80c:	c3860613          	addi	a2,a2,-968 # 1440 <malloc+0x1f2>
     810:	85ce                	mv	a1,s3
     812:	854a                	mv	a0,s2
     814:	dbdff0ef          	jal	5d0 <peek>
     818:	e909                	bnez	a0,82a <parsepipe+0x3a>
}
     81a:	8526                	mv	a0,s1
     81c:	70a2                	ld	ra,40(sp)
     81e:	7402                	ld	s0,32(sp)
     820:	64e2                	ld	s1,24(sp)
     822:	6942                	ld	s2,16(sp)
     824:	69a2                	ld	s3,8(sp)
     826:	6145                	addi	sp,sp,48
     828:	8082                	ret
    gettoken(ps, es, 0, 0);
     82a:	4681                	li	a3,0
     82c:	4601                	li	a2,0
     82e:	85ce                	mv	a1,s3
     830:	854a                	mv	a0,s2
     832:	c63ff0ef          	jal	494 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     836:	85ce                	mv	a1,s3
     838:	854a                	mv	a0,s2
     83a:	fb7ff0ef          	jal	7f0 <parsepipe>
     83e:	85aa                	mv	a1,a0
     840:	8526                	mv	a0,s1
     842:	ba3ff0ef          	jal	3e4 <pipecmd>
     846:	84aa                	mv	s1,a0
  return cmd;
     848:	bfc9                	j	81a <parsepipe+0x2a>

000000000000084a <parseline>:
{
     84a:	7179                	addi	sp,sp,-48
     84c:	f406                	sd	ra,40(sp)
     84e:	f022                	sd	s0,32(sp)
     850:	ec26                	sd	s1,24(sp)
     852:	e84a                	sd	s2,16(sp)
     854:	e44e                	sd	s3,8(sp)
     856:	e052                	sd	s4,0(sp)
     858:	1800                	addi	s0,sp,48
     85a:	892a                	mv	s2,a0
     85c:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     85e:	f93ff0ef          	jal	7f0 <parsepipe>
     862:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     864:	00001a17          	auipc	s4,0x1
     868:	be4a0a13          	addi	s4,s4,-1052 # 1448 <malloc+0x1fa>
     86c:	a819                	j	882 <parseline+0x38>
    gettoken(ps, es, 0, 0);
     86e:	4681                	li	a3,0
     870:	4601                	li	a2,0
     872:	85ce                	mv	a1,s3
     874:	854a                	mv	a0,s2
     876:	c1fff0ef          	jal	494 <gettoken>
    cmd = backcmd(cmd);
     87a:	8526                	mv	a0,s1
     87c:	be5ff0ef          	jal	460 <backcmd>
     880:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     882:	8652                	mv	a2,s4
     884:	85ce                	mv	a1,s3
     886:	854a                	mv	a0,s2
     888:	d49ff0ef          	jal	5d0 <peek>
     88c:	f16d                	bnez	a0,86e <parseline+0x24>
  if(peek(ps, es, ";")){
     88e:	00001617          	auipc	a2,0x1
     892:	bc260613          	addi	a2,a2,-1086 # 1450 <malloc+0x202>
     896:	85ce                	mv	a1,s3
     898:	854a                	mv	a0,s2
     89a:	d37ff0ef          	jal	5d0 <peek>
     89e:	e911                	bnez	a0,8b2 <parseline+0x68>
}
     8a0:	8526                	mv	a0,s1
     8a2:	70a2                	ld	ra,40(sp)
     8a4:	7402                	ld	s0,32(sp)
     8a6:	64e2                	ld	s1,24(sp)
     8a8:	6942                	ld	s2,16(sp)
     8aa:	69a2                	ld	s3,8(sp)
     8ac:	6a02                	ld	s4,0(sp)
     8ae:	6145                	addi	sp,sp,48
     8b0:	8082                	ret
    gettoken(ps, es, 0, 0);
     8b2:	4681                	li	a3,0
     8b4:	4601                	li	a2,0
     8b6:	85ce                	mv	a1,s3
     8b8:	854a                	mv	a0,s2
     8ba:	bdbff0ef          	jal	494 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     8be:	85ce                	mv	a1,s3
     8c0:	854a                	mv	a0,s2
     8c2:	f89ff0ef          	jal	84a <parseline>
     8c6:	85aa                	mv	a1,a0
     8c8:	8526                	mv	a0,s1
     8ca:	b59ff0ef          	jal	422 <listcmd>
     8ce:	84aa                	mv	s1,a0
  return cmd;
     8d0:	bfc1                	j	8a0 <parseline+0x56>

00000000000008d2 <parseblock>:
{
     8d2:	7179                	addi	sp,sp,-48
     8d4:	f406                	sd	ra,40(sp)
     8d6:	f022                	sd	s0,32(sp)
     8d8:	ec26                	sd	s1,24(sp)
     8da:	e84a                	sd	s2,16(sp)
     8dc:	e44e                	sd	s3,8(sp)
     8de:	1800                	addi	s0,sp,48
     8e0:	84aa                	mv	s1,a0
     8e2:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     8e4:	00001617          	auipc	a2,0x1
     8e8:	b3460613          	addi	a2,a2,-1228 # 1418 <malloc+0x1ca>
     8ec:	ce5ff0ef          	jal	5d0 <peek>
     8f0:	c539                	beqz	a0,93e <parseblock+0x6c>
  gettoken(ps, es, 0, 0);
     8f2:	4681                	li	a3,0
     8f4:	4601                	li	a2,0
     8f6:	85ca                	mv	a1,s2
     8f8:	8526                	mv	a0,s1
     8fa:	b9bff0ef          	jal	494 <gettoken>
  cmd = parseline(ps, es);
     8fe:	85ca                	mv	a1,s2
     900:	8526                	mv	a0,s1
     902:	f49ff0ef          	jal	84a <parseline>
     906:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     908:	00001617          	auipc	a2,0x1
     90c:	b6060613          	addi	a2,a2,-1184 # 1468 <malloc+0x21a>
     910:	85ca                	mv	a1,s2
     912:	8526                	mv	a0,s1
     914:	cbdff0ef          	jal	5d0 <peek>
     918:	c90d                	beqz	a0,94a <parseblock+0x78>
  gettoken(ps, es, 0, 0);
     91a:	4681                	li	a3,0
     91c:	4601                	li	a2,0
     91e:	85ca                	mv	a1,s2
     920:	8526                	mv	a0,s1
     922:	b73ff0ef          	jal	494 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     926:	864a                	mv	a2,s2
     928:	85a6                	mv	a1,s1
     92a:	854e                	mv	a0,s3
     92c:	d09ff0ef          	jal	634 <parseredirs>
}
     930:	70a2                	ld	ra,40(sp)
     932:	7402                	ld	s0,32(sp)
     934:	64e2                	ld	s1,24(sp)
     936:	6942                	ld	s2,16(sp)
     938:	69a2                	ld	s3,8(sp)
     93a:	6145                	addi	sp,sp,48
     93c:	8082                	ret
    panic("parseblock");
     93e:	00001517          	auipc	a0,0x1
     942:	b1a50513          	addi	a0,a0,-1254 # 1458 <malloc+0x20a>
     946:	f50ff0ef          	jal	96 <panic>
    panic("syntax - missing )");
     94a:	00001517          	auipc	a0,0x1
     94e:	b2650513          	addi	a0,a0,-1242 # 1470 <malloc+0x222>
     952:	f44ff0ef          	jal	96 <panic>

0000000000000956 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     956:	1101                	addi	sp,sp,-32
     958:	ec06                	sd	ra,24(sp)
     95a:	e822                	sd	s0,16(sp)
     95c:	e426                	sd	s1,8(sp)
     95e:	1000                	addi	s0,sp,32
     960:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     962:	c131                	beqz	a0,9a6 <nulterminate+0x50>
    return 0;

  switch(cmd->type){
     964:	4118                	lw	a4,0(a0)
     966:	4795                	li	a5,5
     968:	02e7ef63          	bltu	a5,a4,9a6 <nulterminate+0x50>
     96c:	00056783          	lwu	a5,0(a0)
     970:	078a                	slli	a5,a5,0x2
     972:	00001717          	auipc	a4,0x1
     976:	b5e70713          	addi	a4,a4,-1186 # 14d0 <malloc+0x282>
     97a:	97ba                	add	a5,a5,a4
     97c:	439c                	lw	a5,0(a5)
     97e:	97ba                	add	a5,a5,a4
     980:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     982:	651c                	ld	a5,8(a0)
     984:	c38d                	beqz	a5,9a6 <nulterminate+0x50>
     986:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     98a:	67b8                	ld	a4,72(a5)
     98c:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     990:	07a1                	addi	a5,a5,8
     992:	ff87b703          	ld	a4,-8(a5)
     996:	fb75                	bnez	a4,98a <nulterminate+0x34>
     998:	a039                	j	9a6 <nulterminate+0x50>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     99a:	6508                	ld	a0,8(a0)
     99c:	fbbff0ef          	jal	956 <nulterminate>
    *rcmd->efile = 0;
     9a0:	6c9c                	ld	a5,24(s1)
     9a2:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     9a6:	8526                	mv	a0,s1
     9a8:	60e2                	ld	ra,24(sp)
     9aa:	6442                	ld	s0,16(sp)
     9ac:	64a2                	ld	s1,8(sp)
     9ae:	6105                	addi	sp,sp,32
     9b0:	8082                	ret
    nulterminate(pcmd->left);
     9b2:	6508                	ld	a0,8(a0)
     9b4:	fa3ff0ef          	jal	956 <nulterminate>
    nulterminate(pcmd->right);
     9b8:	6888                	ld	a0,16(s1)
     9ba:	f9dff0ef          	jal	956 <nulterminate>
    break;
     9be:	b7e5                	j	9a6 <nulterminate+0x50>
    nulterminate(lcmd->left);
     9c0:	6508                	ld	a0,8(a0)
     9c2:	f95ff0ef          	jal	956 <nulterminate>
    nulterminate(lcmd->right);
     9c6:	6888                	ld	a0,16(s1)
     9c8:	f8fff0ef          	jal	956 <nulterminate>
    break;
     9cc:	bfe9                	j	9a6 <nulterminate+0x50>
    nulterminate(bcmd->cmd);
     9ce:	6508                	ld	a0,8(a0)
     9d0:	f87ff0ef          	jal	956 <nulterminate>
    break;
     9d4:	bfc9                	j	9a6 <nulterminate+0x50>

00000000000009d6 <parsecmd>:
{
     9d6:	7179                	addi	sp,sp,-48
     9d8:	f406                	sd	ra,40(sp)
     9da:	f022                	sd	s0,32(sp)
     9dc:	ec26                	sd	s1,24(sp)
     9de:	e84a                	sd	s2,16(sp)
     9e0:	1800                	addi	s0,sp,48
     9e2:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     9e6:	84aa                	mv	s1,a0
     9e8:	18a000ef          	jal	b72 <strlen>
     9ec:	1502                	slli	a0,a0,0x20
     9ee:	9101                	srli	a0,a0,0x20
     9f0:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     9f2:	85a6                	mv	a1,s1
     9f4:	fd840513          	addi	a0,s0,-40
     9f8:	e53ff0ef          	jal	84a <parseline>
     9fc:	892a                	mv	s2,a0
  peek(&s, es, "");
     9fe:	00001617          	auipc	a2,0x1
     a02:	96a60613          	addi	a2,a2,-1686 # 1368 <malloc+0x11a>
     a06:	85a6                	mv	a1,s1
     a08:	fd840513          	addi	a0,s0,-40
     a0c:	bc5ff0ef          	jal	5d0 <peek>
  if(s != es){
     a10:	fd843603          	ld	a2,-40(s0)
     a14:	00961c63          	bne	a2,s1,a2c <parsecmd+0x56>
  nulterminate(cmd);
     a18:	854a                	mv	a0,s2
     a1a:	f3dff0ef          	jal	956 <nulterminate>
}
     a1e:	854a                	mv	a0,s2
     a20:	70a2                	ld	ra,40(sp)
     a22:	7402                	ld	s0,32(sp)
     a24:	64e2                	ld	s1,24(sp)
     a26:	6942                	ld	s2,16(sp)
     a28:	6145                	addi	sp,sp,48
     a2a:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     a2c:	00001597          	auipc	a1,0x1
     a30:	a5c58593          	addi	a1,a1,-1444 # 1488 <malloc+0x23a>
     a34:	4509                	li	a0,2
     a36:	73a000ef          	jal	1170 <fprintf>
    panic("syntax");
     a3a:	00001517          	auipc	a0,0x1
     a3e:	9e650513          	addi	a0,a0,-1562 # 1420 <malloc+0x1d2>
     a42:	e54ff0ef          	jal	96 <panic>

0000000000000a46 <main>:
{
     a46:	7139                	addi	sp,sp,-64
     a48:	fc06                	sd	ra,56(sp)
     a4a:	f822                	sd	s0,48(sp)
     a4c:	f426                	sd	s1,40(sp)
     a4e:	f04a                	sd	s2,32(sp)
     a50:	ec4e                	sd	s3,24(sp)
     a52:	e852                	sd	s4,16(sp)
     a54:	e456                	sd	s5,8(sp)
     a56:	0080                	addi	s0,sp,64
  while((fd = open("console", O_RDWR)) >= 0){
     a58:	00001497          	auipc	s1,0x1
     a5c:	a4048493          	addi	s1,s1,-1472 # 1498 <malloc+0x24a>
     a60:	4589                	li	a1,2
     a62:	8526                	mv	a0,s1
     a64:	35e000ef          	jal	dc2 <open>
     a68:	00054763          	bltz	a0,a76 <main+0x30>
    if(fd >= 3){
     a6c:	4789                	li	a5,2
     a6e:	fea7d9e3          	bge	a5,a0,a60 <main+0x1a>
      close(fd);
     a72:	338000ef          	jal	daa <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     a76:	00001497          	auipc	s1,0x1
     a7a:	5aa48493          	addi	s1,s1,1450 # 2020 <buf.0>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     a7e:	06300913          	li	s2,99
     a82:	06400993          	li	s3,100
     a86:	02000a13          	li	s4,32
     a8a:	a039                	j	a98 <main+0x52>
    if(fork1() == 0)
     a8c:	e28ff0ef          	jal	b4 <fork1>
     a90:	c92d                	beqz	a0,b02 <main+0xbc>
    wait(0);
     a92:	4501                	li	a0,0
     a94:	2f6000ef          	jal	d8a <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     a98:	25800593          	li	a1,600
     a9c:	8526                	mv	a0,s1
     a9e:	daeff0ef          	jal	4c <getcmd>
     aa2:	06054863          	bltz	a0,b12 <main+0xcc>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     aa6:	0004c783          	lbu	a5,0(s1)
     aaa:	ff2791e3          	bne	a5,s2,a8c <main+0x46>
     aae:	0014c783          	lbu	a5,1(s1)
     ab2:	fd379de3          	bne	a5,s3,a8c <main+0x46>
     ab6:	0024c783          	lbu	a5,2(s1)
     aba:	fd4799e3          	bne	a5,s4,a8c <main+0x46>
      buf[strlen(buf)-1] = 0;  // chop \n
     abe:	00001a97          	auipc	s5,0x1
     ac2:	562a8a93          	addi	s5,s5,1378 # 2020 <buf.0>
     ac6:	8556                	mv	a0,s5
     ac8:	0aa000ef          	jal	b72 <strlen>
     acc:	fff5079b          	addiw	a5,a0,-1
     ad0:	1782                	slli	a5,a5,0x20
     ad2:	9381                	srli	a5,a5,0x20
     ad4:	9abe                	add	s5,s5,a5
     ad6:	000a8023          	sb	zero,0(s5)
      if(chdir(buf+3) < 0)
     ada:	00001517          	auipc	a0,0x1
     ade:	54950513          	addi	a0,a0,1353 # 2023 <buf.0+0x3>
     ae2:	310000ef          	jal	df2 <chdir>
     ae6:	fa0559e3          	bgez	a0,a98 <main+0x52>
        fprintf(2, "cannot cd %s\n", buf+3);
     aea:	00001617          	auipc	a2,0x1
     aee:	53960613          	addi	a2,a2,1337 # 2023 <buf.0+0x3>
     af2:	00001597          	auipc	a1,0x1
     af6:	9ae58593          	addi	a1,a1,-1618 # 14a0 <malloc+0x252>
     afa:	4509                	li	a0,2
     afc:	674000ef          	jal	1170 <fprintf>
     b00:	bf61                	j	a98 <main+0x52>
      runcmd(parsecmd(buf));
     b02:	00001517          	auipc	a0,0x1
     b06:	51e50513          	addi	a0,a0,1310 # 2020 <buf.0>
     b0a:	ecdff0ef          	jal	9d6 <parsecmd>
     b0e:	dccff0ef          	jal	da <runcmd>
  exit(0);
     b12:	4501                	li	a0,0
     b14:	26e000ef          	jal	d82 <exit>

0000000000000b18 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
     b18:	1141                	addi	sp,sp,-16
     b1a:	e406                	sd	ra,8(sp)
     b1c:	e022                	sd	s0,0(sp)
     b1e:	0800                	addi	s0,sp,16
  extern int main();
  main();
     b20:	f27ff0ef          	jal	a46 <main>
  exit(0);
     b24:	4501                	li	a0,0
     b26:	25c000ef          	jal	d82 <exit>

0000000000000b2a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     b2a:	1141                	addi	sp,sp,-16
     b2c:	e422                	sd	s0,8(sp)
     b2e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     b30:	87aa                	mv	a5,a0
     b32:	0585                	addi	a1,a1,1
     b34:	0785                	addi	a5,a5,1
     b36:	fff5c703          	lbu	a4,-1(a1)
     b3a:	fee78fa3          	sb	a4,-1(a5)
     b3e:	fb75                	bnez	a4,b32 <strcpy+0x8>
    ;
  return os;
}
     b40:	6422                	ld	s0,8(sp)
     b42:	0141                	addi	sp,sp,16
     b44:	8082                	ret

0000000000000b46 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     b46:	1141                	addi	sp,sp,-16
     b48:	e422                	sd	s0,8(sp)
     b4a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     b4c:	00054783          	lbu	a5,0(a0)
     b50:	cb91                	beqz	a5,b64 <strcmp+0x1e>
     b52:	0005c703          	lbu	a4,0(a1)
     b56:	00f71763          	bne	a4,a5,b64 <strcmp+0x1e>
    p++, q++;
     b5a:	0505                	addi	a0,a0,1
     b5c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     b5e:	00054783          	lbu	a5,0(a0)
     b62:	fbe5                	bnez	a5,b52 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     b64:	0005c503          	lbu	a0,0(a1)
}
     b68:	40a7853b          	subw	a0,a5,a0
     b6c:	6422                	ld	s0,8(sp)
     b6e:	0141                	addi	sp,sp,16
     b70:	8082                	ret

0000000000000b72 <strlen>:

uint
strlen(const char *s)
{
     b72:	1141                	addi	sp,sp,-16
     b74:	e422                	sd	s0,8(sp)
     b76:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     b78:	00054783          	lbu	a5,0(a0)
     b7c:	cf91                	beqz	a5,b98 <strlen+0x26>
     b7e:	0505                	addi	a0,a0,1
     b80:	87aa                	mv	a5,a0
     b82:	86be                	mv	a3,a5
     b84:	0785                	addi	a5,a5,1
     b86:	fff7c703          	lbu	a4,-1(a5)
     b8a:	ff65                	bnez	a4,b82 <strlen+0x10>
     b8c:	40a6853b          	subw	a0,a3,a0
     b90:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     b92:	6422                	ld	s0,8(sp)
     b94:	0141                	addi	sp,sp,16
     b96:	8082                	ret
  for(n = 0; s[n]; n++)
     b98:	4501                	li	a0,0
     b9a:	bfe5                	j	b92 <strlen+0x20>

0000000000000b9c <memset>:

void*
memset(void *dst, int c, uint n)
{
     b9c:	1141                	addi	sp,sp,-16
     b9e:	e422                	sd	s0,8(sp)
     ba0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     ba2:	ca19                	beqz	a2,bb8 <memset+0x1c>
     ba4:	87aa                	mv	a5,a0
     ba6:	1602                	slli	a2,a2,0x20
     ba8:	9201                	srli	a2,a2,0x20
     baa:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     bae:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     bb2:	0785                	addi	a5,a5,1
     bb4:	fee79de3          	bne	a5,a4,bae <memset+0x12>
  }
  return dst;
}
     bb8:	6422                	ld	s0,8(sp)
     bba:	0141                	addi	sp,sp,16
     bbc:	8082                	ret

0000000000000bbe <strchr>:

char*
strchr(const char *s, char c)
{
     bbe:	1141                	addi	sp,sp,-16
     bc0:	e422                	sd	s0,8(sp)
     bc2:	0800                	addi	s0,sp,16
  for(; *s; s++)
     bc4:	00054783          	lbu	a5,0(a0)
     bc8:	cb99                	beqz	a5,bde <strchr+0x20>
    if(*s == c)
     bca:	00f58763          	beq	a1,a5,bd8 <strchr+0x1a>
  for(; *s; s++)
     bce:	0505                	addi	a0,a0,1
     bd0:	00054783          	lbu	a5,0(a0)
     bd4:	fbfd                	bnez	a5,bca <strchr+0xc>
      return (char*)s;
  return 0;
     bd6:	4501                	li	a0,0
}
     bd8:	6422                	ld	s0,8(sp)
     bda:	0141                	addi	sp,sp,16
     bdc:	8082                	ret
  return 0;
     bde:	4501                	li	a0,0
     be0:	bfe5                	j	bd8 <strchr+0x1a>

0000000000000be2 <gets>:

char*
gets(char *buf, int max)
{
     be2:	711d                	addi	sp,sp,-96
     be4:	ec86                	sd	ra,88(sp)
     be6:	e8a2                	sd	s0,80(sp)
     be8:	e4a6                	sd	s1,72(sp)
     bea:	e0ca                	sd	s2,64(sp)
     bec:	fc4e                	sd	s3,56(sp)
     bee:	f852                	sd	s4,48(sp)
     bf0:	f456                	sd	s5,40(sp)
     bf2:	f05a                	sd	s6,32(sp)
     bf4:	ec5e                	sd	s7,24(sp)
     bf6:	1080                	addi	s0,sp,96
     bf8:	8baa                	mv	s7,a0
     bfa:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     bfc:	892a                	mv	s2,a0
     bfe:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     c00:	4aa9                	li	s5,10
     c02:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     c04:	89a6                	mv	s3,s1
     c06:	2485                	addiw	s1,s1,1
     c08:	0344d663          	bge	s1,s4,c34 <gets+0x52>
    cc = read(0, &c, 1);
     c0c:	4605                	li	a2,1
     c0e:	faf40593          	addi	a1,s0,-81
     c12:	4501                	li	a0,0
     c14:	186000ef          	jal	d9a <read>
    if(cc < 1)
     c18:	00a05e63          	blez	a0,c34 <gets+0x52>
    buf[i++] = c;
     c1c:	faf44783          	lbu	a5,-81(s0)
     c20:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     c24:	01578763          	beq	a5,s5,c32 <gets+0x50>
     c28:	0905                	addi	s2,s2,1
     c2a:	fd679de3          	bne	a5,s6,c04 <gets+0x22>
    buf[i++] = c;
     c2e:	89a6                	mv	s3,s1
     c30:	a011                	j	c34 <gets+0x52>
     c32:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     c34:	99de                	add	s3,s3,s7
     c36:	00098023          	sb	zero,0(s3)
  return buf;
}
     c3a:	855e                	mv	a0,s7
     c3c:	60e6                	ld	ra,88(sp)
     c3e:	6446                	ld	s0,80(sp)
     c40:	64a6                	ld	s1,72(sp)
     c42:	6906                	ld	s2,64(sp)
     c44:	79e2                	ld	s3,56(sp)
     c46:	7a42                	ld	s4,48(sp)
     c48:	7aa2                	ld	s5,40(sp)
     c4a:	7b02                	ld	s6,32(sp)
     c4c:	6be2                	ld	s7,24(sp)
     c4e:	6125                	addi	sp,sp,96
     c50:	8082                	ret

0000000000000c52 <stat>:

int
stat(const char *n, struct stat *st)
{
     c52:	1101                	addi	sp,sp,-32
     c54:	ec06                	sd	ra,24(sp)
     c56:	e822                	sd	s0,16(sp)
     c58:	e04a                	sd	s2,0(sp)
     c5a:	1000                	addi	s0,sp,32
     c5c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     c5e:	4581                	li	a1,0
     c60:	162000ef          	jal	dc2 <open>
  if(fd < 0)
     c64:	02054263          	bltz	a0,c88 <stat+0x36>
     c68:	e426                	sd	s1,8(sp)
     c6a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     c6c:	85ca                	mv	a1,s2
     c6e:	16c000ef          	jal	dda <fstat>
     c72:	892a                	mv	s2,a0
  close(fd);
     c74:	8526                	mv	a0,s1
     c76:	134000ef          	jal	daa <close>
  return r;
     c7a:	64a2                	ld	s1,8(sp)
}
     c7c:	854a                	mv	a0,s2
     c7e:	60e2                	ld	ra,24(sp)
     c80:	6442                	ld	s0,16(sp)
     c82:	6902                	ld	s2,0(sp)
     c84:	6105                	addi	sp,sp,32
     c86:	8082                	ret
    return -1;
     c88:	597d                	li	s2,-1
     c8a:	bfcd                	j	c7c <stat+0x2a>

0000000000000c8c <atoi>:

int
atoi(const char *s)
{
     c8c:	1141                	addi	sp,sp,-16
     c8e:	e422                	sd	s0,8(sp)
     c90:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     c92:	00054683          	lbu	a3,0(a0)
     c96:	fd06879b          	addiw	a5,a3,-48
     c9a:	0ff7f793          	zext.b	a5,a5
     c9e:	4625                	li	a2,9
     ca0:	02f66863          	bltu	a2,a5,cd0 <atoi+0x44>
     ca4:	872a                	mv	a4,a0
  n = 0;
     ca6:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     ca8:	0705                	addi	a4,a4,1
     caa:	0025179b          	slliw	a5,a0,0x2
     cae:	9fa9                	addw	a5,a5,a0
     cb0:	0017979b          	slliw	a5,a5,0x1
     cb4:	9fb5                	addw	a5,a5,a3
     cb6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     cba:	00074683          	lbu	a3,0(a4)
     cbe:	fd06879b          	addiw	a5,a3,-48
     cc2:	0ff7f793          	zext.b	a5,a5
     cc6:	fef671e3          	bgeu	a2,a5,ca8 <atoi+0x1c>
  return n;
}
     cca:	6422                	ld	s0,8(sp)
     ccc:	0141                	addi	sp,sp,16
     cce:	8082                	ret
  n = 0;
     cd0:	4501                	li	a0,0
     cd2:	bfe5                	j	cca <atoi+0x3e>

0000000000000cd4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     cd4:	1141                	addi	sp,sp,-16
     cd6:	e422                	sd	s0,8(sp)
     cd8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     cda:	02b57463          	bgeu	a0,a1,d02 <memmove+0x2e>
    while(n-- > 0)
     cde:	00c05f63          	blez	a2,cfc <memmove+0x28>
     ce2:	1602                	slli	a2,a2,0x20
     ce4:	9201                	srli	a2,a2,0x20
     ce6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     cea:	872a                	mv	a4,a0
      *dst++ = *src++;
     cec:	0585                	addi	a1,a1,1
     cee:	0705                	addi	a4,a4,1
     cf0:	fff5c683          	lbu	a3,-1(a1)
     cf4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     cf8:	fef71ae3          	bne	a4,a5,cec <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     cfc:	6422                	ld	s0,8(sp)
     cfe:	0141                	addi	sp,sp,16
     d00:	8082                	ret
    dst += n;
     d02:	00c50733          	add	a4,a0,a2
    src += n;
     d06:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     d08:	fec05ae3          	blez	a2,cfc <memmove+0x28>
     d0c:	fff6079b          	addiw	a5,a2,-1
     d10:	1782                	slli	a5,a5,0x20
     d12:	9381                	srli	a5,a5,0x20
     d14:	fff7c793          	not	a5,a5
     d18:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     d1a:	15fd                	addi	a1,a1,-1
     d1c:	177d                	addi	a4,a4,-1
     d1e:	0005c683          	lbu	a3,0(a1)
     d22:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     d26:	fee79ae3          	bne	a5,a4,d1a <memmove+0x46>
     d2a:	bfc9                	j	cfc <memmove+0x28>

0000000000000d2c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     d2c:	1141                	addi	sp,sp,-16
     d2e:	e422                	sd	s0,8(sp)
     d30:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     d32:	ca05                	beqz	a2,d62 <memcmp+0x36>
     d34:	fff6069b          	addiw	a3,a2,-1
     d38:	1682                	slli	a3,a3,0x20
     d3a:	9281                	srli	a3,a3,0x20
     d3c:	0685                	addi	a3,a3,1
     d3e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     d40:	00054783          	lbu	a5,0(a0)
     d44:	0005c703          	lbu	a4,0(a1)
     d48:	00e79863          	bne	a5,a4,d58 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     d4c:	0505                	addi	a0,a0,1
    p2++;
     d4e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     d50:	fed518e3          	bne	a0,a3,d40 <memcmp+0x14>
  }
  return 0;
     d54:	4501                	li	a0,0
     d56:	a019                	j	d5c <memcmp+0x30>
      return *p1 - *p2;
     d58:	40e7853b          	subw	a0,a5,a4
}
     d5c:	6422                	ld	s0,8(sp)
     d5e:	0141                	addi	sp,sp,16
     d60:	8082                	ret
  return 0;
     d62:	4501                	li	a0,0
     d64:	bfe5                	j	d5c <memcmp+0x30>

0000000000000d66 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     d66:	1141                	addi	sp,sp,-16
     d68:	e406                	sd	ra,8(sp)
     d6a:	e022                	sd	s0,0(sp)
     d6c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     d6e:	f67ff0ef          	jal	cd4 <memmove>
}
     d72:	60a2                	ld	ra,8(sp)
     d74:	6402                	ld	s0,0(sp)
     d76:	0141                	addi	sp,sp,16
     d78:	8082                	ret

0000000000000d7a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     d7a:	4885                	li	a7,1
 ecall
     d7c:	00000073          	ecall
 ret
     d80:	8082                	ret

0000000000000d82 <exit>:
.global exit
exit:
 li a7, SYS_exit
     d82:	4889                	li	a7,2
 ecall
     d84:	00000073          	ecall
 ret
     d88:	8082                	ret

0000000000000d8a <wait>:
.global wait
wait:
 li a7, SYS_wait
     d8a:	488d                	li	a7,3
 ecall
     d8c:	00000073          	ecall
 ret
     d90:	8082                	ret

0000000000000d92 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     d92:	4891                	li	a7,4
 ecall
     d94:	00000073          	ecall
 ret
     d98:	8082                	ret

0000000000000d9a <read>:
.global read
read:
 li a7, SYS_read
     d9a:	4895                	li	a7,5
 ecall
     d9c:	00000073          	ecall
 ret
     da0:	8082                	ret

0000000000000da2 <write>:
.global write
write:
 li a7, SYS_write
     da2:	48c1                	li	a7,16
 ecall
     da4:	00000073          	ecall
 ret
     da8:	8082                	ret

0000000000000daa <close>:
.global close
close:
 li a7, SYS_close
     daa:	48d5                	li	a7,21
 ecall
     dac:	00000073          	ecall
 ret
     db0:	8082                	ret

0000000000000db2 <kill>:
.global kill
kill:
 li a7, SYS_kill
     db2:	4899                	li	a7,6
 ecall
     db4:	00000073          	ecall
 ret
     db8:	8082                	ret

0000000000000dba <exec>:
.global exec
exec:
 li a7, SYS_exec
     dba:	489d                	li	a7,7
 ecall
     dbc:	00000073          	ecall
 ret
     dc0:	8082                	ret

0000000000000dc2 <open>:
.global open
open:
 li a7, SYS_open
     dc2:	48bd                	li	a7,15
 ecall
     dc4:	00000073          	ecall
 ret
     dc8:	8082                	ret

0000000000000dca <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     dca:	48c5                	li	a7,17
 ecall
     dcc:	00000073          	ecall
 ret
     dd0:	8082                	ret

0000000000000dd2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     dd2:	48c9                	li	a7,18
 ecall
     dd4:	00000073          	ecall
 ret
     dd8:	8082                	ret

0000000000000dda <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     dda:	48a1                	li	a7,8
 ecall
     ddc:	00000073          	ecall
 ret
     de0:	8082                	ret

0000000000000de2 <link>:
.global link
link:
 li a7, SYS_link
     de2:	48cd                	li	a7,19
 ecall
     de4:	00000073          	ecall
 ret
     de8:	8082                	ret

0000000000000dea <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     dea:	48d1                	li	a7,20
 ecall
     dec:	00000073          	ecall
 ret
     df0:	8082                	ret

0000000000000df2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     df2:	48a5                	li	a7,9
 ecall
     df4:	00000073          	ecall
 ret
     df8:	8082                	ret

0000000000000dfa <dup>:
.global dup
dup:
 li a7, SYS_dup
     dfa:	48a9                	li	a7,10
 ecall
     dfc:	00000073          	ecall
 ret
     e00:	8082                	ret

0000000000000e02 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     e02:	48ad                	li	a7,11
 ecall
     e04:	00000073          	ecall
 ret
     e08:	8082                	ret

0000000000000e0a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     e0a:	48b1                	li	a7,12
 ecall
     e0c:	00000073          	ecall
 ret
     e10:	8082                	ret

0000000000000e12 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     e12:	48b5                	li	a7,13
 ecall
     e14:	00000073          	ecall
 ret
     e18:	8082                	ret

0000000000000e1a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     e1a:	48b9                	li	a7,14
 ecall
     e1c:	00000073          	ecall
 ret
     e20:	8082                	ret

0000000000000e22 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     e22:	1101                	addi	sp,sp,-32
     e24:	ec06                	sd	ra,24(sp)
     e26:	e822                	sd	s0,16(sp)
     e28:	1000                	addi	s0,sp,32
     e2a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     e2e:	4605                	li	a2,1
     e30:	fef40593          	addi	a1,s0,-17
     e34:	f6fff0ef          	jal	da2 <write>
}
     e38:	60e2                	ld	ra,24(sp)
     e3a:	6442                	ld	s0,16(sp)
     e3c:	6105                	addi	sp,sp,32
     e3e:	8082                	ret

0000000000000e40 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     e40:	7139                	addi	sp,sp,-64
     e42:	fc06                	sd	ra,56(sp)
     e44:	f822                	sd	s0,48(sp)
     e46:	f426                	sd	s1,40(sp)
     e48:	0080                	addi	s0,sp,64
     e4a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     e4c:	c299                	beqz	a3,e52 <printint+0x12>
     e4e:	0805c963          	bltz	a1,ee0 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     e52:	2581                	sext.w	a1,a1
  neg = 0;
     e54:	4881                	li	a7,0
     e56:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     e5a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     e5c:	2601                	sext.w	a2,a2
     e5e:	00000517          	auipc	a0,0x0
     e62:	68a50513          	addi	a0,a0,1674 # 14e8 <digits>
     e66:	883a                	mv	a6,a4
     e68:	2705                	addiw	a4,a4,1
     e6a:	02c5f7bb          	remuw	a5,a1,a2
     e6e:	1782                	slli	a5,a5,0x20
     e70:	9381                	srli	a5,a5,0x20
     e72:	97aa                	add	a5,a5,a0
     e74:	0007c783          	lbu	a5,0(a5)
     e78:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     e7c:	0005879b          	sext.w	a5,a1
     e80:	02c5d5bb          	divuw	a1,a1,a2
     e84:	0685                	addi	a3,a3,1
     e86:	fec7f0e3          	bgeu	a5,a2,e66 <printint+0x26>
  if(neg)
     e8a:	00088c63          	beqz	a7,ea2 <printint+0x62>
    buf[i++] = '-';
     e8e:	fd070793          	addi	a5,a4,-48
     e92:	00878733          	add	a4,a5,s0
     e96:	02d00793          	li	a5,45
     e9a:	fef70823          	sb	a5,-16(a4)
     e9e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     ea2:	02e05a63          	blez	a4,ed6 <printint+0x96>
     ea6:	f04a                	sd	s2,32(sp)
     ea8:	ec4e                	sd	s3,24(sp)
     eaa:	fc040793          	addi	a5,s0,-64
     eae:	00e78933          	add	s2,a5,a4
     eb2:	fff78993          	addi	s3,a5,-1
     eb6:	99ba                	add	s3,s3,a4
     eb8:	377d                	addiw	a4,a4,-1
     eba:	1702                	slli	a4,a4,0x20
     ebc:	9301                	srli	a4,a4,0x20
     ebe:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     ec2:	fff94583          	lbu	a1,-1(s2)
     ec6:	8526                	mv	a0,s1
     ec8:	f5bff0ef          	jal	e22 <putc>
  while(--i >= 0)
     ecc:	197d                	addi	s2,s2,-1
     ece:	ff391ae3          	bne	s2,s3,ec2 <printint+0x82>
     ed2:	7902                	ld	s2,32(sp)
     ed4:	69e2                	ld	s3,24(sp)
}
     ed6:	70e2                	ld	ra,56(sp)
     ed8:	7442                	ld	s0,48(sp)
     eda:	74a2                	ld	s1,40(sp)
     edc:	6121                	addi	sp,sp,64
     ede:	8082                	ret
    x = -xx;
     ee0:	40b005bb          	negw	a1,a1
    neg = 1;
     ee4:	4885                	li	a7,1
    x = -xx;
     ee6:	bf85                	j	e56 <printint+0x16>

0000000000000ee8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     ee8:	711d                	addi	sp,sp,-96
     eea:	ec86                	sd	ra,88(sp)
     eec:	e8a2                	sd	s0,80(sp)
     eee:	e0ca                	sd	s2,64(sp)
     ef0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     ef2:	0005c903          	lbu	s2,0(a1)
     ef6:	26090863          	beqz	s2,1166 <vprintf+0x27e>
     efa:	e4a6                	sd	s1,72(sp)
     efc:	fc4e                	sd	s3,56(sp)
     efe:	f852                	sd	s4,48(sp)
     f00:	f456                	sd	s5,40(sp)
     f02:	f05a                	sd	s6,32(sp)
     f04:	ec5e                	sd	s7,24(sp)
     f06:	e862                	sd	s8,16(sp)
     f08:	e466                	sd	s9,8(sp)
     f0a:	8b2a                	mv	s6,a0
     f0c:	8a2e                	mv	s4,a1
     f0e:	8bb2                	mv	s7,a2
  state = 0;
     f10:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
     f12:	4481                	li	s1,0
     f14:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
     f16:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
     f1a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
     f1e:	06c00c93          	li	s9,108
     f22:	a005                	j	f42 <vprintf+0x5a>
        putc(fd, c0);
     f24:	85ca                	mv	a1,s2
     f26:	855a                	mv	a0,s6
     f28:	efbff0ef          	jal	e22 <putc>
     f2c:	a019                	j	f32 <vprintf+0x4a>
    } else if(state == '%'){
     f2e:	03598263          	beq	s3,s5,f52 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
     f32:	2485                	addiw	s1,s1,1
     f34:	8726                	mv	a4,s1
     f36:	009a07b3          	add	a5,s4,s1
     f3a:	0007c903          	lbu	s2,0(a5)
     f3e:	20090c63          	beqz	s2,1156 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
     f42:	0009079b          	sext.w	a5,s2
    if(state == 0){
     f46:	fe0994e3          	bnez	s3,f2e <vprintf+0x46>
      if(c0 == '%'){
     f4a:	fd579de3          	bne	a5,s5,f24 <vprintf+0x3c>
        state = '%';
     f4e:	89be                	mv	s3,a5
     f50:	b7cd                	j	f32 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
     f52:	00ea06b3          	add	a3,s4,a4
     f56:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
     f5a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
     f5c:	c681                	beqz	a3,f64 <vprintf+0x7c>
     f5e:	9752                	add	a4,a4,s4
     f60:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
     f64:	03878f63          	beq	a5,s8,fa2 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
     f68:	05978963          	beq	a5,s9,fba <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
     f6c:	07500713          	li	a4,117
     f70:	0ee78363          	beq	a5,a4,1056 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
     f74:	07800713          	li	a4,120
     f78:	12e78563          	beq	a5,a4,10a2 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
     f7c:	07000713          	li	a4,112
     f80:	14e78a63          	beq	a5,a4,10d4 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
     f84:	07300713          	li	a4,115
     f88:	18e78a63          	beq	a5,a4,111c <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
     f8c:	02500713          	li	a4,37
     f90:	04e79563          	bne	a5,a4,fda <vprintf+0xf2>
        putc(fd, '%');
     f94:	02500593          	li	a1,37
     f98:	855a                	mv	a0,s6
     f9a:	e89ff0ef          	jal	e22 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
     f9e:	4981                	li	s3,0
     fa0:	bf49                	j	f32 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
     fa2:	008b8913          	addi	s2,s7,8
     fa6:	4685                	li	a3,1
     fa8:	4629                	li	a2,10
     faa:	000ba583          	lw	a1,0(s7)
     fae:	855a                	mv	a0,s6
     fb0:	e91ff0ef          	jal	e40 <printint>
     fb4:	8bca                	mv	s7,s2
      state = 0;
     fb6:	4981                	li	s3,0
     fb8:	bfad                	j	f32 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
     fba:	06400793          	li	a5,100
     fbe:	02f68963          	beq	a3,a5,ff0 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     fc2:	06c00793          	li	a5,108
     fc6:	04f68263          	beq	a3,a5,100a <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
     fca:	07500793          	li	a5,117
     fce:	0af68063          	beq	a3,a5,106e <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
     fd2:	07800793          	li	a5,120
     fd6:	0ef68263          	beq	a3,a5,10ba <vprintf+0x1d2>
        putc(fd, '%');
     fda:	02500593          	li	a1,37
     fde:	855a                	mv	a0,s6
     fe0:	e43ff0ef          	jal	e22 <putc>
        putc(fd, c0);
     fe4:	85ca                	mv	a1,s2
     fe6:	855a                	mv	a0,s6
     fe8:	e3bff0ef          	jal	e22 <putc>
      state = 0;
     fec:	4981                	li	s3,0
     fee:	b791                	j	f32 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     ff0:	008b8913          	addi	s2,s7,8
     ff4:	4685                	li	a3,1
     ff6:	4629                	li	a2,10
     ff8:	000ba583          	lw	a1,0(s7)
     ffc:	855a                	mv	a0,s6
     ffe:	e43ff0ef          	jal	e40 <printint>
        i += 1;
    1002:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
    1004:	8bca                	mv	s7,s2
      state = 0;
    1006:	4981                	li	s3,0
        i += 1;
    1008:	b72d                	j	f32 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    100a:	06400793          	li	a5,100
    100e:	02f60763          	beq	a2,a5,103c <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    1012:	07500793          	li	a5,117
    1016:	06f60963          	beq	a2,a5,1088 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    101a:	07800793          	li	a5,120
    101e:	faf61ee3          	bne	a2,a5,fda <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
    1022:	008b8913          	addi	s2,s7,8
    1026:	4681                	li	a3,0
    1028:	4641                	li	a2,16
    102a:	000ba583          	lw	a1,0(s7)
    102e:	855a                	mv	a0,s6
    1030:	e11ff0ef          	jal	e40 <printint>
        i += 2;
    1034:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
    1036:	8bca                	mv	s7,s2
      state = 0;
    1038:	4981                	li	s3,0
        i += 2;
    103a:	bde5                	j	f32 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    103c:	008b8913          	addi	s2,s7,8
    1040:	4685                	li	a3,1
    1042:	4629                	li	a2,10
    1044:	000ba583          	lw	a1,0(s7)
    1048:	855a                	mv	a0,s6
    104a:	df7ff0ef          	jal	e40 <printint>
        i += 2;
    104e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
    1050:	8bca                	mv	s7,s2
      state = 0;
    1052:	4981                	li	s3,0
        i += 2;
    1054:	bdf9                	j	f32 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
    1056:	008b8913          	addi	s2,s7,8
    105a:	4681                	li	a3,0
    105c:	4629                	li	a2,10
    105e:	000ba583          	lw	a1,0(s7)
    1062:	855a                	mv	a0,s6
    1064:	dddff0ef          	jal	e40 <printint>
    1068:	8bca                	mv	s7,s2
      state = 0;
    106a:	4981                	li	s3,0
    106c:	b5d9                	j	f32 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    106e:	008b8913          	addi	s2,s7,8
    1072:	4681                	li	a3,0
    1074:	4629                	li	a2,10
    1076:	000ba583          	lw	a1,0(s7)
    107a:	855a                	mv	a0,s6
    107c:	dc5ff0ef          	jal	e40 <printint>
        i += 1;
    1080:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
    1082:	8bca                	mv	s7,s2
      state = 0;
    1084:	4981                	li	s3,0
        i += 1;
    1086:	b575                	j	f32 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1088:	008b8913          	addi	s2,s7,8
    108c:	4681                	li	a3,0
    108e:	4629                	li	a2,10
    1090:	000ba583          	lw	a1,0(s7)
    1094:	855a                	mv	a0,s6
    1096:	dabff0ef          	jal	e40 <printint>
        i += 2;
    109a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
    109c:	8bca                	mv	s7,s2
      state = 0;
    109e:	4981                	li	s3,0
        i += 2;
    10a0:	bd49                	j	f32 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
    10a2:	008b8913          	addi	s2,s7,8
    10a6:	4681                	li	a3,0
    10a8:	4641                	li	a2,16
    10aa:	000ba583          	lw	a1,0(s7)
    10ae:	855a                	mv	a0,s6
    10b0:	d91ff0ef          	jal	e40 <printint>
    10b4:	8bca                	mv	s7,s2
      state = 0;
    10b6:	4981                	li	s3,0
    10b8:	bdad                	j	f32 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
    10ba:	008b8913          	addi	s2,s7,8
    10be:	4681                	li	a3,0
    10c0:	4641                	li	a2,16
    10c2:	000ba583          	lw	a1,0(s7)
    10c6:	855a                	mv	a0,s6
    10c8:	d79ff0ef          	jal	e40 <printint>
        i += 1;
    10cc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
    10ce:	8bca                	mv	s7,s2
      state = 0;
    10d0:	4981                	li	s3,0
        i += 1;
    10d2:	b585                	j	f32 <vprintf+0x4a>
    10d4:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
    10d6:	008b8d13          	addi	s10,s7,8
    10da:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    10de:	03000593          	li	a1,48
    10e2:	855a                	mv	a0,s6
    10e4:	d3fff0ef          	jal	e22 <putc>
  putc(fd, 'x');
    10e8:	07800593          	li	a1,120
    10ec:	855a                	mv	a0,s6
    10ee:	d35ff0ef          	jal	e22 <putc>
    10f2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    10f4:	00000b97          	auipc	s7,0x0
    10f8:	3f4b8b93          	addi	s7,s7,1012 # 14e8 <digits>
    10fc:	03c9d793          	srli	a5,s3,0x3c
    1100:	97de                	add	a5,a5,s7
    1102:	0007c583          	lbu	a1,0(a5)
    1106:	855a                	mv	a0,s6
    1108:	d1bff0ef          	jal	e22 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    110c:	0992                	slli	s3,s3,0x4
    110e:	397d                	addiw	s2,s2,-1
    1110:	fe0916e3          	bnez	s2,10fc <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
    1114:	8bea                	mv	s7,s10
      state = 0;
    1116:	4981                	li	s3,0
    1118:	6d02                	ld	s10,0(sp)
    111a:	bd21                	j	f32 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
    111c:	008b8993          	addi	s3,s7,8
    1120:	000bb903          	ld	s2,0(s7)
    1124:	00090f63          	beqz	s2,1142 <vprintf+0x25a>
        for(; *s; s++)
    1128:	00094583          	lbu	a1,0(s2)
    112c:	c195                	beqz	a1,1150 <vprintf+0x268>
          putc(fd, *s);
    112e:	855a                	mv	a0,s6
    1130:	cf3ff0ef          	jal	e22 <putc>
        for(; *s; s++)
    1134:	0905                	addi	s2,s2,1
    1136:	00094583          	lbu	a1,0(s2)
    113a:	f9f5                	bnez	a1,112e <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
    113c:	8bce                	mv	s7,s3
      state = 0;
    113e:	4981                	li	s3,0
    1140:	bbcd                	j	f32 <vprintf+0x4a>
          s = "(null)";
    1142:	00000917          	auipc	s2,0x0
    1146:	36e90913          	addi	s2,s2,878 # 14b0 <malloc+0x262>
        for(; *s; s++)
    114a:	02800593          	li	a1,40
    114e:	b7c5                	j	112e <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
    1150:	8bce                	mv	s7,s3
      state = 0;
    1152:	4981                	li	s3,0
    1154:	bbf9                	j	f32 <vprintf+0x4a>
    1156:	64a6                	ld	s1,72(sp)
    1158:	79e2                	ld	s3,56(sp)
    115a:	7a42                	ld	s4,48(sp)
    115c:	7aa2                	ld	s5,40(sp)
    115e:	7b02                	ld	s6,32(sp)
    1160:	6be2                	ld	s7,24(sp)
    1162:	6c42                	ld	s8,16(sp)
    1164:	6ca2                	ld	s9,8(sp)
    }
  }
}
    1166:	60e6                	ld	ra,88(sp)
    1168:	6446                	ld	s0,80(sp)
    116a:	6906                	ld	s2,64(sp)
    116c:	6125                	addi	sp,sp,96
    116e:	8082                	ret

0000000000001170 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1170:	715d                	addi	sp,sp,-80
    1172:	ec06                	sd	ra,24(sp)
    1174:	e822                	sd	s0,16(sp)
    1176:	1000                	addi	s0,sp,32
    1178:	e010                	sd	a2,0(s0)
    117a:	e414                	sd	a3,8(s0)
    117c:	e818                	sd	a4,16(s0)
    117e:	ec1c                	sd	a5,24(s0)
    1180:	03043023          	sd	a6,32(s0)
    1184:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1188:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    118c:	8622                	mv	a2,s0
    118e:	d5bff0ef          	jal	ee8 <vprintf>
}
    1192:	60e2                	ld	ra,24(sp)
    1194:	6442                	ld	s0,16(sp)
    1196:	6161                	addi	sp,sp,80
    1198:	8082                	ret

000000000000119a <printf>:

void
printf(const char *fmt, ...)
{
    119a:	711d                	addi	sp,sp,-96
    119c:	ec06                	sd	ra,24(sp)
    119e:	e822                	sd	s0,16(sp)
    11a0:	1000                	addi	s0,sp,32
    11a2:	e40c                	sd	a1,8(s0)
    11a4:	e810                	sd	a2,16(s0)
    11a6:	ec14                	sd	a3,24(s0)
    11a8:	f018                	sd	a4,32(s0)
    11aa:	f41c                	sd	a5,40(s0)
    11ac:	03043823          	sd	a6,48(s0)
    11b0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    11b4:	00840613          	addi	a2,s0,8
    11b8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    11bc:	85aa                	mv	a1,a0
    11be:	4505                	li	a0,1
    11c0:	d29ff0ef          	jal	ee8 <vprintf>
}
    11c4:	60e2                	ld	ra,24(sp)
    11c6:	6442                	ld	s0,16(sp)
    11c8:	6125                	addi	sp,sp,96
    11ca:	8082                	ret

00000000000011cc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    11cc:	1141                	addi	sp,sp,-16
    11ce:	e422                	sd	s0,8(sp)
    11d0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    11d2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    11d6:	00001797          	auipc	a5,0x1
    11da:	e3a7b783          	ld	a5,-454(a5) # 2010 <freep>
    11de:	a02d                	j	1208 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    11e0:	4618                	lw	a4,8(a2)
    11e2:	9f2d                	addw	a4,a4,a1
    11e4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    11e8:	6398                	ld	a4,0(a5)
    11ea:	6310                	ld	a2,0(a4)
    11ec:	a83d                	j	122a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    11ee:	ff852703          	lw	a4,-8(a0)
    11f2:	9f31                	addw	a4,a4,a2
    11f4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    11f6:	ff053683          	ld	a3,-16(a0)
    11fa:	a091                	j	123e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    11fc:	6398                	ld	a4,0(a5)
    11fe:	00e7e463          	bltu	a5,a4,1206 <free+0x3a>
    1202:	00e6ea63          	bltu	a3,a4,1216 <free+0x4a>
{
    1206:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1208:	fed7fae3          	bgeu	a5,a3,11fc <free+0x30>
    120c:	6398                	ld	a4,0(a5)
    120e:	00e6e463          	bltu	a3,a4,1216 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1212:	fee7eae3          	bltu	a5,a4,1206 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    1216:	ff852583          	lw	a1,-8(a0)
    121a:	6390                	ld	a2,0(a5)
    121c:	02059813          	slli	a6,a1,0x20
    1220:	01c85713          	srli	a4,a6,0x1c
    1224:	9736                	add	a4,a4,a3
    1226:	fae60de3          	beq	a2,a4,11e0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    122a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    122e:	4790                	lw	a2,8(a5)
    1230:	02061593          	slli	a1,a2,0x20
    1234:	01c5d713          	srli	a4,a1,0x1c
    1238:	973e                	add	a4,a4,a5
    123a:	fae68ae3          	beq	a3,a4,11ee <free+0x22>
    p->s.ptr = bp->s.ptr;
    123e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    1240:	00001717          	auipc	a4,0x1
    1244:	dcf73823          	sd	a5,-560(a4) # 2010 <freep>
}
    1248:	6422                	ld	s0,8(sp)
    124a:	0141                	addi	sp,sp,16
    124c:	8082                	ret

000000000000124e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    124e:	7139                	addi	sp,sp,-64
    1250:	fc06                	sd	ra,56(sp)
    1252:	f822                	sd	s0,48(sp)
    1254:	f426                	sd	s1,40(sp)
    1256:	ec4e                	sd	s3,24(sp)
    1258:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    125a:	02051493          	slli	s1,a0,0x20
    125e:	9081                	srli	s1,s1,0x20
    1260:	04bd                	addi	s1,s1,15
    1262:	8091                	srli	s1,s1,0x4
    1264:	0014899b          	addiw	s3,s1,1
    1268:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    126a:	00001517          	auipc	a0,0x1
    126e:	da653503          	ld	a0,-602(a0) # 2010 <freep>
    1272:	c915                	beqz	a0,12a6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1274:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1276:	4798                	lw	a4,8(a5)
    1278:	08977a63          	bgeu	a4,s1,130c <malloc+0xbe>
    127c:	f04a                	sd	s2,32(sp)
    127e:	e852                	sd	s4,16(sp)
    1280:	e456                	sd	s5,8(sp)
    1282:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    1284:	8a4e                	mv	s4,s3
    1286:	0009871b          	sext.w	a4,s3
    128a:	6685                	lui	a3,0x1
    128c:	00d77363          	bgeu	a4,a3,1292 <malloc+0x44>
    1290:	6a05                	lui	s4,0x1
    1292:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1296:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    129a:	00001917          	auipc	s2,0x1
    129e:	d7690913          	addi	s2,s2,-650 # 2010 <freep>
  if(p == (char*)-1)
    12a2:	5afd                	li	s5,-1
    12a4:	a081                	j	12e4 <malloc+0x96>
    12a6:	f04a                	sd	s2,32(sp)
    12a8:	e852                	sd	s4,16(sp)
    12aa:	e456                	sd	s5,8(sp)
    12ac:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    12ae:	00001797          	auipc	a5,0x1
    12b2:	fca78793          	addi	a5,a5,-54 # 2278 <base>
    12b6:	00001717          	auipc	a4,0x1
    12ba:	d4f73d23          	sd	a5,-678(a4) # 2010 <freep>
    12be:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    12c0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    12c4:	b7c1                	j	1284 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    12c6:	6398                	ld	a4,0(a5)
    12c8:	e118                	sd	a4,0(a0)
    12ca:	a8a9                	j	1324 <malloc+0xd6>
  hp->s.size = nu;
    12cc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    12d0:	0541                	addi	a0,a0,16
    12d2:	efbff0ef          	jal	11cc <free>
  return freep;
    12d6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    12da:	c12d                	beqz	a0,133c <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    12dc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    12de:	4798                	lw	a4,8(a5)
    12e0:	02977263          	bgeu	a4,s1,1304 <malloc+0xb6>
    if(p == freep)
    12e4:	00093703          	ld	a4,0(s2)
    12e8:	853e                	mv	a0,a5
    12ea:	fef719e3          	bne	a4,a5,12dc <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    12ee:	8552                	mv	a0,s4
    12f0:	b1bff0ef          	jal	e0a <sbrk>
  if(p == (char*)-1)
    12f4:	fd551ce3          	bne	a0,s5,12cc <malloc+0x7e>
        return 0;
    12f8:	4501                	li	a0,0
    12fa:	7902                	ld	s2,32(sp)
    12fc:	6a42                	ld	s4,16(sp)
    12fe:	6aa2                	ld	s5,8(sp)
    1300:	6b02                	ld	s6,0(sp)
    1302:	a03d                	j	1330 <malloc+0xe2>
    1304:	7902                	ld	s2,32(sp)
    1306:	6a42                	ld	s4,16(sp)
    1308:	6aa2                	ld	s5,8(sp)
    130a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    130c:	fae48de3          	beq	s1,a4,12c6 <malloc+0x78>
        p->s.size -= nunits;
    1310:	4137073b          	subw	a4,a4,s3
    1314:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1316:	02071693          	slli	a3,a4,0x20
    131a:	01c6d713          	srli	a4,a3,0x1c
    131e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1320:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1324:	00001717          	auipc	a4,0x1
    1328:	cea73623          	sd	a0,-788(a4) # 2010 <freep>
      return (void*)(p + 1);
    132c:	01078513          	addi	a0,a5,16
  }
}
    1330:	70e2                	ld	ra,56(sp)
    1332:	7442                	ld	s0,48(sp)
    1334:	74a2                	ld	s1,40(sp)
    1336:	69e2                	ld	s3,24(sp)
    1338:	6121                	addi	sp,sp,64
    133a:	8082                	ret
    133c:	7902                	ld	s2,32(sp)
    133e:	6a42                	ld	s4,16(sp)
    1340:	6aa2                	ld	s5,8(sp)
    1342:	6b02                	ld	s6,0(sp)
    1344:	b7f5                	j	1330 <malloc+0xe2>
