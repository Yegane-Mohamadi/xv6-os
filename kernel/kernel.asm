
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	92010113          	addi	sp,sp,-1760 # 80007920 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb9af>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	de278793          	addi	a5,a5,-542 # 80000e62 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	addi	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	f84a                	sd	s2,48(sp)
    800000d8:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000da:	04c05263          	blez	a2,8000011e <consolewrite+0x4e>
    800000de:	fc26                	sd	s1,56(sp)
    800000e0:	f44e                	sd	s3,40(sp)
    800000e2:	f052                	sd	s4,32(sp)
    800000e4:	ec56                	sd	s5,24(sp)
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	addi	a0,s0,-65
    800000fa:	14e020ef          	jal	80002248 <either_copyin>
    800000fe:	03550263          	beq	a0,s5,80000122 <consolewrite+0x52>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	035000ef          	jal	8000093a <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addiw	s2,s2,1
    8000010c:	0485                	addi	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
    80000112:	894e                	mv	s2,s3
    80000114:	74e2                	ld	s1,56(sp)
    80000116:	79a2                	ld	s3,40(sp)
    80000118:	7a02                	ld	s4,32(sp)
    8000011a:	6ae2                	ld	s5,24(sp)
    8000011c:	a039                	j	8000012a <consolewrite+0x5a>
    8000011e:	4901                	li	s2,0
    80000120:	a029                	j	8000012a <consolewrite+0x5a>
    80000122:	74e2                	ld	s1,56(sp)
    80000124:	79a2                	ld	s3,40(sp)
    80000126:	7a02                	ld	s4,32(sp)
    80000128:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    8000012a:	854a                	mv	a0,s2
    8000012c:	60a6                	ld	ra,72(sp)
    8000012e:	6406                	ld	s0,64(sp)
    80000130:	7942                	ld	s2,48(sp)
    80000132:	6161                	addi	sp,sp,80
    80000134:	8082                	ret

0000000080000136 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000136:	711d                	addi	sp,sp,-96
    80000138:	ec86                	sd	ra,88(sp)
    8000013a:	e8a2                	sd	s0,80(sp)
    8000013c:	e4a6                	sd	s1,72(sp)
    8000013e:	e0ca                	sd	s2,64(sp)
    80000140:	fc4e                	sd	s3,56(sp)
    80000142:	f852                	sd	s4,48(sp)
    80000144:	f456                	sd	s5,40(sp)
    80000146:	f05a                	sd	s6,32(sp)
    80000148:	1080                	addi	s0,sp,96
    8000014a:	8aaa                	mv	s5,a0
    8000014c:	8a2e                	mv	s4,a1
    8000014e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000150:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000154:	0000f517          	auipc	a0,0xf
    80000158:	7cc50513          	addi	a0,a0,1996 # 8000f920 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	0000f497          	auipc	s1,0xf
    80000164:	7c048493          	addi	s1,s1,1984 # 8000f920 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00010917          	auipc	s2,0x10
    8000016c:	85090913          	addi	s2,s2,-1968 # 8000f9b8 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	754010ef          	jal	800018d4 <myproc>
    80000184:	757010ef          	jal	800020da <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	515010ef          	jal	80001ea2 <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	0000f717          	auipc	a4,0xf
    800001a4:	78070713          	addi	a4,a4,1920 # 8000f920 <cons>
    800001a8:	0017869b          	addiw	a3,a5,1
    800001ac:	08d72c23          	sw	a3,152(a4)
    800001b0:	07f7f693          	andi	a3,a5,127
    800001b4:	9736                	add	a4,a4,a3
    800001b6:	01874703          	lbu	a4,24(a4)
    800001ba:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001be:	4691                	li	a3,4
    800001c0:	04db8663          	beq	s7,a3,8000020c <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001c4:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c8:	4685                	li	a3,1
    800001ca:	faf40613          	addi	a2,s0,-81
    800001ce:	85d2                	mv	a1,s4
    800001d0:	8556                	mv	a0,s5
    800001d2:	02c020ef          	jal	800021fe <either_copyout>
    800001d6:	57fd                	li	a5,-1
    800001d8:	04f50863          	beq	a0,a5,80000228 <consoleread+0xf2>
      break;

    dst++;
    800001dc:	0a05                	addi	s4,s4,1
    --n;
    800001de:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001e0:	47a9                	li	a5,10
    800001e2:	04fb8d63          	beq	s7,a5,8000023c <consoleread+0x106>
    800001e6:	6be2                	ld	s7,24(sp)
    800001e8:	b761                	j	80000170 <consoleread+0x3a>
        release(&cons.lock);
    800001ea:	0000f517          	auipc	a0,0xf
    800001ee:	73650513          	addi	a0,a0,1846 # 8000f920 <cons>
    800001f2:	29b000ef          	jal	80000c8c <release>
        return -1;
    800001f6:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    800001f8:	60e6                	ld	ra,88(sp)
    800001fa:	6446                	ld	s0,80(sp)
    800001fc:	64a6                	ld	s1,72(sp)
    800001fe:	6906                	ld	s2,64(sp)
    80000200:	79e2                	ld	s3,56(sp)
    80000202:	7a42                	ld	s4,48(sp)
    80000204:	7aa2                	ld	s5,40(sp)
    80000206:	7b02                	ld	s6,32(sp)
    80000208:	6125                	addi	sp,sp,96
    8000020a:	8082                	ret
      if(n < target){
    8000020c:	0009871b          	sext.w	a4,s3
    80000210:	01677a63          	bgeu	a4,s6,80000224 <consoleread+0xee>
        cons.r--;
    80000214:	0000f717          	auipc	a4,0xf
    80000218:	7af72223          	sw	a5,1956(a4) # 8000f9b8 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	0000f517          	auipc	a0,0xf
    8000022e:	6f650513          	addi	a0,a0,1782 # 8000f920 <cons>
    80000232:	25b000ef          	jal	80000c8c <release>
  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	bf7d                	j	800001f8 <consoleread+0xc2>
    8000023c:	6be2                	ld	s7,24(sp)
    8000023e:	b7f5                	j	8000022a <consoleread+0xf4>

0000000080000240 <consputc>:
{
    80000240:	1141                	addi	sp,sp,-16
    80000242:	e406                	sd	ra,8(sp)
    80000244:	e022                	sd	s0,0(sp)
    80000246:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000248:	10000793          	li	a5,256
    8000024c:	00f50863          	beq	a0,a5,8000025c <consputc+0x1c>
    uartputc_sync(c);
    80000250:	604000ef          	jal	80000854 <uartputc_sync>
}
    80000254:	60a2                	ld	ra,8(sp)
    80000256:	6402                	ld	s0,0(sp)
    80000258:	0141                	addi	sp,sp,16
    8000025a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000025c:	4521                	li	a0,8
    8000025e:	5f6000ef          	jal	80000854 <uartputc_sync>
    80000262:	02000513          	li	a0,32
    80000266:	5ee000ef          	jal	80000854 <uartputc_sync>
    8000026a:	4521                	li	a0,8
    8000026c:	5e8000ef          	jal	80000854 <uartputc_sync>
    80000270:	b7d5                	j	80000254 <consputc+0x14>

0000000080000272 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000272:	1101                	addi	sp,sp,-32
    80000274:	ec06                	sd	ra,24(sp)
    80000276:	e822                	sd	s0,16(sp)
    80000278:	e426                	sd	s1,8(sp)
    8000027a:	1000                	addi	s0,sp,32
    8000027c:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000027e:	0000f517          	auipc	a0,0xf
    80000282:	6a250513          	addi	a0,a0,1698 # 8000f920 <cons>
    80000286:	16f000ef          	jal	80000bf4 <acquire>

  switch(c){
    8000028a:	47d5                	li	a5,21
    8000028c:	08f48f63          	beq	s1,a5,8000032a <consoleintr+0xb8>
    80000290:	0297c563          	blt	a5,s1,800002ba <consoleintr+0x48>
    80000294:	47a1                	li	a5,8
    80000296:	0ef48463          	beq	s1,a5,8000037e <consoleintr+0x10c>
    8000029a:	47c1                	li	a5,16
    8000029c:	10f49563          	bne	s1,a5,800003a6 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002a0:	7f3010ef          	jal	80002292 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	0000f517          	auipc	a0,0xf
    800002a8:	67c50513          	addi	a0,a0,1660 # 8000f920 <cons>
    800002ac:	1e1000ef          	jal	80000c8c <release>
}
    800002b0:	60e2                	ld	ra,24(sp)
    800002b2:	6442                	ld	s0,16(sp)
    800002b4:	64a2                	ld	s1,8(sp)
    800002b6:	6105                	addi	sp,sp,32
    800002b8:	8082                	ret
  switch(c){
    800002ba:	07f00793          	li	a5,127
    800002be:	0cf48063          	beq	s1,a5,8000037e <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002c2:	0000f717          	auipc	a4,0xf
    800002c6:	65e70713          	addi	a4,a4,1630 # 8000f920 <cons>
    800002ca:	0a072783          	lw	a5,160(a4)
    800002ce:	09872703          	lw	a4,152(a4)
    800002d2:	9f99                	subw	a5,a5,a4
    800002d4:	07f00713          	li	a4,127
    800002d8:	fcf766e3          	bltu	a4,a5,800002a4 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002dc:	47b5                	li	a5,13
    800002de:	0cf48763          	beq	s1,a5,800003ac <consoleintr+0x13a>
      consputc(c);
    800002e2:	8526                	mv	a0,s1
    800002e4:	f5dff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002e8:	0000f797          	auipc	a5,0xf
    800002ec:	63878793          	addi	a5,a5,1592 # 8000f920 <cons>
    800002f0:	0a07a683          	lw	a3,160(a5)
    800002f4:	0016871b          	addiw	a4,a3,1
    800002f8:	0007061b          	sext.w	a2,a4
    800002fc:	0ae7a023          	sw	a4,160(a5)
    80000300:	07f6f693          	andi	a3,a3,127
    80000304:	97b6                	add	a5,a5,a3
    80000306:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000030a:	47a9                	li	a5,10
    8000030c:	0cf48563          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000310:	4791                	li	a5,4
    80000312:	0cf48263          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000316:	0000f797          	auipc	a5,0xf
    8000031a:	6a27a783          	lw	a5,1698(a5) # 8000f9b8 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	0000f717          	auipc	a4,0xf
    80000330:	5f470713          	addi	a4,a4,1524 # 8000f920 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	0000f497          	auipc	s1,0xf
    80000340:	5e448493          	addi	s1,s1,1508 # 8000f920 <cons>
    while(cons.e != cons.w &&
    80000344:	4929                	li	s2,10
    80000346:	02f70863          	beq	a4,a5,80000376 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	37fd                	addiw	a5,a5,-1
    8000034c:	07f7f713          	andi	a4,a5,127
    80000350:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000352:	01874703          	lbu	a4,24(a4)
    80000356:	03270263          	beq	a4,s2,8000037a <consoleintr+0x108>
      cons.e--;
    8000035a:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000035e:	10000513          	li	a0,256
    80000362:	edfff0ef          	jal	80000240 <consputc>
    while(cons.e != cons.w &&
    80000366:	0a04a783          	lw	a5,160(s1)
    8000036a:	09c4a703          	lw	a4,156(s1)
    8000036e:	fcf71ee3          	bne	a4,a5,8000034a <consoleintr+0xd8>
    80000372:	6902                	ld	s2,0(sp)
    80000374:	bf05                	j	800002a4 <consoleintr+0x32>
    80000376:	6902                	ld	s2,0(sp)
    80000378:	b735                	j	800002a4 <consoleintr+0x32>
    8000037a:	6902                	ld	s2,0(sp)
    8000037c:	b725                	j	800002a4 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000037e:	0000f717          	auipc	a4,0xf
    80000382:	5a270713          	addi	a4,a4,1442 # 8000f920 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	62f72623          	sw	a5,1580(a4) # 8000f9c0 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea1ff0ef          	jal	80000240 <consputc>
    800003a4:	b701                	j	800002a4 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	ee048fe3          	beqz	s1,800002a4 <consoleintr+0x32>
    800003aa:	bf21                	j	800002c2 <consoleintr+0x50>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e93ff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	0000f797          	auipc	a5,0xf
    800003b6:	56e78793          	addi	a5,a5,1390 # 8000f920 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	0000f797          	auipc	a5,0xf
    800003da:	5ec7a323          	sw	a2,1510(a5) # 8000f9bc <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	5da50513          	addi	a0,a0,1498 # 8000f9b8 <cons+0x98>
    800003e6:	309010ef          	jal	80001eee <wakeup>
    800003ea:	bd6d                	j	800002a4 <consoleintr+0x32>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c0c58593          	addi	a1,a1,-1012 # 80007000 <etext>
    800003fc:	0000f517          	auipc	a0,0xf
    80000400:	52450513          	addi	a0,a0,1316 # 8000f920 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00022797          	auipc	a5,0x22
    80000410:	8ac78793          	addi	a5,a5,-1876 # 80021cb8 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d2270713          	addi	a4,a4,-734 # 80000136 <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7179                	addi	sp,sp,-48
    80000432:	f406                	sd	ra,40(sp)
    80000434:	f022                	sd	s0,32(sp)
    80000436:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000438:	c219                	beqz	a2,8000043e <printint+0xe>
    8000043a:	08054063          	bltz	a0,800004ba <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000043e:	4881                	li	a7,0
    80000440:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000444:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000446:	00007617          	auipc	a2,0x7
    8000044a:	32a60613          	addi	a2,a2,810 # 80007770 <digits>
    8000044e:	883e                	mv	a6,a5
    80000450:	2785                	addiw	a5,a5,1
    80000452:	02b57733          	remu	a4,a0,a1
    80000456:	9732                	add	a4,a4,a2
    80000458:	00074703          	lbu	a4,0(a4)
    8000045c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000460:	872a                	mv	a4,a0
    80000462:	02b55533          	divu	a0,a0,a1
    80000466:	0685                	addi	a3,a3,1
    80000468:	feb773e3          	bgeu	a4,a1,8000044e <printint+0x1e>

  if(sign)
    8000046c:	00088a63          	beqz	a7,80000480 <printint+0x50>
    buf[i++] = '-';
    80000470:	1781                	addi	a5,a5,-32
    80000472:	97a2                	add	a5,a5,s0
    80000474:	02d00713          	li	a4,45
    80000478:	fee78823          	sb	a4,-16(a5)
    8000047c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000480:	02f05963          	blez	a5,800004b2 <printint+0x82>
    80000484:	ec26                	sd	s1,24(sp)
    80000486:	e84a                	sd	s2,16(sp)
    80000488:	fd040713          	addi	a4,s0,-48
    8000048c:	00f704b3          	add	s1,a4,a5
    80000490:	fff70913          	addi	s2,a4,-1
    80000494:	993e                	add	s2,s2,a5
    80000496:	37fd                	addiw	a5,a5,-1
    80000498:	1782                	slli	a5,a5,0x20
    8000049a:	9381                	srli	a5,a5,0x20
    8000049c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a0:	fff4c503          	lbu	a0,-1(s1)
    800004a4:	d9dff0ef          	jal	80000240 <consputc>
  while(--i >= 0)
    800004a8:	14fd                	addi	s1,s1,-1
    800004aa:	ff249be3          	bne	s1,s2,800004a0 <printint+0x70>
    800004ae:	64e2                	ld	s1,24(sp)
    800004b0:	6942                	ld	s2,16(sp)
}
    800004b2:	70a2                	ld	ra,40(sp)
    800004b4:	7402                	ld	s0,32(sp)
    800004b6:	6145                	addi	sp,sp,48
    800004b8:	8082                	ret
    x = -xx;
    800004ba:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004be:	4885                	li	a7,1
    x = -xx;
    800004c0:	b741                	j	80000440 <printint+0x10>

00000000800004c2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c2:	7155                	addi	sp,sp,-208
    800004c4:	e506                	sd	ra,136(sp)
    800004c6:	e122                	sd	s0,128(sp)
    800004c8:	f0d2                	sd	s4,96(sp)
    800004ca:	0900                	addi	s0,sp,144
    800004cc:	8a2a                	mv	s4,a0
    800004ce:	e40c                	sd	a1,8(s0)
    800004d0:	e810                	sd	a2,16(s0)
    800004d2:	ec14                	sd	a3,24(s0)
    800004d4:	f018                	sd	a4,32(s0)
    800004d6:	f41c                	sd	a5,40(s0)
    800004d8:	03043823          	sd	a6,48(s0)
    800004dc:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004e0:	0000f797          	auipc	a5,0xf
    800004e4:	5007a783          	lw	a5,1280(a5) # 8000f9e0 <pr+0x18>
    800004e8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004ec:	e3a1                	bnez	a5,8000052c <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004ee:	00840793          	addi	a5,s0,8
    800004f2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800004f6:	00054503          	lbu	a0,0(a0)
    800004fa:	26050763          	beqz	a0,80000768 <printf+0x2a6>
    800004fe:	fca6                	sd	s1,120(sp)
    80000500:	f8ca                	sd	s2,112(sp)
    80000502:	f4ce                	sd	s3,104(sp)
    80000504:	ecd6                	sd	s5,88(sp)
    80000506:	e8da                	sd	s6,80(sp)
    80000508:	e0e2                	sd	s8,64(sp)
    8000050a:	fc66                	sd	s9,56(sp)
    8000050c:	f86a                	sd	s10,48(sp)
    8000050e:	f46e                	sd	s11,40(sp)
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    8000052a:	a815                	j	8000055e <printf+0x9c>
    acquire(&pr.lock);
    8000052c:	0000f517          	auipc	a0,0xf
    80000530:	49c50513          	addi	a0,a0,1180 # 8000f9c8 <pr>
    80000534:	6c0000ef          	jal	80000bf4 <acquire>
  va_start(ap, fmt);
    80000538:	00840793          	addi	a5,s0,8
    8000053c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000540:	000a4503          	lbu	a0,0(s4)
    80000544:	fd4d                	bnez	a0,800004fe <printf+0x3c>
    80000546:	a481                	j	80000786 <printf+0x2c4>
      consputc(cx);
    80000548:	cf9ff0ef          	jal	80000240 <consputc>
      continue;
    8000054c:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054e:	0014899b          	addiw	s3,s1,1
    80000552:	013a07b3          	add	a5,s4,s3
    80000556:	0007c503          	lbu	a0,0(a5)
    8000055a:	1e050b63          	beqz	a0,80000750 <printf+0x28e>
    if(cx != '%'){
    8000055e:	ff5515e3          	bne	a0,s5,80000548 <printf+0x86>
    i++;
    80000562:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000566:	009a07b3          	add	a5,s4,s1
    8000056a:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000056e:	1e090163          	beqz	s2,80000750 <printf+0x28e>
    80000572:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000576:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000578:	c789                	beqz	a5,80000582 <printf+0xc0>
    8000057a:	009a0733          	add	a4,s4,s1
    8000057e:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000582:	03690763          	beq	s2,s6,800005b0 <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80000586:	05890163          	beq	s2,s8,800005c8 <printf+0x106>
    } else if(c0 == 'u'){
    8000058a:	0d990b63          	beq	s2,s9,80000660 <printf+0x19e>
    } else if(c0 == 'x'){
    8000058e:	13a90163          	beq	s2,s10,800006b0 <printf+0x1ee>
    } else if(c0 == 'p'){
    80000592:	13b90b63          	beq	s2,s11,800006c8 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    80000596:	07300793          	li	a5,115
    8000059a:	16f90a63          	beq	s2,a5,8000070e <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000059e:	1b590463          	beq	s2,s5,80000746 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005a2:	8556                	mv	a0,s5
    800005a4:	c9dff0ef          	jal	80000240 <consputc>
      consputc(c0);
    800005a8:	854a                	mv	a0,s2
    800005aa:	c97ff0ef          	jal	80000240 <consputc>
    800005ae:	b745                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005b0:	f8843783          	ld	a5,-120(s0)
    800005b4:	00878713          	addi	a4,a5,8
    800005b8:	f8e43423          	sd	a4,-120(s0)
    800005bc:	4605                	li	a2,1
    800005be:	45a9                	li	a1,10
    800005c0:	4388                	lw	a0,0(a5)
    800005c2:	e6fff0ef          	jal	80000430 <printint>
    800005c6:	b761                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c8:	03678663          	beq	a5,s6,800005f4 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005cc:	05878263          	beq	a5,s8,80000610 <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005d0:	0b978463          	beq	a5,s9,80000678 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	fda797e3          	bne	a5,s10,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800005d8:	f8843783          	ld	a5,-120(s0)
    800005dc:	00878713          	addi	a4,a5,8
    800005e0:	f8e43423          	sd	a4,-120(s0)
    800005e4:	4601                	li	a2,0
    800005e6:	45c1                	li	a1,16
    800005e8:	6388                	ld	a0,0(a5)
    800005ea:	e47ff0ef          	jal	80000430 <printint>
      i += 1;
    800005ee:	0029849b          	addiw	s1,s3,2
    800005f2:	bfb1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005f4:	f8843783          	ld	a5,-120(s0)
    800005f8:	00878713          	addi	a4,a5,8
    800005fc:	f8e43423          	sd	a4,-120(s0)
    80000600:	4605                	li	a2,1
    80000602:	45a9                	li	a1,10
    80000604:	6388                	ld	a0,0(a5)
    80000606:	e2bff0ef          	jal	80000430 <printint>
      i += 1;
    8000060a:	0029849b          	addiw	s1,s3,2
    8000060e:	b781                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000610:	06400793          	li	a5,100
    80000614:	02f68863          	beq	a3,a5,80000644 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000618:	07500793          	li	a5,117
    8000061c:	06f68c63          	beq	a3,a5,80000694 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000620:	07800793          	li	a5,120
    80000624:	f6f69fe3          	bne	a3,a5,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	addi	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4601                	li	a2,0
    80000636:	45c1                	li	a1,16
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	df7ff0ef          	jal	80000430 <printint>
      i += 2;
    8000063e:	0039849b          	addiw	s1,s3,3
    80000642:	b731                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	45a9                	li	a1,10
    80000654:	6388                	ld	a0,0(a5)
    80000656:	ddbff0ef          	jal	80000430 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bdc5                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	4388                	lw	a0,0(a5)
    80000672:	dbfff0ef          	jal	80000430 <printint>
    80000676:	bde1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4601                	li	a2,0
    80000686:	45a9                	li	a1,10
    80000688:	6388                	ld	a0,0(a5)
    8000068a:	da7ff0ef          	jal	80000430 <printint>
      i += 1;
    8000068e:	0029849b          	addiw	s1,s3,2
    80000692:	bd75                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	4601                	li	a2,0
    800006a2:	45a9                	li	a1,10
    800006a4:	6388                	ld	a0,0(a5)
    800006a6:	d8bff0ef          	jal	80000430 <printint>
      i += 2;
    800006aa:	0039849b          	addiw	s1,s3,3
    800006ae:	b545                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45c1                	li	a1,16
    800006c0:	4388                	lw	a0,0(a5)
    800006c2:	d6fff0ef          	jal	80000430 <printint>
    800006c6:	b561                	j	8000054e <printf+0x8c>
    800006c8:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006ca:	f8843783          	ld	a5,-120(s0)
    800006ce:	00878713          	addi	a4,a5,8
    800006d2:	f8e43423          	sd	a4,-120(s0)
    800006d6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006da:	03000513          	li	a0,48
    800006de:	b63ff0ef          	jal	80000240 <consputc>
  consputc('x');
    800006e2:	07800513          	li	a0,120
    800006e6:	b5bff0ef          	jal	80000240 <consputc>
    800006ea:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ec:	00007b97          	auipc	s7,0x7
    800006f0:	084b8b93          	addi	s7,s7,132 # 80007770 <digits>
    800006f4:	03c9d793          	srli	a5,s3,0x3c
    800006f8:	97de                	add	a5,a5,s7
    800006fa:	0007c503          	lbu	a0,0(a5)
    800006fe:	b43ff0ef          	jal	80000240 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0992                	slli	s3,s3,0x4
    80000704:	397d                	addiw	s2,s2,-1
    80000706:	fe0917e3          	bnez	s2,800006f4 <printf+0x232>
    8000070a:	6ba6                	ld	s7,72(sp)
    8000070c:	b589                	j	8000054e <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000070e:	f8843783          	ld	a5,-120(s0)
    80000712:	00878713          	addi	a4,a5,8
    80000716:	f8e43423          	sd	a4,-120(s0)
    8000071a:	0007b903          	ld	s2,0(a5)
    8000071e:	00090d63          	beqz	s2,80000738 <printf+0x276>
      for(; *s; s++)
    80000722:	00094503          	lbu	a0,0(s2)
    80000726:	e20504e3          	beqz	a0,8000054e <printf+0x8c>
        consputc(*s);
    8000072a:	b17ff0ef          	jal	80000240 <consputc>
      for(; *s; s++)
    8000072e:	0905                	addi	s2,s2,1
    80000730:	00094503          	lbu	a0,0(s2)
    80000734:	f97d                	bnez	a0,8000072a <printf+0x268>
    80000736:	bd21                	j	8000054e <printf+0x8c>
        s = "(null)";
    80000738:	00007917          	auipc	s2,0x7
    8000073c:	8d090913          	addi	s2,s2,-1840 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000740:	02800513          	li	a0,40
    80000744:	b7dd                	j	8000072a <printf+0x268>
      consputc('%');
    80000746:	02500513          	li	a0,37
    8000074a:	af7ff0ef          	jal	80000240 <consputc>
    8000074e:	b501                	j	8000054e <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    80000750:	f7843783          	ld	a5,-136(s0)
    80000754:	e385                	bnez	a5,80000774 <printf+0x2b2>
    80000756:	74e6                	ld	s1,120(sp)
    80000758:	7946                	ld	s2,112(sp)
    8000075a:	79a6                	ld	s3,104(sp)
    8000075c:	6ae6                	ld	s5,88(sp)
    8000075e:	6b46                	ld	s6,80(sp)
    80000760:	6c06                	ld	s8,64(sp)
    80000762:	7ce2                	ld	s9,56(sp)
    80000764:	7d42                	ld	s10,48(sp)
    80000766:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000768:	4501                	li	a0,0
    8000076a:	60aa                	ld	ra,136(sp)
    8000076c:	640a                	ld	s0,128(sp)
    8000076e:	7a06                	ld	s4,96(sp)
    80000770:	6169                	addi	sp,sp,208
    80000772:	8082                	ret
    80000774:	74e6                	ld	s1,120(sp)
    80000776:	7946                	ld	s2,112(sp)
    80000778:	79a6                	ld	s3,104(sp)
    8000077a:	6ae6                	ld	s5,88(sp)
    8000077c:	6b46                	ld	s6,80(sp)
    8000077e:	6c06                	ld	s8,64(sp)
    80000780:	7ce2                	ld	s9,56(sp)
    80000782:	7d42                	ld	s10,48(sp)
    80000784:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000786:	0000f517          	auipc	a0,0xf
    8000078a:	24250513          	addi	a0,a0,578 # 8000f9c8 <pr>
    8000078e:	4fe000ef          	jal	80000c8c <release>
    80000792:	bfd9                	j	80000768 <printf+0x2a6>

0000000080000794 <panic>:

void
panic(char *s)
{
    80000794:	1101                	addi	sp,sp,-32
    80000796:	ec06                	sd	ra,24(sp)
    80000798:	e822                	sd	s0,16(sp)
    8000079a:	e426                	sd	s1,8(sp)
    8000079c:	1000                	addi	s0,sp,32
    8000079e:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007a0:	0000f797          	auipc	a5,0xf
    800007a4:	2407a023          	sw	zero,576(a5) # 8000f9e0 <pr+0x18>
  printf("panic: ");
    800007a8:	00007517          	auipc	a0,0x7
    800007ac:	87050513          	addi	a0,a0,-1936 # 80007018 <etext+0x18>
    800007b0:	d13ff0ef          	jal	800004c2 <printf>
  printf("%s\n", s);
    800007b4:	85a6                	mv	a1,s1
    800007b6:	00007517          	auipc	a0,0x7
    800007ba:	86a50513          	addi	a0,a0,-1942 # 80007020 <etext+0x20>
    800007be:	d05ff0ef          	jal	800004c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007c2:	4785                	li	a5,1
    800007c4:	00007717          	auipc	a4,0x7
    800007c8:	10f72e23          	sw	a5,284(a4) # 800078e0 <panicked>
  for(;;)
    800007cc:	a001                	j	800007cc <panic+0x38>

00000000800007ce <printfinit>:
    ;
}

void
printfinit(void)
{
    800007ce:	1101                	addi	sp,sp,-32
    800007d0:	ec06                	sd	ra,24(sp)
    800007d2:	e822                	sd	s0,16(sp)
    800007d4:	e426                	sd	s1,8(sp)
    800007d6:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007d8:	0000f497          	auipc	s1,0xf
    800007dc:	1f048493          	addi	s1,s1,496 # 8000f9c8 <pr>
    800007e0:	00007597          	auipc	a1,0x7
    800007e4:	84858593          	addi	a1,a1,-1976 # 80007028 <etext+0x28>
    800007e8:	8526                	mv	a0,s1
    800007ea:	38a000ef          	jal	80000b74 <initlock>
  pr.locking = 1;
    800007ee:	4785                	li	a5,1
    800007f0:	cc9c                	sw	a5,24(s1)
}
    800007f2:	60e2                	ld	ra,24(sp)
    800007f4:	6442                	ld	s0,16(sp)
    800007f6:	64a2                	ld	s1,8(sp)
    800007f8:	6105                	addi	sp,sp,32
    800007fa:	8082                	ret

00000000800007fc <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007fc:	1141                	addi	sp,sp,-16
    800007fe:	e406                	sd	ra,8(sp)
    80000800:	e022                	sd	s0,0(sp)
    80000802:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000804:	100007b7          	lui	a5,0x10000
    80000808:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000080c:	10000737          	lui	a4,0x10000
    80000810:	f8000693          	li	a3,-128
    80000814:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000818:	468d                	li	a3,3
    8000081a:	10000637          	lui	a2,0x10000
    8000081e:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000822:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000826:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000082a:	10000737          	lui	a4,0x10000
    8000082e:	461d                	li	a2,7
    80000830:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000834:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000838:	00006597          	auipc	a1,0x6
    8000083c:	7f858593          	addi	a1,a1,2040 # 80007030 <etext+0x30>
    80000840:	0000f517          	auipc	a0,0xf
    80000844:	1a850513          	addi	a0,a0,424 # 8000f9e8 <uart_tx_lock>
    80000848:	32c000ef          	jal	80000b74 <initlock>
}
    8000084c:	60a2                	ld	ra,8(sp)
    8000084e:	6402                	ld	s0,0(sp)
    80000850:	0141                	addi	sp,sp,16
    80000852:	8082                	ret

0000000080000854 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000854:	1101                	addi	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	1000                	addi	s0,sp,32
    8000085e:	84aa                	mv	s1,a0
  push_off();
    80000860:	354000ef          	jal	80000bb4 <push_off>

  if(panicked){
    80000864:	00007797          	auipc	a5,0x7
    80000868:	07c7a783          	lw	a5,124(a5) # 800078e0 <panicked>
    8000086c:	e795                	bnez	a5,80000898 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000874:	00074783          	lbu	a5,0(a4)
    80000878:	0207f793          	andi	a5,a5,32
    8000087c:	dfe5                	beqz	a5,80000874 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000087e:	0ff4f513          	zext.b	a0,s1
    80000882:	100007b7          	lui	a5,0x10000
    80000886:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088a:	3ae000ef          	jal	80000c38 <pop_off>
}
    8000088e:	60e2                	ld	ra,24(sp)
    80000890:	6442                	ld	s0,16(sp)
    80000892:	64a2                	ld	s1,8(sp)
    80000894:	6105                	addi	sp,sp,32
    80000896:	8082                	ret
    for(;;)
    80000898:	a001                	j	80000898 <uartputc_sync+0x44>

000000008000089a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000089a:	00007797          	auipc	a5,0x7
    8000089e:	04e7b783          	ld	a5,78(a5) # 800078e8 <uart_tx_r>
    800008a2:	00007717          	auipc	a4,0x7
    800008a6:	04e73703          	ld	a4,78(a4) # 800078f0 <uart_tx_w>
    800008aa:	08f70263          	beq	a4,a5,8000092e <uartstart+0x94>
{
    800008ae:	7139                	addi	sp,sp,-64
    800008b0:	fc06                	sd	ra,56(sp)
    800008b2:	f822                	sd	s0,48(sp)
    800008b4:	f426                	sd	s1,40(sp)
    800008b6:	f04a                	sd	s2,32(sp)
    800008b8:	ec4e                	sd	s3,24(sp)
    800008ba:	e852                	sd	s4,16(sp)
    800008bc:	e456                	sd	s5,8(sp)
    800008be:	e05a                	sd	s6,0(sp)
    800008c0:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c2:	10000937          	lui	s2,0x10000
    800008c6:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008c8:	0000fa97          	auipc	s5,0xf
    800008cc:	120a8a93          	addi	s5,s5,288 # 8000f9e8 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	00007497          	auipc	s1,0x7
    800008d4:	01848493          	addi	s1,s1,24 # 800078e8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	00007997          	auipc	s3,0x7
    800008e0:	01498993          	addi	s3,s3,20 # 800078f0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008e4:	00094703          	lbu	a4,0(s2)
    800008e8:	02077713          	andi	a4,a4,32
    800008ec:	c71d                	beqz	a4,8000091a <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ee:	01f7f713          	andi	a4,a5,31
    800008f2:	9756                	add	a4,a4,s5
    800008f4:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008f8:	0785                	addi	a5,a5,1
    800008fa:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008fc:	8526                	mv	a0,s1
    800008fe:	5f0010ef          	jal	80001eee <wakeup>
    WriteReg(THR, c);
    80000902:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000906:	609c                	ld	a5,0(s1)
    80000908:	0009b703          	ld	a4,0(s3)
    8000090c:	fcf71ce3          	bne	a4,a5,800008e4 <uartstart+0x4a>
      ReadReg(ISR);
    80000910:	100007b7          	lui	a5,0x10000
    80000914:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000916:	0007c783          	lbu	a5,0(a5)
  }
}
    8000091a:	70e2                	ld	ra,56(sp)
    8000091c:	7442                	ld	s0,48(sp)
    8000091e:	74a2                	ld	s1,40(sp)
    80000920:	7902                	ld	s2,32(sp)
    80000922:	69e2                	ld	s3,24(sp)
    80000924:	6a42                	ld	s4,16(sp)
    80000926:	6aa2                	ld	s5,8(sp)
    80000928:	6b02                	ld	s6,0(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret
      ReadReg(ISR);
    8000092e:	100007b7          	lui	a5,0x10000
    80000932:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000934:	0007c783          	lbu	a5,0(a5)
      return;
    80000938:	8082                	ret

000000008000093a <uartputc>:
{
    8000093a:	7179                	addi	sp,sp,-48
    8000093c:	f406                	sd	ra,40(sp)
    8000093e:	f022                	sd	s0,32(sp)
    80000940:	ec26                	sd	s1,24(sp)
    80000942:	e84a                	sd	s2,16(sp)
    80000944:	e44e                	sd	s3,8(sp)
    80000946:	e052                	sd	s4,0(sp)
    80000948:	1800                	addi	s0,sp,48
    8000094a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000094c:	0000f517          	auipc	a0,0xf
    80000950:	09c50513          	addi	a0,a0,156 # 8000f9e8 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	00007797          	auipc	a5,0x7
    8000095c:	f887a783          	lw	a5,-120(a5) # 800078e0 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	00007717          	auipc	a4,0x7
    80000966:	f8e73703          	ld	a4,-114(a4) # 800078f0 <uart_tx_w>
    8000096a:	00007797          	auipc	a5,0x7
    8000096e:	f7e7b783          	ld	a5,-130(a5) # 800078e8 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	0000f997          	auipc	s3,0xf
    8000097a:	07298993          	addi	s3,s3,114 # 8000f9e8 <uart_tx_lock>
    8000097e:	00007497          	auipc	s1,0x7
    80000982:	f6a48493          	addi	s1,s1,-150 # 800078e8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00007917          	auipc	s2,0x7
    8000098a:	f6a90913          	addi	s2,s2,-150 # 800078f0 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	50c010ef          	jal	80001ea2 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	0000f497          	auipc	s1,0xf
    800009ac:	04048493          	addi	s1,s1,64 # 8000f9e8 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	00007797          	auipc	a5,0x7
    800009c0:	f2e7ba23          	sd	a4,-204(a5) # 800078f0 <uart_tx_w>
  uartstart();
    800009c4:	ed7ff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    800009c8:	8526                	mv	a0,s1
    800009ca:	2c2000ef          	jal	80000c8c <release>
}
    800009ce:	70a2                	ld	ra,40(sp)
    800009d0:	7402                	ld	s0,32(sp)
    800009d2:	64e2                	ld	s1,24(sp)
    800009d4:	6942                	ld	s2,16(sp)
    800009d6:	69a2                	ld	s3,8(sp)
    800009d8:	6a02                	ld	s4,0(sp)
    800009da:	6145                	addi	sp,sp,48
    800009dc:	8082                	ret
    for(;;)
    800009de:	a001                	j	800009de <uartputc+0xa4>

00000000800009e0 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e0:	1141                	addi	sp,sp,-16
    800009e2:	e422                	sd	s0,8(sp)
    800009e4:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009e6:	100007b7          	lui	a5,0x10000
    800009ea:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009ec:	0007c783          	lbu	a5,0(a5)
    800009f0:	8b85                	andi	a5,a5,1
    800009f2:	cb81                	beqz	a5,80000a02 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009f4:	100007b7          	lui	a5,0x10000
    800009f8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009fc:	6422                	ld	s0,8(sp)
    800009fe:	0141                	addi	sp,sp,16
    80000a00:	8082                	ret
    return -1;
    80000a02:	557d                	li	a0,-1
    80000a04:	bfe5                	j	800009fc <uartgetc+0x1c>

0000000080000a06 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a06:	1101                	addi	sp,sp,-32
    80000a08:	ec06                	sd	ra,24(sp)
    80000a0a:	e822                	sd	s0,16(sp)
    80000a0c:	e426                	sd	s1,8(sp)
    80000a0e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a10:	54fd                	li	s1,-1
    80000a12:	a019                	j	80000a18 <uartintr+0x12>
      break;
    consoleintr(c);
    80000a14:	85fff0ef          	jal	80000272 <consoleintr>
    int c = uartgetc();
    80000a18:	fc9ff0ef          	jal	800009e0 <uartgetc>
    if(c == -1)
    80000a1c:	fe951ce3          	bne	a0,s1,80000a14 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a20:	0000f497          	auipc	s1,0xf
    80000a24:	fc848493          	addi	s1,s1,-56 # 8000f9e8 <uart_tx_lock>
    80000a28:	8526                	mv	a0,s1
    80000a2a:	1ca000ef          	jal	80000bf4 <acquire>
  uartstart();
    80000a2e:	e6dff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    80000a32:	8526                	mv	a0,s1
    80000a34:	258000ef          	jal	80000c8c <release>
}
    80000a38:	60e2                	ld	ra,24(sp)
    80000a3a:	6442                	ld	s0,16(sp)
    80000a3c:	64a2                	ld	s1,8(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret

0000000080000a42 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a42:	1101                	addi	sp,sp,-32
    80000a44:	ec06                	sd	ra,24(sp)
    80000a46:	e822                	sd	s0,16(sp)
    80000a48:	e426                	sd	s1,8(sp)
    80000a4a:	e04a                	sd	s2,0(sp)
    80000a4c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a4e:	03451793          	slli	a5,a0,0x34
    80000a52:	e7a9                	bnez	a5,80000a9c <kfree+0x5a>
    80000a54:	84aa                	mv	s1,a0
    80000a56:	00022797          	auipc	a5,0x22
    80000a5a:	3fa78793          	addi	a5,a5,1018 # 80022e50 <end>
    80000a5e:	02f56f63          	bltu	a0,a5,80000a9c <kfree+0x5a>
    80000a62:	47c5                	li	a5,17
    80000a64:	07ee                	slli	a5,a5,0x1b
    80000a66:	02f57b63          	bgeu	a0,a5,80000a9c <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a6a:	6605                	lui	a2,0x1
    80000a6c:	4585                	li	a1,1
    80000a6e:	25a000ef          	jal	80000cc8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a72:	0000f917          	auipc	s2,0xf
    80000a76:	fae90913          	addi	s2,s2,-82 # 8000fa20 <kmem>
    80000a7a:	854a                	mv	a0,s2
    80000a7c:	178000ef          	jal	80000bf4 <acquire>
  r->next = kmem.freelist;
    80000a80:	01893783          	ld	a5,24(s2)
    80000a84:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a86:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	200000ef          	jal	80000c8c <release>
}
    80000a90:	60e2                	ld	ra,24(sp)
    80000a92:	6442                	ld	s0,16(sp)
    80000a94:	64a2                	ld	s1,8(sp)
    80000a96:	6902                	ld	s2,0(sp)
    80000a98:	6105                	addi	sp,sp,32
    80000a9a:	8082                	ret
    panic("kfree");
    80000a9c:	00006517          	auipc	a0,0x6
    80000aa0:	59c50513          	addi	a0,a0,1436 # 80007038 <etext+0x38>
    80000aa4:	cf1ff0ef          	jal	80000794 <panic>

0000000080000aa8 <freerange>:
{
    80000aa8:	7179                	addi	sp,sp,-48
    80000aaa:	f406                	sd	ra,40(sp)
    80000aac:	f022                	sd	s0,32(sp)
    80000aae:	ec26                	sd	s1,24(sp)
    80000ab0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab2:	6785                	lui	a5,0x1
    80000ab4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ab8:	00e504b3          	add	s1,a0,a4
    80000abc:	777d                	lui	a4,0xfffff
    80000abe:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	94be                	add	s1,s1,a5
    80000ac2:	0295e263          	bltu	a1,s1,80000ae6 <freerange+0x3e>
    80000ac6:	e84a                	sd	s2,16(sp)
    80000ac8:	e44e                	sd	s3,8(sp)
    80000aca:	e052                	sd	s4,0(sp)
    80000acc:	892e                	mv	s2,a1
    kfree(p);
    80000ace:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad0:	6985                	lui	s3,0x1
    kfree(p);
    80000ad2:	01448533          	add	a0,s1,s4
    80000ad6:	f6dff0ef          	jal	80000a42 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ada:	94ce                	add	s1,s1,s3
    80000adc:	fe997be3          	bgeu	s2,s1,80000ad2 <freerange+0x2a>
    80000ae0:	6942                	ld	s2,16(sp)
    80000ae2:	69a2                	ld	s3,8(sp)
    80000ae4:	6a02                	ld	s4,0(sp)
}
    80000ae6:	70a2                	ld	ra,40(sp)
    80000ae8:	7402                	ld	s0,32(sp)
    80000aea:	64e2                	ld	s1,24(sp)
    80000aec:	6145                	addi	sp,sp,48
    80000aee:	8082                	ret

0000000080000af0 <kinit>:
{
    80000af0:	1141                	addi	sp,sp,-16
    80000af2:	e406                	sd	ra,8(sp)
    80000af4:	e022                	sd	s0,0(sp)
    80000af6:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000af8:	00006597          	auipc	a1,0x6
    80000afc:	54858593          	addi	a1,a1,1352 # 80007040 <etext+0x40>
    80000b00:	0000f517          	auipc	a0,0xf
    80000b04:	f2050513          	addi	a0,a0,-224 # 8000fa20 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00022517          	auipc	a0,0x22
    80000b14:	34050513          	addi	a0,a0,832 # 80022e50 <end>
    80000b18:	f91ff0ef          	jal	80000aa8 <freerange>
}
    80000b1c:	60a2                	ld	ra,8(sp)
    80000b1e:	6402                	ld	s0,0(sp)
    80000b20:	0141                	addi	sp,sp,16
    80000b22:	8082                	ret

0000000080000b24 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b24:	1101                	addi	sp,sp,-32
    80000b26:	ec06                	sd	ra,24(sp)
    80000b28:	e822                	sd	s0,16(sp)
    80000b2a:	e426                	sd	s1,8(sp)
    80000b2c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2e:	0000f497          	auipc	s1,0xf
    80000b32:	ef248493          	addi	s1,s1,-270 # 8000fa20 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	0000f517          	auipc	a0,0xf
    80000b46:	ede50513          	addi	a0,a0,-290 # 8000fa20 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	140000ef          	jal	80000c8c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4595                	li	a1,5
    80000b54:	8526                	mv	a0,s1
    80000b56:	172000ef          	jal	80000cc8 <memset>
  return (void*)r;
}
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	60e2                	ld	ra,24(sp)
    80000b5e:	6442                	ld	s0,16(sp)
    80000b60:	64a2                	ld	s1,8(sp)
    80000b62:	6105                	addi	sp,sp,32
    80000b64:	8082                	ret
  release(&kmem.lock);
    80000b66:	0000f517          	auipc	a0,0xf
    80000b6a:	eba50513          	addi	a0,a0,-326 # 8000fa20 <kmem>
    80000b6e:	11e000ef          	jal	80000c8c <release>
  if(r)
    80000b72:	b7e5                	j	80000b5a <kalloc+0x36>

0000000080000b74 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b74:	1141                	addi	sp,sp,-16
    80000b76:	e422                	sd	s0,8(sp)
    80000b78:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b7a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b7c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b80:	00053823          	sd	zero,16(a0)
}
    80000b84:	6422                	ld	s0,8(sp)
    80000b86:	0141                	addi	sp,sp,16
    80000b88:	8082                	ret

0000000080000b8a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b8a:	411c                	lw	a5,0(a0)
    80000b8c:	e399                	bnez	a5,80000b92 <holding+0x8>
    80000b8e:	4501                	li	a0,0
  return r;
}
    80000b90:	8082                	ret
{
    80000b92:	1101                	addi	sp,sp,-32
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	e822                	sd	s0,16(sp)
    80000b98:	e426                	sd	s1,8(sp)
    80000b9a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b9c:	6904                	ld	s1,16(a0)
    80000b9e:	51b000ef          	jal	800018b8 <mycpu>
    80000ba2:	40a48533          	sub	a0,s1,a0
    80000ba6:	00153513          	seqz	a0,a0
}
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret

0000000080000bb4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bb4:	1101                	addi	sp,sp,-32
    80000bb6:	ec06                	sd	ra,24(sp)
    80000bb8:	e822                	sd	s0,16(sp)
    80000bba:	e426                	sd	s1,8(sp)
    80000bbc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbe:	100024f3          	csrr	s1,sstatus
    80000bc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bc6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bc8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bcc:	4ed000ef          	jal	800018b8 <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd4:	4e5000ef          	jal	800018b8 <mycpu>
    80000bd8:	5d3c                	lw	a5,120(a0)
    80000bda:	2785                	addiw	a5,a5,1
    80000bdc:	dd3c                	sw	a5,120(a0)
}
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	addi	sp,sp,32
    80000be6:	8082                	ret
    mycpu()->intena = old;
    80000be8:	4d1000ef          	jal	800018b8 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bec:	8085                	srli	s1,s1,0x1
    80000bee:	8885                	andi	s1,s1,1
    80000bf0:	dd64                	sw	s1,124(a0)
    80000bf2:	b7cd                	j	80000bd4 <push_off+0x20>

0000000080000bf4 <acquire>:
{
    80000bf4:	1101                	addi	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	addi	s0,sp,32
    80000bfe:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c00:	fb5ff0ef          	jal	80000bb4 <push_off>
  if(holding(lk))
    80000c04:	8526                	mv	a0,s1
    80000c06:	f85ff0ef          	jal	80000b8a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0a:	4705                	li	a4,1
  if(holding(lk))
    80000c0c:	e105                	bnez	a0,80000c2c <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0e:	87ba                	mv	a5,a4
    80000c10:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c14:	2781                	sext.w	a5,a5
    80000c16:	ffe5                	bnez	a5,80000c0e <acquire+0x1a>
  __sync_synchronize();
    80000c18:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c1c:	49d000ef          	jal	800018b8 <mycpu>
    80000c20:	e888                	sd	a0,16(s1)
}
    80000c22:	60e2                	ld	ra,24(sp)
    80000c24:	6442                	ld	s0,16(sp)
    80000c26:	64a2                	ld	s1,8(sp)
    80000c28:	6105                	addi	sp,sp,32
    80000c2a:	8082                	ret
    panic("acquire");
    80000c2c:	00006517          	auipc	a0,0x6
    80000c30:	41c50513          	addi	a0,a0,1052 # 80007048 <etext+0x48>
    80000c34:	b61ff0ef          	jal	80000794 <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	479000ef          	jal	800018b8 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c44:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c48:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4a:	e78d                	bnez	a5,80000c74 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c4c:	5d3c                	lw	a5,120(a0)
    80000c4e:	02f05963          	blez	a5,80000c80 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c52:	37fd                	addiw	a5,a5,-1
    80000c54:	0007871b          	sext.w	a4,a5
    80000c58:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5a:	eb09                	bnez	a4,80000c6c <pop_off+0x34>
    80000c5c:	5d7c                	lw	a5,124(a0)
    80000c5e:	c799                	beqz	a5,80000c6c <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c68:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c6c:	60a2                	ld	ra,8(sp)
    80000c6e:	6402                	ld	s0,0(sp)
    80000c70:	0141                	addi	sp,sp,16
    80000c72:	8082                	ret
    panic("pop_off - interruptible");
    80000c74:	00006517          	auipc	a0,0x6
    80000c78:	3dc50513          	addi	a0,a0,988 # 80007050 <etext+0x50>
    80000c7c:	b19ff0ef          	jal	80000794 <panic>
    panic("pop_off");
    80000c80:	00006517          	auipc	a0,0x6
    80000c84:	3e850513          	addi	a0,a0,1000 # 80007068 <etext+0x68>
    80000c88:	b0dff0ef          	jal	80000794 <panic>

0000000080000c8c <release>:
{
    80000c8c:	1101                	addi	sp,sp,-32
    80000c8e:	ec06                	sd	ra,24(sp)
    80000c90:	e822                	sd	s0,16(sp)
    80000c92:	e426                	sd	s1,8(sp)
    80000c94:	1000                	addi	s0,sp,32
    80000c96:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c98:	ef3ff0ef          	jal	80000b8a <holding>
    80000c9c:	c105                	beqz	a0,80000cbc <release+0x30>
  lk->cpu = 0;
    80000c9e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca2:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca6:	0f50000f          	fence	iorw,ow
    80000caa:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cae:	f8bff0ef          	jal	80000c38 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00006517          	auipc	a0,0x6
    80000cc0:	3b450513          	addi	a0,a0,948 # 80007070 <etext+0x70>
    80000cc4:	ad1ff0ef          	jal	80000794 <panic>

0000000080000cc8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cc8:	1141                	addi	sp,sp,-16
    80000cca:	e422                	sd	s0,8(sp)
    80000ccc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cce:	ca19                	beqz	a2,80000ce4 <memset+0x1c>
    80000cd0:	87aa                	mv	a5,a0
    80000cd2:	1602                	slli	a2,a2,0x20
    80000cd4:	9201                	srli	a2,a2,0x20
    80000cd6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cda:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cde:	0785                	addi	a5,a5,1
    80000ce0:	fee79de3          	bne	a5,a4,80000cda <memset+0x12>
  }
  return dst;
}
    80000ce4:	6422                	ld	s0,8(sp)
    80000ce6:	0141                	addi	sp,sp,16
    80000ce8:	8082                	ret

0000000080000cea <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cea:	1141                	addi	sp,sp,-16
    80000cec:	e422                	sd	s0,8(sp)
    80000cee:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf0:	ca05                	beqz	a2,80000d20 <memcmp+0x36>
    80000cf2:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cf6:	1682                	slli	a3,a3,0x20
    80000cf8:	9281                	srli	a3,a3,0x20
    80000cfa:	0685                	addi	a3,a3,1
    80000cfc:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cfe:	00054783          	lbu	a5,0(a0)
    80000d02:	0005c703          	lbu	a4,0(a1)
    80000d06:	00e79863          	bne	a5,a4,80000d16 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0a:	0505                	addi	a0,a0,1
    80000d0c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d0e:	fed518e3          	bne	a0,a3,80000cfe <memcmp+0x14>
  }

  return 0;
    80000d12:	4501                	li	a0,0
    80000d14:	a019                	j	80000d1a <memcmp+0x30>
      return *s1 - *s2;
    80000d16:	40e7853b          	subw	a0,a5,a4
}
    80000d1a:	6422                	ld	s0,8(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret
  return 0;
    80000d20:	4501                	li	a0,0
    80000d22:	bfe5                	j	80000d1a <memcmp+0x30>

0000000080000d24 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d24:	1141                	addi	sp,sp,-16
    80000d26:	e422                	sd	s0,8(sp)
    80000d28:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2a:	c205                	beqz	a2,80000d4a <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d2c:	02a5e263          	bltu	a1,a0,80000d50 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d30:	1602                	slli	a2,a2,0x20
    80000d32:	9201                	srli	a2,a2,0x20
    80000d34:	00c587b3          	add	a5,a1,a2
{
    80000d38:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3a:	0585                	addi	a1,a1,1
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdc1b1>
    80000d3e:	fff5c683          	lbu	a3,-1(a1)
    80000d42:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d46:	feb79ae3          	bne	a5,a1,80000d3a <memmove+0x16>

  return dst;
}
    80000d4a:	6422                	ld	s0,8(sp)
    80000d4c:	0141                	addi	sp,sp,16
    80000d4e:	8082                	ret
  if(s < d && s + n > d){
    80000d50:	02061693          	slli	a3,a2,0x20
    80000d54:	9281                	srli	a3,a3,0x20
    80000d56:	00d58733          	add	a4,a1,a3
    80000d5a:	fce57be3          	bgeu	a0,a4,80000d30 <memmove+0xc>
    d += n;
    80000d5e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	fff7c793          	not	a5,a5
    80000d6c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	16fd                	addi	a3,a3,-1
    80000d72:	00074603          	lbu	a2,0(a4)
    80000d76:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7a:	fef71ae3          	bne	a4,a5,80000d6e <memmove+0x4a>
    80000d7e:	b7f1                	j	80000d4a <memmove+0x26>

0000000080000d80 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d80:	1141                	addi	sp,sp,-16
    80000d82:	e406                	sd	ra,8(sp)
    80000d84:	e022                	sd	s0,0(sp)
    80000d86:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d88:	f9dff0ef          	jal	80000d24 <memmove>
}
    80000d8c:	60a2                	ld	ra,8(sp)
    80000d8e:	6402                	ld	s0,0(sp)
    80000d90:	0141                	addi	sp,sp,16
    80000d92:	8082                	ret

0000000080000d94 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d94:	1141                	addi	sp,sp,-16
    80000d96:	e422                	sd	s0,8(sp)
    80000d98:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9a:	ce11                	beqz	a2,80000db6 <strncmp+0x22>
    80000d9c:	00054783          	lbu	a5,0(a0)
    80000da0:	cf89                	beqz	a5,80000dba <strncmp+0x26>
    80000da2:	0005c703          	lbu	a4,0(a1)
    80000da6:	00f71a63          	bne	a4,a5,80000dba <strncmp+0x26>
    n--, p++, q++;
    80000daa:	367d                	addiw	a2,a2,-1
    80000dac:	0505                	addi	a0,a0,1
    80000dae:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db0:	f675                	bnez	a2,80000d9c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db2:	4501                	li	a0,0
    80000db4:	a801                	j	80000dc4 <strncmp+0x30>
    80000db6:	4501                	li	a0,0
    80000db8:	a031                	j	80000dc4 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000dba:	00054503          	lbu	a0,0(a0)
    80000dbe:	0005c783          	lbu	a5,0(a1)
    80000dc2:	9d1d                	subw	a0,a0,a5
}
    80000dc4:	6422                	ld	s0,8(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret

0000000080000dca <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd0:	87aa                	mv	a5,a0
    80000dd2:	86b2                	mv	a3,a2
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	02d05563          	blez	a3,80000e00 <strncpy+0x36>
    80000dda:	0785                	addi	a5,a5,1
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	fee78fa3          	sb	a4,-1(a5)
    80000de4:	0585                	addi	a1,a1,1
    80000de6:	f775                	bnez	a4,80000dd2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000de8:	873e                	mv	a4,a5
    80000dea:	9fb5                	addw	a5,a5,a3
    80000dec:	37fd                	addiw	a5,a5,-1
    80000dee:	00c05963          	blez	a2,80000e00 <strncpy+0x36>
    *s++ = 0;
    80000df2:	0705                	addi	a4,a4,1
    80000df4:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000df8:	40e786bb          	subw	a3,a5,a4
    80000dfc:	fed04be3          	bgtz	a3,80000df2 <strncpy+0x28>
  return os;
}
    80000e00:	6422                	ld	s0,8(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e0c:	02c05363          	blez	a2,80000e32 <safestrcpy+0x2c>
    80000e10:	fff6069b          	addiw	a3,a2,-1
    80000e14:	1682                	slli	a3,a3,0x20
    80000e16:	9281                	srli	a3,a3,0x20
    80000e18:	96ae                	add	a3,a3,a1
    80000e1a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e1c:	00d58963          	beq	a1,a3,80000e2e <safestrcpy+0x28>
    80000e20:	0585                	addi	a1,a1,1
    80000e22:	0785                	addi	a5,a5,1
    80000e24:	fff5c703          	lbu	a4,-1(a1)
    80000e28:	fee78fa3          	sb	a4,-1(a5)
    80000e2c:	fb65                	bnez	a4,80000e1c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e2e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strlen>:

int
strlen(const char *s)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e3e:	00054783          	lbu	a5,0(a0)
    80000e42:	cf91                	beqz	a5,80000e5e <strlen+0x26>
    80000e44:	0505                	addi	a0,a0,1
    80000e46:	87aa                	mv	a5,a0
    80000e48:	86be                	mv	a3,a5
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	fff7c703          	lbu	a4,-1(a5)
    80000e50:	ff65                	bnez	a4,80000e48 <strlen+0x10>
    80000e52:	40a6853b          	subw	a0,a3,a0
    80000e56:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e5e:	4501                	li	a0,0
    80000e60:	bfe5                	j	80000e58 <strlen+0x20>

0000000080000e62 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e406                	sd	ra,8(sp)
    80000e66:	e022                	sd	s0,0(sp)
    80000e68:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e6a:	23f000ef          	jal	800018a8 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e6e:	00007717          	auipc	a4,0x7
    80000e72:	a8a70713          	addi	a4,a4,-1398 # 800078f8 <started>
  if(cpuid() == 0){
    80000e76:	c51d                	beqz	a0,80000ea4 <main+0x42>
    while(started == 0)
    80000e78:	431c                	lw	a5,0(a4)
    80000e7a:	2781                	sext.w	a5,a5
    80000e7c:	dff5                	beqz	a5,80000e78 <main+0x16>
      ;
    __sync_synchronize();
    80000e7e:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e82:	227000ef          	jal	800018a8 <cpuid>
    80000e86:	85aa                	mv	a1,a0
    80000e88:	00006517          	auipc	a0,0x6
    80000e8c:	21050513          	addi	a0,a0,528 # 80007098 <etext+0x98>
    80000e90:	e32ff0ef          	jal	800004c2 <printf>
    kvminithart();    // turn on paging
    80000e94:	080000ef          	jal	80000f14 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e98:	0ad010ef          	jal	80002744 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	7bc040ef          	jal	80005658 <plicinithart>
  }

  scheduler();        
    80000ea0:	669000ef          	jal	80001d08 <scheduler>
    consoleinit();
    80000ea4:	d48ff0ef          	jal	800003ec <consoleinit>
    printfinit();
    80000ea8:	927ff0ef          	jal	800007ce <printfinit>
    printf("\n");
    80000eac:	00006517          	auipc	a0,0x6
    80000eb0:	1cc50513          	addi	a0,a0,460 # 80007078 <etext+0x78>
    80000eb4:	e0eff0ef          	jal	800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000eb8:	00006517          	auipc	a0,0x6
    80000ebc:	1c850513          	addi	a0,a0,456 # 80007080 <etext+0x80>
    80000ec0:	e02ff0ef          	jal	800004c2 <printf>
    printf("\n");
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1b450513          	addi	a0,a0,436 # 80007078 <etext+0x78>
    80000ecc:	df6ff0ef          	jal	800004c2 <printf>
    kinit();         // physical page allocator
    80000ed0:	c21ff0ef          	jal	80000af0 <kinit>
    kvminit();       // create kernel page table
    80000ed4:	2ca000ef          	jal	8000119e <kvminit>
    kvminithart();   // turn on paging
    80000ed8:	03c000ef          	jal	80000f14 <kvminithart>
    procinit();      // process table
    80000edc:	11d000ef          	jal	800017f8 <procinit>
    trapinit();      // trap vectors
    80000ee0:	041010ef          	jal	80002720 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	061010ef          	jal	80002744 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	756040ef          	jal	8000563e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	76c040ef          	jal	80005658 <plicinithart>
    binit();         // buffer cache
    80000ef0:	717010ef          	jal	80002e06 <binit>
    iinit();         // inode table
    80000ef4:	508020ef          	jal	800033fc <iinit>
    fileinit();      // file table
    80000ef8:	2b4030ef          	jal	800041ac <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	04d040ef          	jal	80005748 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	43d000ef          	jal	80001b3c <userinit>
    __sync_synchronize();
    80000f04:	0ff0000f          	fence
    started = 1;
    80000f08:	4785                	li	a5,1
    80000f0a:	00007717          	auipc	a4,0x7
    80000f0e:	9ef72723          	sw	a5,-1554(a4) # 800078f8 <started>
    80000f12:	b779                	j	80000ea0 <main+0x3e>

0000000080000f14 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f14:	1141                	addi	sp,sp,-16
    80000f16:	e422                	sd	s0,8(sp)
    80000f18:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f1a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f1e:	00007797          	auipc	a5,0x7
    80000f22:	9e27b783          	ld	a5,-1566(a5) # 80007900 <kernel_pagetable>
    80000f26:	83b1                	srli	a5,a5,0xc
    80000f28:	577d                	li	a4,-1
    80000f2a:	177e                	slli	a4,a4,0x3f
    80000f2c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f2e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f32:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret

0000000080000f3c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f3c:	7139                	addi	sp,sp,-64
    80000f3e:	fc06                	sd	ra,56(sp)
    80000f40:	f822                	sd	s0,48(sp)
    80000f42:	f426                	sd	s1,40(sp)
    80000f44:	f04a                	sd	s2,32(sp)
    80000f46:	ec4e                	sd	s3,24(sp)
    80000f48:	e852                	sd	s4,16(sp)
    80000f4a:	e456                	sd	s5,8(sp)
    80000f4c:	e05a                	sd	s6,0(sp)
    80000f4e:	0080                	addi	s0,sp,64
    80000f50:	84aa                	mv	s1,a0
    80000f52:	89ae                	mv	s3,a1
    80000f54:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f56:	57fd                	li	a5,-1
    80000f58:	83e9                	srli	a5,a5,0x1a
    80000f5a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f5c:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f5e:	02b7fc63          	bgeu	a5,a1,80000f96 <walk+0x5a>
    panic("walk");
    80000f62:	00006517          	auipc	a0,0x6
    80000f66:	14e50513          	addi	a0,a0,334 # 800070b0 <etext+0xb0>
    80000f6a:	82bff0ef          	jal	80000794 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f6e:	060a8263          	beqz	s5,80000fd2 <walk+0x96>
    80000f72:	bb3ff0ef          	jal	80000b24 <kalloc>
    80000f76:	84aa                	mv	s1,a0
    80000f78:	c139                	beqz	a0,80000fbe <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f7a:	6605                	lui	a2,0x1
    80000f7c:	4581                	li	a1,0
    80000f7e:	d4bff0ef          	jal	80000cc8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f82:	00c4d793          	srli	a5,s1,0xc
    80000f86:	07aa                	slli	a5,a5,0xa
    80000f88:	0017e793          	ori	a5,a5,1
    80000f8c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f90:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdc1a7>
    80000f92:	036a0063          	beq	s4,s6,80000fb2 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f96:	0149d933          	srl	s2,s3,s4
    80000f9a:	1ff97913          	andi	s2,s2,511
    80000f9e:	090e                	slli	s2,s2,0x3
    80000fa0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fa2:	00093483          	ld	s1,0(s2)
    80000fa6:	0014f793          	andi	a5,s1,1
    80000faa:	d3f1                	beqz	a5,80000f6e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fac:	80a9                	srli	s1,s1,0xa
    80000fae:	04b2                	slli	s1,s1,0xc
    80000fb0:	b7c5                	j	80000f90 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000fb2:	00c9d513          	srli	a0,s3,0xc
    80000fb6:	1ff57513          	andi	a0,a0,511
    80000fba:	050e                	slli	a0,a0,0x3
    80000fbc:	9526                	add	a0,a0,s1
}
    80000fbe:	70e2                	ld	ra,56(sp)
    80000fc0:	7442                	ld	s0,48(sp)
    80000fc2:	74a2                	ld	s1,40(sp)
    80000fc4:	7902                	ld	s2,32(sp)
    80000fc6:	69e2                	ld	s3,24(sp)
    80000fc8:	6a42                	ld	s4,16(sp)
    80000fca:	6aa2                	ld	s5,8(sp)
    80000fcc:	6b02                	ld	s6,0(sp)
    80000fce:	6121                	addi	sp,sp,64
    80000fd0:	8082                	ret
        return 0;
    80000fd2:	4501                	li	a0,0
    80000fd4:	b7ed                	j	80000fbe <walk+0x82>

0000000080000fd6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fd6:	57fd                	li	a5,-1
    80000fd8:	83e9                	srli	a5,a5,0x1a
    80000fda:	00b7f463          	bgeu	a5,a1,80000fe2 <walkaddr+0xc>
    return 0;
    80000fde:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fe0:	8082                	ret
{
    80000fe2:	1141                	addi	sp,sp,-16
    80000fe4:	e406                	sd	ra,8(sp)
    80000fe6:	e022                	sd	s0,0(sp)
    80000fe8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fea:	4601                	li	a2,0
    80000fec:	f51ff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80000ff0:	c105                	beqz	a0,80001010 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000ff2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000ff4:	0117f693          	andi	a3,a5,17
    80000ff8:	4745                	li	a4,17
    return 0;
    80000ffa:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000ffc:	00e68663          	beq	a3,a4,80001008 <walkaddr+0x32>
}
    80001000:	60a2                	ld	ra,8(sp)
    80001002:	6402                	ld	s0,0(sp)
    80001004:	0141                	addi	sp,sp,16
    80001006:	8082                	ret
  pa = PTE2PA(*pte);
    80001008:	83a9                	srli	a5,a5,0xa
    8000100a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000100e:	bfcd                	j	80001000 <walkaddr+0x2a>
    return 0;
    80001010:	4501                	li	a0,0
    80001012:	b7fd                	j	80001000 <walkaddr+0x2a>

0000000080001014 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001014:	715d                	addi	sp,sp,-80
    80001016:	e486                	sd	ra,72(sp)
    80001018:	e0a2                	sd	s0,64(sp)
    8000101a:	fc26                	sd	s1,56(sp)
    8000101c:	f84a                	sd	s2,48(sp)
    8000101e:	f44e                	sd	s3,40(sp)
    80001020:	f052                	sd	s4,32(sp)
    80001022:	ec56                	sd	s5,24(sp)
    80001024:	e85a                	sd	s6,16(sp)
    80001026:	e45e                	sd	s7,8(sp)
    80001028:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000102a:	03459793          	slli	a5,a1,0x34
    8000102e:	e7a9                	bnez	a5,80001078 <mappages+0x64>
    80001030:	8aaa                	mv	s5,a0
    80001032:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001034:	03461793          	slli	a5,a2,0x34
    80001038:	e7b1                	bnez	a5,80001084 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    8000103a:	ca39                	beqz	a2,80001090 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000103c:	77fd                	lui	a5,0xfffff
    8000103e:	963e                	add	a2,a2,a5
    80001040:	00b609b3          	add	s3,a2,a1
  a = va;
    80001044:	892e                	mv	s2,a1
    80001046:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000104a:	6b85                	lui	s7,0x1
    8000104c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	4605                	li	a2,1
    80001052:	85ca                	mv	a1,s2
    80001054:	8556                	mv	a0,s5
    80001056:	ee7ff0ef          	jal	80000f3c <walk>
    8000105a:	c539                	beqz	a0,800010a8 <mappages+0x94>
    if(*pte & PTE_V)
    8000105c:	611c                	ld	a5,0(a0)
    8000105e:	8b85                	andi	a5,a5,1
    80001060:	ef95                	bnez	a5,8000109c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001062:	80b1                	srli	s1,s1,0xc
    80001064:	04aa                	slli	s1,s1,0xa
    80001066:	0164e4b3          	or	s1,s1,s6
    8000106a:	0014e493          	ori	s1,s1,1
    8000106e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001070:	05390863          	beq	s2,s3,800010c0 <mappages+0xac>
    a += PGSIZE;
    80001074:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001076:	bfd9                	j	8000104c <mappages+0x38>
    panic("mappages: va not aligned");
    80001078:	00006517          	auipc	a0,0x6
    8000107c:	04050513          	addi	a0,a0,64 # 800070b8 <etext+0xb8>
    80001080:	f14ff0ef          	jal	80000794 <panic>
    panic("mappages: size not aligned");
    80001084:	00006517          	auipc	a0,0x6
    80001088:	05450513          	addi	a0,a0,84 # 800070d8 <etext+0xd8>
    8000108c:	f08ff0ef          	jal	80000794 <panic>
    panic("mappages: size");
    80001090:	00006517          	auipc	a0,0x6
    80001094:	06850513          	addi	a0,a0,104 # 800070f8 <etext+0xf8>
    80001098:	efcff0ef          	jal	80000794 <panic>
      panic("mappages: remap");
    8000109c:	00006517          	auipc	a0,0x6
    800010a0:	06c50513          	addi	a0,a0,108 # 80007108 <etext+0x108>
    800010a4:	ef0ff0ef          	jal	80000794 <panic>
      return -1;
    800010a8:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010aa:	60a6                	ld	ra,72(sp)
    800010ac:	6406                	ld	s0,64(sp)
    800010ae:	74e2                	ld	s1,56(sp)
    800010b0:	7942                	ld	s2,48(sp)
    800010b2:	79a2                	ld	s3,40(sp)
    800010b4:	7a02                	ld	s4,32(sp)
    800010b6:	6ae2                	ld	s5,24(sp)
    800010b8:	6b42                	ld	s6,16(sp)
    800010ba:	6ba2                	ld	s7,8(sp)
    800010bc:	6161                	addi	sp,sp,80
    800010be:	8082                	ret
  return 0;
    800010c0:	4501                	li	a0,0
    800010c2:	b7e5                	j	800010aa <mappages+0x96>

00000000800010c4 <kvmmap>:
{
    800010c4:	1141                	addi	sp,sp,-16
    800010c6:	e406                	sd	ra,8(sp)
    800010c8:	e022                	sd	s0,0(sp)
    800010ca:	0800                	addi	s0,sp,16
    800010cc:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010ce:	86b2                	mv	a3,a2
    800010d0:	863e                	mv	a2,a5
    800010d2:	f43ff0ef          	jal	80001014 <mappages>
    800010d6:	e509                	bnez	a0,800010e0 <kvmmap+0x1c>
}
    800010d8:	60a2                	ld	ra,8(sp)
    800010da:	6402                	ld	s0,0(sp)
    800010dc:	0141                	addi	sp,sp,16
    800010de:	8082                	ret
    panic("kvmmap");
    800010e0:	00006517          	auipc	a0,0x6
    800010e4:	03850513          	addi	a0,a0,56 # 80007118 <etext+0x118>
    800010e8:	eacff0ef          	jal	80000794 <panic>

00000000800010ec <kvmmake>:
{
    800010ec:	1101                	addi	sp,sp,-32
    800010ee:	ec06                	sd	ra,24(sp)
    800010f0:	e822                	sd	s0,16(sp)
    800010f2:	e426                	sd	s1,8(sp)
    800010f4:	e04a                	sd	s2,0(sp)
    800010f6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010f8:	a2dff0ef          	jal	80000b24 <kalloc>
    800010fc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010fe:	6605                	lui	a2,0x1
    80001100:	4581                	li	a1,0
    80001102:	bc7ff0ef          	jal	80000cc8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001106:	4719                	li	a4,6
    80001108:	6685                	lui	a3,0x1
    8000110a:	10000637          	lui	a2,0x10000
    8000110e:	100005b7          	lui	a1,0x10000
    80001112:	8526                	mv	a0,s1
    80001114:	fb1ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001118:	4719                	li	a4,6
    8000111a:	6685                	lui	a3,0x1
    8000111c:	10001637          	lui	a2,0x10001
    80001120:	100015b7          	lui	a1,0x10001
    80001124:	8526                	mv	a0,s1
    80001126:	f9fff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000112a:	4719                	li	a4,6
    8000112c:	040006b7          	lui	a3,0x4000
    80001130:	0c000637          	lui	a2,0xc000
    80001134:	0c0005b7          	lui	a1,0xc000
    80001138:	8526                	mv	a0,s1
    8000113a:	f8bff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000113e:	00006917          	auipc	s2,0x6
    80001142:	ec290913          	addi	s2,s2,-318 # 80007000 <etext>
    80001146:	4729                	li	a4,10
    80001148:	80006697          	auipc	a3,0x80006
    8000114c:	eb868693          	addi	a3,a3,-328 # 7000 <_entry-0x7fff9000>
    80001150:	4605                	li	a2,1
    80001152:	067e                	slli	a2,a2,0x1f
    80001154:	85b2                	mv	a1,a2
    80001156:	8526                	mv	a0,s1
    80001158:	f6dff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000115c:	46c5                	li	a3,17
    8000115e:	06ee                	slli	a3,a3,0x1b
    80001160:	4719                	li	a4,6
    80001162:	412686b3          	sub	a3,a3,s2
    80001166:	864a                	mv	a2,s2
    80001168:	85ca                	mv	a1,s2
    8000116a:	8526                	mv	a0,s1
    8000116c:	f59ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001170:	4729                	li	a4,10
    80001172:	6685                	lui	a3,0x1
    80001174:	00005617          	auipc	a2,0x5
    80001178:	e8c60613          	addi	a2,a2,-372 # 80006000 <_trampoline>
    8000117c:	040005b7          	lui	a1,0x4000
    80001180:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001182:	05b2                	slli	a1,a1,0xc
    80001184:	8526                	mv	a0,s1
    80001186:	f3fff0ef          	jal	800010c4 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000118a:	8526                	mv	a0,s1
    8000118c:	5da000ef          	jal	80001766 <proc_mapstacks>
}
    80001190:	8526                	mv	a0,s1
    80001192:	60e2                	ld	ra,24(sp)
    80001194:	6442                	ld	s0,16(sp)
    80001196:	64a2                	ld	s1,8(sp)
    80001198:	6902                	ld	s2,0(sp)
    8000119a:	6105                	addi	sp,sp,32
    8000119c:	8082                	ret

000000008000119e <kvminit>:
{
    8000119e:	1141                	addi	sp,sp,-16
    800011a0:	e406                	sd	ra,8(sp)
    800011a2:	e022                	sd	s0,0(sp)
    800011a4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011a6:	f47ff0ef          	jal	800010ec <kvmmake>
    800011aa:	00006797          	auipc	a5,0x6
    800011ae:	74a7bb23          	sd	a0,1878(a5) # 80007900 <kernel_pagetable>
}
    800011b2:	60a2                	ld	ra,8(sp)
    800011b4:	6402                	ld	s0,0(sp)
    800011b6:	0141                	addi	sp,sp,16
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	715d                	addi	sp,sp,-80
    800011bc:	e486                	sd	ra,72(sp)
    800011be:	e0a2                	sd	s0,64(sp)
    800011c0:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e39d                	bnez	a5,800011ec <uvmunmap+0x32>
    800011c8:	f84a                	sd	s2,48(sp)
    800011ca:	f44e                	sd	s3,40(sp)
    800011cc:	f052                	sd	s4,32(sp)
    800011ce:	ec56                	sd	s5,24(sp)
    800011d0:	e85a                	sd	s6,16(sp)
    800011d2:	e45e                	sd	s7,8(sp)
    800011d4:	8a2a                	mv	s4,a0
    800011d6:	892e                	mv	s2,a1
    800011d8:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011da:	0632                	slli	a2,a2,0xc
    800011dc:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800011e0:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011e2:	6b05                	lui	s6,0x1
    800011e4:	0735ff63          	bgeu	a1,s3,80001262 <uvmunmap+0xa8>
    800011e8:	fc26                	sd	s1,56(sp)
    800011ea:	a0a9                	j	80001234 <uvmunmap+0x7a>
    800011ec:	fc26                	sd	s1,56(sp)
    800011ee:	f84a                	sd	s2,48(sp)
    800011f0:	f44e                	sd	s3,40(sp)
    800011f2:	f052                	sd	s4,32(sp)
    800011f4:	ec56                	sd	s5,24(sp)
    800011f6:	e85a                	sd	s6,16(sp)
    800011f8:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800011fa:	00006517          	auipc	a0,0x6
    800011fe:	f2650513          	addi	a0,a0,-218 # 80007120 <etext+0x120>
    80001202:	d92ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: walk");
    80001206:	00006517          	auipc	a0,0x6
    8000120a:	f3250513          	addi	a0,a0,-206 # 80007138 <etext+0x138>
    8000120e:	d86ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not mapped");
    80001212:	00006517          	auipc	a0,0x6
    80001216:	f3650513          	addi	a0,a0,-202 # 80007148 <etext+0x148>
    8000121a:	d7aff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not a leaf");
    8000121e:	00006517          	auipc	a0,0x6
    80001222:	f4250513          	addi	a0,a0,-190 # 80007160 <etext+0x160>
    80001226:	d6eff0ef          	jal	80000794 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000122a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000122e:	995a                	add	s2,s2,s6
    80001230:	03397863          	bgeu	s2,s3,80001260 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001234:	4601                	li	a2,0
    80001236:	85ca                	mv	a1,s2
    80001238:	8552                	mv	a0,s4
    8000123a:	d03ff0ef          	jal	80000f3c <walk>
    8000123e:	84aa                	mv	s1,a0
    80001240:	d179                	beqz	a0,80001206 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001242:	6108                	ld	a0,0(a0)
    80001244:	00157793          	andi	a5,a0,1
    80001248:	d7e9                	beqz	a5,80001212 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000124a:	3ff57793          	andi	a5,a0,1023
    8000124e:	fd7788e3          	beq	a5,s7,8000121e <uvmunmap+0x64>
    if(do_free){
    80001252:	fc0a8ce3          	beqz	s5,8000122a <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    80001256:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001258:	0532                	slli	a0,a0,0xc
    8000125a:	fe8ff0ef          	jal	80000a42 <kfree>
    8000125e:	b7f1                	j	8000122a <uvmunmap+0x70>
    80001260:	74e2                	ld	s1,56(sp)
    80001262:	7942                	ld	s2,48(sp)
    80001264:	79a2                	ld	s3,40(sp)
    80001266:	7a02                	ld	s4,32(sp)
    80001268:	6ae2                	ld	s5,24(sp)
    8000126a:	6b42                	ld	s6,16(sp)
    8000126c:	6ba2                	ld	s7,8(sp)
  }
}
    8000126e:	60a6                	ld	ra,72(sp)
    80001270:	6406                	ld	s0,64(sp)
    80001272:	6161                	addi	sp,sp,80
    80001274:	8082                	ret

0000000080001276 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001276:	1101                	addi	sp,sp,-32
    80001278:	ec06                	sd	ra,24(sp)
    8000127a:	e822                	sd	s0,16(sp)
    8000127c:	e426                	sd	s1,8(sp)
    8000127e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001280:	8a5ff0ef          	jal	80000b24 <kalloc>
    80001284:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001286:	c509                	beqz	a0,80001290 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001288:	6605                	lui	a2,0x1
    8000128a:	4581                	li	a1,0
    8000128c:	a3dff0ef          	jal	80000cc8 <memset>
  return pagetable;
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret

000000008000129c <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000129c:	7179                	addi	sp,sp,-48
    8000129e:	f406                	sd	ra,40(sp)
    800012a0:	f022                	sd	s0,32(sp)
    800012a2:	ec26                	sd	s1,24(sp)
    800012a4:	e84a                	sd	s2,16(sp)
    800012a6:	e44e                	sd	s3,8(sp)
    800012a8:	e052                	sd	s4,0(sp)
    800012aa:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012ac:	6785                	lui	a5,0x1
    800012ae:	04f67063          	bgeu	a2,a5,800012ee <uvmfirst+0x52>
    800012b2:	8a2a                	mv	s4,a0
    800012b4:	89ae                	mv	s3,a1
    800012b6:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012b8:	86dff0ef          	jal	80000b24 <kalloc>
    800012bc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012be:	6605                	lui	a2,0x1
    800012c0:	4581                	li	a1,0
    800012c2:	a07ff0ef          	jal	80000cc8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012c6:	4779                	li	a4,30
    800012c8:	86ca                	mv	a3,s2
    800012ca:	6605                	lui	a2,0x1
    800012cc:	4581                	li	a1,0
    800012ce:	8552                	mv	a0,s4
    800012d0:	d45ff0ef          	jal	80001014 <mappages>
  memmove(mem, src, sz);
    800012d4:	8626                	mv	a2,s1
    800012d6:	85ce                	mv	a1,s3
    800012d8:	854a                	mv	a0,s2
    800012da:	a4bff0ef          	jal	80000d24 <memmove>
}
    800012de:	70a2                	ld	ra,40(sp)
    800012e0:	7402                	ld	s0,32(sp)
    800012e2:	64e2                	ld	s1,24(sp)
    800012e4:	6942                	ld	s2,16(sp)
    800012e6:	69a2                	ld	s3,8(sp)
    800012e8:	6a02                	ld	s4,0(sp)
    800012ea:	6145                	addi	sp,sp,48
    800012ec:	8082                	ret
    panic("uvmfirst: more than a page");
    800012ee:	00006517          	auipc	a0,0x6
    800012f2:	e8a50513          	addi	a0,a0,-374 # 80007178 <etext+0x178>
    800012f6:	c9eff0ef          	jal	80000794 <panic>

00000000800012fa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012fa:	1101                	addi	sp,sp,-32
    800012fc:	ec06                	sd	ra,24(sp)
    800012fe:	e822                	sd	s0,16(sp)
    80001300:	e426                	sd	s1,8(sp)
    80001302:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001304:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001306:	00b67d63          	bgeu	a2,a1,80001320 <uvmdealloc+0x26>
    8000130a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000130c:	6785                	lui	a5,0x1
    8000130e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001310:	00f60733          	add	a4,a2,a5
    80001314:	76fd                	lui	a3,0xfffff
    80001316:	8f75                	and	a4,a4,a3
    80001318:	97ae                	add	a5,a5,a1
    8000131a:	8ff5                	and	a5,a5,a3
    8000131c:	00f76863          	bltu	a4,a5,8000132c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001320:	8526                	mv	a0,s1
    80001322:	60e2                	ld	ra,24(sp)
    80001324:	6442                	ld	s0,16(sp)
    80001326:	64a2                	ld	s1,8(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000132c:	8f99                	sub	a5,a5,a4
    8000132e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001330:	4685                	li	a3,1
    80001332:	0007861b          	sext.w	a2,a5
    80001336:	85ba                	mv	a1,a4
    80001338:	e83ff0ef          	jal	800011ba <uvmunmap>
    8000133c:	b7d5                	j	80001320 <uvmdealloc+0x26>

000000008000133e <uvmalloc>:
  if(newsz < oldsz)
    8000133e:	08b66f63          	bltu	a2,a1,800013dc <uvmalloc+0x9e>
{
    80001342:	7139                	addi	sp,sp,-64
    80001344:	fc06                	sd	ra,56(sp)
    80001346:	f822                	sd	s0,48(sp)
    80001348:	ec4e                	sd	s3,24(sp)
    8000134a:	e852                	sd	s4,16(sp)
    8000134c:	e456                	sd	s5,8(sp)
    8000134e:	0080                	addi	s0,sp,64
    80001350:	8aaa                	mv	s5,a0
    80001352:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001354:	6785                	lui	a5,0x1
    80001356:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001358:	95be                	add	a1,a1,a5
    8000135a:	77fd                	lui	a5,0xfffff
    8000135c:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001360:	08c9f063          	bgeu	s3,a2,800013e0 <uvmalloc+0xa2>
    80001364:	f426                	sd	s1,40(sp)
    80001366:	f04a                	sd	s2,32(sp)
    80001368:	e05a                	sd	s6,0(sp)
    8000136a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000136c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001370:	fb4ff0ef          	jal	80000b24 <kalloc>
    80001374:	84aa                	mv	s1,a0
    if(mem == 0){
    80001376:	c515                	beqz	a0,800013a2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001378:	6605                	lui	a2,0x1
    8000137a:	4581                	li	a1,0
    8000137c:	94dff0ef          	jal	80000cc8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001380:	875a                	mv	a4,s6
    80001382:	86a6                	mv	a3,s1
    80001384:	6605                	lui	a2,0x1
    80001386:	85ca                	mv	a1,s2
    80001388:	8556                	mv	a0,s5
    8000138a:	c8bff0ef          	jal	80001014 <mappages>
    8000138e:	e915                	bnez	a0,800013c2 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001390:	6785                	lui	a5,0x1
    80001392:	993e                	add	s2,s2,a5
    80001394:	fd496ee3          	bltu	s2,s4,80001370 <uvmalloc+0x32>
  return newsz;
    80001398:	8552                	mv	a0,s4
    8000139a:	74a2                	ld	s1,40(sp)
    8000139c:	7902                	ld	s2,32(sp)
    8000139e:	6b02                	ld	s6,0(sp)
    800013a0:	a811                	j	800013b4 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800013a2:	864e                	mv	a2,s3
    800013a4:	85ca                	mv	a1,s2
    800013a6:	8556                	mv	a0,s5
    800013a8:	f53ff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013ac:	4501                	li	a0,0
    800013ae:	74a2                	ld	s1,40(sp)
    800013b0:	7902                	ld	s2,32(sp)
    800013b2:	6b02                	ld	s6,0(sp)
}
    800013b4:	70e2                	ld	ra,56(sp)
    800013b6:	7442                	ld	s0,48(sp)
    800013b8:	69e2                	ld	s3,24(sp)
    800013ba:	6a42                	ld	s4,16(sp)
    800013bc:	6aa2                	ld	s5,8(sp)
    800013be:	6121                	addi	sp,sp,64
    800013c0:	8082                	ret
      kfree(mem);
    800013c2:	8526                	mv	a0,s1
    800013c4:	e7eff0ef          	jal	80000a42 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013c8:	864e                	mv	a2,s3
    800013ca:	85ca                	mv	a1,s2
    800013cc:	8556                	mv	a0,s5
    800013ce:	f2dff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013d2:	4501                	li	a0,0
    800013d4:	74a2                	ld	s1,40(sp)
    800013d6:	7902                	ld	s2,32(sp)
    800013d8:	6b02                	ld	s6,0(sp)
    800013da:	bfe9                	j	800013b4 <uvmalloc+0x76>
    return oldsz;
    800013dc:	852e                	mv	a0,a1
}
    800013de:	8082                	ret
  return newsz;
    800013e0:	8532                	mv	a0,a2
    800013e2:	bfc9                	j	800013b4 <uvmalloc+0x76>

00000000800013e4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013e4:	7179                	addi	sp,sp,-48
    800013e6:	f406                	sd	ra,40(sp)
    800013e8:	f022                	sd	s0,32(sp)
    800013ea:	ec26                	sd	s1,24(sp)
    800013ec:	e84a                	sd	s2,16(sp)
    800013ee:	e44e                	sd	s3,8(sp)
    800013f0:	e052                	sd	s4,0(sp)
    800013f2:	1800                	addi	s0,sp,48
    800013f4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013f6:	84aa                	mv	s1,a0
    800013f8:	6905                	lui	s2,0x1
    800013fa:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013fc:	4985                	li	s3,1
    800013fe:	a819                	j	80001414 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001400:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001402:	00c79513          	slli	a0,a5,0xc
    80001406:	fdfff0ef          	jal	800013e4 <freewalk>
      pagetable[i] = 0;
    8000140a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000140e:	04a1                	addi	s1,s1,8
    80001410:	01248f63          	beq	s1,s2,8000142e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001414:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001416:	00f7f713          	andi	a4,a5,15
    8000141a:	ff3703e3          	beq	a4,s3,80001400 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000141e:	8b85                	andi	a5,a5,1
    80001420:	d7fd                	beqz	a5,8000140e <freewalk+0x2a>
      panic("freewalk: leaf");
    80001422:	00006517          	auipc	a0,0x6
    80001426:	d7650513          	addi	a0,a0,-650 # 80007198 <etext+0x198>
    8000142a:	b6aff0ef          	jal	80000794 <panic>
    }
  }
  kfree((void*)pagetable);
    8000142e:	8552                	mv	a0,s4
    80001430:	e12ff0ef          	jal	80000a42 <kfree>
}
    80001434:	70a2                	ld	ra,40(sp)
    80001436:	7402                	ld	s0,32(sp)
    80001438:	64e2                	ld	s1,24(sp)
    8000143a:	6942                	ld	s2,16(sp)
    8000143c:	69a2                	ld	s3,8(sp)
    8000143e:	6a02                	ld	s4,0(sp)
    80001440:	6145                	addi	sp,sp,48
    80001442:	8082                	ret

0000000080001444 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001444:	1101                	addi	sp,sp,-32
    80001446:	ec06                	sd	ra,24(sp)
    80001448:	e822                	sd	s0,16(sp)
    8000144a:	e426                	sd	s1,8(sp)
    8000144c:	1000                	addi	s0,sp,32
    8000144e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001450:	e989                	bnez	a1,80001462 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001452:	8526                	mv	a0,s1
    80001454:	f91ff0ef          	jal	800013e4 <freewalk>
}
    80001458:	60e2                	ld	ra,24(sp)
    8000145a:	6442                	ld	s0,16(sp)
    8000145c:	64a2                	ld	s1,8(sp)
    8000145e:	6105                	addi	sp,sp,32
    80001460:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001462:	6785                	lui	a5,0x1
    80001464:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001466:	95be                	add	a1,a1,a5
    80001468:	4685                	li	a3,1
    8000146a:	00c5d613          	srli	a2,a1,0xc
    8000146e:	4581                	li	a1,0
    80001470:	d4bff0ef          	jal	800011ba <uvmunmap>
    80001474:	bff9                	j	80001452 <uvmfree+0xe>

0000000080001476 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001476:	c65d                	beqz	a2,80001524 <uvmcopy+0xae>
{
    80001478:	715d                	addi	sp,sp,-80
    8000147a:	e486                	sd	ra,72(sp)
    8000147c:	e0a2                	sd	s0,64(sp)
    8000147e:	fc26                	sd	s1,56(sp)
    80001480:	f84a                	sd	s2,48(sp)
    80001482:	f44e                	sd	s3,40(sp)
    80001484:	f052                	sd	s4,32(sp)
    80001486:	ec56                	sd	s5,24(sp)
    80001488:	e85a                	sd	s6,16(sp)
    8000148a:	e45e                	sd	s7,8(sp)
    8000148c:	0880                	addi	s0,sp,80
    8000148e:	8b2a                	mv	s6,a0
    80001490:	8aae                	mv	s5,a1
    80001492:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001494:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001496:	4601                	li	a2,0
    80001498:	85ce                	mv	a1,s3
    8000149a:	855a                	mv	a0,s6
    8000149c:	aa1ff0ef          	jal	80000f3c <walk>
    800014a0:	c121                	beqz	a0,800014e0 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800014a2:	6118                	ld	a4,0(a0)
    800014a4:	00177793          	andi	a5,a4,1
    800014a8:	c3b1                	beqz	a5,800014ec <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800014aa:	00a75593          	srli	a1,a4,0xa
    800014ae:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014b2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014b6:	e6eff0ef          	jal	80000b24 <kalloc>
    800014ba:	892a                	mv	s2,a0
    800014bc:	c129                	beqz	a0,800014fe <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014be:	6605                	lui	a2,0x1
    800014c0:	85de                	mv	a1,s7
    800014c2:	863ff0ef          	jal	80000d24 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014c6:	8726                	mv	a4,s1
    800014c8:	86ca                	mv	a3,s2
    800014ca:	6605                	lui	a2,0x1
    800014cc:	85ce                	mv	a1,s3
    800014ce:	8556                	mv	a0,s5
    800014d0:	b45ff0ef          	jal	80001014 <mappages>
    800014d4:	e115                	bnez	a0,800014f8 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    800014d6:	6785                	lui	a5,0x1
    800014d8:	99be                	add	s3,s3,a5
    800014da:	fb49eee3          	bltu	s3,s4,80001496 <uvmcopy+0x20>
    800014de:	a805                	j	8000150e <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    800014e0:	00006517          	auipc	a0,0x6
    800014e4:	cc850513          	addi	a0,a0,-824 # 800071a8 <etext+0x1a8>
    800014e8:	aacff0ef          	jal	80000794 <panic>
      panic("uvmcopy: page not present");
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	cdc50513          	addi	a0,a0,-804 # 800071c8 <etext+0x1c8>
    800014f4:	aa0ff0ef          	jal	80000794 <panic>
      kfree(mem);
    800014f8:	854a                	mv	a0,s2
    800014fa:	d48ff0ef          	jal	80000a42 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014fe:	4685                	li	a3,1
    80001500:	00c9d613          	srli	a2,s3,0xc
    80001504:	4581                	li	a1,0
    80001506:	8556                	mv	a0,s5
    80001508:	cb3ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000150c:	557d                	li	a0,-1
}
    8000150e:	60a6                	ld	ra,72(sp)
    80001510:	6406                	ld	s0,64(sp)
    80001512:	74e2                	ld	s1,56(sp)
    80001514:	7942                	ld	s2,48(sp)
    80001516:	79a2                	ld	s3,40(sp)
    80001518:	7a02                	ld	s4,32(sp)
    8000151a:	6ae2                	ld	s5,24(sp)
    8000151c:	6b42                	ld	s6,16(sp)
    8000151e:	6ba2                	ld	s7,8(sp)
    80001520:	6161                	addi	sp,sp,80
    80001522:	8082                	ret
  return 0;
    80001524:	4501                	li	a0,0
}
    80001526:	8082                	ret

0000000080001528 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001528:	1141                	addi	sp,sp,-16
    8000152a:	e406                	sd	ra,8(sp)
    8000152c:	e022                	sd	s0,0(sp)
    8000152e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001530:	4601                	li	a2,0
    80001532:	a0bff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80001536:	c901                	beqz	a0,80001546 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001538:	611c                	ld	a5,0(a0)
    8000153a:	9bbd                	andi	a5,a5,-17
    8000153c:	e11c                	sd	a5,0(a0)
}
    8000153e:	60a2                	ld	ra,8(sp)
    80001540:	6402                	ld	s0,0(sp)
    80001542:	0141                	addi	sp,sp,16
    80001544:	8082                	ret
    panic("uvmclear");
    80001546:	00006517          	auipc	a0,0x6
    8000154a:	ca250513          	addi	a0,a0,-862 # 800071e8 <etext+0x1e8>
    8000154e:	a46ff0ef          	jal	80000794 <panic>

0000000080001552 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001552:	cad1                	beqz	a3,800015e6 <copyout+0x94>
{
    80001554:	711d                	addi	sp,sp,-96
    80001556:	ec86                	sd	ra,88(sp)
    80001558:	e8a2                	sd	s0,80(sp)
    8000155a:	e4a6                	sd	s1,72(sp)
    8000155c:	fc4e                	sd	s3,56(sp)
    8000155e:	f456                	sd	s5,40(sp)
    80001560:	f05a                	sd	s6,32(sp)
    80001562:	ec5e                	sd	s7,24(sp)
    80001564:	1080                	addi	s0,sp,96
    80001566:	8baa                	mv	s7,a0
    80001568:	8aae                	mv	s5,a1
    8000156a:	8b32                	mv	s6,a2
    8000156c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000156e:	74fd                	lui	s1,0xfffff
    80001570:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001572:	57fd                	li	a5,-1
    80001574:	83e9                	srli	a5,a5,0x1a
    80001576:	0697ea63          	bltu	a5,s1,800015ea <copyout+0x98>
    8000157a:	e0ca                	sd	s2,64(sp)
    8000157c:	f852                	sd	s4,48(sp)
    8000157e:	e862                	sd	s8,16(sp)
    80001580:	e466                	sd	s9,8(sp)
    80001582:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001584:	4cd5                	li	s9,21
    80001586:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    80001588:	8c3e                	mv	s8,a5
    8000158a:	a025                	j	800015b2 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    8000158c:	83a9                	srli	a5,a5,0xa
    8000158e:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001590:	409a8533          	sub	a0,s5,s1
    80001594:	0009061b          	sext.w	a2,s2
    80001598:	85da                	mv	a1,s6
    8000159a:	953e                	add	a0,a0,a5
    8000159c:	f88ff0ef          	jal	80000d24 <memmove>

    len -= n;
    800015a0:	412989b3          	sub	s3,s3,s2
    src += n;
    800015a4:	9b4a                	add	s6,s6,s2
  while(len > 0){
    800015a6:	02098963          	beqz	s3,800015d8 <copyout+0x86>
    if(va0 >= MAXVA)
    800015aa:	054c6263          	bltu	s8,s4,800015ee <copyout+0x9c>
    800015ae:	84d2                	mv	s1,s4
    800015b0:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    800015b2:	4601                	li	a2,0
    800015b4:	85a6                	mv	a1,s1
    800015b6:	855e                	mv	a0,s7
    800015b8:	985ff0ef          	jal	80000f3c <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015bc:	c121                	beqz	a0,800015fc <copyout+0xaa>
    800015be:	611c                	ld	a5,0(a0)
    800015c0:	0157f713          	andi	a4,a5,21
    800015c4:	05971b63          	bne	a4,s9,8000161a <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    800015c8:	01a48a33          	add	s4,s1,s10
    800015cc:	415a0933          	sub	s2,s4,s5
    if(n > len)
    800015d0:	fb29fee3          	bgeu	s3,s2,8000158c <copyout+0x3a>
    800015d4:	894e                	mv	s2,s3
    800015d6:	bf5d                	j	8000158c <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    800015d8:	4501                	li	a0,0
    800015da:	6906                	ld	s2,64(sp)
    800015dc:	7a42                	ld	s4,48(sp)
    800015de:	6c42                	ld	s8,16(sp)
    800015e0:	6ca2                	ld	s9,8(sp)
    800015e2:	6d02                	ld	s10,0(sp)
    800015e4:	a015                	j	80001608 <copyout+0xb6>
    800015e6:	4501                	li	a0,0
}
    800015e8:	8082                	ret
      return -1;
    800015ea:	557d                	li	a0,-1
    800015ec:	a831                	j	80001608 <copyout+0xb6>
    800015ee:	557d                	li	a0,-1
    800015f0:	6906                	ld	s2,64(sp)
    800015f2:	7a42                	ld	s4,48(sp)
    800015f4:	6c42                	ld	s8,16(sp)
    800015f6:	6ca2                	ld	s9,8(sp)
    800015f8:	6d02                	ld	s10,0(sp)
    800015fa:	a039                	j	80001608 <copyout+0xb6>
      return -1;
    800015fc:	557d                	li	a0,-1
    800015fe:	6906                	ld	s2,64(sp)
    80001600:	7a42                	ld	s4,48(sp)
    80001602:	6c42                	ld	s8,16(sp)
    80001604:	6ca2                	ld	s9,8(sp)
    80001606:	6d02                	ld	s10,0(sp)
}
    80001608:	60e6                	ld	ra,88(sp)
    8000160a:	6446                	ld	s0,80(sp)
    8000160c:	64a6                	ld	s1,72(sp)
    8000160e:	79e2                	ld	s3,56(sp)
    80001610:	7aa2                	ld	s5,40(sp)
    80001612:	7b02                	ld	s6,32(sp)
    80001614:	6be2                	ld	s7,24(sp)
    80001616:	6125                	addi	sp,sp,96
    80001618:	8082                	ret
      return -1;
    8000161a:	557d                	li	a0,-1
    8000161c:	6906                	ld	s2,64(sp)
    8000161e:	7a42                	ld	s4,48(sp)
    80001620:	6c42                	ld	s8,16(sp)
    80001622:	6ca2                	ld	s9,8(sp)
    80001624:	6d02                	ld	s10,0(sp)
    80001626:	b7cd                	j	80001608 <copyout+0xb6>

0000000080001628 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001628:	c6a5                	beqz	a3,80001690 <copyin+0x68>
{
    8000162a:	715d                	addi	sp,sp,-80
    8000162c:	e486                	sd	ra,72(sp)
    8000162e:	e0a2                	sd	s0,64(sp)
    80001630:	fc26                	sd	s1,56(sp)
    80001632:	f84a                	sd	s2,48(sp)
    80001634:	f44e                	sd	s3,40(sp)
    80001636:	f052                	sd	s4,32(sp)
    80001638:	ec56                	sd	s5,24(sp)
    8000163a:	e85a                	sd	s6,16(sp)
    8000163c:	e45e                	sd	s7,8(sp)
    8000163e:	e062                	sd	s8,0(sp)
    80001640:	0880                	addi	s0,sp,80
    80001642:	8b2a                	mv	s6,a0
    80001644:	8a2e                	mv	s4,a1
    80001646:	8c32                	mv	s8,a2
    80001648:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000164a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000164c:	6a85                	lui	s5,0x1
    8000164e:	a00d                	j	80001670 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001650:	018505b3          	add	a1,a0,s8
    80001654:	0004861b          	sext.w	a2,s1
    80001658:	412585b3          	sub	a1,a1,s2
    8000165c:	8552                	mv	a0,s4
    8000165e:	ec6ff0ef          	jal	80000d24 <memmove>

    len -= n;
    80001662:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001666:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001668:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000166c:	02098063          	beqz	s3,8000168c <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80001670:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001674:	85ca                	mv	a1,s2
    80001676:	855a                	mv	a0,s6
    80001678:	95fff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    8000167c:	cd01                	beqz	a0,80001694 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    8000167e:	418904b3          	sub	s1,s2,s8
    80001682:	94d6                	add	s1,s1,s5
    if(n > len)
    80001684:	fc99f6e3          	bgeu	s3,s1,80001650 <copyin+0x28>
    80001688:	84ce                	mv	s1,s3
    8000168a:	b7d9                	j	80001650 <copyin+0x28>
  }
  return 0;
    8000168c:	4501                	li	a0,0
    8000168e:	a021                	j	80001696 <copyin+0x6e>
    80001690:	4501                	li	a0,0
}
    80001692:	8082                	ret
      return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6c02                	ld	s8,0(sp)
    800016aa:	6161                	addi	sp,sp,80
    800016ac:	8082                	ret

00000000800016ae <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800016ae:	c6dd                	beqz	a3,8000175c <copyinstr+0xae>
{
    800016b0:	715d                	addi	sp,sp,-80
    800016b2:	e486                	sd	ra,72(sp)
    800016b4:	e0a2                	sd	s0,64(sp)
    800016b6:	fc26                	sd	s1,56(sp)
    800016b8:	f84a                	sd	s2,48(sp)
    800016ba:	f44e                	sd	s3,40(sp)
    800016bc:	f052                	sd	s4,32(sp)
    800016be:	ec56                	sd	s5,24(sp)
    800016c0:	e85a                	sd	s6,16(sp)
    800016c2:	e45e                	sd	s7,8(sp)
    800016c4:	0880                	addi	s0,sp,80
    800016c6:	8a2a                	mv	s4,a0
    800016c8:	8b2e                	mv	s6,a1
    800016ca:	8bb2                	mv	s7,a2
    800016cc:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800016ce:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016d0:	6985                	lui	s3,0x1
    800016d2:	a825                	j	8000170a <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016d4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800016d8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016da:	37fd                	addiw	a5,a5,-1
    800016dc:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6161                	addi	sp,sp,80
    800016f4:	8082                	ret
    800016f6:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800016fa:	9742                	add	a4,a4,a6
      --max;
    800016fc:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001700:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001704:	04e58463          	beq	a1,a4,8000174c <copyinstr+0x9e>
{
    80001708:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000170a:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000170e:	85a6                	mv	a1,s1
    80001710:	8552                	mv	a0,s4
    80001712:	8c5ff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    80001716:	cd0d                	beqz	a0,80001750 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001718:	417486b3          	sub	a3,s1,s7
    8000171c:	96ce                	add	a3,a3,s3
    if(n > max)
    8000171e:	00d97363          	bgeu	s2,a3,80001724 <copyinstr+0x76>
    80001722:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001724:	955e                	add	a0,a0,s7
    80001726:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001728:	c695                	beqz	a3,80001754 <copyinstr+0xa6>
    8000172a:	87da                	mv	a5,s6
    8000172c:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000172e:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001732:	96da                	add	a3,a3,s6
    80001734:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001736:	00f60733          	add	a4,a2,a5
    8000173a:	00074703          	lbu	a4,0(a4)
    8000173e:	db59                	beqz	a4,800016d4 <copyinstr+0x26>
        *dst = *p;
    80001740:	00e78023          	sb	a4,0(a5)
      dst++;
    80001744:	0785                	addi	a5,a5,1
    while(n > 0){
    80001746:	fed797e3          	bne	a5,a3,80001734 <copyinstr+0x86>
    8000174a:	b775                	j	800016f6 <copyinstr+0x48>
    8000174c:	4781                	li	a5,0
    8000174e:	b771                	j	800016da <copyinstr+0x2c>
      return -1;
    80001750:	557d                	li	a0,-1
    80001752:	b779                	j	800016e0 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001754:	6b85                	lui	s7,0x1
    80001756:	9ba6                	add	s7,s7,s1
    80001758:	87da                	mv	a5,s6
    8000175a:	b77d                	j	80001708 <copyinstr+0x5a>
  int got_null = 0;
    8000175c:	4781                	li	a5,0
  if(got_null){
    8000175e:	37fd                	addiw	a5,a5,-1
    80001760:	0007851b          	sext.w	a0,a5
}
    80001764:	8082                	ret

0000000080001766 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001766:	7139                	addi	sp,sp,-64
    80001768:	fc06                	sd	ra,56(sp)
    8000176a:	f822                	sd	s0,48(sp)
    8000176c:	f426                	sd	s1,40(sp)
    8000176e:	f04a                	sd	s2,32(sp)
    80001770:	ec4e                	sd	s3,24(sp)
    80001772:	e852                	sd	s4,16(sp)
    80001774:	e456                	sd	s5,8(sp)
    80001776:	e05a                	sd	s6,0(sp)
    80001778:	0080                	addi	s0,sp,64
    8000177a:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000177c:	0000e497          	auipc	s1,0xe
    80001780:	6f448493          	addi	s1,s1,1780 # 8000fe70 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001784:	8b26                	mv	s6,s1
    80001786:	bdef8937          	lui	s2,0xbdef8
    8000178a:	bdf90913          	addi	s2,s2,-1057 # ffffffffbdef7bdf <end+0xffffffff3ded4d8f>
    8000178e:	093e                	slli	s2,s2,0xf
    80001790:	bdf90913          	addi	s2,s2,-1057
    80001794:	093e                	slli	s2,s2,0xf
    80001796:	bdf90913          	addi	s2,s2,-1057
    8000179a:	040009b7          	lui	s3,0x4000
    8000179e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017a0:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017a2:	00016a97          	auipc	s5,0x16
    800017a6:	2cea8a93          	addi	s5,s5,718 # 80017a70 <tickslock>
    char *pa = kalloc();
    800017aa:	b7aff0ef          	jal	80000b24 <kalloc>
    800017ae:	862a                	mv	a2,a0
    if(pa == 0)
    800017b0:	cd15                	beqz	a0,800017ec <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    800017b2:	416485b3          	sub	a1,s1,s6
    800017b6:	8591                	srai	a1,a1,0x4
    800017b8:	032585b3          	mul	a1,a1,s2
    800017bc:	2585                	addiw	a1,a1,1
    800017be:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017c2:	4719                	li	a4,6
    800017c4:	6685                	lui	a3,0x1
    800017c6:	40b985b3          	sub	a1,s3,a1
    800017ca:	8552                	mv	a0,s4
    800017cc:	8f9ff0ef          	jal	800010c4 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d0:	1f048493          	addi	s1,s1,496
    800017d4:	fd549be3          	bne	s1,s5,800017aa <proc_mapstacks+0x44>
  }
}
    800017d8:	70e2                	ld	ra,56(sp)
    800017da:	7442                	ld	s0,48(sp)
    800017dc:	74a2                	ld	s1,40(sp)
    800017de:	7902                	ld	s2,32(sp)
    800017e0:	69e2                	ld	s3,24(sp)
    800017e2:	6a42                	ld	s4,16(sp)
    800017e4:	6aa2                	ld	s5,8(sp)
    800017e6:	6b02                	ld	s6,0(sp)
    800017e8:	6121                	addi	sp,sp,64
    800017ea:	8082                	ret
      panic("kalloc");
    800017ec:	00006517          	auipc	a0,0x6
    800017f0:	a0c50513          	addi	a0,a0,-1524 # 800071f8 <etext+0x1f8>
    800017f4:	fa1fe0ef          	jal	80000794 <panic>

00000000800017f8 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017f8:	7139                	addi	sp,sp,-64
    800017fa:	fc06                	sd	ra,56(sp)
    800017fc:	f822                	sd	s0,48(sp)
    800017fe:	f426                	sd	s1,40(sp)
    80001800:	f04a                	sd	s2,32(sp)
    80001802:	ec4e                	sd	s3,24(sp)
    80001804:	e852                	sd	s4,16(sp)
    80001806:	e456                	sd	s5,8(sp)
    80001808:	e05a                	sd	s6,0(sp)
    8000180a:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000180c:	00006597          	auipc	a1,0x6
    80001810:	9f458593          	addi	a1,a1,-1548 # 80007200 <etext+0x200>
    80001814:	0000e517          	auipc	a0,0xe
    80001818:	22c50513          	addi	a0,a0,556 # 8000fa40 <pid_lock>
    8000181c:	b58ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001820:	00006597          	auipc	a1,0x6
    80001824:	9e858593          	addi	a1,a1,-1560 # 80007208 <etext+0x208>
    80001828:	0000e517          	auipc	a0,0xe
    8000182c:	23050513          	addi	a0,a0,560 # 8000fa58 <wait_lock>
    80001830:	b44ff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001834:	0000e497          	auipc	s1,0xe
    80001838:	63c48493          	addi	s1,s1,1596 # 8000fe70 <proc>
      initlock(&p->lock, "proc");
    8000183c:	00006b17          	auipc	s6,0x6
    80001840:	9dcb0b13          	addi	s6,s6,-1572 # 80007218 <etext+0x218>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001844:	8aa6                	mv	s5,s1
    80001846:	bdef8937          	lui	s2,0xbdef8
    8000184a:	bdf90913          	addi	s2,s2,-1057 # ffffffffbdef7bdf <end+0xffffffff3ded4d8f>
    8000184e:	093e                	slli	s2,s2,0xf
    80001850:	bdf90913          	addi	s2,s2,-1057
    80001854:	093e                	slli	s2,s2,0xf
    80001856:	bdf90913          	addi	s2,s2,-1057
    8000185a:	040009b7          	lui	s3,0x4000
    8000185e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001860:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001862:	00016a17          	auipc	s4,0x16
    80001866:	20ea0a13          	addi	s4,s4,526 # 80017a70 <tickslock>
      initlock(&p->lock, "proc");
    8000186a:	85da                	mv	a1,s6
    8000186c:	8526                	mv	a0,s1
    8000186e:	b06ff0ef          	jal	80000b74 <initlock>
      p->state = UNUSED;
    80001872:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001876:	415487b3          	sub	a5,s1,s5
    8000187a:	8791                	srai	a5,a5,0x4
    8000187c:	032787b3          	mul	a5,a5,s2
    80001880:	2785                	addiw	a5,a5,1
    80001882:	00d7979b          	slliw	a5,a5,0xd
    80001886:	40f987b3          	sub	a5,s3,a5
    8000188a:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000188c:	1f048493          	addi	s1,s1,496
    80001890:	fd449de3          	bne	s1,s4,8000186a <procinit+0x72>
  }
}
    80001894:	70e2                	ld	ra,56(sp)
    80001896:	7442                	ld	s0,48(sp)
    80001898:	74a2                	ld	s1,40(sp)
    8000189a:	7902                	ld	s2,32(sp)
    8000189c:	69e2                	ld	s3,24(sp)
    8000189e:	6a42                	ld	s4,16(sp)
    800018a0:	6aa2                	ld	s5,8(sp)
    800018a2:	6b02                	ld	s6,0(sp)
    800018a4:	6121                	addi	sp,sp,64
    800018a6:	8082                	ret

00000000800018a8 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018a8:	1141                	addi	sp,sp,-16
    800018aa:	e422                	sd	s0,8(sp)
    800018ac:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018ae:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018b0:	2501                	sext.w	a0,a0
    800018b2:	6422                	ld	s0,8(sp)
    800018b4:	0141                	addi	sp,sp,16
    800018b6:	8082                	ret

00000000800018b8 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018b8:	1141                	addi	sp,sp,-16
    800018ba:	e422                	sd	s0,8(sp)
    800018bc:	0800                	addi	s0,sp,16
    800018be:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018c0:	2781                	sext.w	a5,a5
    800018c2:	079e                	slli	a5,a5,0x7
  return c;
}
    800018c4:	0000e517          	auipc	a0,0xe
    800018c8:	1ac50513          	addi	a0,a0,428 # 8000fa70 <cpus>
    800018cc:	953e                	add	a0,a0,a5
    800018ce:	6422                	ld	s0,8(sp)
    800018d0:	0141                	addi	sp,sp,16
    800018d2:	8082                	ret

00000000800018d4 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018d4:	1101                	addi	sp,sp,-32
    800018d6:	ec06                	sd	ra,24(sp)
    800018d8:	e822                	sd	s0,16(sp)
    800018da:	e426                	sd	s1,8(sp)
    800018dc:	1000                	addi	s0,sp,32
  push_off();
    800018de:	ad6ff0ef          	jal	80000bb4 <push_off>
    800018e2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018e4:	2781                	sext.w	a5,a5
    800018e6:	079e                	slli	a5,a5,0x7
    800018e8:	0000e717          	auipc	a4,0xe
    800018ec:	15870713          	addi	a4,a4,344 # 8000fa40 <pid_lock>
    800018f0:	97ba                	add	a5,a5,a4
    800018f2:	7b84                	ld	s1,48(a5)
  pop_off();
    800018f4:	b44ff0ef          	jal	80000c38 <pop_off>
  return p;
}
    800018f8:	8526                	mv	a0,s1
    800018fa:	60e2                	ld	ra,24(sp)
    800018fc:	6442                	ld	s0,16(sp)
    800018fe:	64a2                	ld	s1,8(sp)
    80001900:	6105                	addi	sp,sp,32
    80001902:	8082                	ret

0000000080001904 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001904:	1141                	addi	sp,sp,-16
    80001906:	e406                	sd	ra,8(sp)
    80001908:	e022                	sd	s0,0(sp)
    8000190a:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    8000190c:	fc9ff0ef          	jal	800018d4 <myproc>
    80001910:	b7cff0ef          	jal	80000c8c <release>

  if (first) {
    80001914:	00006797          	auipc	a5,0x6
    80001918:	f7c7a783          	lw	a5,-132(a5) # 80007890 <first.1>
    8000191c:	e799                	bnez	a5,8000192a <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000191e:	63f000ef          	jal	8000275c <usertrapret>
}
    80001922:	60a2                	ld	ra,8(sp)
    80001924:	6402                	ld	s0,0(sp)
    80001926:	0141                	addi	sp,sp,16
    80001928:	8082                	ret
    fsinit(ROOTDEV);
    8000192a:	4505                	li	a0,1
    8000192c:	265010ef          	jal	80003390 <fsinit>
    first = 0;
    80001930:	00006797          	auipc	a5,0x6
    80001934:	f607a023          	sw	zero,-160(a5) # 80007890 <first.1>
    __sync_synchronize();
    80001938:	0ff0000f          	fence
    8000193c:	b7cd                	j	8000191e <forkret+0x1a>

000000008000193e <allocpid>:
{
    8000193e:	1101                	addi	sp,sp,-32
    80001940:	ec06                	sd	ra,24(sp)
    80001942:	e822                	sd	s0,16(sp)
    80001944:	e426                	sd	s1,8(sp)
    80001946:	e04a                	sd	s2,0(sp)
    80001948:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    8000194a:	0000e917          	auipc	s2,0xe
    8000194e:	0f690913          	addi	s2,s2,246 # 8000fa40 <pid_lock>
    80001952:	854a                	mv	a0,s2
    80001954:	aa0ff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    80001958:	00006797          	auipc	a5,0x6
    8000195c:	f3c78793          	addi	a5,a5,-196 # 80007894 <nextpid>
    80001960:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001962:	0014871b          	addiw	a4,s1,1
    80001966:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001968:	854a                	mv	a0,s2
    8000196a:	b22ff0ef          	jal	80000c8c <release>
}
    8000196e:	8526                	mv	a0,s1
    80001970:	60e2                	ld	ra,24(sp)
    80001972:	6442                	ld	s0,16(sp)
    80001974:	64a2                	ld	s1,8(sp)
    80001976:	6902                	ld	s2,0(sp)
    80001978:	6105                	addi	sp,sp,32
    8000197a:	8082                	ret

000000008000197c <proc_pagetable>:
{
    8000197c:	1101                	addi	sp,sp,-32
    8000197e:	ec06                	sd	ra,24(sp)
    80001980:	e822                	sd	s0,16(sp)
    80001982:	e426                	sd	s1,8(sp)
    80001984:	e04a                	sd	s2,0(sp)
    80001986:	1000                	addi	s0,sp,32
    80001988:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    8000198a:	8edff0ef          	jal	80001276 <uvmcreate>
    8000198e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001990:	cd05                	beqz	a0,800019c8 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001992:	4729                	li	a4,10
    80001994:	00004697          	auipc	a3,0x4
    80001998:	66c68693          	addi	a3,a3,1644 # 80006000 <_trampoline>
    8000199c:	6605                	lui	a2,0x1
    8000199e:	040005b7          	lui	a1,0x4000
    800019a2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019a4:	05b2                	slli	a1,a1,0xc
    800019a6:	e6eff0ef          	jal	80001014 <mappages>
    800019aa:	02054663          	bltz	a0,800019d6 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019ae:	4719                	li	a4,6
    800019b0:	05893683          	ld	a3,88(s2)
    800019b4:	6605                	lui	a2,0x1
    800019b6:	020005b7          	lui	a1,0x2000
    800019ba:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019bc:	05b6                	slli	a1,a1,0xd
    800019be:	8526                	mv	a0,s1
    800019c0:	e54ff0ef          	jal	80001014 <mappages>
    800019c4:	00054f63          	bltz	a0,800019e2 <proc_pagetable+0x66>
}
    800019c8:	8526                	mv	a0,s1
    800019ca:	60e2                	ld	ra,24(sp)
    800019cc:	6442                	ld	s0,16(sp)
    800019ce:	64a2                	ld	s1,8(sp)
    800019d0:	6902                	ld	s2,0(sp)
    800019d2:	6105                	addi	sp,sp,32
    800019d4:	8082                	ret
    uvmfree(pagetable, 0);
    800019d6:	4581                	li	a1,0
    800019d8:	8526                	mv	a0,s1
    800019da:	a6bff0ef          	jal	80001444 <uvmfree>
    return 0;
    800019de:	4481                	li	s1,0
    800019e0:	b7e5                	j	800019c8 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019e2:	4681                	li	a3,0
    800019e4:	4605                	li	a2,1
    800019e6:	040005b7          	lui	a1,0x4000
    800019ea:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019ec:	05b2                	slli	a1,a1,0xc
    800019ee:	8526                	mv	a0,s1
    800019f0:	fcaff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    800019f4:	4581                	li	a1,0
    800019f6:	8526                	mv	a0,s1
    800019f8:	a4dff0ef          	jal	80001444 <uvmfree>
    return 0;
    800019fc:	4481                	li	s1,0
    800019fe:	b7e9                	j	800019c8 <proc_pagetable+0x4c>

0000000080001a00 <proc_freepagetable>:
{
    80001a00:	1101                	addi	sp,sp,-32
    80001a02:	ec06                	sd	ra,24(sp)
    80001a04:	e822                	sd	s0,16(sp)
    80001a06:	e426                	sd	s1,8(sp)
    80001a08:	e04a                	sd	s2,0(sp)
    80001a0a:	1000                	addi	s0,sp,32
    80001a0c:	84aa                	mv	s1,a0
    80001a0e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a10:	4681                	li	a3,0
    80001a12:	4605                	li	a2,1
    80001a14:	040005b7          	lui	a1,0x4000
    80001a18:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a1a:	05b2                	slli	a1,a1,0xc
    80001a1c:	f9eff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a20:	4681                	li	a3,0
    80001a22:	4605                	li	a2,1
    80001a24:	020005b7          	lui	a1,0x2000
    80001a28:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a2a:	05b6                	slli	a1,a1,0xd
    80001a2c:	8526                	mv	a0,s1
    80001a2e:	f8cff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001a32:	85ca                	mv	a1,s2
    80001a34:	8526                	mv	a0,s1
    80001a36:	a0fff0ef          	jal	80001444 <uvmfree>
}
    80001a3a:	60e2                	ld	ra,24(sp)
    80001a3c:	6442                	ld	s0,16(sp)
    80001a3e:	64a2                	ld	s1,8(sp)
    80001a40:	6902                	ld	s2,0(sp)
    80001a42:	6105                	addi	sp,sp,32
    80001a44:	8082                	ret

0000000080001a46 <freeproc>:
{
    80001a46:	1101                	addi	sp,sp,-32
    80001a48:	ec06                	sd	ra,24(sp)
    80001a4a:	e822                	sd	s0,16(sp)
    80001a4c:	e426                	sd	s1,8(sp)
    80001a4e:	1000                	addi	s0,sp,32
    80001a50:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a52:	6d28                	ld	a0,88(a0)
    80001a54:	c119                	beqz	a0,80001a5a <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a56:	fedfe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80001a5a:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a5e:	68a8                	ld	a0,80(s1)
    80001a60:	c501                	beqz	a0,80001a68 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a62:	64ac                	ld	a1,72(s1)
    80001a64:	f9dff0ef          	jal	80001a00 <proc_freepagetable>
  p->pagetable = 0;
    80001a68:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a6c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a70:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a74:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a78:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a7c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a80:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a84:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a88:	0004ac23          	sw	zero,24(s1)
}
    80001a8c:	60e2                	ld	ra,24(sp)
    80001a8e:	6442                	ld	s0,16(sp)
    80001a90:	64a2                	ld	s1,8(sp)
    80001a92:	6105                	addi	sp,sp,32
    80001a94:	8082                	ret

0000000080001a96 <allocproc>:
{
    80001a96:	1101                	addi	sp,sp,-32
    80001a98:	ec06                	sd	ra,24(sp)
    80001a9a:	e822                	sd	s0,16(sp)
    80001a9c:	e426                	sd	s1,8(sp)
    80001a9e:	e04a                	sd	s2,0(sp)
    80001aa0:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aa2:	0000e497          	auipc	s1,0xe
    80001aa6:	3ce48493          	addi	s1,s1,974 # 8000fe70 <proc>
    80001aaa:	00016917          	auipc	s2,0x16
    80001aae:	fc690913          	addi	s2,s2,-58 # 80017a70 <tickslock>
    acquire(&p->lock);
    80001ab2:	8526                	mv	a0,s1
    80001ab4:	940ff0ef          	jal	80000bf4 <acquire>
    if(p->state == UNUSED) {
    80001ab8:	4c9c                	lw	a5,24(s1)
    80001aba:	cb91                	beqz	a5,80001ace <allocproc+0x38>
      release(&p->lock);
    80001abc:	8526                	mv	a0,s1
    80001abe:	9ceff0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ac2:	1f048493          	addi	s1,s1,496
    80001ac6:	ff2496e3          	bne	s1,s2,80001ab2 <allocproc+0x1c>
  return 0;
    80001aca:	4481                	li	s1,0
    80001acc:	a089                	j	80001b0e <allocproc+0x78>
  p->pid = allocpid();
    80001ace:	e71ff0ef          	jal	8000193e <allocpid>
    80001ad2:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ad4:	4785                	li	a5,1
    80001ad6:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ad8:	84cff0ef          	jal	80000b24 <kalloc>
    80001adc:	892a                	mv	s2,a0
    80001ade:	eca8                	sd	a0,88(s1)
    80001ae0:	cd15                	beqz	a0,80001b1c <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001ae2:	8526                	mv	a0,s1
    80001ae4:	e99ff0ef          	jal	8000197c <proc_pagetable>
    80001ae8:	892a                	mv	s2,a0
    80001aea:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001aec:	c121                	beqz	a0,80001b2c <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001aee:	07000613          	li	a2,112
    80001af2:	4581                	li	a1,0
    80001af4:	06048513          	addi	a0,s1,96
    80001af8:	9d0ff0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    80001afc:	00000797          	auipc	a5,0x0
    80001b00:	e0878793          	addi	a5,a5,-504 # 80001904 <forkret>
    80001b04:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b06:	60bc                	ld	a5,64(s1)
    80001b08:	6705                	lui	a4,0x1
    80001b0a:	97ba                	add	a5,a5,a4
    80001b0c:	f4bc                	sd	a5,104(s1)
}
    80001b0e:	8526                	mv	a0,s1
    80001b10:	60e2                	ld	ra,24(sp)
    80001b12:	6442                	ld	s0,16(sp)
    80001b14:	64a2                	ld	s1,8(sp)
    80001b16:	6902                	ld	s2,0(sp)
    80001b18:	6105                	addi	sp,sp,32
    80001b1a:	8082                	ret
    freeproc(p);
    80001b1c:	8526                	mv	a0,s1
    80001b1e:	f29ff0ef          	jal	80001a46 <freeproc>
    release(&p->lock);
    80001b22:	8526                	mv	a0,s1
    80001b24:	968ff0ef          	jal	80000c8c <release>
    return 0;
    80001b28:	84ca                	mv	s1,s2
    80001b2a:	b7d5                	j	80001b0e <allocproc+0x78>
    freeproc(p);
    80001b2c:	8526                	mv	a0,s1
    80001b2e:	f19ff0ef          	jal	80001a46 <freeproc>
    release(&p->lock);
    80001b32:	8526                	mv	a0,s1
    80001b34:	958ff0ef          	jal	80000c8c <release>
    return 0;
    80001b38:	84ca                	mv	s1,s2
    80001b3a:	bfd1                	j	80001b0e <allocproc+0x78>

0000000080001b3c <userinit>:
{
    80001b3c:	1101                	addi	sp,sp,-32
    80001b3e:	ec06                	sd	ra,24(sp)
    80001b40:	e822                	sd	s0,16(sp)
    80001b42:	e426                	sd	s1,8(sp)
    80001b44:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b46:	f51ff0ef          	jal	80001a96 <allocproc>
    80001b4a:	84aa                	mv	s1,a0
  initproc = p;
    80001b4c:	00006797          	auipc	a5,0x6
    80001b50:	daa7be23          	sd	a0,-580(a5) # 80007908 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b54:	03400613          	li	a2,52
    80001b58:	00006597          	auipc	a1,0x6
    80001b5c:	d4858593          	addi	a1,a1,-696 # 800078a0 <initcode>
    80001b60:	6928                	ld	a0,80(a0)
    80001b62:	f3aff0ef          	jal	8000129c <uvmfirst>
  p->sz = PGSIZE;
    80001b66:	6785                	lui	a5,0x1
    80001b68:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001b6a:	6cb8                	ld	a4,88(s1)
    80001b6c:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001b70:	6cb8                	ld	a4,88(s1)
    80001b72:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001b74:	4641                	li	a2,16
    80001b76:	00005597          	auipc	a1,0x5
    80001b7a:	6aa58593          	addi	a1,a1,1706 # 80007220 <etext+0x220>
    80001b7e:	15848513          	addi	a0,s1,344
    80001b82:	a84ff0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80001b86:	00005517          	auipc	a0,0x5
    80001b8a:	6aa50513          	addi	a0,a0,1706 # 80007230 <etext+0x230>
    80001b8e:	110020ef          	jal	80003c9e <namei>
    80001b92:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001b96:	478d                	li	a5,3
    80001b98:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001b9a:	8526                	mv	a0,s1
    80001b9c:	8f0ff0ef          	jal	80000c8c <release>
}
    80001ba0:	60e2                	ld	ra,24(sp)
    80001ba2:	6442                	ld	s0,16(sp)
    80001ba4:	64a2                	ld	s1,8(sp)
    80001ba6:	6105                	addi	sp,sp,32
    80001ba8:	8082                	ret

0000000080001baa <growproc>:
{
    80001baa:	1101                	addi	sp,sp,-32
    80001bac:	ec06                	sd	ra,24(sp)
    80001bae:	e822                	sd	s0,16(sp)
    80001bb0:	e426                	sd	s1,8(sp)
    80001bb2:	e04a                	sd	s2,0(sp)
    80001bb4:	1000                	addi	s0,sp,32
    80001bb6:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bb8:	d1dff0ef          	jal	800018d4 <myproc>
    80001bbc:	84aa                	mv	s1,a0
  sz = p->sz;
    80001bbe:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bc0:	01204c63          	bgtz	s2,80001bd8 <growproc+0x2e>
  } else if(n < 0){
    80001bc4:	02094463          	bltz	s2,80001bec <growproc+0x42>
  p->sz = sz;
    80001bc8:	e4ac                	sd	a1,72(s1)
  return 0;
    80001bca:	4501                	li	a0,0
}
    80001bcc:	60e2                	ld	ra,24(sp)
    80001bce:	6442                	ld	s0,16(sp)
    80001bd0:	64a2                	ld	s1,8(sp)
    80001bd2:	6902                	ld	s2,0(sp)
    80001bd4:	6105                	addi	sp,sp,32
    80001bd6:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001bd8:	4691                	li	a3,4
    80001bda:	00b90633          	add	a2,s2,a1
    80001bde:	6928                	ld	a0,80(a0)
    80001be0:	f5eff0ef          	jal	8000133e <uvmalloc>
    80001be4:	85aa                	mv	a1,a0
    80001be6:	f16d                	bnez	a0,80001bc8 <growproc+0x1e>
      return -1;
    80001be8:	557d                	li	a0,-1
    80001bea:	b7cd                	j	80001bcc <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001bec:	00b90633          	add	a2,s2,a1
    80001bf0:	6928                	ld	a0,80(a0)
    80001bf2:	f08ff0ef          	jal	800012fa <uvmdealloc>
    80001bf6:	85aa                	mv	a1,a0
    80001bf8:	bfc1                	j	80001bc8 <growproc+0x1e>

0000000080001bfa <fork>:
{
    80001bfa:	7139                	addi	sp,sp,-64
    80001bfc:	fc06                	sd	ra,56(sp)
    80001bfe:	f822                	sd	s0,48(sp)
    80001c00:	f04a                	sd	s2,32(sp)
    80001c02:	e456                	sd	s5,8(sp)
    80001c04:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c06:	ccfff0ef          	jal	800018d4 <myproc>
    80001c0a:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c0c:	e8bff0ef          	jal	80001a96 <allocproc>
    80001c10:	0e050a63          	beqz	a0,80001d04 <fork+0x10a>
    80001c14:	e852                	sd	s4,16(sp)
    80001c16:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c18:	048ab603          	ld	a2,72(s5)
    80001c1c:	692c                	ld	a1,80(a0)
    80001c1e:	050ab503          	ld	a0,80(s5)
    80001c22:	855ff0ef          	jal	80001476 <uvmcopy>
    80001c26:	04054a63          	bltz	a0,80001c7a <fork+0x80>
    80001c2a:	f426                	sd	s1,40(sp)
    80001c2c:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c2e:	048ab783          	ld	a5,72(s5)
    80001c32:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c36:	058ab683          	ld	a3,88(s5)
    80001c3a:	87b6                	mv	a5,a3
    80001c3c:	058a3703          	ld	a4,88(s4)
    80001c40:	12068693          	addi	a3,a3,288
    80001c44:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c48:	6788                	ld	a0,8(a5)
    80001c4a:	6b8c                	ld	a1,16(a5)
    80001c4c:	6f90                	ld	a2,24(a5)
    80001c4e:	01073023          	sd	a6,0(a4)
    80001c52:	e708                	sd	a0,8(a4)
    80001c54:	eb0c                	sd	a1,16(a4)
    80001c56:	ef10                	sd	a2,24(a4)
    80001c58:	02078793          	addi	a5,a5,32
    80001c5c:	02070713          	addi	a4,a4,32
    80001c60:	fed792e3          	bne	a5,a3,80001c44 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001c64:	058a3783          	ld	a5,88(s4)
    80001c68:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001c6c:	0d0a8493          	addi	s1,s5,208
    80001c70:	0d0a0913          	addi	s2,s4,208
    80001c74:	150a8993          	addi	s3,s5,336
    80001c78:	a831                	j	80001c94 <fork+0x9a>
    freeproc(np);
    80001c7a:	8552                	mv	a0,s4
    80001c7c:	dcbff0ef          	jal	80001a46 <freeproc>
    release(&np->lock);
    80001c80:	8552                	mv	a0,s4
    80001c82:	80aff0ef          	jal	80000c8c <release>
    return -1;
    80001c86:	597d                	li	s2,-1
    80001c88:	6a42                	ld	s4,16(sp)
    80001c8a:	a0b5                	j	80001cf6 <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001c8c:	04a1                	addi	s1,s1,8
    80001c8e:	0921                	addi	s2,s2,8
    80001c90:	01348963          	beq	s1,s3,80001ca2 <fork+0xa8>
    if(p->ofile[i])
    80001c94:	6088                	ld	a0,0(s1)
    80001c96:	d97d                	beqz	a0,80001c8c <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001c98:	596020ef          	jal	8000422e <filedup>
    80001c9c:	00a93023          	sd	a0,0(s2)
    80001ca0:	b7f5                	j	80001c8c <fork+0x92>
  np->cwd = idup(p->cwd);
    80001ca2:	150ab503          	ld	a0,336(s5)
    80001ca6:	0e9010ef          	jal	8000358e <idup>
    80001caa:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cae:	4641                	li	a2,16
    80001cb0:	158a8593          	addi	a1,s5,344
    80001cb4:	158a0513          	addi	a0,s4,344
    80001cb8:	94eff0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    80001cbc:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001cc0:	8552                	mv	a0,s4
    80001cc2:	fcbfe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80001cc6:	0000e497          	auipc	s1,0xe
    80001cca:	d9248493          	addi	s1,s1,-622 # 8000fa58 <wait_lock>
    80001cce:	8526                	mv	a0,s1
    80001cd0:	f25fe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80001cd4:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001cd8:	8526                	mv	a0,s1
    80001cda:	fb3fe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    80001cde:	8552                	mv	a0,s4
    80001ce0:	f15fe0ef          	jal	80000bf4 <acquire>
  np->state = RUNNABLE;
    80001ce4:	478d                	li	a5,3
    80001ce6:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001cea:	8552                	mv	a0,s4
    80001cec:	fa1fe0ef          	jal	80000c8c <release>
  return pid;
    80001cf0:	74a2                	ld	s1,40(sp)
    80001cf2:	69e2                	ld	s3,24(sp)
    80001cf4:	6a42                	ld	s4,16(sp)
}
    80001cf6:	854a                	mv	a0,s2
    80001cf8:	70e2                	ld	ra,56(sp)
    80001cfa:	7442                	ld	s0,48(sp)
    80001cfc:	7902                	ld	s2,32(sp)
    80001cfe:	6aa2                	ld	s5,8(sp)
    80001d00:	6121                	addi	sp,sp,64
    80001d02:	8082                	ret
    return -1;
    80001d04:	597d                	li	s2,-1
    80001d06:	bfc5                	j	80001cf6 <fork+0xfc>

0000000080001d08 <scheduler>:
{
    80001d08:	715d                	addi	sp,sp,-80
    80001d0a:	e486                	sd	ra,72(sp)
    80001d0c:	e0a2                	sd	s0,64(sp)
    80001d0e:	fc26                	sd	s1,56(sp)
    80001d10:	f84a                	sd	s2,48(sp)
    80001d12:	f44e                	sd	s3,40(sp)
    80001d14:	f052                	sd	s4,32(sp)
    80001d16:	ec56                	sd	s5,24(sp)
    80001d18:	e85a                	sd	s6,16(sp)
    80001d1a:	e45e                	sd	s7,8(sp)
    80001d1c:	e062                	sd	s8,0(sp)
    80001d1e:	0880                	addi	s0,sp,80
    80001d20:	8792                	mv	a5,tp
  int id = r_tp();
    80001d22:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d24:	00779b13          	slli	s6,a5,0x7
    80001d28:	0000e717          	auipc	a4,0xe
    80001d2c:	d1870713          	addi	a4,a4,-744 # 8000fa40 <pid_lock>
    80001d30:	975a                	add	a4,a4,s6
    80001d32:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d36:	0000e717          	auipc	a4,0xe
    80001d3a:	d4270713          	addi	a4,a4,-702 # 8000fa78 <cpus+0x8>
    80001d3e:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d40:	4c11                	li	s8,4
        c->proc = p;
    80001d42:	079e                	slli	a5,a5,0x7
    80001d44:	0000ea17          	auipc	s4,0xe
    80001d48:	cfca0a13          	addi	s4,s4,-772 # 8000fa40 <pid_lock>
    80001d4c:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d4e:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d50:	00016997          	auipc	s3,0x16
    80001d54:	d2098993          	addi	s3,s3,-736 # 80017a70 <tickslock>
    80001d58:	a0a9                	j	80001da2 <scheduler+0x9a>
      release(&p->lock);
    80001d5a:	8526                	mv	a0,s1
    80001d5c:	f31fe0ef          	jal	80000c8c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d60:	1f048493          	addi	s1,s1,496
    80001d64:	03348563          	beq	s1,s3,80001d8e <scheduler+0x86>
      acquire(&p->lock);
    80001d68:	8526                	mv	a0,s1
    80001d6a:	e8bfe0ef          	jal	80000bf4 <acquire>
      if(p->state == RUNNABLE) {
    80001d6e:	4c9c                	lw	a5,24(s1)
    80001d70:	ff2795e3          	bne	a5,s2,80001d5a <scheduler+0x52>
        p->state = RUNNING;
    80001d74:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001d78:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001d7c:	06048593          	addi	a1,s1,96
    80001d80:	855a                	mv	a0,s6
    80001d82:	135000ef          	jal	800026b6 <swtch>
        c->proc = 0;
    80001d86:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001d8a:	8ade                	mv	s5,s7
    80001d8c:	b7f9                	j	80001d5a <scheduler+0x52>
    if(found == 0) {
    80001d8e:	000a9a63          	bnez	s5,80001da2 <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d92:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d96:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d9a:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001d9e:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001da2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001da6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001daa:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001dae:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001db0:	0000e497          	auipc	s1,0xe
    80001db4:	0c048493          	addi	s1,s1,192 # 8000fe70 <proc>
      if(p->state == RUNNABLE) {
    80001db8:	490d                	li	s2,3
    80001dba:	b77d                	j	80001d68 <scheduler+0x60>

0000000080001dbc <sched>:
{
    80001dbc:	7179                	addi	sp,sp,-48
    80001dbe:	f406                	sd	ra,40(sp)
    80001dc0:	f022                	sd	s0,32(sp)
    80001dc2:	ec26                	sd	s1,24(sp)
    80001dc4:	e84a                	sd	s2,16(sp)
    80001dc6:	e44e                	sd	s3,8(sp)
    80001dc8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dca:	b0bff0ef          	jal	800018d4 <myproc>
    80001dce:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001dd0:	dbbfe0ef          	jal	80000b8a <holding>
    80001dd4:	c92d                	beqz	a0,80001e46 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001dd6:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001dd8:	2781                	sext.w	a5,a5
    80001dda:	079e                	slli	a5,a5,0x7
    80001ddc:	0000e717          	auipc	a4,0xe
    80001de0:	c6470713          	addi	a4,a4,-924 # 8000fa40 <pid_lock>
    80001de4:	97ba                	add	a5,a5,a4
    80001de6:	0a87a703          	lw	a4,168(a5)
    80001dea:	4785                	li	a5,1
    80001dec:	06f71363          	bne	a4,a5,80001e52 <sched+0x96>
  if(p->state == RUNNING)
    80001df0:	4c98                	lw	a4,24(s1)
    80001df2:	4791                	li	a5,4
    80001df4:	06f70563          	beq	a4,a5,80001e5e <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001df8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001dfc:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001dfe:	e7b5                	bnez	a5,80001e6a <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e00:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e02:	0000e917          	auipc	s2,0xe
    80001e06:	c3e90913          	addi	s2,s2,-962 # 8000fa40 <pid_lock>
    80001e0a:	2781                	sext.w	a5,a5
    80001e0c:	079e                	slli	a5,a5,0x7
    80001e0e:	97ca                	add	a5,a5,s2
    80001e10:	0ac7a983          	lw	s3,172(a5)
    80001e14:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e16:	2781                	sext.w	a5,a5
    80001e18:	079e                	slli	a5,a5,0x7
    80001e1a:	0000e597          	auipc	a1,0xe
    80001e1e:	c5e58593          	addi	a1,a1,-930 # 8000fa78 <cpus+0x8>
    80001e22:	95be                	add	a1,a1,a5
    80001e24:	06048513          	addi	a0,s1,96
    80001e28:	08f000ef          	jal	800026b6 <swtch>
    80001e2c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e2e:	2781                	sext.w	a5,a5
    80001e30:	079e                	slli	a5,a5,0x7
    80001e32:	993e                	add	s2,s2,a5
    80001e34:	0b392623          	sw	s3,172(s2)
}
    80001e38:	70a2                	ld	ra,40(sp)
    80001e3a:	7402                	ld	s0,32(sp)
    80001e3c:	64e2                	ld	s1,24(sp)
    80001e3e:	6942                	ld	s2,16(sp)
    80001e40:	69a2                	ld	s3,8(sp)
    80001e42:	6145                	addi	sp,sp,48
    80001e44:	8082                	ret
    panic("sched p->lock");
    80001e46:	00005517          	auipc	a0,0x5
    80001e4a:	3f250513          	addi	a0,a0,1010 # 80007238 <etext+0x238>
    80001e4e:	947fe0ef          	jal	80000794 <panic>
    panic("sched locks");
    80001e52:	00005517          	auipc	a0,0x5
    80001e56:	3f650513          	addi	a0,a0,1014 # 80007248 <etext+0x248>
    80001e5a:	93bfe0ef          	jal	80000794 <panic>
    panic("sched running");
    80001e5e:	00005517          	auipc	a0,0x5
    80001e62:	3fa50513          	addi	a0,a0,1018 # 80007258 <etext+0x258>
    80001e66:	92ffe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    80001e6a:	00005517          	auipc	a0,0x5
    80001e6e:	3fe50513          	addi	a0,a0,1022 # 80007268 <etext+0x268>
    80001e72:	923fe0ef          	jal	80000794 <panic>

0000000080001e76 <yield>:
{
    80001e76:	1101                	addi	sp,sp,-32
    80001e78:	ec06                	sd	ra,24(sp)
    80001e7a:	e822                	sd	s0,16(sp)
    80001e7c:	e426                	sd	s1,8(sp)
    80001e7e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001e80:	a55ff0ef          	jal	800018d4 <myproc>
    80001e84:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001e86:	d6ffe0ef          	jal	80000bf4 <acquire>
  p->state = RUNNABLE;
    80001e8a:	478d                	li	a5,3
    80001e8c:	cc9c                	sw	a5,24(s1)
  sched();
    80001e8e:	f2fff0ef          	jal	80001dbc <sched>
  release(&p->lock);
    80001e92:	8526                	mv	a0,s1
    80001e94:	df9fe0ef          	jal	80000c8c <release>
}
    80001e98:	60e2                	ld	ra,24(sp)
    80001e9a:	6442                	ld	s0,16(sp)
    80001e9c:	64a2                	ld	s1,8(sp)
    80001e9e:	6105                	addi	sp,sp,32
    80001ea0:	8082                	ret

0000000080001ea2 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001ea2:	7179                	addi	sp,sp,-48
    80001ea4:	f406                	sd	ra,40(sp)
    80001ea6:	f022                	sd	s0,32(sp)
    80001ea8:	ec26                	sd	s1,24(sp)
    80001eaa:	e84a                	sd	s2,16(sp)
    80001eac:	e44e                	sd	s3,8(sp)
    80001eae:	1800                	addi	s0,sp,48
    80001eb0:	89aa                	mv	s3,a0
    80001eb2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001eb4:	a21ff0ef          	jal	800018d4 <myproc>
    80001eb8:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001eba:	d3bfe0ef          	jal	80000bf4 <acquire>
  release(lk);
    80001ebe:	854a                	mv	a0,s2
    80001ec0:	dcdfe0ef          	jal	80000c8c <release>

  // Go to sleep.
  p->chan = chan;
    80001ec4:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001ec8:	4789                	li	a5,2
    80001eca:	cc9c                	sw	a5,24(s1)

  sched();
    80001ecc:	ef1ff0ef          	jal	80001dbc <sched>

  // Tidy up.
  p->chan = 0;
    80001ed0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001ed4:	8526                	mv	a0,s1
    80001ed6:	db7fe0ef          	jal	80000c8c <release>
  acquire(lk);
    80001eda:	854a                	mv	a0,s2
    80001edc:	d19fe0ef          	jal	80000bf4 <acquire>
}
    80001ee0:	70a2                	ld	ra,40(sp)
    80001ee2:	7402                	ld	s0,32(sp)
    80001ee4:	64e2                	ld	s1,24(sp)
    80001ee6:	6942                	ld	s2,16(sp)
    80001ee8:	69a2                	ld	s3,8(sp)
    80001eea:	6145                	addi	sp,sp,48
    80001eec:	8082                	ret

0000000080001eee <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001eee:	7139                	addi	sp,sp,-64
    80001ef0:	fc06                	sd	ra,56(sp)
    80001ef2:	f822                	sd	s0,48(sp)
    80001ef4:	f426                	sd	s1,40(sp)
    80001ef6:	f04a                	sd	s2,32(sp)
    80001ef8:	ec4e                	sd	s3,24(sp)
    80001efa:	e852                	sd	s4,16(sp)
    80001efc:	e456                	sd	s5,8(sp)
    80001efe:	0080                	addi	s0,sp,64
    80001f00:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f02:	0000e497          	auipc	s1,0xe
    80001f06:	f6e48493          	addi	s1,s1,-146 # 8000fe70 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f0a:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f0c:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f0e:	00016917          	auipc	s2,0x16
    80001f12:	b6290913          	addi	s2,s2,-1182 # 80017a70 <tickslock>
    80001f16:	a801                	j	80001f26 <wakeup+0x38>
      }
      release(&p->lock);
    80001f18:	8526                	mv	a0,s1
    80001f1a:	d73fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f1e:	1f048493          	addi	s1,s1,496
    80001f22:	03248263          	beq	s1,s2,80001f46 <wakeup+0x58>
    if(p != myproc()){
    80001f26:	9afff0ef          	jal	800018d4 <myproc>
    80001f2a:	fea48ae3          	beq	s1,a0,80001f1e <wakeup+0x30>
      acquire(&p->lock);
    80001f2e:	8526                	mv	a0,s1
    80001f30:	cc5fe0ef          	jal	80000bf4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f34:	4c9c                	lw	a5,24(s1)
    80001f36:	ff3791e3          	bne	a5,s3,80001f18 <wakeup+0x2a>
    80001f3a:	709c                	ld	a5,32(s1)
    80001f3c:	fd479ee3          	bne	a5,s4,80001f18 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f40:	0154ac23          	sw	s5,24(s1)
    80001f44:	bfd1                	j	80001f18 <wakeup+0x2a>
    }
  }
}
    80001f46:	70e2                	ld	ra,56(sp)
    80001f48:	7442                	ld	s0,48(sp)
    80001f4a:	74a2                	ld	s1,40(sp)
    80001f4c:	7902                	ld	s2,32(sp)
    80001f4e:	69e2                	ld	s3,24(sp)
    80001f50:	6a42                	ld	s4,16(sp)
    80001f52:	6aa2                	ld	s5,8(sp)
    80001f54:	6121                	addi	sp,sp,64
    80001f56:	8082                	ret

0000000080001f58 <reparent>:
{
    80001f58:	7179                	addi	sp,sp,-48
    80001f5a:	f406                	sd	ra,40(sp)
    80001f5c:	f022                	sd	s0,32(sp)
    80001f5e:	ec26                	sd	s1,24(sp)
    80001f60:	e84a                	sd	s2,16(sp)
    80001f62:	e44e                	sd	s3,8(sp)
    80001f64:	e052                	sd	s4,0(sp)
    80001f66:	1800                	addi	s0,sp,48
    80001f68:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f6a:	0000e497          	auipc	s1,0xe
    80001f6e:	f0648493          	addi	s1,s1,-250 # 8000fe70 <proc>
      pp->parent = initproc;
    80001f72:	00006a17          	auipc	s4,0x6
    80001f76:	996a0a13          	addi	s4,s4,-1642 # 80007908 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f7a:	00016997          	auipc	s3,0x16
    80001f7e:	af698993          	addi	s3,s3,-1290 # 80017a70 <tickslock>
    80001f82:	a029                	j	80001f8c <reparent+0x34>
    80001f84:	1f048493          	addi	s1,s1,496
    80001f88:	01348b63          	beq	s1,s3,80001f9e <reparent+0x46>
    if(pp->parent == p){
    80001f8c:	7c9c                	ld	a5,56(s1)
    80001f8e:	ff279be3          	bne	a5,s2,80001f84 <reparent+0x2c>
      pp->parent = initproc;
    80001f92:	000a3503          	ld	a0,0(s4)
    80001f96:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001f98:	f57ff0ef          	jal	80001eee <wakeup>
    80001f9c:	b7e5                	j	80001f84 <reparent+0x2c>
}
    80001f9e:	70a2                	ld	ra,40(sp)
    80001fa0:	7402                	ld	s0,32(sp)
    80001fa2:	64e2                	ld	s1,24(sp)
    80001fa4:	6942                	ld	s2,16(sp)
    80001fa6:	69a2                	ld	s3,8(sp)
    80001fa8:	6a02                	ld	s4,0(sp)
    80001faa:	6145                	addi	sp,sp,48
    80001fac:	8082                	ret

0000000080001fae <exit>:
{
    80001fae:	7179                	addi	sp,sp,-48
    80001fb0:	f406                	sd	ra,40(sp)
    80001fb2:	f022                	sd	s0,32(sp)
    80001fb4:	ec26                	sd	s1,24(sp)
    80001fb6:	e84a                	sd	s2,16(sp)
    80001fb8:	e44e                	sd	s3,8(sp)
    80001fba:	e052                	sd	s4,0(sp)
    80001fbc:	1800                	addi	s0,sp,48
    80001fbe:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001fc0:	915ff0ef          	jal	800018d4 <myproc>
    80001fc4:	89aa                	mv	s3,a0
  if(p == initproc)
    80001fc6:	00006797          	auipc	a5,0x6
    80001fca:	9427b783          	ld	a5,-1726(a5) # 80007908 <initproc>
    80001fce:	0d050493          	addi	s1,a0,208
    80001fd2:	15050913          	addi	s2,a0,336
    80001fd6:	00a79f63          	bne	a5,a0,80001ff4 <exit+0x46>
    panic("init exiting");
    80001fda:	00005517          	auipc	a0,0x5
    80001fde:	2a650513          	addi	a0,a0,678 # 80007280 <etext+0x280>
    80001fe2:	fb2fe0ef          	jal	80000794 <panic>
      fileclose(f);
    80001fe6:	28e020ef          	jal	80004274 <fileclose>
      p->ofile[fd] = 0;
    80001fea:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001fee:	04a1                	addi	s1,s1,8
    80001ff0:	01248563          	beq	s1,s2,80001ffa <exit+0x4c>
    if(p->ofile[fd]){
    80001ff4:	6088                	ld	a0,0(s1)
    80001ff6:	f965                	bnez	a0,80001fe6 <exit+0x38>
    80001ff8:	bfdd                	j	80001fee <exit+0x40>
  begin_op();
    80001ffa:	661010ef          	jal	80003e5a <begin_op>
  iput(p->cwd);
    80001ffe:	1509b503          	ld	a0,336(s3)
    80002002:	744010ef          	jal	80003746 <iput>
  end_op();
    80002006:	6bf010ef          	jal	80003ec4 <end_op>
  p->cwd = 0;
    8000200a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000200e:	0000e497          	auipc	s1,0xe
    80002012:	a4a48493          	addi	s1,s1,-1462 # 8000fa58 <wait_lock>
    80002016:	8526                	mv	a0,s1
    80002018:	bddfe0ef          	jal	80000bf4 <acquire>
  reparent(p);
    8000201c:	854e                	mv	a0,s3
    8000201e:	f3bff0ef          	jal	80001f58 <reparent>
  wakeup(p->parent);
    80002022:	0389b503          	ld	a0,56(s3)
    80002026:	ec9ff0ef          	jal	80001eee <wakeup>
  acquire(&p->lock);
    8000202a:	854e                	mv	a0,s3
    8000202c:	bc9fe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    80002030:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002034:	4795                	li	a5,5
    80002036:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000203a:	8526                	mv	a0,s1
    8000203c:	c51fe0ef          	jal	80000c8c <release>
  sched();
    80002040:	d7dff0ef          	jal	80001dbc <sched>
  panic("zombie exit");
    80002044:	00005517          	auipc	a0,0x5
    80002048:	24c50513          	addi	a0,a0,588 # 80007290 <etext+0x290>
    8000204c:	f48fe0ef          	jal	80000794 <panic>

0000000080002050 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002050:	7179                	addi	sp,sp,-48
    80002052:	f406                	sd	ra,40(sp)
    80002054:	f022                	sd	s0,32(sp)
    80002056:	ec26                	sd	s1,24(sp)
    80002058:	e84a                	sd	s2,16(sp)
    8000205a:	e44e                	sd	s3,8(sp)
    8000205c:	1800                	addi	s0,sp,48
    8000205e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002060:	0000e497          	auipc	s1,0xe
    80002064:	e1048493          	addi	s1,s1,-496 # 8000fe70 <proc>
    80002068:	00016997          	auipc	s3,0x16
    8000206c:	a0898993          	addi	s3,s3,-1528 # 80017a70 <tickslock>
    acquire(&p->lock);
    80002070:	8526                	mv	a0,s1
    80002072:	b83fe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid){
    80002076:	589c                	lw	a5,48(s1)
    80002078:	01278b63          	beq	a5,s2,8000208e <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000207c:	8526                	mv	a0,s1
    8000207e:	c0ffe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002082:	1f048493          	addi	s1,s1,496
    80002086:	ff3495e3          	bne	s1,s3,80002070 <kill+0x20>
  }
  return -1;
    8000208a:	557d                	li	a0,-1
    8000208c:	a819                	j	800020a2 <kill+0x52>
      p->killed = 1;
    8000208e:	4785                	li	a5,1
    80002090:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002092:	4c98                	lw	a4,24(s1)
    80002094:	4789                	li	a5,2
    80002096:	00f70d63          	beq	a4,a5,800020b0 <kill+0x60>
      release(&p->lock);
    8000209a:	8526                	mv	a0,s1
    8000209c:	bf1fe0ef          	jal	80000c8c <release>
      return 0;
    800020a0:	4501                	li	a0,0
}
    800020a2:	70a2                	ld	ra,40(sp)
    800020a4:	7402                	ld	s0,32(sp)
    800020a6:	64e2                	ld	s1,24(sp)
    800020a8:	6942                	ld	s2,16(sp)
    800020aa:	69a2                	ld	s3,8(sp)
    800020ac:	6145                	addi	sp,sp,48
    800020ae:	8082                	ret
        p->state = RUNNABLE;
    800020b0:	478d                	li	a5,3
    800020b2:	cc9c                	sw	a5,24(s1)
    800020b4:	b7dd                	j	8000209a <kill+0x4a>

00000000800020b6 <setkilled>:

void
setkilled(struct proc *p)
{
    800020b6:	1101                	addi	sp,sp,-32
    800020b8:	ec06                	sd	ra,24(sp)
    800020ba:	e822                	sd	s0,16(sp)
    800020bc:	e426                	sd	s1,8(sp)
    800020be:	1000                	addi	s0,sp,32
    800020c0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020c2:	b33fe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    800020c6:	4785                	li	a5,1
    800020c8:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800020ca:	8526                	mv	a0,s1
    800020cc:	bc1fe0ef          	jal	80000c8c <release>
}
    800020d0:	60e2                	ld	ra,24(sp)
    800020d2:	6442                	ld	s0,16(sp)
    800020d4:	64a2                	ld	s1,8(sp)
    800020d6:	6105                	addi	sp,sp,32
    800020d8:	8082                	ret

00000000800020da <killed>:

int
killed(struct proc *p)
{
    800020da:	1101                	addi	sp,sp,-32
    800020dc:	ec06                	sd	ra,24(sp)
    800020de:	e822                	sd	s0,16(sp)
    800020e0:	e426                	sd	s1,8(sp)
    800020e2:	e04a                	sd	s2,0(sp)
    800020e4:	1000                	addi	s0,sp,32
    800020e6:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800020e8:	b0dfe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    800020ec:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800020f0:	8526                	mv	a0,s1
    800020f2:	b9bfe0ef          	jal	80000c8c <release>
  return k;
}
    800020f6:	854a                	mv	a0,s2
    800020f8:	60e2                	ld	ra,24(sp)
    800020fa:	6442                	ld	s0,16(sp)
    800020fc:	64a2                	ld	s1,8(sp)
    800020fe:	6902                	ld	s2,0(sp)
    80002100:	6105                	addi	sp,sp,32
    80002102:	8082                	ret

0000000080002104 <wait>:
{
    80002104:	715d                	addi	sp,sp,-80
    80002106:	e486                	sd	ra,72(sp)
    80002108:	e0a2                	sd	s0,64(sp)
    8000210a:	fc26                	sd	s1,56(sp)
    8000210c:	f84a                	sd	s2,48(sp)
    8000210e:	f44e                	sd	s3,40(sp)
    80002110:	f052                	sd	s4,32(sp)
    80002112:	ec56                	sd	s5,24(sp)
    80002114:	e85a                	sd	s6,16(sp)
    80002116:	e45e                	sd	s7,8(sp)
    80002118:	e062                	sd	s8,0(sp)
    8000211a:	0880                	addi	s0,sp,80
    8000211c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000211e:	fb6ff0ef          	jal	800018d4 <myproc>
    80002122:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002124:	0000e517          	auipc	a0,0xe
    80002128:	93450513          	addi	a0,a0,-1740 # 8000fa58 <wait_lock>
    8000212c:	ac9fe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    80002130:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002132:	4a15                	li	s4,5
        havekids = 1;
    80002134:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002136:	00016997          	auipc	s3,0x16
    8000213a:	93a98993          	addi	s3,s3,-1734 # 80017a70 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000213e:	0000ec17          	auipc	s8,0xe
    80002142:	91ac0c13          	addi	s8,s8,-1766 # 8000fa58 <wait_lock>
    80002146:	a871                	j	800021e2 <wait+0xde>
          pid = pp->pid;
    80002148:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000214c:	000b0c63          	beqz	s6,80002164 <wait+0x60>
    80002150:	4691                	li	a3,4
    80002152:	02c48613          	addi	a2,s1,44
    80002156:	85da                	mv	a1,s6
    80002158:	05093503          	ld	a0,80(s2)
    8000215c:	bf6ff0ef          	jal	80001552 <copyout>
    80002160:	02054b63          	bltz	a0,80002196 <wait+0x92>
          freeproc(pp);
    80002164:	8526                	mv	a0,s1
    80002166:	8e1ff0ef          	jal	80001a46 <freeproc>
          release(&pp->lock);
    8000216a:	8526                	mv	a0,s1
    8000216c:	b21fe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    80002170:	0000e517          	auipc	a0,0xe
    80002174:	8e850513          	addi	a0,a0,-1816 # 8000fa58 <wait_lock>
    80002178:	b15fe0ef          	jal	80000c8c <release>
}
    8000217c:	854e                	mv	a0,s3
    8000217e:	60a6                	ld	ra,72(sp)
    80002180:	6406                	ld	s0,64(sp)
    80002182:	74e2                	ld	s1,56(sp)
    80002184:	7942                	ld	s2,48(sp)
    80002186:	79a2                	ld	s3,40(sp)
    80002188:	7a02                	ld	s4,32(sp)
    8000218a:	6ae2                	ld	s5,24(sp)
    8000218c:	6b42                	ld	s6,16(sp)
    8000218e:	6ba2                	ld	s7,8(sp)
    80002190:	6c02                	ld	s8,0(sp)
    80002192:	6161                	addi	sp,sp,80
    80002194:	8082                	ret
            release(&pp->lock);
    80002196:	8526                	mv	a0,s1
    80002198:	af5fe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    8000219c:	0000e517          	auipc	a0,0xe
    800021a0:	8bc50513          	addi	a0,a0,-1860 # 8000fa58 <wait_lock>
    800021a4:	ae9fe0ef          	jal	80000c8c <release>
            return -1;
    800021a8:	59fd                	li	s3,-1
    800021aa:	bfc9                	j	8000217c <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ac:	1f048493          	addi	s1,s1,496
    800021b0:	03348063          	beq	s1,s3,800021d0 <wait+0xcc>
      if(pp->parent == p){
    800021b4:	7c9c                	ld	a5,56(s1)
    800021b6:	ff279be3          	bne	a5,s2,800021ac <wait+0xa8>
        acquire(&pp->lock);
    800021ba:	8526                	mv	a0,s1
    800021bc:	a39fe0ef          	jal	80000bf4 <acquire>
        if(pp->state == ZOMBIE){
    800021c0:	4c9c                	lw	a5,24(s1)
    800021c2:	f94783e3          	beq	a5,s4,80002148 <wait+0x44>
        release(&pp->lock);
    800021c6:	8526                	mv	a0,s1
    800021c8:	ac5fe0ef          	jal	80000c8c <release>
        havekids = 1;
    800021cc:	8756                	mv	a4,s5
    800021ce:	bff9                	j	800021ac <wait+0xa8>
    if(!havekids || killed(p)){
    800021d0:	cf19                	beqz	a4,800021ee <wait+0xea>
    800021d2:	854a                	mv	a0,s2
    800021d4:	f07ff0ef          	jal	800020da <killed>
    800021d8:	e919                	bnez	a0,800021ee <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021da:	85e2                	mv	a1,s8
    800021dc:	854a                	mv	a0,s2
    800021de:	cc5ff0ef          	jal	80001ea2 <sleep>
    havekids = 0;
    800021e2:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021e4:	0000e497          	auipc	s1,0xe
    800021e8:	c8c48493          	addi	s1,s1,-884 # 8000fe70 <proc>
    800021ec:	b7e1                	j	800021b4 <wait+0xb0>
      release(&wait_lock);
    800021ee:	0000e517          	auipc	a0,0xe
    800021f2:	86a50513          	addi	a0,a0,-1942 # 8000fa58 <wait_lock>
    800021f6:	a97fe0ef          	jal	80000c8c <release>
      return -1;
    800021fa:	59fd                	li	s3,-1
    800021fc:	b741                	j	8000217c <wait+0x78>

00000000800021fe <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800021fe:	7179                	addi	sp,sp,-48
    80002200:	f406                	sd	ra,40(sp)
    80002202:	f022                	sd	s0,32(sp)
    80002204:	ec26                	sd	s1,24(sp)
    80002206:	e84a                	sd	s2,16(sp)
    80002208:	e44e                	sd	s3,8(sp)
    8000220a:	e052                	sd	s4,0(sp)
    8000220c:	1800                	addi	s0,sp,48
    8000220e:	84aa                	mv	s1,a0
    80002210:	892e                	mv	s2,a1
    80002212:	89b2                	mv	s3,a2
    80002214:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002216:	ebeff0ef          	jal	800018d4 <myproc>
  if(user_dst){
    8000221a:	cc99                	beqz	s1,80002238 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000221c:	86d2                	mv	a3,s4
    8000221e:	864e                	mv	a2,s3
    80002220:	85ca                	mv	a1,s2
    80002222:	6928                	ld	a0,80(a0)
    80002224:	b2eff0ef          	jal	80001552 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002228:	70a2                	ld	ra,40(sp)
    8000222a:	7402                	ld	s0,32(sp)
    8000222c:	64e2                	ld	s1,24(sp)
    8000222e:	6942                	ld	s2,16(sp)
    80002230:	69a2                	ld	s3,8(sp)
    80002232:	6a02                	ld	s4,0(sp)
    80002234:	6145                	addi	sp,sp,48
    80002236:	8082                	ret
    memmove((char *)dst, src, len);
    80002238:	000a061b          	sext.w	a2,s4
    8000223c:	85ce                	mv	a1,s3
    8000223e:	854a                	mv	a0,s2
    80002240:	ae5fe0ef          	jal	80000d24 <memmove>
    return 0;
    80002244:	8526                	mv	a0,s1
    80002246:	b7cd                	j	80002228 <either_copyout+0x2a>

0000000080002248 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002248:	7179                	addi	sp,sp,-48
    8000224a:	f406                	sd	ra,40(sp)
    8000224c:	f022                	sd	s0,32(sp)
    8000224e:	ec26                	sd	s1,24(sp)
    80002250:	e84a                	sd	s2,16(sp)
    80002252:	e44e                	sd	s3,8(sp)
    80002254:	e052                	sd	s4,0(sp)
    80002256:	1800                	addi	s0,sp,48
    80002258:	892a                	mv	s2,a0
    8000225a:	84ae                	mv	s1,a1
    8000225c:	89b2                	mv	s3,a2
    8000225e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002260:	e74ff0ef          	jal	800018d4 <myproc>
  if(user_src){
    80002264:	cc99                	beqz	s1,80002282 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002266:	86d2                	mv	a3,s4
    80002268:	864e                	mv	a2,s3
    8000226a:	85ca                	mv	a1,s2
    8000226c:	6928                	ld	a0,80(a0)
    8000226e:	bbaff0ef          	jal	80001628 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002272:	70a2                	ld	ra,40(sp)
    80002274:	7402                	ld	s0,32(sp)
    80002276:	64e2                	ld	s1,24(sp)
    80002278:	6942                	ld	s2,16(sp)
    8000227a:	69a2                	ld	s3,8(sp)
    8000227c:	6a02                	ld	s4,0(sp)
    8000227e:	6145                	addi	sp,sp,48
    80002280:	8082                	ret
    memmove(dst, (char*)src, len);
    80002282:	000a061b          	sext.w	a2,s4
    80002286:	85ce                	mv	a1,s3
    80002288:	854a                	mv	a0,s2
    8000228a:	a9bfe0ef          	jal	80000d24 <memmove>
    return 0;
    8000228e:	8526                	mv	a0,s1
    80002290:	b7cd                	j	80002272 <either_copyin+0x2a>

0000000080002292 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002292:	715d                	addi	sp,sp,-80
    80002294:	e486                	sd	ra,72(sp)
    80002296:	e0a2                	sd	s0,64(sp)
    80002298:	fc26                	sd	s1,56(sp)
    8000229a:	f84a                	sd	s2,48(sp)
    8000229c:	f44e                	sd	s3,40(sp)
    8000229e:	f052                	sd	s4,32(sp)
    800022a0:	ec56                	sd	s5,24(sp)
    800022a2:	e85a                	sd	s6,16(sp)
    800022a4:	e45e                	sd	s7,8(sp)
    800022a6:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022a8:	00005517          	auipc	a0,0x5
    800022ac:	dd050513          	addi	a0,a0,-560 # 80007078 <etext+0x78>
    800022b0:	a12fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022b4:	0000e497          	auipc	s1,0xe
    800022b8:	d1448493          	addi	s1,s1,-748 # 8000ffc8 <proc+0x158>
    800022bc:	00016917          	auipc	s2,0x16
    800022c0:	90c90913          	addi	s2,s2,-1780 # 80017bc8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022c4:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022c6:	00005997          	auipc	s3,0x5
    800022ca:	fda98993          	addi	s3,s3,-38 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    800022ce:	00005a97          	auipc	s5,0x5
    800022d2:	fdaa8a93          	addi	s5,s5,-38 # 800072a8 <etext+0x2a8>
    printf("\n");
    800022d6:	00005a17          	auipc	s4,0x5
    800022da:	da2a0a13          	addi	s4,s4,-606 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022de:	00005b97          	auipc	s7,0x5
    800022e2:	4aab8b93          	addi	s7,s7,1194 # 80007788 <states.0>
    800022e6:	a829                	j	80002300 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800022e8:	ed86a583          	lw	a1,-296(a3)
    800022ec:	8556                	mv	a0,s5
    800022ee:	9d4fe0ef          	jal	800004c2 <printf>
    printf("\n");
    800022f2:	8552                	mv	a0,s4
    800022f4:	9cefe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022f8:	1f048493          	addi	s1,s1,496
    800022fc:	03248263          	beq	s1,s2,80002320 <procdump+0x8e>
    if(p->state == UNUSED)
    80002300:	86a6                	mv	a3,s1
    80002302:	ec04a783          	lw	a5,-320(s1)
    80002306:	dbed                	beqz	a5,800022f8 <procdump+0x66>
      state = "???";
    80002308:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000230a:	fcfb6fe3          	bltu	s6,a5,800022e8 <procdump+0x56>
    8000230e:	02079713          	slli	a4,a5,0x20
    80002312:	01d75793          	srli	a5,a4,0x1d
    80002316:	97de                	add	a5,a5,s7
    80002318:	6390                	ld	a2,0(a5)
    8000231a:	f679                	bnez	a2,800022e8 <procdump+0x56>
      state = "???";
    8000231c:	864e                	mv	a2,s3
    8000231e:	b7e9                	j	800022e8 <procdump+0x56>
  }
}
    80002320:	60a6                	ld	ra,72(sp)
    80002322:	6406                	ld	s0,64(sp)
    80002324:	74e2                	ld	s1,56(sp)
    80002326:	7942                	ld	s2,48(sp)
    80002328:	79a2                	ld	s3,40(sp)
    8000232a:	7a02                	ld	s4,32(sp)
    8000232c:	6ae2                	ld	s5,24(sp)
    8000232e:	6b42                	ld	s6,16(sp)
    80002330:	6ba2                	ld	s7,8(sp)
    80002332:	6161                	addi	sp,sp,80
    80002334:	8082                	ret

0000000080002336 <jointhread>:
int jointhread(uint join_id) {
    80002336:	1101                	addi	sp,sp,-32
    80002338:	ec06                	sd	ra,24(sp)
    8000233a:	e822                	sd	s0,16(sp)
    8000233c:	e426                	sd	s1,8(sp)
    8000233e:	1000                	addi	s0,sp,32
    80002340:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002342:	d92ff0ef          	jal	800018d4 <myproc>
  struct thread *t = p->current_thread;
    80002346:	1e853803          	ld	a6,488(a0)
  if (!t)
    8000234a:	04080c63          	beqz	a6,800023a2 <jointhread+0x6c>
  return -3;
  int found = 0;
  uint current_id = join_id;
    8000234e:	8626                	mv	a2,s1
  int found = 0;
    80002350:	4301                	li	t1,0
  while (current_id != 0) {
  if (current_id == t->id)
  return -1; // deadlock
  uint target_id = current_id;
  current_id = 0;
  for (int i = 0; i < NTHREAD; i++) {
    80002352:	4881                	li	a7,0
    80002354:	4591                	li	a1,4
  if (p->threads[i].id == target_id) {
  current_id = p->threads[i].join;
  found = 1;
    80002356:	4e05                	li	t3,1
    80002358:	a031                	j	80002364 <jointhread+0x2e>
  current_id = p->threads[i].join;
    8000235a:	0796                	slli	a5,a5,0x5
    8000235c:	97aa                	add	a5,a5,a0
    8000235e:	17c7a603          	lw	a2,380(a5)
  found = 1;
    80002362:	8372                	mv	t1,t3
  while (current_id != 0) {
    80002364:	c205                	beqz	a2,80002384 <jointhread+0x4e>
  if (current_id == t->id)
    80002366:	01082783          	lw	a5,16(a6)
    8000236a:	02c78e63          	beq	a5,a2,800023a6 <jointhread+0x70>
    8000236e:	17850713          	addi	a4,a0,376
  for (int i = 0; i < NTHREAD; i++) {
    80002372:	87c6                	mv	a5,a7
  if (p->threads[i].id == target_id) {
    80002374:	4314                	lw	a3,0(a4)
    80002376:	fec682e3          	beq	a3,a2,8000235a <jointhread+0x24>
  for (int i = 0; i < NTHREAD; i++) {
    8000237a:	2785                	addiw	a5,a5,1
    8000237c:	02070713          	addi	a4,a4,32
    80002380:	feb79ae3          	bne	a5,a1,80002374 <jointhread+0x3e>
  break;
  }
  }
  }
  if (!found)
    80002384:	02030363          	beqz	t1,800023aa <jointhread+0x74>
  return -2;
  t->join = join_id;
    80002388:	00982a23          	sw	s1,20(a6)
  t->state = THREAD_JOINED;
    8000238c:	478d                	li	a5,3
    8000238e:	00f82023          	sw	a5,0(a6)
  yield();
    80002392:	ae5ff0ef          	jal	80001e76 <yield>
  return 0;
    80002396:	4501                	li	a0,0
  }
    80002398:	60e2                	ld	ra,24(sp)
    8000239a:	6442                	ld	s0,16(sp)
    8000239c:	64a2                	ld	s1,8(sp)
    8000239e:	6105                	addi	sp,sp,32
    800023a0:	8082                	ret
  return -3;
    800023a2:	5575                	li	a0,-3
    800023a4:	bfd5                	j	80002398 <jointhread+0x62>
  return -1; // deadlock
    800023a6:	557d                	li	a0,-1
    800023a8:	bfc5                	j	80002398 <jointhread+0x62>
  return -2;
    800023aa:	5579                	li	a0,-2
    800023ac:	b7f5                	j	80002398 <jointhread+0x62>

00000000800023ae <freethread>:
}
return 0;
}
void
freethread(struct thread *t)
{
    800023ae:	1101                	addi	sp,sp,-32
    800023b0:	ec06                	sd	ra,24(sp)
    800023b2:	e822                	sd	s0,16(sp)
    800023b4:	e426                	sd	s1,8(sp)
    800023b6:	1000                	addi	s0,sp,32
    800023b8:	84aa                	mv	s1,a0
t->state = THREAD_UNUSED;
    800023ba:	00052023          	sw	zero,0(a0)
if (t->trapframe)
    800023be:	6508                	ld	a0,8(a0)
    800023c0:	c119                	beqz	a0,800023c6 <freethread+0x18>
kfree((void*)t->trapframe);
    800023c2:	e80fe0ef          	jal	80000a42 <kfree>
t->trapframe = 0;
    800023c6:	0004b423          	sd	zero,8(s1)
t->id = 0;
    800023ca:	0004a823          	sw	zero,16(s1)
t->join = 0;
    800023ce:	0004aa23          	sw	zero,20(s1)
}
    800023d2:	60e2                	ld	ra,24(sp)
    800023d4:	6442                	ld	s0,16(sp)
    800023d6:	64a2                	ld	s1,8(sp)
    800023d8:	6105                	addi	sp,sp,32
    800023da:	8082                	ret

00000000800023dc <thread_schd>:
    if (!thread_schd(p))
    setkilled(p);
    }
    int
thread_schd(struct proc *p) {
if (!p->current_thread) {
    800023dc:	1e853783          	ld	a5,488(a0)
    800023e0:	cbed                	beqz	a5,800024d2 <thread_schd+0xf6>
thread_schd(struct proc *p) {
    800023e2:	1101                	addi	sp,sp,-32
    800023e4:	ec06                	sd	ra,24(sp)
    800023e6:	e822                	sd	s0,16(sp)
    800023e8:	e426                	sd	s1,8(sp)
    800023ea:	e04a                	sd	s2,0(sp)
    800023ec:	1000                	addi	s0,sp,32
    800023ee:	84aa                	mv	s1,a0
return 1;
}
if (p->current_thread->state == THREAD_RUNNING) {
    800023f0:	4394                	lw	a3,0(a5)
    800023f2:	4709                	li	a4,2
    800023f4:	02e68c63          	beq	a3,a4,8000242c <thread_schd+0x50>
p->current_thread->state = THREAD_RUNNABLE;
}
acquire(&tickslock);
    800023f8:	00015517          	auipc	a0,0x15
    800023fc:	67850513          	addi	a0,a0,1656 # 80017a70 <tickslock>
    80002400:	ff4fe0ef          	jal	80000bf4 <acquire>
uint ticks0 = ticks;
    80002404:	00005917          	auipc	s2,0x5
    80002408:	50c92903          	lw	s2,1292(s2) # 80007910 <ticks>
release(&tickslock);
    8000240c:	00015517          	auipc	a0,0x15
    80002410:	66450513          	addi	a0,a0,1636 # 80017a70 <tickslock>
    80002414:	879fe0ef          	jal	80000c8c <release>
struct thread *next = 0;
struct thread *t = p->current_thread + 1;
    80002418:	1e84b803          	ld	a6,488(s1)
    8000241c:	02080793          	addi	a5,a6,32
    80002420:	4711                	li	a4,4
for (int i = 0; i < NTHREAD; i++, t++) {
  if (t >= p->threads + NTHREAD) {
    80002422:	1e848593          	addi	a1,s1,488
  t = p->threads;
  }
  if (t->state == THREAD_RUNNABLE) {
    80002426:	4605                	li	a2,1
  next = t;
  break;
  } else if (t->state == THREAD_SLEEPING && ticks0 - t->sleep_tick0 >= t->sleep_n) {
    80002428:	4511                	li	a0,4
    8000242a:	a829                	j	80002444 <thread_schd+0x68>
p->current_thread->state = THREAD_RUNNABLE;
    8000242c:	4705                	li	a4,1
    8000242e:	c398                	sw	a4,0(a5)
    80002430:	b7e1                	j	800023f8 <thread_schd+0x1c>
  if (t->state == THREAD_RUNNABLE) {
    80002432:	4394                	lw	a3,0(a5)
    80002434:	02c68463          	beq	a3,a2,8000245c <thread_schd+0x80>
  } else if (t->state == THREAD_SLEEPING && ticks0 - t->sleep_tick0 >= t->sleep_n) {
    80002438:	00a68b63          	beq	a3,a0,8000244e <thread_schd+0x72>
for (int i = 0; i < NTHREAD; i++, t++) {
    8000243c:	02078793          	addi	a5,a5,32
    80002440:	377d                	addiw	a4,a4,-1
    80002442:	c349                	beqz	a4,800024c4 <thread_schd+0xe8>
  if (t >= p->threads + NTHREAD) {
    80002444:	feb7e7e3          	bltu	a5,a1,80002432 <thread_schd+0x56>
  t = p->threads;
    80002448:	16848793          	addi	a5,s1,360
    8000244c:	b7dd                	j	80002432 <thread_schd+0x56>
  } else if (t->state == THREAD_SLEEPING && ticks0 - t->sleep_tick0 >= t->sleep_n) {
    8000244e:	4fd4                	lw	a3,28(a5)
    80002450:	40d906bb          	subw	a3,s2,a3
    80002454:	0187a883          	lw	a7,24(a5)
    80002458:	ff16e2e3          	bltu	a3,a7,8000243c <thread_schd+0x60>
  break;
  }
  }
  if (next == 0) {
  return 0;
  } else if (p->current_thread != next) {
    8000245c:	06f80d63          	beq	a6,a5,800024d6 <thread_schd+0xfa>
  next->state = THREAD_RUNNING;
    80002460:	4709                	li	a4,2
    80002462:	c398                	sw	a4,0(a5)
  struct thread *t = p->current_thread;
    80002464:	1e84b703          	ld	a4,488(s1)
  p->current_thread = next;
    80002468:	1ef4b423          	sd	a5,488(s1)
  if (t->trapframe) {
    8000246c:	6714                	ld	a3,8(a4)
    8000246e:	c685                	beqz	a3,80002496 <thread_schd+0xba>
  *t->trapframe = *p->trapframe;
    80002470:	6cb8                	ld	a4,88(s1)
    80002472:	12070893          	addi	a7,a4,288
    80002476:	00073803          	ld	a6,0(a4)
    8000247a:	6708                	ld	a0,8(a4)
    8000247c:	6b0c                	ld	a1,16(a4)
    8000247e:	6f10                	ld	a2,24(a4)
    80002480:	0106b023          	sd	a6,0(a3)
    80002484:	e688                	sd	a0,8(a3)
    80002486:	ea8c                	sd	a1,16(a3)
    80002488:	ee90                	sd	a2,24(a3)
    8000248a:	02070713          	addi	a4,a4,32
    8000248e:	02068693          	addi	a3,a3,32
    80002492:	ff1712e3          	bne	a4,a7,80002476 <thread_schd+0x9a>
  }
  *p->trapframe = *next->trapframe;
    80002496:	6794                	ld	a3,8(a5)
    80002498:	87b6                	mv	a5,a3
    8000249a:	6cb8                	ld	a4,88(s1)
    8000249c:	12068693          	addi	a3,a3,288
    800024a0:	0007b803          	ld	a6,0(a5)
    800024a4:	6788                	ld	a0,8(a5)
    800024a6:	6b8c                	ld	a1,16(a5)
    800024a8:	6f90                	ld	a2,24(a5)
    800024aa:	01073023          	sd	a6,0(a4)
    800024ae:	e708                	sd	a0,8(a4)
    800024b0:	eb0c                	sd	a1,16(a4)
    800024b2:	ef10                	sd	a2,24(a4)
    800024b4:	02078793          	addi	a5,a5,32
    800024b8:	02070713          	addi	a4,a4,32
    800024bc:	fed792e3          	bne	a5,a3,800024a0 <thread_schd+0xc4>
  }
  return 1;
    800024c0:	4505                	li	a0,1
    800024c2:	a011                	j	800024c6 <thread_schd+0xea>
  return 0;
    800024c4:	4501                	li	a0,0
  }
    800024c6:	60e2                	ld	ra,24(sp)
    800024c8:	6442                	ld	s0,16(sp)
    800024ca:	64a2                	ld	s1,8(sp)
    800024cc:	6902                	ld	s2,0(sp)
    800024ce:	6105                	addi	sp,sp,32
    800024d0:	8082                	ret
return 1;
    800024d2:	4505                	li	a0,1
  }
    800024d4:	8082                	ret
  return 1;
    800024d6:	4505                	li	a0,1
    800024d8:	b7fd                	j	800024c6 <thread_schd+0xea>

00000000800024da <exitthread>:
void exitthread() {
    800024da:	1101                	addi	sp,sp,-32
    800024dc:	ec06                	sd	ra,24(sp)
    800024de:	e822                	sd	s0,16(sp)
    800024e0:	e426                	sd	s1,8(sp)
    800024e2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800024e4:	bf0ff0ef          	jal	800018d4 <myproc>
    800024e8:	84aa                	mv	s1,a0
  for (struct thread *t = p->threads; t < p->threads + NTHREAD; t++) {if (t->state == THREAD_JOINED && t->join == id) {
    800024ea:	16850793          	addi	a5,a0,360
    800024ee:	1e850693          	addi	a3,a0,488
    800024f2:	02d7f663          	bgeu	a5,a3,8000251e <exitthread+0x44>
  uint id = p->current_thread->id;
    800024f6:	1e853703          	ld	a4,488(a0)
    800024fa:	4b0c                	lw	a1,16(a4)
  for (struct thread *t = p->threads; t < p->threads + NTHREAD; t++) {if (t->state == THREAD_JOINED && t->join == id) {
    800024fc:	460d                	li	a2,3
    800024fe:	a029                	j	80002508 <exitthread+0x2e>
    80002500:	02078793          	addi	a5,a5,32
    80002504:	00d78d63          	beq	a5,a3,8000251e <exitthread+0x44>
    80002508:	4398                	lw	a4,0(a5)
    8000250a:	fec71be3          	bne	a4,a2,80002500 <exitthread+0x26>
    8000250e:	4bd8                	lw	a4,20(a5)
    80002510:	feb718e3          	bne	a4,a1,80002500 <exitthread+0x26>
    t->join = 0;
    80002514:	0007aa23          	sw	zero,20(a5)
    t->state = THREAD_RUNNABLE;
    80002518:	4705                	li	a4,1
    8000251a:	c398                	sw	a4,0(a5)
    8000251c:	b7d5                	j	80002500 <exitthread+0x26>
    freethread(p->current_thread);
    8000251e:	1e84b503          	ld	a0,488(s1)
    80002522:	e8dff0ef          	jal	800023ae <freethread>
    if (!thread_schd(p))
    80002526:	8526                	mv	a0,s1
    80002528:	eb5ff0ef          	jal	800023dc <thread_schd>
    8000252c:	c511                	beqz	a0,80002538 <exitthread+0x5e>
    }
    8000252e:	60e2                	ld	ra,24(sp)
    80002530:	6442                	ld	s0,16(sp)
    80002532:	64a2                	ld	s1,8(sp)
    80002534:	6105                	addi	sp,sp,32
    80002536:	8082                	ret
    setkilled(p);
    80002538:	8526                	mv	a0,s1
    8000253a:	b7dff0ef          	jal	800020b6 <setkilled>
    }
    8000253e:	bfc5                	j	8000252e <exitthread+0x54>

0000000080002540 <sleepthread>:
    
      void sleepthread(int n, uint ticks0) {
    80002540:	1101                	addi	sp,sp,-32
    80002542:	ec06                	sd	ra,24(sp)
    80002544:	e822                	sd	s0,16(sp)
    80002546:	e426                	sd	s1,8(sp)
    80002548:	e04a                	sd	s2,0(sp)
    8000254a:	1000                	addi	s0,sp,32
    8000254c:	892a                	mv	s2,a0
    8000254e:	84ae                	mv	s1,a1
        struct thread *t = myproc()->current_thread;
    80002550:	b84ff0ef          	jal	800018d4 <myproc>
    80002554:	1e853783          	ld	a5,488(a0)
        t->sleep_n = n;
    80002558:	0127ac23          	sw	s2,24(a5)
        t->sleep_tick0 = ticks0;
    8000255c:	cfc4                	sw	s1,28(a5)
        t->state = THREAD_SLEEPING;
    8000255e:	4711                	li	a4,4
    80002560:	c398                	sw	a4,0(a5)
        thread_schd(myproc());
    80002562:	b72ff0ef          	jal	800018d4 <myproc>
    80002566:	e77ff0ef          	jal	800023dc <thread_schd>
        }
    8000256a:	60e2                	ld	ra,24(sp)
    8000256c:	6442                	ld	s0,16(sp)
    8000256e:	64a2                	ld	s1,8(sp)
    80002570:	6902                	ld	s2,0(sp)
    80002572:	6105                	addi	sp,sp,32
    80002574:	8082                	ret

0000000080002576 <initthread>:
        struct thread *
initthread(struct proc *p)
{
    80002576:	7179                	addi	sp,sp,-48
    80002578:	f406                	sd	ra,40(sp)
    8000257a:	f022                	sd	s0,32(sp)
    8000257c:	ec26                	sd	s1,24(sp)
    8000257e:	e84a                	sd	s2,16(sp)
    80002580:	1800                	addi	s0,sp,48
    80002582:	84aa                	mv	s1,a0
if (!p->current_thread) {
    80002584:	1e853783          	ld	a5,488(a0)
    80002588:	cb91                	beqz	a5,8000259c <initthread+0x26>
return 0;
}
t->state = THREAD_RUNNING;
p->current_thread = t;
}
return p->current_thread;
    8000258a:	1e84b903          	ld	s2,488(s1)
}
    8000258e:	854a                	mv	a0,s2
    80002590:	70a2                	ld	ra,40(sp)
    80002592:	7402                	ld	s0,32(sp)
    80002594:	64e2                	ld	s1,24(sp)
    80002596:	6942                	ld	s2,16(sp)
    80002598:	6145                	addi	sp,sp,48
    8000259a:	8082                	ret
    8000259c:	e44e                	sd	s3,8(sp)
p->threads[i].trapframe = 0;
    8000259e:	16053823          	sd	zero,368(a0)
freethread(&p->threads[i]);
    800025a2:	16850993          	addi	s3,a0,360
    800025a6:	854e                	mv	a0,s3
    800025a8:	e07ff0ef          	jal	800023ae <freethread>
p->threads[i].trapframe = 0;
    800025ac:	1804b823          	sd	zero,400(s1)
freethread(&p->threads[i]);
    800025b0:	18848513          	addi	a0,s1,392
    800025b4:	dfbff0ef          	jal	800023ae <freethread>
p->threads[i].trapframe = 0;
    800025b8:	1a04b823          	sd	zero,432(s1)
freethread(&p->threads[i]);
    800025bc:	1a848513          	addi	a0,s1,424
    800025c0:	defff0ef          	jal	800023ae <freethread>
p->threads[i].trapframe = 0;
    800025c4:	1c04b823          	sd	zero,464(s1)
freethread(&p->threads[i]);
    800025c8:	1c848513          	addi	a0,s1,456
    800025cc:	de3ff0ef          	jal	800023ae <freethread>
t->id = p->pid;
    800025d0:	589c                	lw	a5,48(s1)
    800025d2:	16f4ac23          	sw	a5,376(s1)
if ((t->trapframe = (struct trapframe *)kalloc()) == 0) {
    800025d6:	d4efe0ef          	jal	80000b24 <kalloc>
    800025da:	892a                	mv	s2,a0
    800025dc:	16a4b823          	sd	a0,368(s1)
    800025e0:	c901                	beqz	a0,800025f0 <initthread+0x7a>
t->state = THREAD_RUNNING;
    800025e2:	4789                	li	a5,2
    800025e4:	16f4a423          	sw	a5,360(s1)
p->current_thread = t;
    800025e8:	1f34b423          	sd	s3,488(s1)
    800025ec:	69a2                	ld	s3,8(sp)
    800025ee:	bf71                	j	8000258a <initthread+0x14>
freethread(t);
    800025f0:	854e                	mv	a0,s3
    800025f2:	dbdff0ef          	jal	800023ae <freethread>
return 0;
    800025f6:	69a2                	ld	s3,8(sp)
    800025f8:	bf59                	j	8000258e <initthread+0x18>

00000000800025fa <allocthread>:
  uint64 arg) {
    800025fa:	7139                	addi	sp,sp,-64
    800025fc:	fc06                	sd	ra,56(sp)
    800025fe:	f822                	sd	s0,48(sp)
    80002600:	f426                	sd	s1,40(sp)
    80002602:	f04a                	sd	s2,32(sp)
    80002604:	e852                	sd	s4,16(sp)
    80002606:	e456                	sd	s5,8(sp)
    80002608:	e05a                	sd	s6,0(sp)
    8000260a:	0080                	addi	s0,sp,64
    8000260c:	8a2a                	mv	s4,a0
    8000260e:	8b2e                	mv	s6,a1
    80002610:	8ab2                	mv	s5,a2
  struct proc *p = myproc();
    80002612:	ac2ff0ef          	jal	800018d4 <myproc>
    80002616:	892a                	mv	s2,a0
  if (!initthread(p))
    80002618:	f5fff0ef          	jal	80002576 <initthread>
    8000261c:	84aa                	mv	s1,a0
    8000261e:	cd11                	beqz	a0,8000263a <allocthread+0x40>
  for (struct thread *t = p->threads; t < p->threads + NTHREAD; t++) {
    80002620:	16890493          	addi	s1,s2,360
    80002624:	1e890713          	addi	a4,s2,488
    80002628:	08e4f563          	bgeu	s1,a4,800026b2 <allocthread+0xb8>
  if (t->state == THREAD_UNUSED) {
    8000262c:	409c                	lw	a5,0(s1)
    8000262e:	c385                	beqz	a5,8000264e <allocthread+0x54>
  for (struct thread *t = p->threads; t < p->threads + NTHREAD; t++) {
    80002630:	02048493          	addi	s1,s1,32
    80002634:	fee49ce3          	bne	s1,a4,8000262c <allocthread+0x32>
return 0;
    80002638:	4481                	li	s1,0
}
    8000263a:	8526                	mv	a0,s1
    8000263c:	70e2                	ld	ra,56(sp)
    8000263e:	7442                	ld	s0,48(sp)
    80002640:	74a2                	ld	s1,40(sp)
    80002642:	7902                	ld	s2,32(sp)
    80002644:	6a42                	ld	s4,16(sp)
    80002646:	6aa2                	ld	s5,8(sp)
    80002648:	6b02                	ld	s6,0(sp)
    8000264a:	6121                	addi	sp,sp,64
    8000264c:	8082                	ret
    8000264e:	ec4e                	sd	s3,24(sp)
  t->id = allocpid();
    80002650:	aeeff0ef          	jal	8000193e <allocpid>
    80002654:	c888                	sw	a0,16(s1)
  if ((t->trapframe = (struct trapframe *)kalloc()) == 0) {
    80002656:	ccefe0ef          	jal	80000b24 <kalloc>
    8000265a:	89aa                	mv	s3,a0
    8000265c:	e488                	sd	a0,8(s1)
    8000265e:	c521                	beqz	a0,800026a6 <allocthread+0xac>
  t->state = THREAD_RUNNABLE;
    80002660:	4785                	li	a5,1
    80002662:	c09c                	sw	a5,0(s1)
  *t->trapframe = *p->trapframe;
    80002664:	05893703          	ld	a4,88(s2)
    80002668:	87aa                	mv	a5,a0
    8000266a:	12070813          	addi	a6,a4,288
    8000266e:	6308                	ld	a0,0(a4)
    80002670:	670c                	ld	a1,8(a4)
    80002672:	6b10                	ld	a2,16(a4)
    80002674:	6f14                	ld	a3,24(a4)
    80002676:	e388                	sd	a0,0(a5)
    80002678:	e78c                	sd	a1,8(a5)
    8000267a:	eb90                	sd	a2,16(a5)
    8000267c:	ef94                	sd	a3,24(a5)
    8000267e:	02070713          	addi	a4,a4,32
    80002682:	02078793          	addi	a5,a5,32
    80002686:	ff0714e3          	bne	a4,a6,8000266e <allocthread+0x74>
  t->trapframe->sp = stack_address;
    8000268a:	649c                	ld	a5,8(s1)
    8000268c:	0367b823          	sd	s6,48(a5)
  t->trapframe->a0 = arg;
    80002690:	649c                	ld	a5,8(s1)
    80002692:	0757b823          	sd	s5,112(a5)
t->trapframe->ra = -1;
    80002696:	649c                	ld	a5,8(s1)
    80002698:	577d                	li	a4,-1
    8000269a:	f798                	sd	a4,40(a5)
t->trapframe->epc = (uint64) start_thread;
    8000269c:	649c                	ld	a5,8(s1)
    8000269e:	0147bc23          	sd	s4,24(a5)
return t;
    800026a2:	69e2                	ld	s3,24(sp)
    800026a4:	bf59                	j	8000263a <allocthread+0x40>
  freethread(t);
    800026a6:	8526                	mv	a0,s1
    800026a8:	d07ff0ef          	jal	800023ae <freethread>
return 0;
    800026ac:	84ce                	mv	s1,s3
  break;
    800026ae:	69e2                	ld	s3,24(sp)
    800026b0:	b769                	j	8000263a <allocthread+0x40>
return 0;
    800026b2:	4481                	li	s1,0
    800026b4:	b759                	j	8000263a <allocthread+0x40>

00000000800026b6 <swtch>:
    800026b6:	00153023          	sd	ra,0(a0)
    800026ba:	00253423          	sd	sp,8(a0)
    800026be:	e900                	sd	s0,16(a0)
    800026c0:	ed04                	sd	s1,24(a0)
    800026c2:	03253023          	sd	s2,32(a0)
    800026c6:	03353423          	sd	s3,40(a0)
    800026ca:	03453823          	sd	s4,48(a0)
    800026ce:	03553c23          	sd	s5,56(a0)
    800026d2:	05653023          	sd	s6,64(a0)
    800026d6:	05753423          	sd	s7,72(a0)
    800026da:	05853823          	sd	s8,80(a0)
    800026de:	05953c23          	sd	s9,88(a0)
    800026e2:	07a53023          	sd	s10,96(a0)
    800026e6:	07b53423          	sd	s11,104(a0)
    800026ea:	0005b083          	ld	ra,0(a1)
    800026ee:	0085b103          	ld	sp,8(a1)
    800026f2:	6980                	ld	s0,16(a1)
    800026f4:	6d84                	ld	s1,24(a1)
    800026f6:	0205b903          	ld	s2,32(a1)
    800026fa:	0285b983          	ld	s3,40(a1)
    800026fe:	0305ba03          	ld	s4,48(a1)
    80002702:	0385ba83          	ld	s5,56(a1)
    80002706:	0405bb03          	ld	s6,64(a1)
    8000270a:	0485bb83          	ld	s7,72(a1)
    8000270e:	0505bc03          	ld	s8,80(a1)
    80002712:	0585bc83          	ld	s9,88(a1)
    80002716:	0605bd03          	ld	s10,96(a1)
    8000271a:	0685bd83          	ld	s11,104(a1)
    8000271e:	8082                	ret

0000000080002720 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002720:	1141                	addi	sp,sp,-16
    80002722:	e406                	sd	ra,8(sp)
    80002724:	e022                	sd	s0,0(sp)
    80002726:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002728:	00005597          	auipc	a1,0x5
    8000272c:	bc058593          	addi	a1,a1,-1088 # 800072e8 <etext+0x2e8>
    80002730:	00015517          	auipc	a0,0x15
    80002734:	34050513          	addi	a0,a0,832 # 80017a70 <tickslock>
    80002738:	c3cfe0ef          	jal	80000b74 <initlock>
}
    8000273c:	60a2                	ld	ra,8(sp)
    8000273e:	6402                	ld	s0,0(sp)
    80002740:	0141                	addi	sp,sp,16
    80002742:	8082                	ret

0000000080002744 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002744:	1141                	addi	sp,sp,-16
    80002746:	e422                	sd	s0,8(sp)
    80002748:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000274a:	00003797          	auipc	a5,0x3
    8000274e:	e9678793          	addi	a5,a5,-362 # 800055e0 <kernelvec>
    80002752:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002756:	6422                	ld	s0,8(sp)
    80002758:	0141                	addi	sp,sp,16
    8000275a:	8082                	ret

000000008000275c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000275c:	1141                	addi	sp,sp,-16
    8000275e:	e406                	sd	ra,8(sp)
    80002760:	e022                	sd	s0,0(sp)
    80002762:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002764:	970ff0ef          	jal	800018d4 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002768:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000276c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000276e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002772:	00004697          	auipc	a3,0x4
    80002776:	88e68693          	addi	a3,a3,-1906 # 80006000 <_trampoline>
    8000277a:	00004717          	auipc	a4,0x4
    8000277e:	88670713          	addi	a4,a4,-1914 # 80006000 <_trampoline>
    80002782:	8f15                	sub	a4,a4,a3
    80002784:	040007b7          	lui	a5,0x4000
    80002788:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000278a:	07b2                	slli	a5,a5,0xc
    8000278c:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000278e:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002792:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002794:	18002673          	csrr	a2,satp
    80002798:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000279a:	6d30                	ld	a2,88(a0)
    8000279c:	6138                	ld	a4,64(a0)
    8000279e:	6585                	lui	a1,0x1
    800027a0:	972e                	add	a4,a4,a1
    800027a2:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027a4:	6d38                	ld	a4,88(a0)
    800027a6:	00000617          	auipc	a2,0x0
    800027aa:	11060613          	addi	a2,a2,272 # 800028b6 <usertrap>
    800027ae:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800027b0:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027b2:	8612                	mv	a2,tp
    800027b4:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027b6:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027ba:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027be:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027c2:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800027c6:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027c8:	6f18                	ld	a4,24(a4)
    800027ca:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800027ce:	6928                	ld	a0,80(a0)
    800027d0:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800027d2:	00004717          	auipc	a4,0x4
    800027d6:	8ca70713          	addi	a4,a4,-1846 # 8000609c <userret>
    800027da:	8f15                	sub	a4,a4,a3
    800027dc:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800027de:	577d                	li	a4,-1
    800027e0:	177e                	slli	a4,a4,0x3f
    800027e2:	8d59                	or	a0,a0,a4
    800027e4:	9782                	jalr	a5
}
    800027e6:	60a2                	ld	ra,8(sp)
    800027e8:	6402                	ld	s0,0(sp)
    800027ea:	0141                	addi	sp,sp,16
    800027ec:	8082                	ret

00000000800027ee <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800027ee:	1101                	addi	sp,sp,-32
    800027f0:	ec06                	sd	ra,24(sp)
    800027f2:	e822                	sd	s0,16(sp)
    800027f4:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800027f6:	8b2ff0ef          	jal	800018a8 <cpuid>
    800027fa:	cd11                	beqz	a0,80002816 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800027fc:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002800:	000f4737          	lui	a4,0xf4
    80002804:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002808:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    8000280a:	14d79073          	csrw	stimecmp,a5
}
    8000280e:	60e2                	ld	ra,24(sp)
    80002810:	6442                	ld	s0,16(sp)
    80002812:	6105                	addi	sp,sp,32
    80002814:	8082                	ret
    80002816:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002818:	00015497          	auipc	s1,0x15
    8000281c:	25848493          	addi	s1,s1,600 # 80017a70 <tickslock>
    80002820:	8526                	mv	a0,s1
    80002822:	bd2fe0ef          	jal	80000bf4 <acquire>
    ticks++;
    80002826:	00005517          	auipc	a0,0x5
    8000282a:	0ea50513          	addi	a0,a0,234 # 80007910 <ticks>
    8000282e:	411c                	lw	a5,0(a0)
    80002830:	2785                	addiw	a5,a5,1
    80002832:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002834:	ebaff0ef          	jal	80001eee <wakeup>
    release(&tickslock);
    80002838:	8526                	mv	a0,s1
    8000283a:	c52fe0ef          	jal	80000c8c <release>
    8000283e:	64a2                	ld	s1,8(sp)
    80002840:	bf75                	j	800027fc <clockintr+0xe>

0000000080002842 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002842:	1101                	addi	sp,sp,-32
    80002844:	ec06                	sd	ra,24(sp)
    80002846:	e822                	sd	s0,16(sp)
    80002848:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000284a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    8000284e:	57fd                	li	a5,-1
    80002850:	17fe                	slli	a5,a5,0x3f
    80002852:	07a5                	addi	a5,a5,9
    80002854:	00f70c63          	beq	a4,a5,8000286c <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002858:	57fd                	li	a5,-1
    8000285a:	17fe                	slli	a5,a5,0x3f
    8000285c:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000285e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002860:	04f70763          	beq	a4,a5,800028ae <devintr+0x6c>
  }
}
    80002864:	60e2                	ld	ra,24(sp)
    80002866:	6442                	ld	s0,16(sp)
    80002868:	6105                	addi	sp,sp,32
    8000286a:	8082                	ret
    8000286c:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000286e:	61f020ef          	jal	8000568c <plic_claim>
    80002872:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002874:	47a9                	li	a5,10
    80002876:	00f50963          	beq	a0,a5,80002888 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    8000287a:	4785                	li	a5,1
    8000287c:	00f50963          	beq	a0,a5,8000288e <devintr+0x4c>
    return 1;
    80002880:	4505                	li	a0,1
    } else if(irq){
    80002882:	e889                	bnez	s1,80002894 <devintr+0x52>
    80002884:	64a2                	ld	s1,8(sp)
    80002886:	bff9                	j	80002864 <devintr+0x22>
      uartintr();
    80002888:	97efe0ef          	jal	80000a06 <uartintr>
    if(irq)
    8000288c:	a819                	j	800028a2 <devintr+0x60>
      virtio_disk_intr();
    8000288e:	2c4030ef          	jal	80005b52 <virtio_disk_intr>
    if(irq)
    80002892:	a801                	j	800028a2 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002894:	85a6                	mv	a1,s1
    80002896:	00005517          	auipc	a0,0x5
    8000289a:	a5a50513          	addi	a0,a0,-1446 # 800072f0 <etext+0x2f0>
    8000289e:	c25fd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    800028a2:	8526                	mv	a0,s1
    800028a4:	609020ef          	jal	800056ac <plic_complete>
    return 1;
    800028a8:	4505                	li	a0,1
    800028aa:	64a2                	ld	s1,8(sp)
    800028ac:	bf65                	j	80002864 <devintr+0x22>
    clockintr();
    800028ae:	f41ff0ef          	jal	800027ee <clockintr>
    return 2;
    800028b2:	4509                	li	a0,2
    800028b4:	bf45                	j	80002864 <devintr+0x22>

00000000800028b6 <usertrap>:
{
    800028b6:	1101                	addi	sp,sp,-32
    800028b8:	ec06                	sd	ra,24(sp)
    800028ba:	e822                	sd	s0,16(sp)
    800028bc:	e426                	sd	s1,8(sp)
    800028be:	e04a                	sd	s2,0(sp)
    800028c0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028c2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800028c6:	1007f793          	andi	a5,a5,256
    800028ca:	ef85                	bnez	a5,80002902 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028cc:	00003797          	auipc	a5,0x3
    800028d0:	d1478793          	addi	a5,a5,-748 # 800055e0 <kernelvec>
    800028d4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800028d8:	ffdfe0ef          	jal	800018d4 <myproc>
    800028dc:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800028de:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028e0:	14102773          	csrr	a4,sepc
    800028e4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028e6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800028ea:	47a1                	li	a5,8
    800028ec:	02f70163          	beq	a4,a5,8000290e <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    800028f0:	f53ff0ef          	jal	80002842 <devintr>
    800028f4:	892a                	mv	s2,a0
    800028f6:	c135                	beqz	a0,8000295a <usertrap+0xa4>
  if(killed(p))
    800028f8:	8526                	mv	a0,s1
    800028fa:	fe0ff0ef          	jal	800020da <killed>
    800028fe:	cd1d                	beqz	a0,8000293c <usertrap+0x86>
    80002900:	a81d                	j	80002936 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80002902:	00005517          	auipc	a0,0x5
    80002906:	a0e50513          	addi	a0,a0,-1522 # 80007310 <etext+0x310>
    8000290a:	e8bfd0ef          	jal	80000794 <panic>
    if(killed(p))
    8000290e:	fccff0ef          	jal	800020da <killed>
    80002912:	e121                	bnez	a0,80002952 <usertrap+0x9c>
    p->trapframe->epc += 4;
    80002914:	6cb8                	ld	a4,88(s1)
    80002916:	6f1c                	ld	a5,24(a4)
    80002918:	0791                	addi	a5,a5,4
    8000291a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000291c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002920:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002924:	10079073          	csrw	sstatus,a5
    syscall();
    80002928:	248000ef          	jal	80002b70 <syscall>
  if(killed(p))
    8000292c:	8526                	mv	a0,s1
    8000292e:	facff0ef          	jal	800020da <killed>
    80002932:	c901                	beqz	a0,80002942 <usertrap+0x8c>
    80002934:	4901                	li	s2,0
    exit(-1);
    80002936:	557d                	li	a0,-1
    80002938:	e76ff0ef          	jal	80001fae <exit>
  if(which_dev == 2)
    8000293c:	4789                	li	a5,2
    8000293e:	04f90563          	beq	s2,a5,80002988 <usertrap+0xd2>
  usertrapret();
    80002942:	e1bff0ef          	jal	8000275c <usertrapret>
}
    80002946:	60e2                	ld	ra,24(sp)
    80002948:	6442                	ld	s0,16(sp)
    8000294a:	64a2                	ld	s1,8(sp)
    8000294c:	6902                	ld	s2,0(sp)
    8000294e:	6105                	addi	sp,sp,32
    80002950:	8082                	ret
      exit(-1);
    80002952:	557d                	li	a0,-1
    80002954:	e5aff0ef          	jal	80001fae <exit>
    80002958:	bf75                	j	80002914 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000295a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000295e:	5890                	lw	a2,48(s1)
    80002960:	00005517          	auipc	a0,0x5
    80002964:	9d050513          	addi	a0,a0,-1584 # 80007330 <etext+0x330>
    80002968:	b5bfd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000296c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002970:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002974:	00005517          	auipc	a0,0x5
    80002978:	9ec50513          	addi	a0,a0,-1556 # 80007360 <etext+0x360>
    8000297c:	b47fd0ef          	jal	800004c2 <printf>
    setkilled(p);
    80002980:	8526                	mv	a0,s1
    80002982:	f34ff0ef          	jal	800020b6 <setkilled>
    80002986:	b75d                	j	8000292c <usertrap+0x76>
    yield();
    80002988:	ceeff0ef          	jal	80001e76 <yield>
    8000298c:	bf5d                	j	80002942 <usertrap+0x8c>

000000008000298e <kerneltrap>:
{
    8000298e:	7179                	addi	sp,sp,-48
    80002990:	f406                	sd	ra,40(sp)
    80002992:	f022                	sd	s0,32(sp)
    80002994:	ec26                	sd	s1,24(sp)
    80002996:	e84a                	sd	s2,16(sp)
    80002998:	e44e                	sd	s3,8(sp)
    8000299a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000299c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029a0:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029a4:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800029a8:	1004f793          	andi	a5,s1,256
    800029ac:	c795                	beqz	a5,800029d8 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029ae:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029b2:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029b4:	eb85                	bnez	a5,800029e4 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800029b6:	e8dff0ef          	jal	80002842 <devintr>
    800029ba:	c91d                	beqz	a0,800029f0 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800029bc:	4789                	li	a5,2
    800029be:	04f50a63          	beq	a0,a5,80002a12 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029c2:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029c6:	10049073          	csrw	sstatus,s1
}
    800029ca:	70a2                	ld	ra,40(sp)
    800029cc:	7402                	ld	s0,32(sp)
    800029ce:	64e2                	ld	s1,24(sp)
    800029d0:	6942                	ld	s2,16(sp)
    800029d2:	69a2                	ld	s3,8(sp)
    800029d4:	6145                	addi	sp,sp,48
    800029d6:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029d8:	00005517          	auipc	a0,0x5
    800029dc:	9b050513          	addi	a0,a0,-1616 # 80007388 <etext+0x388>
    800029e0:	db5fd0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    800029e4:	00005517          	auipc	a0,0x5
    800029e8:	9cc50513          	addi	a0,a0,-1588 # 800073b0 <etext+0x3b0>
    800029ec:	da9fd0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029f0:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029f4:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800029f8:	85ce                	mv	a1,s3
    800029fa:	00005517          	auipc	a0,0x5
    800029fe:	9d650513          	addi	a0,a0,-1578 # 800073d0 <etext+0x3d0>
    80002a02:	ac1fd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    80002a06:	00005517          	auipc	a0,0x5
    80002a0a:	9f250513          	addi	a0,a0,-1550 # 800073f8 <etext+0x3f8>
    80002a0e:	d87fd0ef          	jal	80000794 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002a12:	ec3fe0ef          	jal	800018d4 <myproc>
    80002a16:	d555                	beqz	a0,800029c2 <kerneltrap+0x34>
    yield();
    80002a18:	c5eff0ef          	jal	80001e76 <yield>
    80002a1c:	b75d                	j	800029c2 <kerneltrap+0x34>

0000000080002a1e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a1e:	1101                	addi	sp,sp,-32
    80002a20:	ec06                	sd	ra,24(sp)
    80002a22:	e822                	sd	s0,16(sp)
    80002a24:	e426                	sd	s1,8(sp)
    80002a26:	1000                	addi	s0,sp,32
    80002a28:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a2a:	eabfe0ef          	jal	800018d4 <myproc>
  switch (n) {
    80002a2e:	4795                	li	a5,5
    80002a30:	0497e163          	bltu	a5,s1,80002a72 <argraw+0x54>
    80002a34:	048a                	slli	s1,s1,0x2
    80002a36:	00005717          	auipc	a4,0x5
    80002a3a:	d8270713          	addi	a4,a4,-638 # 800077b8 <states.0+0x30>
    80002a3e:	94ba                	add	s1,s1,a4
    80002a40:	409c                	lw	a5,0(s1)
    80002a42:	97ba                	add	a5,a5,a4
    80002a44:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a46:	6d3c                	ld	a5,88(a0)
    80002a48:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a4a:	60e2                	ld	ra,24(sp)
    80002a4c:	6442                	ld	s0,16(sp)
    80002a4e:	64a2                	ld	s1,8(sp)
    80002a50:	6105                	addi	sp,sp,32
    80002a52:	8082                	ret
    return p->trapframe->a1;
    80002a54:	6d3c                	ld	a5,88(a0)
    80002a56:	7fa8                	ld	a0,120(a5)
    80002a58:	bfcd                	j	80002a4a <argraw+0x2c>
    return p->trapframe->a2;
    80002a5a:	6d3c                	ld	a5,88(a0)
    80002a5c:	63c8                	ld	a0,128(a5)
    80002a5e:	b7f5                	j	80002a4a <argraw+0x2c>
    return p->trapframe->a3;
    80002a60:	6d3c                	ld	a5,88(a0)
    80002a62:	67c8                	ld	a0,136(a5)
    80002a64:	b7dd                	j	80002a4a <argraw+0x2c>
    return p->trapframe->a4;
    80002a66:	6d3c                	ld	a5,88(a0)
    80002a68:	6bc8                	ld	a0,144(a5)
    80002a6a:	b7c5                	j	80002a4a <argraw+0x2c>
    return p->trapframe->a5;
    80002a6c:	6d3c                	ld	a5,88(a0)
    80002a6e:	6fc8                	ld	a0,152(a5)
    80002a70:	bfe9                	j	80002a4a <argraw+0x2c>
  panic("argraw");
    80002a72:	00005517          	auipc	a0,0x5
    80002a76:	99650513          	addi	a0,a0,-1642 # 80007408 <etext+0x408>
    80002a7a:	d1bfd0ef          	jal	80000794 <panic>

0000000080002a7e <fetchaddr>:
{
    80002a7e:	1101                	addi	sp,sp,-32
    80002a80:	ec06                	sd	ra,24(sp)
    80002a82:	e822                	sd	s0,16(sp)
    80002a84:	e426                	sd	s1,8(sp)
    80002a86:	e04a                	sd	s2,0(sp)
    80002a88:	1000                	addi	s0,sp,32
    80002a8a:	84aa                	mv	s1,a0
    80002a8c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a8e:	e47fe0ef          	jal	800018d4 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a92:	653c                	ld	a5,72(a0)
    80002a94:	02f4f663          	bgeu	s1,a5,80002ac0 <fetchaddr+0x42>
    80002a98:	00848713          	addi	a4,s1,8
    80002a9c:	02e7e463          	bltu	a5,a4,80002ac4 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002aa0:	46a1                	li	a3,8
    80002aa2:	8626                	mv	a2,s1
    80002aa4:	85ca                	mv	a1,s2
    80002aa6:	6928                	ld	a0,80(a0)
    80002aa8:	b81fe0ef          	jal	80001628 <copyin>
    80002aac:	00a03533          	snez	a0,a0
    80002ab0:	40a00533          	neg	a0,a0
}
    80002ab4:	60e2                	ld	ra,24(sp)
    80002ab6:	6442                	ld	s0,16(sp)
    80002ab8:	64a2                	ld	s1,8(sp)
    80002aba:	6902                	ld	s2,0(sp)
    80002abc:	6105                	addi	sp,sp,32
    80002abe:	8082                	ret
    return -1;
    80002ac0:	557d                	li	a0,-1
    80002ac2:	bfcd                	j	80002ab4 <fetchaddr+0x36>
    80002ac4:	557d                	li	a0,-1
    80002ac6:	b7fd                	j	80002ab4 <fetchaddr+0x36>

0000000080002ac8 <fetchstr>:
{
    80002ac8:	7179                	addi	sp,sp,-48
    80002aca:	f406                	sd	ra,40(sp)
    80002acc:	f022                	sd	s0,32(sp)
    80002ace:	ec26                	sd	s1,24(sp)
    80002ad0:	e84a                	sd	s2,16(sp)
    80002ad2:	e44e                	sd	s3,8(sp)
    80002ad4:	1800                	addi	s0,sp,48
    80002ad6:	892a                	mv	s2,a0
    80002ad8:	84ae                	mv	s1,a1
    80002ada:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002adc:	df9fe0ef          	jal	800018d4 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002ae0:	86ce                	mv	a3,s3
    80002ae2:	864a                	mv	a2,s2
    80002ae4:	85a6                	mv	a1,s1
    80002ae6:	6928                	ld	a0,80(a0)
    80002ae8:	bc7fe0ef          	jal	800016ae <copyinstr>
    80002aec:	00054c63          	bltz	a0,80002b04 <fetchstr+0x3c>
  return strlen(buf);
    80002af0:	8526                	mv	a0,s1
    80002af2:	b46fe0ef          	jal	80000e38 <strlen>
}
    80002af6:	70a2                	ld	ra,40(sp)
    80002af8:	7402                	ld	s0,32(sp)
    80002afa:	64e2                	ld	s1,24(sp)
    80002afc:	6942                	ld	s2,16(sp)
    80002afe:	69a2                	ld	s3,8(sp)
    80002b00:	6145                	addi	sp,sp,48
    80002b02:	8082                	ret
    return -1;
    80002b04:	557d                	li	a0,-1
    80002b06:	bfc5                	j	80002af6 <fetchstr+0x2e>

0000000080002b08 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b08:	1101                	addi	sp,sp,-32
    80002b0a:	ec06                	sd	ra,24(sp)
    80002b0c:	e822                	sd	s0,16(sp)
    80002b0e:	e426                	sd	s1,8(sp)
    80002b10:	1000                	addi	s0,sp,32
    80002b12:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b14:	f0bff0ef          	jal	80002a1e <argraw>
    80002b18:	c088                	sw	a0,0(s1)
}
    80002b1a:	60e2                	ld	ra,24(sp)
    80002b1c:	6442                	ld	s0,16(sp)
    80002b1e:	64a2                	ld	s1,8(sp)
    80002b20:	6105                	addi	sp,sp,32
    80002b22:	8082                	ret

0000000080002b24 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b24:	1101                	addi	sp,sp,-32
    80002b26:	ec06                	sd	ra,24(sp)
    80002b28:	e822                	sd	s0,16(sp)
    80002b2a:	e426                	sd	s1,8(sp)
    80002b2c:	1000                	addi	s0,sp,32
    80002b2e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b30:	eefff0ef          	jal	80002a1e <argraw>
    80002b34:	e088                	sd	a0,0(s1)
}
    80002b36:	60e2                	ld	ra,24(sp)
    80002b38:	6442                	ld	s0,16(sp)
    80002b3a:	64a2                	ld	s1,8(sp)
    80002b3c:	6105                	addi	sp,sp,32
    80002b3e:	8082                	ret

0000000080002b40 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b40:	7179                	addi	sp,sp,-48
    80002b42:	f406                	sd	ra,40(sp)
    80002b44:	f022                	sd	s0,32(sp)
    80002b46:	ec26                	sd	s1,24(sp)
    80002b48:	e84a                	sd	s2,16(sp)
    80002b4a:	1800                	addi	s0,sp,48
    80002b4c:	84ae                	mv	s1,a1
    80002b4e:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b50:	fd840593          	addi	a1,s0,-40
    80002b54:	fd1ff0ef          	jal	80002b24 <argaddr>
  return fetchstr(addr, buf, max);
    80002b58:	864a                	mv	a2,s2
    80002b5a:	85a6                	mv	a1,s1
    80002b5c:	fd843503          	ld	a0,-40(s0)
    80002b60:	f69ff0ef          	jal	80002ac8 <fetchstr>
}
    80002b64:	70a2                	ld	ra,40(sp)
    80002b66:	7402                	ld	s0,32(sp)
    80002b68:	64e2                	ld	s1,24(sp)
    80002b6a:	6942                	ld	s2,16(sp)
    80002b6c:	6145                	addi	sp,sp,48
    80002b6e:	8082                	ret

0000000080002b70 <syscall>:
[SYS_thread] sys_thread,
[SYS_jointhread] sys_jointhread,
};

void
syscall(void) {
    80002b70:	1101                	addi	sp,sp,-32
    80002b72:	ec06                	sd	ra,24(sp)
    80002b74:	e822                	sd	s0,16(sp)
    80002b76:	e426                	sd	s1,8(sp)
    80002b78:	e04a                	sd	s2,0(sp)
    80002b7a:	1000                	addi	s0,sp,32
int num;
struct proc *p = myproc();
    80002b7c:	d59fe0ef          	jal	800018d4 <myproc>
    80002b80:	84aa                	mv	s1,a0
struct thread *oldt = p->current_thread;
    80002b82:	1e853903          	ld	s2,488(a0)
uint64 ret;
num = p->trapframe->a7;
    80002b86:	6d3c                	ld	a5,88(a0)
    80002b88:	77dc                	ld	a5,168(a5)
    80002b8a:	0007869b          	sext.w	a3,a5
if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b8e:	37fd                	addiw	a5,a5,-1
    80002b90:	4759                	li	a4,22
    80002b92:	00f76d63          	bltu	a4,a5,80002bac <syscall+0x3c>
    80002b96:	00369713          	slli	a4,a3,0x3
    80002b9a:	00005797          	auipc	a5,0x5
    80002b9e:	c3678793          	addi	a5,a5,-970 # 800077d0 <syscalls>
    80002ba2:	97ba                	add	a5,a5,a4
    80002ba4:	639c                	ld	a5,0(a5)
    80002ba6:	c399                	beqz	a5,80002bac <syscall+0x3c>
// Use num to lookup the system call function for num, call it,
// and store its return value in p->trapframe->a0
ret = syscalls[num]();
    80002ba8:	9782                	jalr	a5
    80002baa:	a819                	j	80002bc0 <syscall+0x50>
} else {
printf("%d %s: unknown sys call %d\n",
    80002bac:	15848613          	addi	a2,s1,344
    80002bb0:	588c                	lw	a1,48(s1)
    80002bb2:	00005517          	auipc	a0,0x5
    80002bb6:	85e50513          	addi	a0,a0,-1954 # 80007410 <etext+0x410>
    80002bba:	909fd0ef          	jal	800004c2 <printf>
p->pid, p->name, num);
ret = -1;
    80002bbe:	557d                	li	a0,-1
}
struct thread *newt = p->current_thread;
    80002bc0:	1e84b783          	ld	a5,488(s1)
if (oldt != newt) {
    80002bc4:	00f90b63          	beq	s2,a5,80002bda <syscall+0x6a>
if (!oldt)
    80002bc8:	02090163          	beqz	s2,80002bea <syscall+0x7a>
oldt = &p->threads[0];
oldt->trapframe->a0 = ret;
    80002bcc:	00893783          	ld	a5,8(s2)
    80002bd0:	fba8                	sd	a0,112(a5)
}
if (oldt == newt || p->current_thread == oldt) {
    80002bd2:	1e84b783          	ld	a5,488(s1)
    80002bd6:	01279463          	bne	a5,s2,80002bde <syscall+0x6e>
p->trapframe->a0 = ret;
    80002bda:	6cbc                	ld	a5,88(s1)
    80002bdc:	fba8                	sd	a0,112(a5)
}
    80002bde:	60e2                	ld	ra,24(sp)
    80002be0:	6442                	ld	s0,16(sp)
    80002be2:	64a2                	ld	s1,8(sp)
    80002be4:	6902                	ld	s2,0(sp)
    80002be6:	6105                	addi	sp,sp,32
    80002be8:	8082                	ret
oldt = &p->threads[0];
    80002bea:	16848913          	addi	s2,s1,360
oldt->trapframe->a0 = ret;
    80002bee:	1704b703          	ld	a4,368(s1)
    80002bf2:	fb28                	sd	a0,112(a4)
if (oldt == newt || p->current_thread == oldt) {
    80002bf4:	fd279fe3          	bne	a5,s2,80002bd2 <syscall+0x62>
    80002bf8:	b7cd                	j	80002bda <syscall+0x6a>

0000000080002bfa <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002bfa:	1101                	addi	sp,sp,-32
    80002bfc:	ec06                	sd	ra,24(sp)
    80002bfe:	e822                	sd	s0,16(sp)
    80002c00:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002c02:	fec40593          	addi	a1,s0,-20
    80002c06:	4501                	li	a0,0
    80002c08:	f01ff0ef          	jal	80002b08 <argint>
  exit(n);
    80002c0c:	fec42503          	lw	a0,-20(s0)
    80002c10:	b9eff0ef          	jal	80001fae <exit>
  return 0;  // not reached
}
    80002c14:	4501                	li	a0,0
    80002c16:	60e2                	ld	ra,24(sp)
    80002c18:	6442                	ld	s0,16(sp)
    80002c1a:	6105                	addi	sp,sp,32
    80002c1c:	8082                	ret

0000000080002c1e <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c1e:	1141                	addi	sp,sp,-16
    80002c20:	e406                	sd	ra,8(sp)
    80002c22:	e022                	sd	s0,0(sp)
    80002c24:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c26:	caffe0ef          	jal	800018d4 <myproc>
}
    80002c2a:	5908                	lw	a0,48(a0)
    80002c2c:	60a2                	ld	ra,8(sp)
    80002c2e:	6402                	ld	s0,0(sp)
    80002c30:	0141                	addi	sp,sp,16
    80002c32:	8082                	ret

0000000080002c34 <sys_fork>:

uint64
sys_fork(void)
{
    80002c34:	1141                	addi	sp,sp,-16
    80002c36:	e406                	sd	ra,8(sp)
    80002c38:	e022                	sd	s0,0(sp)
    80002c3a:	0800                	addi	s0,sp,16
  return fork();
    80002c3c:	fbffe0ef          	jal	80001bfa <fork>
}
    80002c40:	60a2                	ld	ra,8(sp)
    80002c42:	6402                	ld	s0,0(sp)
    80002c44:	0141                	addi	sp,sp,16
    80002c46:	8082                	ret

0000000080002c48 <sys_wait>:

uint64
sys_wait(void)
{
    80002c48:	1101                	addi	sp,sp,-32
    80002c4a:	ec06                	sd	ra,24(sp)
    80002c4c:	e822                	sd	s0,16(sp)
    80002c4e:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c50:	fe840593          	addi	a1,s0,-24
    80002c54:	4501                	li	a0,0
    80002c56:	ecfff0ef          	jal	80002b24 <argaddr>
  return wait(p);
    80002c5a:	fe843503          	ld	a0,-24(s0)
    80002c5e:	ca6ff0ef          	jal	80002104 <wait>
}
    80002c62:	60e2                	ld	ra,24(sp)
    80002c64:	6442                	ld	s0,16(sp)
    80002c66:	6105                	addi	sp,sp,32
    80002c68:	8082                	ret

0000000080002c6a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c6a:	7179                	addi	sp,sp,-48
    80002c6c:	f406                	sd	ra,40(sp)
    80002c6e:	f022                	sd	s0,32(sp)
    80002c70:	ec26                	sd	s1,24(sp)
    80002c72:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002c74:	fdc40593          	addi	a1,s0,-36
    80002c78:	4501                	li	a0,0
    80002c7a:	e8fff0ef          	jal	80002b08 <argint>
  addr = myproc()->sz;
    80002c7e:	c57fe0ef          	jal	800018d4 <myproc>
    80002c82:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002c84:	fdc42503          	lw	a0,-36(s0)
    80002c88:	f23fe0ef          	jal	80001baa <growproc>
    80002c8c:	00054863          	bltz	a0,80002c9c <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002c90:	8526                	mv	a0,s1
    80002c92:	70a2                	ld	ra,40(sp)
    80002c94:	7402                	ld	s0,32(sp)
    80002c96:	64e2                	ld	s1,24(sp)
    80002c98:	6145                	addi	sp,sp,48
    80002c9a:	8082                	ret
    return -1;
    80002c9c:	54fd                	li	s1,-1
    80002c9e:	bfcd                	j	80002c90 <sys_sbrk+0x26>

0000000080002ca0 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002ca0:	7139                	addi	sp,sp,-64
    80002ca2:	fc06                	sd	ra,56(sp)
    80002ca4:	f822                	sd	s0,48(sp)
    80002ca6:	f04a                	sd	s2,32(sp)
    80002ca8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002caa:	fcc40593          	addi	a1,s0,-52
    80002cae:	4501                	li	a0,0
    80002cb0:	e59ff0ef          	jal	80002b08 <argint>
  if(n < 0)
    80002cb4:	fcc42783          	lw	a5,-52(s0)
    80002cb8:	0607c763          	bltz	a5,80002d26 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002cbc:	00015517          	auipc	a0,0x15
    80002cc0:	db450513          	addi	a0,a0,-588 # 80017a70 <tickslock>
    80002cc4:	f31fd0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    80002cc8:	00005917          	auipc	s2,0x5
    80002ccc:	c4892903          	lw	s2,-952(s2) # 80007910 <ticks>
  while(ticks - ticks0 < n){
    80002cd0:	fcc42783          	lw	a5,-52(s0)
    80002cd4:	cf8d                	beqz	a5,80002d0e <sys_sleep+0x6e>
    80002cd6:	f426                	sd	s1,40(sp)
    80002cd8:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002cda:	00015997          	auipc	s3,0x15
    80002cde:	d9698993          	addi	s3,s3,-618 # 80017a70 <tickslock>
    80002ce2:	00005497          	auipc	s1,0x5
    80002ce6:	c2e48493          	addi	s1,s1,-978 # 80007910 <ticks>
    if(killed(myproc())){
    80002cea:	bebfe0ef          	jal	800018d4 <myproc>
    80002cee:	becff0ef          	jal	800020da <killed>
    80002cf2:	ed0d                	bnez	a0,80002d2c <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002cf4:	85ce                	mv	a1,s3
    80002cf6:	8526                	mv	a0,s1
    80002cf8:	9aaff0ef          	jal	80001ea2 <sleep>
  while(ticks - ticks0 < n){
    80002cfc:	409c                	lw	a5,0(s1)
    80002cfe:	412787bb          	subw	a5,a5,s2
    80002d02:	fcc42703          	lw	a4,-52(s0)
    80002d06:	fee7e2e3          	bltu	a5,a4,80002cea <sys_sleep+0x4a>
    80002d0a:	74a2                	ld	s1,40(sp)
    80002d0c:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002d0e:	00015517          	auipc	a0,0x15
    80002d12:	d6250513          	addi	a0,a0,-670 # 80017a70 <tickslock>
    80002d16:	f77fd0ef          	jal	80000c8c <release>
  return 0;
    80002d1a:	4501                	li	a0,0
}
    80002d1c:	70e2                	ld	ra,56(sp)
    80002d1e:	7442                	ld	s0,48(sp)
    80002d20:	7902                	ld	s2,32(sp)
    80002d22:	6121                	addi	sp,sp,64
    80002d24:	8082                	ret
    n = 0;
    80002d26:	fc042623          	sw	zero,-52(s0)
    80002d2a:	bf49                	j	80002cbc <sys_sleep+0x1c>
      release(&tickslock);
    80002d2c:	00015517          	auipc	a0,0x15
    80002d30:	d4450513          	addi	a0,a0,-700 # 80017a70 <tickslock>
    80002d34:	f59fd0ef          	jal	80000c8c <release>
      return -1;
    80002d38:	557d                	li	a0,-1
    80002d3a:	74a2                	ld	s1,40(sp)
    80002d3c:	69e2                	ld	s3,24(sp)
    80002d3e:	bff9                	j	80002d1c <sys_sleep+0x7c>

0000000080002d40 <sys_kill>:

uint64
sys_kill(void)
{
    80002d40:	1101                	addi	sp,sp,-32
    80002d42:	ec06                	sd	ra,24(sp)
    80002d44:	e822                	sd	s0,16(sp)
    80002d46:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d48:	fec40593          	addi	a1,s0,-20
    80002d4c:	4501                	li	a0,0
    80002d4e:	dbbff0ef          	jal	80002b08 <argint>
  return kill(pid);
    80002d52:	fec42503          	lw	a0,-20(s0)
    80002d56:	afaff0ef          	jal	80002050 <kill>
}
    80002d5a:	60e2                	ld	ra,24(sp)
    80002d5c:	6442                	ld	s0,16(sp)
    80002d5e:	6105                	addi	sp,sp,32
    80002d60:	8082                	ret

0000000080002d62 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d62:	1101                	addi	sp,sp,-32
    80002d64:	ec06                	sd	ra,24(sp)
    80002d66:	e822                	sd	s0,16(sp)
    80002d68:	e426                	sd	s1,8(sp)
    80002d6a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d6c:	00015517          	auipc	a0,0x15
    80002d70:	d0450513          	addi	a0,a0,-764 # 80017a70 <tickslock>
    80002d74:	e81fd0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    80002d78:	00005497          	auipc	s1,0x5
    80002d7c:	b984a483          	lw	s1,-1128(s1) # 80007910 <ticks>
  release(&tickslock);
    80002d80:	00015517          	auipc	a0,0x15
    80002d84:	cf050513          	addi	a0,a0,-784 # 80017a70 <tickslock>
    80002d88:	f05fd0ef          	jal	80000c8c <release>
  return xticks;
}
    80002d8c:	02049513          	slli	a0,s1,0x20
    80002d90:	9101                	srli	a0,a0,0x20
    80002d92:	60e2                	ld	ra,24(sp)
    80002d94:	6442                	ld	s0,16(sp)
    80002d96:	64a2                	ld	s1,8(sp)
    80002d98:	6105                	addi	sp,sp,32
    80002d9a:	8082                	ret

0000000080002d9c <sys_thread>:
uint64 sys_thread(void) {
    80002d9c:	7179                	addi	sp,sp,-48
    80002d9e:	f406                	sd	ra,40(sp)
    80002da0:	f022                	sd	s0,32(sp)
    80002da2:	1800                	addi	s0,sp,48
  uint64 start_thread, stack_address, arg;
  argaddr(0, &start_thread);
    80002da4:	fe840593          	addi	a1,s0,-24
    80002da8:	4501                	li	a0,0
    80002daa:	d7bff0ef          	jal	80002b24 <argaddr>
  argaddr(1, &stack_address);
    80002dae:	fe040593          	addi	a1,s0,-32
    80002db2:	4505                	li	a0,1
    80002db4:	d71ff0ef          	jal	80002b24 <argaddr>
  argaddr(2, &arg);
    80002db8:	fd840593          	addi	a1,s0,-40
    80002dbc:	4509                	li	a0,2
    80002dbe:	d67ff0ef          	jal	80002b24 <argaddr>
  struct thread *t = allocthread(start_thread, stack_address, arg);
    80002dc2:	fd843603          	ld	a2,-40(s0)
    80002dc6:	fe043583          	ld	a1,-32(s0)
    80002dca:	fe843503          	ld	a0,-24(s0)
    80002dce:	82dff0ef          	jal	800025fa <allocthread>
    80002dd2:	87aa                	mv	a5,a0
  return t ? t->id : 0;
    80002dd4:	4501                	li	a0,0
    80002dd6:	c399                	beqz	a5,80002ddc <sys_thread+0x40>
    80002dd8:	0107e503          	lwu	a0,16(a5)
  }
    80002ddc:	70a2                	ld	ra,40(sp)
    80002dde:	7402                	ld	s0,32(sp)
    80002de0:	6145                	addi	sp,sp,48
    80002de2:	8082                	ret

0000000080002de4 <sys_jointhread>:
  uint64 sys_jointhread(void) {
    80002de4:	1101                	addi	sp,sp,-32
    80002de6:	ec06                	sd	ra,24(sp)
    80002de8:	e822                	sd	s0,16(sp)
    80002dea:	1000                	addi	s0,sp,32
    int id;
    argint(0, &id);
    80002dec:	fec40593          	addi	a1,s0,-20
    80002df0:	4501                	li	a0,0
    80002df2:	d17ff0ef          	jal	80002b08 <argint>
    return jointhread(id);
    80002df6:	fec42503          	lw	a0,-20(s0)
    80002dfa:	d3cff0ef          	jal	80002336 <jointhread>
    80002dfe:	60e2                	ld	ra,24(sp)
    80002e00:	6442                	ld	s0,16(sp)
    80002e02:	6105                	addi	sp,sp,32
    80002e04:	8082                	ret

0000000080002e06 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e06:	7179                	addi	sp,sp,-48
    80002e08:	f406                	sd	ra,40(sp)
    80002e0a:	f022                	sd	s0,32(sp)
    80002e0c:	ec26                	sd	s1,24(sp)
    80002e0e:	e84a                	sd	s2,16(sp)
    80002e10:	e44e                	sd	s3,8(sp)
    80002e12:	e052                	sd	s4,0(sp)
    80002e14:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e16:	00004597          	auipc	a1,0x4
    80002e1a:	61a58593          	addi	a1,a1,1562 # 80007430 <etext+0x430>
    80002e1e:	00015517          	auipc	a0,0x15
    80002e22:	c6a50513          	addi	a0,a0,-918 # 80017a88 <bcache>
    80002e26:	d4ffd0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e2a:	0001d797          	auipc	a5,0x1d
    80002e2e:	c5e78793          	addi	a5,a5,-930 # 8001fa88 <bcache+0x8000>
    80002e32:	0001d717          	auipc	a4,0x1d
    80002e36:	ebe70713          	addi	a4,a4,-322 # 8001fcf0 <bcache+0x8268>
    80002e3a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e3e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e42:	00015497          	auipc	s1,0x15
    80002e46:	c5e48493          	addi	s1,s1,-930 # 80017aa0 <bcache+0x18>
    b->next = bcache.head.next;
    80002e4a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e4c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e4e:	00004a17          	auipc	s4,0x4
    80002e52:	5eaa0a13          	addi	s4,s4,1514 # 80007438 <etext+0x438>
    b->next = bcache.head.next;
    80002e56:	2b893783          	ld	a5,696(s2)
    80002e5a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e5c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e60:	85d2                	mv	a1,s4
    80002e62:	01048513          	addi	a0,s1,16
    80002e66:	248010ef          	jal	800040ae <initsleeplock>
    bcache.head.next->prev = b;
    80002e6a:	2b893783          	ld	a5,696(s2)
    80002e6e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e70:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e74:	45848493          	addi	s1,s1,1112
    80002e78:	fd349fe3          	bne	s1,s3,80002e56 <binit+0x50>
  }
}
    80002e7c:	70a2                	ld	ra,40(sp)
    80002e7e:	7402                	ld	s0,32(sp)
    80002e80:	64e2                	ld	s1,24(sp)
    80002e82:	6942                	ld	s2,16(sp)
    80002e84:	69a2                	ld	s3,8(sp)
    80002e86:	6a02                	ld	s4,0(sp)
    80002e88:	6145                	addi	sp,sp,48
    80002e8a:	8082                	ret

0000000080002e8c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e8c:	7179                	addi	sp,sp,-48
    80002e8e:	f406                	sd	ra,40(sp)
    80002e90:	f022                	sd	s0,32(sp)
    80002e92:	ec26                	sd	s1,24(sp)
    80002e94:	e84a                	sd	s2,16(sp)
    80002e96:	e44e                	sd	s3,8(sp)
    80002e98:	1800                	addi	s0,sp,48
    80002e9a:	892a                	mv	s2,a0
    80002e9c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e9e:	00015517          	auipc	a0,0x15
    80002ea2:	bea50513          	addi	a0,a0,-1046 # 80017a88 <bcache>
    80002ea6:	d4ffd0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002eaa:	0001d497          	auipc	s1,0x1d
    80002eae:	e964b483          	ld	s1,-362(s1) # 8001fd40 <bcache+0x82b8>
    80002eb2:	0001d797          	auipc	a5,0x1d
    80002eb6:	e3e78793          	addi	a5,a5,-450 # 8001fcf0 <bcache+0x8268>
    80002eba:	02f48b63          	beq	s1,a5,80002ef0 <bread+0x64>
    80002ebe:	873e                	mv	a4,a5
    80002ec0:	a021                	j	80002ec8 <bread+0x3c>
    80002ec2:	68a4                	ld	s1,80(s1)
    80002ec4:	02e48663          	beq	s1,a4,80002ef0 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002ec8:	449c                	lw	a5,8(s1)
    80002eca:	ff279ce3          	bne	a5,s2,80002ec2 <bread+0x36>
    80002ece:	44dc                	lw	a5,12(s1)
    80002ed0:	ff3799e3          	bne	a5,s3,80002ec2 <bread+0x36>
      b->refcnt++;
    80002ed4:	40bc                	lw	a5,64(s1)
    80002ed6:	2785                	addiw	a5,a5,1
    80002ed8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002eda:	00015517          	auipc	a0,0x15
    80002ede:	bae50513          	addi	a0,a0,-1106 # 80017a88 <bcache>
    80002ee2:	dabfd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002ee6:	01048513          	addi	a0,s1,16
    80002eea:	1fa010ef          	jal	800040e4 <acquiresleep>
      return b;
    80002eee:	a889                	j	80002f40 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ef0:	0001d497          	auipc	s1,0x1d
    80002ef4:	e484b483          	ld	s1,-440(s1) # 8001fd38 <bcache+0x82b0>
    80002ef8:	0001d797          	auipc	a5,0x1d
    80002efc:	df878793          	addi	a5,a5,-520 # 8001fcf0 <bcache+0x8268>
    80002f00:	00f48863          	beq	s1,a5,80002f10 <bread+0x84>
    80002f04:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f06:	40bc                	lw	a5,64(s1)
    80002f08:	cb91                	beqz	a5,80002f1c <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f0a:	64a4                	ld	s1,72(s1)
    80002f0c:	fee49de3          	bne	s1,a4,80002f06 <bread+0x7a>
  panic("bget: no buffers");
    80002f10:	00004517          	auipc	a0,0x4
    80002f14:	53050513          	addi	a0,a0,1328 # 80007440 <etext+0x440>
    80002f18:	87dfd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80002f1c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f20:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f24:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f28:	4785                	li	a5,1
    80002f2a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f2c:	00015517          	auipc	a0,0x15
    80002f30:	b5c50513          	addi	a0,a0,-1188 # 80017a88 <bcache>
    80002f34:	d59fd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002f38:	01048513          	addi	a0,s1,16
    80002f3c:	1a8010ef          	jal	800040e4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f40:	409c                	lw	a5,0(s1)
    80002f42:	cb89                	beqz	a5,80002f54 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f44:	8526                	mv	a0,s1
    80002f46:	70a2                	ld	ra,40(sp)
    80002f48:	7402                	ld	s0,32(sp)
    80002f4a:	64e2                	ld	s1,24(sp)
    80002f4c:	6942                	ld	s2,16(sp)
    80002f4e:	69a2                	ld	s3,8(sp)
    80002f50:	6145                	addi	sp,sp,48
    80002f52:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f54:	4581                	li	a1,0
    80002f56:	8526                	mv	a0,s1
    80002f58:	1e9020ef          	jal	80005940 <virtio_disk_rw>
    b->valid = 1;
    80002f5c:	4785                	li	a5,1
    80002f5e:	c09c                	sw	a5,0(s1)
  return b;
    80002f60:	b7d5                	j	80002f44 <bread+0xb8>

0000000080002f62 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f62:	1101                	addi	sp,sp,-32
    80002f64:	ec06                	sd	ra,24(sp)
    80002f66:	e822                	sd	s0,16(sp)
    80002f68:	e426                	sd	s1,8(sp)
    80002f6a:	1000                	addi	s0,sp,32
    80002f6c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f6e:	0541                	addi	a0,a0,16
    80002f70:	1f2010ef          	jal	80004162 <holdingsleep>
    80002f74:	c911                	beqz	a0,80002f88 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f76:	4585                	li	a1,1
    80002f78:	8526                	mv	a0,s1
    80002f7a:	1c7020ef          	jal	80005940 <virtio_disk_rw>
}
    80002f7e:	60e2                	ld	ra,24(sp)
    80002f80:	6442                	ld	s0,16(sp)
    80002f82:	64a2                	ld	s1,8(sp)
    80002f84:	6105                	addi	sp,sp,32
    80002f86:	8082                	ret
    panic("bwrite");
    80002f88:	00004517          	auipc	a0,0x4
    80002f8c:	4d050513          	addi	a0,a0,1232 # 80007458 <etext+0x458>
    80002f90:	805fd0ef          	jal	80000794 <panic>

0000000080002f94 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002f94:	1101                	addi	sp,sp,-32
    80002f96:	ec06                	sd	ra,24(sp)
    80002f98:	e822                	sd	s0,16(sp)
    80002f9a:	e426                	sd	s1,8(sp)
    80002f9c:	e04a                	sd	s2,0(sp)
    80002f9e:	1000                	addi	s0,sp,32
    80002fa0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fa2:	01050913          	addi	s2,a0,16
    80002fa6:	854a                	mv	a0,s2
    80002fa8:	1ba010ef          	jal	80004162 <holdingsleep>
    80002fac:	c135                	beqz	a0,80003010 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002fae:	854a                	mv	a0,s2
    80002fb0:	17a010ef          	jal	8000412a <releasesleep>

  acquire(&bcache.lock);
    80002fb4:	00015517          	auipc	a0,0x15
    80002fb8:	ad450513          	addi	a0,a0,-1324 # 80017a88 <bcache>
    80002fbc:	c39fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002fc0:	40bc                	lw	a5,64(s1)
    80002fc2:	37fd                	addiw	a5,a5,-1
    80002fc4:	0007871b          	sext.w	a4,a5
    80002fc8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002fca:	e71d                	bnez	a4,80002ff8 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002fcc:	68b8                	ld	a4,80(s1)
    80002fce:	64bc                	ld	a5,72(s1)
    80002fd0:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002fd2:	68b8                	ld	a4,80(s1)
    80002fd4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002fd6:	0001d797          	auipc	a5,0x1d
    80002fda:	ab278793          	addi	a5,a5,-1358 # 8001fa88 <bcache+0x8000>
    80002fde:	2b87b703          	ld	a4,696(a5)
    80002fe2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002fe4:	0001d717          	auipc	a4,0x1d
    80002fe8:	d0c70713          	addi	a4,a4,-756 # 8001fcf0 <bcache+0x8268>
    80002fec:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002fee:	2b87b703          	ld	a4,696(a5)
    80002ff2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002ff4:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002ff8:	00015517          	auipc	a0,0x15
    80002ffc:	a9050513          	addi	a0,a0,-1392 # 80017a88 <bcache>
    80003000:	c8dfd0ef          	jal	80000c8c <release>
}
    80003004:	60e2                	ld	ra,24(sp)
    80003006:	6442                	ld	s0,16(sp)
    80003008:	64a2                	ld	s1,8(sp)
    8000300a:	6902                	ld	s2,0(sp)
    8000300c:	6105                	addi	sp,sp,32
    8000300e:	8082                	ret
    panic("brelse");
    80003010:	00004517          	auipc	a0,0x4
    80003014:	45050513          	addi	a0,a0,1104 # 80007460 <etext+0x460>
    80003018:	f7cfd0ef          	jal	80000794 <panic>

000000008000301c <bpin>:

void
bpin(struct buf *b) {
    8000301c:	1101                	addi	sp,sp,-32
    8000301e:	ec06                	sd	ra,24(sp)
    80003020:	e822                	sd	s0,16(sp)
    80003022:	e426                	sd	s1,8(sp)
    80003024:	1000                	addi	s0,sp,32
    80003026:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003028:	00015517          	auipc	a0,0x15
    8000302c:	a6050513          	addi	a0,a0,-1440 # 80017a88 <bcache>
    80003030:	bc5fd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    80003034:	40bc                	lw	a5,64(s1)
    80003036:	2785                	addiw	a5,a5,1
    80003038:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000303a:	00015517          	auipc	a0,0x15
    8000303e:	a4e50513          	addi	a0,a0,-1458 # 80017a88 <bcache>
    80003042:	c4bfd0ef          	jal	80000c8c <release>
}
    80003046:	60e2                	ld	ra,24(sp)
    80003048:	6442                	ld	s0,16(sp)
    8000304a:	64a2                	ld	s1,8(sp)
    8000304c:	6105                	addi	sp,sp,32
    8000304e:	8082                	ret

0000000080003050 <bunpin>:

void
bunpin(struct buf *b) {
    80003050:	1101                	addi	sp,sp,-32
    80003052:	ec06                	sd	ra,24(sp)
    80003054:	e822                	sd	s0,16(sp)
    80003056:	e426                	sd	s1,8(sp)
    80003058:	1000                	addi	s0,sp,32
    8000305a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000305c:	00015517          	auipc	a0,0x15
    80003060:	a2c50513          	addi	a0,a0,-1492 # 80017a88 <bcache>
    80003064:	b91fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80003068:	40bc                	lw	a5,64(s1)
    8000306a:	37fd                	addiw	a5,a5,-1
    8000306c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000306e:	00015517          	auipc	a0,0x15
    80003072:	a1a50513          	addi	a0,a0,-1510 # 80017a88 <bcache>
    80003076:	c17fd0ef          	jal	80000c8c <release>
}
    8000307a:	60e2                	ld	ra,24(sp)
    8000307c:	6442                	ld	s0,16(sp)
    8000307e:	64a2                	ld	s1,8(sp)
    80003080:	6105                	addi	sp,sp,32
    80003082:	8082                	ret

0000000080003084 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003084:	1101                	addi	sp,sp,-32
    80003086:	ec06                	sd	ra,24(sp)
    80003088:	e822                	sd	s0,16(sp)
    8000308a:	e426                	sd	s1,8(sp)
    8000308c:	e04a                	sd	s2,0(sp)
    8000308e:	1000                	addi	s0,sp,32
    80003090:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003092:	00d5d59b          	srliw	a1,a1,0xd
    80003096:	0001d797          	auipc	a5,0x1d
    8000309a:	0ce7a783          	lw	a5,206(a5) # 80020164 <sb+0x1c>
    8000309e:	9dbd                	addw	a1,a1,a5
    800030a0:	dedff0ef          	jal	80002e8c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800030a4:	0074f713          	andi	a4,s1,7
    800030a8:	4785                	li	a5,1
    800030aa:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800030ae:	14ce                	slli	s1,s1,0x33
    800030b0:	90d9                	srli	s1,s1,0x36
    800030b2:	00950733          	add	a4,a0,s1
    800030b6:	05874703          	lbu	a4,88(a4)
    800030ba:	00e7f6b3          	and	a3,a5,a4
    800030be:	c29d                	beqz	a3,800030e4 <bfree+0x60>
    800030c0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800030c2:	94aa                	add	s1,s1,a0
    800030c4:	fff7c793          	not	a5,a5
    800030c8:	8f7d                	and	a4,a4,a5
    800030ca:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800030ce:	711000ef          	jal	80003fde <log_write>
  brelse(bp);
    800030d2:	854a                	mv	a0,s2
    800030d4:	ec1ff0ef          	jal	80002f94 <brelse>
}
    800030d8:	60e2                	ld	ra,24(sp)
    800030da:	6442                	ld	s0,16(sp)
    800030dc:	64a2                	ld	s1,8(sp)
    800030de:	6902                	ld	s2,0(sp)
    800030e0:	6105                	addi	sp,sp,32
    800030e2:	8082                	ret
    panic("freeing free block");
    800030e4:	00004517          	auipc	a0,0x4
    800030e8:	38450513          	addi	a0,a0,900 # 80007468 <etext+0x468>
    800030ec:	ea8fd0ef          	jal	80000794 <panic>

00000000800030f0 <balloc>:
{
    800030f0:	711d                	addi	sp,sp,-96
    800030f2:	ec86                	sd	ra,88(sp)
    800030f4:	e8a2                	sd	s0,80(sp)
    800030f6:	e4a6                	sd	s1,72(sp)
    800030f8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800030fa:	0001d797          	auipc	a5,0x1d
    800030fe:	0527a783          	lw	a5,82(a5) # 8002014c <sb+0x4>
    80003102:	0e078f63          	beqz	a5,80003200 <balloc+0x110>
    80003106:	e0ca                	sd	s2,64(sp)
    80003108:	fc4e                	sd	s3,56(sp)
    8000310a:	f852                	sd	s4,48(sp)
    8000310c:	f456                	sd	s5,40(sp)
    8000310e:	f05a                	sd	s6,32(sp)
    80003110:	ec5e                	sd	s7,24(sp)
    80003112:	e862                	sd	s8,16(sp)
    80003114:	e466                	sd	s9,8(sp)
    80003116:	8baa                	mv	s7,a0
    80003118:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000311a:	0001db17          	auipc	s6,0x1d
    8000311e:	02eb0b13          	addi	s6,s6,46 # 80020148 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003122:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003124:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003126:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003128:	6c89                	lui	s9,0x2
    8000312a:	a0b5                	j	80003196 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000312c:	97ca                	add	a5,a5,s2
    8000312e:	8e55                	or	a2,a2,a3
    80003130:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003134:	854a                	mv	a0,s2
    80003136:	6a9000ef          	jal	80003fde <log_write>
        brelse(bp);
    8000313a:	854a                	mv	a0,s2
    8000313c:	e59ff0ef          	jal	80002f94 <brelse>
  bp = bread(dev, bno);
    80003140:	85a6                	mv	a1,s1
    80003142:	855e                	mv	a0,s7
    80003144:	d49ff0ef          	jal	80002e8c <bread>
    80003148:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000314a:	40000613          	li	a2,1024
    8000314e:	4581                	li	a1,0
    80003150:	05850513          	addi	a0,a0,88
    80003154:	b75fd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    80003158:	854a                	mv	a0,s2
    8000315a:	685000ef          	jal	80003fde <log_write>
  brelse(bp);
    8000315e:	854a                	mv	a0,s2
    80003160:	e35ff0ef          	jal	80002f94 <brelse>
}
    80003164:	6906                	ld	s2,64(sp)
    80003166:	79e2                	ld	s3,56(sp)
    80003168:	7a42                	ld	s4,48(sp)
    8000316a:	7aa2                	ld	s5,40(sp)
    8000316c:	7b02                	ld	s6,32(sp)
    8000316e:	6be2                	ld	s7,24(sp)
    80003170:	6c42                	ld	s8,16(sp)
    80003172:	6ca2                	ld	s9,8(sp)
}
    80003174:	8526                	mv	a0,s1
    80003176:	60e6                	ld	ra,88(sp)
    80003178:	6446                	ld	s0,80(sp)
    8000317a:	64a6                	ld	s1,72(sp)
    8000317c:	6125                	addi	sp,sp,96
    8000317e:	8082                	ret
    brelse(bp);
    80003180:	854a                	mv	a0,s2
    80003182:	e13ff0ef          	jal	80002f94 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003186:	015c87bb          	addw	a5,s9,s5
    8000318a:	00078a9b          	sext.w	s5,a5
    8000318e:	004b2703          	lw	a4,4(s6)
    80003192:	04eaff63          	bgeu	s5,a4,800031f0 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80003196:	41fad79b          	sraiw	a5,s5,0x1f
    8000319a:	0137d79b          	srliw	a5,a5,0x13
    8000319e:	015787bb          	addw	a5,a5,s5
    800031a2:	40d7d79b          	sraiw	a5,a5,0xd
    800031a6:	01cb2583          	lw	a1,28(s6)
    800031aa:	9dbd                	addw	a1,a1,a5
    800031ac:	855e                	mv	a0,s7
    800031ae:	cdfff0ef          	jal	80002e8c <bread>
    800031b2:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031b4:	004b2503          	lw	a0,4(s6)
    800031b8:	000a849b          	sext.w	s1,s5
    800031bc:	8762                	mv	a4,s8
    800031be:	fca4f1e3          	bgeu	s1,a0,80003180 <balloc+0x90>
      m = 1 << (bi % 8);
    800031c2:	00777693          	andi	a3,a4,7
    800031c6:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800031ca:	41f7579b          	sraiw	a5,a4,0x1f
    800031ce:	01d7d79b          	srliw	a5,a5,0x1d
    800031d2:	9fb9                	addw	a5,a5,a4
    800031d4:	4037d79b          	sraiw	a5,a5,0x3
    800031d8:	00f90633          	add	a2,s2,a5
    800031dc:	05864603          	lbu	a2,88(a2)
    800031e0:	00c6f5b3          	and	a1,a3,a2
    800031e4:	d5a1                	beqz	a1,8000312c <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031e6:	2705                	addiw	a4,a4,1
    800031e8:	2485                	addiw	s1,s1,1
    800031ea:	fd471ae3          	bne	a4,s4,800031be <balloc+0xce>
    800031ee:	bf49                	j	80003180 <balloc+0x90>
    800031f0:	6906                	ld	s2,64(sp)
    800031f2:	79e2                	ld	s3,56(sp)
    800031f4:	7a42                	ld	s4,48(sp)
    800031f6:	7aa2                	ld	s5,40(sp)
    800031f8:	7b02                	ld	s6,32(sp)
    800031fa:	6be2                	ld	s7,24(sp)
    800031fc:	6c42                	ld	s8,16(sp)
    800031fe:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003200:	00004517          	auipc	a0,0x4
    80003204:	28050513          	addi	a0,a0,640 # 80007480 <etext+0x480>
    80003208:	abafd0ef          	jal	800004c2 <printf>
  return 0;
    8000320c:	4481                	li	s1,0
    8000320e:	b79d                	j	80003174 <balloc+0x84>

0000000080003210 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003210:	7179                	addi	sp,sp,-48
    80003212:	f406                	sd	ra,40(sp)
    80003214:	f022                	sd	s0,32(sp)
    80003216:	ec26                	sd	s1,24(sp)
    80003218:	e84a                	sd	s2,16(sp)
    8000321a:	e44e                	sd	s3,8(sp)
    8000321c:	1800                	addi	s0,sp,48
    8000321e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003220:	47ad                	li	a5,11
    80003222:	02b7e663          	bltu	a5,a1,8000324e <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003226:	02059793          	slli	a5,a1,0x20
    8000322a:	01e7d593          	srli	a1,a5,0x1e
    8000322e:	00b504b3          	add	s1,a0,a1
    80003232:	0504a903          	lw	s2,80(s1)
    80003236:	06091a63          	bnez	s2,800032aa <bmap+0x9a>
      addr = balloc(ip->dev);
    8000323a:	4108                	lw	a0,0(a0)
    8000323c:	eb5ff0ef          	jal	800030f0 <balloc>
    80003240:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003244:	06090363          	beqz	s2,800032aa <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80003248:	0524a823          	sw	s2,80(s1)
    8000324c:	a8b9                	j	800032aa <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000324e:	ff45849b          	addiw	s1,a1,-12
    80003252:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003256:	0ff00793          	li	a5,255
    8000325a:	06e7ee63          	bltu	a5,a4,800032d6 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000325e:	08052903          	lw	s2,128(a0)
    80003262:	00091d63          	bnez	s2,8000327c <bmap+0x6c>
      addr = balloc(ip->dev);
    80003266:	4108                	lw	a0,0(a0)
    80003268:	e89ff0ef          	jal	800030f0 <balloc>
    8000326c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003270:	02090d63          	beqz	s2,800032aa <bmap+0x9a>
    80003274:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003276:	0929a023          	sw	s2,128(s3)
    8000327a:	a011                	j	8000327e <bmap+0x6e>
    8000327c:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000327e:	85ca                	mv	a1,s2
    80003280:	0009a503          	lw	a0,0(s3)
    80003284:	c09ff0ef          	jal	80002e8c <bread>
    80003288:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000328a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000328e:	02049713          	slli	a4,s1,0x20
    80003292:	01e75593          	srli	a1,a4,0x1e
    80003296:	00b784b3          	add	s1,a5,a1
    8000329a:	0004a903          	lw	s2,0(s1)
    8000329e:	00090e63          	beqz	s2,800032ba <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800032a2:	8552                	mv	a0,s4
    800032a4:	cf1ff0ef          	jal	80002f94 <brelse>
    return addr;
    800032a8:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800032aa:	854a                	mv	a0,s2
    800032ac:	70a2                	ld	ra,40(sp)
    800032ae:	7402                	ld	s0,32(sp)
    800032b0:	64e2                	ld	s1,24(sp)
    800032b2:	6942                	ld	s2,16(sp)
    800032b4:	69a2                	ld	s3,8(sp)
    800032b6:	6145                	addi	sp,sp,48
    800032b8:	8082                	ret
      addr = balloc(ip->dev);
    800032ba:	0009a503          	lw	a0,0(s3)
    800032be:	e33ff0ef          	jal	800030f0 <balloc>
    800032c2:	0005091b          	sext.w	s2,a0
      if(addr){
    800032c6:	fc090ee3          	beqz	s2,800032a2 <bmap+0x92>
        a[bn] = addr;
    800032ca:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800032ce:	8552                	mv	a0,s4
    800032d0:	50f000ef          	jal	80003fde <log_write>
    800032d4:	b7f9                	j	800032a2 <bmap+0x92>
    800032d6:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800032d8:	00004517          	auipc	a0,0x4
    800032dc:	1c050513          	addi	a0,a0,448 # 80007498 <etext+0x498>
    800032e0:	cb4fd0ef          	jal	80000794 <panic>

00000000800032e4 <iget>:
{
    800032e4:	7179                	addi	sp,sp,-48
    800032e6:	f406                	sd	ra,40(sp)
    800032e8:	f022                	sd	s0,32(sp)
    800032ea:	ec26                	sd	s1,24(sp)
    800032ec:	e84a                	sd	s2,16(sp)
    800032ee:	e44e                	sd	s3,8(sp)
    800032f0:	e052                	sd	s4,0(sp)
    800032f2:	1800                	addi	s0,sp,48
    800032f4:	89aa                	mv	s3,a0
    800032f6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800032f8:	0001d517          	auipc	a0,0x1d
    800032fc:	e7050513          	addi	a0,a0,-400 # 80020168 <itable>
    80003300:	8f5fd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    80003304:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003306:	0001d497          	auipc	s1,0x1d
    8000330a:	e7a48493          	addi	s1,s1,-390 # 80020180 <itable+0x18>
    8000330e:	0001f697          	auipc	a3,0x1f
    80003312:	90268693          	addi	a3,a3,-1790 # 80021c10 <log>
    80003316:	a039                	j	80003324 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003318:	02090963          	beqz	s2,8000334a <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000331c:	08848493          	addi	s1,s1,136
    80003320:	02d48863          	beq	s1,a3,80003350 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003324:	449c                	lw	a5,8(s1)
    80003326:	fef059e3          	blez	a5,80003318 <iget+0x34>
    8000332a:	4098                	lw	a4,0(s1)
    8000332c:	ff3716e3          	bne	a4,s3,80003318 <iget+0x34>
    80003330:	40d8                	lw	a4,4(s1)
    80003332:	ff4713e3          	bne	a4,s4,80003318 <iget+0x34>
      ip->ref++;
    80003336:	2785                	addiw	a5,a5,1
    80003338:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000333a:	0001d517          	auipc	a0,0x1d
    8000333e:	e2e50513          	addi	a0,a0,-466 # 80020168 <itable>
    80003342:	94bfd0ef          	jal	80000c8c <release>
      return ip;
    80003346:	8926                	mv	s2,s1
    80003348:	a02d                	j	80003372 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000334a:	fbe9                	bnez	a5,8000331c <iget+0x38>
      empty = ip;
    8000334c:	8926                	mv	s2,s1
    8000334e:	b7f9                	j	8000331c <iget+0x38>
  if(empty == 0)
    80003350:	02090a63          	beqz	s2,80003384 <iget+0xa0>
  ip->dev = dev;
    80003354:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003358:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000335c:	4785                	li	a5,1
    8000335e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003362:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003366:	0001d517          	auipc	a0,0x1d
    8000336a:	e0250513          	addi	a0,a0,-510 # 80020168 <itable>
    8000336e:	91ffd0ef          	jal	80000c8c <release>
}
    80003372:	854a                	mv	a0,s2
    80003374:	70a2                	ld	ra,40(sp)
    80003376:	7402                	ld	s0,32(sp)
    80003378:	64e2                	ld	s1,24(sp)
    8000337a:	6942                	ld	s2,16(sp)
    8000337c:	69a2                	ld	s3,8(sp)
    8000337e:	6a02                	ld	s4,0(sp)
    80003380:	6145                	addi	sp,sp,48
    80003382:	8082                	ret
    panic("iget: no inodes");
    80003384:	00004517          	auipc	a0,0x4
    80003388:	12c50513          	addi	a0,a0,300 # 800074b0 <etext+0x4b0>
    8000338c:	c08fd0ef          	jal	80000794 <panic>

0000000080003390 <fsinit>:
fsinit(int dev) {
    80003390:	7179                	addi	sp,sp,-48
    80003392:	f406                	sd	ra,40(sp)
    80003394:	f022                	sd	s0,32(sp)
    80003396:	ec26                	sd	s1,24(sp)
    80003398:	e84a                	sd	s2,16(sp)
    8000339a:	e44e                	sd	s3,8(sp)
    8000339c:	1800                	addi	s0,sp,48
    8000339e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800033a0:	4585                	li	a1,1
    800033a2:	aebff0ef          	jal	80002e8c <bread>
    800033a6:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800033a8:	0001d997          	auipc	s3,0x1d
    800033ac:	da098993          	addi	s3,s3,-608 # 80020148 <sb>
    800033b0:	02000613          	li	a2,32
    800033b4:	05850593          	addi	a1,a0,88
    800033b8:	854e                	mv	a0,s3
    800033ba:	96bfd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    800033be:	8526                	mv	a0,s1
    800033c0:	bd5ff0ef          	jal	80002f94 <brelse>
  if(sb.magic != FSMAGIC)
    800033c4:	0009a703          	lw	a4,0(s3)
    800033c8:	102037b7          	lui	a5,0x10203
    800033cc:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800033d0:	02f71063          	bne	a4,a5,800033f0 <fsinit+0x60>
  initlog(dev, &sb);
    800033d4:	0001d597          	auipc	a1,0x1d
    800033d8:	d7458593          	addi	a1,a1,-652 # 80020148 <sb>
    800033dc:	854a                	mv	a0,s2
    800033de:	1f9000ef          	jal	80003dd6 <initlog>
}
    800033e2:	70a2                	ld	ra,40(sp)
    800033e4:	7402                	ld	s0,32(sp)
    800033e6:	64e2                	ld	s1,24(sp)
    800033e8:	6942                	ld	s2,16(sp)
    800033ea:	69a2                	ld	s3,8(sp)
    800033ec:	6145                	addi	sp,sp,48
    800033ee:	8082                	ret
    panic("invalid file system");
    800033f0:	00004517          	auipc	a0,0x4
    800033f4:	0d050513          	addi	a0,a0,208 # 800074c0 <etext+0x4c0>
    800033f8:	b9cfd0ef          	jal	80000794 <panic>

00000000800033fc <iinit>:
{
    800033fc:	7179                	addi	sp,sp,-48
    800033fe:	f406                	sd	ra,40(sp)
    80003400:	f022                	sd	s0,32(sp)
    80003402:	ec26                	sd	s1,24(sp)
    80003404:	e84a                	sd	s2,16(sp)
    80003406:	e44e                	sd	s3,8(sp)
    80003408:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000340a:	00004597          	auipc	a1,0x4
    8000340e:	0ce58593          	addi	a1,a1,206 # 800074d8 <etext+0x4d8>
    80003412:	0001d517          	auipc	a0,0x1d
    80003416:	d5650513          	addi	a0,a0,-682 # 80020168 <itable>
    8000341a:	f5afd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000341e:	0001d497          	auipc	s1,0x1d
    80003422:	d7248493          	addi	s1,s1,-654 # 80020190 <itable+0x28>
    80003426:	0001e997          	auipc	s3,0x1e
    8000342a:	7fa98993          	addi	s3,s3,2042 # 80021c20 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000342e:	00004917          	auipc	s2,0x4
    80003432:	0b290913          	addi	s2,s2,178 # 800074e0 <etext+0x4e0>
    80003436:	85ca                	mv	a1,s2
    80003438:	8526                	mv	a0,s1
    8000343a:	475000ef          	jal	800040ae <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000343e:	08848493          	addi	s1,s1,136
    80003442:	ff349ae3          	bne	s1,s3,80003436 <iinit+0x3a>
}
    80003446:	70a2                	ld	ra,40(sp)
    80003448:	7402                	ld	s0,32(sp)
    8000344a:	64e2                	ld	s1,24(sp)
    8000344c:	6942                	ld	s2,16(sp)
    8000344e:	69a2                	ld	s3,8(sp)
    80003450:	6145                	addi	sp,sp,48
    80003452:	8082                	ret

0000000080003454 <ialloc>:
{
    80003454:	7139                	addi	sp,sp,-64
    80003456:	fc06                	sd	ra,56(sp)
    80003458:	f822                	sd	s0,48(sp)
    8000345a:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000345c:	0001d717          	auipc	a4,0x1d
    80003460:	cf872703          	lw	a4,-776(a4) # 80020154 <sb+0xc>
    80003464:	4785                	li	a5,1
    80003466:	06e7f063          	bgeu	a5,a4,800034c6 <ialloc+0x72>
    8000346a:	f426                	sd	s1,40(sp)
    8000346c:	f04a                	sd	s2,32(sp)
    8000346e:	ec4e                	sd	s3,24(sp)
    80003470:	e852                	sd	s4,16(sp)
    80003472:	e456                	sd	s5,8(sp)
    80003474:	e05a                	sd	s6,0(sp)
    80003476:	8aaa                	mv	s5,a0
    80003478:	8b2e                	mv	s6,a1
    8000347a:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000347c:	0001da17          	auipc	s4,0x1d
    80003480:	ccca0a13          	addi	s4,s4,-820 # 80020148 <sb>
    80003484:	00495593          	srli	a1,s2,0x4
    80003488:	018a2783          	lw	a5,24(s4)
    8000348c:	9dbd                	addw	a1,a1,a5
    8000348e:	8556                	mv	a0,s5
    80003490:	9fdff0ef          	jal	80002e8c <bread>
    80003494:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003496:	05850993          	addi	s3,a0,88
    8000349a:	00f97793          	andi	a5,s2,15
    8000349e:	079a                	slli	a5,a5,0x6
    800034a0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800034a2:	00099783          	lh	a5,0(s3)
    800034a6:	cb9d                	beqz	a5,800034dc <ialloc+0x88>
    brelse(bp);
    800034a8:	aedff0ef          	jal	80002f94 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800034ac:	0905                	addi	s2,s2,1
    800034ae:	00ca2703          	lw	a4,12(s4)
    800034b2:	0009079b          	sext.w	a5,s2
    800034b6:	fce7e7e3          	bltu	a5,a4,80003484 <ialloc+0x30>
    800034ba:	74a2                	ld	s1,40(sp)
    800034bc:	7902                	ld	s2,32(sp)
    800034be:	69e2                	ld	s3,24(sp)
    800034c0:	6a42                	ld	s4,16(sp)
    800034c2:	6aa2                	ld	s5,8(sp)
    800034c4:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800034c6:	00004517          	auipc	a0,0x4
    800034ca:	02250513          	addi	a0,a0,34 # 800074e8 <etext+0x4e8>
    800034ce:	ff5fc0ef          	jal	800004c2 <printf>
  return 0;
    800034d2:	4501                	li	a0,0
}
    800034d4:	70e2                	ld	ra,56(sp)
    800034d6:	7442                	ld	s0,48(sp)
    800034d8:	6121                	addi	sp,sp,64
    800034da:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800034dc:	04000613          	li	a2,64
    800034e0:	4581                	li	a1,0
    800034e2:	854e                	mv	a0,s3
    800034e4:	fe4fd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    800034e8:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800034ec:	8526                	mv	a0,s1
    800034ee:	2f1000ef          	jal	80003fde <log_write>
      brelse(bp);
    800034f2:	8526                	mv	a0,s1
    800034f4:	aa1ff0ef          	jal	80002f94 <brelse>
      return iget(dev, inum);
    800034f8:	0009059b          	sext.w	a1,s2
    800034fc:	8556                	mv	a0,s5
    800034fe:	de7ff0ef          	jal	800032e4 <iget>
    80003502:	74a2                	ld	s1,40(sp)
    80003504:	7902                	ld	s2,32(sp)
    80003506:	69e2                	ld	s3,24(sp)
    80003508:	6a42                	ld	s4,16(sp)
    8000350a:	6aa2                	ld	s5,8(sp)
    8000350c:	6b02                	ld	s6,0(sp)
    8000350e:	b7d9                	j	800034d4 <ialloc+0x80>

0000000080003510 <iupdate>:
{
    80003510:	1101                	addi	sp,sp,-32
    80003512:	ec06                	sd	ra,24(sp)
    80003514:	e822                	sd	s0,16(sp)
    80003516:	e426                	sd	s1,8(sp)
    80003518:	e04a                	sd	s2,0(sp)
    8000351a:	1000                	addi	s0,sp,32
    8000351c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000351e:	415c                	lw	a5,4(a0)
    80003520:	0047d79b          	srliw	a5,a5,0x4
    80003524:	0001d597          	auipc	a1,0x1d
    80003528:	c3c5a583          	lw	a1,-964(a1) # 80020160 <sb+0x18>
    8000352c:	9dbd                	addw	a1,a1,a5
    8000352e:	4108                	lw	a0,0(a0)
    80003530:	95dff0ef          	jal	80002e8c <bread>
    80003534:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003536:	05850793          	addi	a5,a0,88
    8000353a:	40d8                	lw	a4,4(s1)
    8000353c:	8b3d                	andi	a4,a4,15
    8000353e:	071a                	slli	a4,a4,0x6
    80003540:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003542:	04449703          	lh	a4,68(s1)
    80003546:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000354a:	04649703          	lh	a4,70(s1)
    8000354e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003552:	04849703          	lh	a4,72(s1)
    80003556:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000355a:	04a49703          	lh	a4,74(s1)
    8000355e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003562:	44f8                	lw	a4,76(s1)
    80003564:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003566:	03400613          	li	a2,52
    8000356a:	05048593          	addi	a1,s1,80
    8000356e:	00c78513          	addi	a0,a5,12
    80003572:	fb2fd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    80003576:	854a                	mv	a0,s2
    80003578:	267000ef          	jal	80003fde <log_write>
  brelse(bp);
    8000357c:	854a                	mv	a0,s2
    8000357e:	a17ff0ef          	jal	80002f94 <brelse>
}
    80003582:	60e2                	ld	ra,24(sp)
    80003584:	6442                	ld	s0,16(sp)
    80003586:	64a2                	ld	s1,8(sp)
    80003588:	6902                	ld	s2,0(sp)
    8000358a:	6105                	addi	sp,sp,32
    8000358c:	8082                	ret

000000008000358e <idup>:
{
    8000358e:	1101                	addi	sp,sp,-32
    80003590:	ec06                	sd	ra,24(sp)
    80003592:	e822                	sd	s0,16(sp)
    80003594:	e426                	sd	s1,8(sp)
    80003596:	1000                	addi	s0,sp,32
    80003598:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000359a:	0001d517          	auipc	a0,0x1d
    8000359e:	bce50513          	addi	a0,a0,-1074 # 80020168 <itable>
    800035a2:	e52fd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    800035a6:	449c                	lw	a5,8(s1)
    800035a8:	2785                	addiw	a5,a5,1
    800035aa:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800035ac:	0001d517          	auipc	a0,0x1d
    800035b0:	bbc50513          	addi	a0,a0,-1092 # 80020168 <itable>
    800035b4:	ed8fd0ef          	jal	80000c8c <release>
}
    800035b8:	8526                	mv	a0,s1
    800035ba:	60e2                	ld	ra,24(sp)
    800035bc:	6442                	ld	s0,16(sp)
    800035be:	64a2                	ld	s1,8(sp)
    800035c0:	6105                	addi	sp,sp,32
    800035c2:	8082                	ret

00000000800035c4 <ilock>:
{
    800035c4:	1101                	addi	sp,sp,-32
    800035c6:	ec06                	sd	ra,24(sp)
    800035c8:	e822                	sd	s0,16(sp)
    800035ca:	e426                	sd	s1,8(sp)
    800035cc:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800035ce:	cd19                	beqz	a0,800035ec <ilock+0x28>
    800035d0:	84aa                	mv	s1,a0
    800035d2:	451c                	lw	a5,8(a0)
    800035d4:	00f05c63          	blez	a5,800035ec <ilock+0x28>
  acquiresleep(&ip->lock);
    800035d8:	0541                	addi	a0,a0,16
    800035da:	30b000ef          	jal	800040e4 <acquiresleep>
  if(ip->valid == 0){
    800035de:	40bc                	lw	a5,64(s1)
    800035e0:	cf89                	beqz	a5,800035fa <ilock+0x36>
}
    800035e2:	60e2                	ld	ra,24(sp)
    800035e4:	6442                	ld	s0,16(sp)
    800035e6:	64a2                	ld	s1,8(sp)
    800035e8:	6105                	addi	sp,sp,32
    800035ea:	8082                	ret
    800035ec:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800035ee:	00004517          	auipc	a0,0x4
    800035f2:	f1250513          	addi	a0,a0,-238 # 80007500 <etext+0x500>
    800035f6:	99efd0ef          	jal	80000794 <panic>
    800035fa:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035fc:	40dc                	lw	a5,4(s1)
    800035fe:	0047d79b          	srliw	a5,a5,0x4
    80003602:	0001d597          	auipc	a1,0x1d
    80003606:	b5e5a583          	lw	a1,-1186(a1) # 80020160 <sb+0x18>
    8000360a:	9dbd                	addw	a1,a1,a5
    8000360c:	4088                	lw	a0,0(s1)
    8000360e:	87fff0ef          	jal	80002e8c <bread>
    80003612:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003614:	05850593          	addi	a1,a0,88
    80003618:	40dc                	lw	a5,4(s1)
    8000361a:	8bbd                	andi	a5,a5,15
    8000361c:	079a                	slli	a5,a5,0x6
    8000361e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003620:	00059783          	lh	a5,0(a1)
    80003624:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003628:	00259783          	lh	a5,2(a1)
    8000362c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003630:	00459783          	lh	a5,4(a1)
    80003634:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003638:	00659783          	lh	a5,6(a1)
    8000363c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003640:	459c                	lw	a5,8(a1)
    80003642:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003644:	03400613          	li	a2,52
    80003648:	05b1                	addi	a1,a1,12
    8000364a:	05048513          	addi	a0,s1,80
    8000364e:	ed6fd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    80003652:	854a                	mv	a0,s2
    80003654:	941ff0ef          	jal	80002f94 <brelse>
    ip->valid = 1;
    80003658:	4785                	li	a5,1
    8000365a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000365c:	04449783          	lh	a5,68(s1)
    80003660:	c399                	beqz	a5,80003666 <ilock+0xa2>
    80003662:	6902                	ld	s2,0(sp)
    80003664:	bfbd                	j	800035e2 <ilock+0x1e>
      panic("ilock: no type");
    80003666:	00004517          	auipc	a0,0x4
    8000366a:	ea250513          	addi	a0,a0,-350 # 80007508 <etext+0x508>
    8000366e:	926fd0ef          	jal	80000794 <panic>

0000000080003672 <iunlock>:
{
    80003672:	1101                	addi	sp,sp,-32
    80003674:	ec06                	sd	ra,24(sp)
    80003676:	e822                	sd	s0,16(sp)
    80003678:	e426                	sd	s1,8(sp)
    8000367a:	e04a                	sd	s2,0(sp)
    8000367c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000367e:	c505                	beqz	a0,800036a6 <iunlock+0x34>
    80003680:	84aa                	mv	s1,a0
    80003682:	01050913          	addi	s2,a0,16
    80003686:	854a                	mv	a0,s2
    80003688:	2db000ef          	jal	80004162 <holdingsleep>
    8000368c:	cd09                	beqz	a0,800036a6 <iunlock+0x34>
    8000368e:	449c                	lw	a5,8(s1)
    80003690:	00f05b63          	blez	a5,800036a6 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003694:	854a                	mv	a0,s2
    80003696:	295000ef          	jal	8000412a <releasesleep>
}
    8000369a:	60e2                	ld	ra,24(sp)
    8000369c:	6442                	ld	s0,16(sp)
    8000369e:	64a2                	ld	s1,8(sp)
    800036a0:	6902                	ld	s2,0(sp)
    800036a2:	6105                	addi	sp,sp,32
    800036a4:	8082                	ret
    panic("iunlock");
    800036a6:	00004517          	auipc	a0,0x4
    800036aa:	e7250513          	addi	a0,a0,-398 # 80007518 <etext+0x518>
    800036ae:	8e6fd0ef          	jal	80000794 <panic>

00000000800036b2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800036b2:	7179                	addi	sp,sp,-48
    800036b4:	f406                	sd	ra,40(sp)
    800036b6:	f022                	sd	s0,32(sp)
    800036b8:	ec26                	sd	s1,24(sp)
    800036ba:	e84a                	sd	s2,16(sp)
    800036bc:	e44e                	sd	s3,8(sp)
    800036be:	1800                	addi	s0,sp,48
    800036c0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800036c2:	05050493          	addi	s1,a0,80
    800036c6:	08050913          	addi	s2,a0,128
    800036ca:	a021                	j	800036d2 <itrunc+0x20>
    800036cc:	0491                	addi	s1,s1,4
    800036ce:	01248b63          	beq	s1,s2,800036e4 <itrunc+0x32>
    if(ip->addrs[i]){
    800036d2:	408c                	lw	a1,0(s1)
    800036d4:	dde5                	beqz	a1,800036cc <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800036d6:	0009a503          	lw	a0,0(s3)
    800036da:	9abff0ef          	jal	80003084 <bfree>
      ip->addrs[i] = 0;
    800036de:	0004a023          	sw	zero,0(s1)
    800036e2:	b7ed                	j	800036cc <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800036e4:	0809a583          	lw	a1,128(s3)
    800036e8:	ed89                	bnez	a1,80003702 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800036ea:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800036ee:	854e                	mv	a0,s3
    800036f0:	e21ff0ef          	jal	80003510 <iupdate>
}
    800036f4:	70a2                	ld	ra,40(sp)
    800036f6:	7402                	ld	s0,32(sp)
    800036f8:	64e2                	ld	s1,24(sp)
    800036fa:	6942                	ld	s2,16(sp)
    800036fc:	69a2                	ld	s3,8(sp)
    800036fe:	6145                	addi	sp,sp,48
    80003700:	8082                	ret
    80003702:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003704:	0009a503          	lw	a0,0(s3)
    80003708:	f84ff0ef          	jal	80002e8c <bread>
    8000370c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000370e:	05850493          	addi	s1,a0,88
    80003712:	45850913          	addi	s2,a0,1112
    80003716:	a021                	j	8000371e <itrunc+0x6c>
    80003718:	0491                	addi	s1,s1,4
    8000371a:	01248963          	beq	s1,s2,8000372c <itrunc+0x7a>
      if(a[j])
    8000371e:	408c                	lw	a1,0(s1)
    80003720:	dde5                	beqz	a1,80003718 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003722:	0009a503          	lw	a0,0(s3)
    80003726:	95fff0ef          	jal	80003084 <bfree>
    8000372a:	b7fd                	j	80003718 <itrunc+0x66>
    brelse(bp);
    8000372c:	8552                	mv	a0,s4
    8000372e:	867ff0ef          	jal	80002f94 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003732:	0809a583          	lw	a1,128(s3)
    80003736:	0009a503          	lw	a0,0(s3)
    8000373a:	94bff0ef          	jal	80003084 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000373e:	0809a023          	sw	zero,128(s3)
    80003742:	6a02                	ld	s4,0(sp)
    80003744:	b75d                	j	800036ea <itrunc+0x38>

0000000080003746 <iput>:
{
    80003746:	1101                	addi	sp,sp,-32
    80003748:	ec06                	sd	ra,24(sp)
    8000374a:	e822                	sd	s0,16(sp)
    8000374c:	e426                	sd	s1,8(sp)
    8000374e:	1000                	addi	s0,sp,32
    80003750:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003752:	0001d517          	auipc	a0,0x1d
    80003756:	a1650513          	addi	a0,a0,-1514 # 80020168 <itable>
    8000375a:	c9afd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000375e:	4498                	lw	a4,8(s1)
    80003760:	4785                	li	a5,1
    80003762:	02f70063          	beq	a4,a5,80003782 <iput+0x3c>
  ip->ref--;
    80003766:	449c                	lw	a5,8(s1)
    80003768:	37fd                	addiw	a5,a5,-1
    8000376a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000376c:	0001d517          	auipc	a0,0x1d
    80003770:	9fc50513          	addi	a0,a0,-1540 # 80020168 <itable>
    80003774:	d18fd0ef          	jal	80000c8c <release>
}
    80003778:	60e2                	ld	ra,24(sp)
    8000377a:	6442                	ld	s0,16(sp)
    8000377c:	64a2                	ld	s1,8(sp)
    8000377e:	6105                	addi	sp,sp,32
    80003780:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003782:	40bc                	lw	a5,64(s1)
    80003784:	d3ed                	beqz	a5,80003766 <iput+0x20>
    80003786:	04a49783          	lh	a5,74(s1)
    8000378a:	fff1                	bnez	a5,80003766 <iput+0x20>
    8000378c:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000378e:	01048913          	addi	s2,s1,16
    80003792:	854a                	mv	a0,s2
    80003794:	151000ef          	jal	800040e4 <acquiresleep>
    release(&itable.lock);
    80003798:	0001d517          	auipc	a0,0x1d
    8000379c:	9d050513          	addi	a0,a0,-1584 # 80020168 <itable>
    800037a0:	cecfd0ef          	jal	80000c8c <release>
    itrunc(ip);
    800037a4:	8526                	mv	a0,s1
    800037a6:	f0dff0ef          	jal	800036b2 <itrunc>
    ip->type = 0;
    800037aa:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800037ae:	8526                	mv	a0,s1
    800037b0:	d61ff0ef          	jal	80003510 <iupdate>
    ip->valid = 0;
    800037b4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800037b8:	854a                	mv	a0,s2
    800037ba:	171000ef          	jal	8000412a <releasesleep>
    acquire(&itable.lock);
    800037be:	0001d517          	auipc	a0,0x1d
    800037c2:	9aa50513          	addi	a0,a0,-1622 # 80020168 <itable>
    800037c6:	c2efd0ef          	jal	80000bf4 <acquire>
    800037ca:	6902                	ld	s2,0(sp)
    800037cc:	bf69                	j	80003766 <iput+0x20>

00000000800037ce <iunlockput>:
{
    800037ce:	1101                	addi	sp,sp,-32
    800037d0:	ec06                	sd	ra,24(sp)
    800037d2:	e822                	sd	s0,16(sp)
    800037d4:	e426                	sd	s1,8(sp)
    800037d6:	1000                	addi	s0,sp,32
    800037d8:	84aa                	mv	s1,a0
  iunlock(ip);
    800037da:	e99ff0ef          	jal	80003672 <iunlock>
  iput(ip);
    800037de:	8526                	mv	a0,s1
    800037e0:	f67ff0ef          	jal	80003746 <iput>
}
    800037e4:	60e2                	ld	ra,24(sp)
    800037e6:	6442                	ld	s0,16(sp)
    800037e8:	64a2                	ld	s1,8(sp)
    800037ea:	6105                	addi	sp,sp,32
    800037ec:	8082                	ret

00000000800037ee <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800037ee:	1141                	addi	sp,sp,-16
    800037f0:	e422                	sd	s0,8(sp)
    800037f2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800037f4:	411c                	lw	a5,0(a0)
    800037f6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800037f8:	415c                	lw	a5,4(a0)
    800037fa:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800037fc:	04451783          	lh	a5,68(a0)
    80003800:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003804:	04a51783          	lh	a5,74(a0)
    80003808:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000380c:	04c56783          	lwu	a5,76(a0)
    80003810:	e99c                	sd	a5,16(a1)
}
    80003812:	6422                	ld	s0,8(sp)
    80003814:	0141                	addi	sp,sp,16
    80003816:	8082                	ret

0000000080003818 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003818:	457c                	lw	a5,76(a0)
    8000381a:	0ed7eb63          	bltu	a5,a3,80003910 <readi+0xf8>
{
    8000381e:	7159                	addi	sp,sp,-112
    80003820:	f486                	sd	ra,104(sp)
    80003822:	f0a2                	sd	s0,96(sp)
    80003824:	eca6                	sd	s1,88(sp)
    80003826:	e0d2                	sd	s4,64(sp)
    80003828:	fc56                	sd	s5,56(sp)
    8000382a:	f85a                	sd	s6,48(sp)
    8000382c:	f45e                	sd	s7,40(sp)
    8000382e:	1880                	addi	s0,sp,112
    80003830:	8b2a                	mv	s6,a0
    80003832:	8bae                	mv	s7,a1
    80003834:	8a32                	mv	s4,a2
    80003836:	84b6                	mv	s1,a3
    80003838:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000383a:	9f35                	addw	a4,a4,a3
    return 0;
    8000383c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000383e:	0cd76063          	bltu	a4,a3,800038fe <readi+0xe6>
    80003842:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003844:	00e7f463          	bgeu	a5,a4,8000384c <readi+0x34>
    n = ip->size - off;
    80003848:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000384c:	080a8f63          	beqz	s5,800038ea <readi+0xd2>
    80003850:	e8ca                	sd	s2,80(sp)
    80003852:	f062                	sd	s8,32(sp)
    80003854:	ec66                	sd	s9,24(sp)
    80003856:	e86a                	sd	s10,16(sp)
    80003858:	e46e                	sd	s11,8(sp)
    8000385a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000385c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003860:	5c7d                	li	s8,-1
    80003862:	a80d                	j	80003894 <readi+0x7c>
    80003864:	020d1d93          	slli	s11,s10,0x20
    80003868:	020ddd93          	srli	s11,s11,0x20
    8000386c:	05890613          	addi	a2,s2,88
    80003870:	86ee                	mv	a3,s11
    80003872:	963a                	add	a2,a2,a4
    80003874:	85d2                	mv	a1,s4
    80003876:	855e                	mv	a0,s7
    80003878:	987fe0ef          	jal	800021fe <either_copyout>
    8000387c:	05850763          	beq	a0,s8,800038ca <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003880:	854a                	mv	a0,s2
    80003882:	f12ff0ef          	jal	80002f94 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003886:	013d09bb          	addw	s3,s10,s3
    8000388a:	009d04bb          	addw	s1,s10,s1
    8000388e:	9a6e                	add	s4,s4,s11
    80003890:	0559f763          	bgeu	s3,s5,800038de <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003894:	00a4d59b          	srliw	a1,s1,0xa
    80003898:	855a                	mv	a0,s6
    8000389a:	977ff0ef          	jal	80003210 <bmap>
    8000389e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800038a2:	c5b1                	beqz	a1,800038ee <readi+0xd6>
    bp = bread(ip->dev, addr);
    800038a4:	000b2503          	lw	a0,0(s6)
    800038a8:	de4ff0ef          	jal	80002e8c <bread>
    800038ac:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800038ae:	3ff4f713          	andi	a4,s1,1023
    800038b2:	40ec87bb          	subw	a5,s9,a4
    800038b6:	413a86bb          	subw	a3,s5,s3
    800038ba:	8d3e                	mv	s10,a5
    800038bc:	2781                	sext.w	a5,a5
    800038be:	0006861b          	sext.w	a2,a3
    800038c2:	faf671e3          	bgeu	a2,a5,80003864 <readi+0x4c>
    800038c6:	8d36                	mv	s10,a3
    800038c8:	bf71                	j	80003864 <readi+0x4c>
      brelse(bp);
    800038ca:	854a                	mv	a0,s2
    800038cc:	ec8ff0ef          	jal	80002f94 <brelse>
      tot = -1;
    800038d0:	59fd                	li	s3,-1
      break;
    800038d2:	6946                	ld	s2,80(sp)
    800038d4:	7c02                	ld	s8,32(sp)
    800038d6:	6ce2                	ld	s9,24(sp)
    800038d8:	6d42                	ld	s10,16(sp)
    800038da:	6da2                	ld	s11,8(sp)
    800038dc:	a831                	j	800038f8 <readi+0xe0>
    800038de:	6946                	ld	s2,80(sp)
    800038e0:	7c02                	ld	s8,32(sp)
    800038e2:	6ce2                	ld	s9,24(sp)
    800038e4:	6d42                	ld	s10,16(sp)
    800038e6:	6da2                	ld	s11,8(sp)
    800038e8:	a801                	j	800038f8 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038ea:	89d6                	mv	s3,s5
    800038ec:	a031                	j	800038f8 <readi+0xe0>
    800038ee:	6946                	ld	s2,80(sp)
    800038f0:	7c02                	ld	s8,32(sp)
    800038f2:	6ce2                	ld	s9,24(sp)
    800038f4:	6d42                	ld	s10,16(sp)
    800038f6:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800038f8:	0009851b          	sext.w	a0,s3
    800038fc:	69a6                	ld	s3,72(sp)
}
    800038fe:	70a6                	ld	ra,104(sp)
    80003900:	7406                	ld	s0,96(sp)
    80003902:	64e6                	ld	s1,88(sp)
    80003904:	6a06                	ld	s4,64(sp)
    80003906:	7ae2                	ld	s5,56(sp)
    80003908:	7b42                	ld	s6,48(sp)
    8000390a:	7ba2                	ld	s7,40(sp)
    8000390c:	6165                	addi	sp,sp,112
    8000390e:	8082                	ret
    return 0;
    80003910:	4501                	li	a0,0
}
    80003912:	8082                	ret

0000000080003914 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003914:	457c                	lw	a5,76(a0)
    80003916:	10d7e063          	bltu	a5,a3,80003a16 <writei+0x102>
{
    8000391a:	7159                	addi	sp,sp,-112
    8000391c:	f486                	sd	ra,104(sp)
    8000391e:	f0a2                	sd	s0,96(sp)
    80003920:	e8ca                	sd	s2,80(sp)
    80003922:	e0d2                	sd	s4,64(sp)
    80003924:	fc56                	sd	s5,56(sp)
    80003926:	f85a                	sd	s6,48(sp)
    80003928:	f45e                	sd	s7,40(sp)
    8000392a:	1880                	addi	s0,sp,112
    8000392c:	8aaa                	mv	s5,a0
    8000392e:	8bae                	mv	s7,a1
    80003930:	8a32                	mv	s4,a2
    80003932:	8936                	mv	s2,a3
    80003934:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003936:	00e687bb          	addw	a5,a3,a4
    8000393a:	0ed7e063          	bltu	a5,a3,80003a1a <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000393e:	00043737          	lui	a4,0x43
    80003942:	0cf76e63          	bltu	a4,a5,80003a1e <writei+0x10a>
    80003946:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003948:	0a0b0f63          	beqz	s6,80003a06 <writei+0xf2>
    8000394c:	eca6                	sd	s1,88(sp)
    8000394e:	f062                	sd	s8,32(sp)
    80003950:	ec66                	sd	s9,24(sp)
    80003952:	e86a                	sd	s10,16(sp)
    80003954:	e46e                	sd	s11,8(sp)
    80003956:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003958:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000395c:	5c7d                	li	s8,-1
    8000395e:	a825                	j	80003996 <writei+0x82>
    80003960:	020d1d93          	slli	s11,s10,0x20
    80003964:	020ddd93          	srli	s11,s11,0x20
    80003968:	05848513          	addi	a0,s1,88
    8000396c:	86ee                	mv	a3,s11
    8000396e:	8652                	mv	a2,s4
    80003970:	85de                	mv	a1,s7
    80003972:	953a                	add	a0,a0,a4
    80003974:	8d5fe0ef          	jal	80002248 <either_copyin>
    80003978:	05850a63          	beq	a0,s8,800039cc <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000397c:	8526                	mv	a0,s1
    8000397e:	660000ef          	jal	80003fde <log_write>
    brelse(bp);
    80003982:	8526                	mv	a0,s1
    80003984:	e10ff0ef          	jal	80002f94 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003988:	013d09bb          	addw	s3,s10,s3
    8000398c:	012d093b          	addw	s2,s10,s2
    80003990:	9a6e                	add	s4,s4,s11
    80003992:	0569f063          	bgeu	s3,s6,800039d2 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003996:	00a9559b          	srliw	a1,s2,0xa
    8000399a:	8556                	mv	a0,s5
    8000399c:	875ff0ef          	jal	80003210 <bmap>
    800039a0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800039a4:	c59d                	beqz	a1,800039d2 <writei+0xbe>
    bp = bread(ip->dev, addr);
    800039a6:	000aa503          	lw	a0,0(s5)
    800039aa:	ce2ff0ef          	jal	80002e8c <bread>
    800039ae:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039b0:	3ff97713          	andi	a4,s2,1023
    800039b4:	40ec87bb          	subw	a5,s9,a4
    800039b8:	413b06bb          	subw	a3,s6,s3
    800039bc:	8d3e                	mv	s10,a5
    800039be:	2781                	sext.w	a5,a5
    800039c0:	0006861b          	sext.w	a2,a3
    800039c4:	f8f67ee3          	bgeu	a2,a5,80003960 <writei+0x4c>
    800039c8:	8d36                	mv	s10,a3
    800039ca:	bf59                	j	80003960 <writei+0x4c>
      brelse(bp);
    800039cc:	8526                	mv	a0,s1
    800039ce:	dc6ff0ef          	jal	80002f94 <brelse>
  }

  if(off > ip->size)
    800039d2:	04caa783          	lw	a5,76(s5)
    800039d6:	0327fa63          	bgeu	a5,s2,80003a0a <writei+0xf6>
    ip->size = off;
    800039da:	052aa623          	sw	s2,76(s5)
    800039de:	64e6                	ld	s1,88(sp)
    800039e0:	7c02                	ld	s8,32(sp)
    800039e2:	6ce2                	ld	s9,24(sp)
    800039e4:	6d42                	ld	s10,16(sp)
    800039e6:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800039e8:	8556                	mv	a0,s5
    800039ea:	b27ff0ef          	jal	80003510 <iupdate>

  return tot;
    800039ee:	0009851b          	sext.w	a0,s3
    800039f2:	69a6                	ld	s3,72(sp)
}
    800039f4:	70a6                	ld	ra,104(sp)
    800039f6:	7406                	ld	s0,96(sp)
    800039f8:	6946                	ld	s2,80(sp)
    800039fa:	6a06                	ld	s4,64(sp)
    800039fc:	7ae2                	ld	s5,56(sp)
    800039fe:	7b42                	ld	s6,48(sp)
    80003a00:	7ba2                	ld	s7,40(sp)
    80003a02:	6165                	addi	sp,sp,112
    80003a04:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a06:	89da                	mv	s3,s6
    80003a08:	b7c5                	j	800039e8 <writei+0xd4>
    80003a0a:	64e6                	ld	s1,88(sp)
    80003a0c:	7c02                	ld	s8,32(sp)
    80003a0e:	6ce2                	ld	s9,24(sp)
    80003a10:	6d42                	ld	s10,16(sp)
    80003a12:	6da2                	ld	s11,8(sp)
    80003a14:	bfd1                	j	800039e8 <writei+0xd4>
    return -1;
    80003a16:	557d                	li	a0,-1
}
    80003a18:	8082                	ret
    return -1;
    80003a1a:	557d                	li	a0,-1
    80003a1c:	bfe1                	j	800039f4 <writei+0xe0>
    return -1;
    80003a1e:	557d                	li	a0,-1
    80003a20:	bfd1                	j	800039f4 <writei+0xe0>

0000000080003a22 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003a22:	1141                	addi	sp,sp,-16
    80003a24:	e406                	sd	ra,8(sp)
    80003a26:	e022                	sd	s0,0(sp)
    80003a28:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003a2a:	4639                	li	a2,14
    80003a2c:	b68fd0ef          	jal	80000d94 <strncmp>
}
    80003a30:	60a2                	ld	ra,8(sp)
    80003a32:	6402                	ld	s0,0(sp)
    80003a34:	0141                	addi	sp,sp,16
    80003a36:	8082                	ret

0000000080003a38 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003a38:	7139                	addi	sp,sp,-64
    80003a3a:	fc06                	sd	ra,56(sp)
    80003a3c:	f822                	sd	s0,48(sp)
    80003a3e:	f426                	sd	s1,40(sp)
    80003a40:	f04a                	sd	s2,32(sp)
    80003a42:	ec4e                	sd	s3,24(sp)
    80003a44:	e852                	sd	s4,16(sp)
    80003a46:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003a48:	04451703          	lh	a4,68(a0)
    80003a4c:	4785                	li	a5,1
    80003a4e:	00f71a63          	bne	a4,a5,80003a62 <dirlookup+0x2a>
    80003a52:	892a                	mv	s2,a0
    80003a54:	89ae                	mv	s3,a1
    80003a56:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a58:	457c                	lw	a5,76(a0)
    80003a5a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003a5c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a5e:	e39d                	bnez	a5,80003a84 <dirlookup+0x4c>
    80003a60:	a095                	j	80003ac4 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003a62:	00004517          	auipc	a0,0x4
    80003a66:	abe50513          	addi	a0,a0,-1346 # 80007520 <etext+0x520>
    80003a6a:	d2bfc0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    80003a6e:	00004517          	auipc	a0,0x4
    80003a72:	aca50513          	addi	a0,a0,-1334 # 80007538 <etext+0x538>
    80003a76:	d1ffc0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a7a:	24c1                	addiw	s1,s1,16
    80003a7c:	04c92783          	lw	a5,76(s2)
    80003a80:	04f4f163          	bgeu	s1,a5,80003ac2 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a84:	4741                	li	a4,16
    80003a86:	86a6                	mv	a3,s1
    80003a88:	fc040613          	addi	a2,s0,-64
    80003a8c:	4581                	li	a1,0
    80003a8e:	854a                	mv	a0,s2
    80003a90:	d89ff0ef          	jal	80003818 <readi>
    80003a94:	47c1                	li	a5,16
    80003a96:	fcf51ce3          	bne	a0,a5,80003a6e <dirlookup+0x36>
    if(de.inum == 0)
    80003a9a:	fc045783          	lhu	a5,-64(s0)
    80003a9e:	dff1                	beqz	a5,80003a7a <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003aa0:	fc240593          	addi	a1,s0,-62
    80003aa4:	854e                	mv	a0,s3
    80003aa6:	f7dff0ef          	jal	80003a22 <namecmp>
    80003aaa:	f961                	bnez	a0,80003a7a <dirlookup+0x42>
      if(poff)
    80003aac:	000a0463          	beqz	s4,80003ab4 <dirlookup+0x7c>
        *poff = off;
    80003ab0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003ab4:	fc045583          	lhu	a1,-64(s0)
    80003ab8:	00092503          	lw	a0,0(s2)
    80003abc:	829ff0ef          	jal	800032e4 <iget>
    80003ac0:	a011                	j	80003ac4 <dirlookup+0x8c>
  return 0;
    80003ac2:	4501                	li	a0,0
}
    80003ac4:	70e2                	ld	ra,56(sp)
    80003ac6:	7442                	ld	s0,48(sp)
    80003ac8:	74a2                	ld	s1,40(sp)
    80003aca:	7902                	ld	s2,32(sp)
    80003acc:	69e2                	ld	s3,24(sp)
    80003ace:	6a42                	ld	s4,16(sp)
    80003ad0:	6121                	addi	sp,sp,64
    80003ad2:	8082                	ret

0000000080003ad4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003ad4:	711d                	addi	sp,sp,-96
    80003ad6:	ec86                	sd	ra,88(sp)
    80003ad8:	e8a2                	sd	s0,80(sp)
    80003ada:	e4a6                	sd	s1,72(sp)
    80003adc:	e0ca                	sd	s2,64(sp)
    80003ade:	fc4e                	sd	s3,56(sp)
    80003ae0:	f852                	sd	s4,48(sp)
    80003ae2:	f456                	sd	s5,40(sp)
    80003ae4:	f05a                	sd	s6,32(sp)
    80003ae6:	ec5e                	sd	s7,24(sp)
    80003ae8:	e862                	sd	s8,16(sp)
    80003aea:	e466                	sd	s9,8(sp)
    80003aec:	1080                	addi	s0,sp,96
    80003aee:	84aa                	mv	s1,a0
    80003af0:	8b2e                	mv	s6,a1
    80003af2:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003af4:	00054703          	lbu	a4,0(a0)
    80003af8:	02f00793          	li	a5,47
    80003afc:	00f70e63          	beq	a4,a5,80003b18 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003b00:	dd5fd0ef          	jal	800018d4 <myproc>
    80003b04:	15053503          	ld	a0,336(a0)
    80003b08:	a87ff0ef          	jal	8000358e <idup>
    80003b0c:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003b0e:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003b12:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003b14:	4b85                	li	s7,1
    80003b16:	a871                	j	80003bb2 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003b18:	4585                	li	a1,1
    80003b1a:	4505                	li	a0,1
    80003b1c:	fc8ff0ef          	jal	800032e4 <iget>
    80003b20:	8a2a                	mv	s4,a0
    80003b22:	b7f5                	j	80003b0e <namex+0x3a>
      iunlockput(ip);
    80003b24:	8552                	mv	a0,s4
    80003b26:	ca9ff0ef          	jal	800037ce <iunlockput>
      return 0;
    80003b2a:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003b2c:	8552                	mv	a0,s4
    80003b2e:	60e6                	ld	ra,88(sp)
    80003b30:	6446                	ld	s0,80(sp)
    80003b32:	64a6                	ld	s1,72(sp)
    80003b34:	6906                	ld	s2,64(sp)
    80003b36:	79e2                	ld	s3,56(sp)
    80003b38:	7a42                	ld	s4,48(sp)
    80003b3a:	7aa2                	ld	s5,40(sp)
    80003b3c:	7b02                	ld	s6,32(sp)
    80003b3e:	6be2                	ld	s7,24(sp)
    80003b40:	6c42                	ld	s8,16(sp)
    80003b42:	6ca2                	ld	s9,8(sp)
    80003b44:	6125                	addi	sp,sp,96
    80003b46:	8082                	ret
      iunlock(ip);
    80003b48:	8552                	mv	a0,s4
    80003b4a:	b29ff0ef          	jal	80003672 <iunlock>
      return ip;
    80003b4e:	bff9                	j	80003b2c <namex+0x58>
      iunlockput(ip);
    80003b50:	8552                	mv	a0,s4
    80003b52:	c7dff0ef          	jal	800037ce <iunlockput>
      return 0;
    80003b56:	8a4e                	mv	s4,s3
    80003b58:	bfd1                	j	80003b2c <namex+0x58>
  len = path - s;
    80003b5a:	40998633          	sub	a2,s3,s1
    80003b5e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003b62:	099c5063          	bge	s8,s9,80003be2 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003b66:	4639                	li	a2,14
    80003b68:	85a6                	mv	a1,s1
    80003b6a:	8556                	mv	a0,s5
    80003b6c:	9b8fd0ef          	jal	80000d24 <memmove>
    80003b70:	84ce                	mv	s1,s3
  while(*path == '/')
    80003b72:	0004c783          	lbu	a5,0(s1)
    80003b76:	01279763          	bne	a5,s2,80003b84 <namex+0xb0>
    path++;
    80003b7a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003b7c:	0004c783          	lbu	a5,0(s1)
    80003b80:	ff278de3          	beq	a5,s2,80003b7a <namex+0xa6>
    ilock(ip);
    80003b84:	8552                	mv	a0,s4
    80003b86:	a3fff0ef          	jal	800035c4 <ilock>
    if(ip->type != T_DIR){
    80003b8a:	044a1783          	lh	a5,68(s4)
    80003b8e:	f9779be3          	bne	a5,s7,80003b24 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003b92:	000b0563          	beqz	s6,80003b9c <namex+0xc8>
    80003b96:	0004c783          	lbu	a5,0(s1)
    80003b9a:	d7dd                	beqz	a5,80003b48 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003b9c:	4601                	li	a2,0
    80003b9e:	85d6                	mv	a1,s5
    80003ba0:	8552                	mv	a0,s4
    80003ba2:	e97ff0ef          	jal	80003a38 <dirlookup>
    80003ba6:	89aa                	mv	s3,a0
    80003ba8:	d545                	beqz	a0,80003b50 <namex+0x7c>
    iunlockput(ip);
    80003baa:	8552                	mv	a0,s4
    80003bac:	c23ff0ef          	jal	800037ce <iunlockput>
    ip = next;
    80003bb0:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003bb2:	0004c783          	lbu	a5,0(s1)
    80003bb6:	01279763          	bne	a5,s2,80003bc4 <namex+0xf0>
    path++;
    80003bba:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003bbc:	0004c783          	lbu	a5,0(s1)
    80003bc0:	ff278de3          	beq	a5,s2,80003bba <namex+0xe6>
  if(*path == 0)
    80003bc4:	cb8d                	beqz	a5,80003bf6 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003bc6:	0004c783          	lbu	a5,0(s1)
    80003bca:	89a6                	mv	s3,s1
  len = path - s;
    80003bcc:	4c81                	li	s9,0
    80003bce:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003bd0:	01278963          	beq	a5,s2,80003be2 <namex+0x10e>
    80003bd4:	d3d9                	beqz	a5,80003b5a <namex+0x86>
    path++;
    80003bd6:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003bd8:	0009c783          	lbu	a5,0(s3)
    80003bdc:	ff279ce3          	bne	a5,s2,80003bd4 <namex+0x100>
    80003be0:	bfad                	j	80003b5a <namex+0x86>
    memmove(name, s, len);
    80003be2:	2601                	sext.w	a2,a2
    80003be4:	85a6                	mv	a1,s1
    80003be6:	8556                	mv	a0,s5
    80003be8:	93cfd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    80003bec:	9cd6                	add	s9,s9,s5
    80003bee:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003bf2:	84ce                	mv	s1,s3
    80003bf4:	bfbd                	j	80003b72 <namex+0x9e>
  if(nameiparent){
    80003bf6:	f20b0be3          	beqz	s6,80003b2c <namex+0x58>
    iput(ip);
    80003bfa:	8552                	mv	a0,s4
    80003bfc:	b4bff0ef          	jal	80003746 <iput>
    return 0;
    80003c00:	4a01                	li	s4,0
    80003c02:	b72d                	j	80003b2c <namex+0x58>

0000000080003c04 <dirlink>:
{
    80003c04:	7139                	addi	sp,sp,-64
    80003c06:	fc06                	sd	ra,56(sp)
    80003c08:	f822                	sd	s0,48(sp)
    80003c0a:	f04a                	sd	s2,32(sp)
    80003c0c:	ec4e                	sd	s3,24(sp)
    80003c0e:	e852                	sd	s4,16(sp)
    80003c10:	0080                	addi	s0,sp,64
    80003c12:	892a                	mv	s2,a0
    80003c14:	8a2e                	mv	s4,a1
    80003c16:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003c18:	4601                	li	a2,0
    80003c1a:	e1fff0ef          	jal	80003a38 <dirlookup>
    80003c1e:	e535                	bnez	a0,80003c8a <dirlink+0x86>
    80003c20:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c22:	04c92483          	lw	s1,76(s2)
    80003c26:	c48d                	beqz	s1,80003c50 <dirlink+0x4c>
    80003c28:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c2a:	4741                	li	a4,16
    80003c2c:	86a6                	mv	a3,s1
    80003c2e:	fc040613          	addi	a2,s0,-64
    80003c32:	4581                	li	a1,0
    80003c34:	854a                	mv	a0,s2
    80003c36:	be3ff0ef          	jal	80003818 <readi>
    80003c3a:	47c1                	li	a5,16
    80003c3c:	04f51b63          	bne	a0,a5,80003c92 <dirlink+0x8e>
    if(de.inum == 0)
    80003c40:	fc045783          	lhu	a5,-64(s0)
    80003c44:	c791                	beqz	a5,80003c50 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c46:	24c1                	addiw	s1,s1,16
    80003c48:	04c92783          	lw	a5,76(s2)
    80003c4c:	fcf4efe3          	bltu	s1,a5,80003c2a <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003c50:	4639                	li	a2,14
    80003c52:	85d2                	mv	a1,s4
    80003c54:	fc240513          	addi	a0,s0,-62
    80003c58:	972fd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    80003c5c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c60:	4741                	li	a4,16
    80003c62:	86a6                	mv	a3,s1
    80003c64:	fc040613          	addi	a2,s0,-64
    80003c68:	4581                	li	a1,0
    80003c6a:	854a                	mv	a0,s2
    80003c6c:	ca9ff0ef          	jal	80003914 <writei>
    80003c70:	1541                	addi	a0,a0,-16
    80003c72:	00a03533          	snez	a0,a0
    80003c76:	40a00533          	neg	a0,a0
    80003c7a:	74a2                	ld	s1,40(sp)
}
    80003c7c:	70e2                	ld	ra,56(sp)
    80003c7e:	7442                	ld	s0,48(sp)
    80003c80:	7902                	ld	s2,32(sp)
    80003c82:	69e2                	ld	s3,24(sp)
    80003c84:	6a42                	ld	s4,16(sp)
    80003c86:	6121                	addi	sp,sp,64
    80003c88:	8082                	ret
    iput(ip);
    80003c8a:	abdff0ef          	jal	80003746 <iput>
    return -1;
    80003c8e:	557d                	li	a0,-1
    80003c90:	b7f5                	j	80003c7c <dirlink+0x78>
      panic("dirlink read");
    80003c92:	00004517          	auipc	a0,0x4
    80003c96:	8b650513          	addi	a0,a0,-1866 # 80007548 <etext+0x548>
    80003c9a:	afbfc0ef          	jal	80000794 <panic>

0000000080003c9e <namei>:

struct inode*
namei(char *path)
{
    80003c9e:	1101                	addi	sp,sp,-32
    80003ca0:	ec06                	sd	ra,24(sp)
    80003ca2:	e822                	sd	s0,16(sp)
    80003ca4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ca6:	fe040613          	addi	a2,s0,-32
    80003caa:	4581                	li	a1,0
    80003cac:	e29ff0ef          	jal	80003ad4 <namex>
}
    80003cb0:	60e2                	ld	ra,24(sp)
    80003cb2:	6442                	ld	s0,16(sp)
    80003cb4:	6105                	addi	sp,sp,32
    80003cb6:	8082                	ret

0000000080003cb8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003cb8:	1141                	addi	sp,sp,-16
    80003cba:	e406                	sd	ra,8(sp)
    80003cbc:	e022                	sd	s0,0(sp)
    80003cbe:	0800                	addi	s0,sp,16
    80003cc0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003cc2:	4585                	li	a1,1
    80003cc4:	e11ff0ef          	jal	80003ad4 <namex>
}
    80003cc8:	60a2                	ld	ra,8(sp)
    80003cca:	6402                	ld	s0,0(sp)
    80003ccc:	0141                	addi	sp,sp,16
    80003cce:	8082                	ret

0000000080003cd0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003cd0:	1101                	addi	sp,sp,-32
    80003cd2:	ec06                	sd	ra,24(sp)
    80003cd4:	e822                	sd	s0,16(sp)
    80003cd6:	e426                	sd	s1,8(sp)
    80003cd8:	e04a                	sd	s2,0(sp)
    80003cda:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003cdc:	0001e917          	auipc	s2,0x1e
    80003ce0:	f3490913          	addi	s2,s2,-204 # 80021c10 <log>
    80003ce4:	01892583          	lw	a1,24(s2)
    80003ce8:	02892503          	lw	a0,40(s2)
    80003cec:	9a0ff0ef          	jal	80002e8c <bread>
    80003cf0:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003cf2:	02c92603          	lw	a2,44(s2)
    80003cf6:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003cf8:	00c05f63          	blez	a2,80003d16 <write_head+0x46>
    80003cfc:	0001e717          	auipc	a4,0x1e
    80003d00:	f4470713          	addi	a4,a4,-188 # 80021c40 <log+0x30>
    80003d04:	87aa                	mv	a5,a0
    80003d06:	060a                	slli	a2,a2,0x2
    80003d08:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003d0a:	4314                	lw	a3,0(a4)
    80003d0c:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003d0e:	0711                	addi	a4,a4,4
    80003d10:	0791                	addi	a5,a5,4
    80003d12:	fec79ce3          	bne	a5,a2,80003d0a <write_head+0x3a>
  }
  bwrite(buf);
    80003d16:	8526                	mv	a0,s1
    80003d18:	a4aff0ef          	jal	80002f62 <bwrite>
  brelse(buf);
    80003d1c:	8526                	mv	a0,s1
    80003d1e:	a76ff0ef          	jal	80002f94 <brelse>
}
    80003d22:	60e2                	ld	ra,24(sp)
    80003d24:	6442                	ld	s0,16(sp)
    80003d26:	64a2                	ld	s1,8(sp)
    80003d28:	6902                	ld	s2,0(sp)
    80003d2a:	6105                	addi	sp,sp,32
    80003d2c:	8082                	ret

0000000080003d2e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d2e:	0001e797          	auipc	a5,0x1e
    80003d32:	f0e7a783          	lw	a5,-242(a5) # 80021c3c <log+0x2c>
    80003d36:	08f05f63          	blez	a5,80003dd4 <install_trans+0xa6>
{
    80003d3a:	7139                	addi	sp,sp,-64
    80003d3c:	fc06                	sd	ra,56(sp)
    80003d3e:	f822                	sd	s0,48(sp)
    80003d40:	f426                	sd	s1,40(sp)
    80003d42:	f04a                	sd	s2,32(sp)
    80003d44:	ec4e                	sd	s3,24(sp)
    80003d46:	e852                	sd	s4,16(sp)
    80003d48:	e456                	sd	s5,8(sp)
    80003d4a:	e05a                	sd	s6,0(sp)
    80003d4c:	0080                	addi	s0,sp,64
    80003d4e:	8b2a                	mv	s6,a0
    80003d50:	0001ea97          	auipc	s5,0x1e
    80003d54:	ef0a8a93          	addi	s5,s5,-272 # 80021c40 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d58:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d5a:	0001e997          	auipc	s3,0x1e
    80003d5e:	eb698993          	addi	s3,s3,-330 # 80021c10 <log>
    80003d62:	a829                	j	80003d7c <install_trans+0x4e>
    brelse(lbuf);
    80003d64:	854a                	mv	a0,s2
    80003d66:	a2eff0ef          	jal	80002f94 <brelse>
    brelse(dbuf);
    80003d6a:	8526                	mv	a0,s1
    80003d6c:	a28ff0ef          	jal	80002f94 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d70:	2a05                	addiw	s4,s4,1
    80003d72:	0a91                	addi	s5,s5,4
    80003d74:	02c9a783          	lw	a5,44(s3)
    80003d78:	04fa5463          	bge	s4,a5,80003dc0 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d7c:	0189a583          	lw	a1,24(s3)
    80003d80:	014585bb          	addw	a1,a1,s4
    80003d84:	2585                	addiw	a1,a1,1
    80003d86:	0289a503          	lw	a0,40(s3)
    80003d8a:	902ff0ef          	jal	80002e8c <bread>
    80003d8e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003d90:	000aa583          	lw	a1,0(s5)
    80003d94:	0289a503          	lw	a0,40(s3)
    80003d98:	8f4ff0ef          	jal	80002e8c <bread>
    80003d9c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003d9e:	40000613          	li	a2,1024
    80003da2:	05890593          	addi	a1,s2,88
    80003da6:	05850513          	addi	a0,a0,88
    80003daa:	f7bfc0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003dae:	8526                	mv	a0,s1
    80003db0:	9b2ff0ef          	jal	80002f62 <bwrite>
    if(recovering == 0)
    80003db4:	fa0b18e3          	bnez	s6,80003d64 <install_trans+0x36>
      bunpin(dbuf);
    80003db8:	8526                	mv	a0,s1
    80003dba:	a96ff0ef          	jal	80003050 <bunpin>
    80003dbe:	b75d                	j	80003d64 <install_trans+0x36>
}
    80003dc0:	70e2                	ld	ra,56(sp)
    80003dc2:	7442                	ld	s0,48(sp)
    80003dc4:	74a2                	ld	s1,40(sp)
    80003dc6:	7902                	ld	s2,32(sp)
    80003dc8:	69e2                	ld	s3,24(sp)
    80003dca:	6a42                	ld	s4,16(sp)
    80003dcc:	6aa2                	ld	s5,8(sp)
    80003dce:	6b02                	ld	s6,0(sp)
    80003dd0:	6121                	addi	sp,sp,64
    80003dd2:	8082                	ret
    80003dd4:	8082                	ret

0000000080003dd6 <initlog>:
{
    80003dd6:	7179                	addi	sp,sp,-48
    80003dd8:	f406                	sd	ra,40(sp)
    80003dda:	f022                	sd	s0,32(sp)
    80003ddc:	ec26                	sd	s1,24(sp)
    80003dde:	e84a                	sd	s2,16(sp)
    80003de0:	e44e                	sd	s3,8(sp)
    80003de2:	1800                	addi	s0,sp,48
    80003de4:	892a                	mv	s2,a0
    80003de6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003de8:	0001e497          	auipc	s1,0x1e
    80003dec:	e2848493          	addi	s1,s1,-472 # 80021c10 <log>
    80003df0:	00003597          	auipc	a1,0x3
    80003df4:	76858593          	addi	a1,a1,1896 # 80007558 <etext+0x558>
    80003df8:	8526                	mv	a0,s1
    80003dfa:	d7bfc0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003dfe:	0149a583          	lw	a1,20(s3)
    80003e02:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003e04:	0109a783          	lw	a5,16(s3)
    80003e08:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003e0a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003e0e:	854a                	mv	a0,s2
    80003e10:	87cff0ef          	jal	80002e8c <bread>
  log.lh.n = lh->n;
    80003e14:	4d30                	lw	a2,88(a0)
    80003e16:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003e18:	00c05f63          	blez	a2,80003e36 <initlog+0x60>
    80003e1c:	87aa                	mv	a5,a0
    80003e1e:	0001e717          	auipc	a4,0x1e
    80003e22:	e2270713          	addi	a4,a4,-478 # 80021c40 <log+0x30>
    80003e26:	060a                	slli	a2,a2,0x2
    80003e28:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003e2a:	4ff4                	lw	a3,92(a5)
    80003e2c:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e2e:	0791                	addi	a5,a5,4
    80003e30:	0711                	addi	a4,a4,4
    80003e32:	fec79ce3          	bne	a5,a2,80003e2a <initlog+0x54>
  brelse(buf);
    80003e36:	95eff0ef          	jal	80002f94 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003e3a:	4505                	li	a0,1
    80003e3c:	ef3ff0ef          	jal	80003d2e <install_trans>
  log.lh.n = 0;
    80003e40:	0001e797          	auipc	a5,0x1e
    80003e44:	de07ae23          	sw	zero,-516(a5) # 80021c3c <log+0x2c>
  write_head(); // clear the log
    80003e48:	e89ff0ef          	jal	80003cd0 <write_head>
}
    80003e4c:	70a2                	ld	ra,40(sp)
    80003e4e:	7402                	ld	s0,32(sp)
    80003e50:	64e2                	ld	s1,24(sp)
    80003e52:	6942                	ld	s2,16(sp)
    80003e54:	69a2                	ld	s3,8(sp)
    80003e56:	6145                	addi	sp,sp,48
    80003e58:	8082                	ret

0000000080003e5a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003e5a:	1101                	addi	sp,sp,-32
    80003e5c:	ec06                	sd	ra,24(sp)
    80003e5e:	e822                	sd	s0,16(sp)
    80003e60:	e426                	sd	s1,8(sp)
    80003e62:	e04a                	sd	s2,0(sp)
    80003e64:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e66:	0001e517          	auipc	a0,0x1e
    80003e6a:	daa50513          	addi	a0,a0,-598 # 80021c10 <log>
    80003e6e:	d87fc0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003e72:	0001e497          	auipc	s1,0x1e
    80003e76:	d9e48493          	addi	s1,s1,-610 # 80021c10 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003e7a:	4979                	li	s2,30
    80003e7c:	a029                	j	80003e86 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003e7e:	85a6                	mv	a1,s1
    80003e80:	8526                	mv	a0,s1
    80003e82:	820fe0ef          	jal	80001ea2 <sleep>
    if(log.committing){
    80003e86:	50dc                	lw	a5,36(s1)
    80003e88:	fbfd                	bnez	a5,80003e7e <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003e8a:	5098                	lw	a4,32(s1)
    80003e8c:	2705                	addiw	a4,a4,1
    80003e8e:	0027179b          	slliw	a5,a4,0x2
    80003e92:	9fb9                	addw	a5,a5,a4
    80003e94:	0017979b          	slliw	a5,a5,0x1
    80003e98:	54d4                	lw	a3,44(s1)
    80003e9a:	9fb5                	addw	a5,a5,a3
    80003e9c:	00f95763          	bge	s2,a5,80003eaa <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003ea0:	85a6                	mv	a1,s1
    80003ea2:	8526                	mv	a0,s1
    80003ea4:	ffffd0ef          	jal	80001ea2 <sleep>
    80003ea8:	bff9                	j	80003e86 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003eaa:	0001e517          	auipc	a0,0x1e
    80003eae:	d6650513          	addi	a0,a0,-666 # 80021c10 <log>
    80003eb2:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003eb4:	dd9fc0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003eb8:	60e2                	ld	ra,24(sp)
    80003eba:	6442                	ld	s0,16(sp)
    80003ebc:	64a2                	ld	s1,8(sp)
    80003ebe:	6902                	ld	s2,0(sp)
    80003ec0:	6105                	addi	sp,sp,32
    80003ec2:	8082                	ret

0000000080003ec4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003ec4:	7139                	addi	sp,sp,-64
    80003ec6:	fc06                	sd	ra,56(sp)
    80003ec8:	f822                	sd	s0,48(sp)
    80003eca:	f426                	sd	s1,40(sp)
    80003ecc:	f04a                	sd	s2,32(sp)
    80003ece:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003ed0:	0001e497          	auipc	s1,0x1e
    80003ed4:	d4048493          	addi	s1,s1,-704 # 80021c10 <log>
    80003ed8:	8526                	mv	a0,s1
    80003eda:	d1bfc0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003ede:	509c                	lw	a5,32(s1)
    80003ee0:	37fd                	addiw	a5,a5,-1
    80003ee2:	0007891b          	sext.w	s2,a5
    80003ee6:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003ee8:	50dc                	lw	a5,36(s1)
    80003eea:	ef9d                	bnez	a5,80003f28 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003eec:	04091763          	bnez	s2,80003f3a <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003ef0:	0001e497          	auipc	s1,0x1e
    80003ef4:	d2048493          	addi	s1,s1,-736 # 80021c10 <log>
    80003ef8:	4785                	li	a5,1
    80003efa:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003efc:	8526                	mv	a0,s1
    80003efe:	d8ffc0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003f02:	54dc                	lw	a5,44(s1)
    80003f04:	04f04b63          	bgtz	a5,80003f5a <end_op+0x96>
    acquire(&log.lock);
    80003f08:	0001e497          	auipc	s1,0x1e
    80003f0c:	d0848493          	addi	s1,s1,-760 # 80021c10 <log>
    80003f10:	8526                	mv	a0,s1
    80003f12:	ce3fc0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80003f16:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003f1a:	8526                	mv	a0,s1
    80003f1c:	fd3fd0ef          	jal	80001eee <wakeup>
    release(&log.lock);
    80003f20:	8526                	mv	a0,s1
    80003f22:	d6bfc0ef          	jal	80000c8c <release>
}
    80003f26:	a025                	j	80003f4e <end_op+0x8a>
    80003f28:	ec4e                	sd	s3,24(sp)
    80003f2a:	e852                	sd	s4,16(sp)
    80003f2c:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003f2e:	00003517          	auipc	a0,0x3
    80003f32:	63250513          	addi	a0,a0,1586 # 80007560 <etext+0x560>
    80003f36:	85ffc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80003f3a:	0001e497          	auipc	s1,0x1e
    80003f3e:	cd648493          	addi	s1,s1,-810 # 80021c10 <log>
    80003f42:	8526                	mv	a0,s1
    80003f44:	fabfd0ef          	jal	80001eee <wakeup>
  release(&log.lock);
    80003f48:	8526                	mv	a0,s1
    80003f4a:	d43fc0ef          	jal	80000c8c <release>
}
    80003f4e:	70e2                	ld	ra,56(sp)
    80003f50:	7442                	ld	s0,48(sp)
    80003f52:	74a2                	ld	s1,40(sp)
    80003f54:	7902                	ld	s2,32(sp)
    80003f56:	6121                	addi	sp,sp,64
    80003f58:	8082                	ret
    80003f5a:	ec4e                	sd	s3,24(sp)
    80003f5c:	e852                	sd	s4,16(sp)
    80003f5e:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f60:	0001ea97          	auipc	s5,0x1e
    80003f64:	ce0a8a93          	addi	s5,s5,-800 # 80021c40 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003f68:	0001ea17          	auipc	s4,0x1e
    80003f6c:	ca8a0a13          	addi	s4,s4,-856 # 80021c10 <log>
    80003f70:	018a2583          	lw	a1,24(s4)
    80003f74:	012585bb          	addw	a1,a1,s2
    80003f78:	2585                	addiw	a1,a1,1
    80003f7a:	028a2503          	lw	a0,40(s4)
    80003f7e:	f0ffe0ef          	jal	80002e8c <bread>
    80003f82:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003f84:	000aa583          	lw	a1,0(s5)
    80003f88:	028a2503          	lw	a0,40(s4)
    80003f8c:	f01fe0ef          	jal	80002e8c <bread>
    80003f90:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003f92:	40000613          	li	a2,1024
    80003f96:	05850593          	addi	a1,a0,88
    80003f9a:	05848513          	addi	a0,s1,88
    80003f9e:	d87fc0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    80003fa2:	8526                	mv	a0,s1
    80003fa4:	fbffe0ef          	jal	80002f62 <bwrite>
    brelse(from);
    80003fa8:	854e                	mv	a0,s3
    80003faa:	febfe0ef          	jal	80002f94 <brelse>
    brelse(to);
    80003fae:	8526                	mv	a0,s1
    80003fb0:	fe5fe0ef          	jal	80002f94 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fb4:	2905                	addiw	s2,s2,1
    80003fb6:	0a91                	addi	s5,s5,4
    80003fb8:	02ca2783          	lw	a5,44(s4)
    80003fbc:	faf94ae3          	blt	s2,a5,80003f70 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003fc0:	d11ff0ef          	jal	80003cd0 <write_head>
    install_trans(0); // Now install writes to home locations
    80003fc4:	4501                	li	a0,0
    80003fc6:	d69ff0ef          	jal	80003d2e <install_trans>
    log.lh.n = 0;
    80003fca:	0001e797          	auipc	a5,0x1e
    80003fce:	c607a923          	sw	zero,-910(a5) # 80021c3c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003fd2:	cffff0ef          	jal	80003cd0 <write_head>
    80003fd6:	69e2                	ld	s3,24(sp)
    80003fd8:	6a42                	ld	s4,16(sp)
    80003fda:	6aa2                	ld	s5,8(sp)
    80003fdc:	b735                	j	80003f08 <end_op+0x44>

0000000080003fde <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003fde:	1101                	addi	sp,sp,-32
    80003fe0:	ec06                	sd	ra,24(sp)
    80003fe2:	e822                	sd	s0,16(sp)
    80003fe4:	e426                	sd	s1,8(sp)
    80003fe6:	e04a                	sd	s2,0(sp)
    80003fe8:	1000                	addi	s0,sp,32
    80003fea:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003fec:	0001e917          	auipc	s2,0x1e
    80003ff0:	c2490913          	addi	s2,s2,-988 # 80021c10 <log>
    80003ff4:	854a                	mv	a0,s2
    80003ff6:	bfffc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003ffa:	02c92603          	lw	a2,44(s2)
    80003ffe:	47f5                	li	a5,29
    80004000:	06c7c363          	blt	a5,a2,80004066 <log_write+0x88>
    80004004:	0001e797          	auipc	a5,0x1e
    80004008:	c287a783          	lw	a5,-984(a5) # 80021c2c <log+0x1c>
    8000400c:	37fd                	addiw	a5,a5,-1
    8000400e:	04f65c63          	bge	a2,a5,80004066 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004012:	0001e797          	auipc	a5,0x1e
    80004016:	c1e7a783          	lw	a5,-994(a5) # 80021c30 <log+0x20>
    8000401a:	04f05c63          	blez	a5,80004072 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000401e:	4781                	li	a5,0
    80004020:	04c05f63          	blez	a2,8000407e <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004024:	44cc                	lw	a1,12(s1)
    80004026:	0001e717          	auipc	a4,0x1e
    8000402a:	c1a70713          	addi	a4,a4,-998 # 80021c40 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000402e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004030:	4314                	lw	a3,0(a4)
    80004032:	04b68663          	beq	a3,a1,8000407e <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80004036:	2785                	addiw	a5,a5,1
    80004038:	0711                	addi	a4,a4,4
    8000403a:	fef61be3          	bne	a2,a5,80004030 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000403e:	0621                	addi	a2,a2,8
    80004040:	060a                	slli	a2,a2,0x2
    80004042:	0001e797          	auipc	a5,0x1e
    80004046:	bce78793          	addi	a5,a5,-1074 # 80021c10 <log>
    8000404a:	97b2                	add	a5,a5,a2
    8000404c:	44d8                	lw	a4,12(s1)
    8000404e:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004050:	8526                	mv	a0,s1
    80004052:	fcbfe0ef          	jal	8000301c <bpin>
    log.lh.n++;
    80004056:	0001e717          	auipc	a4,0x1e
    8000405a:	bba70713          	addi	a4,a4,-1094 # 80021c10 <log>
    8000405e:	575c                	lw	a5,44(a4)
    80004060:	2785                	addiw	a5,a5,1
    80004062:	d75c                	sw	a5,44(a4)
    80004064:	a80d                	j	80004096 <log_write+0xb8>
    panic("too big a transaction");
    80004066:	00003517          	auipc	a0,0x3
    8000406a:	50a50513          	addi	a0,a0,1290 # 80007570 <etext+0x570>
    8000406e:	f26fc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    80004072:	00003517          	auipc	a0,0x3
    80004076:	51650513          	addi	a0,a0,1302 # 80007588 <etext+0x588>
    8000407a:	f1afc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    8000407e:	00878693          	addi	a3,a5,8
    80004082:	068a                	slli	a3,a3,0x2
    80004084:	0001e717          	auipc	a4,0x1e
    80004088:	b8c70713          	addi	a4,a4,-1140 # 80021c10 <log>
    8000408c:	9736                	add	a4,a4,a3
    8000408e:	44d4                	lw	a3,12(s1)
    80004090:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004092:	faf60fe3          	beq	a2,a5,80004050 <log_write+0x72>
  }
  release(&log.lock);
    80004096:	0001e517          	auipc	a0,0x1e
    8000409a:	b7a50513          	addi	a0,a0,-1158 # 80021c10 <log>
    8000409e:	beffc0ef          	jal	80000c8c <release>
}
    800040a2:	60e2                	ld	ra,24(sp)
    800040a4:	6442                	ld	s0,16(sp)
    800040a6:	64a2                	ld	s1,8(sp)
    800040a8:	6902                	ld	s2,0(sp)
    800040aa:	6105                	addi	sp,sp,32
    800040ac:	8082                	ret

00000000800040ae <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800040ae:	1101                	addi	sp,sp,-32
    800040b0:	ec06                	sd	ra,24(sp)
    800040b2:	e822                	sd	s0,16(sp)
    800040b4:	e426                	sd	s1,8(sp)
    800040b6:	e04a                	sd	s2,0(sp)
    800040b8:	1000                	addi	s0,sp,32
    800040ba:	84aa                	mv	s1,a0
    800040bc:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800040be:	00003597          	auipc	a1,0x3
    800040c2:	4ea58593          	addi	a1,a1,1258 # 800075a8 <etext+0x5a8>
    800040c6:	0521                	addi	a0,a0,8
    800040c8:	aadfc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    800040cc:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800040d0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800040d4:	0204a423          	sw	zero,40(s1)
}
    800040d8:	60e2                	ld	ra,24(sp)
    800040da:	6442                	ld	s0,16(sp)
    800040dc:	64a2                	ld	s1,8(sp)
    800040de:	6902                	ld	s2,0(sp)
    800040e0:	6105                	addi	sp,sp,32
    800040e2:	8082                	ret

00000000800040e4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800040e4:	1101                	addi	sp,sp,-32
    800040e6:	ec06                	sd	ra,24(sp)
    800040e8:	e822                	sd	s0,16(sp)
    800040ea:	e426                	sd	s1,8(sp)
    800040ec:	e04a                	sd	s2,0(sp)
    800040ee:	1000                	addi	s0,sp,32
    800040f0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800040f2:	00850913          	addi	s2,a0,8
    800040f6:	854a                	mv	a0,s2
    800040f8:	afdfc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    800040fc:	409c                	lw	a5,0(s1)
    800040fe:	c799                	beqz	a5,8000410c <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004100:	85ca                	mv	a1,s2
    80004102:	8526                	mv	a0,s1
    80004104:	d9ffd0ef          	jal	80001ea2 <sleep>
  while (lk->locked) {
    80004108:	409c                	lw	a5,0(s1)
    8000410a:	fbfd                	bnez	a5,80004100 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000410c:	4785                	li	a5,1
    8000410e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004110:	fc4fd0ef          	jal	800018d4 <myproc>
    80004114:	591c                	lw	a5,48(a0)
    80004116:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004118:	854a                	mv	a0,s2
    8000411a:	b73fc0ef          	jal	80000c8c <release>
}
    8000411e:	60e2                	ld	ra,24(sp)
    80004120:	6442                	ld	s0,16(sp)
    80004122:	64a2                	ld	s1,8(sp)
    80004124:	6902                	ld	s2,0(sp)
    80004126:	6105                	addi	sp,sp,32
    80004128:	8082                	ret

000000008000412a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000412a:	1101                	addi	sp,sp,-32
    8000412c:	ec06                	sd	ra,24(sp)
    8000412e:	e822                	sd	s0,16(sp)
    80004130:	e426                	sd	s1,8(sp)
    80004132:	e04a                	sd	s2,0(sp)
    80004134:	1000                	addi	s0,sp,32
    80004136:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004138:	00850913          	addi	s2,a0,8
    8000413c:	854a                	mv	a0,s2
    8000413e:	ab7fc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    80004142:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004146:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000414a:	8526                	mv	a0,s1
    8000414c:	da3fd0ef          	jal	80001eee <wakeup>
  release(&lk->lk);
    80004150:	854a                	mv	a0,s2
    80004152:	b3bfc0ef          	jal	80000c8c <release>
}
    80004156:	60e2                	ld	ra,24(sp)
    80004158:	6442                	ld	s0,16(sp)
    8000415a:	64a2                	ld	s1,8(sp)
    8000415c:	6902                	ld	s2,0(sp)
    8000415e:	6105                	addi	sp,sp,32
    80004160:	8082                	ret

0000000080004162 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004162:	7179                	addi	sp,sp,-48
    80004164:	f406                	sd	ra,40(sp)
    80004166:	f022                	sd	s0,32(sp)
    80004168:	ec26                	sd	s1,24(sp)
    8000416a:	e84a                	sd	s2,16(sp)
    8000416c:	1800                	addi	s0,sp,48
    8000416e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004170:	00850913          	addi	s2,a0,8
    80004174:	854a                	mv	a0,s2
    80004176:	a7ffc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000417a:	409c                	lw	a5,0(s1)
    8000417c:	ef81                	bnez	a5,80004194 <holdingsleep+0x32>
    8000417e:	4481                	li	s1,0
  release(&lk->lk);
    80004180:	854a                	mv	a0,s2
    80004182:	b0bfc0ef          	jal	80000c8c <release>
  return r;
}
    80004186:	8526                	mv	a0,s1
    80004188:	70a2                	ld	ra,40(sp)
    8000418a:	7402                	ld	s0,32(sp)
    8000418c:	64e2                	ld	s1,24(sp)
    8000418e:	6942                	ld	s2,16(sp)
    80004190:	6145                	addi	sp,sp,48
    80004192:	8082                	ret
    80004194:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004196:	0284a983          	lw	s3,40(s1)
    8000419a:	f3afd0ef          	jal	800018d4 <myproc>
    8000419e:	5904                	lw	s1,48(a0)
    800041a0:	413484b3          	sub	s1,s1,s3
    800041a4:	0014b493          	seqz	s1,s1
    800041a8:	69a2                	ld	s3,8(sp)
    800041aa:	bfd9                	j	80004180 <holdingsleep+0x1e>

00000000800041ac <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800041ac:	1141                	addi	sp,sp,-16
    800041ae:	e406                	sd	ra,8(sp)
    800041b0:	e022                	sd	s0,0(sp)
    800041b2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800041b4:	00003597          	auipc	a1,0x3
    800041b8:	40458593          	addi	a1,a1,1028 # 800075b8 <etext+0x5b8>
    800041bc:	0001e517          	auipc	a0,0x1e
    800041c0:	b9c50513          	addi	a0,a0,-1124 # 80021d58 <ftable>
    800041c4:	9b1fc0ef          	jal	80000b74 <initlock>
}
    800041c8:	60a2                	ld	ra,8(sp)
    800041ca:	6402                	ld	s0,0(sp)
    800041cc:	0141                	addi	sp,sp,16
    800041ce:	8082                	ret

00000000800041d0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800041d0:	1101                	addi	sp,sp,-32
    800041d2:	ec06                	sd	ra,24(sp)
    800041d4:	e822                	sd	s0,16(sp)
    800041d6:	e426                	sd	s1,8(sp)
    800041d8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800041da:	0001e517          	auipc	a0,0x1e
    800041de:	b7e50513          	addi	a0,a0,-1154 # 80021d58 <ftable>
    800041e2:	a13fc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800041e6:	0001e497          	auipc	s1,0x1e
    800041ea:	b8a48493          	addi	s1,s1,-1142 # 80021d70 <ftable+0x18>
    800041ee:	0001f717          	auipc	a4,0x1f
    800041f2:	b2270713          	addi	a4,a4,-1246 # 80022d10 <disk>
    if(f->ref == 0){
    800041f6:	40dc                	lw	a5,4(s1)
    800041f8:	cf89                	beqz	a5,80004212 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800041fa:	02848493          	addi	s1,s1,40
    800041fe:	fee49ce3          	bne	s1,a4,800041f6 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004202:	0001e517          	auipc	a0,0x1e
    80004206:	b5650513          	addi	a0,a0,-1194 # 80021d58 <ftable>
    8000420a:	a83fc0ef          	jal	80000c8c <release>
  return 0;
    8000420e:	4481                	li	s1,0
    80004210:	a809                	j	80004222 <filealloc+0x52>
      f->ref = 1;
    80004212:	4785                	li	a5,1
    80004214:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004216:	0001e517          	auipc	a0,0x1e
    8000421a:	b4250513          	addi	a0,a0,-1214 # 80021d58 <ftable>
    8000421e:	a6ffc0ef          	jal	80000c8c <release>
}
    80004222:	8526                	mv	a0,s1
    80004224:	60e2                	ld	ra,24(sp)
    80004226:	6442                	ld	s0,16(sp)
    80004228:	64a2                	ld	s1,8(sp)
    8000422a:	6105                	addi	sp,sp,32
    8000422c:	8082                	ret

000000008000422e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000422e:	1101                	addi	sp,sp,-32
    80004230:	ec06                	sd	ra,24(sp)
    80004232:	e822                	sd	s0,16(sp)
    80004234:	e426                	sd	s1,8(sp)
    80004236:	1000                	addi	s0,sp,32
    80004238:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000423a:	0001e517          	auipc	a0,0x1e
    8000423e:	b1e50513          	addi	a0,a0,-1250 # 80021d58 <ftable>
    80004242:	9b3fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80004246:	40dc                	lw	a5,4(s1)
    80004248:	02f05063          	blez	a5,80004268 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000424c:	2785                	addiw	a5,a5,1
    8000424e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004250:	0001e517          	auipc	a0,0x1e
    80004254:	b0850513          	addi	a0,a0,-1272 # 80021d58 <ftable>
    80004258:	a35fc0ef          	jal	80000c8c <release>
  return f;
}
    8000425c:	8526                	mv	a0,s1
    8000425e:	60e2                	ld	ra,24(sp)
    80004260:	6442                	ld	s0,16(sp)
    80004262:	64a2                	ld	s1,8(sp)
    80004264:	6105                	addi	sp,sp,32
    80004266:	8082                	ret
    panic("filedup");
    80004268:	00003517          	auipc	a0,0x3
    8000426c:	35850513          	addi	a0,a0,856 # 800075c0 <etext+0x5c0>
    80004270:	d24fc0ef          	jal	80000794 <panic>

0000000080004274 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004274:	7139                	addi	sp,sp,-64
    80004276:	fc06                	sd	ra,56(sp)
    80004278:	f822                	sd	s0,48(sp)
    8000427a:	f426                	sd	s1,40(sp)
    8000427c:	0080                	addi	s0,sp,64
    8000427e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004280:	0001e517          	auipc	a0,0x1e
    80004284:	ad850513          	addi	a0,a0,-1320 # 80021d58 <ftable>
    80004288:	96dfc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    8000428c:	40dc                	lw	a5,4(s1)
    8000428e:	04f05a63          	blez	a5,800042e2 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004292:	37fd                	addiw	a5,a5,-1
    80004294:	0007871b          	sext.w	a4,a5
    80004298:	c0dc                	sw	a5,4(s1)
    8000429a:	04e04e63          	bgtz	a4,800042f6 <fileclose+0x82>
    8000429e:	f04a                	sd	s2,32(sp)
    800042a0:	ec4e                	sd	s3,24(sp)
    800042a2:	e852                	sd	s4,16(sp)
    800042a4:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800042a6:	0004a903          	lw	s2,0(s1)
    800042aa:	0094ca83          	lbu	s5,9(s1)
    800042ae:	0104ba03          	ld	s4,16(s1)
    800042b2:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800042b6:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800042ba:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800042be:	0001e517          	auipc	a0,0x1e
    800042c2:	a9a50513          	addi	a0,a0,-1382 # 80021d58 <ftable>
    800042c6:	9c7fc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    800042ca:	4785                	li	a5,1
    800042cc:	04f90063          	beq	s2,a5,8000430c <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800042d0:	3979                	addiw	s2,s2,-2
    800042d2:	4785                	li	a5,1
    800042d4:	0527f563          	bgeu	a5,s2,8000431e <fileclose+0xaa>
    800042d8:	7902                	ld	s2,32(sp)
    800042da:	69e2                	ld	s3,24(sp)
    800042dc:	6a42                	ld	s4,16(sp)
    800042de:	6aa2                	ld	s5,8(sp)
    800042e0:	a00d                	j	80004302 <fileclose+0x8e>
    800042e2:	f04a                	sd	s2,32(sp)
    800042e4:	ec4e                	sd	s3,24(sp)
    800042e6:	e852                	sd	s4,16(sp)
    800042e8:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800042ea:	00003517          	auipc	a0,0x3
    800042ee:	2de50513          	addi	a0,a0,734 # 800075c8 <etext+0x5c8>
    800042f2:	ca2fc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    800042f6:	0001e517          	auipc	a0,0x1e
    800042fa:	a6250513          	addi	a0,a0,-1438 # 80021d58 <ftable>
    800042fe:	98ffc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004302:	70e2                	ld	ra,56(sp)
    80004304:	7442                	ld	s0,48(sp)
    80004306:	74a2                	ld	s1,40(sp)
    80004308:	6121                	addi	sp,sp,64
    8000430a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000430c:	85d6                	mv	a1,s5
    8000430e:	8552                	mv	a0,s4
    80004310:	336000ef          	jal	80004646 <pipeclose>
    80004314:	7902                	ld	s2,32(sp)
    80004316:	69e2                	ld	s3,24(sp)
    80004318:	6a42                	ld	s4,16(sp)
    8000431a:	6aa2                	ld	s5,8(sp)
    8000431c:	b7dd                	j	80004302 <fileclose+0x8e>
    begin_op();
    8000431e:	b3dff0ef          	jal	80003e5a <begin_op>
    iput(ff.ip);
    80004322:	854e                	mv	a0,s3
    80004324:	c22ff0ef          	jal	80003746 <iput>
    end_op();
    80004328:	b9dff0ef          	jal	80003ec4 <end_op>
    8000432c:	7902                	ld	s2,32(sp)
    8000432e:	69e2                	ld	s3,24(sp)
    80004330:	6a42                	ld	s4,16(sp)
    80004332:	6aa2                	ld	s5,8(sp)
    80004334:	b7f9                	j	80004302 <fileclose+0x8e>

0000000080004336 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004336:	715d                	addi	sp,sp,-80
    80004338:	e486                	sd	ra,72(sp)
    8000433a:	e0a2                	sd	s0,64(sp)
    8000433c:	fc26                	sd	s1,56(sp)
    8000433e:	f44e                	sd	s3,40(sp)
    80004340:	0880                	addi	s0,sp,80
    80004342:	84aa                	mv	s1,a0
    80004344:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004346:	d8efd0ef          	jal	800018d4 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000434a:	409c                	lw	a5,0(s1)
    8000434c:	37f9                	addiw	a5,a5,-2
    8000434e:	4705                	li	a4,1
    80004350:	04f76063          	bltu	a4,a5,80004390 <filestat+0x5a>
    80004354:	f84a                	sd	s2,48(sp)
    80004356:	892a                	mv	s2,a0
    ilock(f->ip);
    80004358:	6c88                	ld	a0,24(s1)
    8000435a:	a6aff0ef          	jal	800035c4 <ilock>
    stati(f->ip, &st);
    8000435e:	fb840593          	addi	a1,s0,-72
    80004362:	6c88                	ld	a0,24(s1)
    80004364:	c8aff0ef          	jal	800037ee <stati>
    iunlock(f->ip);
    80004368:	6c88                	ld	a0,24(s1)
    8000436a:	b08ff0ef          	jal	80003672 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000436e:	46e1                	li	a3,24
    80004370:	fb840613          	addi	a2,s0,-72
    80004374:	85ce                	mv	a1,s3
    80004376:	05093503          	ld	a0,80(s2)
    8000437a:	9d8fd0ef          	jal	80001552 <copyout>
    8000437e:	41f5551b          	sraiw	a0,a0,0x1f
    80004382:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004384:	60a6                	ld	ra,72(sp)
    80004386:	6406                	ld	s0,64(sp)
    80004388:	74e2                	ld	s1,56(sp)
    8000438a:	79a2                	ld	s3,40(sp)
    8000438c:	6161                	addi	sp,sp,80
    8000438e:	8082                	ret
  return -1;
    80004390:	557d                	li	a0,-1
    80004392:	bfcd                	j	80004384 <filestat+0x4e>

0000000080004394 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004394:	7179                	addi	sp,sp,-48
    80004396:	f406                	sd	ra,40(sp)
    80004398:	f022                	sd	s0,32(sp)
    8000439a:	e84a                	sd	s2,16(sp)
    8000439c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000439e:	00854783          	lbu	a5,8(a0)
    800043a2:	cfd1                	beqz	a5,8000443e <fileread+0xaa>
    800043a4:	ec26                	sd	s1,24(sp)
    800043a6:	e44e                	sd	s3,8(sp)
    800043a8:	84aa                	mv	s1,a0
    800043aa:	89ae                	mv	s3,a1
    800043ac:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800043ae:	411c                	lw	a5,0(a0)
    800043b0:	4705                	li	a4,1
    800043b2:	04e78363          	beq	a5,a4,800043f8 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800043b6:	470d                	li	a4,3
    800043b8:	04e78763          	beq	a5,a4,80004406 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800043bc:	4709                	li	a4,2
    800043be:	06e79a63          	bne	a5,a4,80004432 <fileread+0x9e>
    ilock(f->ip);
    800043c2:	6d08                	ld	a0,24(a0)
    800043c4:	a00ff0ef          	jal	800035c4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800043c8:	874a                	mv	a4,s2
    800043ca:	5094                	lw	a3,32(s1)
    800043cc:	864e                	mv	a2,s3
    800043ce:	4585                	li	a1,1
    800043d0:	6c88                	ld	a0,24(s1)
    800043d2:	c46ff0ef          	jal	80003818 <readi>
    800043d6:	892a                	mv	s2,a0
    800043d8:	00a05563          	blez	a0,800043e2 <fileread+0x4e>
      f->off += r;
    800043dc:	509c                	lw	a5,32(s1)
    800043de:	9fa9                	addw	a5,a5,a0
    800043e0:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800043e2:	6c88                	ld	a0,24(s1)
    800043e4:	a8eff0ef          	jal	80003672 <iunlock>
    800043e8:	64e2                	ld	s1,24(sp)
    800043ea:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800043ec:	854a                	mv	a0,s2
    800043ee:	70a2                	ld	ra,40(sp)
    800043f0:	7402                	ld	s0,32(sp)
    800043f2:	6942                	ld	s2,16(sp)
    800043f4:	6145                	addi	sp,sp,48
    800043f6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800043f8:	6908                	ld	a0,16(a0)
    800043fa:	388000ef          	jal	80004782 <piperead>
    800043fe:	892a                	mv	s2,a0
    80004400:	64e2                	ld	s1,24(sp)
    80004402:	69a2                	ld	s3,8(sp)
    80004404:	b7e5                	j	800043ec <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004406:	02451783          	lh	a5,36(a0)
    8000440a:	03079693          	slli	a3,a5,0x30
    8000440e:	92c1                	srli	a3,a3,0x30
    80004410:	4725                	li	a4,9
    80004412:	02d76863          	bltu	a4,a3,80004442 <fileread+0xae>
    80004416:	0792                	slli	a5,a5,0x4
    80004418:	0001e717          	auipc	a4,0x1e
    8000441c:	8a070713          	addi	a4,a4,-1888 # 80021cb8 <devsw>
    80004420:	97ba                	add	a5,a5,a4
    80004422:	639c                	ld	a5,0(a5)
    80004424:	c39d                	beqz	a5,8000444a <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004426:	4505                	li	a0,1
    80004428:	9782                	jalr	a5
    8000442a:	892a                	mv	s2,a0
    8000442c:	64e2                	ld	s1,24(sp)
    8000442e:	69a2                	ld	s3,8(sp)
    80004430:	bf75                	j	800043ec <fileread+0x58>
    panic("fileread");
    80004432:	00003517          	auipc	a0,0x3
    80004436:	1a650513          	addi	a0,a0,422 # 800075d8 <etext+0x5d8>
    8000443a:	b5afc0ef          	jal	80000794 <panic>
    return -1;
    8000443e:	597d                	li	s2,-1
    80004440:	b775                	j	800043ec <fileread+0x58>
      return -1;
    80004442:	597d                	li	s2,-1
    80004444:	64e2                	ld	s1,24(sp)
    80004446:	69a2                	ld	s3,8(sp)
    80004448:	b755                	j	800043ec <fileread+0x58>
    8000444a:	597d                	li	s2,-1
    8000444c:	64e2                	ld	s1,24(sp)
    8000444e:	69a2                	ld	s3,8(sp)
    80004450:	bf71                	j	800043ec <fileread+0x58>

0000000080004452 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004452:	00954783          	lbu	a5,9(a0)
    80004456:	10078b63          	beqz	a5,8000456c <filewrite+0x11a>
{
    8000445a:	715d                	addi	sp,sp,-80
    8000445c:	e486                	sd	ra,72(sp)
    8000445e:	e0a2                	sd	s0,64(sp)
    80004460:	f84a                	sd	s2,48(sp)
    80004462:	f052                	sd	s4,32(sp)
    80004464:	e85a                	sd	s6,16(sp)
    80004466:	0880                	addi	s0,sp,80
    80004468:	892a                	mv	s2,a0
    8000446a:	8b2e                	mv	s6,a1
    8000446c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000446e:	411c                	lw	a5,0(a0)
    80004470:	4705                	li	a4,1
    80004472:	02e78763          	beq	a5,a4,800044a0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004476:	470d                	li	a4,3
    80004478:	02e78863          	beq	a5,a4,800044a8 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000447c:	4709                	li	a4,2
    8000447e:	0ce79c63          	bne	a5,a4,80004556 <filewrite+0x104>
    80004482:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004484:	0ac05863          	blez	a2,80004534 <filewrite+0xe2>
    80004488:	fc26                	sd	s1,56(sp)
    8000448a:	ec56                	sd	s5,24(sp)
    8000448c:	e45e                	sd	s7,8(sp)
    8000448e:	e062                	sd	s8,0(sp)
    int i = 0;
    80004490:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004492:	6b85                	lui	s7,0x1
    80004494:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004498:	6c05                	lui	s8,0x1
    8000449a:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000449e:	a8b5                	j	8000451a <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800044a0:	6908                	ld	a0,16(a0)
    800044a2:	1fc000ef          	jal	8000469e <pipewrite>
    800044a6:	a04d                	j	80004548 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800044a8:	02451783          	lh	a5,36(a0)
    800044ac:	03079693          	slli	a3,a5,0x30
    800044b0:	92c1                	srli	a3,a3,0x30
    800044b2:	4725                	li	a4,9
    800044b4:	0ad76e63          	bltu	a4,a3,80004570 <filewrite+0x11e>
    800044b8:	0792                	slli	a5,a5,0x4
    800044ba:	0001d717          	auipc	a4,0x1d
    800044be:	7fe70713          	addi	a4,a4,2046 # 80021cb8 <devsw>
    800044c2:	97ba                	add	a5,a5,a4
    800044c4:	679c                	ld	a5,8(a5)
    800044c6:	c7dd                	beqz	a5,80004574 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800044c8:	4505                	li	a0,1
    800044ca:	9782                	jalr	a5
    800044cc:	a8b5                	j	80004548 <filewrite+0xf6>
      if(n1 > max)
    800044ce:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800044d2:	989ff0ef          	jal	80003e5a <begin_op>
      ilock(f->ip);
    800044d6:	01893503          	ld	a0,24(s2)
    800044da:	8eaff0ef          	jal	800035c4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800044de:	8756                	mv	a4,s5
    800044e0:	02092683          	lw	a3,32(s2)
    800044e4:	01698633          	add	a2,s3,s6
    800044e8:	4585                	li	a1,1
    800044ea:	01893503          	ld	a0,24(s2)
    800044ee:	c26ff0ef          	jal	80003914 <writei>
    800044f2:	84aa                	mv	s1,a0
    800044f4:	00a05763          	blez	a0,80004502 <filewrite+0xb0>
        f->off += r;
    800044f8:	02092783          	lw	a5,32(s2)
    800044fc:	9fa9                	addw	a5,a5,a0
    800044fe:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004502:	01893503          	ld	a0,24(s2)
    80004506:	96cff0ef          	jal	80003672 <iunlock>
      end_op();
    8000450a:	9bbff0ef          	jal	80003ec4 <end_op>

      if(r != n1){
    8000450e:	029a9563          	bne	s5,s1,80004538 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004512:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004516:	0149da63          	bge	s3,s4,8000452a <filewrite+0xd8>
      int n1 = n - i;
    8000451a:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000451e:	0004879b          	sext.w	a5,s1
    80004522:	fafbd6e3          	bge	s7,a5,800044ce <filewrite+0x7c>
    80004526:	84e2                	mv	s1,s8
    80004528:	b75d                	j	800044ce <filewrite+0x7c>
    8000452a:	74e2                	ld	s1,56(sp)
    8000452c:	6ae2                	ld	s5,24(sp)
    8000452e:	6ba2                	ld	s7,8(sp)
    80004530:	6c02                	ld	s8,0(sp)
    80004532:	a039                	j	80004540 <filewrite+0xee>
    int i = 0;
    80004534:	4981                	li	s3,0
    80004536:	a029                	j	80004540 <filewrite+0xee>
    80004538:	74e2                	ld	s1,56(sp)
    8000453a:	6ae2                	ld	s5,24(sp)
    8000453c:	6ba2                	ld	s7,8(sp)
    8000453e:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004540:	033a1c63          	bne	s4,s3,80004578 <filewrite+0x126>
    80004544:	8552                	mv	a0,s4
    80004546:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004548:	60a6                	ld	ra,72(sp)
    8000454a:	6406                	ld	s0,64(sp)
    8000454c:	7942                	ld	s2,48(sp)
    8000454e:	7a02                	ld	s4,32(sp)
    80004550:	6b42                	ld	s6,16(sp)
    80004552:	6161                	addi	sp,sp,80
    80004554:	8082                	ret
    80004556:	fc26                	sd	s1,56(sp)
    80004558:	f44e                	sd	s3,40(sp)
    8000455a:	ec56                	sd	s5,24(sp)
    8000455c:	e45e                	sd	s7,8(sp)
    8000455e:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004560:	00003517          	auipc	a0,0x3
    80004564:	08850513          	addi	a0,a0,136 # 800075e8 <etext+0x5e8>
    80004568:	a2cfc0ef          	jal	80000794 <panic>
    return -1;
    8000456c:	557d                	li	a0,-1
}
    8000456e:	8082                	ret
      return -1;
    80004570:	557d                	li	a0,-1
    80004572:	bfd9                	j	80004548 <filewrite+0xf6>
    80004574:	557d                	li	a0,-1
    80004576:	bfc9                	j	80004548 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004578:	557d                	li	a0,-1
    8000457a:	79a2                	ld	s3,40(sp)
    8000457c:	b7f1                	j	80004548 <filewrite+0xf6>

000000008000457e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000457e:	7179                	addi	sp,sp,-48
    80004580:	f406                	sd	ra,40(sp)
    80004582:	f022                	sd	s0,32(sp)
    80004584:	ec26                	sd	s1,24(sp)
    80004586:	e052                	sd	s4,0(sp)
    80004588:	1800                	addi	s0,sp,48
    8000458a:	84aa                	mv	s1,a0
    8000458c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000458e:	0005b023          	sd	zero,0(a1)
    80004592:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004596:	c3bff0ef          	jal	800041d0 <filealloc>
    8000459a:	e088                	sd	a0,0(s1)
    8000459c:	c549                	beqz	a0,80004626 <pipealloc+0xa8>
    8000459e:	c33ff0ef          	jal	800041d0 <filealloc>
    800045a2:	00aa3023          	sd	a0,0(s4)
    800045a6:	cd25                	beqz	a0,8000461e <pipealloc+0xa0>
    800045a8:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800045aa:	d7afc0ef          	jal	80000b24 <kalloc>
    800045ae:	892a                	mv	s2,a0
    800045b0:	c12d                	beqz	a0,80004612 <pipealloc+0x94>
    800045b2:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800045b4:	4985                	li	s3,1
    800045b6:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800045ba:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800045be:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800045c2:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800045c6:	00003597          	auipc	a1,0x3
    800045ca:	03258593          	addi	a1,a1,50 # 800075f8 <etext+0x5f8>
    800045ce:	da6fc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    800045d2:	609c                	ld	a5,0(s1)
    800045d4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800045d8:	609c                	ld	a5,0(s1)
    800045da:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800045de:	609c                	ld	a5,0(s1)
    800045e0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800045e4:	609c                	ld	a5,0(s1)
    800045e6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800045ea:	000a3783          	ld	a5,0(s4)
    800045ee:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800045f2:	000a3783          	ld	a5,0(s4)
    800045f6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800045fa:	000a3783          	ld	a5,0(s4)
    800045fe:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004602:	000a3783          	ld	a5,0(s4)
    80004606:	0127b823          	sd	s2,16(a5)
  return 0;
    8000460a:	4501                	li	a0,0
    8000460c:	6942                	ld	s2,16(sp)
    8000460e:	69a2                	ld	s3,8(sp)
    80004610:	a01d                	j	80004636 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004612:	6088                	ld	a0,0(s1)
    80004614:	c119                	beqz	a0,8000461a <pipealloc+0x9c>
    80004616:	6942                	ld	s2,16(sp)
    80004618:	a029                	j	80004622 <pipealloc+0xa4>
    8000461a:	6942                	ld	s2,16(sp)
    8000461c:	a029                	j	80004626 <pipealloc+0xa8>
    8000461e:	6088                	ld	a0,0(s1)
    80004620:	c10d                	beqz	a0,80004642 <pipealloc+0xc4>
    fileclose(*f0);
    80004622:	c53ff0ef          	jal	80004274 <fileclose>
  if(*f1)
    80004626:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000462a:	557d                	li	a0,-1
  if(*f1)
    8000462c:	c789                	beqz	a5,80004636 <pipealloc+0xb8>
    fileclose(*f1);
    8000462e:	853e                	mv	a0,a5
    80004630:	c45ff0ef          	jal	80004274 <fileclose>
  return -1;
    80004634:	557d                	li	a0,-1
}
    80004636:	70a2                	ld	ra,40(sp)
    80004638:	7402                	ld	s0,32(sp)
    8000463a:	64e2                	ld	s1,24(sp)
    8000463c:	6a02                	ld	s4,0(sp)
    8000463e:	6145                	addi	sp,sp,48
    80004640:	8082                	ret
  return -1;
    80004642:	557d                	li	a0,-1
    80004644:	bfcd                	j	80004636 <pipealloc+0xb8>

0000000080004646 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004646:	1101                	addi	sp,sp,-32
    80004648:	ec06                	sd	ra,24(sp)
    8000464a:	e822                	sd	s0,16(sp)
    8000464c:	e426                	sd	s1,8(sp)
    8000464e:	e04a                	sd	s2,0(sp)
    80004650:	1000                	addi	s0,sp,32
    80004652:	84aa                	mv	s1,a0
    80004654:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004656:	d9efc0ef          	jal	80000bf4 <acquire>
  if(writable){
    8000465a:	02090763          	beqz	s2,80004688 <pipeclose+0x42>
    pi->writeopen = 0;
    8000465e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004662:	21848513          	addi	a0,s1,536
    80004666:	889fd0ef          	jal	80001eee <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000466a:	2204b783          	ld	a5,544(s1)
    8000466e:	e785                	bnez	a5,80004696 <pipeclose+0x50>
    release(&pi->lock);
    80004670:	8526                	mv	a0,s1
    80004672:	e1afc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    80004676:	8526                	mv	a0,s1
    80004678:	bcafc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    8000467c:	60e2                	ld	ra,24(sp)
    8000467e:	6442                	ld	s0,16(sp)
    80004680:	64a2                	ld	s1,8(sp)
    80004682:	6902                	ld	s2,0(sp)
    80004684:	6105                	addi	sp,sp,32
    80004686:	8082                	ret
    pi->readopen = 0;
    80004688:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000468c:	21c48513          	addi	a0,s1,540
    80004690:	85ffd0ef          	jal	80001eee <wakeup>
    80004694:	bfd9                	j	8000466a <pipeclose+0x24>
    release(&pi->lock);
    80004696:	8526                	mv	a0,s1
    80004698:	df4fc0ef          	jal	80000c8c <release>
}
    8000469c:	b7c5                	j	8000467c <pipeclose+0x36>

000000008000469e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000469e:	711d                	addi	sp,sp,-96
    800046a0:	ec86                	sd	ra,88(sp)
    800046a2:	e8a2                	sd	s0,80(sp)
    800046a4:	e4a6                	sd	s1,72(sp)
    800046a6:	e0ca                	sd	s2,64(sp)
    800046a8:	fc4e                	sd	s3,56(sp)
    800046aa:	f852                	sd	s4,48(sp)
    800046ac:	f456                	sd	s5,40(sp)
    800046ae:	1080                	addi	s0,sp,96
    800046b0:	84aa                	mv	s1,a0
    800046b2:	8aae                	mv	s5,a1
    800046b4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800046b6:	a1efd0ef          	jal	800018d4 <myproc>
    800046ba:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800046bc:	8526                	mv	a0,s1
    800046be:	d36fc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    800046c2:	0b405a63          	blez	s4,80004776 <pipewrite+0xd8>
    800046c6:	f05a                	sd	s6,32(sp)
    800046c8:	ec5e                	sd	s7,24(sp)
    800046ca:	e862                	sd	s8,16(sp)
  int i = 0;
    800046cc:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800046ce:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800046d0:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800046d4:	21c48b93          	addi	s7,s1,540
    800046d8:	a81d                	j	8000470e <pipewrite+0x70>
      release(&pi->lock);
    800046da:	8526                	mv	a0,s1
    800046dc:	db0fc0ef          	jal	80000c8c <release>
      return -1;
    800046e0:	597d                	li	s2,-1
    800046e2:	7b02                	ld	s6,32(sp)
    800046e4:	6be2                	ld	s7,24(sp)
    800046e6:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800046e8:	854a                	mv	a0,s2
    800046ea:	60e6                	ld	ra,88(sp)
    800046ec:	6446                	ld	s0,80(sp)
    800046ee:	64a6                	ld	s1,72(sp)
    800046f0:	6906                	ld	s2,64(sp)
    800046f2:	79e2                	ld	s3,56(sp)
    800046f4:	7a42                	ld	s4,48(sp)
    800046f6:	7aa2                	ld	s5,40(sp)
    800046f8:	6125                	addi	sp,sp,96
    800046fa:	8082                	ret
      wakeup(&pi->nread);
    800046fc:	8562                	mv	a0,s8
    800046fe:	ff0fd0ef          	jal	80001eee <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004702:	85a6                	mv	a1,s1
    80004704:	855e                	mv	a0,s7
    80004706:	f9cfd0ef          	jal	80001ea2 <sleep>
  while(i < n){
    8000470a:	05495b63          	bge	s2,s4,80004760 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    8000470e:	2204a783          	lw	a5,544(s1)
    80004712:	d7e1                	beqz	a5,800046da <pipewrite+0x3c>
    80004714:	854e                	mv	a0,s3
    80004716:	9c5fd0ef          	jal	800020da <killed>
    8000471a:	f161                	bnez	a0,800046da <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000471c:	2184a783          	lw	a5,536(s1)
    80004720:	21c4a703          	lw	a4,540(s1)
    80004724:	2007879b          	addiw	a5,a5,512
    80004728:	fcf70ae3          	beq	a4,a5,800046fc <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000472c:	4685                	li	a3,1
    8000472e:	01590633          	add	a2,s2,s5
    80004732:	faf40593          	addi	a1,s0,-81
    80004736:	0509b503          	ld	a0,80(s3)
    8000473a:	eeffc0ef          	jal	80001628 <copyin>
    8000473e:	03650e63          	beq	a0,s6,8000477a <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004742:	21c4a783          	lw	a5,540(s1)
    80004746:	0017871b          	addiw	a4,a5,1
    8000474a:	20e4ae23          	sw	a4,540(s1)
    8000474e:	1ff7f793          	andi	a5,a5,511
    80004752:	97a6                	add	a5,a5,s1
    80004754:	faf44703          	lbu	a4,-81(s0)
    80004758:	00e78c23          	sb	a4,24(a5)
      i++;
    8000475c:	2905                	addiw	s2,s2,1
    8000475e:	b775                	j	8000470a <pipewrite+0x6c>
    80004760:	7b02                	ld	s6,32(sp)
    80004762:	6be2                	ld	s7,24(sp)
    80004764:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004766:	21848513          	addi	a0,s1,536
    8000476a:	f84fd0ef          	jal	80001eee <wakeup>
  release(&pi->lock);
    8000476e:	8526                	mv	a0,s1
    80004770:	d1cfc0ef          	jal	80000c8c <release>
  return i;
    80004774:	bf95                	j	800046e8 <pipewrite+0x4a>
  int i = 0;
    80004776:	4901                	li	s2,0
    80004778:	b7fd                	j	80004766 <pipewrite+0xc8>
    8000477a:	7b02                	ld	s6,32(sp)
    8000477c:	6be2                	ld	s7,24(sp)
    8000477e:	6c42                	ld	s8,16(sp)
    80004780:	b7dd                	j	80004766 <pipewrite+0xc8>

0000000080004782 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004782:	715d                	addi	sp,sp,-80
    80004784:	e486                	sd	ra,72(sp)
    80004786:	e0a2                	sd	s0,64(sp)
    80004788:	fc26                	sd	s1,56(sp)
    8000478a:	f84a                	sd	s2,48(sp)
    8000478c:	f44e                	sd	s3,40(sp)
    8000478e:	f052                	sd	s4,32(sp)
    80004790:	ec56                	sd	s5,24(sp)
    80004792:	0880                	addi	s0,sp,80
    80004794:	84aa                	mv	s1,a0
    80004796:	892e                	mv	s2,a1
    80004798:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000479a:	93afd0ef          	jal	800018d4 <myproc>
    8000479e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800047a0:	8526                	mv	a0,s1
    800047a2:	c52fc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047a6:	2184a703          	lw	a4,536(s1)
    800047aa:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800047ae:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047b2:	02f71563          	bne	a4,a5,800047dc <piperead+0x5a>
    800047b6:	2244a783          	lw	a5,548(s1)
    800047ba:	cb85                	beqz	a5,800047ea <piperead+0x68>
    if(killed(pr)){
    800047bc:	8552                	mv	a0,s4
    800047be:	91dfd0ef          	jal	800020da <killed>
    800047c2:	ed19                	bnez	a0,800047e0 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800047c4:	85a6                	mv	a1,s1
    800047c6:	854e                	mv	a0,s3
    800047c8:	edafd0ef          	jal	80001ea2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047cc:	2184a703          	lw	a4,536(s1)
    800047d0:	21c4a783          	lw	a5,540(s1)
    800047d4:	fef701e3          	beq	a4,a5,800047b6 <piperead+0x34>
    800047d8:	e85a                	sd	s6,16(sp)
    800047da:	a809                	j	800047ec <piperead+0x6a>
    800047dc:	e85a                	sd	s6,16(sp)
    800047de:	a039                	j	800047ec <piperead+0x6a>
      release(&pi->lock);
    800047e0:	8526                	mv	a0,s1
    800047e2:	caafc0ef          	jal	80000c8c <release>
      return -1;
    800047e6:	59fd                	li	s3,-1
    800047e8:	a8b1                	j	80004844 <piperead+0xc2>
    800047ea:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800047ec:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800047ee:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800047f0:	05505263          	blez	s5,80004834 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    800047f4:	2184a783          	lw	a5,536(s1)
    800047f8:	21c4a703          	lw	a4,540(s1)
    800047fc:	02f70c63          	beq	a4,a5,80004834 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004800:	0017871b          	addiw	a4,a5,1
    80004804:	20e4ac23          	sw	a4,536(s1)
    80004808:	1ff7f793          	andi	a5,a5,511
    8000480c:	97a6                	add	a5,a5,s1
    8000480e:	0187c783          	lbu	a5,24(a5)
    80004812:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004816:	4685                	li	a3,1
    80004818:	fbf40613          	addi	a2,s0,-65
    8000481c:	85ca                	mv	a1,s2
    8000481e:	050a3503          	ld	a0,80(s4)
    80004822:	d31fc0ef          	jal	80001552 <copyout>
    80004826:	01650763          	beq	a0,s6,80004834 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000482a:	2985                	addiw	s3,s3,1
    8000482c:	0905                	addi	s2,s2,1
    8000482e:	fd3a93e3          	bne	s5,s3,800047f4 <piperead+0x72>
    80004832:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004834:	21c48513          	addi	a0,s1,540
    80004838:	eb6fd0ef          	jal	80001eee <wakeup>
  release(&pi->lock);
    8000483c:	8526                	mv	a0,s1
    8000483e:	c4efc0ef          	jal	80000c8c <release>
    80004842:	6b42                	ld	s6,16(sp)
  return i;
}
    80004844:	854e                	mv	a0,s3
    80004846:	60a6                	ld	ra,72(sp)
    80004848:	6406                	ld	s0,64(sp)
    8000484a:	74e2                	ld	s1,56(sp)
    8000484c:	7942                	ld	s2,48(sp)
    8000484e:	79a2                	ld	s3,40(sp)
    80004850:	7a02                	ld	s4,32(sp)
    80004852:	6ae2                	ld	s5,24(sp)
    80004854:	6161                	addi	sp,sp,80
    80004856:	8082                	ret

0000000080004858 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004858:	1141                	addi	sp,sp,-16
    8000485a:	e422                	sd	s0,8(sp)
    8000485c:	0800                	addi	s0,sp,16
    8000485e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004860:	8905                	andi	a0,a0,1
    80004862:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004864:	8b89                	andi	a5,a5,2
    80004866:	c399                	beqz	a5,8000486c <flags2perm+0x14>
      perm |= PTE_W;
    80004868:	00456513          	ori	a0,a0,4
    return perm;
}
    8000486c:	6422                	ld	s0,8(sp)
    8000486e:	0141                	addi	sp,sp,16
    80004870:	8082                	ret

0000000080004872 <exec>:

int
exec(char *path, char **argv)
{
    80004872:	df010113          	addi	sp,sp,-528
    80004876:	20113423          	sd	ra,520(sp)
    8000487a:	20813023          	sd	s0,512(sp)
    8000487e:	ffa6                	sd	s1,504(sp)
    80004880:	fbca                	sd	s2,496(sp)
    80004882:	0c00                	addi	s0,sp,528
    80004884:	892a                	mv	s2,a0
    80004886:	dea43c23          	sd	a0,-520(s0)
    8000488a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000488e:	846fd0ef          	jal	800018d4 <myproc>
    80004892:	84aa                	mv	s1,a0

  begin_op();
    80004894:	dc6ff0ef          	jal	80003e5a <begin_op>

  if((ip = namei(path)) == 0){
    80004898:	854a                	mv	a0,s2
    8000489a:	c04ff0ef          	jal	80003c9e <namei>
    8000489e:	c931                	beqz	a0,800048f2 <exec+0x80>
    800048a0:	f3d2                	sd	s4,480(sp)
    800048a2:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800048a4:	d21fe0ef          	jal	800035c4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800048a8:	04000713          	li	a4,64
    800048ac:	4681                	li	a3,0
    800048ae:	e5040613          	addi	a2,s0,-432
    800048b2:	4581                	li	a1,0
    800048b4:	8552                	mv	a0,s4
    800048b6:	f63fe0ef          	jal	80003818 <readi>
    800048ba:	04000793          	li	a5,64
    800048be:	00f51a63          	bne	a0,a5,800048d2 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800048c2:	e5042703          	lw	a4,-432(s0)
    800048c6:	464c47b7          	lui	a5,0x464c4
    800048ca:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800048ce:	02f70663          	beq	a4,a5,800048fa <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800048d2:	8552                	mv	a0,s4
    800048d4:	efbfe0ef          	jal	800037ce <iunlockput>
    end_op();
    800048d8:	decff0ef          	jal	80003ec4 <end_op>
  }
  return -1;
    800048dc:	557d                	li	a0,-1
    800048de:	7a1e                	ld	s4,480(sp)
}
    800048e0:	20813083          	ld	ra,520(sp)
    800048e4:	20013403          	ld	s0,512(sp)
    800048e8:	74fe                	ld	s1,504(sp)
    800048ea:	795e                	ld	s2,496(sp)
    800048ec:	21010113          	addi	sp,sp,528
    800048f0:	8082                	ret
    end_op();
    800048f2:	dd2ff0ef          	jal	80003ec4 <end_op>
    return -1;
    800048f6:	557d                	li	a0,-1
    800048f8:	b7e5                	j	800048e0 <exec+0x6e>
    800048fa:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800048fc:	8526                	mv	a0,s1
    800048fe:	87efd0ef          	jal	8000197c <proc_pagetable>
    80004902:	8b2a                	mv	s6,a0
    80004904:	2c050b63          	beqz	a0,80004bda <exec+0x368>
    80004908:	f7ce                	sd	s3,488(sp)
    8000490a:	efd6                	sd	s5,472(sp)
    8000490c:	e7de                	sd	s7,456(sp)
    8000490e:	e3e2                	sd	s8,448(sp)
    80004910:	ff66                	sd	s9,440(sp)
    80004912:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004914:	e7042d03          	lw	s10,-400(s0)
    80004918:	e8845783          	lhu	a5,-376(s0)
    8000491c:	12078963          	beqz	a5,80004a4e <exec+0x1dc>
    80004920:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004922:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004924:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004926:	6c85                	lui	s9,0x1
    80004928:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000492c:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004930:	6a85                	lui	s5,0x1
    80004932:	a085                	j	80004992 <exec+0x120>
      panic("loadseg: address should exist");
    80004934:	00003517          	auipc	a0,0x3
    80004938:	ccc50513          	addi	a0,a0,-820 # 80007600 <etext+0x600>
    8000493c:	e59fb0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    80004940:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004942:	8726                	mv	a4,s1
    80004944:	012c06bb          	addw	a3,s8,s2
    80004948:	4581                	li	a1,0
    8000494a:	8552                	mv	a0,s4
    8000494c:	ecdfe0ef          	jal	80003818 <readi>
    80004950:	2501                	sext.w	a0,a0
    80004952:	24a49a63          	bne	s1,a0,80004ba6 <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004956:	012a893b          	addw	s2,s5,s2
    8000495a:	03397363          	bgeu	s2,s3,80004980 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    8000495e:	02091593          	slli	a1,s2,0x20
    80004962:	9181                	srli	a1,a1,0x20
    80004964:	95de                	add	a1,a1,s7
    80004966:	855a                	mv	a0,s6
    80004968:	e6efc0ef          	jal	80000fd6 <walkaddr>
    8000496c:	862a                	mv	a2,a0
    if(pa == 0)
    8000496e:	d179                	beqz	a0,80004934 <exec+0xc2>
    if(sz - i < PGSIZE)
    80004970:	412984bb          	subw	s1,s3,s2
    80004974:	0004879b          	sext.w	a5,s1
    80004978:	fcfcf4e3          	bgeu	s9,a5,80004940 <exec+0xce>
    8000497c:	84d6                	mv	s1,s5
    8000497e:	b7c9                	j	80004940 <exec+0xce>
    sz = sz1;
    80004980:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004984:	2d85                	addiw	s11,s11,1
    80004986:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    8000498a:	e8845783          	lhu	a5,-376(s0)
    8000498e:	08fdd063          	bge	s11,a5,80004a0e <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004992:	2d01                	sext.w	s10,s10
    80004994:	03800713          	li	a4,56
    80004998:	86ea                	mv	a3,s10
    8000499a:	e1840613          	addi	a2,s0,-488
    8000499e:	4581                	li	a1,0
    800049a0:	8552                	mv	a0,s4
    800049a2:	e77fe0ef          	jal	80003818 <readi>
    800049a6:	03800793          	li	a5,56
    800049aa:	1cf51663          	bne	a0,a5,80004b76 <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800049ae:	e1842783          	lw	a5,-488(s0)
    800049b2:	4705                	li	a4,1
    800049b4:	fce798e3          	bne	a5,a4,80004984 <exec+0x112>
    if(ph.memsz < ph.filesz)
    800049b8:	e4043483          	ld	s1,-448(s0)
    800049bc:	e3843783          	ld	a5,-456(s0)
    800049c0:	1af4ef63          	bltu	s1,a5,80004b7e <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800049c4:	e2843783          	ld	a5,-472(s0)
    800049c8:	94be                	add	s1,s1,a5
    800049ca:	1af4ee63          	bltu	s1,a5,80004b86 <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    800049ce:	df043703          	ld	a4,-528(s0)
    800049d2:	8ff9                	and	a5,a5,a4
    800049d4:	1a079d63          	bnez	a5,80004b8e <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800049d8:	e1c42503          	lw	a0,-484(s0)
    800049dc:	e7dff0ef          	jal	80004858 <flags2perm>
    800049e0:	86aa                	mv	a3,a0
    800049e2:	8626                	mv	a2,s1
    800049e4:	85ca                	mv	a1,s2
    800049e6:	855a                	mv	a0,s6
    800049e8:	957fc0ef          	jal	8000133e <uvmalloc>
    800049ec:	e0a43423          	sd	a0,-504(s0)
    800049f0:	1a050363          	beqz	a0,80004b96 <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800049f4:	e2843b83          	ld	s7,-472(s0)
    800049f8:	e2042c03          	lw	s8,-480(s0)
    800049fc:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004a00:	00098463          	beqz	s3,80004a08 <exec+0x196>
    80004a04:	4901                	li	s2,0
    80004a06:	bfa1                	j	8000495e <exec+0xec>
    sz = sz1;
    80004a08:	e0843903          	ld	s2,-504(s0)
    80004a0c:	bfa5                	j	80004984 <exec+0x112>
    80004a0e:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004a10:	8552                	mv	a0,s4
    80004a12:	dbdfe0ef          	jal	800037ce <iunlockput>
  end_op();
    80004a16:	caeff0ef          	jal	80003ec4 <end_op>
  p = myproc();
    80004a1a:	ebbfc0ef          	jal	800018d4 <myproc>
    80004a1e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004a20:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004a24:	6985                	lui	s3,0x1
    80004a26:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004a28:	99ca                	add	s3,s3,s2
    80004a2a:	77fd                	lui	a5,0xfffff
    80004a2c:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004a30:	4691                	li	a3,4
    80004a32:	6609                	lui	a2,0x2
    80004a34:	964e                	add	a2,a2,s3
    80004a36:	85ce                	mv	a1,s3
    80004a38:	855a                	mv	a0,s6
    80004a3a:	905fc0ef          	jal	8000133e <uvmalloc>
    80004a3e:	892a                	mv	s2,a0
    80004a40:	e0a43423          	sd	a0,-504(s0)
    80004a44:	e519                	bnez	a0,80004a52 <exec+0x1e0>
  if(pagetable)
    80004a46:	e1343423          	sd	s3,-504(s0)
    80004a4a:	4a01                	li	s4,0
    80004a4c:	aab1                	j	80004ba8 <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a4e:	4901                	li	s2,0
    80004a50:	b7c1                	j	80004a10 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004a52:	75f9                	lui	a1,0xffffe
    80004a54:	95aa                	add	a1,a1,a0
    80004a56:	855a                	mv	a0,s6
    80004a58:	ad1fc0ef          	jal	80001528 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004a5c:	7bfd                	lui	s7,0xfffff
    80004a5e:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004a60:	e0043783          	ld	a5,-512(s0)
    80004a64:	6388                	ld	a0,0(a5)
    80004a66:	cd39                	beqz	a0,80004ac4 <exec+0x252>
    80004a68:	e9040993          	addi	s3,s0,-368
    80004a6c:	f9040c13          	addi	s8,s0,-112
    80004a70:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004a72:	bc6fc0ef          	jal	80000e38 <strlen>
    80004a76:	0015079b          	addiw	a5,a0,1
    80004a7a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004a7e:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004a82:	11796e63          	bltu	s2,s7,80004b9e <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004a86:	e0043d03          	ld	s10,-512(s0)
    80004a8a:	000d3a03          	ld	s4,0(s10)
    80004a8e:	8552                	mv	a0,s4
    80004a90:	ba8fc0ef          	jal	80000e38 <strlen>
    80004a94:	0015069b          	addiw	a3,a0,1
    80004a98:	8652                	mv	a2,s4
    80004a9a:	85ca                	mv	a1,s2
    80004a9c:	855a                	mv	a0,s6
    80004a9e:	ab5fc0ef          	jal	80001552 <copyout>
    80004aa2:	10054063          	bltz	a0,80004ba2 <exec+0x330>
    ustack[argc] = sp;
    80004aa6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004aaa:	0485                	addi	s1,s1,1
    80004aac:	008d0793          	addi	a5,s10,8
    80004ab0:	e0f43023          	sd	a5,-512(s0)
    80004ab4:	008d3503          	ld	a0,8(s10)
    80004ab8:	c909                	beqz	a0,80004aca <exec+0x258>
    if(argc >= MAXARG)
    80004aba:	09a1                	addi	s3,s3,8
    80004abc:	fb899be3          	bne	s3,s8,80004a72 <exec+0x200>
  ip = 0;
    80004ac0:	4a01                	li	s4,0
    80004ac2:	a0dd                	j	80004ba8 <exec+0x336>
  sp = sz;
    80004ac4:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004ac8:	4481                	li	s1,0
  ustack[argc] = 0;
    80004aca:	00349793          	slli	a5,s1,0x3
    80004ace:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdc140>
    80004ad2:	97a2                	add	a5,a5,s0
    80004ad4:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004ad8:	00148693          	addi	a3,s1,1
    80004adc:	068e                	slli	a3,a3,0x3
    80004ade:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004ae2:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004ae6:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004aea:	f5796ee3          	bltu	s2,s7,80004a46 <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004aee:	e9040613          	addi	a2,s0,-368
    80004af2:	85ca                	mv	a1,s2
    80004af4:	855a                	mv	a0,s6
    80004af6:	a5dfc0ef          	jal	80001552 <copyout>
    80004afa:	0e054263          	bltz	a0,80004bde <exec+0x36c>
  p->trapframe->a1 = sp;
    80004afe:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004b02:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004b06:	df843783          	ld	a5,-520(s0)
    80004b0a:	0007c703          	lbu	a4,0(a5)
    80004b0e:	cf11                	beqz	a4,80004b2a <exec+0x2b8>
    80004b10:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004b12:	02f00693          	li	a3,47
    80004b16:	a039                	j	80004b24 <exec+0x2b2>
      last = s+1;
    80004b18:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004b1c:	0785                	addi	a5,a5,1
    80004b1e:	fff7c703          	lbu	a4,-1(a5)
    80004b22:	c701                	beqz	a4,80004b2a <exec+0x2b8>
    if(*s == '/')
    80004b24:	fed71ce3          	bne	a4,a3,80004b1c <exec+0x2aa>
    80004b28:	bfc5                	j	80004b18 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004b2a:	4641                	li	a2,16
    80004b2c:	df843583          	ld	a1,-520(s0)
    80004b30:	158a8513          	addi	a0,s5,344
    80004b34:	ad2fc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    80004b38:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004b3c:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004b40:	e0843783          	ld	a5,-504(s0)
    80004b44:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004b48:	058ab783          	ld	a5,88(s5)
    80004b4c:	e6843703          	ld	a4,-408(s0)
    80004b50:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004b52:	058ab783          	ld	a5,88(s5)
    80004b56:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004b5a:	85e6                	mv	a1,s9
    80004b5c:	ea5fc0ef          	jal	80001a00 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004b60:	0004851b          	sext.w	a0,s1
    80004b64:	79be                	ld	s3,488(sp)
    80004b66:	7a1e                	ld	s4,480(sp)
    80004b68:	6afe                	ld	s5,472(sp)
    80004b6a:	6b5e                	ld	s6,464(sp)
    80004b6c:	6bbe                	ld	s7,456(sp)
    80004b6e:	6c1e                	ld	s8,448(sp)
    80004b70:	7cfa                	ld	s9,440(sp)
    80004b72:	7d5a                	ld	s10,432(sp)
    80004b74:	b3b5                	j	800048e0 <exec+0x6e>
    80004b76:	e1243423          	sd	s2,-504(s0)
    80004b7a:	7dba                	ld	s11,424(sp)
    80004b7c:	a035                	j	80004ba8 <exec+0x336>
    80004b7e:	e1243423          	sd	s2,-504(s0)
    80004b82:	7dba                	ld	s11,424(sp)
    80004b84:	a015                	j	80004ba8 <exec+0x336>
    80004b86:	e1243423          	sd	s2,-504(s0)
    80004b8a:	7dba                	ld	s11,424(sp)
    80004b8c:	a831                	j	80004ba8 <exec+0x336>
    80004b8e:	e1243423          	sd	s2,-504(s0)
    80004b92:	7dba                	ld	s11,424(sp)
    80004b94:	a811                	j	80004ba8 <exec+0x336>
    80004b96:	e1243423          	sd	s2,-504(s0)
    80004b9a:	7dba                	ld	s11,424(sp)
    80004b9c:	a031                	j	80004ba8 <exec+0x336>
  ip = 0;
    80004b9e:	4a01                	li	s4,0
    80004ba0:	a021                	j	80004ba8 <exec+0x336>
    80004ba2:	4a01                	li	s4,0
  if(pagetable)
    80004ba4:	a011                	j	80004ba8 <exec+0x336>
    80004ba6:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004ba8:	e0843583          	ld	a1,-504(s0)
    80004bac:	855a                	mv	a0,s6
    80004bae:	e53fc0ef          	jal	80001a00 <proc_freepagetable>
  return -1;
    80004bb2:	557d                	li	a0,-1
  if(ip){
    80004bb4:	000a1b63          	bnez	s4,80004bca <exec+0x358>
    80004bb8:	79be                	ld	s3,488(sp)
    80004bba:	7a1e                	ld	s4,480(sp)
    80004bbc:	6afe                	ld	s5,472(sp)
    80004bbe:	6b5e                	ld	s6,464(sp)
    80004bc0:	6bbe                	ld	s7,456(sp)
    80004bc2:	6c1e                	ld	s8,448(sp)
    80004bc4:	7cfa                	ld	s9,440(sp)
    80004bc6:	7d5a                	ld	s10,432(sp)
    80004bc8:	bb21                	j	800048e0 <exec+0x6e>
    80004bca:	79be                	ld	s3,488(sp)
    80004bcc:	6afe                	ld	s5,472(sp)
    80004bce:	6b5e                	ld	s6,464(sp)
    80004bd0:	6bbe                	ld	s7,456(sp)
    80004bd2:	6c1e                	ld	s8,448(sp)
    80004bd4:	7cfa                	ld	s9,440(sp)
    80004bd6:	7d5a                	ld	s10,432(sp)
    80004bd8:	b9ed                	j	800048d2 <exec+0x60>
    80004bda:	6b5e                	ld	s6,464(sp)
    80004bdc:	b9dd                	j	800048d2 <exec+0x60>
  sz = sz1;
    80004bde:	e0843983          	ld	s3,-504(s0)
    80004be2:	b595                	j	80004a46 <exec+0x1d4>

0000000080004be4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004be4:	7179                	addi	sp,sp,-48
    80004be6:	f406                	sd	ra,40(sp)
    80004be8:	f022                	sd	s0,32(sp)
    80004bea:	ec26                	sd	s1,24(sp)
    80004bec:	e84a                	sd	s2,16(sp)
    80004bee:	1800                	addi	s0,sp,48
    80004bf0:	892e                	mv	s2,a1
    80004bf2:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004bf4:	fdc40593          	addi	a1,s0,-36
    80004bf8:	f11fd0ef          	jal	80002b08 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004bfc:	fdc42703          	lw	a4,-36(s0)
    80004c00:	47bd                	li	a5,15
    80004c02:	02e7e963          	bltu	a5,a4,80004c34 <argfd+0x50>
    80004c06:	ccffc0ef          	jal	800018d4 <myproc>
    80004c0a:	fdc42703          	lw	a4,-36(s0)
    80004c0e:	01a70793          	addi	a5,a4,26
    80004c12:	078e                	slli	a5,a5,0x3
    80004c14:	953e                	add	a0,a0,a5
    80004c16:	611c                	ld	a5,0(a0)
    80004c18:	c385                	beqz	a5,80004c38 <argfd+0x54>
    return -1;
  if(pfd)
    80004c1a:	00090463          	beqz	s2,80004c22 <argfd+0x3e>
    *pfd = fd;
    80004c1e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004c22:	4501                	li	a0,0
  if(pf)
    80004c24:	c091                	beqz	s1,80004c28 <argfd+0x44>
    *pf = f;
    80004c26:	e09c                	sd	a5,0(s1)
}
    80004c28:	70a2                	ld	ra,40(sp)
    80004c2a:	7402                	ld	s0,32(sp)
    80004c2c:	64e2                	ld	s1,24(sp)
    80004c2e:	6942                	ld	s2,16(sp)
    80004c30:	6145                	addi	sp,sp,48
    80004c32:	8082                	ret
    return -1;
    80004c34:	557d                	li	a0,-1
    80004c36:	bfcd                	j	80004c28 <argfd+0x44>
    80004c38:	557d                	li	a0,-1
    80004c3a:	b7fd                	j	80004c28 <argfd+0x44>

0000000080004c3c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004c3c:	1101                	addi	sp,sp,-32
    80004c3e:	ec06                	sd	ra,24(sp)
    80004c40:	e822                	sd	s0,16(sp)
    80004c42:	e426                	sd	s1,8(sp)
    80004c44:	1000                	addi	s0,sp,32
    80004c46:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004c48:	c8dfc0ef          	jal	800018d4 <myproc>
    80004c4c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004c4e:	0d050793          	addi	a5,a0,208
    80004c52:	4501                	li	a0,0
    80004c54:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004c56:	6398                	ld	a4,0(a5)
    80004c58:	cb19                	beqz	a4,80004c6e <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004c5a:	2505                	addiw	a0,a0,1
    80004c5c:	07a1                	addi	a5,a5,8
    80004c5e:	fed51ce3          	bne	a0,a3,80004c56 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004c62:	557d                	li	a0,-1
}
    80004c64:	60e2                	ld	ra,24(sp)
    80004c66:	6442                	ld	s0,16(sp)
    80004c68:	64a2                	ld	s1,8(sp)
    80004c6a:	6105                	addi	sp,sp,32
    80004c6c:	8082                	ret
      p->ofile[fd] = f;
    80004c6e:	01a50793          	addi	a5,a0,26
    80004c72:	078e                	slli	a5,a5,0x3
    80004c74:	963e                	add	a2,a2,a5
    80004c76:	e204                	sd	s1,0(a2)
      return fd;
    80004c78:	b7f5                	j	80004c64 <fdalloc+0x28>

0000000080004c7a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004c7a:	715d                	addi	sp,sp,-80
    80004c7c:	e486                	sd	ra,72(sp)
    80004c7e:	e0a2                	sd	s0,64(sp)
    80004c80:	fc26                	sd	s1,56(sp)
    80004c82:	f84a                	sd	s2,48(sp)
    80004c84:	f44e                	sd	s3,40(sp)
    80004c86:	ec56                	sd	s5,24(sp)
    80004c88:	e85a                	sd	s6,16(sp)
    80004c8a:	0880                	addi	s0,sp,80
    80004c8c:	8b2e                	mv	s6,a1
    80004c8e:	89b2                	mv	s3,a2
    80004c90:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004c92:	fb040593          	addi	a1,s0,-80
    80004c96:	822ff0ef          	jal	80003cb8 <nameiparent>
    80004c9a:	84aa                	mv	s1,a0
    80004c9c:	10050a63          	beqz	a0,80004db0 <create+0x136>
    return 0;

  ilock(dp);
    80004ca0:	925fe0ef          	jal	800035c4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004ca4:	4601                	li	a2,0
    80004ca6:	fb040593          	addi	a1,s0,-80
    80004caa:	8526                	mv	a0,s1
    80004cac:	d8dfe0ef          	jal	80003a38 <dirlookup>
    80004cb0:	8aaa                	mv	s5,a0
    80004cb2:	c129                	beqz	a0,80004cf4 <create+0x7a>
    iunlockput(dp);
    80004cb4:	8526                	mv	a0,s1
    80004cb6:	b19fe0ef          	jal	800037ce <iunlockput>
    ilock(ip);
    80004cba:	8556                	mv	a0,s5
    80004cbc:	909fe0ef          	jal	800035c4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004cc0:	4789                	li	a5,2
    80004cc2:	02fb1463          	bne	s6,a5,80004cea <create+0x70>
    80004cc6:	044ad783          	lhu	a5,68(s5)
    80004cca:	37f9                	addiw	a5,a5,-2
    80004ccc:	17c2                	slli	a5,a5,0x30
    80004cce:	93c1                	srli	a5,a5,0x30
    80004cd0:	4705                	li	a4,1
    80004cd2:	00f76c63          	bltu	a4,a5,80004cea <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004cd6:	8556                	mv	a0,s5
    80004cd8:	60a6                	ld	ra,72(sp)
    80004cda:	6406                	ld	s0,64(sp)
    80004cdc:	74e2                	ld	s1,56(sp)
    80004cde:	7942                	ld	s2,48(sp)
    80004ce0:	79a2                	ld	s3,40(sp)
    80004ce2:	6ae2                	ld	s5,24(sp)
    80004ce4:	6b42                	ld	s6,16(sp)
    80004ce6:	6161                	addi	sp,sp,80
    80004ce8:	8082                	ret
    iunlockput(ip);
    80004cea:	8556                	mv	a0,s5
    80004cec:	ae3fe0ef          	jal	800037ce <iunlockput>
    return 0;
    80004cf0:	4a81                	li	s5,0
    80004cf2:	b7d5                	j	80004cd6 <create+0x5c>
    80004cf4:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004cf6:	85da                	mv	a1,s6
    80004cf8:	4088                	lw	a0,0(s1)
    80004cfa:	f5afe0ef          	jal	80003454 <ialloc>
    80004cfe:	8a2a                	mv	s4,a0
    80004d00:	cd15                	beqz	a0,80004d3c <create+0xc2>
  ilock(ip);
    80004d02:	8c3fe0ef          	jal	800035c4 <ilock>
  ip->major = major;
    80004d06:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004d0a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004d0e:	4905                	li	s2,1
    80004d10:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004d14:	8552                	mv	a0,s4
    80004d16:	ffafe0ef          	jal	80003510 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004d1a:	032b0763          	beq	s6,s2,80004d48 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004d1e:	004a2603          	lw	a2,4(s4)
    80004d22:	fb040593          	addi	a1,s0,-80
    80004d26:	8526                	mv	a0,s1
    80004d28:	eddfe0ef          	jal	80003c04 <dirlink>
    80004d2c:	06054563          	bltz	a0,80004d96 <create+0x11c>
  iunlockput(dp);
    80004d30:	8526                	mv	a0,s1
    80004d32:	a9dfe0ef          	jal	800037ce <iunlockput>
  return ip;
    80004d36:	8ad2                	mv	s5,s4
    80004d38:	7a02                	ld	s4,32(sp)
    80004d3a:	bf71                	j	80004cd6 <create+0x5c>
    iunlockput(dp);
    80004d3c:	8526                	mv	a0,s1
    80004d3e:	a91fe0ef          	jal	800037ce <iunlockput>
    return 0;
    80004d42:	8ad2                	mv	s5,s4
    80004d44:	7a02                	ld	s4,32(sp)
    80004d46:	bf41                	j	80004cd6 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004d48:	004a2603          	lw	a2,4(s4)
    80004d4c:	00003597          	auipc	a1,0x3
    80004d50:	8d458593          	addi	a1,a1,-1836 # 80007620 <etext+0x620>
    80004d54:	8552                	mv	a0,s4
    80004d56:	eaffe0ef          	jal	80003c04 <dirlink>
    80004d5a:	02054e63          	bltz	a0,80004d96 <create+0x11c>
    80004d5e:	40d0                	lw	a2,4(s1)
    80004d60:	00003597          	auipc	a1,0x3
    80004d64:	8c858593          	addi	a1,a1,-1848 # 80007628 <etext+0x628>
    80004d68:	8552                	mv	a0,s4
    80004d6a:	e9bfe0ef          	jal	80003c04 <dirlink>
    80004d6e:	02054463          	bltz	a0,80004d96 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004d72:	004a2603          	lw	a2,4(s4)
    80004d76:	fb040593          	addi	a1,s0,-80
    80004d7a:	8526                	mv	a0,s1
    80004d7c:	e89fe0ef          	jal	80003c04 <dirlink>
    80004d80:	00054b63          	bltz	a0,80004d96 <create+0x11c>
    dp->nlink++;  // for ".."
    80004d84:	04a4d783          	lhu	a5,74(s1)
    80004d88:	2785                	addiw	a5,a5,1
    80004d8a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004d8e:	8526                	mv	a0,s1
    80004d90:	f80fe0ef          	jal	80003510 <iupdate>
    80004d94:	bf71                	j	80004d30 <create+0xb6>
  ip->nlink = 0;
    80004d96:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004d9a:	8552                	mv	a0,s4
    80004d9c:	f74fe0ef          	jal	80003510 <iupdate>
  iunlockput(ip);
    80004da0:	8552                	mv	a0,s4
    80004da2:	a2dfe0ef          	jal	800037ce <iunlockput>
  iunlockput(dp);
    80004da6:	8526                	mv	a0,s1
    80004da8:	a27fe0ef          	jal	800037ce <iunlockput>
  return 0;
    80004dac:	7a02                	ld	s4,32(sp)
    80004dae:	b725                	j	80004cd6 <create+0x5c>
    return 0;
    80004db0:	8aaa                	mv	s5,a0
    80004db2:	b715                	j	80004cd6 <create+0x5c>

0000000080004db4 <sys_dup>:
{
    80004db4:	7179                	addi	sp,sp,-48
    80004db6:	f406                	sd	ra,40(sp)
    80004db8:	f022                	sd	s0,32(sp)
    80004dba:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004dbc:	fd840613          	addi	a2,s0,-40
    80004dc0:	4581                	li	a1,0
    80004dc2:	4501                	li	a0,0
    80004dc4:	e21ff0ef          	jal	80004be4 <argfd>
    return -1;
    80004dc8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004dca:	02054363          	bltz	a0,80004df0 <sys_dup+0x3c>
    80004dce:	ec26                	sd	s1,24(sp)
    80004dd0:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004dd2:	fd843903          	ld	s2,-40(s0)
    80004dd6:	854a                	mv	a0,s2
    80004dd8:	e65ff0ef          	jal	80004c3c <fdalloc>
    80004ddc:	84aa                	mv	s1,a0
    return -1;
    80004dde:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004de0:	00054d63          	bltz	a0,80004dfa <sys_dup+0x46>
  filedup(f);
    80004de4:	854a                	mv	a0,s2
    80004de6:	c48ff0ef          	jal	8000422e <filedup>
  return fd;
    80004dea:	87a6                	mv	a5,s1
    80004dec:	64e2                	ld	s1,24(sp)
    80004dee:	6942                	ld	s2,16(sp)
}
    80004df0:	853e                	mv	a0,a5
    80004df2:	70a2                	ld	ra,40(sp)
    80004df4:	7402                	ld	s0,32(sp)
    80004df6:	6145                	addi	sp,sp,48
    80004df8:	8082                	ret
    80004dfa:	64e2                	ld	s1,24(sp)
    80004dfc:	6942                	ld	s2,16(sp)
    80004dfe:	bfcd                	j	80004df0 <sys_dup+0x3c>

0000000080004e00 <sys_read>:
{
    80004e00:	7179                	addi	sp,sp,-48
    80004e02:	f406                	sd	ra,40(sp)
    80004e04:	f022                	sd	s0,32(sp)
    80004e06:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e08:	fd840593          	addi	a1,s0,-40
    80004e0c:	4505                	li	a0,1
    80004e0e:	d17fd0ef          	jal	80002b24 <argaddr>
  argint(2, &n);
    80004e12:	fe440593          	addi	a1,s0,-28
    80004e16:	4509                	li	a0,2
    80004e18:	cf1fd0ef          	jal	80002b08 <argint>
  if(argfd(0, 0, &f) < 0)
    80004e1c:	fe840613          	addi	a2,s0,-24
    80004e20:	4581                	li	a1,0
    80004e22:	4501                	li	a0,0
    80004e24:	dc1ff0ef          	jal	80004be4 <argfd>
    80004e28:	87aa                	mv	a5,a0
    return -1;
    80004e2a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e2c:	0007ca63          	bltz	a5,80004e40 <sys_read+0x40>
  return fileread(f, p, n);
    80004e30:	fe442603          	lw	a2,-28(s0)
    80004e34:	fd843583          	ld	a1,-40(s0)
    80004e38:	fe843503          	ld	a0,-24(s0)
    80004e3c:	d58ff0ef          	jal	80004394 <fileread>
}
    80004e40:	70a2                	ld	ra,40(sp)
    80004e42:	7402                	ld	s0,32(sp)
    80004e44:	6145                	addi	sp,sp,48
    80004e46:	8082                	ret

0000000080004e48 <sys_write>:
{
    80004e48:	7179                	addi	sp,sp,-48
    80004e4a:	f406                	sd	ra,40(sp)
    80004e4c:	f022                	sd	s0,32(sp)
    80004e4e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e50:	fd840593          	addi	a1,s0,-40
    80004e54:	4505                	li	a0,1
    80004e56:	ccffd0ef          	jal	80002b24 <argaddr>
  argint(2, &n);
    80004e5a:	fe440593          	addi	a1,s0,-28
    80004e5e:	4509                	li	a0,2
    80004e60:	ca9fd0ef          	jal	80002b08 <argint>
  if(argfd(0, 0, &f) < 0)
    80004e64:	fe840613          	addi	a2,s0,-24
    80004e68:	4581                	li	a1,0
    80004e6a:	4501                	li	a0,0
    80004e6c:	d79ff0ef          	jal	80004be4 <argfd>
    80004e70:	87aa                	mv	a5,a0
    return -1;
    80004e72:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e74:	0007ca63          	bltz	a5,80004e88 <sys_write+0x40>
  return filewrite(f, p, n);
    80004e78:	fe442603          	lw	a2,-28(s0)
    80004e7c:	fd843583          	ld	a1,-40(s0)
    80004e80:	fe843503          	ld	a0,-24(s0)
    80004e84:	dceff0ef          	jal	80004452 <filewrite>
}
    80004e88:	70a2                	ld	ra,40(sp)
    80004e8a:	7402                	ld	s0,32(sp)
    80004e8c:	6145                	addi	sp,sp,48
    80004e8e:	8082                	ret

0000000080004e90 <sys_close>:
{
    80004e90:	1101                	addi	sp,sp,-32
    80004e92:	ec06                	sd	ra,24(sp)
    80004e94:	e822                	sd	s0,16(sp)
    80004e96:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004e98:	fe040613          	addi	a2,s0,-32
    80004e9c:	fec40593          	addi	a1,s0,-20
    80004ea0:	4501                	li	a0,0
    80004ea2:	d43ff0ef          	jal	80004be4 <argfd>
    return -1;
    80004ea6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004ea8:	02054063          	bltz	a0,80004ec8 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004eac:	a29fc0ef          	jal	800018d4 <myproc>
    80004eb0:	fec42783          	lw	a5,-20(s0)
    80004eb4:	07e9                	addi	a5,a5,26
    80004eb6:	078e                	slli	a5,a5,0x3
    80004eb8:	953e                	add	a0,a0,a5
    80004eba:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004ebe:	fe043503          	ld	a0,-32(s0)
    80004ec2:	bb2ff0ef          	jal	80004274 <fileclose>
  return 0;
    80004ec6:	4781                	li	a5,0
}
    80004ec8:	853e                	mv	a0,a5
    80004eca:	60e2                	ld	ra,24(sp)
    80004ecc:	6442                	ld	s0,16(sp)
    80004ece:	6105                	addi	sp,sp,32
    80004ed0:	8082                	ret

0000000080004ed2 <sys_fstat>:
{
    80004ed2:	1101                	addi	sp,sp,-32
    80004ed4:	ec06                	sd	ra,24(sp)
    80004ed6:	e822                	sd	s0,16(sp)
    80004ed8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004eda:	fe040593          	addi	a1,s0,-32
    80004ede:	4505                	li	a0,1
    80004ee0:	c45fd0ef          	jal	80002b24 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004ee4:	fe840613          	addi	a2,s0,-24
    80004ee8:	4581                	li	a1,0
    80004eea:	4501                	li	a0,0
    80004eec:	cf9ff0ef          	jal	80004be4 <argfd>
    80004ef0:	87aa                	mv	a5,a0
    return -1;
    80004ef2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ef4:	0007c863          	bltz	a5,80004f04 <sys_fstat+0x32>
  return filestat(f, st);
    80004ef8:	fe043583          	ld	a1,-32(s0)
    80004efc:	fe843503          	ld	a0,-24(s0)
    80004f00:	c36ff0ef          	jal	80004336 <filestat>
}
    80004f04:	60e2                	ld	ra,24(sp)
    80004f06:	6442                	ld	s0,16(sp)
    80004f08:	6105                	addi	sp,sp,32
    80004f0a:	8082                	ret

0000000080004f0c <sys_link>:
{
    80004f0c:	7169                	addi	sp,sp,-304
    80004f0e:	f606                	sd	ra,296(sp)
    80004f10:	f222                	sd	s0,288(sp)
    80004f12:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f14:	08000613          	li	a2,128
    80004f18:	ed040593          	addi	a1,s0,-304
    80004f1c:	4501                	li	a0,0
    80004f1e:	c23fd0ef          	jal	80002b40 <argstr>
    return -1;
    80004f22:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f24:	0c054e63          	bltz	a0,80005000 <sys_link+0xf4>
    80004f28:	08000613          	li	a2,128
    80004f2c:	f5040593          	addi	a1,s0,-176
    80004f30:	4505                	li	a0,1
    80004f32:	c0ffd0ef          	jal	80002b40 <argstr>
    return -1;
    80004f36:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f38:	0c054463          	bltz	a0,80005000 <sys_link+0xf4>
    80004f3c:	ee26                	sd	s1,280(sp)
  begin_op();
    80004f3e:	f1dfe0ef          	jal	80003e5a <begin_op>
  if((ip = namei(old)) == 0){
    80004f42:	ed040513          	addi	a0,s0,-304
    80004f46:	d59fe0ef          	jal	80003c9e <namei>
    80004f4a:	84aa                	mv	s1,a0
    80004f4c:	c53d                	beqz	a0,80004fba <sys_link+0xae>
  ilock(ip);
    80004f4e:	e76fe0ef          	jal	800035c4 <ilock>
  if(ip->type == T_DIR){
    80004f52:	04449703          	lh	a4,68(s1)
    80004f56:	4785                	li	a5,1
    80004f58:	06f70663          	beq	a4,a5,80004fc4 <sys_link+0xb8>
    80004f5c:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004f5e:	04a4d783          	lhu	a5,74(s1)
    80004f62:	2785                	addiw	a5,a5,1
    80004f64:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f68:	8526                	mv	a0,s1
    80004f6a:	da6fe0ef          	jal	80003510 <iupdate>
  iunlock(ip);
    80004f6e:	8526                	mv	a0,s1
    80004f70:	f02fe0ef          	jal	80003672 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004f74:	fd040593          	addi	a1,s0,-48
    80004f78:	f5040513          	addi	a0,s0,-176
    80004f7c:	d3dfe0ef          	jal	80003cb8 <nameiparent>
    80004f80:	892a                	mv	s2,a0
    80004f82:	cd21                	beqz	a0,80004fda <sys_link+0xce>
  ilock(dp);
    80004f84:	e40fe0ef          	jal	800035c4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004f88:	00092703          	lw	a4,0(s2)
    80004f8c:	409c                	lw	a5,0(s1)
    80004f8e:	04f71363          	bne	a4,a5,80004fd4 <sys_link+0xc8>
    80004f92:	40d0                	lw	a2,4(s1)
    80004f94:	fd040593          	addi	a1,s0,-48
    80004f98:	854a                	mv	a0,s2
    80004f9a:	c6bfe0ef          	jal	80003c04 <dirlink>
    80004f9e:	02054b63          	bltz	a0,80004fd4 <sys_link+0xc8>
  iunlockput(dp);
    80004fa2:	854a                	mv	a0,s2
    80004fa4:	82bfe0ef          	jal	800037ce <iunlockput>
  iput(ip);
    80004fa8:	8526                	mv	a0,s1
    80004faa:	f9cfe0ef          	jal	80003746 <iput>
  end_op();
    80004fae:	f17fe0ef          	jal	80003ec4 <end_op>
  return 0;
    80004fb2:	4781                	li	a5,0
    80004fb4:	64f2                	ld	s1,280(sp)
    80004fb6:	6952                	ld	s2,272(sp)
    80004fb8:	a0a1                	j	80005000 <sys_link+0xf4>
    end_op();
    80004fba:	f0bfe0ef          	jal	80003ec4 <end_op>
    return -1;
    80004fbe:	57fd                	li	a5,-1
    80004fc0:	64f2                	ld	s1,280(sp)
    80004fc2:	a83d                	j	80005000 <sys_link+0xf4>
    iunlockput(ip);
    80004fc4:	8526                	mv	a0,s1
    80004fc6:	809fe0ef          	jal	800037ce <iunlockput>
    end_op();
    80004fca:	efbfe0ef          	jal	80003ec4 <end_op>
    return -1;
    80004fce:	57fd                	li	a5,-1
    80004fd0:	64f2                	ld	s1,280(sp)
    80004fd2:	a03d                	j	80005000 <sys_link+0xf4>
    iunlockput(dp);
    80004fd4:	854a                	mv	a0,s2
    80004fd6:	ff8fe0ef          	jal	800037ce <iunlockput>
  ilock(ip);
    80004fda:	8526                	mv	a0,s1
    80004fdc:	de8fe0ef          	jal	800035c4 <ilock>
  ip->nlink--;
    80004fe0:	04a4d783          	lhu	a5,74(s1)
    80004fe4:	37fd                	addiw	a5,a5,-1
    80004fe6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004fea:	8526                	mv	a0,s1
    80004fec:	d24fe0ef          	jal	80003510 <iupdate>
  iunlockput(ip);
    80004ff0:	8526                	mv	a0,s1
    80004ff2:	fdcfe0ef          	jal	800037ce <iunlockput>
  end_op();
    80004ff6:	ecffe0ef          	jal	80003ec4 <end_op>
  return -1;
    80004ffa:	57fd                	li	a5,-1
    80004ffc:	64f2                	ld	s1,280(sp)
    80004ffe:	6952                	ld	s2,272(sp)
}
    80005000:	853e                	mv	a0,a5
    80005002:	70b2                	ld	ra,296(sp)
    80005004:	7412                	ld	s0,288(sp)
    80005006:	6155                	addi	sp,sp,304
    80005008:	8082                	ret

000000008000500a <sys_unlink>:
{
    8000500a:	7151                	addi	sp,sp,-240
    8000500c:	f586                	sd	ra,232(sp)
    8000500e:	f1a2                	sd	s0,224(sp)
    80005010:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005012:	08000613          	li	a2,128
    80005016:	f3040593          	addi	a1,s0,-208
    8000501a:	4501                	li	a0,0
    8000501c:	b25fd0ef          	jal	80002b40 <argstr>
    80005020:	16054063          	bltz	a0,80005180 <sys_unlink+0x176>
    80005024:	eda6                	sd	s1,216(sp)
  begin_op();
    80005026:	e35fe0ef          	jal	80003e5a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000502a:	fb040593          	addi	a1,s0,-80
    8000502e:	f3040513          	addi	a0,s0,-208
    80005032:	c87fe0ef          	jal	80003cb8 <nameiparent>
    80005036:	84aa                	mv	s1,a0
    80005038:	c945                	beqz	a0,800050e8 <sys_unlink+0xde>
  ilock(dp);
    8000503a:	d8afe0ef          	jal	800035c4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000503e:	00002597          	auipc	a1,0x2
    80005042:	5e258593          	addi	a1,a1,1506 # 80007620 <etext+0x620>
    80005046:	fb040513          	addi	a0,s0,-80
    8000504a:	9d9fe0ef          	jal	80003a22 <namecmp>
    8000504e:	10050e63          	beqz	a0,8000516a <sys_unlink+0x160>
    80005052:	00002597          	auipc	a1,0x2
    80005056:	5d658593          	addi	a1,a1,1494 # 80007628 <etext+0x628>
    8000505a:	fb040513          	addi	a0,s0,-80
    8000505e:	9c5fe0ef          	jal	80003a22 <namecmp>
    80005062:	10050463          	beqz	a0,8000516a <sys_unlink+0x160>
    80005066:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005068:	f2c40613          	addi	a2,s0,-212
    8000506c:	fb040593          	addi	a1,s0,-80
    80005070:	8526                	mv	a0,s1
    80005072:	9c7fe0ef          	jal	80003a38 <dirlookup>
    80005076:	892a                	mv	s2,a0
    80005078:	0e050863          	beqz	a0,80005168 <sys_unlink+0x15e>
  ilock(ip);
    8000507c:	d48fe0ef          	jal	800035c4 <ilock>
  if(ip->nlink < 1)
    80005080:	04a91783          	lh	a5,74(s2)
    80005084:	06f05763          	blez	a5,800050f2 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005088:	04491703          	lh	a4,68(s2)
    8000508c:	4785                	li	a5,1
    8000508e:	06f70963          	beq	a4,a5,80005100 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005092:	4641                	li	a2,16
    80005094:	4581                	li	a1,0
    80005096:	fc040513          	addi	a0,s0,-64
    8000509a:	c2ffb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000509e:	4741                	li	a4,16
    800050a0:	f2c42683          	lw	a3,-212(s0)
    800050a4:	fc040613          	addi	a2,s0,-64
    800050a8:	4581                	li	a1,0
    800050aa:	8526                	mv	a0,s1
    800050ac:	869fe0ef          	jal	80003914 <writei>
    800050b0:	47c1                	li	a5,16
    800050b2:	08f51b63          	bne	a0,a5,80005148 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    800050b6:	04491703          	lh	a4,68(s2)
    800050ba:	4785                	li	a5,1
    800050bc:	08f70d63          	beq	a4,a5,80005156 <sys_unlink+0x14c>
  iunlockput(dp);
    800050c0:	8526                	mv	a0,s1
    800050c2:	f0cfe0ef          	jal	800037ce <iunlockput>
  ip->nlink--;
    800050c6:	04a95783          	lhu	a5,74(s2)
    800050ca:	37fd                	addiw	a5,a5,-1
    800050cc:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800050d0:	854a                	mv	a0,s2
    800050d2:	c3efe0ef          	jal	80003510 <iupdate>
  iunlockput(ip);
    800050d6:	854a                	mv	a0,s2
    800050d8:	ef6fe0ef          	jal	800037ce <iunlockput>
  end_op();
    800050dc:	de9fe0ef          	jal	80003ec4 <end_op>
  return 0;
    800050e0:	4501                	li	a0,0
    800050e2:	64ee                	ld	s1,216(sp)
    800050e4:	694e                	ld	s2,208(sp)
    800050e6:	a849                	j	80005178 <sys_unlink+0x16e>
    end_op();
    800050e8:	dddfe0ef          	jal	80003ec4 <end_op>
    return -1;
    800050ec:	557d                	li	a0,-1
    800050ee:	64ee                	ld	s1,216(sp)
    800050f0:	a061                	j	80005178 <sys_unlink+0x16e>
    800050f2:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800050f4:	00002517          	auipc	a0,0x2
    800050f8:	53c50513          	addi	a0,a0,1340 # 80007630 <etext+0x630>
    800050fc:	e98fb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005100:	04c92703          	lw	a4,76(s2)
    80005104:	02000793          	li	a5,32
    80005108:	f8e7f5e3          	bgeu	a5,a4,80005092 <sys_unlink+0x88>
    8000510c:	e5ce                	sd	s3,200(sp)
    8000510e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005112:	4741                	li	a4,16
    80005114:	86ce                	mv	a3,s3
    80005116:	f1840613          	addi	a2,s0,-232
    8000511a:	4581                	li	a1,0
    8000511c:	854a                	mv	a0,s2
    8000511e:	efafe0ef          	jal	80003818 <readi>
    80005122:	47c1                	li	a5,16
    80005124:	00f51c63          	bne	a0,a5,8000513c <sys_unlink+0x132>
    if(de.inum != 0)
    80005128:	f1845783          	lhu	a5,-232(s0)
    8000512c:	efa1                	bnez	a5,80005184 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000512e:	29c1                	addiw	s3,s3,16
    80005130:	04c92783          	lw	a5,76(s2)
    80005134:	fcf9efe3          	bltu	s3,a5,80005112 <sys_unlink+0x108>
    80005138:	69ae                	ld	s3,200(sp)
    8000513a:	bfa1                	j	80005092 <sys_unlink+0x88>
      panic("isdirempty: readi");
    8000513c:	00002517          	auipc	a0,0x2
    80005140:	50c50513          	addi	a0,a0,1292 # 80007648 <etext+0x648>
    80005144:	e50fb0ef          	jal	80000794 <panic>
    80005148:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    8000514a:	00002517          	auipc	a0,0x2
    8000514e:	51650513          	addi	a0,a0,1302 # 80007660 <etext+0x660>
    80005152:	e42fb0ef          	jal	80000794 <panic>
    dp->nlink--;
    80005156:	04a4d783          	lhu	a5,74(s1)
    8000515a:	37fd                	addiw	a5,a5,-1
    8000515c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005160:	8526                	mv	a0,s1
    80005162:	baefe0ef          	jal	80003510 <iupdate>
    80005166:	bfa9                	j	800050c0 <sys_unlink+0xb6>
    80005168:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000516a:	8526                	mv	a0,s1
    8000516c:	e62fe0ef          	jal	800037ce <iunlockput>
  end_op();
    80005170:	d55fe0ef          	jal	80003ec4 <end_op>
  return -1;
    80005174:	557d                	li	a0,-1
    80005176:	64ee                	ld	s1,216(sp)
}
    80005178:	70ae                	ld	ra,232(sp)
    8000517a:	740e                	ld	s0,224(sp)
    8000517c:	616d                	addi	sp,sp,240
    8000517e:	8082                	ret
    return -1;
    80005180:	557d                	li	a0,-1
    80005182:	bfdd                	j	80005178 <sys_unlink+0x16e>
    iunlockput(ip);
    80005184:	854a                	mv	a0,s2
    80005186:	e48fe0ef          	jal	800037ce <iunlockput>
    goto bad;
    8000518a:	694e                	ld	s2,208(sp)
    8000518c:	69ae                	ld	s3,200(sp)
    8000518e:	bff1                	j	8000516a <sys_unlink+0x160>

0000000080005190 <sys_open>:

uint64
sys_open(void)
{
    80005190:	7131                	addi	sp,sp,-192
    80005192:	fd06                	sd	ra,184(sp)
    80005194:	f922                	sd	s0,176(sp)
    80005196:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005198:	f4c40593          	addi	a1,s0,-180
    8000519c:	4505                	li	a0,1
    8000519e:	96bfd0ef          	jal	80002b08 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800051a2:	08000613          	li	a2,128
    800051a6:	f5040593          	addi	a1,s0,-176
    800051aa:	4501                	li	a0,0
    800051ac:	995fd0ef          	jal	80002b40 <argstr>
    800051b0:	87aa                	mv	a5,a0
    return -1;
    800051b2:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800051b4:	0a07c263          	bltz	a5,80005258 <sys_open+0xc8>
    800051b8:	f526                	sd	s1,168(sp)

  begin_op();
    800051ba:	ca1fe0ef          	jal	80003e5a <begin_op>

  if(omode & O_CREATE){
    800051be:	f4c42783          	lw	a5,-180(s0)
    800051c2:	2007f793          	andi	a5,a5,512
    800051c6:	c3d5                	beqz	a5,8000526a <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800051c8:	4681                	li	a3,0
    800051ca:	4601                	li	a2,0
    800051cc:	4589                	li	a1,2
    800051ce:	f5040513          	addi	a0,s0,-176
    800051d2:	aa9ff0ef          	jal	80004c7a <create>
    800051d6:	84aa                	mv	s1,a0
    if(ip == 0){
    800051d8:	c541                	beqz	a0,80005260 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800051da:	04449703          	lh	a4,68(s1)
    800051de:	478d                	li	a5,3
    800051e0:	00f71763          	bne	a4,a5,800051ee <sys_open+0x5e>
    800051e4:	0464d703          	lhu	a4,70(s1)
    800051e8:	47a5                	li	a5,9
    800051ea:	0ae7ed63          	bltu	a5,a4,800052a4 <sys_open+0x114>
    800051ee:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800051f0:	fe1fe0ef          	jal	800041d0 <filealloc>
    800051f4:	892a                	mv	s2,a0
    800051f6:	c179                	beqz	a0,800052bc <sys_open+0x12c>
    800051f8:	ed4e                	sd	s3,152(sp)
    800051fa:	a43ff0ef          	jal	80004c3c <fdalloc>
    800051fe:	89aa                	mv	s3,a0
    80005200:	0a054a63          	bltz	a0,800052b4 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005204:	04449703          	lh	a4,68(s1)
    80005208:	478d                	li	a5,3
    8000520a:	0cf70263          	beq	a4,a5,800052ce <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000520e:	4789                	li	a5,2
    80005210:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005214:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005218:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000521c:	f4c42783          	lw	a5,-180(s0)
    80005220:	0017c713          	xori	a4,a5,1
    80005224:	8b05                	andi	a4,a4,1
    80005226:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000522a:	0037f713          	andi	a4,a5,3
    8000522e:	00e03733          	snez	a4,a4
    80005232:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005236:	4007f793          	andi	a5,a5,1024
    8000523a:	c791                	beqz	a5,80005246 <sys_open+0xb6>
    8000523c:	04449703          	lh	a4,68(s1)
    80005240:	4789                	li	a5,2
    80005242:	08f70d63          	beq	a4,a5,800052dc <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005246:	8526                	mv	a0,s1
    80005248:	c2afe0ef          	jal	80003672 <iunlock>
  end_op();
    8000524c:	c79fe0ef          	jal	80003ec4 <end_op>

  return fd;
    80005250:	854e                	mv	a0,s3
    80005252:	74aa                	ld	s1,168(sp)
    80005254:	790a                	ld	s2,160(sp)
    80005256:	69ea                	ld	s3,152(sp)
}
    80005258:	70ea                	ld	ra,184(sp)
    8000525a:	744a                	ld	s0,176(sp)
    8000525c:	6129                	addi	sp,sp,192
    8000525e:	8082                	ret
      end_op();
    80005260:	c65fe0ef          	jal	80003ec4 <end_op>
      return -1;
    80005264:	557d                	li	a0,-1
    80005266:	74aa                	ld	s1,168(sp)
    80005268:	bfc5                	j	80005258 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    8000526a:	f5040513          	addi	a0,s0,-176
    8000526e:	a31fe0ef          	jal	80003c9e <namei>
    80005272:	84aa                	mv	s1,a0
    80005274:	c11d                	beqz	a0,8000529a <sys_open+0x10a>
    ilock(ip);
    80005276:	b4efe0ef          	jal	800035c4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000527a:	04449703          	lh	a4,68(s1)
    8000527e:	4785                	li	a5,1
    80005280:	f4f71de3          	bne	a4,a5,800051da <sys_open+0x4a>
    80005284:	f4c42783          	lw	a5,-180(s0)
    80005288:	d3bd                	beqz	a5,800051ee <sys_open+0x5e>
      iunlockput(ip);
    8000528a:	8526                	mv	a0,s1
    8000528c:	d42fe0ef          	jal	800037ce <iunlockput>
      end_op();
    80005290:	c35fe0ef          	jal	80003ec4 <end_op>
      return -1;
    80005294:	557d                	li	a0,-1
    80005296:	74aa                	ld	s1,168(sp)
    80005298:	b7c1                	j	80005258 <sys_open+0xc8>
      end_op();
    8000529a:	c2bfe0ef          	jal	80003ec4 <end_op>
      return -1;
    8000529e:	557d                	li	a0,-1
    800052a0:	74aa                	ld	s1,168(sp)
    800052a2:	bf5d                	j	80005258 <sys_open+0xc8>
    iunlockput(ip);
    800052a4:	8526                	mv	a0,s1
    800052a6:	d28fe0ef          	jal	800037ce <iunlockput>
    end_op();
    800052aa:	c1bfe0ef          	jal	80003ec4 <end_op>
    return -1;
    800052ae:	557d                	li	a0,-1
    800052b0:	74aa                	ld	s1,168(sp)
    800052b2:	b75d                	j	80005258 <sys_open+0xc8>
      fileclose(f);
    800052b4:	854a                	mv	a0,s2
    800052b6:	fbffe0ef          	jal	80004274 <fileclose>
    800052ba:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800052bc:	8526                	mv	a0,s1
    800052be:	d10fe0ef          	jal	800037ce <iunlockput>
    end_op();
    800052c2:	c03fe0ef          	jal	80003ec4 <end_op>
    return -1;
    800052c6:	557d                	li	a0,-1
    800052c8:	74aa                	ld	s1,168(sp)
    800052ca:	790a                	ld	s2,160(sp)
    800052cc:	b771                	j	80005258 <sys_open+0xc8>
    f->type = FD_DEVICE;
    800052ce:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800052d2:	04649783          	lh	a5,70(s1)
    800052d6:	02f91223          	sh	a5,36(s2)
    800052da:	bf3d                	j	80005218 <sys_open+0x88>
    itrunc(ip);
    800052dc:	8526                	mv	a0,s1
    800052de:	bd4fe0ef          	jal	800036b2 <itrunc>
    800052e2:	b795                	j	80005246 <sys_open+0xb6>

00000000800052e4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800052e4:	7175                	addi	sp,sp,-144
    800052e6:	e506                	sd	ra,136(sp)
    800052e8:	e122                	sd	s0,128(sp)
    800052ea:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800052ec:	b6ffe0ef          	jal	80003e5a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800052f0:	08000613          	li	a2,128
    800052f4:	f7040593          	addi	a1,s0,-144
    800052f8:	4501                	li	a0,0
    800052fa:	847fd0ef          	jal	80002b40 <argstr>
    800052fe:	02054363          	bltz	a0,80005324 <sys_mkdir+0x40>
    80005302:	4681                	li	a3,0
    80005304:	4601                	li	a2,0
    80005306:	4585                	li	a1,1
    80005308:	f7040513          	addi	a0,s0,-144
    8000530c:	96fff0ef          	jal	80004c7a <create>
    80005310:	c911                	beqz	a0,80005324 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005312:	cbcfe0ef          	jal	800037ce <iunlockput>
  end_op();
    80005316:	baffe0ef          	jal	80003ec4 <end_op>
  return 0;
    8000531a:	4501                	li	a0,0
}
    8000531c:	60aa                	ld	ra,136(sp)
    8000531e:	640a                	ld	s0,128(sp)
    80005320:	6149                	addi	sp,sp,144
    80005322:	8082                	ret
    end_op();
    80005324:	ba1fe0ef          	jal	80003ec4 <end_op>
    return -1;
    80005328:	557d                	li	a0,-1
    8000532a:	bfcd                	j	8000531c <sys_mkdir+0x38>

000000008000532c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000532c:	7135                	addi	sp,sp,-160
    8000532e:	ed06                	sd	ra,152(sp)
    80005330:	e922                	sd	s0,144(sp)
    80005332:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005334:	b27fe0ef          	jal	80003e5a <begin_op>
  argint(1, &major);
    80005338:	f6c40593          	addi	a1,s0,-148
    8000533c:	4505                	li	a0,1
    8000533e:	fcafd0ef          	jal	80002b08 <argint>
  argint(2, &minor);
    80005342:	f6840593          	addi	a1,s0,-152
    80005346:	4509                	li	a0,2
    80005348:	fc0fd0ef          	jal	80002b08 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000534c:	08000613          	li	a2,128
    80005350:	f7040593          	addi	a1,s0,-144
    80005354:	4501                	li	a0,0
    80005356:	feafd0ef          	jal	80002b40 <argstr>
    8000535a:	02054563          	bltz	a0,80005384 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000535e:	f6841683          	lh	a3,-152(s0)
    80005362:	f6c41603          	lh	a2,-148(s0)
    80005366:	458d                	li	a1,3
    80005368:	f7040513          	addi	a0,s0,-144
    8000536c:	90fff0ef          	jal	80004c7a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005370:	c911                	beqz	a0,80005384 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005372:	c5cfe0ef          	jal	800037ce <iunlockput>
  end_op();
    80005376:	b4ffe0ef          	jal	80003ec4 <end_op>
  return 0;
    8000537a:	4501                	li	a0,0
}
    8000537c:	60ea                	ld	ra,152(sp)
    8000537e:	644a                	ld	s0,144(sp)
    80005380:	610d                	addi	sp,sp,160
    80005382:	8082                	ret
    end_op();
    80005384:	b41fe0ef          	jal	80003ec4 <end_op>
    return -1;
    80005388:	557d                	li	a0,-1
    8000538a:	bfcd                	j	8000537c <sys_mknod+0x50>

000000008000538c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000538c:	7135                	addi	sp,sp,-160
    8000538e:	ed06                	sd	ra,152(sp)
    80005390:	e922                	sd	s0,144(sp)
    80005392:	e14a                	sd	s2,128(sp)
    80005394:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005396:	d3efc0ef          	jal	800018d4 <myproc>
    8000539a:	892a                	mv	s2,a0
  
  begin_op();
    8000539c:	abffe0ef          	jal	80003e5a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800053a0:	08000613          	li	a2,128
    800053a4:	f6040593          	addi	a1,s0,-160
    800053a8:	4501                	li	a0,0
    800053aa:	f96fd0ef          	jal	80002b40 <argstr>
    800053ae:	04054363          	bltz	a0,800053f4 <sys_chdir+0x68>
    800053b2:	e526                	sd	s1,136(sp)
    800053b4:	f6040513          	addi	a0,s0,-160
    800053b8:	8e7fe0ef          	jal	80003c9e <namei>
    800053bc:	84aa                	mv	s1,a0
    800053be:	c915                	beqz	a0,800053f2 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800053c0:	a04fe0ef          	jal	800035c4 <ilock>
  if(ip->type != T_DIR){
    800053c4:	04449703          	lh	a4,68(s1)
    800053c8:	4785                	li	a5,1
    800053ca:	02f71963          	bne	a4,a5,800053fc <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800053ce:	8526                	mv	a0,s1
    800053d0:	aa2fe0ef          	jal	80003672 <iunlock>
  iput(p->cwd);
    800053d4:	15093503          	ld	a0,336(s2)
    800053d8:	b6efe0ef          	jal	80003746 <iput>
  end_op();
    800053dc:	ae9fe0ef          	jal	80003ec4 <end_op>
  p->cwd = ip;
    800053e0:	14993823          	sd	s1,336(s2)
  return 0;
    800053e4:	4501                	li	a0,0
    800053e6:	64aa                	ld	s1,136(sp)
}
    800053e8:	60ea                	ld	ra,152(sp)
    800053ea:	644a                	ld	s0,144(sp)
    800053ec:	690a                	ld	s2,128(sp)
    800053ee:	610d                	addi	sp,sp,160
    800053f0:	8082                	ret
    800053f2:	64aa                	ld	s1,136(sp)
    end_op();
    800053f4:	ad1fe0ef          	jal	80003ec4 <end_op>
    return -1;
    800053f8:	557d                	li	a0,-1
    800053fa:	b7fd                	j	800053e8 <sys_chdir+0x5c>
    iunlockput(ip);
    800053fc:	8526                	mv	a0,s1
    800053fe:	bd0fe0ef          	jal	800037ce <iunlockput>
    end_op();
    80005402:	ac3fe0ef          	jal	80003ec4 <end_op>
    return -1;
    80005406:	557d                	li	a0,-1
    80005408:	64aa                	ld	s1,136(sp)
    8000540a:	bff9                	j	800053e8 <sys_chdir+0x5c>

000000008000540c <sys_exec>:

uint64
sys_exec(void)
{
    8000540c:	7121                	addi	sp,sp,-448
    8000540e:	ff06                	sd	ra,440(sp)
    80005410:	fb22                	sd	s0,432(sp)
    80005412:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005414:	e4840593          	addi	a1,s0,-440
    80005418:	4505                	li	a0,1
    8000541a:	f0afd0ef          	jal	80002b24 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000541e:	08000613          	li	a2,128
    80005422:	f5040593          	addi	a1,s0,-176
    80005426:	4501                	li	a0,0
    80005428:	f18fd0ef          	jal	80002b40 <argstr>
    8000542c:	87aa                	mv	a5,a0
    return -1;
    8000542e:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005430:	0c07c463          	bltz	a5,800054f8 <sys_exec+0xec>
    80005434:	f726                	sd	s1,424(sp)
    80005436:	f34a                	sd	s2,416(sp)
    80005438:	ef4e                	sd	s3,408(sp)
    8000543a:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000543c:	10000613          	li	a2,256
    80005440:	4581                	li	a1,0
    80005442:	e5040513          	addi	a0,s0,-432
    80005446:	883fb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000544a:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000544e:	89a6                	mv	s3,s1
    80005450:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005452:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005456:	00391513          	slli	a0,s2,0x3
    8000545a:	e4040593          	addi	a1,s0,-448
    8000545e:	e4843783          	ld	a5,-440(s0)
    80005462:	953e                	add	a0,a0,a5
    80005464:	e1afd0ef          	jal	80002a7e <fetchaddr>
    80005468:	02054663          	bltz	a0,80005494 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    8000546c:	e4043783          	ld	a5,-448(s0)
    80005470:	c3a9                	beqz	a5,800054b2 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005472:	eb2fb0ef          	jal	80000b24 <kalloc>
    80005476:	85aa                	mv	a1,a0
    80005478:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000547c:	cd01                	beqz	a0,80005494 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000547e:	6605                	lui	a2,0x1
    80005480:	e4043503          	ld	a0,-448(s0)
    80005484:	e44fd0ef          	jal	80002ac8 <fetchstr>
    80005488:	00054663          	bltz	a0,80005494 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    8000548c:	0905                	addi	s2,s2,1
    8000548e:	09a1                	addi	s3,s3,8
    80005490:	fd4913e3          	bne	s2,s4,80005456 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005494:	f5040913          	addi	s2,s0,-176
    80005498:	6088                	ld	a0,0(s1)
    8000549a:	c931                	beqz	a0,800054ee <sys_exec+0xe2>
    kfree(argv[i]);
    8000549c:	da6fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054a0:	04a1                	addi	s1,s1,8
    800054a2:	ff249be3          	bne	s1,s2,80005498 <sys_exec+0x8c>
  return -1;
    800054a6:	557d                	li	a0,-1
    800054a8:	74ba                	ld	s1,424(sp)
    800054aa:	791a                	ld	s2,416(sp)
    800054ac:	69fa                	ld	s3,408(sp)
    800054ae:	6a5a                	ld	s4,400(sp)
    800054b0:	a0a1                	j	800054f8 <sys_exec+0xec>
      argv[i] = 0;
    800054b2:	0009079b          	sext.w	a5,s2
    800054b6:	078e                	slli	a5,a5,0x3
    800054b8:	fd078793          	addi	a5,a5,-48
    800054bc:	97a2                	add	a5,a5,s0
    800054be:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    800054c2:	e5040593          	addi	a1,s0,-432
    800054c6:	f5040513          	addi	a0,s0,-176
    800054ca:	ba8ff0ef          	jal	80004872 <exec>
    800054ce:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054d0:	f5040993          	addi	s3,s0,-176
    800054d4:	6088                	ld	a0,0(s1)
    800054d6:	c511                	beqz	a0,800054e2 <sys_exec+0xd6>
    kfree(argv[i]);
    800054d8:	d6afb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054dc:	04a1                	addi	s1,s1,8
    800054de:	ff349be3          	bne	s1,s3,800054d4 <sys_exec+0xc8>
  return ret;
    800054e2:	854a                	mv	a0,s2
    800054e4:	74ba                	ld	s1,424(sp)
    800054e6:	791a                	ld	s2,416(sp)
    800054e8:	69fa                	ld	s3,408(sp)
    800054ea:	6a5a                	ld	s4,400(sp)
    800054ec:	a031                	j	800054f8 <sys_exec+0xec>
  return -1;
    800054ee:	557d                	li	a0,-1
    800054f0:	74ba                	ld	s1,424(sp)
    800054f2:	791a                	ld	s2,416(sp)
    800054f4:	69fa                	ld	s3,408(sp)
    800054f6:	6a5a                	ld	s4,400(sp)
}
    800054f8:	70fa                	ld	ra,440(sp)
    800054fa:	745a                	ld	s0,432(sp)
    800054fc:	6139                	addi	sp,sp,448
    800054fe:	8082                	ret

0000000080005500 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005500:	7139                	addi	sp,sp,-64
    80005502:	fc06                	sd	ra,56(sp)
    80005504:	f822                	sd	s0,48(sp)
    80005506:	f426                	sd	s1,40(sp)
    80005508:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000550a:	bcafc0ef          	jal	800018d4 <myproc>
    8000550e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005510:	fd840593          	addi	a1,s0,-40
    80005514:	4501                	li	a0,0
    80005516:	e0efd0ef          	jal	80002b24 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000551a:	fc840593          	addi	a1,s0,-56
    8000551e:	fd040513          	addi	a0,s0,-48
    80005522:	85cff0ef          	jal	8000457e <pipealloc>
    return -1;
    80005526:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005528:	0a054463          	bltz	a0,800055d0 <sys_pipe+0xd0>
  fd0 = -1;
    8000552c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005530:	fd043503          	ld	a0,-48(s0)
    80005534:	f08ff0ef          	jal	80004c3c <fdalloc>
    80005538:	fca42223          	sw	a0,-60(s0)
    8000553c:	08054163          	bltz	a0,800055be <sys_pipe+0xbe>
    80005540:	fc843503          	ld	a0,-56(s0)
    80005544:	ef8ff0ef          	jal	80004c3c <fdalloc>
    80005548:	fca42023          	sw	a0,-64(s0)
    8000554c:	06054063          	bltz	a0,800055ac <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005550:	4691                	li	a3,4
    80005552:	fc440613          	addi	a2,s0,-60
    80005556:	fd843583          	ld	a1,-40(s0)
    8000555a:	68a8                	ld	a0,80(s1)
    8000555c:	ff7fb0ef          	jal	80001552 <copyout>
    80005560:	00054e63          	bltz	a0,8000557c <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005564:	4691                	li	a3,4
    80005566:	fc040613          	addi	a2,s0,-64
    8000556a:	fd843583          	ld	a1,-40(s0)
    8000556e:	0591                	addi	a1,a1,4
    80005570:	68a8                	ld	a0,80(s1)
    80005572:	fe1fb0ef          	jal	80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005576:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005578:	04055c63          	bgez	a0,800055d0 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000557c:	fc442783          	lw	a5,-60(s0)
    80005580:	07e9                	addi	a5,a5,26
    80005582:	078e                	slli	a5,a5,0x3
    80005584:	97a6                	add	a5,a5,s1
    80005586:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000558a:	fc042783          	lw	a5,-64(s0)
    8000558e:	07e9                	addi	a5,a5,26
    80005590:	078e                	slli	a5,a5,0x3
    80005592:	94be                	add	s1,s1,a5
    80005594:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005598:	fd043503          	ld	a0,-48(s0)
    8000559c:	cd9fe0ef          	jal	80004274 <fileclose>
    fileclose(wf);
    800055a0:	fc843503          	ld	a0,-56(s0)
    800055a4:	cd1fe0ef          	jal	80004274 <fileclose>
    return -1;
    800055a8:	57fd                	li	a5,-1
    800055aa:	a01d                	j	800055d0 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800055ac:	fc442783          	lw	a5,-60(s0)
    800055b0:	0007c763          	bltz	a5,800055be <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800055b4:	07e9                	addi	a5,a5,26
    800055b6:	078e                	slli	a5,a5,0x3
    800055b8:	97a6                	add	a5,a5,s1
    800055ba:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800055be:	fd043503          	ld	a0,-48(s0)
    800055c2:	cb3fe0ef          	jal	80004274 <fileclose>
    fileclose(wf);
    800055c6:	fc843503          	ld	a0,-56(s0)
    800055ca:	cabfe0ef          	jal	80004274 <fileclose>
    return -1;
    800055ce:	57fd                	li	a5,-1
}
    800055d0:	853e                	mv	a0,a5
    800055d2:	70e2                	ld	ra,56(sp)
    800055d4:	7442                	ld	s0,48(sp)
    800055d6:	74a2                	ld	s1,40(sp)
    800055d8:	6121                	addi	sp,sp,64
    800055da:	8082                	ret
    800055dc:	0000                	unimp
	...

00000000800055e0 <kernelvec>:
    800055e0:	7111                	addi	sp,sp,-256
    800055e2:	e006                	sd	ra,0(sp)
    800055e4:	e40a                	sd	sp,8(sp)
    800055e6:	e80e                	sd	gp,16(sp)
    800055e8:	ec12                	sd	tp,24(sp)
    800055ea:	f016                	sd	t0,32(sp)
    800055ec:	f41a                	sd	t1,40(sp)
    800055ee:	f81e                	sd	t2,48(sp)
    800055f0:	e4aa                	sd	a0,72(sp)
    800055f2:	e8ae                	sd	a1,80(sp)
    800055f4:	ecb2                	sd	a2,88(sp)
    800055f6:	f0b6                	sd	a3,96(sp)
    800055f8:	f4ba                	sd	a4,104(sp)
    800055fa:	f8be                	sd	a5,112(sp)
    800055fc:	fcc2                	sd	a6,120(sp)
    800055fe:	e146                	sd	a7,128(sp)
    80005600:	edf2                	sd	t3,216(sp)
    80005602:	f1f6                	sd	t4,224(sp)
    80005604:	f5fa                	sd	t5,232(sp)
    80005606:	f9fe                	sd	t6,240(sp)
    80005608:	b86fd0ef          	jal	8000298e <kerneltrap>
    8000560c:	6082                	ld	ra,0(sp)
    8000560e:	6122                	ld	sp,8(sp)
    80005610:	61c2                	ld	gp,16(sp)
    80005612:	7282                	ld	t0,32(sp)
    80005614:	7322                	ld	t1,40(sp)
    80005616:	73c2                	ld	t2,48(sp)
    80005618:	6526                	ld	a0,72(sp)
    8000561a:	65c6                	ld	a1,80(sp)
    8000561c:	6666                	ld	a2,88(sp)
    8000561e:	7686                	ld	a3,96(sp)
    80005620:	7726                	ld	a4,104(sp)
    80005622:	77c6                	ld	a5,112(sp)
    80005624:	7866                	ld	a6,120(sp)
    80005626:	688a                	ld	a7,128(sp)
    80005628:	6e6e                	ld	t3,216(sp)
    8000562a:	7e8e                	ld	t4,224(sp)
    8000562c:	7f2e                	ld	t5,232(sp)
    8000562e:	7fce                	ld	t6,240(sp)
    80005630:	6111                	addi	sp,sp,256
    80005632:	10200073          	sret
	...

000000008000563e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000563e:	1141                	addi	sp,sp,-16
    80005640:	e422                	sd	s0,8(sp)
    80005642:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005644:	0c0007b7          	lui	a5,0xc000
    80005648:	4705                	li	a4,1
    8000564a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000564c:	0c0007b7          	lui	a5,0xc000
    80005650:	c3d8                	sw	a4,4(a5)
}
    80005652:	6422                	ld	s0,8(sp)
    80005654:	0141                	addi	sp,sp,16
    80005656:	8082                	ret

0000000080005658 <plicinithart>:

void
plicinithart(void)
{
    80005658:	1141                	addi	sp,sp,-16
    8000565a:	e406                	sd	ra,8(sp)
    8000565c:	e022                	sd	s0,0(sp)
    8000565e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005660:	a48fc0ef          	jal	800018a8 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005664:	0085171b          	slliw	a4,a0,0x8
    80005668:	0c0027b7          	lui	a5,0xc002
    8000566c:	97ba                	add	a5,a5,a4
    8000566e:	40200713          	li	a4,1026
    80005672:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005676:	00d5151b          	slliw	a0,a0,0xd
    8000567a:	0c2017b7          	lui	a5,0xc201
    8000567e:	97aa                	add	a5,a5,a0
    80005680:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005684:	60a2                	ld	ra,8(sp)
    80005686:	6402                	ld	s0,0(sp)
    80005688:	0141                	addi	sp,sp,16
    8000568a:	8082                	ret

000000008000568c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000568c:	1141                	addi	sp,sp,-16
    8000568e:	e406                	sd	ra,8(sp)
    80005690:	e022                	sd	s0,0(sp)
    80005692:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005694:	a14fc0ef          	jal	800018a8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005698:	00d5151b          	slliw	a0,a0,0xd
    8000569c:	0c2017b7          	lui	a5,0xc201
    800056a0:	97aa                	add	a5,a5,a0
  return irq;
}
    800056a2:	43c8                	lw	a0,4(a5)
    800056a4:	60a2                	ld	ra,8(sp)
    800056a6:	6402                	ld	s0,0(sp)
    800056a8:	0141                	addi	sp,sp,16
    800056aa:	8082                	ret

00000000800056ac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800056ac:	1101                	addi	sp,sp,-32
    800056ae:	ec06                	sd	ra,24(sp)
    800056b0:	e822                	sd	s0,16(sp)
    800056b2:	e426                	sd	s1,8(sp)
    800056b4:	1000                	addi	s0,sp,32
    800056b6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800056b8:	9f0fc0ef          	jal	800018a8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800056bc:	00d5151b          	slliw	a0,a0,0xd
    800056c0:	0c2017b7          	lui	a5,0xc201
    800056c4:	97aa                	add	a5,a5,a0
    800056c6:	c3c4                	sw	s1,4(a5)
}
    800056c8:	60e2                	ld	ra,24(sp)
    800056ca:	6442                	ld	s0,16(sp)
    800056cc:	64a2                	ld	s1,8(sp)
    800056ce:	6105                	addi	sp,sp,32
    800056d0:	8082                	ret

00000000800056d2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800056d2:	1141                	addi	sp,sp,-16
    800056d4:	e406                	sd	ra,8(sp)
    800056d6:	e022                	sd	s0,0(sp)
    800056d8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800056da:	479d                	li	a5,7
    800056dc:	04a7ca63          	blt	a5,a0,80005730 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800056e0:	0001d797          	auipc	a5,0x1d
    800056e4:	63078793          	addi	a5,a5,1584 # 80022d10 <disk>
    800056e8:	97aa                	add	a5,a5,a0
    800056ea:	0187c783          	lbu	a5,24(a5)
    800056ee:	e7b9                	bnez	a5,8000573c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800056f0:	00451693          	slli	a3,a0,0x4
    800056f4:	0001d797          	auipc	a5,0x1d
    800056f8:	61c78793          	addi	a5,a5,1564 # 80022d10 <disk>
    800056fc:	6398                	ld	a4,0(a5)
    800056fe:	9736                	add	a4,a4,a3
    80005700:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005704:	6398                	ld	a4,0(a5)
    80005706:	9736                	add	a4,a4,a3
    80005708:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000570c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005710:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005714:	97aa                	add	a5,a5,a0
    80005716:	4705                	li	a4,1
    80005718:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000571c:	0001d517          	auipc	a0,0x1d
    80005720:	60c50513          	addi	a0,a0,1548 # 80022d28 <disk+0x18>
    80005724:	fcafc0ef          	jal	80001eee <wakeup>
}
    80005728:	60a2                	ld	ra,8(sp)
    8000572a:	6402                	ld	s0,0(sp)
    8000572c:	0141                	addi	sp,sp,16
    8000572e:	8082                	ret
    panic("free_desc 1");
    80005730:	00002517          	auipc	a0,0x2
    80005734:	f4050513          	addi	a0,a0,-192 # 80007670 <etext+0x670>
    80005738:	85cfb0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    8000573c:	00002517          	auipc	a0,0x2
    80005740:	f4450513          	addi	a0,a0,-188 # 80007680 <etext+0x680>
    80005744:	850fb0ef          	jal	80000794 <panic>

0000000080005748 <virtio_disk_init>:
{
    80005748:	1101                	addi	sp,sp,-32
    8000574a:	ec06                	sd	ra,24(sp)
    8000574c:	e822                	sd	s0,16(sp)
    8000574e:	e426                	sd	s1,8(sp)
    80005750:	e04a                	sd	s2,0(sp)
    80005752:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005754:	00002597          	auipc	a1,0x2
    80005758:	f3c58593          	addi	a1,a1,-196 # 80007690 <etext+0x690>
    8000575c:	0001d517          	auipc	a0,0x1d
    80005760:	6dc50513          	addi	a0,a0,1756 # 80022e38 <disk+0x128>
    80005764:	c10fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005768:	100017b7          	lui	a5,0x10001
    8000576c:	4398                	lw	a4,0(a5)
    8000576e:	2701                	sext.w	a4,a4
    80005770:	747277b7          	lui	a5,0x74727
    80005774:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005778:	18f71063          	bne	a4,a5,800058f8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000577c:	100017b7          	lui	a5,0x10001
    80005780:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005782:	439c                	lw	a5,0(a5)
    80005784:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005786:	4709                	li	a4,2
    80005788:	16e79863          	bne	a5,a4,800058f8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000578c:	100017b7          	lui	a5,0x10001
    80005790:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005792:	439c                	lw	a5,0(a5)
    80005794:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005796:	16e79163          	bne	a5,a4,800058f8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000579a:	100017b7          	lui	a5,0x10001
    8000579e:	47d8                	lw	a4,12(a5)
    800057a0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800057a2:	554d47b7          	lui	a5,0x554d4
    800057a6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800057aa:	14f71763          	bne	a4,a5,800058f8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800057ae:	100017b7          	lui	a5,0x10001
    800057b2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800057b6:	4705                	li	a4,1
    800057b8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057ba:	470d                	li	a4,3
    800057bc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800057be:	10001737          	lui	a4,0x10001
    800057c2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800057c4:	c7ffe737          	lui	a4,0xc7ffe
    800057c8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb90f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800057cc:	8ef9                	and	a3,a3,a4
    800057ce:	10001737          	lui	a4,0x10001
    800057d2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057d4:	472d                	li	a4,11
    800057d6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057d8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800057dc:	439c                	lw	a5,0(a5)
    800057de:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800057e2:	8ba1                	andi	a5,a5,8
    800057e4:	12078063          	beqz	a5,80005904 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800057e8:	100017b7          	lui	a5,0x10001
    800057ec:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800057f0:	100017b7          	lui	a5,0x10001
    800057f4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800057f8:	439c                	lw	a5,0(a5)
    800057fa:	2781                	sext.w	a5,a5
    800057fc:	10079a63          	bnez	a5,80005910 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005800:	100017b7          	lui	a5,0x10001
    80005804:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005808:	439c                	lw	a5,0(a5)
    8000580a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000580c:	10078863          	beqz	a5,8000591c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005810:	471d                	li	a4,7
    80005812:	10f77b63          	bgeu	a4,a5,80005928 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005816:	b0efb0ef          	jal	80000b24 <kalloc>
    8000581a:	0001d497          	auipc	s1,0x1d
    8000581e:	4f648493          	addi	s1,s1,1270 # 80022d10 <disk>
    80005822:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005824:	b00fb0ef          	jal	80000b24 <kalloc>
    80005828:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000582a:	afafb0ef          	jal	80000b24 <kalloc>
    8000582e:	87aa                	mv	a5,a0
    80005830:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005832:	6088                	ld	a0,0(s1)
    80005834:	10050063          	beqz	a0,80005934 <virtio_disk_init+0x1ec>
    80005838:	0001d717          	auipc	a4,0x1d
    8000583c:	4e073703          	ld	a4,1248(a4) # 80022d18 <disk+0x8>
    80005840:	0e070a63          	beqz	a4,80005934 <virtio_disk_init+0x1ec>
    80005844:	0e078863          	beqz	a5,80005934 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005848:	6605                	lui	a2,0x1
    8000584a:	4581                	li	a1,0
    8000584c:	c7cfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005850:	0001d497          	auipc	s1,0x1d
    80005854:	4c048493          	addi	s1,s1,1216 # 80022d10 <disk>
    80005858:	6605                	lui	a2,0x1
    8000585a:	4581                	li	a1,0
    8000585c:	6488                	ld	a0,8(s1)
    8000585e:	c6afb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005862:	6605                	lui	a2,0x1
    80005864:	4581                	li	a1,0
    80005866:	6888                	ld	a0,16(s1)
    80005868:	c60fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000586c:	100017b7          	lui	a5,0x10001
    80005870:	4721                	li	a4,8
    80005872:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005874:	4098                	lw	a4,0(s1)
    80005876:	100017b7          	lui	a5,0x10001
    8000587a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000587e:	40d8                	lw	a4,4(s1)
    80005880:	100017b7          	lui	a5,0x10001
    80005884:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005888:	649c                	ld	a5,8(s1)
    8000588a:	0007869b          	sext.w	a3,a5
    8000588e:	10001737          	lui	a4,0x10001
    80005892:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005896:	9781                	srai	a5,a5,0x20
    80005898:	10001737          	lui	a4,0x10001
    8000589c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800058a0:	689c                	ld	a5,16(s1)
    800058a2:	0007869b          	sext.w	a3,a5
    800058a6:	10001737          	lui	a4,0x10001
    800058aa:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800058ae:	9781                	srai	a5,a5,0x20
    800058b0:	10001737          	lui	a4,0x10001
    800058b4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800058b8:	10001737          	lui	a4,0x10001
    800058bc:	4785                	li	a5,1
    800058be:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800058c0:	00f48c23          	sb	a5,24(s1)
    800058c4:	00f48ca3          	sb	a5,25(s1)
    800058c8:	00f48d23          	sb	a5,26(s1)
    800058cc:	00f48da3          	sb	a5,27(s1)
    800058d0:	00f48e23          	sb	a5,28(s1)
    800058d4:	00f48ea3          	sb	a5,29(s1)
    800058d8:	00f48f23          	sb	a5,30(s1)
    800058dc:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800058e0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800058e4:	100017b7          	lui	a5,0x10001
    800058e8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800058ec:	60e2                	ld	ra,24(sp)
    800058ee:	6442                	ld	s0,16(sp)
    800058f0:	64a2                	ld	s1,8(sp)
    800058f2:	6902                	ld	s2,0(sp)
    800058f4:	6105                	addi	sp,sp,32
    800058f6:	8082                	ret
    panic("could not find virtio disk");
    800058f8:	00002517          	auipc	a0,0x2
    800058fc:	da850513          	addi	a0,a0,-600 # 800076a0 <etext+0x6a0>
    80005900:	e95fa0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005904:	00002517          	auipc	a0,0x2
    80005908:	dbc50513          	addi	a0,a0,-580 # 800076c0 <etext+0x6c0>
    8000590c:	e89fa0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    80005910:	00002517          	auipc	a0,0x2
    80005914:	dd050513          	addi	a0,a0,-560 # 800076e0 <etext+0x6e0>
    80005918:	e7dfa0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    8000591c:	00002517          	auipc	a0,0x2
    80005920:	de450513          	addi	a0,a0,-540 # 80007700 <etext+0x700>
    80005924:	e71fa0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    80005928:	00002517          	auipc	a0,0x2
    8000592c:	df850513          	addi	a0,a0,-520 # 80007720 <etext+0x720>
    80005930:	e65fa0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    80005934:	00002517          	auipc	a0,0x2
    80005938:	e0c50513          	addi	a0,a0,-500 # 80007740 <etext+0x740>
    8000593c:	e59fa0ef          	jal	80000794 <panic>

0000000080005940 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005940:	7159                	addi	sp,sp,-112
    80005942:	f486                	sd	ra,104(sp)
    80005944:	f0a2                	sd	s0,96(sp)
    80005946:	eca6                	sd	s1,88(sp)
    80005948:	e8ca                	sd	s2,80(sp)
    8000594a:	e4ce                	sd	s3,72(sp)
    8000594c:	e0d2                	sd	s4,64(sp)
    8000594e:	fc56                	sd	s5,56(sp)
    80005950:	f85a                	sd	s6,48(sp)
    80005952:	f45e                	sd	s7,40(sp)
    80005954:	f062                	sd	s8,32(sp)
    80005956:	ec66                	sd	s9,24(sp)
    80005958:	1880                	addi	s0,sp,112
    8000595a:	8a2a                	mv	s4,a0
    8000595c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000595e:	00c52c83          	lw	s9,12(a0)
    80005962:	001c9c9b          	slliw	s9,s9,0x1
    80005966:	1c82                	slli	s9,s9,0x20
    80005968:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000596c:	0001d517          	auipc	a0,0x1d
    80005970:	4cc50513          	addi	a0,a0,1228 # 80022e38 <disk+0x128>
    80005974:	a80fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    80005978:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000597a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000597c:	0001db17          	auipc	s6,0x1d
    80005980:	394b0b13          	addi	s6,s6,916 # 80022d10 <disk>
  for(int i = 0; i < 3; i++){
    80005984:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005986:	0001dc17          	auipc	s8,0x1d
    8000598a:	4b2c0c13          	addi	s8,s8,1202 # 80022e38 <disk+0x128>
    8000598e:	a8b9                	j	800059ec <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005990:	00fb0733          	add	a4,s6,a5
    80005994:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005998:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000599a:	0207c563          	bltz	a5,800059c4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000599e:	2905                	addiw	s2,s2,1
    800059a0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800059a2:	05590963          	beq	s2,s5,800059f4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    800059a6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800059a8:	0001d717          	auipc	a4,0x1d
    800059ac:	36870713          	addi	a4,a4,872 # 80022d10 <disk>
    800059b0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800059b2:	01874683          	lbu	a3,24(a4)
    800059b6:	fee9                	bnez	a3,80005990 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800059b8:	2785                	addiw	a5,a5,1
    800059ba:	0705                	addi	a4,a4,1
    800059bc:	fe979be3          	bne	a5,s1,800059b2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    800059c0:	57fd                	li	a5,-1
    800059c2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800059c4:	01205d63          	blez	s2,800059de <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800059c8:	f9042503          	lw	a0,-112(s0)
    800059cc:	d07ff0ef          	jal	800056d2 <free_desc>
      for(int j = 0; j < i; j++)
    800059d0:	4785                	li	a5,1
    800059d2:	0127d663          	bge	a5,s2,800059de <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800059d6:	f9442503          	lw	a0,-108(s0)
    800059da:	cf9ff0ef          	jal	800056d2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800059de:	85e2                	mv	a1,s8
    800059e0:	0001d517          	auipc	a0,0x1d
    800059e4:	34850513          	addi	a0,a0,840 # 80022d28 <disk+0x18>
    800059e8:	cbafc0ef          	jal	80001ea2 <sleep>
  for(int i = 0; i < 3; i++){
    800059ec:	f9040613          	addi	a2,s0,-112
    800059f0:	894e                	mv	s2,s3
    800059f2:	bf55                	j	800059a6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800059f4:	f9042503          	lw	a0,-112(s0)
    800059f8:	00451693          	slli	a3,a0,0x4

  if(write)
    800059fc:	0001d797          	auipc	a5,0x1d
    80005a00:	31478793          	addi	a5,a5,788 # 80022d10 <disk>
    80005a04:	00a50713          	addi	a4,a0,10
    80005a08:	0712                	slli	a4,a4,0x4
    80005a0a:	973e                	add	a4,a4,a5
    80005a0c:	01703633          	snez	a2,s7
    80005a10:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005a12:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005a16:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005a1a:	6398                	ld	a4,0(a5)
    80005a1c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a1e:	0a868613          	addi	a2,a3,168
    80005a22:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005a24:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005a26:	6390                	ld	a2,0(a5)
    80005a28:	00d605b3          	add	a1,a2,a3
    80005a2c:	4741                	li	a4,16
    80005a2e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005a30:	4805                	li	a6,1
    80005a32:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005a36:	f9442703          	lw	a4,-108(s0)
    80005a3a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005a3e:	0712                	slli	a4,a4,0x4
    80005a40:	963a                	add	a2,a2,a4
    80005a42:	058a0593          	addi	a1,s4,88
    80005a46:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005a48:	0007b883          	ld	a7,0(a5)
    80005a4c:	9746                	add	a4,a4,a7
    80005a4e:	40000613          	li	a2,1024
    80005a52:	c710                	sw	a2,8(a4)
  if(write)
    80005a54:	001bb613          	seqz	a2,s7
    80005a58:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005a5c:	00166613          	ori	a2,a2,1
    80005a60:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005a64:	f9842583          	lw	a1,-104(s0)
    80005a68:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005a6c:	00250613          	addi	a2,a0,2
    80005a70:	0612                	slli	a2,a2,0x4
    80005a72:	963e                	add	a2,a2,a5
    80005a74:	577d                	li	a4,-1
    80005a76:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005a7a:	0592                	slli	a1,a1,0x4
    80005a7c:	98ae                	add	a7,a7,a1
    80005a7e:	03068713          	addi	a4,a3,48
    80005a82:	973e                	add	a4,a4,a5
    80005a84:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005a88:	6398                	ld	a4,0(a5)
    80005a8a:	972e                	add	a4,a4,a1
    80005a8c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005a90:	4689                	li	a3,2
    80005a92:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005a96:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005a9a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005a9e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005aa2:	6794                	ld	a3,8(a5)
    80005aa4:	0026d703          	lhu	a4,2(a3)
    80005aa8:	8b1d                	andi	a4,a4,7
    80005aaa:	0706                	slli	a4,a4,0x1
    80005aac:	96ba                	add	a3,a3,a4
    80005aae:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005ab2:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005ab6:	6798                	ld	a4,8(a5)
    80005ab8:	00275783          	lhu	a5,2(a4)
    80005abc:	2785                	addiw	a5,a5,1
    80005abe:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005ac2:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005ac6:	100017b7          	lui	a5,0x10001
    80005aca:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005ace:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005ad2:	0001d917          	auipc	s2,0x1d
    80005ad6:	36690913          	addi	s2,s2,870 # 80022e38 <disk+0x128>
  while(b->disk == 1) {
    80005ada:	4485                	li	s1,1
    80005adc:	01079a63          	bne	a5,a6,80005af0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005ae0:	85ca                	mv	a1,s2
    80005ae2:	8552                	mv	a0,s4
    80005ae4:	bbefc0ef          	jal	80001ea2 <sleep>
  while(b->disk == 1) {
    80005ae8:	004a2783          	lw	a5,4(s4)
    80005aec:	fe978ae3          	beq	a5,s1,80005ae0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005af0:	f9042903          	lw	s2,-112(s0)
    80005af4:	00290713          	addi	a4,s2,2
    80005af8:	0712                	slli	a4,a4,0x4
    80005afa:	0001d797          	auipc	a5,0x1d
    80005afe:	21678793          	addi	a5,a5,534 # 80022d10 <disk>
    80005b02:	97ba                	add	a5,a5,a4
    80005b04:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005b08:	0001d997          	auipc	s3,0x1d
    80005b0c:	20898993          	addi	s3,s3,520 # 80022d10 <disk>
    80005b10:	00491713          	slli	a4,s2,0x4
    80005b14:	0009b783          	ld	a5,0(s3)
    80005b18:	97ba                	add	a5,a5,a4
    80005b1a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005b1e:	854a                	mv	a0,s2
    80005b20:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005b24:	bafff0ef          	jal	800056d2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005b28:	8885                	andi	s1,s1,1
    80005b2a:	f0fd                	bnez	s1,80005b10 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005b2c:	0001d517          	auipc	a0,0x1d
    80005b30:	30c50513          	addi	a0,a0,780 # 80022e38 <disk+0x128>
    80005b34:	958fb0ef          	jal	80000c8c <release>
}
    80005b38:	70a6                	ld	ra,104(sp)
    80005b3a:	7406                	ld	s0,96(sp)
    80005b3c:	64e6                	ld	s1,88(sp)
    80005b3e:	6946                	ld	s2,80(sp)
    80005b40:	69a6                	ld	s3,72(sp)
    80005b42:	6a06                	ld	s4,64(sp)
    80005b44:	7ae2                	ld	s5,56(sp)
    80005b46:	7b42                	ld	s6,48(sp)
    80005b48:	7ba2                	ld	s7,40(sp)
    80005b4a:	7c02                	ld	s8,32(sp)
    80005b4c:	6ce2                	ld	s9,24(sp)
    80005b4e:	6165                	addi	sp,sp,112
    80005b50:	8082                	ret

0000000080005b52 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005b52:	1101                	addi	sp,sp,-32
    80005b54:	ec06                	sd	ra,24(sp)
    80005b56:	e822                	sd	s0,16(sp)
    80005b58:	e426                	sd	s1,8(sp)
    80005b5a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005b5c:	0001d497          	auipc	s1,0x1d
    80005b60:	1b448493          	addi	s1,s1,436 # 80022d10 <disk>
    80005b64:	0001d517          	auipc	a0,0x1d
    80005b68:	2d450513          	addi	a0,a0,724 # 80022e38 <disk+0x128>
    80005b6c:	888fb0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005b70:	100017b7          	lui	a5,0x10001
    80005b74:	53b8                	lw	a4,96(a5)
    80005b76:	8b0d                	andi	a4,a4,3
    80005b78:	100017b7          	lui	a5,0x10001
    80005b7c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005b7e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005b82:	689c                	ld	a5,16(s1)
    80005b84:	0204d703          	lhu	a4,32(s1)
    80005b88:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005b8c:	04f70663          	beq	a4,a5,80005bd8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005b90:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005b94:	6898                	ld	a4,16(s1)
    80005b96:	0204d783          	lhu	a5,32(s1)
    80005b9a:	8b9d                	andi	a5,a5,7
    80005b9c:	078e                	slli	a5,a5,0x3
    80005b9e:	97ba                	add	a5,a5,a4
    80005ba0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005ba2:	00278713          	addi	a4,a5,2
    80005ba6:	0712                	slli	a4,a4,0x4
    80005ba8:	9726                	add	a4,a4,s1
    80005baa:	01074703          	lbu	a4,16(a4)
    80005bae:	e321                	bnez	a4,80005bee <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005bb0:	0789                	addi	a5,a5,2
    80005bb2:	0792                	slli	a5,a5,0x4
    80005bb4:	97a6                	add	a5,a5,s1
    80005bb6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005bb8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005bbc:	b32fc0ef          	jal	80001eee <wakeup>

    disk.used_idx += 1;
    80005bc0:	0204d783          	lhu	a5,32(s1)
    80005bc4:	2785                	addiw	a5,a5,1
    80005bc6:	17c2                	slli	a5,a5,0x30
    80005bc8:	93c1                	srli	a5,a5,0x30
    80005bca:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005bce:	6898                	ld	a4,16(s1)
    80005bd0:	00275703          	lhu	a4,2(a4)
    80005bd4:	faf71ee3          	bne	a4,a5,80005b90 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005bd8:	0001d517          	auipc	a0,0x1d
    80005bdc:	26050513          	addi	a0,a0,608 # 80022e38 <disk+0x128>
    80005be0:	8acfb0ef          	jal	80000c8c <release>
}
    80005be4:	60e2                	ld	ra,24(sp)
    80005be6:	6442                	ld	s0,16(sp)
    80005be8:	64a2                	ld	s1,8(sp)
    80005bea:	6105                	addi	sp,sp,32
    80005bec:	8082                	ret
      panic("virtio_disk_intr status");
    80005bee:	00002517          	auipc	a0,0x2
    80005bf2:	b6a50513          	addi	a0,a0,-1174 # 80007758 <etext+0x758>
    80005bf6:	b9ffa0ef          	jal	80000794 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
