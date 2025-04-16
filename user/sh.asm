
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
      62:	2e258593          	addi	a1,a1,738 # 1340 <malloc+0xfe>
      66:	4509                	li	a0,2
      68:	52f000ef          	jal	d96 <write>
  memset(buf, 0, nbuf);
      6c:	864a                	mv	a2,s2
      6e:	4581                	li	a1,0
      70:	8526                	mv	a0,s1
      72:	31f000ef          	jal	b90 <memset>
  gets(buf, nbuf);
      76:	85ca                	mv	a1,s2
      78:	8526                	mv	a0,s1
      7a:	35d000ef          	jal	bd6 <gets>
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
      a4:	2b058593          	addi	a1,a1,688 # 1350 <malloc+0x10e>
      a8:	4509                	li	a0,2
      aa:	0ba010ef          	jal	1164 <fprintf>
  exit(1);
      ae:	4505                	li	a0,1
      b0:	4c7000ef          	jal	d76 <exit>

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
      bc:	4b3000ef          	jal	d6e <fork>
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
      d2:	29250513          	addi	a0,a0,658 # 1360 <malloc+0x11e>
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
      fe:	3ae70713          	addi	a4,a4,942 # 14a8 <malloc+0x266>
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
     11a:	45d000ef          	jal	d76 <exit>
     11e:	f852                	sd	s4,48(sp)
     120:	f456                	sd	s5,40(sp)
     122:	f05a                	sd	s6,32(sp)
     124:	ec5e                	sd	s7,24(sp)
    panic("runcmd");
     126:	00001517          	auipc	a0,0x1
     12a:	24250513          	addi	a0,a0,578 # 1368 <malloc+0x126>
     12e:	f69ff0ef          	jal	96 <panic>
    if(ecmd->argv[0] == 0)
     132:	00853903          	ld	s2,8(a0)
     136:	06090163          	beqz	s2,198 <runcmd+0xbe>
    if(strcmp(ecmd->argv[0], "echo") == 0) {
     13a:	00001597          	auipc	a1,0x1
     13e:	23658593          	addi	a1,a1,566 # 1370 <malloc+0x12e>
     142:	854a                	mv	a0,s2
     144:	1f7000ef          	jal	b3a <strcmp>
     148:	89aa                	mv	s3,a0
     14a:	ed5d                	bnez	a0,208 <runcmd+0x12e>
      for(int i = 1; ecmd->argv[i]; i++) {
     14c:	6888                	ld	a0,16(s1)
     14e:	cd19                	beqz	a0,16c <runcmd+0x92>
     150:	01848913          	addi	s2,s1,24
        total_len += strlen(ecmd->argv[i]);
     154:	213000ef          	jal	b66 <strlen>
     158:	00a989bb          	addw	s3,s3,a0
      for(int i = 1; ecmd->argv[i]; i++) {
     15c:	0921                	addi	s2,s2,8
     15e:	ff893503          	ld	a0,-8(s2)
     162:	f96d                	bnez	a0,154 <runcmd+0x7a>
      if(total_len > 512) {
     164:	20000793          	li	a5,512
     168:	0337cf63          	blt	a5,s3,1a6 <runcmd+0xcc>
     16c:	f852                	sd	s4,48(sp)
     16e:	f456                	sd	s5,40(sp)
     170:	f05a                	sd	s6,32(sp)
     172:	ec5e                	sd	s7,24(sp)
     174:	04c1                	addi	s1,s1,16
        if(strstr(ecmd->argv[i], "os"))
     176:	00001a17          	auipc	s4,0x1
     17a:	21aa0a13          	addi	s4,s4,538 # 1390 <malloc+0x14e>
          printf("%s", ecmd->argv[i]);
     17e:	00001b97          	auipc	s7,0x1
     182:	22ab8b93          	addi	s7,s7,554 # 13a8 <malloc+0x166>
          printf("\033[1;34m%s\033[0m", ecmd->argv[i]);
     186:	00001a97          	auipc	s5,0x1
     18a:	212a8a93          	addi	s5,s5,530 # 1398 <malloc+0x156>
          printf(" ");
     18e:	00001b17          	auipc	s6,0x1
     192:	222b0b13          	addi	s6,s6,546 # 13b0 <malloc+0x16e>
     196:	a81d                	j	1cc <runcmd+0xf2>
     198:	f852                	sd	s4,48(sp)
     19a:	f456                	sd	s5,40(sp)
     19c:	f05a                	sd	s6,32(sp)
     19e:	ec5e                	sd	s7,24(sp)
      exit(1);
     1a0:	4505                	li	a0,1
     1a2:	3d5000ef          	jal	d76 <exit>
     1a6:	f852                	sd	s4,48(sp)
     1a8:	f456                	sd	s5,40(sp)
     1aa:	f05a                	sd	s6,32(sp)
     1ac:	ec5e                	sd	s7,24(sp)
        printf("Message too long\n");
     1ae:	00001517          	auipc	a0,0x1
     1b2:	1ca50513          	addi	a0,a0,458 # 1378 <malloc+0x136>
     1b6:	7d9000ef          	jal	118e <printf>
        exit(0);
     1ba:	4501                	li	a0,0
     1bc:	3bb000ef          	jal	d76 <exit>
          printf("%s", ecmd->argv[i]);
     1c0:	85ca                	mv	a1,s2
     1c2:	855e                	mv	a0,s7
     1c4:	7cb000ef          	jal	118e <printf>
     1c8:	a005                	j	1e8 <runcmd+0x10e>
     1ca:	04a1                	addi	s1,s1,8
      for(int i = 1; ecmd->argv[i]; i++) {
     1cc:	89a6                	mv	s3,s1
     1ce:	0004b903          	ld	s2,0(s1)
     1d2:	02090263          	beqz	s2,1f6 <runcmd+0x11c>
        if(strstr(ecmd->argv[i], "os"))
     1d6:	85d2                	mv	a1,s4
     1d8:	854a                	mv	a0,s2
     1da:	e27ff0ef          	jal	0 <strstr>
     1de:	d16d                	beqz	a0,1c0 <runcmd+0xe6>
          printf("\033[1;34m%s\033[0m", ecmd->argv[i]);
     1e0:	85ca                	mv	a1,s2
     1e2:	8556                	mv	a0,s5
     1e4:	7ab000ef          	jal	118e <printf>
        if(ecmd->argv[i+1])
     1e8:	0089b783          	ld	a5,8(s3)
     1ec:	dff9                	beqz	a5,1ca <runcmd+0xf0>
          printf(" ");
     1ee:	855a                	mv	a0,s6
     1f0:	79f000ef          	jal	118e <printf>
     1f4:	bfd9                	j	1ca <runcmd+0xf0>
      printf("\n");
     1f6:	00001517          	auipc	a0,0x1
     1fa:	19250513          	addi	a0,a0,402 # 1388 <malloc+0x146>
     1fe:	791000ef          	jal	118e <printf>
      exit(0);
     202:	4501                	li	a0,0
     204:	373000ef          	jal	d76 <exit>
    exec(ecmd->argv[0], ecmd->argv);
     208:	00848593          	addi	a1,s1,8
     20c:	854a                	mv	a0,s2
     20e:	3a1000ef          	jal	dae <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     212:	6490                	ld	a2,8(s1)
     214:	00001597          	auipc	a1,0x1
     218:	1a458593          	addi	a1,a1,420 # 13b8 <malloc+0x176>
     21c:	4509                	li	a0,2
     21e:	747000ef          	jal	1164 <fprintf>
    break;
     222:	a239                	j	330 <runcmd+0x256>
    close(rcmd->fd);
     224:	5148                	lw	a0,36(a0)
     226:	379000ef          	jal	d9e <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     22a:	508c                	lw	a1,32(s1)
     22c:	6888                	ld	a0,16(s1)
     22e:	389000ef          	jal	db6 <open>
     232:	00054963          	bltz	a0,244 <runcmd+0x16a>
     236:	f852                	sd	s4,48(sp)
     238:	f456                	sd	s5,40(sp)
     23a:	f05a                	sd	s6,32(sp)
     23c:	ec5e                	sd	s7,24(sp)
    runcmd(rcmd->cmd);
     23e:	6488                	ld	a0,8(s1)
     240:	e9bff0ef          	jal	da <runcmd>
     244:	f852                	sd	s4,48(sp)
     246:	f456                	sd	s5,40(sp)
     248:	f05a                	sd	s6,32(sp)
     24a:	ec5e                	sd	s7,24(sp)
      fprintf(2, "open %s failed\n", rcmd->file);
     24c:	6890                	ld	a2,16(s1)
     24e:	00001597          	auipc	a1,0x1
     252:	17a58593          	addi	a1,a1,378 # 13c8 <malloc+0x186>
     256:	4509                	li	a0,2
     258:	70d000ef          	jal	1164 <fprintf>
      exit(1);
     25c:	4505                	li	a0,1
     25e:	319000ef          	jal	d76 <exit>
    if(fork1() == 0)
     262:	e53ff0ef          	jal	b4 <fork1>
     266:	e901                	bnez	a0,276 <runcmd+0x19c>
     268:	f852                	sd	s4,48(sp)
     26a:	f456                	sd	s5,40(sp)
     26c:	f05a                	sd	s6,32(sp)
     26e:	ec5e                	sd	s7,24(sp)
      runcmd(lcmd->left);
     270:	6488                	ld	a0,8(s1)
     272:	e69ff0ef          	jal	da <runcmd>
     276:	f852                	sd	s4,48(sp)
     278:	f456                	sd	s5,40(sp)
     27a:	f05a                	sd	s6,32(sp)
     27c:	ec5e                	sd	s7,24(sp)
    wait(0);
     27e:	4501                	li	a0,0
     280:	2ff000ef          	jal	d7e <wait>
    runcmd(lcmd->right);
     284:	6888                	ld	a0,16(s1)
     286:	e55ff0ef          	jal	da <runcmd>
    if(pipe(p) < 0)
     28a:	fa840513          	addi	a0,s0,-88
     28e:	2f9000ef          	jal	d86 <pipe>
     292:	02054b63          	bltz	a0,2c8 <runcmd+0x1ee>
    if(fork1() == 0){
     296:	e1fff0ef          	jal	b4 <fork1>
     29a:	e129                	bnez	a0,2dc <runcmd+0x202>
     29c:	f852                	sd	s4,48(sp)
     29e:	f456                	sd	s5,40(sp)
     2a0:	f05a                	sd	s6,32(sp)
     2a2:	ec5e                	sd	s7,24(sp)
      close(1);
     2a4:	4505                	li	a0,1
     2a6:	2f9000ef          	jal	d9e <close>
      dup(p[1]);
     2aa:	fac42503          	lw	a0,-84(s0)
     2ae:	341000ef          	jal	dee <dup>
      close(p[0]);
     2b2:	fa842503          	lw	a0,-88(s0)
     2b6:	2e9000ef          	jal	d9e <close>
      close(p[1]);
     2ba:	fac42503          	lw	a0,-84(s0)
     2be:	2e1000ef          	jal	d9e <close>
      runcmd(pcmd->left);
     2c2:	6488                	ld	a0,8(s1)
     2c4:	e17ff0ef          	jal	da <runcmd>
     2c8:	f852                	sd	s4,48(sp)
     2ca:	f456                	sd	s5,40(sp)
     2cc:	f05a                	sd	s6,32(sp)
     2ce:	ec5e                	sd	s7,24(sp)
      panic("pipe");
     2d0:	00001517          	auipc	a0,0x1
     2d4:	10850513          	addi	a0,a0,264 # 13d8 <malloc+0x196>
     2d8:	dbfff0ef          	jal	96 <panic>
    if(fork1() == 0){
     2dc:	dd9ff0ef          	jal	b4 <fork1>
     2e0:	e515                	bnez	a0,30c <runcmd+0x232>
     2e2:	f852                	sd	s4,48(sp)
     2e4:	f456                	sd	s5,40(sp)
     2e6:	f05a                	sd	s6,32(sp)
     2e8:	ec5e                	sd	s7,24(sp)
      close(0);
     2ea:	2b5000ef          	jal	d9e <close>
      dup(p[0]);
     2ee:	fa842503          	lw	a0,-88(s0)
     2f2:	2fd000ef          	jal	dee <dup>
      close(p[0]);
     2f6:	fa842503          	lw	a0,-88(s0)
     2fa:	2a5000ef          	jal	d9e <close>
      close(p[1]);
     2fe:	fac42503          	lw	a0,-84(s0)
     302:	29d000ef          	jal	d9e <close>
      runcmd(pcmd->right);
     306:	6888                	ld	a0,16(s1)
     308:	dd3ff0ef          	jal	da <runcmd>
    close(p[0]);
     30c:	fa842503          	lw	a0,-88(s0)
     310:	28f000ef          	jal	d9e <close>
    close(p[1]);
     314:	fac42503          	lw	a0,-84(s0)
     318:	287000ef          	jal	d9e <close>
    wait(0);
     31c:	4501                	li	a0,0
     31e:	261000ef          	jal	d7e <wait>
    wait(0);
     322:	4501                	li	a0,0
     324:	25b000ef          	jal	d7e <wait>
    break;
     328:	a021                	j	330 <runcmd+0x256>
    if(fork1() == 0)
     32a:	d8bff0ef          	jal	b4 <fork1>
     32e:	c901                	beqz	a0,33e <runcmd+0x264>
     330:	f852                	sd	s4,48(sp)
     332:	f456                	sd	s5,40(sp)
     334:	f05a                	sd	s6,32(sp)
     336:	ec5e                	sd	s7,24(sp)
  exit(0);
     338:	4501                	li	a0,0
     33a:	23d000ef          	jal	d76 <exit>
     33e:	f852                	sd	s4,48(sp)
     340:	f456                	sd	s5,40(sp)
     342:	f05a                	sd	s6,32(sp)
     344:	ec5e                	sd	s7,24(sp)
      runcmd(bcmd->cmd);
     346:	6488                	ld	a0,8(s1)
     348:	d93ff0ef          	jal	da <runcmd>

000000000000034c <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     34c:	1101                	addi	sp,sp,-32
     34e:	ec06                	sd	ra,24(sp)
     350:	e822                	sd	s0,16(sp)
     352:	e426                	sd	s1,8(sp)
     354:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     356:	0a800513          	li	a0,168
     35a:	6e9000ef          	jal	1242 <malloc>
     35e:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     360:	0a800613          	li	a2,168
     364:	4581                	li	a1,0
     366:	02b000ef          	jal	b90 <memset>
  cmd->type = EXEC;
     36a:	4785                	li	a5,1
     36c:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     36e:	8526                	mv	a0,s1
     370:	60e2                	ld	ra,24(sp)
     372:	6442                	ld	s0,16(sp)
     374:	64a2                	ld	s1,8(sp)
     376:	6105                	addi	sp,sp,32
     378:	8082                	ret

000000000000037a <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     37a:	7139                	addi	sp,sp,-64
     37c:	fc06                	sd	ra,56(sp)
     37e:	f822                	sd	s0,48(sp)
     380:	f426                	sd	s1,40(sp)
     382:	f04a                	sd	s2,32(sp)
     384:	ec4e                	sd	s3,24(sp)
     386:	e852                	sd	s4,16(sp)
     388:	e456                	sd	s5,8(sp)
     38a:	e05a                	sd	s6,0(sp)
     38c:	0080                	addi	s0,sp,64
     38e:	8b2a                	mv	s6,a0
     390:	8aae                	mv	s5,a1
     392:	8a32                	mv	s4,a2
     394:	89b6                	mv	s3,a3
     396:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     398:	02800513          	li	a0,40
     39c:	6a7000ef          	jal	1242 <malloc>
     3a0:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3a2:	02800613          	li	a2,40
     3a6:	4581                	li	a1,0
     3a8:	7e8000ef          	jal	b90 <memset>
  cmd->type = REDIR;
     3ac:	4789                	li	a5,2
     3ae:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     3b0:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     3b4:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     3b8:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     3bc:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     3c0:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     3c4:	8526                	mv	a0,s1
     3c6:	70e2                	ld	ra,56(sp)
     3c8:	7442                	ld	s0,48(sp)
     3ca:	74a2                	ld	s1,40(sp)
     3cc:	7902                	ld	s2,32(sp)
     3ce:	69e2                	ld	s3,24(sp)
     3d0:	6a42                	ld	s4,16(sp)
     3d2:	6aa2                	ld	s5,8(sp)
     3d4:	6b02                	ld	s6,0(sp)
     3d6:	6121                	addi	sp,sp,64
     3d8:	8082                	ret

00000000000003da <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     3da:	7179                	addi	sp,sp,-48
     3dc:	f406                	sd	ra,40(sp)
     3de:	f022                	sd	s0,32(sp)
     3e0:	ec26                	sd	s1,24(sp)
     3e2:	e84a                	sd	s2,16(sp)
     3e4:	e44e                	sd	s3,8(sp)
     3e6:	1800                	addi	s0,sp,48
     3e8:	89aa                	mv	s3,a0
     3ea:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3ec:	4561                	li	a0,24
     3ee:	655000ef          	jal	1242 <malloc>
     3f2:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3f4:	4661                	li	a2,24
     3f6:	4581                	li	a1,0
     3f8:	798000ef          	jal	b90 <memset>
  cmd->type = PIPE;
     3fc:	478d                	li	a5,3
     3fe:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     400:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     404:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     408:	8526                	mv	a0,s1
     40a:	70a2                	ld	ra,40(sp)
     40c:	7402                	ld	s0,32(sp)
     40e:	64e2                	ld	s1,24(sp)
     410:	6942                	ld	s2,16(sp)
     412:	69a2                	ld	s3,8(sp)
     414:	6145                	addi	sp,sp,48
     416:	8082                	ret

0000000000000418 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     418:	7179                	addi	sp,sp,-48
     41a:	f406                	sd	ra,40(sp)
     41c:	f022                	sd	s0,32(sp)
     41e:	ec26                	sd	s1,24(sp)
     420:	e84a                	sd	s2,16(sp)
     422:	e44e                	sd	s3,8(sp)
     424:	1800                	addi	s0,sp,48
     426:	89aa                	mv	s3,a0
     428:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     42a:	4561                	li	a0,24
     42c:	617000ef          	jal	1242 <malloc>
     430:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     432:	4661                	li	a2,24
     434:	4581                	li	a1,0
     436:	75a000ef          	jal	b90 <memset>
  cmd->type = LIST;
     43a:	4791                	li	a5,4
     43c:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     43e:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     442:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     446:	8526                	mv	a0,s1
     448:	70a2                	ld	ra,40(sp)
     44a:	7402                	ld	s0,32(sp)
     44c:	64e2                	ld	s1,24(sp)
     44e:	6942                	ld	s2,16(sp)
     450:	69a2                	ld	s3,8(sp)
     452:	6145                	addi	sp,sp,48
     454:	8082                	ret

0000000000000456 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     456:	1101                	addi	sp,sp,-32
     458:	ec06                	sd	ra,24(sp)
     45a:	e822                	sd	s0,16(sp)
     45c:	e426                	sd	s1,8(sp)
     45e:	e04a                	sd	s2,0(sp)
     460:	1000                	addi	s0,sp,32
     462:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     464:	4541                	li	a0,16
     466:	5dd000ef          	jal	1242 <malloc>
     46a:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     46c:	4641                	li	a2,16
     46e:	4581                	li	a1,0
     470:	720000ef          	jal	b90 <memset>
  cmd->type = BACK;
     474:	4795                	li	a5,5
     476:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     478:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     47c:	8526                	mv	a0,s1
     47e:	60e2                	ld	ra,24(sp)
     480:	6442                	ld	s0,16(sp)
     482:	64a2                	ld	s1,8(sp)
     484:	6902                	ld	s2,0(sp)
     486:	6105                	addi	sp,sp,32
     488:	8082                	ret

000000000000048a <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     48a:	7139                	addi	sp,sp,-64
     48c:	fc06                	sd	ra,56(sp)
     48e:	f822                	sd	s0,48(sp)
     490:	f426                	sd	s1,40(sp)
     492:	f04a                	sd	s2,32(sp)
     494:	ec4e                	sd	s3,24(sp)
     496:	e852                	sd	s4,16(sp)
     498:	e456                	sd	s5,8(sp)
     49a:	e05a                	sd	s6,0(sp)
     49c:	0080                	addi	s0,sp,64
     49e:	8a2a                	mv	s4,a0
     4a0:	892e                	mv	s2,a1
     4a2:	8ab2                	mv	s5,a2
     4a4:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     4a6:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     4a8:	00002997          	auipc	s3,0x2
     4ac:	b6098993          	addi	s3,s3,-1184 # 2008 <whitespace>
     4b0:	00b4fc63          	bgeu	s1,a1,4c8 <gettoken+0x3e>
     4b4:	0004c583          	lbu	a1,0(s1)
     4b8:	854e                	mv	a0,s3
     4ba:	6f8000ef          	jal	bb2 <strchr>
     4be:	c509                	beqz	a0,4c8 <gettoken+0x3e>
    s++;
     4c0:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     4c2:	fe9919e3          	bne	s2,s1,4b4 <gettoken+0x2a>
     4c6:	84ca                	mv	s1,s2
  if(q)
     4c8:	000a8463          	beqz	s5,4d0 <gettoken+0x46>
    *q = s;
     4cc:	009ab023          	sd	s1,0(s5)
  ret = *s;
     4d0:	0004c783          	lbu	a5,0(s1)
     4d4:	00078a9b          	sext.w	s5,a5
  switch(*s){
     4d8:	03c00713          	li	a4,60
     4dc:	06f76463          	bltu	a4,a5,544 <gettoken+0xba>
     4e0:	03a00713          	li	a4,58
     4e4:	00f76e63          	bltu	a4,a5,500 <gettoken+0x76>
     4e8:	cf89                	beqz	a5,502 <gettoken+0x78>
     4ea:	02600713          	li	a4,38
     4ee:	00e78963          	beq	a5,a4,500 <gettoken+0x76>
     4f2:	fd87879b          	addiw	a5,a5,-40
     4f6:	0ff7f793          	zext.b	a5,a5
     4fa:	4705                	li	a4,1
     4fc:	06f76b63          	bltu	a4,a5,572 <gettoken+0xe8>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     500:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     502:	000b0463          	beqz	s6,50a <gettoken+0x80>
    *eq = s;
     506:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     50a:	00002997          	auipc	s3,0x2
     50e:	afe98993          	addi	s3,s3,-1282 # 2008 <whitespace>
     512:	0124fc63          	bgeu	s1,s2,52a <gettoken+0xa0>
     516:	0004c583          	lbu	a1,0(s1)
     51a:	854e                	mv	a0,s3
     51c:	696000ef          	jal	bb2 <strchr>
     520:	c509                	beqz	a0,52a <gettoken+0xa0>
    s++;
     522:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     524:	fe9919e3          	bne	s2,s1,516 <gettoken+0x8c>
     528:	84ca                	mv	s1,s2
  *ps = s;
     52a:	009a3023          	sd	s1,0(s4)
  return ret;
}
     52e:	8556                	mv	a0,s5
     530:	70e2                	ld	ra,56(sp)
     532:	7442                	ld	s0,48(sp)
     534:	74a2                	ld	s1,40(sp)
     536:	7902                	ld	s2,32(sp)
     538:	69e2                	ld	s3,24(sp)
     53a:	6a42                	ld	s4,16(sp)
     53c:	6aa2                	ld	s5,8(sp)
     53e:	6b02                	ld	s6,0(sp)
     540:	6121                	addi	sp,sp,64
     542:	8082                	ret
  switch(*s){
     544:	03e00713          	li	a4,62
     548:	02e79163          	bne	a5,a4,56a <gettoken+0xe0>
    s++;
     54c:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     550:	0014c703          	lbu	a4,1(s1)
     554:	03e00793          	li	a5,62
      s++;
     558:	0489                	addi	s1,s1,2
      ret = '+';
     55a:	02b00a93          	li	s5,43
    if(*s == '>'){
     55e:	faf702e3          	beq	a4,a5,502 <gettoken+0x78>
    s++;
     562:	84b6                	mv	s1,a3
  ret = *s;
     564:	03e00a93          	li	s5,62
     568:	bf69                	j	502 <gettoken+0x78>
  switch(*s){
     56a:	07c00713          	li	a4,124
     56e:	f8e789e3          	beq	a5,a4,500 <gettoken+0x76>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     572:	00002997          	auipc	s3,0x2
     576:	a9698993          	addi	s3,s3,-1386 # 2008 <whitespace>
     57a:	00002a97          	auipc	s5,0x2
     57e:	a86a8a93          	addi	s5,s5,-1402 # 2000 <symbols>
     582:	0324fd63          	bgeu	s1,s2,5bc <gettoken+0x132>
     586:	0004c583          	lbu	a1,0(s1)
     58a:	854e                	mv	a0,s3
     58c:	626000ef          	jal	bb2 <strchr>
     590:	e11d                	bnez	a0,5b6 <gettoken+0x12c>
     592:	0004c583          	lbu	a1,0(s1)
     596:	8556                	mv	a0,s5
     598:	61a000ef          	jal	bb2 <strchr>
     59c:	e911                	bnez	a0,5b0 <gettoken+0x126>
      s++;
     59e:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     5a0:	fe9913e3          	bne	s2,s1,586 <gettoken+0xfc>
  if(eq)
     5a4:	84ca                	mv	s1,s2
    ret = 'a';
     5a6:	06100a93          	li	s5,97
  if(eq)
     5aa:	f40b1ee3          	bnez	s6,506 <gettoken+0x7c>
     5ae:	bfb5                	j	52a <gettoken+0xa0>
    ret = 'a';
     5b0:	06100a93          	li	s5,97
     5b4:	b7b9                	j	502 <gettoken+0x78>
     5b6:	06100a93          	li	s5,97
     5ba:	b7a1                	j	502 <gettoken+0x78>
     5bc:	06100a93          	li	s5,97
  if(eq)
     5c0:	f40b13e3          	bnez	s6,506 <gettoken+0x7c>
     5c4:	b79d                	j	52a <gettoken+0xa0>

00000000000005c6 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     5c6:	7139                	addi	sp,sp,-64
     5c8:	fc06                	sd	ra,56(sp)
     5ca:	f822                	sd	s0,48(sp)
     5cc:	f426                	sd	s1,40(sp)
     5ce:	f04a                	sd	s2,32(sp)
     5d0:	ec4e                	sd	s3,24(sp)
     5d2:	e852                	sd	s4,16(sp)
     5d4:	e456                	sd	s5,8(sp)
     5d6:	0080                	addi	s0,sp,64
     5d8:	8a2a                	mv	s4,a0
     5da:	892e                	mv	s2,a1
     5dc:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     5de:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     5e0:	00002997          	auipc	s3,0x2
     5e4:	a2898993          	addi	s3,s3,-1496 # 2008 <whitespace>
     5e8:	00b4fc63          	bgeu	s1,a1,600 <peek+0x3a>
     5ec:	0004c583          	lbu	a1,0(s1)
     5f0:	854e                	mv	a0,s3
     5f2:	5c0000ef          	jal	bb2 <strchr>
     5f6:	c509                	beqz	a0,600 <peek+0x3a>
    s++;
     5f8:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     5fa:	fe9919e3          	bne	s2,s1,5ec <peek+0x26>
     5fe:	84ca                	mv	s1,s2
  *ps = s;
     600:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     604:	0004c583          	lbu	a1,0(s1)
     608:	4501                	li	a0,0
     60a:	e991                	bnez	a1,61e <peek+0x58>
}
     60c:	70e2                	ld	ra,56(sp)
     60e:	7442                	ld	s0,48(sp)
     610:	74a2                	ld	s1,40(sp)
     612:	7902                	ld	s2,32(sp)
     614:	69e2                	ld	s3,24(sp)
     616:	6a42                	ld	s4,16(sp)
     618:	6aa2                	ld	s5,8(sp)
     61a:	6121                	addi	sp,sp,64
     61c:	8082                	ret
  return *s && strchr(toks, *s);
     61e:	8556                	mv	a0,s5
     620:	592000ef          	jal	bb2 <strchr>
     624:	00a03533          	snez	a0,a0
     628:	b7d5                	j	60c <peek+0x46>

000000000000062a <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     62a:	711d                	addi	sp,sp,-96
     62c:	ec86                	sd	ra,88(sp)
     62e:	e8a2                	sd	s0,80(sp)
     630:	e4a6                	sd	s1,72(sp)
     632:	e0ca                	sd	s2,64(sp)
     634:	fc4e                	sd	s3,56(sp)
     636:	f852                	sd	s4,48(sp)
     638:	f456                	sd	s5,40(sp)
     63a:	f05a                	sd	s6,32(sp)
     63c:	ec5e                	sd	s7,24(sp)
     63e:	1080                	addi	s0,sp,96
     640:	8a2a                	mv	s4,a0
     642:	89ae                	mv	s3,a1
     644:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     646:	00001a97          	auipc	s5,0x1
     64a:	dbaa8a93          	addi	s5,s5,-582 # 1400 <malloc+0x1be>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     64e:	06100b13          	li	s6,97
      panic("missing file for redirection");
    switch(tok){
     652:	03c00b93          	li	s7,60
  while(peek(ps, es, "<>")){
     656:	a00d                	j	678 <parseredirs+0x4e>
      panic("missing file for redirection");
     658:	00001517          	auipc	a0,0x1
     65c:	d8850513          	addi	a0,a0,-632 # 13e0 <malloc+0x19e>
     660:	a37ff0ef          	jal	96 <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     664:	4701                	li	a4,0
     666:	4681                	li	a3,0
     668:	fa043603          	ld	a2,-96(s0)
     66c:	fa843583          	ld	a1,-88(s0)
     670:	8552                	mv	a0,s4
     672:	d09ff0ef          	jal	37a <redircmd>
     676:	8a2a                	mv	s4,a0
  while(peek(ps, es, "<>")){
     678:	8656                	mv	a2,s5
     67a:	85ca                	mv	a1,s2
     67c:	854e                	mv	a0,s3
     67e:	f49ff0ef          	jal	5c6 <peek>
     682:	c525                	beqz	a0,6ea <parseredirs+0xc0>
    tok = gettoken(ps, es, 0, 0);
     684:	4681                	li	a3,0
     686:	4601                	li	a2,0
     688:	85ca                	mv	a1,s2
     68a:	854e                	mv	a0,s3
     68c:	dffff0ef          	jal	48a <gettoken>
     690:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     692:	fa040693          	addi	a3,s0,-96
     696:	fa840613          	addi	a2,s0,-88
     69a:	85ca                	mv	a1,s2
     69c:	854e                	mv	a0,s3
     69e:	dedff0ef          	jal	48a <gettoken>
     6a2:	fb651be3          	bne	a0,s6,658 <parseredirs+0x2e>
    switch(tok){
     6a6:	fb748fe3          	beq	s1,s7,664 <parseredirs+0x3a>
     6aa:	03e00793          	li	a5,62
     6ae:	02f48263          	beq	s1,a5,6d2 <parseredirs+0xa8>
     6b2:	02b00793          	li	a5,43
     6b6:	fcf491e3          	bne	s1,a5,678 <parseredirs+0x4e>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     6ba:	4705                	li	a4,1
     6bc:	20100693          	li	a3,513
     6c0:	fa043603          	ld	a2,-96(s0)
     6c4:	fa843583          	ld	a1,-88(s0)
     6c8:	8552                	mv	a0,s4
     6ca:	cb1ff0ef          	jal	37a <redircmd>
     6ce:	8a2a                	mv	s4,a0
      break;
     6d0:	b765                	j	678 <parseredirs+0x4e>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     6d2:	4705                	li	a4,1
     6d4:	60100693          	li	a3,1537
     6d8:	fa043603          	ld	a2,-96(s0)
     6dc:	fa843583          	ld	a1,-88(s0)
     6e0:	8552                	mv	a0,s4
     6e2:	c99ff0ef          	jal	37a <redircmd>
     6e6:	8a2a                	mv	s4,a0
      break;
     6e8:	bf41                	j	678 <parseredirs+0x4e>
    }
  }
  return cmd;
}
     6ea:	8552                	mv	a0,s4
     6ec:	60e6                	ld	ra,88(sp)
     6ee:	6446                	ld	s0,80(sp)
     6f0:	64a6                	ld	s1,72(sp)
     6f2:	6906                	ld	s2,64(sp)
     6f4:	79e2                	ld	s3,56(sp)
     6f6:	7a42                	ld	s4,48(sp)
     6f8:	7aa2                	ld	s5,40(sp)
     6fa:	7b02                	ld	s6,32(sp)
     6fc:	6be2                	ld	s7,24(sp)
     6fe:	6125                	addi	sp,sp,96
     700:	8082                	ret

0000000000000702 <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     702:	7159                	addi	sp,sp,-112
     704:	f486                	sd	ra,104(sp)
     706:	f0a2                	sd	s0,96(sp)
     708:	eca6                	sd	s1,88(sp)
     70a:	e0d2                	sd	s4,64(sp)
     70c:	fc56                	sd	s5,56(sp)
     70e:	1880                	addi	s0,sp,112
     710:	8a2a                	mv	s4,a0
     712:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     714:	00001617          	auipc	a2,0x1
     718:	cf460613          	addi	a2,a2,-780 # 1408 <malloc+0x1c6>
     71c:	eabff0ef          	jal	5c6 <peek>
     720:	e915                	bnez	a0,754 <parseexec+0x52>
     722:	e8ca                	sd	s2,80(sp)
     724:	e4ce                	sd	s3,72(sp)
     726:	f85a                	sd	s6,48(sp)
     728:	f45e                	sd	s7,40(sp)
     72a:	f062                	sd	s8,32(sp)
     72c:	ec66                	sd	s9,24(sp)
     72e:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     730:	c1dff0ef          	jal	34c <execcmd>
     734:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     736:	8656                	mv	a2,s5
     738:	85d2                	mv	a1,s4
     73a:	ef1ff0ef          	jal	62a <parseredirs>
     73e:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     740:	008c0913          	addi	s2,s8,8
     744:	00001b17          	auipc	s6,0x1
     748:	ce4b0b13          	addi	s6,s6,-796 # 1428 <malloc+0x1e6>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     74c:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     750:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     752:	a815                	j	786 <parseexec+0x84>
    return parseblock(ps, es);
     754:	85d6                	mv	a1,s5
     756:	8552                	mv	a0,s4
     758:	170000ef          	jal	8c8 <parseblock>
     75c:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     75e:	8526                	mv	a0,s1
     760:	70a6                	ld	ra,104(sp)
     762:	7406                	ld	s0,96(sp)
     764:	64e6                	ld	s1,88(sp)
     766:	6a06                	ld	s4,64(sp)
     768:	7ae2                	ld	s5,56(sp)
     76a:	6165                	addi	sp,sp,112
     76c:	8082                	ret
      panic("syntax");
     76e:	00001517          	auipc	a0,0x1
     772:	ca250513          	addi	a0,a0,-862 # 1410 <malloc+0x1ce>
     776:	921ff0ef          	jal	96 <panic>
    ret = parseredirs(ret, ps, es);
     77a:	8656                	mv	a2,s5
     77c:	85d2                	mv	a1,s4
     77e:	8526                	mv	a0,s1
     780:	eabff0ef          	jal	62a <parseredirs>
     784:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     786:	865a                	mv	a2,s6
     788:	85d6                	mv	a1,s5
     78a:	8552                	mv	a0,s4
     78c:	e3bff0ef          	jal	5c6 <peek>
     790:	ed15                	bnez	a0,7cc <parseexec+0xca>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     792:	f9040693          	addi	a3,s0,-112
     796:	f9840613          	addi	a2,s0,-104
     79a:	85d6                	mv	a1,s5
     79c:	8552                	mv	a0,s4
     79e:	cedff0ef          	jal	48a <gettoken>
     7a2:	c50d                	beqz	a0,7cc <parseexec+0xca>
    if(tok != 'a')
     7a4:	fd9515e3          	bne	a0,s9,76e <parseexec+0x6c>
    cmd->argv[argc] = q;
     7a8:	f9843783          	ld	a5,-104(s0)
     7ac:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     7b0:	f9043783          	ld	a5,-112(s0)
     7b4:	04f93823          	sd	a5,80(s2)
    argc++;
     7b8:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     7ba:	0921                	addi	s2,s2,8
     7bc:	fb799fe3          	bne	s3,s7,77a <parseexec+0x78>
      panic("too many args");
     7c0:	00001517          	auipc	a0,0x1
     7c4:	c5850513          	addi	a0,a0,-936 # 1418 <malloc+0x1d6>
     7c8:	8cfff0ef          	jal	96 <panic>
  cmd->argv[argc] = 0;
     7cc:	098e                	slli	s3,s3,0x3
     7ce:	9c4e                	add	s8,s8,s3
     7d0:	000c3423          	sd	zero,8(s8)
  cmd->eargv[argc] = 0;
     7d4:	040c3c23          	sd	zero,88(s8)
     7d8:	6946                	ld	s2,80(sp)
     7da:	69a6                	ld	s3,72(sp)
     7dc:	7b42                	ld	s6,48(sp)
     7de:	7ba2                	ld	s7,40(sp)
     7e0:	7c02                	ld	s8,32(sp)
     7e2:	6ce2                	ld	s9,24(sp)
  return ret;
     7e4:	bfad                	j	75e <parseexec+0x5c>

00000000000007e6 <parsepipe>:
{
     7e6:	7179                	addi	sp,sp,-48
     7e8:	f406                	sd	ra,40(sp)
     7ea:	f022                	sd	s0,32(sp)
     7ec:	ec26                	sd	s1,24(sp)
     7ee:	e84a                	sd	s2,16(sp)
     7f0:	e44e                	sd	s3,8(sp)
     7f2:	1800                	addi	s0,sp,48
     7f4:	892a                	mv	s2,a0
     7f6:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     7f8:	f0bff0ef          	jal	702 <parseexec>
     7fc:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     7fe:	00001617          	auipc	a2,0x1
     802:	c3260613          	addi	a2,a2,-974 # 1430 <malloc+0x1ee>
     806:	85ce                	mv	a1,s3
     808:	854a                	mv	a0,s2
     80a:	dbdff0ef          	jal	5c6 <peek>
     80e:	e909                	bnez	a0,820 <parsepipe+0x3a>
}
     810:	8526                	mv	a0,s1
     812:	70a2                	ld	ra,40(sp)
     814:	7402                	ld	s0,32(sp)
     816:	64e2                	ld	s1,24(sp)
     818:	6942                	ld	s2,16(sp)
     81a:	69a2                	ld	s3,8(sp)
     81c:	6145                	addi	sp,sp,48
     81e:	8082                	ret
    gettoken(ps, es, 0, 0);
     820:	4681                	li	a3,0
     822:	4601                	li	a2,0
     824:	85ce                	mv	a1,s3
     826:	854a                	mv	a0,s2
     828:	c63ff0ef          	jal	48a <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     82c:	85ce                	mv	a1,s3
     82e:	854a                	mv	a0,s2
     830:	fb7ff0ef          	jal	7e6 <parsepipe>
     834:	85aa                	mv	a1,a0
     836:	8526                	mv	a0,s1
     838:	ba3ff0ef          	jal	3da <pipecmd>
     83c:	84aa                	mv	s1,a0
  return cmd;
     83e:	bfc9                	j	810 <parsepipe+0x2a>

0000000000000840 <parseline>:
{
     840:	7179                	addi	sp,sp,-48
     842:	f406                	sd	ra,40(sp)
     844:	f022                	sd	s0,32(sp)
     846:	ec26                	sd	s1,24(sp)
     848:	e84a                	sd	s2,16(sp)
     84a:	e44e                	sd	s3,8(sp)
     84c:	e052                	sd	s4,0(sp)
     84e:	1800                	addi	s0,sp,48
     850:	892a                	mv	s2,a0
     852:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     854:	f93ff0ef          	jal	7e6 <parsepipe>
     858:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     85a:	00001a17          	auipc	s4,0x1
     85e:	bdea0a13          	addi	s4,s4,-1058 # 1438 <malloc+0x1f6>
     862:	a819                	j	878 <parseline+0x38>
    gettoken(ps, es, 0, 0);
     864:	4681                	li	a3,0
     866:	4601                	li	a2,0
     868:	85ce                	mv	a1,s3
     86a:	854a                	mv	a0,s2
     86c:	c1fff0ef          	jal	48a <gettoken>
    cmd = backcmd(cmd);
     870:	8526                	mv	a0,s1
     872:	be5ff0ef          	jal	456 <backcmd>
     876:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     878:	8652                	mv	a2,s4
     87a:	85ce                	mv	a1,s3
     87c:	854a                	mv	a0,s2
     87e:	d49ff0ef          	jal	5c6 <peek>
     882:	f16d                	bnez	a0,864 <parseline+0x24>
  if(peek(ps, es, ";")){
     884:	00001617          	auipc	a2,0x1
     888:	bbc60613          	addi	a2,a2,-1092 # 1440 <malloc+0x1fe>
     88c:	85ce                	mv	a1,s3
     88e:	854a                	mv	a0,s2
     890:	d37ff0ef          	jal	5c6 <peek>
     894:	e911                	bnez	a0,8a8 <parseline+0x68>
}
     896:	8526                	mv	a0,s1
     898:	70a2                	ld	ra,40(sp)
     89a:	7402                	ld	s0,32(sp)
     89c:	64e2                	ld	s1,24(sp)
     89e:	6942                	ld	s2,16(sp)
     8a0:	69a2                	ld	s3,8(sp)
     8a2:	6a02                	ld	s4,0(sp)
     8a4:	6145                	addi	sp,sp,48
     8a6:	8082                	ret
    gettoken(ps, es, 0, 0);
     8a8:	4681                	li	a3,0
     8aa:	4601                	li	a2,0
     8ac:	85ce                	mv	a1,s3
     8ae:	854a                	mv	a0,s2
     8b0:	bdbff0ef          	jal	48a <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     8b4:	85ce                	mv	a1,s3
     8b6:	854a                	mv	a0,s2
     8b8:	f89ff0ef          	jal	840 <parseline>
     8bc:	85aa                	mv	a1,a0
     8be:	8526                	mv	a0,s1
     8c0:	b59ff0ef          	jal	418 <listcmd>
     8c4:	84aa                	mv	s1,a0
  return cmd;
     8c6:	bfc1                	j	896 <parseline+0x56>

00000000000008c8 <parseblock>:
{
     8c8:	7179                	addi	sp,sp,-48
     8ca:	f406                	sd	ra,40(sp)
     8cc:	f022                	sd	s0,32(sp)
     8ce:	ec26                	sd	s1,24(sp)
     8d0:	e84a                	sd	s2,16(sp)
     8d2:	e44e                	sd	s3,8(sp)
     8d4:	1800                	addi	s0,sp,48
     8d6:	84aa                	mv	s1,a0
     8d8:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     8da:	00001617          	auipc	a2,0x1
     8de:	b2e60613          	addi	a2,a2,-1234 # 1408 <malloc+0x1c6>
     8e2:	ce5ff0ef          	jal	5c6 <peek>
     8e6:	c539                	beqz	a0,934 <parseblock+0x6c>
  gettoken(ps, es, 0, 0);
     8e8:	4681                	li	a3,0
     8ea:	4601                	li	a2,0
     8ec:	85ca                	mv	a1,s2
     8ee:	8526                	mv	a0,s1
     8f0:	b9bff0ef          	jal	48a <gettoken>
  cmd = parseline(ps, es);
     8f4:	85ca                	mv	a1,s2
     8f6:	8526                	mv	a0,s1
     8f8:	f49ff0ef          	jal	840 <parseline>
     8fc:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     8fe:	00001617          	auipc	a2,0x1
     902:	b5a60613          	addi	a2,a2,-1190 # 1458 <malloc+0x216>
     906:	85ca                	mv	a1,s2
     908:	8526                	mv	a0,s1
     90a:	cbdff0ef          	jal	5c6 <peek>
     90e:	c90d                	beqz	a0,940 <parseblock+0x78>
  gettoken(ps, es, 0, 0);
     910:	4681                	li	a3,0
     912:	4601                	li	a2,0
     914:	85ca                	mv	a1,s2
     916:	8526                	mv	a0,s1
     918:	b73ff0ef          	jal	48a <gettoken>
  cmd = parseredirs(cmd, ps, es);
     91c:	864a                	mv	a2,s2
     91e:	85a6                	mv	a1,s1
     920:	854e                	mv	a0,s3
     922:	d09ff0ef          	jal	62a <parseredirs>
}
     926:	70a2                	ld	ra,40(sp)
     928:	7402                	ld	s0,32(sp)
     92a:	64e2                	ld	s1,24(sp)
     92c:	6942                	ld	s2,16(sp)
     92e:	69a2                	ld	s3,8(sp)
     930:	6145                	addi	sp,sp,48
     932:	8082                	ret
    panic("parseblock");
     934:	00001517          	auipc	a0,0x1
     938:	b1450513          	addi	a0,a0,-1260 # 1448 <malloc+0x206>
     93c:	f5aff0ef          	jal	96 <panic>
    panic("syntax - missing )");
     940:	00001517          	auipc	a0,0x1
     944:	b2050513          	addi	a0,a0,-1248 # 1460 <malloc+0x21e>
     948:	f4eff0ef          	jal	96 <panic>

000000000000094c <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     94c:	1101                	addi	sp,sp,-32
     94e:	ec06                	sd	ra,24(sp)
     950:	e822                	sd	s0,16(sp)
     952:	e426                	sd	s1,8(sp)
     954:	1000                	addi	s0,sp,32
     956:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     958:	c131                	beqz	a0,99c <nulterminate+0x50>
    return 0;

  switch(cmd->type){
     95a:	4118                	lw	a4,0(a0)
     95c:	4795                	li	a5,5
     95e:	02e7ef63          	bltu	a5,a4,99c <nulterminate+0x50>
     962:	00056783          	lwu	a5,0(a0)
     966:	078a                	slli	a5,a5,0x2
     968:	00001717          	auipc	a4,0x1
     96c:	b5870713          	addi	a4,a4,-1192 # 14c0 <malloc+0x27e>
     970:	97ba                	add	a5,a5,a4
     972:	439c                	lw	a5,0(a5)
     974:	97ba                	add	a5,a5,a4
     976:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     978:	651c                	ld	a5,8(a0)
     97a:	c38d                	beqz	a5,99c <nulterminate+0x50>
     97c:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     980:	67b8                	ld	a4,72(a5)
     982:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     986:	07a1                	addi	a5,a5,8
     988:	ff87b703          	ld	a4,-8(a5)
     98c:	fb75                	bnez	a4,980 <nulterminate+0x34>
     98e:	a039                	j	99c <nulterminate+0x50>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     990:	6508                	ld	a0,8(a0)
     992:	fbbff0ef          	jal	94c <nulterminate>
    *rcmd->efile = 0;
     996:	6c9c                	ld	a5,24(s1)
     998:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
} 
     99c:	8526                	mv	a0,s1
     99e:	60e2                	ld	ra,24(sp)
     9a0:	6442                	ld	s0,16(sp)
     9a2:	64a2                	ld	s1,8(sp)
     9a4:	6105                	addi	sp,sp,32
     9a6:	8082                	ret
    nulterminate(pcmd->left);
     9a8:	6508                	ld	a0,8(a0)
     9aa:	fa3ff0ef          	jal	94c <nulterminate>
    nulterminate(pcmd->right);
     9ae:	6888                	ld	a0,16(s1)
     9b0:	f9dff0ef          	jal	94c <nulterminate>
    break;
     9b4:	b7e5                	j	99c <nulterminate+0x50>
    nulterminate(lcmd->left);
     9b6:	6508                	ld	a0,8(a0)
     9b8:	f95ff0ef          	jal	94c <nulterminate>
    nulterminate(lcmd->right);
     9bc:	6888                	ld	a0,16(s1)
     9be:	f8fff0ef          	jal	94c <nulterminate>
    break;
     9c2:	bfe9                	j	99c <nulterminate+0x50>
    nulterminate(bcmd->cmd);
     9c4:	6508                	ld	a0,8(a0)
     9c6:	f87ff0ef          	jal	94c <nulterminate>
    break;
     9ca:	bfc9                	j	99c <nulterminate+0x50>

00000000000009cc <parsecmd>:
{
     9cc:	7179                	addi	sp,sp,-48
     9ce:	f406                	sd	ra,40(sp)
     9d0:	f022                	sd	s0,32(sp)
     9d2:	ec26                	sd	s1,24(sp)
     9d4:	e84a                	sd	s2,16(sp)
     9d6:	1800                	addi	s0,sp,48
     9d8:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     9dc:	84aa                	mv	s1,a0
     9de:	188000ef          	jal	b66 <strlen>
     9e2:	1502                	slli	a0,a0,0x20
     9e4:	9101                	srli	a0,a0,0x20
     9e6:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     9e8:	85a6                	mv	a1,s1
     9ea:	fd840513          	addi	a0,s0,-40
     9ee:	e53ff0ef          	jal	840 <parseline>
     9f2:	892a                	mv	s2,a0
  peek(&s, es, "");
     9f4:	00001617          	auipc	a2,0x1
     9f8:	96460613          	addi	a2,a2,-1692 # 1358 <malloc+0x116>
     9fc:	85a6                	mv	a1,s1
     9fe:	fd840513          	addi	a0,s0,-40
     a02:	bc5ff0ef          	jal	5c6 <peek>
  if(s != es){
     a06:	fd843603          	ld	a2,-40(s0)
     a0a:	00961c63          	bne	a2,s1,a22 <parsecmd+0x56>
  nulterminate(cmd);
     a0e:	854a                	mv	a0,s2
     a10:	f3dff0ef          	jal	94c <nulterminate>
}
     a14:	854a                	mv	a0,s2
     a16:	70a2                	ld	ra,40(sp)
     a18:	7402                	ld	s0,32(sp)
     a1a:	64e2                	ld	s1,24(sp)
     a1c:	6942                	ld	s2,16(sp)
     a1e:	6145                	addi	sp,sp,48
     a20:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     a22:	00001597          	auipc	a1,0x1
     a26:	a5658593          	addi	a1,a1,-1450 # 1478 <malloc+0x236>
     a2a:	4509                	li	a0,2
     a2c:	738000ef          	jal	1164 <fprintf>
    panic("syntax");
     a30:	00001517          	auipc	a0,0x1
     a34:	9e050513          	addi	a0,a0,-1568 # 1410 <malloc+0x1ce>
     a38:	e5eff0ef          	jal	96 <panic>

0000000000000a3c <main>:
{
     a3c:	7179                	addi	sp,sp,-48
     a3e:	f406                	sd	ra,40(sp)
     a40:	f022                	sd	s0,32(sp)
     a42:	ec26                	sd	s1,24(sp)
     a44:	e84a                	sd	s2,16(sp)
     a46:	e44e                	sd	s3,8(sp)
     a48:	e052                	sd	s4,0(sp)
     a4a:	1800                	addi	s0,sp,48
  while((fd = open("console", O_RDWR)) >= 0){
     a4c:	00001497          	auipc	s1,0x1
     a50:	a3c48493          	addi	s1,s1,-1476 # 1488 <malloc+0x246>
     a54:	4589                	li	a1,2
     a56:	8526                	mv	a0,s1
     a58:	35e000ef          	jal	db6 <open>
     a5c:	00054763          	bltz	a0,a6a <main+0x2e>
    if(fd >= 3){
     a60:	4789                	li	a5,2
     a62:	fea7d9e3          	bge	a5,a0,a54 <main+0x18>
      close(fd);
     a66:	338000ef          	jal	d9e <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     a6a:	00001497          	auipc	s1,0x1
     a6e:	5b648493          	addi	s1,s1,1462 # 2020 <buf.0>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     a72:	06300913          	li	s2,99
     a76:	02000993          	li	s3,32
     a7a:	a039                	j	a88 <main+0x4c>
    if(fork1() == 0)
     a7c:	e38ff0ef          	jal	b4 <fork1>
     a80:	c93d                	beqz	a0,af6 <main+0xba>
    wait(0);
     a82:	4501                	li	a0,0
     a84:	2fa000ef          	jal	d7e <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     a88:	06400593          	li	a1,100
     a8c:	8526                	mv	a0,s1
     a8e:	dbeff0ef          	jal	4c <getcmd>
     a92:	06054a63          	bltz	a0,b06 <main+0xca>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     a96:	0004c783          	lbu	a5,0(s1)
     a9a:	ff2791e3          	bne	a5,s2,a7c <main+0x40>
     a9e:	0014c703          	lbu	a4,1(s1)
     aa2:	06400793          	li	a5,100
     aa6:	fcf71be3          	bne	a4,a5,a7c <main+0x40>
     aaa:	0024c783          	lbu	a5,2(s1)
     aae:	fd3797e3          	bne	a5,s3,a7c <main+0x40>
      buf[strlen(buf)-1] = 0;  // chop \n
     ab2:	00001a17          	auipc	s4,0x1
     ab6:	56ea0a13          	addi	s4,s4,1390 # 2020 <buf.0>
     aba:	8552                	mv	a0,s4
     abc:	0aa000ef          	jal	b66 <strlen>
     ac0:	fff5079b          	addiw	a5,a0,-1
     ac4:	1782                	slli	a5,a5,0x20
     ac6:	9381                	srli	a5,a5,0x20
     ac8:	9a3e                	add	s4,s4,a5
     aca:	000a0023          	sb	zero,0(s4)
      if(chdir(buf+3) < 0)
     ace:	00001517          	auipc	a0,0x1
     ad2:	55550513          	addi	a0,a0,1365 # 2023 <buf.0+0x3>
     ad6:	310000ef          	jal	de6 <chdir>
     ada:	fa0557e3          	bgez	a0,a88 <main+0x4c>
        fprintf(2, "cannot cd %s\n", buf+3);
     ade:	00001617          	auipc	a2,0x1
     ae2:	54560613          	addi	a2,a2,1349 # 2023 <buf.0+0x3>
     ae6:	00001597          	auipc	a1,0x1
     aea:	9aa58593          	addi	a1,a1,-1622 # 1490 <malloc+0x24e>
     aee:	4509                	li	a0,2
     af0:	674000ef          	jal	1164 <fprintf>
     af4:	bf51                	j	a88 <main+0x4c>
      runcmd(parsecmd(buf));
     af6:	00001517          	auipc	a0,0x1
     afa:	52a50513          	addi	a0,a0,1322 # 2020 <buf.0>
     afe:	ecfff0ef          	jal	9cc <parsecmd>
     b02:	dd8ff0ef          	jal	da <runcmd>
  exit(0);
     b06:	4501                	li	a0,0
     b08:	26e000ef          	jal	d76 <exit>

0000000000000b0c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
     b0c:	1141                	addi	sp,sp,-16
     b0e:	e406                	sd	ra,8(sp)
     b10:	e022                	sd	s0,0(sp)
     b12:	0800                	addi	s0,sp,16
  extern int main();
  main();
     b14:	f29ff0ef          	jal	a3c <main>
  exit(0);
     b18:	4501                	li	a0,0
     b1a:	25c000ef          	jal	d76 <exit>

0000000000000b1e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     b1e:	1141                	addi	sp,sp,-16
     b20:	e422                	sd	s0,8(sp)
     b22:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     b24:	87aa                	mv	a5,a0
     b26:	0585                	addi	a1,a1,1
     b28:	0785                	addi	a5,a5,1
     b2a:	fff5c703          	lbu	a4,-1(a1)
     b2e:	fee78fa3          	sb	a4,-1(a5)
     b32:	fb75                	bnez	a4,b26 <strcpy+0x8>
    ;
  return os;
}
     b34:	6422                	ld	s0,8(sp)
     b36:	0141                	addi	sp,sp,16
     b38:	8082                	ret

0000000000000b3a <strcmp>:

int
strcmp(const char *p, const char *q)
{
     b3a:	1141                	addi	sp,sp,-16
     b3c:	e422                	sd	s0,8(sp)
     b3e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     b40:	00054783          	lbu	a5,0(a0)
     b44:	cb91                	beqz	a5,b58 <strcmp+0x1e>
     b46:	0005c703          	lbu	a4,0(a1)
     b4a:	00f71763          	bne	a4,a5,b58 <strcmp+0x1e>
    p++, q++;
     b4e:	0505                	addi	a0,a0,1
     b50:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     b52:	00054783          	lbu	a5,0(a0)
     b56:	fbe5                	bnez	a5,b46 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     b58:	0005c503          	lbu	a0,0(a1)
}
     b5c:	40a7853b          	subw	a0,a5,a0
     b60:	6422                	ld	s0,8(sp)
     b62:	0141                	addi	sp,sp,16
     b64:	8082                	ret

0000000000000b66 <strlen>:

uint
strlen(const char *s)
{
     b66:	1141                	addi	sp,sp,-16
     b68:	e422                	sd	s0,8(sp)
     b6a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     b6c:	00054783          	lbu	a5,0(a0)
     b70:	cf91                	beqz	a5,b8c <strlen+0x26>
     b72:	0505                	addi	a0,a0,1
     b74:	87aa                	mv	a5,a0
     b76:	86be                	mv	a3,a5
     b78:	0785                	addi	a5,a5,1
     b7a:	fff7c703          	lbu	a4,-1(a5)
     b7e:	ff65                	bnez	a4,b76 <strlen+0x10>
     b80:	40a6853b          	subw	a0,a3,a0
     b84:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     b86:	6422                	ld	s0,8(sp)
     b88:	0141                	addi	sp,sp,16
     b8a:	8082                	ret
  for(n = 0; s[n]; n++)
     b8c:	4501                	li	a0,0
     b8e:	bfe5                	j	b86 <strlen+0x20>

0000000000000b90 <memset>:

void*
memset(void *dst, int c, uint n)
{
     b90:	1141                	addi	sp,sp,-16
     b92:	e422                	sd	s0,8(sp)
     b94:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     b96:	ca19                	beqz	a2,bac <memset+0x1c>
     b98:	87aa                	mv	a5,a0
     b9a:	1602                	slli	a2,a2,0x20
     b9c:	9201                	srli	a2,a2,0x20
     b9e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     ba2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     ba6:	0785                	addi	a5,a5,1
     ba8:	fee79de3          	bne	a5,a4,ba2 <memset+0x12>
  }
  return dst;
}
     bac:	6422                	ld	s0,8(sp)
     bae:	0141                	addi	sp,sp,16
     bb0:	8082                	ret

0000000000000bb2 <strchr>:

char*
strchr(const char *s, char c)
{
     bb2:	1141                	addi	sp,sp,-16
     bb4:	e422                	sd	s0,8(sp)
     bb6:	0800                	addi	s0,sp,16
  for(; *s; s++)
     bb8:	00054783          	lbu	a5,0(a0)
     bbc:	cb99                	beqz	a5,bd2 <strchr+0x20>
    if(*s == c)
     bbe:	00f58763          	beq	a1,a5,bcc <strchr+0x1a>
  for(; *s; s++)
     bc2:	0505                	addi	a0,a0,1
     bc4:	00054783          	lbu	a5,0(a0)
     bc8:	fbfd                	bnez	a5,bbe <strchr+0xc>
      return (char*)s;
  return 0;
     bca:	4501                	li	a0,0
}
     bcc:	6422                	ld	s0,8(sp)
     bce:	0141                	addi	sp,sp,16
     bd0:	8082                	ret
  return 0;
     bd2:	4501                	li	a0,0
     bd4:	bfe5                	j	bcc <strchr+0x1a>

0000000000000bd6 <gets>:

char*
gets(char *buf, int max)
{
     bd6:	711d                	addi	sp,sp,-96
     bd8:	ec86                	sd	ra,88(sp)
     bda:	e8a2                	sd	s0,80(sp)
     bdc:	e4a6                	sd	s1,72(sp)
     bde:	e0ca                	sd	s2,64(sp)
     be0:	fc4e                	sd	s3,56(sp)
     be2:	f852                	sd	s4,48(sp)
     be4:	f456                	sd	s5,40(sp)
     be6:	f05a                	sd	s6,32(sp)
     be8:	ec5e                	sd	s7,24(sp)
     bea:	1080                	addi	s0,sp,96
     bec:	8baa                	mv	s7,a0
     bee:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     bf0:	892a                	mv	s2,a0
     bf2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     bf4:	4aa9                	li	s5,10
     bf6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     bf8:	89a6                	mv	s3,s1
     bfa:	2485                	addiw	s1,s1,1
     bfc:	0344d663          	bge	s1,s4,c28 <gets+0x52>
    cc = read(0, &c, 1);
     c00:	4605                	li	a2,1
     c02:	faf40593          	addi	a1,s0,-81
     c06:	4501                	li	a0,0
     c08:	186000ef          	jal	d8e <read>
    if(cc < 1)
     c0c:	00a05e63          	blez	a0,c28 <gets+0x52>
    buf[i++] = c;
     c10:	faf44783          	lbu	a5,-81(s0)
     c14:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     c18:	01578763          	beq	a5,s5,c26 <gets+0x50>
     c1c:	0905                	addi	s2,s2,1
     c1e:	fd679de3          	bne	a5,s6,bf8 <gets+0x22>
    buf[i++] = c;
     c22:	89a6                	mv	s3,s1
     c24:	a011                	j	c28 <gets+0x52>
     c26:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     c28:	99de                	add	s3,s3,s7
     c2a:	00098023          	sb	zero,0(s3)
  return buf;
}
     c2e:	855e                	mv	a0,s7
     c30:	60e6                	ld	ra,88(sp)
     c32:	6446                	ld	s0,80(sp)
     c34:	64a6                	ld	s1,72(sp)
     c36:	6906                	ld	s2,64(sp)
     c38:	79e2                	ld	s3,56(sp)
     c3a:	7a42                	ld	s4,48(sp)
     c3c:	7aa2                	ld	s5,40(sp)
     c3e:	7b02                	ld	s6,32(sp)
     c40:	6be2                	ld	s7,24(sp)
     c42:	6125                	addi	sp,sp,96
     c44:	8082                	ret

0000000000000c46 <stat>:

int
stat(const char *n, struct stat *st)
{
     c46:	1101                	addi	sp,sp,-32
     c48:	ec06                	sd	ra,24(sp)
     c4a:	e822                	sd	s0,16(sp)
     c4c:	e04a                	sd	s2,0(sp)
     c4e:	1000                	addi	s0,sp,32
     c50:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     c52:	4581                	li	a1,0
     c54:	162000ef          	jal	db6 <open>
  if(fd < 0)
     c58:	02054263          	bltz	a0,c7c <stat+0x36>
     c5c:	e426                	sd	s1,8(sp)
     c5e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     c60:	85ca                	mv	a1,s2
     c62:	16c000ef          	jal	dce <fstat>
     c66:	892a                	mv	s2,a0
  close(fd);
     c68:	8526                	mv	a0,s1
     c6a:	134000ef          	jal	d9e <close>
  return r;
     c6e:	64a2                	ld	s1,8(sp)
}
     c70:	854a                	mv	a0,s2
     c72:	60e2                	ld	ra,24(sp)
     c74:	6442                	ld	s0,16(sp)
     c76:	6902                	ld	s2,0(sp)
     c78:	6105                	addi	sp,sp,32
     c7a:	8082                	ret
    return -1;
     c7c:	597d                	li	s2,-1
     c7e:	bfcd                	j	c70 <stat+0x2a>

0000000000000c80 <atoi>:

int
atoi(const char *s)
{
     c80:	1141                	addi	sp,sp,-16
     c82:	e422                	sd	s0,8(sp)
     c84:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     c86:	00054683          	lbu	a3,0(a0)
     c8a:	fd06879b          	addiw	a5,a3,-48
     c8e:	0ff7f793          	zext.b	a5,a5
     c92:	4625                	li	a2,9
     c94:	02f66863          	bltu	a2,a5,cc4 <atoi+0x44>
     c98:	872a                	mv	a4,a0
  n = 0;
     c9a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     c9c:	0705                	addi	a4,a4,1
     c9e:	0025179b          	slliw	a5,a0,0x2
     ca2:	9fa9                	addw	a5,a5,a0
     ca4:	0017979b          	slliw	a5,a5,0x1
     ca8:	9fb5                	addw	a5,a5,a3
     caa:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     cae:	00074683          	lbu	a3,0(a4)
     cb2:	fd06879b          	addiw	a5,a3,-48
     cb6:	0ff7f793          	zext.b	a5,a5
     cba:	fef671e3          	bgeu	a2,a5,c9c <atoi+0x1c>
  return n;
}
     cbe:	6422                	ld	s0,8(sp)
     cc0:	0141                	addi	sp,sp,16
     cc2:	8082                	ret
  n = 0;
     cc4:	4501                	li	a0,0
     cc6:	bfe5                	j	cbe <atoi+0x3e>

0000000000000cc8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     cc8:	1141                	addi	sp,sp,-16
     cca:	e422                	sd	s0,8(sp)
     ccc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     cce:	02b57463          	bgeu	a0,a1,cf6 <memmove+0x2e>
    while(n-- > 0)
     cd2:	00c05f63          	blez	a2,cf0 <memmove+0x28>
     cd6:	1602                	slli	a2,a2,0x20
     cd8:	9201                	srli	a2,a2,0x20
     cda:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     cde:	872a                	mv	a4,a0
      *dst++ = *src++;
     ce0:	0585                	addi	a1,a1,1
     ce2:	0705                	addi	a4,a4,1
     ce4:	fff5c683          	lbu	a3,-1(a1)
     ce8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     cec:	fef71ae3          	bne	a4,a5,ce0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     cf0:	6422                	ld	s0,8(sp)
     cf2:	0141                	addi	sp,sp,16
     cf4:	8082                	ret
    dst += n;
     cf6:	00c50733          	add	a4,a0,a2
    src += n;
     cfa:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     cfc:	fec05ae3          	blez	a2,cf0 <memmove+0x28>
     d00:	fff6079b          	addiw	a5,a2,-1
     d04:	1782                	slli	a5,a5,0x20
     d06:	9381                	srli	a5,a5,0x20
     d08:	fff7c793          	not	a5,a5
     d0c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     d0e:	15fd                	addi	a1,a1,-1
     d10:	177d                	addi	a4,a4,-1
     d12:	0005c683          	lbu	a3,0(a1)
     d16:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     d1a:	fee79ae3          	bne	a5,a4,d0e <memmove+0x46>
     d1e:	bfc9                	j	cf0 <memmove+0x28>

0000000000000d20 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     d20:	1141                	addi	sp,sp,-16
     d22:	e422                	sd	s0,8(sp)
     d24:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     d26:	ca05                	beqz	a2,d56 <memcmp+0x36>
     d28:	fff6069b          	addiw	a3,a2,-1
     d2c:	1682                	slli	a3,a3,0x20
     d2e:	9281                	srli	a3,a3,0x20
     d30:	0685                	addi	a3,a3,1
     d32:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     d34:	00054783          	lbu	a5,0(a0)
     d38:	0005c703          	lbu	a4,0(a1)
     d3c:	00e79863          	bne	a5,a4,d4c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     d40:	0505                	addi	a0,a0,1
    p2++;
     d42:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     d44:	fed518e3          	bne	a0,a3,d34 <memcmp+0x14>
  }
  return 0;
     d48:	4501                	li	a0,0
     d4a:	a019                	j	d50 <memcmp+0x30>
      return *p1 - *p2;
     d4c:	40e7853b          	subw	a0,a5,a4
}
     d50:	6422                	ld	s0,8(sp)
     d52:	0141                	addi	sp,sp,16
     d54:	8082                	ret
  return 0;
     d56:	4501                	li	a0,0
     d58:	bfe5                	j	d50 <memcmp+0x30>

0000000000000d5a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     d5a:	1141                	addi	sp,sp,-16
     d5c:	e406                	sd	ra,8(sp)
     d5e:	e022                	sd	s0,0(sp)
     d60:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     d62:	f67ff0ef          	jal	cc8 <memmove>
}
     d66:	60a2                	ld	ra,8(sp)
     d68:	6402                	ld	s0,0(sp)
     d6a:	0141                	addi	sp,sp,16
     d6c:	8082                	ret

0000000000000d6e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     d6e:	4885                	li	a7,1
 ecall
     d70:	00000073          	ecall
 ret
     d74:	8082                	ret

0000000000000d76 <exit>:
.global exit
exit:
 li a7, SYS_exit
     d76:	4889                	li	a7,2
 ecall
     d78:	00000073          	ecall
 ret
     d7c:	8082                	ret

0000000000000d7e <wait>:
.global wait
wait:
 li a7, SYS_wait
     d7e:	488d                	li	a7,3
 ecall
     d80:	00000073          	ecall
 ret
     d84:	8082                	ret

0000000000000d86 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     d86:	4891                	li	a7,4
 ecall
     d88:	00000073          	ecall
 ret
     d8c:	8082                	ret

0000000000000d8e <read>:
.global read
read:
 li a7, SYS_read
     d8e:	4895                	li	a7,5
 ecall
     d90:	00000073          	ecall
 ret
     d94:	8082                	ret

0000000000000d96 <write>:
.global write
write:
 li a7, SYS_write
     d96:	48c1                	li	a7,16
 ecall
     d98:	00000073          	ecall
 ret
     d9c:	8082                	ret

0000000000000d9e <close>:
.global close
close:
 li a7, SYS_close
     d9e:	48d5                	li	a7,21
 ecall
     da0:	00000073          	ecall
 ret
     da4:	8082                	ret

0000000000000da6 <kill>:
.global kill
kill:
 li a7, SYS_kill
     da6:	4899                	li	a7,6
 ecall
     da8:	00000073          	ecall
 ret
     dac:	8082                	ret

0000000000000dae <exec>:
.global exec
exec:
 li a7, SYS_exec
     dae:	489d                	li	a7,7
 ecall
     db0:	00000073          	ecall
 ret
     db4:	8082                	ret

0000000000000db6 <open>:
.global open
open:
 li a7, SYS_open
     db6:	48bd                	li	a7,15
 ecall
     db8:	00000073          	ecall
 ret
     dbc:	8082                	ret

0000000000000dbe <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     dbe:	48c5                	li	a7,17
 ecall
     dc0:	00000073          	ecall
 ret
     dc4:	8082                	ret

0000000000000dc6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     dc6:	48c9                	li	a7,18
 ecall
     dc8:	00000073          	ecall
 ret
     dcc:	8082                	ret

0000000000000dce <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     dce:	48a1                	li	a7,8
 ecall
     dd0:	00000073          	ecall
 ret
     dd4:	8082                	ret

0000000000000dd6 <link>:
.global link
link:
 li a7, SYS_link
     dd6:	48cd                	li	a7,19
 ecall
     dd8:	00000073          	ecall
 ret
     ddc:	8082                	ret

0000000000000dde <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     dde:	48d1                	li	a7,20
 ecall
     de0:	00000073          	ecall
 ret
     de4:	8082                	ret

0000000000000de6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     de6:	48a5                	li	a7,9
 ecall
     de8:	00000073          	ecall
 ret
     dec:	8082                	ret

0000000000000dee <dup>:
.global dup
dup:
 li a7, SYS_dup
     dee:	48a9                	li	a7,10
 ecall
     df0:	00000073          	ecall
 ret
     df4:	8082                	ret

0000000000000df6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     df6:	48ad                	li	a7,11
 ecall
     df8:	00000073          	ecall
 ret
     dfc:	8082                	ret

0000000000000dfe <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     dfe:	48b1                	li	a7,12
 ecall
     e00:	00000073          	ecall
 ret
     e04:	8082                	ret

0000000000000e06 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     e06:	48b5                	li	a7,13
 ecall
     e08:	00000073          	ecall
 ret
     e0c:	8082                	ret

0000000000000e0e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     e0e:	48b9                	li	a7,14
 ecall
     e10:	00000073          	ecall
 ret
     e14:	8082                	ret

0000000000000e16 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     e16:	1101                	addi	sp,sp,-32
     e18:	ec06                	sd	ra,24(sp)
     e1a:	e822                	sd	s0,16(sp)
     e1c:	1000                	addi	s0,sp,32
     e1e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     e22:	4605                	li	a2,1
     e24:	fef40593          	addi	a1,s0,-17
     e28:	f6fff0ef          	jal	d96 <write>
}
     e2c:	60e2                	ld	ra,24(sp)
     e2e:	6442                	ld	s0,16(sp)
     e30:	6105                	addi	sp,sp,32
     e32:	8082                	ret

0000000000000e34 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     e34:	7139                	addi	sp,sp,-64
     e36:	fc06                	sd	ra,56(sp)
     e38:	f822                	sd	s0,48(sp)
     e3a:	f426                	sd	s1,40(sp)
     e3c:	0080                	addi	s0,sp,64
     e3e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     e40:	c299                	beqz	a3,e46 <printint+0x12>
     e42:	0805c963          	bltz	a1,ed4 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     e46:	2581                	sext.w	a1,a1
  neg = 0;
     e48:	4881                	li	a7,0
     e4a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     e4e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     e50:	2601                	sext.w	a2,a2
     e52:	00000517          	auipc	a0,0x0
     e56:	68650513          	addi	a0,a0,1670 # 14d8 <digits>
     e5a:	883a                	mv	a6,a4
     e5c:	2705                	addiw	a4,a4,1
     e5e:	02c5f7bb          	remuw	a5,a1,a2
     e62:	1782                	slli	a5,a5,0x20
     e64:	9381                	srli	a5,a5,0x20
     e66:	97aa                	add	a5,a5,a0
     e68:	0007c783          	lbu	a5,0(a5)
     e6c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     e70:	0005879b          	sext.w	a5,a1
     e74:	02c5d5bb          	divuw	a1,a1,a2
     e78:	0685                	addi	a3,a3,1
     e7a:	fec7f0e3          	bgeu	a5,a2,e5a <printint+0x26>
  if(neg)
     e7e:	00088c63          	beqz	a7,e96 <printint+0x62>
    buf[i++] = '-';
     e82:	fd070793          	addi	a5,a4,-48
     e86:	00878733          	add	a4,a5,s0
     e8a:	02d00793          	li	a5,45
     e8e:	fef70823          	sb	a5,-16(a4)
     e92:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     e96:	02e05a63          	blez	a4,eca <printint+0x96>
     e9a:	f04a                	sd	s2,32(sp)
     e9c:	ec4e                	sd	s3,24(sp)
     e9e:	fc040793          	addi	a5,s0,-64
     ea2:	00e78933          	add	s2,a5,a4
     ea6:	fff78993          	addi	s3,a5,-1
     eaa:	99ba                	add	s3,s3,a4
     eac:	377d                	addiw	a4,a4,-1
     eae:	1702                	slli	a4,a4,0x20
     eb0:	9301                	srli	a4,a4,0x20
     eb2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     eb6:	fff94583          	lbu	a1,-1(s2)
     eba:	8526                	mv	a0,s1
     ebc:	f5bff0ef          	jal	e16 <putc>
  while(--i >= 0)
     ec0:	197d                	addi	s2,s2,-1
     ec2:	ff391ae3          	bne	s2,s3,eb6 <printint+0x82>
     ec6:	7902                	ld	s2,32(sp)
     ec8:	69e2                	ld	s3,24(sp)
}
     eca:	70e2                	ld	ra,56(sp)
     ecc:	7442                	ld	s0,48(sp)
     ece:	74a2                	ld	s1,40(sp)
     ed0:	6121                	addi	sp,sp,64
     ed2:	8082                	ret
    x = -xx;
     ed4:	40b005bb          	negw	a1,a1
    neg = 1;
     ed8:	4885                	li	a7,1
    x = -xx;
     eda:	bf85                	j	e4a <printint+0x16>

0000000000000edc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     edc:	711d                	addi	sp,sp,-96
     ede:	ec86                	sd	ra,88(sp)
     ee0:	e8a2                	sd	s0,80(sp)
     ee2:	e0ca                	sd	s2,64(sp)
     ee4:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     ee6:	0005c903          	lbu	s2,0(a1)
     eea:	26090863          	beqz	s2,115a <vprintf+0x27e>
     eee:	e4a6                	sd	s1,72(sp)
     ef0:	fc4e                	sd	s3,56(sp)
     ef2:	f852                	sd	s4,48(sp)
     ef4:	f456                	sd	s5,40(sp)
     ef6:	f05a                	sd	s6,32(sp)
     ef8:	ec5e                	sd	s7,24(sp)
     efa:	e862                	sd	s8,16(sp)
     efc:	e466                	sd	s9,8(sp)
     efe:	8b2a                	mv	s6,a0
     f00:	8a2e                	mv	s4,a1
     f02:	8bb2                	mv	s7,a2
  state = 0;
     f04:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
     f06:	4481                	li	s1,0
     f08:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
     f0a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
     f0e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
     f12:	06c00c93          	li	s9,108
     f16:	a005                	j	f36 <vprintf+0x5a>
        putc(fd, c0);
     f18:	85ca                	mv	a1,s2
     f1a:	855a                	mv	a0,s6
     f1c:	efbff0ef          	jal	e16 <putc>
     f20:	a019                	j	f26 <vprintf+0x4a>
    } else if(state == '%'){
     f22:	03598263          	beq	s3,s5,f46 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
     f26:	2485                	addiw	s1,s1,1
     f28:	8726                	mv	a4,s1
     f2a:	009a07b3          	add	a5,s4,s1
     f2e:	0007c903          	lbu	s2,0(a5)
     f32:	20090c63          	beqz	s2,114a <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
     f36:	0009079b          	sext.w	a5,s2
    if(state == 0){
     f3a:	fe0994e3          	bnez	s3,f22 <vprintf+0x46>
      if(c0 == '%'){
     f3e:	fd579de3          	bne	a5,s5,f18 <vprintf+0x3c>
        state = '%';
     f42:	89be                	mv	s3,a5
     f44:	b7cd                	j	f26 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
     f46:	00ea06b3          	add	a3,s4,a4
     f4a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
     f4e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
     f50:	c681                	beqz	a3,f58 <vprintf+0x7c>
     f52:	9752                	add	a4,a4,s4
     f54:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
     f58:	03878f63          	beq	a5,s8,f96 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
     f5c:	05978963          	beq	a5,s9,fae <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
     f60:	07500713          	li	a4,117
     f64:	0ee78363          	beq	a5,a4,104a <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
     f68:	07800713          	li	a4,120
     f6c:	12e78563          	beq	a5,a4,1096 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
     f70:	07000713          	li	a4,112
     f74:	14e78a63          	beq	a5,a4,10c8 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
     f78:	07300713          	li	a4,115
     f7c:	18e78a63          	beq	a5,a4,1110 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
     f80:	02500713          	li	a4,37
     f84:	04e79563          	bne	a5,a4,fce <vprintf+0xf2>
        putc(fd, '%');
     f88:	02500593          	li	a1,37
     f8c:	855a                	mv	a0,s6
     f8e:	e89ff0ef          	jal	e16 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
     f92:	4981                	li	s3,0
     f94:	bf49                	j	f26 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
     f96:	008b8913          	addi	s2,s7,8
     f9a:	4685                	li	a3,1
     f9c:	4629                	li	a2,10
     f9e:	000ba583          	lw	a1,0(s7)
     fa2:	855a                	mv	a0,s6
     fa4:	e91ff0ef          	jal	e34 <printint>
     fa8:	8bca                	mv	s7,s2
      state = 0;
     faa:	4981                	li	s3,0
     fac:	bfad                	j	f26 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
     fae:	06400793          	li	a5,100
     fb2:	02f68963          	beq	a3,a5,fe4 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     fb6:	06c00793          	li	a5,108
     fba:	04f68263          	beq	a3,a5,ffe <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
     fbe:	07500793          	li	a5,117
     fc2:	0af68063          	beq	a3,a5,1062 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
     fc6:	07800793          	li	a5,120
     fca:	0ef68263          	beq	a3,a5,10ae <vprintf+0x1d2>
        putc(fd, '%');
     fce:	02500593          	li	a1,37
     fd2:	855a                	mv	a0,s6
     fd4:	e43ff0ef          	jal	e16 <putc>
        putc(fd, c0);
     fd8:	85ca                	mv	a1,s2
     fda:	855a                	mv	a0,s6
     fdc:	e3bff0ef          	jal	e16 <putc>
      state = 0;
     fe0:	4981                	li	s3,0
     fe2:	b791                	j	f26 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     fe4:	008b8913          	addi	s2,s7,8
     fe8:	4685                	li	a3,1
     fea:	4629                	li	a2,10
     fec:	000ba583          	lw	a1,0(s7)
     ff0:	855a                	mv	a0,s6
     ff2:	e43ff0ef          	jal	e34 <printint>
        i += 1;
     ff6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     ff8:	8bca                	mv	s7,s2
      state = 0;
     ffa:	4981                	li	s3,0
        i += 1;
     ffc:	b72d                	j	f26 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     ffe:	06400793          	li	a5,100
    1002:	02f60763          	beq	a2,a5,1030 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    1006:	07500793          	li	a5,117
    100a:	06f60963          	beq	a2,a5,107c <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    100e:	07800793          	li	a5,120
    1012:	faf61ee3          	bne	a2,a5,fce <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
    1016:	008b8913          	addi	s2,s7,8
    101a:	4681                	li	a3,0
    101c:	4641                	li	a2,16
    101e:	000ba583          	lw	a1,0(s7)
    1022:	855a                	mv	a0,s6
    1024:	e11ff0ef          	jal	e34 <printint>
        i += 2;
    1028:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
    102a:	8bca                	mv	s7,s2
      state = 0;
    102c:	4981                	li	s3,0
        i += 2;
    102e:	bde5                	j	f26 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    1030:	008b8913          	addi	s2,s7,8
    1034:	4685                	li	a3,1
    1036:	4629                	li	a2,10
    1038:	000ba583          	lw	a1,0(s7)
    103c:	855a                	mv	a0,s6
    103e:	df7ff0ef          	jal	e34 <printint>
        i += 2;
    1042:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
    1044:	8bca                	mv	s7,s2
      state = 0;
    1046:	4981                	li	s3,0
        i += 2;
    1048:	bdf9                	j	f26 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
    104a:	008b8913          	addi	s2,s7,8
    104e:	4681                	li	a3,0
    1050:	4629                	li	a2,10
    1052:	000ba583          	lw	a1,0(s7)
    1056:	855a                	mv	a0,s6
    1058:	dddff0ef          	jal	e34 <printint>
    105c:	8bca                	mv	s7,s2
      state = 0;
    105e:	4981                	li	s3,0
    1060:	b5d9                	j	f26 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1062:	008b8913          	addi	s2,s7,8
    1066:	4681                	li	a3,0
    1068:	4629                	li	a2,10
    106a:	000ba583          	lw	a1,0(s7)
    106e:	855a                	mv	a0,s6
    1070:	dc5ff0ef          	jal	e34 <printint>
        i += 1;
    1074:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
    1076:	8bca                	mv	s7,s2
      state = 0;
    1078:	4981                	li	s3,0
        i += 1;
    107a:	b575                	j	f26 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    107c:	008b8913          	addi	s2,s7,8
    1080:	4681                	li	a3,0
    1082:	4629                	li	a2,10
    1084:	000ba583          	lw	a1,0(s7)
    1088:	855a                	mv	a0,s6
    108a:	dabff0ef          	jal	e34 <printint>
        i += 2;
    108e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
    1090:	8bca                	mv	s7,s2
      state = 0;
    1092:	4981                	li	s3,0
        i += 2;
    1094:	bd49                	j	f26 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
    1096:	008b8913          	addi	s2,s7,8
    109a:	4681                	li	a3,0
    109c:	4641                	li	a2,16
    109e:	000ba583          	lw	a1,0(s7)
    10a2:	855a                	mv	a0,s6
    10a4:	d91ff0ef          	jal	e34 <printint>
    10a8:	8bca                	mv	s7,s2
      state = 0;
    10aa:	4981                	li	s3,0
    10ac:	bdad                	j	f26 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
    10ae:	008b8913          	addi	s2,s7,8
    10b2:	4681                	li	a3,0
    10b4:	4641                	li	a2,16
    10b6:	000ba583          	lw	a1,0(s7)
    10ba:	855a                	mv	a0,s6
    10bc:	d79ff0ef          	jal	e34 <printint>
        i += 1;
    10c0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
    10c2:	8bca                	mv	s7,s2
      state = 0;
    10c4:	4981                	li	s3,0
        i += 1;
    10c6:	b585                	j	f26 <vprintf+0x4a>
    10c8:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
    10ca:	008b8d13          	addi	s10,s7,8
    10ce:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    10d2:	03000593          	li	a1,48
    10d6:	855a                	mv	a0,s6
    10d8:	d3fff0ef          	jal	e16 <putc>
  putc(fd, 'x');
    10dc:	07800593          	li	a1,120
    10e0:	855a                	mv	a0,s6
    10e2:	d35ff0ef          	jal	e16 <putc>
    10e6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    10e8:	00000b97          	auipc	s7,0x0
    10ec:	3f0b8b93          	addi	s7,s7,1008 # 14d8 <digits>
    10f0:	03c9d793          	srli	a5,s3,0x3c
    10f4:	97de                	add	a5,a5,s7
    10f6:	0007c583          	lbu	a1,0(a5)
    10fa:	855a                	mv	a0,s6
    10fc:	d1bff0ef          	jal	e16 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1100:	0992                	slli	s3,s3,0x4
    1102:	397d                	addiw	s2,s2,-1
    1104:	fe0916e3          	bnez	s2,10f0 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
    1108:	8bea                	mv	s7,s10
      state = 0;
    110a:	4981                	li	s3,0
    110c:	6d02                	ld	s10,0(sp)
    110e:	bd21                	j	f26 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
    1110:	008b8993          	addi	s3,s7,8
    1114:	000bb903          	ld	s2,0(s7)
    1118:	00090f63          	beqz	s2,1136 <vprintf+0x25a>
        for(; *s; s++)
    111c:	00094583          	lbu	a1,0(s2)
    1120:	c195                	beqz	a1,1144 <vprintf+0x268>
          putc(fd, *s);
    1122:	855a                	mv	a0,s6
    1124:	cf3ff0ef          	jal	e16 <putc>
        for(; *s; s++)
    1128:	0905                	addi	s2,s2,1
    112a:	00094583          	lbu	a1,0(s2)
    112e:	f9f5                	bnez	a1,1122 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
    1130:	8bce                	mv	s7,s3
      state = 0;
    1132:	4981                	li	s3,0
    1134:	bbcd                	j	f26 <vprintf+0x4a>
          s = "(null)";
    1136:	00000917          	auipc	s2,0x0
    113a:	36a90913          	addi	s2,s2,874 # 14a0 <malloc+0x25e>
        for(; *s; s++)
    113e:	02800593          	li	a1,40
    1142:	b7c5                	j	1122 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
    1144:	8bce                	mv	s7,s3
      state = 0;
    1146:	4981                	li	s3,0
    1148:	bbf9                	j	f26 <vprintf+0x4a>
    114a:	64a6                	ld	s1,72(sp)
    114c:	79e2                	ld	s3,56(sp)
    114e:	7a42                	ld	s4,48(sp)
    1150:	7aa2                	ld	s5,40(sp)
    1152:	7b02                	ld	s6,32(sp)
    1154:	6be2                	ld	s7,24(sp)
    1156:	6c42                	ld	s8,16(sp)
    1158:	6ca2                	ld	s9,8(sp)
    }
  }
}
    115a:	60e6                	ld	ra,88(sp)
    115c:	6446                	ld	s0,80(sp)
    115e:	6906                	ld	s2,64(sp)
    1160:	6125                	addi	sp,sp,96
    1162:	8082                	ret

0000000000001164 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1164:	715d                	addi	sp,sp,-80
    1166:	ec06                	sd	ra,24(sp)
    1168:	e822                	sd	s0,16(sp)
    116a:	1000                	addi	s0,sp,32
    116c:	e010                	sd	a2,0(s0)
    116e:	e414                	sd	a3,8(s0)
    1170:	e818                	sd	a4,16(s0)
    1172:	ec1c                	sd	a5,24(s0)
    1174:	03043023          	sd	a6,32(s0)
    1178:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    117c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1180:	8622                	mv	a2,s0
    1182:	d5bff0ef          	jal	edc <vprintf>
}
    1186:	60e2                	ld	ra,24(sp)
    1188:	6442                	ld	s0,16(sp)
    118a:	6161                	addi	sp,sp,80
    118c:	8082                	ret

000000000000118e <printf>:

void
printf(const char *fmt, ...)
{
    118e:	711d                	addi	sp,sp,-96
    1190:	ec06                	sd	ra,24(sp)
    1192:	e822                	sd	s0,16(sp)
    1194:	1000                	addi	s0,sp,32
    1196:	e40c                	sd	a1,8(s0)
    1198:	e810                	sd	a2,16(s0)
    119a:	ec14                	sd	a3,24(s0)
    119c:	f018                	sd	a4,32(s0)
    119e:	f41c                	sd	a5,40(s0)
    11a0:	03043823          	sd	a6,48(s0)
    11a4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    11a8:	00840613          	addi	a2,s0,8
    11ac:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    11b0:	85aa                	mv	a1,a0
    11b2:	4505                	li	a0,1
    11b4:	d29ff0ef          	jal	edc <vprintf>
}
    11b8:	60e2                	ld	ra,24(sp)
    11ba:	6442                	ld	s0,16(sp)
    11bc:	6125                	addi	sp,sp,96
    11be:	8082                	ret

00000000000011c0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    11c0:	1141                	addi	sp,sp,-16
    11c2:	e422                	sd	s0,8(sp)
    11c4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    11c6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    11ca:	00001797          	auipc	a5,0x1
    11ce:	e467b783          	ld	a5,-442(a5) # 2010 <freep>
    11d2:	a02d                	j	11fc <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    11d4:	4618                	lw	a4,8(a2)
    11d6:	9f2d                	addw	a4,a4,a1
    11d8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    11dc:	6398                	ld	a4,0(a5)
    11de:	6310                	ld	a2,0(a4)
    11e0:	a83d                	j	121e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    11e2:	ff852703          	lw	a4,-8(a0)
    11e6:	9f31                	addw	a4,a4,a2
    11e8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    11ea:	ff053683          	ld	a3,-16(a0)
    11ee:	a091                	j	1232 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    11f0:	6398                	ld	a4,0(a5)
    11f2:	00e7e463          	bltu	a5,a4,11fa <free+0x3a>
    11f6:	00e6ea63          	bltu	a3,a4,120a <free+0x4a>
{
    11fa:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    11fc:	fed7fae3          	bgeu	a5,a3,11f0 <free+0x30>
    1200:	6398                	ld	a4,0(a5)
    1202:	00e6e463          	bltu	a3,a4,120a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1206:	fee7eae3          	bltu	a5,a4,11fa <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    120a:	ff852583          	lw	a1,-8(a0)
    120e:	6390                	ld	a2,0(a5)
    1210:	02059813          	slli	a6,a1,0x20
    1214:	01c85713          	srli	a4,a6,0x1c
    1218:	9736                	add	a4,a4,a3
    121a:	fae60de3          	beq	a2,a4,11d4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    121e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1222:	4790                	lw	a2,8(a5)
    1224:	02061593          	slli	a1,a2,0x20
    1228:	01c5d713          	srli	a4,a1,0x1c
    122c:	973e                	add	a4,a4,a5
    122e:	fae68ae3          	beq	a3,a4,11e2 <free+0x22>
    p->s.ptr = bp->s.ptr;
    1232:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    1234:	00001717          	auipc	a4,0x1
    1238:	dcf73e23          	sd	a5,-548(a4) # 2010 <freep>
}
    123c:	6422                	ld	s0,8(sp)
    123e:	0141                	addi	sp,sp,16
    1240:	8082                	ret

0000000000001242 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1242:	7139                	addi	sp,sp,-64
    1244:	fc06                	sd	ra,56(sp)
    1246:	f822                	sd	s0,48(sp)
    1248:	f426                	sd	s1,40(sp)
    124a:	ec4e                	sd	s3,24(sp)
    124c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    124e:	02051493          	slli	s1,a0,0x20
    1252:	9081                	srli	s1,s1,0x20
    1254:	04bd                	addi	s1,s1,15
    1256:	8091                	srli	s1,s1,0x4
    1258:	0014899b          	addiw	s3,s1,1
    125c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    125e:	00001517          	auipc	a0,0x1
    1262:	db253503          	ld	a0,-590(a0) # 2010 <freep>
    1266:	c915                	beqz	a0,129a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1268:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    126a:	4798                	lw	a4,8(a5)
    126c:	08977a63          	bgeu	a4,s1,1300 <malloc+0xbe>
    1270:	f04a                	sd	s2,32(sp)
    1272:	e852                	sd	s4,16(sp)
    1274:	e456                	sd	s5,8(sp)
    1276:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    1278:	8a4e                	mv	s4,s3
    127a:	0009871b          	sext.w	a4,s3
    127e:	6685                	lui	a3,0x1
    1280:	00d77363          	bgeu	a4,a3,1286 <malloc+0x44>
    1284:	6a05                	lui	s4,0x1
    1286:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    128a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    128e:	00001917          	auipc	s2,0x1
    1292:	d8290913          	addi	s2,s2,-638 # 2010 <freep>
  if(p == (char*)-1)
    1296:	5afd                	li	s5,-1
    1298:	a081                	j	12d8 <malloc+0x96>
    129a:	f04a                	sd	s2,32(sp)
    129c:	e852                	sd	s4,16(sp)
    129e:	e456                	sd	s5,8(sp)
    12a0:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    12a2:	00001797          	auipc	a5,0x1
    12a6:	de678793          	addi	a5,a5,-538 # 2088 <base>
    12aa:	00001717          	auipc	a4,0x1
    12ae:	d6f73323          	sd	a5,-666(a4) # 2010 <freep>
    12b2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    12b4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    12b8:	b7c1                	j	1278 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    12ba:	6398                	ld	a4,0(a5)
    12bc:	e118                	sd	a4,0(a0)
    12be:	a8a9                	j	1318 <malloc+0xd6>
  hp->s.size = nu;
    12c0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    12c4:	0541                	addi	a0,a0,16
    12c6:	efbff0ef          	jal	11c0 <free>
  return freep;
    12ca:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    12ce:	c12d                	beqz	a0,1330 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    12d0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    12d2:	4798                	lw	a4,8(a5)
    12d4:	02977263          	bgeu	a4,s1,12f8 <malloc+0xb6>
    if(p == freep)
    12d8:	00093703          	ld	a4,0(s2)
    12dc:	853e                	mv	a0,a5
    12de:	fef719e3          	bne	a4,a5,12d0 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    12e2:	8552                	mv	a0,s4
    12e4:	b1bff0ef          	jal	dfe <sbrk>
  if(p == (char*)-1)
    12e8:	fd551ce3          	bne	a0,s5,12c0 <malloc+0x7e>
        return 0;
    12ec:	4501                	li	a0,0
    12ee:	7902                	ld	s2,32(sp)
    12f0:	6a42                	ld	s4,16(sp)
    12f2:	6aa2                	ld	s5,8(sp)
    12f4:	6b02                	ld	s6,0(sp)
    12f6:	a03d                	j	1324 <malloc+0xe2>
    12f8:	7902                	ld	s2,32(sp)
    12fa:	6a42                	ld	s4,16(sp)
    12fc:	6aa2                	ld	s5,8(sp)
    12fe:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    1300:	fae48de3          	beq	s1,a4,12ba <malloc+0x78>
        p->s.size -= nunits;
    1304:	4137073b          	subw	a4,a4,s3
    1308:	c798                	sw	a4,8(a5)
        p += p->s.size;
    130a:	02071693          	slli	a3,a4,0x20
    130e:	01c6d713          	srli	a4,a3,0x1c
    1312:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1314:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1318:	00001717          	auipc	a4,0x1
    131c:	cea73c23          	sd	a0,-776(a4) # 2010 <freep>
      return (void*)(p + 1);
    1320:	01078513          	addi	a0,a5,16
  }
}
    1324:	70e2                	ld	ra,56(sp)
    1326:	7442                	ld	s0,48(sp)
    1328:	74a2                	ld	s1,40(sp)
    132a:	69e2                	ld	s3,24(sp)
    132c:	6121                	addi	sp,sp,64
    132e:	8082                	ret
    1330:	7902                	ld	s2,32(sp)
    1332:	6a42                	ld	s4,16(sp)
    1334:	6aa2                	ld	s5,8(sp)
    1336:	6b02                	ld	s6,0(sp)
    1338:	b7f5                	j	1324 <malloc+0xe2>
