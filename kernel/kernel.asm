
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	a5010113          	addi	sp,sp,-1456 # 80007a50 <stack0>
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

#define MIE_STIE (1L << 5)

static inline uint64 r_mie() {
  uint64 x;
  asm volatile("csrr %0, mie" : "=r"(x));
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
  return x;
}

static inline void w_mie(uint64 x) {
  asm volatile("csrw mie, %0" : : "r"(x));
    8000002a:	30479073          	csrw	mie,a5
  asm volatile("csrw 0x14d, %0" : : "r"(x));
}

static inline uint64 r_menvcfg() {
  uint64 x;
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4
  return x;
}

static inline void w_menvcfg(uint64 x) {
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    80000038:	30a79073          	csrw	0x30a,a5
  asm volatile("csrw mcounteren, %0" : : "r"(x));
}

static inline uint64 r_mcounteren() {
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r"(x));
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r"(x));
    80000044:	30679073          	csrw	mcounteren,a5
  return x;
}

static inline uint64 r_time() {
  uint64 x;
  asm volatile("csrr %0, time" : "=r"(x));
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
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
  asm volatile("csrr %0, mstatus" : "=r"(x));
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdda7f>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r"(x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r"(x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	e3678793          	addi	a5,a5,-458 # 80000eb6 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r"(x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r"(x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r"(x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r"(x));
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r"(x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r"(x));
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
  asm volatile("mv %0, tp" : "=r"(x));
  return x;
}

static inline void w_tp(uint64 x) {
  asm volatile("mv tp, %0" : : "r"(x));
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
    800000fa:	1ea020ef          	jal	800022e4 <either_copyin>
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
    80000154:	00010517          	auipc	a0,0x10
    80000158:	8fc50513          	addi	a0,a0,-1796 # 8000fa50 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	00010497          	auipc	s1,0x10
    80000164:	8f048493          	addi	s1,s1,-1808 # 8000fa50 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00010917          	auipc	s2,0x10
    8000016c:	98090913          	addi	s2,s2,-1664 # 8000fae8 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	7f0010ef          	jal	80001970 <myproc>
    80000184:	7f3010ef          	jal	80002176 <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	5b1010ef          	jal	80001f3e <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	00010717          	auipc	a4,0x10
    800001a4:	8b070713          	addi	a4,a4,-1872 # 8000fa50 <cons>
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
    800001d2:	0c8020ef          	jal	8000229a <either_copyout>
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
    800001ea:	00010517          	auipc	a0,0x10
    800001ee:	86650513          	addi	a0,a0,-1946 # 8000fa50 <cons>
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
    80000214:	00010717          	auipc	a4,0x10
    80000218:	8cf72a23          	sw	a5,-1836(a4) # 8000fae8 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	00010517          	auipc	a0,0x10
    8000022e:	82650513          	addi	a0,a0,-2010 # 8000fa50 <cons>
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
    80000282:	7d250513          	addi	a0,a0,2002 # 8000fa50 <cons>
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
    800002a0:	08e020ef          	jal	8000232e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	0000f517          	auipc	a0,0xf
    800002a8:	7ac50513          	addi	a0,a0,1964 # 8000fa50 <cons>
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
    800002c6:	78e70713          	addi	a4,a4,1934 # 8000fa50 <cons>
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
    800002ec:	76878793          	addi	a5,a5,1896 # 8000fa50 <cons>
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
    8000031a:	7d27a783          	lw	a5,2002(a5) # 8000fae8 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	0000f717          	auipc	a4,0xf
    80000330:	72470713          	addi	a4,a4,1828 # 8000fa50 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	0000f497          	auipc	s1,0xf
    80000340:	71448493          	addi	s1,s1,1812 # 8000fa50 <cons>
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
    80000382:	6d270713          	addi	a4,a4,1746 # 8000fa50 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	74f72e23          	sw	a5,1884(a4) # 8000faf0 <cons+0xa0>
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
    800003b6:	69e78793          	addi	a5,a5,1694 # 8000fa50 <cons>
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
    800003da:	70c7ab23          	sw	a2,1814(a5) # 8000faec <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	70a50513          	addi	a0,a0,1802 # 8000fae8 <cons+0x98>
    800003e6:	3a5010ef          	jal	80001f8a <wakeup>
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
    80000400:	65450513          	addi	a0,a0,1620 # 8000fa50 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	0001f797          	auipc	a5,0x1f
    80000410:	7dc78793          	addi	a5,a5,2012 # 8001fbe8 <devsw>
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
    8000044a:	46a60613          	addi	a2,a2,1130 # 800078b0 <digits>
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
    800004e4:	6307a783          	lw	a5,1584(a5) # 8000fb10 <pr+0x18>
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
    80000530:	5cc50513          	addi	a0,a0,1484 # 8000faf8 <pr>
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
    800006f0:	1c4b8b93          	addi	s7,s7,452 # 800078b0 <digits>
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
    8000078a:	37250513          	addi	a0,a0,882 # 8000faf8 <pr>
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
    800007a4:	3607a823          	sw	zero,880(a5) # 8000fb10 <pr+0x18>
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
    800007c8:	24f72623          	sw	a5,588(a4) # 80007a10 <panicked>
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
    800007dc:	32048493          	addi	s1,s1,800 # 8000faf8 <pr>
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
    80000844:	2d850513          	addi	a0,a0,728 # 8000fb18 <uart_tx_lock>
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
    80000868:	1ac7a783          	lw	a5,428(a5) # 80007a10 <panicked>
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
    8000089e:	17e7b783          	ld	a5,382(a5) # 80007a18 <uart_tx_r>
    800008a2:	00007717          	auipc	a4,0x7
    800008a6:	17e73703          	ld	a4,382(a4) # 80007a20 <uart_tx_w>
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
    800008cc:	250a8a93          	addi	s5,s5,592 # 8000fb18 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	00007497          	auipc	s1,0x7
    800008d4:	14848493          	addi	s1,s1,328 # 80007a18 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	00007997          	auipc	s3,0x7
    800008e0:	14498993          	addi	s3,s3,324 # 80007a20 <uart_tx_w>
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
    800008fe:	68c010ef          	jal	80001f8a <wakeup>
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
    80000950:	1cc50513          	addi	a0,a0,460 # 8000fb18 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	00007797          	auipc	a5,0x7
    8000095c:	0b87a783          	lw	a5,184(a5) # 80007a10 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	00007717          	auipc	a4,0x7
    80000966:	0be73703          	ld	a4,190(a4) # 80007a20 <uart_tx_w>
    8000096a:	00007797          	auipc	a5,0x7
    8000096e:	0ae7b783          	ld	a5,174(a5) # 80007a18 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	0000f997          	auipc	s3,0xf
    8000097a:	1a298993          	addi	s3,s3,418 # 8000fb18 <uart_tx_lock>
    8000097e:	00007497          	auipc	s1,0x7
    80000982:	09a48493          	addi	s1,s1,154 # 80007a18 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00007917          	auipc	s2,0x7
    8000098a:	09a90913          	addi	s2,s2,154 # 80007a20 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	5a8010ef          	jal	80001f3e <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	0000f497          	auipc	s1,0xf
    800009ac:	17048493          	addi	s1,s1,368 # 8000fb18 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	00007797          	auipc	a5,0x7
    800009c0:	06e7b223          	sd	a4,100(a5) # 80007a20 <uart_tx_w>
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
    80000a24:	0f848493          	addi	s1,s1,248 # 8000fb18 <uart_tx_lock>
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
    80000a56:	00020797          	auipc	a5,0x20
    80000a5a:	32a78793          	addi	a5,a5,810 # 80020d80 <end>
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
    80000a76:	0de90913          	addi	s2,s2,222 # 8000fb50 <kmem>
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
    80000b04:	05050513          	addi	a0,a0,80 # 8000fb50 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00020517          	auipc	a0,0x20
    80000b14:	27050513          	addi	a0,a0,624 # 80020d80 <end>
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
    80000b32:	02248493          	addi	s1,s1,34 # 8000fb50 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	0000f517          	auipc	a0,0xf
    80000b46:	00e50513          	addi	a0,a0,14 # 8000fb50 <kmem>
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
    80000b6a:	fea50513          	addi	a0,a0,-22 # 8000fb50 <kmem>
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
    80000b9e:	5b7000ef          	jal	80001954 <mycpu>
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
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000bbe:	100024f3          	csrr	s1,sstatus
    80000bc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bc6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80000bc8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bcc:	589000ef          	jal	80001954 <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd4:	581000ef          	jal	80001954 <mycpu>
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
    80000be8:	56d000ef          	jal	80001954 <mycpu>
  return (r_sstatus() & SSTATUS_SIE) != 0;
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
    80000c1c:	539000ef          	jal	80001954 <mycpu>
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
    80000c40:	515000ef          	jal	80001954 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000c44:	100027f3          	csrr	a5,sstatus
  return (r_sstatus() & SSTATUS_SIE) != 0;
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
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r"(x));
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
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde281>
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

0000000080000e62 <log_message>:

#include "types.h"
#include "riscv.h"
#include "custom-logger.h"
#include "defs.h"
void log_message(int level, const char *message) {
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e406                	sd	ra,8(sp)
    80000e66:	e022                	sd	s0,0(sp)
    80000e68:	0800                	addi	s0,sp,16
  switch (level) {
    80000e6a:	4785                	li	a5,1
    80000e6c:	02f50063          	beq	a0,a5,80000e8c <log_message+0x2a>
    80000e70:	4789                	li	a5,2
    80000e72:	02f50463          	beq	a0,a5,80000e9a <log_message+0x38>
    80000e76:	e90d                	bnez	a0,80000ea8 <log_message+0x46>
    case INFO:
      printf("[INFO] %s\n", message);
    80000e78:	00006517          	auipc	a0,0x6
    80000e7c:	20050513          	addi	a0,a0,512 # 80007078 <etext+0x78>
    80000e80:	e42ff0ef          	jal	800004c2 <printf>
      printf("[ERROR] %s\n", message);
      break;
    default:
      printf("[UNKNOWN LEVEL] %s\n", message);
  }
}
    80000e84:	60a2                	ld	ra,8(sp)
    80000e86:	6402                	ld	s0,0(sp)
    80000e88:	0141                	addi	sp,sp,16
    80000e8a:	8082                	ret
      printf("[WARNING] %s\n", message);
    80000e8c:	00006517          	auipc	a0,0x6
    80000e90:	1fc50513          	addi	a0,a0,508 # 80007088 <etext+0x88>
    80000e94:	e2eff0ef          	jal	800004c2 <printf>
      break;
    80000e98:	b7f5                	j	80000e84 <log_message+0x22>
      printf("[ERROR] %s\n", message);
    80000e9a:	00006517          	auipc	a0,0x6
    80000e9e:	1fe50513          	addi	a0,a0,510 # 80007098 <etext+0x98>
    80000ea2:	e20ff0ef          	jal	800004c2 <printf>
      break;
    80000ea6:	bff9                	j	80000e84 <log_message+0x22>
      printf("[UNKNOWN LEVEL] %s\n", message);
    80000ea8:	00006517          	auipc	a0,0x6
    80000eac:	20050513          	addi	a0,a0,512 # 800070a8 <etext+0xa8>
    80000eb0:	e12ff0ef          	jal	800004c2 <printf>
}
    80000eb4:	bfc1                	j	80000e84 <log_message+0x22>

0000000080000eb6 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000eb6:	1141                	addi	sp,sp,-16
    80000eb8:	e406                	sd	ra,8(sp)
    80000eba:	e022                	sd	s0,0(sp)
    80000ebc:	0800                	addi	s0,sp,16
      printf("[INFO] %s\n", message);
    80000ebe:	00006597          	auipc	a1,0x6
    80000ec2:	20258593          	addi	a1,a1,514 # 800070c0 <etext+0xc0>
    80000ec6:	00006517          	auipc	a0,0x6
    80000eca:	1b250513          	addi	a0,a0,434 # 80007078 <etext+0x78>
    80000ece:	df4ff0ef          	jal	800004c2 <printf>
      printf("[WARNING] %s\n", message);
    80000ed2:	00006597          	auipc	a1,0x6
    80000ed6:	27658593          	addi	a1,a1,630 # 80007148 <etext+0x148>
    80000eda:	00006517          	auipc	a0,0x6
    80000ede:	1ae50513          	addi	a0,a0,430 # 80007088 <etext+0x88>
    80000ee2:	de0ff0ef          	jal	800004c2 <printf>
      printf("[ERROR] %s\n", message);
    80000ee6:	00006597          	auipc	a1,0x6
    80000eea:	29a58593          	addi	a1,a1,666 # 80007180 <etext+0x180>
    80000eee:	00006517          	auipc	a0,0x6
    80000ef2:	1aa50513          	addi	a0,a0,426 # 80007098 <etext+0x98>
    80000ef6:	dccff0ef          	jal	800004c2 <printf>
  
log_message(INFO, "Welcome to AUT MCS Principles of Operating Systems Course. This message is from a custom logger implemented by 40213025 and 40112026");
log_message(WARN, "This is a test warning message for the custom logger");
log_message(ERROR, "This is a test error message for the custom logger");

  if(cpuid() == 0){
    80000efa:	24b000ef          	jal	80001944 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000efe:	00007717          	auipc	a4,0x7
    80000f02:	b2a70713          	addi	a4,a4,-1238 # 80007a28 <started>
  if(cpuid() == 0){
    80000f06:	c51d                	beqz	a0,80000f34 <main+0x7e>
    while(started == 0)
    80000f08:	431c                	lw	a5,0(a4)
    80000f0a:	2781                	sext.w	a5,a5
    80000f0c:	dff5                	beqz	a5,80000f08 <main+0x52>
      ;
    __sync_synchronize();
    80000f0e:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f12:	233000ef          	jal	80001944 <cpuid>
    80000f16:	85aa                	mv	a1,a0
    80000f18:	00006517          	auipc	a0,0x6
    80000f1c:	2c050513          	addi	a0,a0,704 # 800071d8 <etext+0x1d8>
    80000f20:	da2ff0ef          	jal	800004c2 <printf>
    kvminithart();    // turn on paging
    80000f24:	080000ef          	jal	80000fa4 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f28:	538010ef          	jal	80002460 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f2c:	3bc040ef          	jal	800052e8 <plicinithart>
  }

  scheduler();        
    80000f30:	675000ef          	jal	80001da4 <scheduler>
    consoleinit();
    80000f34:	cb8ff0ef          	jal	800003ec <consoleinit>
    printfinit();
    80000f38:	897ff0ef          	jal	800007ce <printfinit>
    printf("\n");
    80000f3c:	00006517          	auipc	a0,0x6
    80000f40:	27c50513          	addi	a0,a0,636 # 800071b8 <etext+0x1b8>
    80000f44:	d7eff0ef          	jal	800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000f48:	00006517          	auipc	a0,0x6
    80000f4c:	27850513          	addi	a0,a0,632 # 800071c0 <etext+0x1c0>
    80000f50:	d72ff0ef          	jal	800004c2 <printf>
    printf("\n");
    80000f54:	00006517          	auipc	a0,0x6
    80000f58:	26450513          	addi	a0,a0,612 # 800071b8 <etext+0x1b8>
    80000f5c:	d66ff0ef          	jal	800004c2 <printf>
    kinit();         // physical page allocator
    80000f60:	b91ff0ef          	jal	80000af0 <kinit>
    kvminit();       // create kernel page table
    80000f64:	2ca000ef          	jal	8000122e <kvminit>
    kvminithart();   // turn on paging
    80000f68:	03c000ef          	jal	80000fa4 <kvminithart>
    procinit();      // process table
    80000f6c:	123000ef          	jal	8000188e <procinit>
    trapinit();      // trap vectors
    80000f70:	4cc010ef          	jal	8000243c <trapinit>
    trapinithart();  // install kernel trap vector
    80000f74:	4ec010ef          	jal	80002460 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f78:	356040ef          	jal	800052ce <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f7c:	36c040ef          	jal	800052e8 <plicinithart>
    binit();         // buffer cache
    80000f80:	313010ef          	jal	80002a92 <binit>
    iinit();         // inode table
    80000f84:	104020ef          	jal	80003088 <iinit>
    fileinit();      // file table
    80000f88:	6b1020ef          	jal	80003e38 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8c:	44c040ef          	jal	800053d8 <virtio_disk_init>
    userinit();      // first user process
    80000f90:	449000ef          	jal	80001bd8 <userinit>
    __sync_synchronize();
    80000f94:	0ff0000f          	fence
    started = 1;
    80000f98:	4785                	li	a5,1
    80000f9a:	00007717          	auipc	a4,0x7
    80000f9e:	a8f72723          	sw	a5,-1394(a4) # 80007a28 <started>
    80000fa2:	b779                	j	80000f30 <main+0x7a>

0000000080000fa4 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fa4:	1141                	addi	sp,sp,-16
    80000fa6:	e422                	sd	s0,8(sp)
    80000fa8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, ra" : "=r"(x));
  return x;
}

static inline void sfence_vma() {
  asm volatile("sfence.vma zero, zero");
    80000faa:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fae:	00007797          	auipc	a5,0x7
    80000fb2:	a827b783          	ld	a5,-1406(a5) # 80007a30 <kernel_pagetable>
    80000fb6:	83b1                	srli	a5,a5,0xc
    80000fb8:	577d                	li	a4,-1
    80000fba:	177e                	slli	a4,a4,0x3f
    80000fbc:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r"(x));
    80000fbe:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fc2:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fc6:	6422                	ld	s0,8(sp)
    80000fc8:	0141                	addi	sp,sp,16
    80000fca:	8082                	ret

0000000080000fcc <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fcc:	7139                	addi	sp,sp,-64
    80000fce:	fc06                	sd	ra,56(sp)
    80000fd0:	f822                	sd	s0,48(sp)
    80000fd2:	f426                	sd	s1,40(sp)
    80000fd4:	f04a                	sd	s2,32(sp)
    80000fd6:	ec4e                	sd	s3,24(sp)
    80000fd8:	e852                	sd	s4,16(sp)
    80000fda:	e456                	sd	s5,8(sp)
    80000fdc:	e05a                	sd	s6,0(sp)
    80000fde:	0080                	addi	s0,sp,64
    80000fe0:	84aa                	mv	s1,a0
    80000fe2:	89ae                	mv	s3,a1
    80000fe4:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fe6:	57fd                	li	a5,-1
    80000fe8:	83e9                	srli	a5,a5,0x1a
    80000fea:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fec:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fee:	02b7fc63          	bgeu	a5,a1,80001026 <walk+0x5a>
    panic("walk");
    80000ff2:	00006517          	auipc	a0,0x6
    80000ff6:	1fe50513          	addi	a0,a0,510 # 800071f0 <etext+0x1f0>
    80000ffa:	f9aff0ef          	jal	80000794 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ffe:	060a8263          	beqz	s5,80001062 <walk+0x96>
    80001002:	b23ff0ef          	jal	80000b24 <kalloc>
    80001006:	84aa                	mv	s1,a0
    80001008:	c139                	beqz	a0,8000104e <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000100a:	6605                	lui	a2,0x1
    8000100c:	4581                	li	a1,0
    8000100e:	cbbff0ef          	jal	80000cc8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001012:	00c4d793          	srli	a5,s1,0xc
    80001016:	07aa                	slli	a5,a5,0xa
    80001018:	0017e793          	ori	a5,a5,1
    8000101c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001020:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde277>
    80001022:	036a0063          	beq	s4,s6,80001042 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80001026:	0149d933          	srl	s2,s3,s4
    8000102a:	1ff97913          	andi	s2,s2,511
    8000102e:	090e                	slli	s2,s2,0x3
    80001030:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001032:	00093483          	ld	s1,0(s2)
    80001036:	0014f793          	andi	a5,s1,1
    8000103a:	d3f1                	beqz	a5,80000ffe <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000103c:	80a9                	srli	s1,s1,0xa
    8000103e:	04b2                	slli	s1,s1,0xc
    80001040:	b7c5                	j	80001020 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80001042:	00c9d513          	srli	a0,s3,0xc
    80001046:	1ff57513          	andi	a0,a0,511
    8000104a:	050e                	slli	a0,a0,0x3
    8000104c:	9526                	add	a0,a0,s1
}
    8000104e:	70e2                	ld	ra,56(sp)
    80001050:	7442                	ld	s0,48(sp)
    80001052:	74a2                	ld	s1,40(sp)
    80001054:	7902                	ld	s2,32(sp)
    80001056:	69e2                	ld	s3,24(sp)
    80001058:	6a42                	ld	s4,16(sp)
    8000105a:	6aa2                	ld	s5,8(sp)
    8000105c:	6b02                	ld	s6,0(sp)
    8000105e:	6121                	addi	sp,sp,64
    80001060:	8082                	ret
        return 0;
    80001062:	4501                	li	a0,0
    80001064:	b7ed                	j	8000104e <walk+0x82>

0000000080001066 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001066:	57fd                	li	a5,-1
    80001068:	83e9                	srli	a5,a5,0x1a
    8000106a:	00b7f463          	bgeu	a5,a1,80001072 <walkaddr+0xc>
    return 0;
    8000106e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001070:	8082                	ret
{
    80001072:	1141                	addi	sp,sp,-16
    80001074:	e406                	sd	ra,8(sp)
    80001076:	e022                	sd	s0,0(sp)
    80001078:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000107a:	4601                	li	a2,0
    8000107c:	f51ff0ef          	jal	80000fcc <walk>
  if(pte == 0)
    80001080:	c105                	beqz	a0,800010a0 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80001082:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001084:	0117f693          	andi	a3,a5,17
    80001088:	4745                	li	a4,17
    return 0;
    8000108a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000108c:	00e68663          	beq	a3,a4,80001098 <walkaddr+0x32>
}
    80001090:	60a2                	ld	ra,8(sp)
    80001092:	6402                	ld	s0,0(sp)
    80001094:	0141                	addi	sp,sp,16
    80001096:	8082                	ret
  pa = PTE2PA(*pte);
    80001098:	83a9                	srli	a5,a5,0xa
    8000109a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000109e:	bfcd                	j	80001090 <walkaddr+0x2a>
    return 0;
    800010a0:	4501                	li	a0,0
    800010a2:	b7fd                	j	80001090 <walkaddr+0x2a>

00000000800010a4 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010a4:	715d                	addi	sp,sp,-80
    800010a6:	e486                	sd	ra,72(sp)
    800010a8:	e0a2                	sd	s0,64(sp)
    800010aa:	fc26                	sd	s1,56(sp)
    800010ac:	f84a                	sd	s2,48(sp)
    800010ae:	f44e                	sd	s3,40(sp)
    800010b0:	f052                	sd	s4,32(sp)
    800010b2:	ec56                	sd	s5,24(sp)
    800010b4:	e85a                	sd	s6,16(sp)
    800010b6:	e45e                	sd	s7,8(sp)
    800010b8:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800010ba:	03459793          	slli	a5,a1,0x34
    800010be:	e7a9                	bnez	a5,80001108 <mappages+0x64>
    800010c0:	8aaa                	mv	s5,a0
    800010c2:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    800010c4:	03461793          	slli	a5,a2,0x34
    800010c8:	e7b1                	bnez	a5,80001114 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    800010ca:	ca39                	beqz	a2,80001120 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    800010cc:	77fd                	lui	a5,0xfffff
    800010ce:	963e                	add	a2,a2,a5
    800010d0:	00b609b3          	add	s3,a2,a1
  a = va;
    800010d4:	892e                	mv	s2,a1
    800010d6:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010da:	6b85                	lui	s7,0x1
    800010dc:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    800010e0:	4605                	li	a2,1
    800010e2:	85ca                	mv	a1,s2
    800010e4:	8556                	mv	a0,s5
    800010e6:	ee7ff0ef          	jal	80000fcc <walk>
    800010ea:	c539                	beqz	a0,80001138 <mappages+0x94>
    if(*pte & PTE_V)
    800010ec:	611c                	ld	a5,0(a0)
    800010ee:	8b85                	andi	a5,a5,1
    800010f0:	ef95                	bnez	a5,8000112c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010f2:	80b1                	srli	s1,s1,0xc
    800010f4:	04aa                	slli	s1,s1,0xa
    800010f6:	0164e4b3          	or	s1,s1,s6
    800010fa:	0014e493          	ori	s1,s1,1
    800010fe:	e104                	sd	s1,0(a0)
    if(a == last)
    80001100:	05390863          	beq	s2,s3,80001150 <mappages+0xac>
    a += PGSIZE;
    80001104:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001106:	bfd9                	j	800010dc <mappages+0x38>
    panic("mappages: va not aligned");
    80001108:	00006517          	auipc	a0,0x6
    8000110c:	0f050513          	addi	a0,a0,240 # 800071f8 <etext+0x1f8>
    80001110:	e84ff0ef          	jal	80000794 <panic>
    panic("mappages: size not aligned");
    80001114:	00006517          	auipc	a0,0x6
    80001118:	10450513          	addi	a0,a0,260 # 80007218 <etext+0x218>
    8000111c:	e78ff0ef          	jal	80000794 <panic>
    panic("mappages: size");
    80001120:	00006517          	auipc	a0,0x6
    80001124:	11850513          	addi	a0,a0,280 # 80007238 <etext+0x238>
    80001128:	e6cff0ef          	jal	80000794 <panic>
      panic("mappages: remap");
    8000112c:	00006517          	auipc	a0,0x6
    80001130:	11c50513          	addi	a0,a0,284 # 80007248 <etext+0x248>
    80001134:	e60ff0ef          	jal	80000794 <panic>
      return -1;
    80001138:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000113a:	60a6                	ld	ra,72(sp)
    8000113c:	6406                	ld	s0,64(sp)
    8000113e:	74e2                	ld	s1,56(sp)
    80001140:	7942                	ld	s2,48(sp)
    80001142:	79a2                	ld	s3,40(sp)
    80001144:	7a02                	ld	s4,32(sp)
    80001146:	6ae2                	ld	s5,24(sp)
    80001148:	6b42                	ld	s6,16(sp)
    8000114a:	6ba2                	ld	s7,8(sp)
    8000114c:	6161                	addi	sp,sp,80
    8000114e:	8082                	ret
  return 0;
    80001150:	4501                	li	a0,0
    80001152:	b7e5                	j	8000113a <mappages+0x96>

0000000080001154 <kvmmap>:
{
    80001154:	1141                	addi	sp,sp,-16
    80001156:	e406                	sd	ra,8(sp)
    80001158:	e022                	sd	s0,0(sp)
    8000115a:	0800                	addi	s0,sp,16
    8000115c:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000115e:	86b2                	mv	a3,a2
    80001160:	863e                	mv	a2,a5
    80001162:	f43ff0ef          	jal	800010a4 <mappages>
    80001166:	e509                	bnez	a0,80001170 <kvmmap+0x1c>
}
    80001168:	60a2                	ld	ra,8(sp)
    8000116a:	6402                	ld	s0,0(sp)
    8000116c:	0141                	addi	sp,sp,16
    8000116e:	8082                	ret
    panic("kvmmap");
    80001170:	00006517          	auipc	a0,0x6
    80001174:	0e850513          	addi	a0,a0,232 # 80007258 <etext+0x258>
    80001178:	e1cff0ef          	jal	80000794 <panic>

000000008000117c <kvmmake>:
{
    8000117c:	1101                	addi	sp,sp,-32
    8000117e:	ec06                	sd	ra,24(sp)
    80001180:	e822                	sd	s0,16(sp)
    80001182:	e426                	sd	s1,8(sp)
    80001184:	e04a                	sd	s2,0(sp)
    80001186:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001188:	99dff0ef          	jal	80000b24 <kalloc>
    8000118c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000118e:	6605                	lui	a2,0x1
    80001190:	4581                	li	a1,0
    80001192:	b37ff0ef          	jal	80000cc8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001196:	4719                	li	a4,6
    80001198:	6685                	lui	a3,0x1
    8000119a:	10000637          	lui	a2,0x10000
    8000119e:	100005b7          	lui	a1,0x10000
    800011a2:	8526                	mv	a0,s1
    800011a4:	fb1ff0ef          	jal	80001154 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a8:	4719                	li	a4,6
    800011aa:	6685                	lui	a3,0x1
    800011ac:	10001637          	lui	a2,0x10001
    800011b0:	100015b7          	lui	a1,0x10001
    800011b4:	8526                	mv	a0,s1
    800011b6:	f9fff0ef          	jal	80001154 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800011ba:	4719                	li	a4,6
    800011bc:	040006b7          	lui	a3,0x4000
    800011c0:	0c000637          	lui	a2,0xc000
    800011c4:	0c0005b7          	lui	a1,0xc000
    800011c8:	8526                	mv	a0,s1
    800011ca:	f8bff0ef          	jal	80001154 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ce:	00006917          	auipc	s2,0x6
    800011d2:	e3290913          	addi	s2,s2,-462 # 80007000 <etext>
    800011d6:	4729                	li	a4,10
    800011d8:	80006697          	auipc	a3,0x80006
    800011dc:	e2868693          	addi	a3,a3,-472 # 7000 <_entry-0x7fff9000>
    800011e0:	4605                	li	a2,1
    800011e2:	067e                	slli	a2,a2,0x1f
    800011e4:	85b2                	mv	a1,a2
    800011e6:	8526                	mv	a0,s1
    800011e8:	f6dff0ef          	jal	80001154 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011ec:	46c5                	li	a3,17
    800011ee:	06ee                	slli	a3,a3,0x1b
    800011f0:	4719                	li	a4,6
    800011f2:	412686b3          	sub	a3,a3,s2
    800011f6:	864a                	mv	a2,s2
    800011f8:	85ca                	mv	a1,s2
    800011fa:	8526                	mv	a0,s1
    800011fc:	f59ff0ef          	jal	80001154 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001200:	4729                	li	a4,10
    80001202:	6685                	lui	a3,0x1
    80001204:	00005617          	auipc	a2,0x5
    80001208:	dfc60613          	addi	a2,a2,-516 # 80006000 <_trampoline>
    8000120c:	040005b7          	lui	a1,0x4000
    80001210:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001212:	05b2                	slli	a1,a1,0xc
    80001214:	8526                	mv	a0,s1
    80001216:	f3fff0ef          	jal	80001154 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000121a:	8526                	mv	a0,s1
    8000121c:	5da000ef          	jal	800017f6 <proc_mapstacks>
}
    80001220:	8526                	mv	a0,s1
    80001222:	60e2                	ld	ra,24(sp)
    80001224:	6442                	ld	s0,16(sp)
    80001226:	64a2                	ld	s1,8(sp)
    80001228:	6902                	ld	s2,0(sp)
    8000122a:	6105                	addi	sp,sp,32
    8000122c:	8082                	ret

000000008000122e <kvminit>:
{
    8000122e:	1141                	addi	sp,sp,-16
    80001230:	e406                	sd	ra,8(sp)
    80001232:	e022                	sd	s0,0(sp)
    80001234:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001236:	f47ff0ef          	jal	8000117c <kvmmake>
    8000123a:	00006797          	auipc	a5,0x6
    8000123e:	7ea7bb23          	sd	a0,2038(a5) # 80007a30 <kernel_pagetable>
}
    80001242:	60a2                	ld	ra,8(sp)
    80001244:	6402                	ld	s0,0(sp)
    80001246:	0141                	addi	sp,sp,16
    80001248:	8082                	ret

000000008000124a <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000124a:	715d                	addi	sp,sp,-80
    8000124c:	e486                	sd	ra,72(sp)
    8000124e:	e0a2                	sd	s0,64(sp)
    80001250:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001252:	03459793          	slli	a5,a1,0x34
    80001256:	e39d                	bnez	a5,8000127c <uvmunmap+0x32>
    80001258:	f84a                	sd	s2,48(sp)
    8000125a:	f44e                	sd	s3,40(sp)
    8000125c:	f052                	sd	s4,32(sp)
    8000125e:	ec56                	sd	s5,24(sp)
    80001260:	e85a                	sd	s6,16(sp)
    80001262:	e45e                	sd	s7,8(sp)
    80001264:	8a2a                	mv	s4,a0
    80001266:	892e                	mv	s2,a1
    80001268:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000126a:	0632                	slli	a2,a2,0xc
    8000126c:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001270:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001272:	6b05                	lui	s6,0x1
    80001274:	0735ff63          	bgeu	a1,s3,800012f2 <uvmunmap+0xa8>
    80001278:	fc26                	sd	s1,56(sp)
    8000127a:	a0a9                	j	800012c4 <uvmunmap+0x7a>
    8000127c:	fc26                	sd	s1,56(sp)
    8000127e:	f84a                	sd	s2,48(sp)
    80001280:	f44e                	sd	s3,40(sp)
    80001282:	f052                	sd	s4,32(sp)
    80001284:	ec56                	sd	s5,24(sp)
    80001286:	e85a                	sd	s6,16(sp)
    80001288:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    8000128a:	00006517          	auipc	a0,0x6
    8000128e:	fd650513          	addi	a0,a0,-42 # 80007260 <etext+0x260>
    80001292:	d02ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: walk");
    80001296:	00006517          	auipc	a0,0x6
    8000129a:	fe250513          	addi	a0,a0,-30 # 80007278 <etext+0x278>
    8000129e:	cf6ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not mapped");
    800012a2:	00006517          	auipc	a0,0x6
    800012a6:	fe650513          	addi	a0,a0,-26 # 80007288 <etext+0x288>
    800012aa:	ceaff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not a leaf");
    800012ae:	00006517          	auipc	a0,0x6
    800012b2:	ff250513          	addi	a0,a0,-14 # 800072a0 <etext+0x2a0>
    800012b6:	cdeff0ef          	jal	80000794 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    800012ba:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012be:	995a                	add	s2,s2,s6
    800012c0:	03397863          	bgeu	s2,s3,800012f0 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012c4:	4601                	li	a2,0
    800012c6:	85ca                	mv	a1,s2
    800012c8:	8552                	mv	a0,s4
    800012ca:	d03ff0ef          	jal	80000fcc <walk>
    800012ce:	84aa                	mv	s1,a0
    800012d0:	d179                	beqz	a0,80001296 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    800012d2:	6108                	ld	a0,0(a0)
    800012d4:	00157793          	andi	a5,a0,1
    800012d8:	d7e9                	beqz	a5,800012a2 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    800012da:	3ff57793          	andi	a5,a0,1023
    800012de:	fd7788e3          	beq	a5,s7,800012ae <uvmunmap+0x64>
    if(do_free){
    800012e2:	fc0a8ce3          	beqz	s5,800012ba <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    800012e6:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800012e8:	0532                	slli	a0,a0,0xc
    800012ea:	f58ff0ef          	jal	80000a42 <kfree>
    800012ee:	b7f1                	j	800012ba <uvmunmap+0x70>
    800012f0:	74e2                	ld	s1,56(sp)
    800012f2:	7942                	ld	s2,48(sp)
    800012f4:	79a2                	ld	s3,40(sp)
    800012f6:	7a02                	ld	s4,32(sp)
    800012f8:	6ae2                	ld	s5,24(sp)
    800012fa:	6b42                	ld	s6,16(sp)
    800012fc:	6ba2                	ld	s7,8(sp)
  }
}
    800012fe:	60a6                	ld	ra,72(sp)
    80001300:	6406                	ld	s0,64(sp)
    80001302:	6161                	addi	sp,sp,80
    80001304:	8082                	ret

0000000080001306 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001306:	1101                	addi	sp,sp,-32
    80001308:	ec06                	sd	ra,24(sp)
    8000130a:	e822                	sd	s0,16(sp)
    8000130c:	e426                	sd	s1,8(sp)
    8000130e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001310:	815ff0ef          	jal	80000b24 <kalloc>
    80001314:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001316:	c509                	beqz	a0,80001320 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001318:	6605                	lui	a2,0x1
    8000131a:	4581                	li	a1,0
    8000131c:	9adff0ef          	jal	80000cc8 <memset>
  return pagetable;
}
    80001320:	8526                	mv	a0,s1
    80001322:	60e2                	ld	ra,24(sp)
    80001324:	6442                	ld	s0,16(sp)
    80001326:	64a2                	ld	s1,8(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret

000000008000132c <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000132c:	7179                	addi	sp,sp,-48
    8000132e:	f406                	sd	ra,40(sp)
    80001330:	f022                	sd	s0,32(sp)
    80001332:	ec26                	sd	s1,24(sp)
    80001334:	e84a                	sd	s2,16(sp)
    80001336:	e44e                	sd	s3,8(sp)
    80001338:	e052                	sd	s4,0(sp)
    8000133a:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000133c:	6785                	lui	a5,0x1
    8000133e:	04f67063          	bgeu	a2,a5,8000137e <uvmfirst+0x52>
    80001342:	8a2a                	mv	s4,a0
    80001344:	89ae                	mv	s3,a1
    80001346:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001348:	fdcff0ef          	jal	80000b24 <kalloc>
    8000134c:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000134e:	6605                	lui	a2,0x1
    80001350:	4581                	li	a1,0
    80001352:	977ff0ef          	jal	80000cc8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001356:	4779                	li	a4,30
    80001358:	86ca                	mv	a3,s2
    8000135a:	6605                	lui	a2,0x1
    8000135c:	4581                	li	a1,0
    8000135e:	8552                	mv	a0,s4
    80001360:	d45ff0ef          	jal	800010a4 <mappages>
  memmove(mem, src, sz);
    80001364:	8626                	mv	a2,s1
    80001366:	85ce                	mv	a1,s3
    80001368:	854a                	mv	a0,s2
    8000136a:	9bbff0ef          	jal	80000d24 <memmove>
}
    8000136e:	70a2                	ld	ra,40(sp)
    80001370:	7402                	ld	s0,32(sp)
    80001372:	64e2                	ld	s1,24(sp)
    80001374:	6942                	ld	s2,16(sp)
    80001376:	69a2                	ld	s3,8(sp)
    80001378:	6a02                	ld	s4,0(sp)
    8000137a:	6145                	addi	sp,sp,48
    8000137c:	8082                	ret
    panic("uvmfirst: more than a page");
    8000137e:	00006517          	auipc	a0,0x6
    80001382:	f3a50513          	addi	a0,a0,-198 # 800072b8 <etext+0x2b8>
    80001386:	c0eff0ef          	jal	80000794 <panic>

000000008000138a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000138a:	1101                	addi	sp,sp,-32
    8000138c:	ec06                	sd	ra,24(sp)
    8000138e:	e822                	sd	s0,16(sp)
    80001390:	e426                	sd	s1,8(sp)
    80001392:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001394:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001396:	00b67d63          	bgeu	a2,a1,800013b0 <uvmdealloc+0x26>
    8000139a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000139c:	6785                	lui	a5,0x1
    8000139e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013a0:	00f60733          	add	a4,a2,a5
    800013a4:	76fd                	lui	a3,0xfffff
    800013a6:	8f75                	and	a4,a4,a3
    800013a8:	97ae                	add	a5,a5,a1
    800013aa:	8ff5                	and	a5,a5,a3
    800013ac:	00f76863          	bltu	a4,a5,800013bc <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013b0:	8526                	mv	a0,s1
    800013b2:	60e2                	ld	ra,24(sp)
    800013b4:	6442                	ld	s0,16(sp)
    800013b6:	64a2                	ld	s1,8(sp)
    800013b8:	6105                	addi	sp,sp,32
    800013ba:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013bc:	8f99                	sub	a5,a5,a4
    800013be:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013c0:	4685                	li	a3,1
    800013c2:	0007861b          	sext.w	a2,a5
    800013c6:	85ba                	mv	a1,a4
    800013c8:	e83ff0ef          	jal	8000124a <uvmunmap>
    800013cc:	b7d5                	j	800013b0 <uvmdealloc+0x26>

00000000800013ce <uvmalloc>:
  if(newsz < oldsz)
    800013ce:	08b66f63          	bltu	a2,a1,8000146c <uvmalloc+0x9e>
{
    800013d2:	7139                	addi	sp,sp,-64
    800013d4:	fc06                	sd	ra,56(sp)
    800013d6:	f822                	sd	s0,48(sp)
    800013d8:	ec4e                	sd	s3,24(sp)
    800013da:	e852                	sd	s4,16(sp)
    800013dc:	e456                	sd	s5,8(sp)
    800013de:	0080                	addi	s0,sp,64
    800013e0:	8aaa                	mv	s5,a0
    800013e2:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800013e4:	6785                	lui	a5,0x1
    800013e6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013e8:	95be                	add	a1,a1,a5
    800013ea:	77fd                	lui	a5,0xfffff
    800013ec:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013f0:	08c9f063          	bgeu	s3,a2,80001470 <uvmalloc+0xa2>
    800013f4:	f426                	sd	s1,40(sp)
    800013f6:	f04a                	sd	s2,32(sp)
    800013f8:	e05a                	sd	s6,0(sp)
    800013fa:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013fc:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001400:	f24ff0ef          	jal	80000b24 <kalloc>
    80001404:	84aa                	mv	s1,a0
    if(mem == 0){
    80001406:	c515                	beqz	a0,80001432 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001408:	6605                	lui	a2,0x1
    8000140a:	4581                	li	a1,0
    8000140c:	8bdff0ef          	jal	80000cc8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001410:	875a                	mv	a4,s6
    80001412:	86a6                	mv	a3,s1
    80001414:	6605                	lui	a2,0x1
    80001416:	85ca                	mv	a1,s2
    80001418:	8556                	mv	a0,s5
    8000141a:	c8bff0ef          	jal	800010a4 <mappages>
    8000141e:	e915                	bnez	a0,80001452 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001420:	6785                	lui	a5,0x1
    80001422:	993e                	add	s2,s2,a5
    80001424:	fd496ee3          	bltu	s2,s4,80001400 <uvmalloc+0x32>
  return newsz;
    80001428:	8552                	mv	a0,s4
    8000142a:	74a2                	ld	s1,40(sp)
    8000142c:	7902                	ld	s2,32(sp)
    8000142e:	6b02                	ld	s6,0(sp)
    80001430:	a811                	j	80001444 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    80001432:	864e                	mv	a2,s3
    80001434:	85ca                	mv	a1,s2
    80001436:	8556                	mv	a0,s5
    80001438:	f53ff0ef          	jal	8000138a <uvmdealloc>
      return 0;
    8000143c:	4501                	li	a0,0
    8000143e:	74a2                	ld	s1,40(sp)
    80001440:	7902                	ld	s2,32(sp)
    80001442:	6b02                	ld	s6,0(sp)
}
    80001444:	70e2                	ld	ra,56(sp)
    80001446:	7442                	ld	s0,48(sp)
    80001448:	69e2                	ld	s3,24(sp)
    8000144a:	6a42                	ld	s4,16(sp)
    8000144c:	6aa2                	ld	s5,8(sp)
    8000144e:	6121                	addi	sp,sp,64
    80001450:	8082                	ret
      kfree(mem);
    80001452:	8526                	mv	a0,s1
    80001454:	deeff0ef          	jal	80000a42 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001458:	864e                	mv	a2,s3
    8000145a:	85ca                	mv	a1,s2
    8000145c:	8556                	mv	a0,s5
    8000145e:	f2dff0ef          	jal	8000138a <uvmdealloc>
      return 0;
    80001462:	4501                	li	a0,0
    80001464:	74a2                	ld	s1,40(sp)
    80001466:	7902                	ld	s2,32(sp)
    80001468:	6b02                	ld	s6,0(sp)
    8000146a:	bfe9                	j	80001444 <uvmalloc+0x76>
    return oldsz;
    8000146c:	852e                	mv	a0,a1
}
    8000146e:	8082                	ret
  return newsz;
    80001470:	8532                	mv	a0,a2
    80001472:	bfc9                	j	80001444 <uvmalloc+0x76>

0000000080001474 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001474:	7179                	addi	sp,sp,-48
    80001476:	f406                	sd	ra,40(sp)
    80001478:	f022                	sd	s0,32(sp)
    8000147a:	ec26                	sd	s1,24(sp)
    8000147c:	e84a                	sd	s2,16(sp)
    8000147e:	e44e                	sd	s3,8(sp)
    80001480:	e052                	sd	s4,0(sp)
    80001482:	1800                	addi	s0,sp,48
    80001484:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001486:	84aa                	mv	s1,a0
    80001488:	6905                	lui	s2,0x1
    8000148a:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000148c:	4985                	li	s3,1
    8000148e:	a819                	j	800014a4 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001490:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001492:	00c79513          	slli	a0,a5,0xc
    80001496:	fdfff0ef          	jal	80001474 <freewalk>
      pagetable[i] = 0;
    8000149a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000149e:	04a1                	addi	s1,s1,8
    800014a0:	01248f63          	beq	s1,s2,800014be <freewalk+0x4a>
    pte_t pte = pagetable[i];
    800014a4:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014a6:	00f7f713          	andi	a4,a5,15
    800014aa:	ff3703e3          	beq	a4,s3,80001490 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014ae:	8b85                	andi	a5,a5,1
    800014b0:	d7fd                	beqz	a5,8000149e <freewalk+0x2a>
      panic("freewalk: leaf");
    800014b2:	00006517          	auipc	a0,0x6
    800014b6:	e2650513          	addi	a0,a0,-474 # 800072d8 <etext+0x2d8>
    800014ba:	adaff0ef          	jal	80000794 <panic>
    }
  }
  kfree((void*)pagetable);
    800014be:	8552                	mv	a0,s4
    800014c0:	d82ff0ef          	jal	80000a42 <kfree>
}
    800014c4:	70a2                	ld	ra,40(sp)
    800014c6:	7402                	ld	s0,32(sp)
    800014c8:	64e2                	ld	s1,24(sp)
    800014ca:	6942                	ld	s2,16(sp)
    800014cc:	69a2                	ld	s3,8(sp)
    800014ce:	6a02                	ld	s4,0(sp)
    800014d0:	6145                	addi	sp,sp,48
    800014d2:	8082                	ret

00000000800014d4 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800014d4:	1101                	addi	sp,sp,-32
    800014d6:	ec06                	sd	ra,24(sp)
    800014d8:	e822                	sd	s0,16(sp)
    800014da:	e426                	sd	s1,8(sp)
    800014dc:	1000                	addi	s0,sp,32
    800014de:	84aa                	mv	s1,a0
  if(sz > 0)
    800014e0:	e989                	bnez	a1,800014f2 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800014e2:	8526                	mv	a0,s1
    800014e4:	f91ff0ef          	jal	80001474 <freewalk>
}
    800014e8:	60e2                	ld	ra,24(sp)
    800014ea:	6442                	ld	s0,16(sp)
    800014ec:	64a2                	ld	s1,8(sp)
    800014ee:	6105                	addi	sp,sp,32
    800014f0:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800014f2:	6785                	lui	a5,0x1
    800014f4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014f6:	95be                	add	a1,a1,a5
    800014f8:	4685                	li	a3,1
    800014fa:	00c5d613          	srli	a2,a1,0xc
    800014fe:	4581                	li	a1,0
    80001500:	d4bff0ef          	jal	8000124a <uvmunmap>
    80001504:	bff9                	j	800014e2 <uvmfree+0xe>

0000000080001506 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001506:	c65d                	beqz	a2,800015b4 <uvmcopy+0xae>
{
    80001508:	715d                	addi	sp,sp,-80
    8000150a:	e486                	sd	ra,72(sp)
    8000150c:	e0a2                	sd	s0,64(sp)
    8000150e:	fc26                	sd	s1,56(sp)
    80001510:	f84a                	sd	s2,48(sp)
    80001512:	f44e                	sd	s3,40(sp)
    80001514:	f052                	sd	s4,32(sp)
    80001516:	ec56                	sd	s5,24(sp)
    80001518:	e85a                	sd	s6,16(sp)
    8000151a:	e45e                	sd	s7,8(sp)
    8000151c:	0880                	addi	s0,sp,80
    8000151e:	8b2a                	mv	s6,a0
    80001520:	8aae                	mv	s5,a1
    80001522:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001524:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001526:	4601                	li	a2,0
    80001528:	85ce                	mv	a1,s3
    8000152a:	855a                	mv	a0,s6
    8000152c:	aa1ff0ef          	jal	80000fcc <walk>
    80001530:	c121                	beqz	a0,80001570 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001532:	6118                	ld	a4,0(a0)
    80001534:	00177793          	andi	a5,a4,1
    80001538:	c3b1                	beqz	a5,8000157c <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000153a:	00a75593          	srli	a1,a4,0xa
    8000153e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001542:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001546:	ddeff0ef          	jal	80000b24 <kalloc>
    8000154a:	892a                	mv	s2,a0
    8000154c:	c129                	beqz	a0,8000158e <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000154e:	6605                	lui	a2,0x1
    80001550:	85de                	mv	a1,s7
    80001552:	fd2ff0ef          	jal	80000d24 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001556:	8726                	mv	a4,s1
    80001558:	86ca                	mv	a3,s2
    8000155a:	6605                	lui	a2,0x1
    8000155c:	85ce                	mv	a1,s3
    8000155e:	8556                	mv	a0,s5
    80001560:	b45ff0ef          	jal	800010a4 <mappages>
    80001564:	e115                	bnez	a0,80001588 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    80001566:	6785                	lui	a5,0x1
    80001568:	99be                	add	s3,s3,a5
    8000156a:	fb49eee3          	bltu	s3,s4,80001526 <uvmcopy+0x20>
    8000156e:	a805                	j	8000159e <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    80001570:	00006517          	auipc	a0,0x6
    80001574:	d7850513          	addi	a0,a0,-648 # 800072e8 <etext+0x2e8>
    80001578:	a1cff0ef          	jal	80000794 <panic>
      panic("uvmcopy: page not present");
    8000157c:	00006517          	auipc	a0,0x6
    80001580:	d8c50513          	addi	a0,a0,-628 # 80007308 <etext+0x308>
    80001584:	a10ff0ef          	jal	80000794 <panic>
      kfree(mem);
    80001588:	854a                	mv	a0,s2
    8000158a:	cb8ff0ef          	jal	80000a42 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000158e:	4685                	li	a3,1
    80001590:	00c9d613          	srli	a2,s3,0xc
    80001594:	4581                	li	a1,0
    80001596:	8556                	mv	a0,s5
    80001598:	cb3ff0ef          	jal	8000124a <uvmunmap>
  return -1;
    8000159c:	557d                	li	a0,-1
}
    8000159e:	60a6                	ld	ra,72(sp)
    800015a0:	6406                	ld	s0,64(sp)
    800015a2:	74e2                	ld	s1,56(sp)
    800015a4:	7942                	ld	s2,48(sp)
    800015a6:	79a2                	ld	s3,40(sp)
    800015a8:	7a02                	ld	s4,32(sp)
    800015aa:	6ae2                	ld	s5,24(sp)
    800015ac:	6b42                	ld	s6,16(sp)
    800015ae:	6ba2                	ld	s7,8(sp)
    800015b0:	6161                	addi	sp,sp,80
    800015b2:	8082                	ret
  return 0;
    800015b4:	4501                	li	a0,0
}
    800015b6:	8082                	ret

00000000800015b8 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800015b8:	1141                	addi	sp,sp,-16
    800015ba:	e406                	sd	ra,8(sp)
    800015bc:	e022                	sd	s0,0(sp)
    800015be:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800015c0:	4601                	li	a2,0
    800015c2:	a0bff0ef          	jal	80000fcc <walk>
  if(pte == 0)
    800015c6:	c901                	beqz	a0,800015d6 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800015c8:	611c                	ld	a5,0(a0)
    800015ca:	9bbd                	andi	a5,a5,-17
    800015cc:	e11c                	sd	a5,0(a0)
}
    800015ce:	60a2                	ld	ra,8(sp)
    800015d0:	6402                	ld	s0,0(sp)
    800015d2:	0141                	addi	sp,sp,16
    800015d4:	8082                	ret
    panic("uvmclear");
    800015d6:	00006517          	auipc	a0,0x6
    800015da:	d5250513          	addi	a0,a0,-686 # 80007328 <etext+0x328>
    800015de:	9b6ff0ef          	jal	80000794 <panic>

00000000800015e2 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    800015e2:	cad1                	beqz	a3,80001676 <copyout+0x94>
{
    800015e4:	711d                	addi	sp,sp,-96
    800015e6:	ec86                	sd	ra,88(sp)
    800015e8:	e8a2                	sd	s0,80(sp)
    800015ea:	e4a6                	sd	s1,72(sp)
    800015ec:	fc4e                	sd	s3,56(sp)
    800015ee:	f456                	sd	s5,40(sp)
    800015f0:	f05a                	sd	s6,32(sp)
    800015f2:	ec5e                	sd	s7,24(sp)
    800015f4:	1080                	addi	s0,sp,96
    800015f6:	8baa                	mv	s7,a0
    800015f8:	8aae                	mv	s5,a1
    800015fa:	8b32                	mv	s6,a2
    800015fc:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800015fe:	74fd                	lui	s1,0xfffff
    80001600:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001602:	57fd                	li	a5,-1
    80001604:	83e9                	srli	a5,a5,0x1a
    80001606:	0697ea63          	bltu	a5,s1,8000167a <copyout+0x98>
    8000160a:	e0ca                	sd	s2,64(sp)
    8000160c:	f852                	sd	s4,48(sp)
    8000160e:	e862                	sd	s8,16(sp)
    80001610:	e466                	sd	s9,8(sp)
    80001612:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001614:	4cd5                	li	s9,21
    80001616:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    80001618:	8c3e                	mv	s8,a5
    8000161a:	a025                	j	80001642 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    8000161c:	83a9                	srli	a5,a5,0xa
    8000161e:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001620:	409a8533          	sub	a0,s5,s1
    80001624:	0009061b          	sext.w	a2,s2
    80001628:	85da                	mv	a1,s6
    8000162a:	953e                	add	a0,a0,a5
    8000162c:	ef8ff0ef          	jal	80000d24 <memmove>

    len -= n;
    80001630:	412989b3          	sub	s3,s3,s2
    src += n;
    80001634:	9b4a                	add	s6,s6,s2
  while(len > 0){
    80001636:	02098963          	beqz	s3,80001668 <copyout+0x86>
    if(va0 >= MAXVA)
    8000163a:	054c6263          	bltu	s8,s4,8000167e <copyout+0x9c>
    8000163e:	84d2                	mv	s1,s4
    80001640:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    80001642:	4601                	li	a2,0
    80001644:	85a6                	mv	a1,s1
    80001646:	855e                	mv	a0,s7
    80001648:	985ff0ef          	jal	80000fcc <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    8000164c:	c121                	beqz	a0,8000168c <copyout+0xaa>
    8000164e:	611c                	ld	a5,0(a0)
    80001650:	0157f713          	andi	a4,a5,21
    80001654:	05971b63          	bne	a4,s9,800016aa <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    80001658:	01a48a33          	add	s4,s1,s10
    8000165c:	415a0933          	sub	s2,s4,s5
    if(n > len)
    80001660:	fb29fee3          	bgeu	s3,s2,8000161c <copyout+0x3a>
    80001664:	894e                	mv	s2,s3
    80001666:	bf5d                	j	8000161c <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    80001668:	4501                	li	a0,0
    8000166a:	6906                	ld	s2,64(sp)
    8000166c:	7a42                	ld	s4,48(sp)
    8000166e:	6c42                	ld	s8,16(sp)
    80001670:	6ca2                	ld	s9,8(sp)
    80001672:	6d02                	ld	s10,0(sp)
    80001674:	a015                	j	80001698 <copyout+0xb6>
    80001676:	4501                	li	a0,0
}
    80001678:	8082                	ret
      return -1;
    8000167a:	557d                	li	a0,-1
    8000167c:	a831                	j	80001698 <copyout+0xb6>
    8000167e:	557d                	li	a0,-1
    80001680:	6906                	ld	s2,64(sp)
    80001682:	7a42                	ld	s4,48(sp)
    80001684:	6c42                	ld	s8,16(sp)
    80001686:	6ca2                	ld	s9,8(sp)
    80001688:	6d02                	ld	s10,0(sp)
    8000168a:	a039                	j	80001698 <copyout+0xb6>
      return -1;
    8000168c:	557d                	li	a0,-1
    8000168e:	6906                	ld	s2,64(sp)
    80001690:	7a42                	ld	s4,48(sp)
    80001692:	6c42                	ld	s8,16(sp)
    80001694:	6ca2                	ld	s9,8(sp)
    80001696:	6d02                	ld	s10,0(sp)
}
    80001698:	60e6                	ld	ra,88(sp)
    8000169a:	6446                	ld	s0,80(sp)
    8000169c:	64a6                	ld	s1,72(sp)
    8000169e:	79e2                	ld	s3,56(sp)
    800016a0:	7aa2                	ld	s5,40(sp)
    800016a2:	7b02                	ld	s6,32(sp)
    800016a4:	6be2                	ld	s7,24(sp)
    800016a6:	6125                	addi	sp,sp,96
    800016a8:	8082                	ret
      return -1;
    800016aa:	557d                	li	a0,-1
    800016ac:	6906                	ld	s2,64(sp)
    800016ae:	7a42                	ld	s4,48(sp)
    800016b0:	6c42                	ld	s8,16(sp)
    800016b2:	6ca2                	ld	s9,8(sp)
    800016b4:	6d02                	ld	s10,0(sp)
    800016b6:	b7cd                	j	80001698 <copyout+0xb6>

00000000800016b8 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016b8:	c6a5                	beqz	a3,80001720 <copyin+0x68>
{
    800016ba:	715d                	addi	sp,sp,-80
    800016bc:	e486                	sd	ra,72(sp)
    800016be:	e0a2                	sd	s0,64(sp)
    800016c0:	fc26                	sd	s1,56(sp)
    800016c2:	f84a                	sd	s2,48(sp)
    800016c4:	f44e                	sd	s3,40(sp)
    800016c6:	f052                	sd	s4,32(sp)
    800016c8:	ec56                	sd	s5,24(sp)
    800016ca:	e85a                	sd	s6,16(sp)
    800016cc:	e45e                	sd	s7,8(sp)
    800016ce:	e062                	sd	s8,0(sp)
    800016d0:	0880                	addi	s0,sp,80
    800016d2:	8b2a                	mv	s6,a0
    800016d4:	8a2e                	mv	s4,a1
    800016d6:	8c32                	mv	s8,a2
    800016d8:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800016da:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016dc:	6a85                	lui	s5,0x1
    800016de:	a00d                	j	80001700 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016e0:	018505b3          	add	a1,a0,s8
    800016e4:	0004861b          	sext.w	a2,s1
    800016e8:	412585b3          	sub	a1,a1,s2
    800016ec:	8552                	mv	a0,s4
    800016ee:	e36ff0ef          	jal	80000d24 <memmove>

    len -= n;
    800016f2:	409989b3          	sub	s3,s3,s1
    dst += n;
    800016f6:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800016f8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016fc:	02098063          	beqz	s3,8000171c <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80001700:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001704:	85ca                	mv	a1,s2
    80001706:	855a                	mv	a0,s6
    80001708:	95fff0ef          	jal	80001066 <walkaddr>
    if(pa0 == 0)
    8000170c:	cd01                	beqz	a0,80001724 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    8000170e:	418904b3          	sub	s1,s2,s8
    80001712:	94d6                	add	s1,s1,s5
    if(n > len)
    80001714:	fc99f6e3          	bgeu	s3,s1,800016e0 <copyin+0x28>
    80001718:	84ce                	mv	s1,s3
    8000171a:	b7d9                	j	800016e0 <copyin+0x28>
  }
  return 0;
    8000171c:	4501                	li	a0,0
    8000171e:	a021                	j	80001726 <copyin+0x6e>
    80001720:	4501                	li	a0,0
}
    80001722:	8082                	ret
      return -1;
    80001724:	557d                	li	a0,-1
}
    80001726:	60a6                	ld	ra,72(sp)
    80001728:	6406                	ld	s0,64(sp)
    8000172a:	74e2                	ld	s1,56(sp)
    8000172c:	7942                	ld	s2,48(sp)
    8000172e:	79a2                	ld	s3,40(sp)
    80001730:	7a02                	ld	s4,32(sp)
    80001732:	6ae2                	ld	s5,24(sp)
    80001734:	6b42                	ld	s6,16(sp)
    80001736:	6ba2                	ld	s7,8(sp)
    80001738:	6c02                	ld	s8,0(sp)
    8000173a:	6161                	addi	sp,sp,80
    8000173c:	8082                	ret

000000008000173e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000173e:	c6dd                	beqz	a3,800017ec <copyinstr+0xae>
{
    80001740:	715d                	addi	sp,sp,-80
    80001742:	e486                	sd	ra,72(sp)
    80001744:	e0a2                	sd	s0,64(sp)
    80001746:	fc26                	sd	s1,56(sp)
    80001748:	f84a                	sd	s2,48(sp)
    8000174a:	f44e                	sd	s3,40(sp)
    8000174c:	f052                	sd	s4,32(sp)
    8000174e:	ec56                	sd	s5,24(sp)
    80001750:	e85a                	sd	s6,16(sp)
    80001752:	e45e                	sd	s7,8(sp)
    80001754:	0880                	addi	s0,sp,80
    80001756:	8a2a                	mv	s4,a0
    80001758:	8b2e                	mv	s6,a1
    8000175a:	8bb2                	mv	s7,a2
    8000175c:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    8000175e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001760:	6985                	lui	s3,0x1
    80001762:	a825                	j	8000179a <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001764:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001768:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000176a:	37fd                	addiw	a5,a5,-1
    8000176c:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001770:	60a6                	ld	ra,72(sp)
    80001772:	6406                	ld	s0,64(sp)
    80001774:	74e2                	ld	s1,56(sp)
    80001776:	7942                	ld	s2,48(sp)
    80001778:	79a2                	ld	s3,40(sp)
    8000177a:	7a02                	ld	s4,32(sp)
    8000177c:	6ae2                	ld	s5,24(sp)
    8000177e:	6b42                	ld	s6,16(sp)
    80001780:	6ba2                	ld	s7,8(sp)
    80001782:	6161                	addi	sp,sp,80
    80001784:	8082                	ret
    80001786:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    8000178a:	9742                	add	a4,a4,a6
      --max;
    8000178c:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001790:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001794:	04e58463          	beq	a1,a4,800017dc <copyinstr+0x9e>
{
    80001798:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000179a:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000179e:	85a6                	mv	a1,s1
    800017a0:	8552                	mv	a0,s4
    800017a2:	8c5ff0ef          	jal	80001066 <walkaddr>
    if(pa0 == 0)
    800017a6:	cd0d                	beqz	a0,800017e0 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017a8:	417486b3          	sub	a3,s1,s7
    800017ac:	96ce                	add	a3,a3,s3
    if(n > max)
    800017ae:	00d97363          	bgeu	s2,a3,800017b4 <copyinstr+0x76>
    800017b2:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    800017b4:	955e                	add	a0,a0,s7
    800017b6:	8d05                	sub	a0,a0,s1
    while(n > 0){
    800017b8:	c695                	beqz	a3,800017e4 <copyinstr+0xa6>
    800017ba:	87da                	mv	a5,s6
    800017bc:	885a                	mv	a6,s6
      if(*p == '\0'){
    800017be:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800017c2:	96da                	add	a3,a3,s6
    800017c4:	85be                	mv	a1,a5
      if(*p == '\0'){
    800017c6:	00f60733          	add	a4,a2,a5
    800017ca:	00074703          	lbu	a4,0(a4)
    800017ce:	db59                	beqz	a4,80001764 <copyinstr+0x26>
        *dst = *p;
    800017d0:	00e78023          	sb	a4,0(a5)
      dst++;
    800017d4:	0785                	addi	a5,a5,1
    while(n > 0){
    800017d6:	fed797e3          	bne	a5,a3,800017c4 <copyinstr+0x86>
    800017da:	b775                	j	80001786 <copyinstr+0x48>
    800017dc:	4781                	li	a5,0
    800017de:	b771                	j	8000176a <copyinstr+0x2c>
      return -1;
    800017e0:	557d                	li	a0,-1
    800017e2:	b779                	j	80001770 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    800017e4:	6b85                	lui	s7,0x1
    800017e6:	9ba6                	add	s7,s7,s1
    800017e8:	87da                	mv	a5,s6
    800017ea:	b77d                	j	80001798 <copyinstr+0x5a>
  int got_null = 0;
    800017ec:	4781                	li	a5,0
  if(got_null){
    800017ee:	37fd                	addiw	a5,a5,-1
    800017f0:	0007851b          	sext.w	a0,a5
}
    800017f4:	8082                	ret

00000000800017f6 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800017f6:	7139                	addi	sp,sp,-64
    800017f8:	fc06                	sd	ra,56(sp)
    800017fa:	f822                	sd	s0,48(sp)
    800017fc:	f426                	sd	s1,40(sp)
    800017fe:	f04a                	sd	s2,32(sp)
    80001800:	ec4e                	sd	s3,24(sp)
    80001802:	e852                	sd	s4,16(sp)
    80001804:	e456                	sd	s5,8(sp)
    80001806:	e05a                	sd	s6,0(sp)
    80001808:	0080                	addi	s0,sp,64
    8000180a:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000180c:	0000e497          	auipc	s1,0xe
    80001810:	79448493          	addi	s1,s1,1940 # 8000ffa0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001814:	8b26                	mv	s6,s1
    80001816:	04fa5937          	lui	s2,0x4fa5
    8000181a:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    8000181e:	0932                	slli	s2,s2,0xc
    80001820:	fa590913          	addi	s2,s2,-91
    80001824:	0932                	slli	s2,s2,0xc
    80001826:	fa590913          	addi	s2,s2,-91
    8000182a:	0932                	slli	s2,s2,0xc
    8000182c:	fa590913          	addi	s2,s2,-91
    80001830:	040009b7          	lui	s3,0x4000
    80001834:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001836:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001838:	00014a97          	auipc	s5,0x14
    8000183c:	168a8a93          	addi	s5,s5,360 # 800159a0 <tickslock>
    char *pa = kalloc();
    80001840:	ae4ff0ef          	jal	80000b24 <kalloc>
    80001844:	862a                	mv	a2,a0
    if(pa == 0)
    80001846:	cd15                	beqz	a0,80001882 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    80001848:	416485b3          	sub	a1,s1,s6
    8000184c:	858d                	srai	a1,a1,0x3
    8000184e:	032585b3          	mul	a1,a1,s2
    80001852:	2585                	addiw	a1,a1,1
    80001854:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001858:	4719                	li	a4,6
    8000185a:	6685                	lui	a3,0x1
    8000185c:	40b985b3          	sub	a1,s3,a1
    80001860:	8552                	mv	a0,s4
    80001862:	8f3ff0ef          	jal	80001154 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001866:	16848493          	addi	s1,s1,360
    8000186a:	fd549be3          	bne	s1,s5,80001840 <proc_mapstacks+0x4a>
  }
}
    8000186e:	70e2                	ld	ra,56(sp)
    80001870:	7442                	ld	s0,48(sp)
    80001872:	74a2                	ld	s1,40(sp)
    80001874:	7902                	ld	s2,32(sp)
    80001876:	69e2                	ld	s3,24(sp)
    80001878:	6a42                	ld	s4,16(sp)
    8000187a:	6aa2                	ld	s5,8(sp)
    8000187c:	6b02                	ld	s6,0(sp)
    8000187e:	6121                	addi	sp,sp,64
    80001880:	8082                	ret
      panic("kalloc");
    80001882:	00006517          	auipc	a0,0x6
    80001886:	ab650513          	addi	a0,a0,-1354 # 80007338 <etext+0x338>
    8000188a:	f0bfe0ef          	jal	80000794 <panic>

000000008000188e <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000188e:	7139                	addi	sp,sp,-64
    80001890:	fc06                	sd	ra,56(sp)
    80001892:	f822                	sd	s0,48(sp)
    80001894:	f426                	sd	s1,40(sp)
    80001896:	f04a                	sd	s2,32(sp)
    80001898:	ec4e                	sd	s3,24(sp)
    8000189a:	e852                	sd	s4,16(sp)
    8000189c:	e456                	sd	s5,8(sp)
    8000189e:	e05a                	sd	s6,0(sp)
    800018a0:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018a2:	00006597          	auipc	a1,0x6
    800018a6:	a9e58593          	addi	a1,a1,-1378 # 80007340 <etext+0x340>
    800018aa:	0000e517          	auipc	a0,0xe
    800018ae:	2c650513          	addi	a0,a0,710 # 8000fb70 <pid_lock>
    800018b2:	ac2ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018b6:	00006597          	auipc	a1,0x6
    800018ba:	a9258593          	addi	a1,a1,-1390 # 80007348 <etext+0x348>
    800018be:	0000e517          	auipc	a0,0xe
    800018c2:	2ca50513          	addi	a0,a0,714 # 8000fb88 <wait_lock>
    800018c6:	aaeff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ca:	0000e497          	auipc	s1,0xe
    800018ce:	6d648493          	addi	s1,s1,1750 # 8000ffa0 <proc>
      initlock(&p->lock, "proc");
    800018d2:	00006b17          	auipc	s6,0x6
    800018d6:	a86b0b13          	addi	s6,s6,-1402 # 80007358 <etext+0x358>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    800018da:	8aa6                	mv	s5,s1
    800018dc:	04fa5937          	lui	s2,0x4fa5
    800018e0:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    800018e4:	0932                	slli	s2,s2,0xc
    800018e6:	fa590913          	addi	s2,s2,-91
    800018ea:	0932                	slli	s2,s2,0xc
    800018ec:	fa590913          	addi	s2,s2,-91
    800018f0:	0932                	slli	s2,s2,0xc
    800018f2:	fa590913          	addi	s2,s2,-91
    800018f6:	040009b7          	lui	s3,0x4000
    800018fa:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018fc:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018fe:	00014a17          	auipc	s4,0x14
    80001902:	0a2a0a13          	addi	s4,s4,162 # 800159a0 <tickslock>
      initlock(&p->lock, "proc");
    80001906:	85da                	mv	a1,s6
    80001908:	8526                	mv	a0,s1
    8000190a:	a6aff0ef          	jal	80000b74 <initlock>
      p->state = UNUSED;
    8000190e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001912:	415487b3          	sub	a5,s1,s5
    80001916:	878d                	srai	a5,a5,0x3
    80001918:	032787b3          	mul	a5,a5,s2
    8000191c:	2785                	addiw	a5,a5,1
    8000191e:	00d7979b          	slliw	a5,a5,0xd
    80001922:	40f987b3          	sub	a5,s3,a5
    80001926:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001928:	16848493          	addi	s1,s1,360
    8000192c:	fd449de3          	bne	s1,s4,80001906 <procinit+0x78>
  }
}
    80001930:	70e2                	ld	ra,56(sp)
    80001932:	7442                	ld	s0,48(sp)
    80001934:	74a2                	ld	s1,40(sp)
    80001936:	7902                	ld	s2,32(sp)
    80001938:	69e2                	ld	s3,24(sp)
    8000193a:	6a42                	ld	s4,16(sp)
    8000193c:	6aa2                	ld	s5,8(sp)
    8000193e:	6b02                	ld	s6,0(sp)
    80001940:	6121                	addi	sp,sp,64
    80001942:	8082                	ret

0000000080001944 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001944:	1141                	addi	sp,sp,-16
    80001946:	e422                	sd	s0,8(sp)
    80001948:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    8000194a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000194c:	2501                	sext.w	a0,a0
    8000194e:	6422                	ld	s0,8(sp)
    80001950:	0141                	addi	sp,sp,16
    80001952:	8082                	ret

0000000080001954 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001954:	1141                	addi	sp,sp,-16
    80001956:	e422                	sd	s0,8(sp)
    80001958:	0800                	addi	s0,sp,16
    8000195a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000195c:	2781                	sext.w	a5,a5
    8000195e:	079e                	slli	a5,a5,0x7
  return c;
}
    80001960:	0000e517          	auipc	a0,0xe
    80001964:	24050513          	addi	a0,a0,576 # 8000fba0 <cpus>
    80001968:	953e                	add	a0,a0,a5
    8000196a:	6422                	ld	s0,8(sp)
    8000196c:	0141                	addi	sp,sp,16
    8000196e:	8082                	ret

0000000080001970 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001970:	1101                	addi	sp,sp,-32
    80001972:	ec06                	sd	ra,24(sp)
    80001974:	e822                	sd	s0,16(sp)
    80001976:	e426                	sd	s1,8(sp)
    80001978:	1000                	addi	s0,sp,32
  push_off();
    8000197a:	a3aff0ef          	jal	80000bb4 <push_off>
    8000197e:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001980:	2781                	sext.w	a5,a5
    80001982:	079e                	slli	a5,a5,0x7
    80001984:	0000e717          	auipc	a4,0xe
    80001988:	1ec70713          	addi	a4,a4,492 # 8000fb70 <pid_lock>
    8000198c:	97ba                	add	a5,a5,a4
    8000198e:	7b84                	ld	s1,48(a5)
  pop_off();
    80001990:	aa8ff0ef          	jal	80000c38 <pop_off>
  return p;
}
    80001994:	8526                	mv	a0,s1
    80001996:	60e2                	ld	ra,24(sp)
    80001998:	6442                	ld	s0,16(sp)
    8000199a:	64a2                	ld	s1,8(sp)
    8000199c:	6105                	addi	sp,sp,32
    8000199e:	8082                	ret

00000000800019a0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019a0:	1141                	addi	sp,sp,-16
    800019a2:	e406                	sd	ra,8(sp)
    800019a4:	e022                	sd	s0,0(sp)
    800019a6:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019a8:	fc9ff0ef          	jal	80001970 <myproc>
    800019ac:	ae0ff0ef          	jal	80000c8c <release>

  if (first) {
    800019b0:	00006797          	auipc	a5,0x6
    800019b4:	0107a783          	lw	a5,16(a5) # 800079c0 <first.1>
    800019b8:	e799                	bnez	a5,800019c6 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    800019ba:	2bf000ef          	jal	80002478 <usertrapret>
}
    800019be:	60a2                	ld	ra,8(sp)
    800019c0:	6402                	ld	s0,0(sp)
    800019c2:	0141                	addi	sp,sp,16
    800019c4:	8082                	ret
    fsinit(ROOTDEV);
    800019c6:	4505                	li	a0,1
    800019c8:	654010ef          	jal	8000301c <fsinit>
    first = 0;
    800019cc:	00006797          	auipc	a5,0x6
    800019d0:	fe07aa23          	sw	zero,-12(a5) # 800079c0 <first.1>
    __sync_synchronize();
    800019d4:	0ff0000f          	fence
    800019d8:	b7cd                	j	800019ba <forkret+0x1a>

00000000800019da <allocpid>:
{
    800019da:	1101                	addi	sp,sp,-32
    800019dc:	ec06                	sd	ra,24(sp)
    800019de:	e822                	sd	s0,16(sp)
    800019e0:	e426                	sd	s1,8(sp)
    800019e2:	e04a                	sd	s2,0(sp)
    800019e4:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800019e6:	0000e917          	auipc	s2,0xe
    800019ea:	18a90913          	addi	s2,s2,394 # 8000fb70 <pid_lock>
    800019ee:	854a                	mv	a0,s2
    800019f0:	a04ff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    800019f4:	00006797          	auipc	a5,0x6
    800019f8:	fd078793          	addi	a5,a5,-48 # 800079c4 <nextpid>
    800019fc:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019fe:	0014871b          	addiw	a4,s1,1
    80001a02:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a04:	854a                	mv	a0,s2
    80001a06:	a86ff0ef          	jal	80000c8c <release>
}
    80001a0a:	8526                	mv	a0,s1
    80001a0c:	60e2                	ld	ra,24(sp)
    80001a0e:	6442                	ld	s0,16(sp)
    80001a10:	64a2                	ld	s1,8(sp)
    80001a12:	6902                	ld	s2,0(sp)
    80001a14:	6105                	addi	sp,sp,32
    80001a16:	8082                	ret

0000000080001a18 <proc_pagetable>:
{
    80001a18:	1101                	addi	sp,sp,-32
    80001a1a:	ec06                	sd	ra,24(sp)
    80001a1c:	e822                	sd	s0,16(sp)
    80001a1e:	e426                	sd	s1,8(sp)
    80001a20:	e04a                	sd	s2,0(sp)
    80001a22:	1000                	addi	s0,sp,32
    80001a24:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a26:	8e1ff0ef          	jal	80001306 <uvmcreate>
    80001a2a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a2c:	cd05                	beqz	a0,80001a64 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a2e:	4729                	li	a4,10
    80001a30:	00004697          	auipc	a3,0x4
    80001a34:	5d068693          	addi	a3,a3,1488 # 80006000 <_trampoline>
    80001a38:	6605                	lui	a2,0x1
    80001a3a:	040005b7          	lui	a1,0x4000
    80001a3e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a40:	05b2                	slli	a1,a1,0xc
    80001a42:	e62ff0ef          	jal	800010a4 <mappages>
    80001a46:	02054663          	bltz	a0,80001a72 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a4a:	4719                	li	a4,6
    80001a4c:	05893683          	ld	a3,88(s2)
    80001a50:	6605                	lui	a2,0x1
    80001a52:	020005b7          	lui	a1,0x2000
    80001a56:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a58:	05b6                	slli	a1,a1,0xd
    80001a5a:	8526                	mv	a0,s1
    80001a5c:	e48ff0ef          	jal	800010a4 <mappages>
    80001a60:	00054f63          	bltz	a0,80001a7e <proc_pagetable+0x66>
}
    80001a64:	8526                	mv	a0,s1
    80001a66:	60e2                	ld	ra,24(sp)
    80001a68:	6442                	ld	s0,16(sp)
    80001a6a:	64a2                	ld	s1,8(sp)
    80001a6c:	6902                	ld	s2,0(sp)
    80001a6e:	6105                	addi	sp,sp,32
    80001a70:	8082                	ret
    uvmfree(pagetable, 0);
    80001a72:	4581                	li	a1,0
    80001a74:	8526                	mv	a0,s1
    80001a76:	a5fff0ef          	jal	800014d4 <uvmfree>
    return 0;
    80001a7a:	4481                	li	s1,0
    80001a7c:	b7e5                	j	80001a64 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a7e:	4681                	li	a3,0
    80001a80:	4605                	li	a2,1
    80001a82:	040005b7          	lui	a1,0x4000
    80001a86:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a88:	05b2                	slli	a1,a1,0xc
    80001a8a:	8526                	mv	a0,s1
    80001a8c:	fbeff0ef          	jal	8000124a <uvmunmap>
    uvmfree(pagetable, 0);
    80001a90:	4581                	li	a1,0
    80001a92:	8526                	mv	a0,s1
    80001a94:	a41ff0ef          	jal	800014d4 <uvmfree>
    return 0;
    80001a98:	4481                	li	s1,0
    80001a9a:	b7e9                	j	80001a64 <proc_pagetable+0x4c>

0000000080001a9c <proc_freepagetable>:
{
    80001a9c:	1101                	addi	sp,sp,-32
    80001a9e:	ec06                	sd	ra,24(sp)
    80001aa0:	e822                	sd	s0,16(sp)
    80001aa2:	e426                	sd	s1,8(sp)
    80001aa4:	e04a                	sd	s2,0(sp)
    80001aa6:	1000                	addi	s0,sp,32
    80001aa8:	84aa                	mv	s1,a0
    80001aaa:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aac:	4681                	li	a3,0
    80001aae:	4605                	li	a2,1
    80001ab0:	040005b7          	lui	a1,0x4000
    80001ab4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ab6:	05b2                	slli	a1,a1,0xc
    80001ab8:	f92ff0ef          	jal	8000124a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001abc:	4681                	li	a3,0
    80001abe:	4605                	li	a2,1
    80001ac0:	020005b7          	lui	a1,0x2000
    80001ac4:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ac6:	05b6                	slli	a1,a1,0xd
    80001ac8:	8526                	mv	a0,s1
    80001aca:	f80ff0ef          	jal	8000124a <uvmunmap>
  uvmfree(pagetable, sz);
    80001ace:	85ca                	mv	a1,s2
    80001ad0:	8526                	mv	a0,s1
    80001ad2:	a03ff0ef          	jal	800014d4 <uvmfree>
}
    80001ad6:	60e2                	ld	ra,24(sp)
    80001ad8:	6442                	ld	s0,16(sp)
    80001ada:	64a2                	ld	s1,8(sp)
    80001adc:	6902                	ld	s2,0(sp)
    80001ade:	6105                	addi	sp,sp,32
    80001ae0:	8082                	ret

0000000080001ae2 <freeproc>:
{
    80001ae2:	1101                	addi	sp,sp,-32
    80001ae4:	ec06                	sd	ra,24(sp)
    80001ae6:	e822                	sd	s0,16(sp)
    80001ae8:	e426                	sd	s1,8(sp)
    80001aea:	1000                	addi	s0,sp,32
    80001aec:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001aee:	6d28                	ld	a0,88(a0)
    80001af0:	c119                	beqz	a0,80001af6 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001af2:	f51fe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80001af6:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001afa:	68a8                	ld	a0,80(s1)
    80001afc:	c501                	beqz	a0,80001b04 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001afe:	64ac                	ld	a1,72(s1)
    80001b00:	f9dff0ef          	jal	80001a9c <proc_freepagetable>
  p->pagetable = 0;
    80001b04:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b08:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b0c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b10:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b14:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b18:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b1c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b20:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b24:	0004ac23          	sw	zero,24(s1)
}
    80001b28:	60e2                	ld	ra,24(sp)
    80001b2a:	6442                	ld	s0,16(sp)
    80001b2c:	64a2                	ld	s1,8(sp)
    80001b2e:	6105                	addi	sp,sp,32
    80001b30:	8082                	ret

0000000080001b32 <allocproc>:
{
    80001b32:	1101                	addi	sp,sp,-32
    80001b34:	ec06                	sd	ra,24(sp)
    80001b36:	e822                	sd	s0,16(sp)
    80001b38:	e426                	sd	s1,8(sp)
    80001b3a:	e04a                	sd	s2,0(sp)
    80001b3c:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b3e:	0000e497          	auipc	s1,0xe
    80001b42:	46248493          	addi	s1,s1,1122 # 8000ffa0 <proc>
    80001b46:	00014917          	auipc	s2,0x14
    80001b4a:	e5a90913          	addi	s2,s2,-422 # 800159a0 <tickslock>
    acquire(&p->lock);
    80001b4e:	8526                	mv	a0,s1
    80001b50:	8a4ff0ef          	jal	80000bf4 <acquire>
    if(p->state == UNUSED) {
    80001b54:	4c9c                	lw	a5,24(s1)
    80001b56:	cb91                	beqz	a5,80001b6a <allocproc+0x38>
      release(&p->lock);
    80001b58:	8526                	mv	a0,s1
    80001b5a:	932ff0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b5e:	16848493          	addi	s1,s1,360
    80001b62:	ff2496e3          	bne	s1,s2,80001b4e <allocproc+0x1c>
  return 0;
    80001b66:	4481                	li	s1,0
    80001b68:	a089                	j	80001baa <allocproc+0x78>
  p->pid = allocpid();
    80001b6a:	e71ff0ef          	jal	800019da <allocpid>
    80001b6e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b70:	4785                	li	a5,1
    80001b72:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b74:	fb1fe0ef          	jal	80000b24 <kalloc>
    80001b78:	892a                	mv	s2,a0
    80001b7a:	eca8                	sd	a0,88(s1)
    80001b7c:	cd15                	beqz	a0,80001bb8 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b7e:	8526                	mv	a0,s1
    80001b80:	e99ff0ef          	jal	80001a18 <proc_pagetable>
    80001b84:	892a                	mv	s2,a0
    80001b86:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b88:	c121                	beqz	a0,80001bc8 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b8a:	07000613          	li	a2,112
    80001b8e:	4581                	li	a1,0
    80001b90:	06048513          	addi	a0,s1,96
    80001b94:	934ff0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    80001b98:	00000797          	auipc	a5,0x0
    80001b9c:	e0878793          	addi	a5,a5,-504 # 800019a0 <forkret>
    80001ba0:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ba2:	60bc                	ld	a5,64(s1)
    80001ba4:	6705                	lui	a4,0x1
    80001ba6:	97ba                	add	a5,a5,a4
    80001ba8:	f4bc                	sd	a5,104(s1)
}
    80001baa:	8526                	mv	a0,s1
    80001bac:	60e2                	ld	ra,24(sp)
    80001bae:	6442                	ld	s0,16(sp)
    80001bb0:	64a2                	ld	s1,8(sp)
    80001bb2:	6902                	ld	s2,0(sp)
    80001bb4:	6105                	addi	sp,sp,32
    80001bb6:	8082                	ret
    freeproc(p);
    80001bb8:	8526                	mv	a0,s1
    80001bba:	f29ff0ef          	jal	80001ae2 <freeproc>
    release(&p->lock);
    80001bbe:	8526                	mv	a0,s1
    80001bc0:	8ccff0ef          	jal	80000c8c <release>
    return 0;
    80001bc4:	84ca                	mv	s1,s2
    80001bc6:	b7d5                	j	80001baa <allocproc+0x78>
    freeproc(p);
    80001bc8:	8526                	mv	a0,s1
    80001bca:	f19ff0ef          	jal	80001ae2 <freeproc>
    release(&p->lock);
    80001bce:	8526                	mv	a0,s1
    80001bd0:	8bcff0ef          	jal	80000c8c <release>
    return 0;
    80001bd4:	84ca                	mv	s1,s2
    80001bd6:	bfd1                	j	80001baa <allocproc+0x78>

0000000080001bd8 <userinit>:
{
    80001bd8:	1101                	addi	sp,sp,-32
    80001bda:	ec06                	sd	ra,24(sp)
    80001bdc:	e822                	sd	s0,16(sp)
    80001bde:	e426                	sd	s1,8(sp)
    80001be0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001be2:	f51ff0ef          	jal	80001b32 <allocproc>
    80001be6:	84aa                	mv	s1,a0
  initproc = p;
    80001be8:	00006797          	auipc	a5,0x6
    80001bec:	e4a7b823          	sd	a0,-432(a5) # 80007a38 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001bf0:	03400613          	li	a2,52
    80001bf4:	00006597          	auipc	a1,0x6
    80001bf8:	ddc58593          	addi	a1,a1,-548 # 800079d0 <initcode>
    80001bfc:	6928                	ld	a0,80(a0)
    80001bfe:	f2eff0ef          	jal	8000132c <uvmfirst>
  p->sz = PGSIZE;
    80001c02:	6785                	lui	a5,0x1
    80001c04:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001c06:	6cb8                	ld	a4,88(s1)
    80001c08:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001c0c:	6cb8                	ld	a4,88(s1)
    80001c0e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001c10:	4641                	li	a2,16
    80001c12:	00005597          	auipc	a1,0x5
    80001c16:	74e58593          	addi	a1,a1,1870 # 80007360 <etext+0x360>
    80001c1a:	15848513          	addi	a0,s1,344
    80001c1e:	9e8ff0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80001c22:	00005517          	auipc	a0,0x5
    80001c26:	74e50513          	addi	a0,a0,1870 # 80007370 <etext+0x370>
    80001c2a:	501010ef          	jal	8000392a <namei>
    80001c2e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c32:	478d                	li	a5,3
    80001c34:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c36:	8526                	mv	a0,s1
    80001c38:	854ff0ef          	jal	80000c8c <release>
}
    80001c3c:	60e2                	ld	ra,24(sp)
    80001c3e:	6442                	ld	s0,16(sp)
    80001c40:	64a2                	ld	s1,8(sp)
    80001c42:	6105                	addi	sp,sp,32
    80001c44:	8082                	ret

0000000080001c46 <growproc>:
{
    80001c46:	1101                	addi	sp,sp,-32
    80001c48:	ec06                	sd	ra,24(sp)
    80001c4a:	e822                	sd	s0,16(sp)
    80001c4c:	e426                	sd	s1,8(sp)
    80001c4e:	e04a                	sd	s2,0(sp)
    80001c50:	1000                	addi	s0,sp,32
    80001c52:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001c54:	d1dff0ef          	jal	80001970 <myproc>
    80001c58:	84aa                	mv	s1,a0
  sz = p->sz;
    80001c5a:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001c5c:	01204c63          	bgtz	s2,80001c74 <growproc+0x2e>
  } else if(n < 0){
    80001c60:	02094463          	bltz	s2,80001c88 <growproc+0x42>
  p->sz = sz;
    80001c64:	e4ac                	sd	a1,72(s1)
  return 0;
    80001c66:	4501                	li	a0,0
}
    80001c68:	60e2                	ld	ra,24(sp)
    80001c6a:	6442                	ld	s0,16(sp)
    80001c6c:	64a2                	ld	s1,8(sp)
    80001c6e:	6902                	ld	s2,0(sp)
    80001c70:	6105                	addi	sp,sp,32
    80001c72:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c74:	4691                	li	a3,4
    80001c76:	00b90633          	add	a2,s2,a1
    80001c7a:	6928                	ld	a0,80(a0)
    80001c7c:	f52ff0ef          	jal	800013ce <uvmalloc>
    80001c80:	85aa                	mv	a1,a0
    80001c82:	f16d                	bnez	a0,80001c64 <growproc+0x1e>
      return -1;
    80001c84:	557d                	li	a0,-1
    80001c86:	b7cd                	j	80001c68 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c88:	00b90633          	add	a2,s2,a1
    80001c8c:	6928                	ld	a0,80(a0)
    80001c8e:	efcff0ef          	jal	8000138a <uvmdealloc>
    80001c92:	85aa                	mv	a1,a0
    80001c94:	bfc1                	j	80001c64 <growproc+0x1e>

0000000080001c96 <fork>:
{
    80001c96:	7139                	addi	sp,sp,-64
    80001c98:	fc06                	sd	ra,56(sp)
    80001c9a:	f822                	sd	s0,48(sp)
    80001c9c:	f04a                	sd	s2,32(sp)
    80001c9e:	e456                	sd	s5,8(sp)
    80001ca0:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001ca2:	ccfff0ef          	jal	80001970 <myproc>
    80001ca6:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001ca8:	e8bff0ef          	jal	80001b32 <allocproc>
    80001cac:	0e050a63          	beqz	a0,80001da0 <fork+0x10a>
    80001cb0:	e852                	sd	s4,16(sp)
    80001cb2:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001cb4:	048ab603          	ld	a2,72(s5)
    80001cb8:	692c                	ld	a1,80(a0)
    80001cba:	050ab503          	ld	a0,80(s5)
    80001cbe:	849ff0ef          	jal	80001506 <uvmcopy>
    80001cc2:	04054a63          	bltz	a0,80001d16 <fork+0x80>
    80001cc6:	f426                	sd	s1,40(sp)
    80001cc8:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001cca:	048ab783          	ld	a5,72(s5)
    80001cce:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001cd2:	058ab683          	ld	a3,88(s5)
    80001cd6:	87b6                	mv	a5,a3
    80001cd8:	058a3703          	ld	a4,88(s4)
    80001cdc:	12068693          	addi	a3,a3,288
    80001ce0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001ce4:	6788                	ld	a0,8(a5)
    80001ce6:	6b8c                	ld	a1,16(a5)
    80001ce8:	6f90                	ld	a2,24(a5)
    80001cea:	01073023          	sd	a6,0(a4)
    80001cee:	e708                	sd	a0,8(a4)
    80001cf0:	eb0c                	sd	a1,16(a4)
    80001cf2:	ef10                	sd	a2,24(a4)
    80001cf4:	02078793          	addi	a5,a5,32
    80001cf8:	02070713          	addi	a4,a4,32
    80001cfc:	fed792e3          	bne	a5,a3,80001ce0 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001d00:	058a3783          	ld	a5,88(s4)
    80001d04:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001d08:	0d0a8493          	addi	s1,s5,208
    80001d0c:	0d0a0913          	addi	s2,s4,208
    80001d10:	150a8993          	addi	s3,s5,336
    80001d14:	a831                	j	80001d30 <fork+0x9a>
    freeproc(np);
    80001d16:	8552                	mv	a0,s4
    80001d18:	dcbff0ef          	jal	80001ae2 <freeproc>
    release(&np->lock);
    80001d1c:	8552                	mv	a0,s4
    80001d1e:	f6ffe0ef          	jal	80000c8c <release>
    return -1;
    80001d22:	597d                	li	s2,-1
    80001d24:	6a42                	ld	s4,16(sp)
    80001d26:	a0b5                	j	80001d92 <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001d28:	04a1                	addi	s1,s1,8
    80001d2a:	0921                	addi	s2,s2,8
    80001d2c:	01348963          	beq	s1,s3,80001d3e <fork+0xa8>
    if(p->ofile[i])
    80001d30:	6088                	ld	a0,0(s1)
    80001d32:	d97d                	beqz	a0,80001d28 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d34:	186020ef          	jal	80003eba <filedup>
    80001d38:	00a93023          	sd	a0,0(s2)
    80001d3c:	b7f5                	j	80001d28 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001d3e:	150ab503          	ld	a0,336(s5)
    80001d42:	4d8010ef          	jal	8000321a <idup>
    80001d46:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d4a:	4641                	li	a2,16
    80001d4c:	158a8593          	addi	a1,s5,344
    80001d50:	158a0513          	addi	a0,s4,344
    80001d54:	8b2ff0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    80001d58:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001d5c:	8552                	mv	a0,s4
    80001d5e:	f2ffe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80001d62:	0000e497          	auipc	s1,0xe
    80001d66:	e2648493          	addi	s1,s1,-474 # 8000fb88 <wait_lock>
    80001d6a:	8526                	mv	a0,s1
    80001d6c:	e89fe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80001d70:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d74:	8526                	mv	a0,s1
    80001d76:	f17fe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    80001d7a:	8552                	mv	a0,s4
    80001d7c:	e79fe0ef          	jal	80000bf4 <acquire>
  np->state = RUNNABLE;
    80001d80:	478d                	li	a5,3
    80001d82:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d86:	8552                	mv	a0,s4
    80001d88:	f05fe0ef          	jal	80000c8c <release>
  return pid;
    80001d8c:	74a2                	ld	s1,40(sp)
    80001d8e:	69e2                	ld	s3,24(sp)
    80001d90:	6a42                	ld	s4,16(sp)
}
    80001d92:	854a                	mv	a0,s2
    80001d94:	70e2                	ld	ra,56(sp)
    80001d96:	7442                	ld	s0,48(sp)
    80001d98:	7902                	ld	s2,32(sp)
    80001d9a:	6aa2                	ld	s5,8(sp)
    80001d9c:	6121                	addi	sp,sp,64
    80001d9e:	8082                	ret
    return -1;
    80001da0:	597d                	li	s2,-1
    80001da2:	bfc5                	j	80001d92 <fork+0xfc>

0000000080001da4 <scheduler>:
{
    80001da4:	715d                	addi	sp,sp,-80
    80001da6:	e486                	sd	ra,72(sp)
    80001da8:	e0a2                	sd	s0,64(sp)
    80001daa:	fc26                	sd	s1,56(sp)
    80001dac:	f84a                	sd	s2,48(sp)
    80001dae:	f44e                	sd	s3,40(sp)
    80001db0:	f052                	sd	s4,32(sp)
    80001db2:	ec56                	sd	s5,24(sp)
    80001db4:	e85a                	sd	s6,16(sp)
    80001db6:	e45e                	sd	s7,8(sp)
    80001db8:	e062                	sd	s8,0(sp)
    80001dba:	0880                	addi	s0,sp,80
    80001dbc:	8792                	mv	a5,tp
  int id = r_tp();
    80001dbe:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001dc0:	00779b13          	slli	s6,a5,0x7
    80001dc4:	0000e717          	auipc	a4,0xe
    80001dc8:	dac70713          	addi	a4,a4,-596 # 8000fb70 <pid_lock>
    80001dcc:	975a                	add	a4,a4,s6
    80001dce:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001dd2:	0000e717          	auipc	a4,0xe
    80001dd6:	dd670713          	addi	a4,a4,-554 # 8000fba8 <cpus+0x8>
    80001dda:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001ddc:	4c11                	li	s8,4
        c->proc = p;
    80001dde:	079e                	slli	a5,a5,0x7
    80001de0:	0000ea17          	auipc	s4,0xe
    80001de4:	d90a0a13          	addi	s4,s4,-624 # 8000fb70 <pid_lock>
    80001de8:	9a3e                	add	s4,s4,a5
        found = 1;
    80001dea:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dec:	00014997          	auipc	s3,0x14
    80001df0:	bb498993          	addi	s3,s3,-1100 # 800159a0 <tickslock>
    80001df4:	a0a9                	j	80001e3e <scheduler+0x9a>
      release(&p->lock);
    80001df6:	8526                	mv	a0,s1
    80001df8:	e95fe0ef          	jal	80000c8c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dfc:	16848493          	addi	s1,s1,360
    80001e00:	03348563          	beq	s1,s3,80001e2a <scheduler+0x86>
      acquire(&p->lock);
    80001e04:	8526                	mv	a0,s1
    80001e06:	deffe0ef          	jal	80000bf4 <acquire>
      if(p->state == RUNNABLE) {
    80001e0a:	4c9c                	lw	a5,24(s1)
    80001e0c:	ff2795e3          	bne	a5,s2,80001df6 <scheduler+0x52>
        p->state = RUNNING;
    80001e10:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001e14:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001e18:	06048593          	addi	a1,s1,96
    80001e1c:	855a                	mv	a0,s6
    80001e1e:	5b4000ef          	jal	800023d2 <swtch>
        c->proc = 0;
    80001e22:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001e26:	8ade                	mv	s5,s7
    80001e28:	b7f9                	j	80001df6 <scheduler+0x52>
    if(found == 0) {
    80001e2a:	000a9a63          	bnez	s5,80001e3e <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001e2e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e32:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80001e36:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001e3a:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001e3e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e42:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80001e46:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001e4a:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e4c:	0000e497          	auipc	s1,0xe
    80001e50:	15448493          	addi	s1,s1,340 # 8000ffa0 <proc>
      if(p->state == RUNNABLE) {
    80001e54:	490d                	li	s2,3
    80001e56:	b77d                	j	80001e04 <scheduler+0x60>

0000000080001e58 <sched>:
{
    80001e58:	7179                	addi	sp,sp,-48
    80001e5a:	f406                	sd	ra,40(sp)
    80001e5c:	f022                	sd	s0,32(sp)
    80001e5e:	ec26                	sd	s1,24(sp)
    80001e60:	e84a                	sd	s2,16(sp)
    80001e62:	e44e                	sd	s3,8(sp)
    80001e64:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e66:	b0bff0ef          	jal	80001970 <myproc>
    80001e6a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e6c:	d1ffe0ef          	jal	80000b8a <holding>
    80001e70:	c92d                	beqz	a0,80001ee2 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r"(x));
    80001e72:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e74:	2781                	sext.w	a5,a5
    80001e76:	079e                	slli	a5,a5,0x7
    80001e78:	0000e717          	auipc	a4,0xe
    80001e7c:	cf870713          	addi	a4,a4,-776 # 8000fb70 <pid_lock>
    80001e80:	97ba                	add	a5,a5,a4
    80001e82:	0a87a703          	lw	a4,168(a5)
    80001e86:	4785                	li	a5,1
    80001e88:	06f71363          	bne	a4,a5,80001eee <sched+0x96>
  if(p->state == RUNNING)
    80001e8c:	4c98                	lw	a4,24(s1)
    80001e8e:	4791                	li	a5,4
    80001e90:	06f70563          	beq	a4,a5,80001efa <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001e94:	100027f3          	csrr	a5,sstatus
  return (r_sstatus() & SSTATUS_SIE) != 0;
    80001e98:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e9a:	e7b5                	bnez	a5,80001f06 <sched+0xae>
  asm volatile("mv %0, tp" : "=r"(x));
    80001e9c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e9e:	0000e917          	auipc	s2,0xe
    80001ea2:	cd290913          	addi	s2,s2,-814 # 8000fb70 <pid_lock>
    80001ea6:	2781                	sext.w	a5,a5
    80001ea8:	079e                	slli	a5,a5,0x7
    80001eaa:	97ca                	add	a5,a5,s2
    80001eac:	0ac7a983          	lw	s3,172(a5)
    80001eb0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001eb2:	2781                	sext.w	a5,a5
    80001eb4:	079e                	slli	a5,a5,0x7
    80001eb6:	0000e597          	auipc	a1,0xe
    80001eba:	cf258593          	addi	a1,a1,-782 # 8000fba8 <cpus+0x8>
    80001ebe:	95be                	add	a1,a1,a5
    80001ec0:	06048513          	addi	a0,s1,96
    80001ec4:	50e000ef          	jal	800023d2 <swtch>
    80001ec8:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001eca:	2781                	sext.w	a5,a5
    80001ecc:	079e                	slli	a5,a5,0x7
    80001ece:	993e                	add	s2,s2,a5
    80001ed0:	0b392623          	sw	s3,172(s2)
}
    80001ed4:	70a2                	ld	ra,40(sp)
    80001ed6:	7402                	ld	s0,32(sp)
    80001ed8:	64e2                	ld	s1,24(sp)
    80001eda:	6942                	ld	s2,16(sp)
    80001edc:	69a2                	ld	s3,8(sp)
    80001ede:	6145                	addi	sp,sp,48
    80001ee0:	8082                	ret
    panic("sched p->lock");
    80001ee2:	00005517          	auipc	a0,0x5
    80001ee6:	49650513          	addi	a0,a0,1174 # 80007378 <etext+0x378>
    80001eea:	8abfe0ef          	jal	80000794 <panic>
    panic("sched locks");
    80001eee:	00005517          	auipc	a0,0x5
    80001ef2:	49a50513          	addi	a0,a0,1178 # 80007388 <etext+0x388>
    80001ef6:	89ffe0ef          	jal	80000794 <panic>
    panic("sched running");
    80001efa:	00005517          	auipc	a0,0x5
    80001efe:	49e50513          	addi	a0,a0,1182 # 80007398 <etext+0x398>
    80001f02:	893fe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    80001f06:	00005517          	auipc	a0,0x5
    80001f0a:	4a250513          	addi	a0,a0,1186 # 800073a8 <etext+0x3a8>
    80001f0e:	887fe0ef          	jal	80000794 <panic>

0000000080001f12 <yield>:
{
    80001f12:	1101                	addi	sp,sp,-32
    80001f14:	ec06                	sd	ra,24(sp)
    80001f16:	e822                	sd	s0,16(sp)
    80001f18:	e426                	sd	s1,8(sp)
    80001f1a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f1c:	a55ff0ef          	jal	80001970 <myproc>
    80001f20:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f22:	cd3fe0ef          	jal	80000bf4 <acquire>
  p->state = RUNNABLE;
    80001f26:	478d                	li	a5,3
    80001f28:	cc9c                	sw	a5,24(s1)
  sched();
    80001f2a:	f2fff0ef          	jal	80001e58 <sched>
  release(&p->lock);
    80001f2e:	8526                	mv	a0,s1
    80001f30:	d5dfe0ef          	jal	80000c8c <release>
}
    80001f34:	60e2                	ld	ra,24(sp)
    80001f36:	6442                	ld	s0,16(sp)
    80001f38:	64a2                	ld	s1,8(sp)
    80001f3a:	6105                	addi	sp,sp,32
    80001f3c:	8082                	ret

0000000080001f3e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001f3e:	7179                	addi	sp,sp,-48
    80001f40:	f406                	sd	ra,40(sp)
    80001f42:	f022                	sd	s0,32(sp)
    80001f44:	ec26                	sd	s1,24(sp)
    80001f46:	e84a                	sd	s2,16(sp)
    80001f48:	e44e                	sd	s3,8(sp)
    80001f4a:	1800                	addi	s0,sp,48
    80001f4c:	89aa                	mv	s3,a0
    80001f4e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f50:	a21ff0ef          	jal	80001970 <myproc>
    80001f54:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001f56:	c9ffe0ef          	jal	80000bf4 <acquire>
  release(lk);
    80001f5a:	854a                	mv	a0,s2
    80001f5c:	d31fe0ef          	jal	80000c8c <release>

  // Go to sleep.
  p->chan = chan;
    80001f60:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f64:	4789                	li	a5,2
    80001f66:	cc9c                	sw	a5,24(s1)

  sched();
    80001f68:	ef1ff0ef          	jal	80001e58 <sched>

  // Tidy up.
  p->chan = 0;
    80001f6c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f70:	8526                	mv	a0,s1
    80001f72:	d1bfe0ef          	jal	80000c8c <release>
  acquire(lk);
    80001f76:	854a                	mv	a0,s2
    80001f78:	c7dfe0ef          	jal	80000bf4 <acquire>
}
    80001f7c:	70a2                	ld	ra,40(sp)
    80001f7e:	7402                	ld	s0,32(sp)
    80001f80:	64e2                	ld	s1,24(sp)
    80001f82:	6942                	ld	s2,16(sp)
    80001f84:	69a2                	ld	s3,8(sp)
    80001f86:	6145                	addi	sp,sp,48
    80001f88:	8082                	ret

0000000080001f8a <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001f8a:	7139                	addi	sp,sp,-64
    80001f8c:	fc06                	sd	ra,56(sp)
    80001f8e:	f822                	sd	s0,48(sp)
    80001f90:	f426                	sd	s1,40(sp)
    80001f92:	f04a                	sd	s2,32(sp)
    80001f94:	ec4e                	sd	s3,24(sp)
    80001f96:	e852                	sd	s4,16(sp)
    80001f98:	e456                	sd	s5,8(sp)
    80001f9a:	0080                	addi	s0,sp,64
    80001f9c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f9e:	0000e497          	auipc	s1,0xe
    80001fa2:	00248493          	addi	s1,s1,2 # 8000ffa0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001fa6:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001fa8:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001faa:	00014917          	auipc	s2,0x14
    80001fae:	9f690913          	addi	s2,s2,-1546 # 800159a0 <tickslock>
    80001fb2:	a801                	j	80001fc2 <wakeup+0x38>
      }
      release(&p->lock);
    80001fb4:	8526                	mv	a0,s1
    80001fb6:	cd7fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fba:	16848493          	addi	s1,s1,360
    80001fbe:	03248263          	beq	s1,s2,80001fe2 <wakeup+0x58>
    if(p != myproc()){
    80001fc2:	9afff0ef          	jal	80001970 <myproc>
    80001fc6:	fea48ae3          	beq	s1,a0,80001fba <wakeup+0x30>
      acquire(&p->lock);
    80001fca:	8526                	mv	a0,s1
    80001fcc:	c29fe0ef          	jal	80000bf4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001fd0:	4c9c                	lw	a5,24(s1)
    80001fd2:	ff3791e3          	bne	a5,s3,80001fb4 <wakeup+0x2a>
    80001fd6:	709c                	ld	a5,32(s1)
    80001fd8:	fd479ee3          	bne	a5,s4,80001fb4 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001fdc:	0154ac23          	sw	s5,24(s1)
    80001fe0:	bfd1                	j	80001fb4 <wakeup+0x2a>
    }
  }
}
    80001fe2:	70e2                	ld	ra,56(sp)
    80001fe4:	7442                	ld	s0,48(sp)
    80001fe6:	74a2                	ld	s1,40(sp)
    80001fe8:	7902                	ld	s2,32(sp)
    80001fea:	69e2                	ld	s3,24(sp)
    80001fec:	6a42                	ld	s4,16(sp)
    80001fee:	6aa2                	ld	s5,8(sp)
    80001ff0:	6121                	addi	sp,sp,64
    80001ff2:	8082                	ret

0000000080001ff4 <reparent>:
{
    80001ff4:	7179                	addi	sp,sp,-48
    80001ff6:	f406                	sd	ra,40(sp)
    80001ff8:	f022                	sd	s0,32(sp)
    80001ffa:	ec26                	sd	s1,24(sp)
    80001ffc:	e84a                	sd	s2,16(sp)
    80001ffe:	e44e                	sd	s3,8(sp)
    80002000:	e052                	sd	s4,0(sp)
    80002002:	1800                	addi	s0,sp,48
    80002004:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002006:	0000e497          	auipc	s1,0xe
    8000200a:	f9a48493          	addi	s1,s1,-102 # 8000ffa0 <proc>
      pp->parent = initproc;
    8000200e:	00006a17          	auipc	s4,0x6
    80002012:	a2aa0a13          	addi	s4,s4,-1494 # 80007a38 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002016:	00014997          	auipc	s3,0x14
    8000201a:	98a98993          	addi	s3,s3,-1654 # 800159a0 <tickslock>
    8000201e:	a029                	j	80002028 <reparent+0x34>
    80002020:	16848493          	addi	s1,s1,360
    80002024:	01348b63          	beq	s1,s3,8000203a <reparent+0x46>
    if(pp->parent == p){
    80002028:	7c9c                	ld	a5,56(s1)
    8000202a:	ff279be3          	bne	a5,s2,80002020 <reparent+0x2c>
      pp->parent = initproc;
    8000202e:	000a3503          	ld	a0,0(s4)
    80002032:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002034:	f57ff0ef          	jal	80001f8a <wakeup>
    80002038:	b7e5                	j	80002020 <reparent+0x2c>
}
    8000203a:	70a2                	ld	ra,40(sp)
    8000203c:	7402                	ld	s0,32(sp)
    8000203e:	64e2                	ld	s1,24(sp)
    80002040:	6942                	ld	s2,16(sp)
    80002042:	69a2                	ld	s3,8(sp)
    80002044:	6a02                	ld	s4,0(sp)
    80002046:	6145                	addi	sp,sp,48
    80002048:	8082                	ret

000000008000204a <exit>:
{
    8000204a:	7179                	addi	sp,sp,-48
    8000204c:	f406                	sd	ra,40(sp)
    8000204e:	f022                	sd	s0,32(sp)
    80002050:	ec26                	sd	s1,24(sp)
    80002052:	e84a                	sd	s2,16(sp)
    80002054:	e44e                	sd	s3,8(sp)
    80002056:	e052                	sd	s4,0(sp)
    80002058:	1800                	addi	s0,sp,48
    8000205a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000205c:	915ff0ef          	jal	80001970 <myproc>
    80002060:	89aa                	mv	s3,a0
  if(p == initproc)
    80002062:	00006797          	auipc	a5,0x6
    80002066:	9d67b783          	ld	a5,-1578(a5) # 80007a38 <initproc>
    8000206a:	0d050493          	addi	s1,a0,208
    8000206e:	15050913          	addi	s2,a0,336
    80002072:	00a79f63          	bne	a5,a0,80002090 <exit+0x46>
    panic("init exiting");
    80002076:	00005517          	auipc	a0,0x5
    8000207a:	34a50513          	addi	a0,a0,842 # 800073c0 <etext+0x3c0>
    8000207e:	f16fe0ef          	jal	80000794 <panic>
      fileclose(f);
    80002082:	67f010ef          	jal	80003f00 <fileclose>
      p->ofile[fd] = 0;
    80002086:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000208a:	04a1                	addi	s1,s1,8
    8000208c:	01248563          	beq	s1,s2,80002096 <exit+0x4c>
    if(p->ofile[fd]){
    80002090:	6088                	ld	a0,0(s1)
    80002092:	f965                	bnez	a0,80002082 <exit+0x38>
    80002094:	bfdd                	j	8000208a <exit+0x40>
  begin_op();
    80002096:	251010ef          	jal	80003ae6 <begin_op>
  iput(p->cwd);
    8000209a:	1509b503          	ld	a0,336(s3)
    8000209e:	334010ef          	jal	800033d2 <iput>
  end_op();
    800020a2:	2af010ef          	jal	80003b50 <end_op>
  p->cwd = 0;
    800020a6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800020aa:	0000e497          	auipc	s1,0xe
    800020ae:	ade48493          	addi	s1,s1,-1314 # 8000fb88 <wait_lock>
    800020b2:	8526                	mv	a0,s1
    800020b4:	b41fe0ef          	jal	80000bf4 <acquire>
  reparent(p);
    800020b8:	854e                	mv	a0,s3
    800020ba:	f3bff0ef          	jal	80001ff4 <reparent>
  wakeup(p->parent);
    800020be:	0389b503          	ld	a0,56(s3)
    800020c2:	ec9ff0ef          	jal	80001f8a <wakeup>
  acquire(&p->lock);
    800020c6:	854e                	mv	a0,s3
    800020c8:	b2dfe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    800020cc:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800020d0:	4795                	li	a5,5
    800020d2:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800020d6:	8526                	mv	a0,s1
    800020d8:	bb5fe0ef          	jal	80000c8c <release>
  sched();
    800020dc:	d7dff0ef          	jal	80001e58 <sched>
  panic("zombie exit");
    800020e0:	00005517          	auipc	a0,0x5
    800020e4:	2f050513          	addi	a0,a0,752 # 800073d0 <etext+0x3d0>
    800020e8:	eacfe0ef          	jal	80000794 <panic>

00000000800020ec <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800020ec:	7179                	addi	sp,sp,-48
    800020ee:	f406                	sd	ra,40(sp)
    800020f0:	f022                	sd	s0,32(sp)
    800020f2:	ec26                	sd	s1,24(sp)
    800020f4:	e84a                	sd	s2,16(sp)
    800020f6:	e44e                	sd	s3,8(sp)
    800020f8:	1800                	addi	s0,sp,48
    800020fa:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800020fc:	0000e497          	auipc	s1,0xe
    80002100:	ea448493          	addi	s1,s1,-348 # 8000ffa0 <proc>
    80002104:	00014997          	auipc	s3,0x14
    80002108:	89c98993          	addi	s3,s3,-1892 # 800159a0 <tickslock>
    acquire(&p->lock);
    8000210c:	8526                	mv	a0,s1
    8000210e:	ae7fe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid){
    80002112:	589c                	lw	a5,48(s1)
    80002114:	01278b63          	beq	a5,s2,8000212a <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002118:	8526                	mv	a0,s1
    8000211a:	b73fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000211e:	16848493          	addi	s1,s1,360
    80002122:	ff3495e3          	bne	s1,s3,8000210c <kill+0x20>
  }
  return -1;
    80002126:	557d                	li	a0,-1
    80002128:	a819                	j	8000213e <kill+0x52>
      p->killed = 1;
    8000212a:	4785                	li	a5,1
    8000212c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000212e:	4c98                	lw	a4,24(s1)
    80002130:	4789                	li	a5,2
    80002132:	00f70d63          	beq	a4,a5,8000214c <kill+0x60>
      release(&p->lock);
    80002136:	8526                	mv	a0,s1
    80002138:	b55fe0ef          	jal	80000c8c <release>
      return 0;
    8000213c:	4501                	li	a0,0
}
    8000213e:	70a2                	ld	ra,40(sp)
    80002140:	7402                	ld	s0,32(sp)
    80002142:	64e2                	ld	s1,24(sp)
    80002144:	6942                	ld	s2,16(sp)
    80002146:	69a2                	ld	s3,8(sp)
    80002148:	6145                	addi	sp,sp,48
    8000214a:	8082                	ret
        p->state = RUNNABLE;
    8000214c:	478d                	li	a5,3
    8000214e:	cc9c                	sw	a5,24(s1)
    80002150:	b7dd                	j	80002136 <kill+0x4a>

0000000080002152 <setkilled>:

void
setkilled(struct proc *p)
{
    80002152:	1101                	addi	sp,sp,-32
    80002154:	ec06                	sd	ra,24(sp)
    80002156:	e822                	sd	s0,16(sp)
    80002158:	e426                	sd	s1,8(sp)
    8000215a:	1000                	addi	s0,sp,32
    8000215c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000215e:	a97fe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    80002162:	4785                	li	a5,1
    80002164:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002166:	8526                	mv	a0,s1
    80002168:	b25fe0ef          	jal	80000c8c <release>
}
    8000216c:	60e2                	ld	ra,24(sp)
    8000216e:	6442                	ld	s0,16(sp)
    80002170:	64a2                	ld	s1,8(sp)
    80002172:	6105                	addi	sp,sp,32
    80002174:	8082                	ret

0000000080002176 <killed>:

int
killed(struct proc *p)
{
    80002176:	1101                	addi	sp,sp,-32
    80002178:	ec06                	sd	ra,24(sp)
    8000217a:	e822                	sd	s0,16(sp)
    8000217c:	e426                	sd	s1,8(sp)
    8000217e:	e04a                	sd	s2,0(sp)
    80002180:	1000                	addi	s0,sp,32
    80002182:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002184:	a71fe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    80002188:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000218c:	8526                	mv	a0,s1
    8000218e:	afffe0ef          	jal	80000c8c <release>
  return k;
}
    80002192:	854a                	mv	a0,s2
    80002194:	60e2                	ld	ra,24(sp)
    80002196:	6442                	ld	s0,16(sp)
    80002198:	64a2                	ld	s1,8(sp)
    8000219a:	6902                	ld	s2,0(sp)
    8000219c:	6105                	addi	sp,sp,32
    8000219e:	8082                	ret

00000000800021a0 <wait>:
{
    800021a0:	715d                	addi	sp,sp,-80
    800021a2:	e486                	sd	ra,72(sp)
    800021a4:	e0a2                	sd	s0,64(sp)
    800021a6:	fc26                	sd	s1,56(sp)
    800021a8:	f84a                	sd	s2,48(sp)
    800021aa:	f44e                	sd	s3,40(sp)
    800021ac:	f052                	sd	s4,32(sp)
    800021ae:	ec56                	sd	s5,24(sp)
    800021b0:	e85a                	sd	s6,16(sp)
    800021b2:	e45e                	sd	s7,8(sp)
    800021b4:	e062                	sd	s8,0(sp)
    800021b6:	0880                	addi	s0,sp,80
    800021b8:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800021ba:	fb6ff0ef          	jal	80001970 <myproc>
    800021be:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800021c0:	0000e517          	auipc	a0,0xe
    800021c4:	9c850513          	addi	a0,a0,-1592 # 8000fb88 <wait_lock>
    800021c8:	a2dfe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    800021cc:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800021ce:	4a15                	li	s4,5
        havekids = 1;
    800021d0:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021d2:	00013997          	auipc	s3,0x13
    800021d6:	7ce98993          	addi	s3,s3,1998 # 800159a0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021da:	0000ec17          	auipc	s8,0xe
    800021de:	9aec0c13          	addi	s8,s8,-1618 # 8000fb88 <wait_lock>
    800021e2:	a871                	j	8000227e <wait+0xde>
          pid = pp->pid;
    800021e4:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800021e8:	000b0c63          	beqz	s6,80002200 <wait+0x60>
    800021ec:	4691                	li	a3,4
    800021ee:	02c48613          	addi	a2,s1,44
    800021f2:	85da                	mv	a1,s6
    800021f4:	05093503          	ld	a0,80(s2)
    800021f8:	beaff0ef          	jal	800015e2 <copyout>
    800021fc:	02054b63          	bltz	a0,80002232 <wait+0x92>
          freeproc(pp);
    80002200:	8526                	mv	a0,s1
    80002202:	8e1ff0ef          	jal	80001ae2 <freeproc>
          release(&pp->lock);
    80002206:	8526                	mv	a0,s1
    80002208:	a85fe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    8000220c:	0000e517          	auipc	a0,0xe
    80002210:	97c50513          	addi	a0,a0,-1668 # 8000fb88 <wait_lock>
    80002214:	a79fe0ef          	jal	80000c8c <release>
}
    80002218:	854e                	mv	a0,s3
    8000221a:	60a6                	ld	ra,72(sp)
    8000221c:	6406                	ld	s0,64(sp)
    8000221e:	74e2                	ld	s1,56(sp)
    80002220:	7942                	ld	s2,48(sp)
    80002222:	79a2                	ld	s3,40(sp)
    80002224:	7a02                	ld	s4,32(sp)
    80002226:	6ae2                	ld	s5,24(sp)
    80002228:	6b42                	ld	s6,16(sp)
    8000222a:	6ba2                	ld	s7,8(sp)
    8000222c:	6c02                	ld	s8,0(sp)
    8000222e:	6161                	addi	sp,sp,80
    80002230:	8082                	ret
            release(&pp->lock);
    80002232:	8526                	mv	a0,s1
    80002234:	a59fe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    80002238:	0000e517          	auipc	a0,0xe
    8000223c:	95050513          	addi	a0,a0,-1712 # 8000fb88 <wait_lock>
    80002240:	a4dfe0ef          	jal	80000c8c <release>
            return -1;
    80002244:	59fd                	li	s3,-1
    80002246:	bfc9                	j	80002218 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002248:	16848493          	addi	s1,s1,360
    8000224c:	03348063          	beq	s1,s3,8000226c <wait+0xcc>
      if(pp->parent == p){
    80002250:	7c9c                	ld	a5,56(s1)
    80002252:	ff279be3          	bne	a5,s2,80002248 <wait+0xa8>
        acquire(&pp->lock);
    80002256:	8526                	mv	a0,s1
    80002258:	99dfe0ef          	jal	80000bf4 <acquire>
        if(pp->state == ZOMBIE){
    8000225c:	4c9c                	lw	a5,24(s1)
    8000225e:	f94783e3          	beq	a5,s4,800021e4 <wait+0x44>
        release(&pp->lock);
    80002262:	8526                	mv	a0,s1
    80002264:	a29fe0ef          	jal	80000c8c <release>
        havekids = 1;
    80002268:	8756                	mv	a4,s5
    8000226a:	bff9                	j	80002248 <wait+0xa8>
    if(!havekids || killed(p)){
    8000226c:	cf19                	beqz	a4,8000228a <wait+0xea>
    8000226e:	854a                	mv	a0,s2
    80002270:	f07ff0ef          	jal	80002176 <killed>
    80002274:	e919                	bnez	a0,8000228a <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002276:	85e2                	mv	a1,s8
    80002278:	854a                	mv	a0,s2
    8000227a:	cc5ff0ef          	jal	80001f3e <sleep>
    havekids = 0;
    8000227e:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002280:	0000e497          	auipc	s1,0xe
    80002284:	d2048493          	addi	s1,s1,-736 # 8000ffa0 <proc>
    80002288:	b7e1                	j	80002250 <wait+0xb0>
      release(&wait_lock);
    8000228a:	0000e517          	auipc	a0,0xe
    8000228e:	8fe50513          	addi	a0,a0,-1794 # 8000fb88 <wait_lock>
    80002292:	9fbfe0ef          	jal	80000c8c <release>
      return -1;
    80002296:	59fd                	li	s3,-1
    80002298:	b741                	j	80002218 <wait+0x78>

000000008000229a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000229a:	7179                	addi	sp,sp,-48
    8000229c:	f406                	sd	ra,40(sp)
    8000229e:	f022                	sd	s0,32(sp)
    800022a0:	ec26                	sd	s1,24(sp)
    800022a2:	e84a                	sd	s2,16(sp)
    800022a4:	e44e                	sd	s3,8(sp)
    800022a6:	e052                	sd	s4,0(sp)
    800022a8:	1800                	addi	s0,sp,48
    800022aa:	84aa                	mv	s1,a0
    800022ac:	892e                	mv	s2,a1
    800022ae:	89b2                	mv	s3,a2
    800022b0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022b2:	ebeff0ef          	jal	80001970 <myproc>
  if(user_dst){
    800022b6:	cc99                	beqz	s1,800022d4 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800022b8:	86d2                	mv	a3,s4
    800022ba:	864e                	mv	a2,s3
    800022bc:	85ca                	mv	a1,s2
    800022be:	6928                	ld	a0,80(a0)
    800022c0:	b22ff0ef          	jal	800015e2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800022c4:	70a2                	ld	ra,40(sp)
    800022c6:	7402                	ld	s0,32(sp)
    800022c8:	64e2                	ld	s1,24(sp)
    800022ca:	6942                	ld	s2,16(sp)
    800022cc:	69a2                	ld	s3,8(sp)
    800022ce:	6a02                	ld	s4,0(sp)
    800022d0:	6145                	addi	sp,sp,48
    800022d2:	8082                	ret
    memmove((char *)dst, src, len);
    800022d4:	000a061b          	sext.w	a2,s4
    800022d8:	85ce                	mv	a1,s3
    800022da:	854a                	mv	a0,s2
    800022dc:	a49fe0ef          	jal	80000d24 <memmove>
    return 0;
    800022e0:	8526                	mv	a0,s1
    800022e2:	b7cd                	j	800022c4 <either_copyout+0x2a>

00000000800022e4 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800022e4:	7179                	addi	sp,sp,-48
    800022e6:	f406                	sd	ra,40(sp)
    800022e8:	f022                	sd	s0,32(sp)
    800022ea:	ec26                	sd	s1,24(sp)
    800022ec:	e84a                	sd	s2,16(sp)
    800022ee:	e44e                	sd	s3,8(sp)
    800022f0:	e052                	sd	s4,0(sp)
    800022f2:	1800                	addi	s0,sp,48
    800022f4:	892a                	mv	s2,a0
    800022f6:	84ae                	mv	s1,a1
    800022f8:	89b2                	mv	s3,a2
    800022fa:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022fc:	e74ff0ef          	jal	80001970 <myproc>
  if(user_src){
    80002300:	cc99                	beqz	s1,8000231e <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002302:	86d2                	mv	a3,s4
    80002304:	864e                	mv	a2,s3
    80002306:	85ca                	mv	a1,s2
    80002308:	6928                	ld	a0,80(a0)
    8000230a:	baeff0ef          	jal	800016b8 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000230e:	70a2                	ld	ra,40(sp)
    80002310:	7402                	ld	s0,32(sp)
    80002312:	64e2                	ld	s1,24(sp)
    80002314:	6942                	ld	s2,16(sp)
    80002316:	69a2                	ld	s3,8(sp)
    80002318:	6a02                	ld	s4,0(sp)
    8000231a:	6145                	addi	sp,sp,48
    8000231c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000231e:	000a061b          	sext.w	a2,s4
    80002322:	85ce                	mv	a1,s3
    80002324:	854a                	mv	a0,s2
    80002326:	9fffe0ef          	jal	80000d24 <memmove>
    return 0;
    8000232a:	8526                	mv	a0,s1
    8000232c:	b7cd                	j	8000230e <either_copyin+0x2a>

000000008000232e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000232e:	715d                	addi	sp,sp,-80
    80002330:	e486                	sd	ra,72(sp)
    80002332:	e0a2                	sd	s0,64(sp)
    80002334:	fc26                	sd	s1,56(sp)
    80002336:	f84a                	sd	s2,48(sp)
    80002338:	f44e                	sd	s3,40(sp)
    8000233a:	f052                	sd	s4,32(sp)
    8000233c:	ec56                	sd	s5,24(sp)
    8000233e:	e85a                	sd	s6,16(sp)
    80002340:	e45e                	sd	s7,8(sp)
    80002342:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002344:	00005517          	auipc	a0,0x5
    80002348:	e7450513          	addi	a0,a0,-396 # 800071b8 <etext+0x1b8>
    8000234c:	976fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002350:	0000e497          	auipc	s1,0xe
    80002354:	da848493          	addi	s1,s1,-600 # 800100f8 <proc+0x158>
    80002358:	00013917          	auipc	s2,0x13
    8000235c:	7a090913          	addi	s2,s2,1952 # 80015af8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002360:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002362:	00005997          	auipc	s3,0x5
    80002366:	07e98993          	addi	s3,s3,126 # 800073e0 <etext+0x3e0>
    printf("%d %s %s", p->pid, state, p->name);
    8000236a:	00005a97          	auipc	s5,0x5
    8000236e:	07ea8a93          	addi	s5,s5,126 # 800073e8 <etext+0x3e8>
    printf("\n");
    80002372:	00005a17          	auipc	s4,0x5
    80002376:	e46a0a13          	addi	s4,s4,-442 # 800071b8 <etext+0x1b8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000237a:	00005b97          	auipc	s7,0x5
    8000237e:	54eb8b93          	addi	s7,s7,1358 # 800078c8 <states.0>
    80002382:	a829                	j	8000239c <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002384:	ed86a583          	lw	a1,-296(a3)
    80002388:	8556                	mv	a0,s5
    8000238a:	938fe0ef          	jal	800004c2 <printf>
    printf("\n");
    8000238e:	8552                	mv	a0,s4
    80002390:	932fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002394:	16848493          	addi	s1,s1,360
    80002398:	03248263          	beq	s1,s2,800023bc <procdump+0x8e>
    if(p->state == UNUSED)
    8000239c:	86a6                	mv	a3,s1
    8000239e:	ec04a783          	lw	a5,-320(s1)
    800023a2:	dbed                	beqz	a5,80002394 <procdump+0x66>
      state = "???";
    800023a4:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023a6:	fcfb6fe3          	bltu	s6,a5,80002384 <procdump+0x56>
    800023aa:	02079713          	slli	a4,a5,0x20
    800023ae:	01d75793          	srli	a5,a4,0x1d
    800023b2:	97de                	add	a5,a5,s7
    800023b4:	6390                	ld	a2,0(a5)
    800023b6:	f679                	bnez	a2,80002384 <procdump+0x56>
      state = "???";
    800023b8:	864e                	mv	a2,s3
    800023ba:	b7e9                	j	80002384 <procdump+0x56>
  }
}
    800023bc:	60a6                	ld	ra,72(sp)
    800023be:	6406                	ld	s0,64(sp)
    800023c0:	74e2                	ld	s1,56(sp)
    800023c2:	7942                	ld	s2,48(sp)
    800023c4:	79a2                	ld	s3,40(sp)
    800023c6:	7a02                	ld	s4,32(sp)
    800023c8:	6ae2                	ld	s5,24(sp)
    800023ca:	6b42                	ld	s6,16(sp)
    800023cc:	6ba2                	ld	s7,8(sp)
    800023ce:	6161                	addi	sp,sp,80
    800023d0:	8082                	ret

00000000800023d2 <swtch>:
    800023d2:	00153023          	sd	ra,0(a0)
    800023d6:	00253423          	sd	sp,8(a0)
    800023da:	e900                	sd	s0,16(a0)
    800023dc:	ed04                	sd	s1,24(a0)
    800023de:	03253023          	sd	s2,32(a0)
    800023e2:	03353423          	sd	s3,40(a0)
    800023e6:	03453823          	sd	s4,48(a0)
    800023ea:	03553c23          	sd	s5,56(a0)
    800023ee:	05653023          	sd	s6,64(a0)
    800023f2:	05753423          	sd	s7,72(a0)
    800023f6:	05853823          	sd	s8,80(a0)
    800023fa:	05953c23          	sd	s9,88(a0)
    800023fe:	07a53023          	sd	s10,96(a0)
    80002402:	07b53423          	sd	s11,104(a0)
    80002406:	0005b083          	ld	ra,0(a1)
    8000240a:	0085b103          	ld	sp,8(a1)
    8000240e:	6980                	ld	s0,16(a1)
    80002410:	6d84                	ld	s1,24(a1)
    80002412:	0205b903          	ld	s2,32(a1)
    80002416:	0285b983          	ld	s3,40(a1)
    8000241a:	0305ba03          	ld	s4,48(a1)
    8000241e:	0385ba83          	ld	s5,56(a1)
    80002422:	0405bb03          	ld	s6,64(a1)
    80002426:	0485bb83          	ld	s7,72(a1)
    8000242a:	0505bc03          	ld	s8,80(a1)
    8000242e:	0585bc83          	ld	s9,88(a1)
    80002432:	0605bd03          	ld	s10,96(a1)
    80002436:	0685bd83          	ld	s11,104(a1)
    8000243a:	8082                	ret

000000008000243c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000243c:	1141                	addi	sp,sp,-16
    8000243e:	e406                	sd	ra,8(sp)
    80002440:	e022                	sd	s0,0(sp)
    80002442:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002444:	00005597          	auipc	a1,0x5
    80002448:	fe458593          	addi	a1,a1,-28 # 80007428 <etext+0x428>
    8000244c:	00013517          	auipc	a0,0x13
    80002450:	55450513          	addi	a0,a0,1364 # 800159a0 <tickslock>
    80002454:	f20fe0ef          	jal	80000b74 <initlock>
}
    80002458:	60a2                	ld	ra,8(sp)
    8000245a:	6402                	ld	s0,0(sp)
    8000245c:	0141                	addi	sp,sp,16
    8000245e:	8082                	ret

0000000080002460 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002460:	1141                	addi	sp,sp,-16
    80002462:	e422                	sd	s0,8(sp)
    80002464:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002466:	00003797          	auipc	a5,0x3
    8000246a:	e0a78793          	addi	a5,a5,-502 # 80005270 <kernelvec>
    8000246e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002472:	6422                	ld	s0,8(sp)
    80002474:	0141                	addi	sp,sp,16
    80002476:	8082                	ret

0000000080002478 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002478:	1141                	addi	sp,sp,-16
    8000247a:	e406                	sd	ra,8(sp)
    8000247c:	e022                	sd	s0,0(sp)
    8000247e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002480:	cf0ff0ef          	jal	80001970 <myproc>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002484:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002488:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000248a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000248e:	00004697          	auipc	a3,0x4
    80002492:	b7268693          	addi	a3,a3,-1166 # 80006000 <_trampoline>
    80002496:	00004717          	auipc	a4,0x4
    8000249a:	b6a70713          	addi	a4,a4,-1174 # 80006000 <_trampoline>
    8000249e:	8f15                	sub	a4,a4,a3
    800024a0:	040007b7          	lui	a5,0x4000
    800024a4:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800024a6:	07b2                	slli	a5,a5,0xc
    800024a8:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r"(x));
    800024aa:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800024ae:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    800024b0:	18002673          	csrr	a2,satp
    800024b4:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800024b6:	6d30                	ld	a2,88(a0)
    800024b8:	6138                	ld	a4,64(a0)
    800024ba:	6585                	lui	a1,0x1
    800024bc:	972e                	add	a4,a4,a1
    800024be:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800024c0:	6d38                	ld	a4,88(a0)
    800024c2:	00000617          	auipc	a2,0x0
    800024c6:	11060613          	addi	a2,a2,272 # 800025d2 <usertrap>
    800024ca:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800024cc:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    800024ce:	8612                	mv	a2,tp
    800024d0:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800024d2:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800024d6:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800024da:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800024de:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800024e2:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    800024e4:	6f18                	ld	a4,24(a4)
    800024e6:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800024ea:	6928                	ld	a0,80(a0)
    800024ec:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800024ee:	00004717          	auipc	a4,0x4
    800024f2:	bae70713          	addi	a4,a4,-1106 # 8000609c <userret>
    800024f6:	8f15                	sub	a4,a4,a3
    800024f8:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800024fa:	577d                	li	a4,-1
    800024fc:	177e                	slli	a4,a4,0x3f
    800024fe:	8d59                	or	a0,a0,a4
    80002500:	9782                	jalr	a5
}
    80002502:	60a2                	ld	ra,8(sp)
    80002504:	6402                	ld	s0,0(sp)
    80002506:	0141                	addi	sp,sp,16
    80002508:	8082                	ret

000000008000250a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000250a:	1101                	addi	sp,sp,-32
    8000250c:	ec06                	sd	ra,24(sp)
    8000250e:	e822                	sd	s0,16(sp)
    80002510:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002512:	c32ff0ef          	jal	80001944 <cpuid>
    80002516:	cd11                	beqz	a0,80002532 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    80002518:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000251c:	000f4737          	lui	a4,0xf4
    80002520:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002524:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    80002526:	14d79073          	csrw	stimecmp,a5
}
    8000252a:	60e2                	ld	ra,24(sp)
    8000252c:	6442                	ld	s0,16(sp)
    8000252e:	6105                	addi	sp,sp,32
    80002530:	8082                	ret
    80002532:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002534:	00013497          	auipc	s1,0x13
    80002538:	46c48493          	addi	s1,s1,1132 # 800159a0 <tickslock>
    8000253c:	8526                	mv	a0,s1
    8000253e:	eb6fe0ef          	jal	80000bf4 <acquire>
    ticks++;
    80002542:	00005517          	auipc	a0,0x5
    80002546:	4fe50513          	addi	a0,a0,1278 # 80007a40 <ticks>
    8000254a:	411c                	lw	a5,0(a0)
    8000254c:	2785                	addiw	a5,a5,1
    8000254e:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002550:	a3bff0ef          	jal	80001f8a <wakeup>
    release(&tickslock);
    80002554:	8526                	mv	a0,s1
    80002556:	f36fe0ef          	jal	80000c8c <release>
    8000255a:	64a2                	ld	s1,8(sp)
    8000255c:	bf75                	j	80002518 <clockintr+0xe>

000000008000255e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000255e:	1101                	addi	sp,sp,-32
    80002560:	ec06                	sd	ra,24(sp)
    80002562:	e822                	sd	s0,16(sp)
    80002564:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    80002566:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    8000256a:	57fd                	li	a5,-1
    8000256c:	17fe                	slli	a5,a5,0x3f
    8000256e:	07a5                	addi	a5,a5,9
    80002570:	00f70c63          	beq	a4,a5,80002588 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002574:	57fd                	li	a5,-1
    80002576:	17fe                	slli	a5,a5,0x3f
    80002578:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000257a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000257c:	04f70763          	beq	a4,a5,800025ca <devintr+0x6c>
  }
}
    80002580:	60e2                	ld	ra,24(sp)
    80002582:	6442                	ld	s0,16(sp)
    80002584:	6105                	addi	sp,sp,32
    80002586:	8082                	ret
    80002588:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000258a:	593020ef          	jal	8000531c <plic_claim>
    8000258e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002590:	47a9                	li	a5,10
    80002592:	00f50963          	beq	a0,a5,800025a4 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002596:	4785                	li	a5,1
    80002598:	00f50963          	beq	a0,a5,800025aa <devintr+0x4c>
    return 1;
    8000259c:	4505                	li	a0,1
    } else if(irq){
    8000259e:	e889                	bnez	s1,800025b0 <devintr+0x52>
    800025a0:	64a2                	ld	s1,8(sp)
    800025a2:	bff9                	j	80002580 <devintr+0x22>
      uartintr();
    800025a4:	c62fe0ef          	jal	80000a06 <uartintr>
    if(irq)
    800025a8:	a819                	j	800025be <devintr+0x60>
      virtio_disk_intr();
    800025aa:	238030ef          	jal	800057e2 <virtio_disk_intr>
    if(irq)
    800025ae:	a801                	j	800025be <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    800025b0:	85a6                	mv	a1,s1
    800025b2:	00005517          	auipc	a0,0x5
    800025b6:	e7e50513          	addi	a0,a0,-386 # 80007430 <etext+0x430>
    800025ba:	f09fd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    800025be:	8526                	mv	a0,s1
    800025c0:	57d020ef          	jal	8000533c <plic_complete>
    return 1;
    800025c4:	4505                	li	a0,1
    800025c6:	64a2                	ld	s1,8(sp)
    800025c8:	bf65                	j	80002580 <devintr+0x22>
    clockintr();
    800025ca:	f41ff0ef          	jal	8000250a <clockintr>
    return 2;
    800025ce:	4509                	li	a0,2
    800025d0:	bf45                	j	80002580 <devintr+0x22>

00000000800025d2 <usertrap>:
{
    800025d2:	1101                	addi	sp,sp,-32
    800025d4:	ec06                	sd	ra,24(sp)
    800025d6:	e822                	sd	s0,16(sp)
    800025d8:	e426                	sd	s1,8(sp)
    800025da:	e04a                	sd	s2,0(sp)
    800025dc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800025de:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800025e2:	1007f793          	andi	a5,a5,256
    800025e6:	ef85                	bnez	a5,8000261e <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r"(x));
    800025e8:	00003797          	auipc	a5,0x3
    800025ec:	c8878793          	addi	a5,a5,-888 # 80005270 <kernelvec>
    800025f0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800025f4:	b7cff0ef          	jal	80001970 <myproc>
    800025f8:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800025fa:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    800025fc:	14102773          	csrr	a4,sepc
    80002600:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    80002602:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002606:	47a1                	li	a5,8
    80002608:	02f70163          	beq	a4,a5,8000262a <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    8000260c:	f53ff0ef          	jal	8000255e <devintr>
    80002610:	892a                	mv	s2,a0
    80002612:	c135                	beqz	a0,80002676 <usertrap+0xa4>
  if(killed(p))
    80002614:	8526                	mv	a0,s1
    80002616:	b61ff0ef          	jal	80002176 <killed>
    8000261a:	cd1d                	beqz	a0,80002658 <usertrap+0x86>
    8000261c:	a81d                	j	80002652 <usertrap+0x80>
    panic("usertrap: not from user mode");
    8000261e:	00005517          	auipc	a0,0x5
    80002622:	e3250513          	addi	a0,a0,-462 # 80007450 <etext+0x450>
    80002626:	96efe0ef          	jal	80000794 <panic>
    if(killed(p))
    8000262a:	b4dff0ef          	jal	80002176 <killed>
    8000262e:	e121                	bnez	a0,8000266e <usertrap+0x9c>
    p->trapframe->epc += 4;
    80002630:	6cb8                	ld	a4,88(s1)
    80002632:	6f1c                	ld	a5,24(a4)
    80002634:	0791                	addi	a5,a5,4
    80002636:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002638:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000263c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002640:	10079073          	csrw	sstatus,a5
    syscall();
    80002644:	248000ef          	jal	8000288c <syscall>
  if(killed(p))
    80002648:	8526                	mv	a0,s1
    8000264a:	b2dff0ef          	jal	80002176 <killed>
    8000264e:	c901                	beqz	a0,8000265e <usertrap+0x8c>
    80002650:	4901                	li	s2,0
    exit(-1);
    80002652:	557d                	li	a0,-1
    80002654:	9f7ff0ef          	jal	8000204a <exit>
  if(which_dev == 2)
    80002658:	4789                	li	a5,2
    8000265a:	04f90563          	beq	s2,a5,800026a4 <usertrap+0xd2>
  usertrapret();
    8000265e:	e1bff0ef          	jal	80002478 <usertrapret>
}
    80002662:	60e2                	ld	ra,24(sp)
    80002664:	6442                	ld	s0,16(sp)
    80002666:	64a2                	ld	s1,8(sp)
    80002668:	6902                	ld	s2,0(sp)
    8000266a:	6105                	addi	sp,sp,32
    8000266c:	8082                	ret
      exit(-1);
    8000266e:	557d                	li	a0,-1
    80002670:	9dbff0ef          	jal	8000204a <exit>
    80002674:	bf75                	j	80002630 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r"(x));
    80002676:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000267a:	5890                	lw	a2,48(s1)
    8000267c:	00005517          	auipc	a0,0x5
    80002680:	df450513          	addi	a0,a0,-524 # 80007470 <etext+0x470>
    80002684:	e3ffd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002688:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    8000268c:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002690:	00005517          	auipc	a0,0x5
    80002694:	e1050513          	addi	a0,a0,-496 # 800074a0 <etext+0x4a0>
    80002698:	e2bfd0ef          	jal	800004c2 <printf>
    setkilled(p);
    8000269c:	8526                	mv	a0,s1
    8000269e:	ab5ff0ef          	jal	80002152 <setkilled>
    800026a2:	b75d                	j	80002648 <usertrap+0x76>
    yield();
    800026a4:	86fff0ef          	jal	80001f12 <yield>
    800026a8:	bf5d                	j	8000265e <usertrap+0x8c>

00000000800026aa <kerneltrap>:
{
    800026aa:	7179                	addi	sp,sp,-48
    800026ac:	f406                	sd	ra,40(sp)
    800026ae:	f022                	sd	s0,32(sp)
    800026b0:	ec26                	sd	s1,24(sp)
    800026b2:	e84a                	sd	s2,16(sp)
    800026b4:	e44e                	sd	s3,8(sp)
    800026b6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026b8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800026bc:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    800026c0:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800026c4:	1004f793          	andi	a5,s1,256
    800026c8:	c795                	beqz	a5,800026f4 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800026ca:	100027f3          	csrr	a5,sstatus
  return (r_sstatus() & SSTATUS_SIE) != 0;
    800026ce:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800026d0:	eb85                	bnez	a5,80002700 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800026d2:	e8dff0ef          	jal	8000255e <devintr>
    800026d6:	c91d                	beqz	a0,8000270c <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800026d8:	4789                	li	a5,2
    800026da:	04f50a63          	beq	a0,a5,8000272e <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r"(x));
    800026de:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800026e2:	10049073          	csrw	sstatus,s1
}
    800026e6:	70a2                	ld	ra,40(sp)
    800026e8:	7402                	ld	s0,32(sp)
    800026ea:	64e2                	ld	s1,24(sp)
    800026ec:	6942                	ld	s2,16(sp)
    800026ee:	69a2                	ld	s3,8(sp)
    800026f0:	6145                	addi	sp,sp,48
    800026f2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800026f4:	00005517          	auipc	a0,0x5
    800026f8:	dd450513          	addi	a0,a0,-556 # 800074c8 <etext+0x4c8>
    800026fc:	898fe0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    80002700:	00005517          	auipc	a0,0x5
    80002704:	df050513          	addi	a0,a0,-528 # 800074f0 <etext+0x4f0>
    80002708:	88cfe0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000270c:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002710:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002714:	85ce                	mv	a1,s3
    80002716:	00005517          	auipc	a0,0x5
    8000271a:	dfa50513          	addi	a0,a0,-518 # 80007510 <etext+0x510>
    8000271e:	da5fd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    80002722:	00005517          	auipc	a0,0x5
    80002726:	e1650513          	addi	a0,a0,-490 # 80007538 <etext+0x538>
    8000272a:	86afe0ef          	jal	80000794 <panic>
  if(which_dev == 2 && myproc() != 0)
    8000272e:	a42ff0ef          	jal	80001970 <myproc>
    80002732:	d555                	beqz	a0,800026de <kerneltrap+0x34>
    yield();
    80002734:	fdeff0ef          	jal	80001f12 <yield>
    80002738:	b75d                	j	800026de <kerneltrap+0x34>

000000008000273a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000273a:	1101                	addi	sp,sp,-32
    8000273c:	ec06                	sd	ra,24(sp)
    8000273e:	e822                	sd	s0,16(sp)
    80002740:	e426                	sd	s1,8(sp)
    80002742:	1000                	addi	s0,sp,32
    80002744:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002746:	a2aff0ef          	jal	80001970 <myproc>
  switch (n) {
    8000274a:	4795                	li	a5,5
    8000274c:	0497e163          	bltu	a5,s1,8000278e <argraw+0x54>
    80002750:	048a                	slli	s1,s1,0x2
    80002752:	00005717          	auipc	a4,0x5
    80002756:	1a670713          	addi	a4,a4,422 # 800078f8 <states.0+0x30>
    8000275a:	94ba                	add	s1,s1,a4
    8000275c:	409c                	lw	a5,0(s1)
    8000275e:	97ba                	add	a5,a5,a4
    80002760:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002762:	6d3c                	ld	a5,88(a0)
    80002764:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002766:	60e2                	ld	ra,24(sp)
    80002768:	6442                	ld	s0,16(sp)
    8000276a:	64a2                	ld	s1,8(sp)
    8000276c:	6105                	addi	sp,sp,32
    8000276e:	8082                	ret
    return p->trapframe->a1;
    80002770:	6d3c                	ld	a5,88(a0)
    80002772:	7fa8                	ld	a0,120(a5)
    80002774:	bfcd                	j	80002766 <argraw+0x2c>
    return p->trapframe->a2;
    80002776:	6d3c                	ld	a5,88(a0)
    80002778:	63c8                	ld	a0,128(a5)
    8000277a:	b7f5                	j	80002766 <argraw+0x2c>
    return p->trapframe->a3;
    8000277c:	6d3c                	ld	a5,88(a0)
    8000277e:	67c8                	ld	a0,136(a5)
    80002780:	b7dd                	j	80002766 <argraw+0x2c>
    return p->trapframe->a4;
    80002782:	6d3c                	ld	a5,88(a0)
    80002784:	6bc8                	ld	a0,144(a5)
    80002786:	b7c5                	j	80002766 <argraw+0x2c>
    return p->trapframe->a5;
    80002788:	6d3c                	ld	a5,88(a0)
    8000278a:	6fc8                	ld	a0,152(a5)
    8000278c:	bfe9                	j	80002766 <argraw+0x2c>
  panic("argraw");
    8000278e:	00005517          	auipc	a0,0x5
    80002792:	dba50513          	addi	a0,a0,-582 # 80007548 <etext+0x548>
    80002796:	ffffd0ef          	jal	80000794 <panic>

000000008000279a <fetchaddr>:
{
    8000279a:	1101                	addi	sp,sp,-32
    8000279c:	ec06                	sd	ra,24(sp)
    8000279e:	e822                	sd	s0,16(sp)
    800027a0:	e426                	sd	s1,8(sp)
    800027a2:	e04a                	sd	s2,0(sp)
    800027a4:	1000                	addi	s0,sp,32
    800027a6:	84aa                	mv	s1,a0
    800027a8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800027aa:	9c6ff0ef          	jal	80001970 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800027ae:	653c                	ld	a5,72(a0)
    800027b0:	02f4f663          	bgeu	s1,a5,800027dc <fetchaddr+0x42>
    800027b4:	00848713          	addi	a4,s1,8
    800027b8:	02e7e463          	bltu	a5,a4,800027e0 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800027bc:	46a1                	li	a3,8
    800027be:	8626                	mv	a2,s1
    800027c0:	85ca                	mv	a1,s2
    800027c2:	6928                	ld	a0,80(a0)
    800027c4:	ef5fe0ef          	jal	800016b8 <copyin>
    800027c8:	00a03533          	snez	a0,a0
    800027cc:	40a00533          	neg	a0,a0
}
    800027d0:	60e2                	ld	ra,24(sp)
    800027d2:	6442                	ld	s0,16(sp)
    800027d4:	64a2                	ld	s1,8(sp)
    800027d6:	6902                	ld	s2,0(sp)
    800027d8:	6105                	addi	sp,sp,32
    800027da:	8082                	ret
    return -1;
    800027dc:	557d                	li	a0,-1
    800027de:	bfcd                	j	800027d0 <fetchaddr+0x36>
    800027e0:	557d                	li	a0,-1
    800027e2:	b7fd                	j	800027d0 <fetchaddr+0x36>

00000000800027e4 <fetchstr>:
{
    800027e4:	7179                	addi	sp,sp,-48
    800027e6:	f406                	sd	ra,40(sp)
    800027e8:	f022                	sd	s0,32(sp)
    800027ea:	ec26                	sd	s1,24(sp)
    800027ec:	e84a                	sd	s2,16(sp)
    800027ee:	e44e                	sd	s3,8(sp)
    800027f0:	1800                	addi	s0,sp,48
    800027f2:	892a                	mv	s2,a0
    800027f4:	84ae                	mv	s1,a1
    800027f6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800027f8:	978ff0ef          	jal	80001970 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800027fc:	86ce                	mv	a3,s3
    800027fe:	864a                	mv	a2,s2
    80002800:	85a6                	mv	a1,s1
    80002802:	6928                	ld	a0,80(a0)
    80002804:	f3bfe0ef          	jal	8000173e <copyinstr>
    80002808:	00054c63          	bltz	a0,80002820 <fetchstr+0x3c>
  return strlen(buf);
    8000280c:	8526                	mv	a0,s1
    8000280e:	e2afe0ef          	jal	80000e38 <strlen>
}
    80002812:	70a2                	ld	ra,40(sp)
    80002814:	7402                	ld	s0,32(sp)
    80002816:	64e2                	ld	s1,24(sp)
    80002818:	6942                	ld	s2,16(sp)
    8000281a:	69a2                	ld	s3,8(sp)
    8000281c:	6145                	addi	sp,sp,48
    8000281e:	8082                	ret
    return -1;
    80002820:	557d                	li	a0,-1
    80002822:	bfc5                	j	80002812 <fetchstr+0x2e>

0000000080002824 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002824:	1101                	addi	sp,sp,-32
    80002826:	ec06                	sd	ra,24(sp)
    80002828:	e822                	sd	s0,16(sp)
    8000282a:	e426                	sd	s1,8(sp)
    8000282c:	1000                	addi	s0,sp,32
    8000282e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002830:	f0bff0ef          	jal	8000273a <argraw>
    80002834:	c088                	sw	a0,0(s1)
}
    80002836:	60e2                	ld	ra,24(sp)
    80002838:	6442                	ld	s0,16(sp)
    8000283a:	64a2                	ld	s1,8(sp)
    8000283c:	6105                	addi	sp,sp,32
    8000283e:	8082                	ret

0000000080002840 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002840:	1101                	addi	sp,sp,-32
    80002842:	ec06                	sd	ra,24(sp)
    80002844:	e822                	sd	s0,16(sp)
    80002846:	e426                	sd	s1,8(sp)
    80002848:	1000                	addi	s0,sp,32
    8000284a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000284c:	eefff0ef          	jal	8000273a <argraw>
    80002850:	e088                	sd	a0,0(s1)
}
    80002852:	60e2                	ld	ra,24(sp)
    80002854:	6442                	ld	s0,16(sp)
    80002856:	64a2                	ld	s1,8(sp)
    80002858:	6105                	addi	sp,sp,32
    8000285a:	8082                	ret

000000008000285c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000285c:	7179                	addi	sp,sp,-48
    8000285e:	f406                	sd	ra,40(sp)
    80002860:	f022                	sd	s0,32(sp)
    80002862:	ec26                	sd	s1,24(sp)
    80002864:	e84a                	sd	s2,16(sp)
    80002866:	1800                	addi	s0,sp,48
    80002868:	84ae                	mv	s1,a1
    8000286a:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000286c:	fd840593          	addi	a1,s0,-40
    80002870:	fd1ff0ef          	jal	80002840 <argaddr>
  return fetchstr(addr, buf, max);
    80002874:	864a                	mv	a2,s2
    80002876:	85a6                	mv	a1,s1
    80002878:	fd843503          	ld	a0,-40(s0)
    8000287c:	f69ff0ef          	jal	800027e4 <fetchstr>
}
    80002880:	70a2                	ld	ra,40(sp)
    80002882:	7402                	ld	s0,32(sp)
    80002884:	64e2                	ld	s1,24(sp)
    80002886:	6942                	ld	s2,16(sp)
    80002888:	6145                	addi	sp,sp,48
    8000288a:	8082                	ret

000000008000288c <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    8000288c:	1101                	addi	sp,sp,-32
    8000288e:	ec06                	sd	ra,24(sp)
    80002890:	e822                	sd	s0,16(sp)
    80002892:	e426                	sd	s1,8(sp)
    80002894:	e04a                	sd	s2,0(sp)
    80002896:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002898:	8d8ff0ef          	jal	80001970 <myproc>
    8000289c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000289e:	05853903          	ld	s2,88(a0)
    800028a2:	0a893783          	ld	a5,168(s2)
    800028a6:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800028aa:	37fd                	addiw	a5,a5,-1
    800028ac:	4751                	li	a4,20
    800028ae:	00f76f63          	bltu	a4,a5,800028cc <syscall+0x40>
    800028b2:	00369713          	slli	a4,a3,0x3
    800028b6:	00005797          	auipc	a5,0x5
    800028ba:	05a78793          	addi	a5,a5,90 # 80007910 <syscalls>
    800028be:	97ba                	add	a5,a5,a4
    800028c0:	639c                	ld	a5,0(a5)
    800028c2:	c789                	beqz	a5,800028cc <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800028c4:	9782                	jalr	a5
    800028c6:	06a93823          	sd	a0,112(s2)
    800028ca:	a829                	j	800028e4 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800028cc:	15848613          	addi	a2,s1,344
    800028d0:	588c                	lw	a1,48(s1)
    800028d2:	00005517          	auipc	a0,0x5
    800028d6:	c7e50513          	addi	a0,a0,-898 # 80007550 <etext+0x550>
    800028da:	be9fd0ef          	jal	800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800028de:	6cbc                	ld	a5,88(s1)
    800028e0:	577d                	li	a4,-1
    800028e2:	fbb8                	sd	a4,112(a5)
  }
}
    800028e4:	60e2                	ld	ra,24(sp)
    800028e6:	6442                	ld	s0,16(sp)
    800028e8:	64a2                	ld	s1,8(sp)
    800028ea:	6902                	ld	s2,0(sp)
    800028ec:	6105                	addi	sp,sp,32
    800028ee:	8082                	ret

00000000800028f0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800028f0:	1101                	addi	sp,sp,-32
    800028f2:	ec06                	sd	ra,24(sp)
    800028f4:	e822                	sd	s0,16(sp)
    800028f6:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800028f8:	fec40593          	addi	a1,s0,-20
    800028fc:	4501                	li	a0,0
    800028fe:	f27ff0ef          	jal	80002824 <argint>
  exit(n);
    80002902:	fec42503          	lw	a0,-20(s0)
    80002906:	f44ff0ef          	jal	8000204a <exit>
  return 0;  // not reached
}
    8000290a:	4501                	li	a0,0
    8000290c:	60e2                	ld	ra,24(sp)
    8000290e:	6442                	ld	s0,16(sp)
    80002910:	6105                	addi	sp,sp,32
    80002912:	8082                	ret

0000000080002914 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002914:	1141                	addi	sp,sp,-16
    80002916:	e406                	sd	ra,8(sp)
    80002918:	e022                	sd	s0,0(sp)
    8000291a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000291c:	854ff0ef          	jal	80001970 <myproc>
}
    80002920:	5908                	lw	a0,48(a0)
    80002922:	60a2                	ld	ra,8(sp)
    80002924:	6402                	ld	s0,0(sp)
    80002926:	0141                	addi	sp,sp,16
    80002928:	8082                	ret

000000008000292a <sys_fork>:

uint64
sys_fork(void)
{
    8000292a:	1141                	addi	sp,sp,-16
    8000292c:	e406                	sd	ra,8(sp)
    8000292e:	e022                	sd	s0,0(sp)
    80002930:	0800                	addi	s0,sp,16
  return fork();
    80002932:	b64ff0ef          	jal	80001c96 <fork>
}
    80002936:	60a2                	ld	ra,8(sp)
    80002938:	6402                	ld	s0,0(sp)
    8000293a:	0141                	addi	sp,sp,16
    8000293c:	8082                	ret

000000008000293e <sys_wait>:

uint64
sys_wait(void)
{
    8000293e:	1101                	addi	sp,sp,-32
    80002940:	ec06                	sd	ra,24(sp)
    80002942:	e822                	sd	s0,16(sp)
    80002944:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002946:	fe840593          	addi	a1,s0,-24
    8000294a:	4501                	li	a0,0
    8000294c:	ef5ff0ef          	jal	80002840 <argaddr>
  return wait(p);
    80002950:	fe843503          	ld	a0,-24(s0)
    80002954:	84dff0ef          	jal	800021a0 <wait>
}
    80002958:	60e2                	ld	ra,24(sp)
    8000295a:	6442                	ld	s0,16(sp)
    8000295c:	6105                	addi	sp,sp,32
    8000295e:	8082                	ret

0000000080002960 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002960:	7179                	addi	sp,sp,-48
    80002962:	f406                	sd	ra,40(sp)
    80002964:	f022                	sd	s0,32(sp)
    80002966:	ec26                	sd	s1,24(sp)
    80002968:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000296a:	fdc40593          	addi	a1,s0,-36
    8000296e:	4501                	li	a0,0
    80002970:	eb5ff0ef          	jal	80002824 <argint>
  addr = myproc()->sz;
    80002974:	ffdfe0ef          	jal	80001970 <myproc>
    80002978:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    8000297a:	fdc42503          	lw	a0,-36(s0)
    8000297e:	ac8ff0ef          	jal	80001c46 <growproc>
    80002982:	00054863          	bltz	a0,80002992 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002986:	8526                	mv	a0,s1
    80002988:	70a2                	ld	ra,40(sp)
    8000298a:	7402                	ld	s0,32(sp)
    8000298c:	64e2                	ld	s1,24(sp)
    8000298e:	6145                	addi	sp,sp,48
    80002990:	8082                	ret
    return -1;
    80002992:	54fd                	li	s1,-1
    80002994:	bfcd                	j	80002986 <sys_sbrk+0x26>

0000000080002996 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002996:	7139                	addi	sp,sp,-64
    80002998:	fc06                	sd	ra,56(sp)
    8000299a:	f822                	sd	s0,48(sp)
    8000299c:	f04a                	sd	s2,32(sp)
    8000299e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800029a0:	fcc40593          	addi	a1,s0,-52
    800029a4:	4501                	li	a0,0
    800029a6:	e7fff0ef          	jal	80002824 <argint>
  if(n < 0)
    800029aa:	fcc42783          	lw	a5,-52(s0)
    800029ae:	0607c763          	bltz	a5,80002a1c <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    800029b2:	00013517          	auipc	a0,0x13
    800029b6:	fee50513          	addi	a0,a0,-18 # 800159a0 <tickslock>
    800029ba:	a3afe0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    800029be:	00005917          	auipc	s2,0x5
    800029c2:	08292903          	lw	s2,130(s2) # 80007a40 <ticks>
  while(ticks - ticks0 < n){
    800029c6:	fcc42783          	lw	a5,-52(s0)
    800029ca:	cf8d                	beqz	a5,80002a04 <sys_sleep+0x6e>
    800029cc:	f426                	sd	s1,40(sp)
    800029ce:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800029d0:	00013997          	auipc	s3,0x13
    800029d4:	fd098993          	addi	s3,s3,-48 # 800159a0 <tickslock>
    800029d8:	00005497          	auipc	s1,0x5
    800029dc:	06848493          	addi	s1,s1,104 # 80007a40 <ticks>
    if(killed(myproc())){
    800029e0:	f91fe0ef          	jal	80001970 <myproc>
    800029e4:	f92ff0ef          	jal	80002176 <killed>
    800029e8:	ed0d                	bnez	a0,80002a22 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    800029ea:	85ce                	mv	a1,s3
    800029ec:	8526                	mv	a0,s1
    800029ee:	d50ff0ef          	jal	80001f3e <sleep>
  while(ticks - ticks0 < n){
    800029f2:	409c                	lw	a5,0(s1)
    800029f4:	412787bb          	subw	a5,a5,s2
    800029f8:	fcc42703          	lw	a4,-52(s0)
    800029fc:	fee7e2e3          	bltu	a5,a4,800029e0 <sys_sleep+0x4a>
    80002a00:	74a2                	ld	s1,40(sp)
    80002a02:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002a04:	00013517          	auipc	a0,0x13
    80002a08:	f9c50513          	addi	a0,a0,-100 # 800159a0 <tickslock>
    80002a0c:	a80fe0ef          	jal	80000c8c <release>
  return 0;
    80002a10:	4501                	li	a0,0
}
    80002a12:	70e2                	ld	ra,56(sp)
    80002a14:	7442                	ld	s0,48(sp)
    80002a16:	7902                	ld	s2,32(sp)
    80002a18:	6121                	addi	sp,sp,64
    80002a1a:	8082                	ret
    n = 0;
    80002a1c:	fc042623          	sw	zero,-52(s0)
    80002a20:	bf49                	j	800029b2 <sys_sleep+0x1c>
      release(&tickslock);
    80002a22:	00013517          	auipc	a0,0x13
    80002a26:	f7e50513          	addi	a0,a0,-130 # 800159a0 <tickslock>
    80002a2a:	a62fe0ef          	jal	80000c8c <release>
      return -1;
    80002a2e:	557d                	li	a0,-1
    80002a30:	74a2                	ld	s1,40(sp)
    80002a32:	69e2                	ld	s3,24(sp)
    80002a34:	bff9                	j	80002a12 <sys_sleep+0x7c>

0000000080002a36 <sys_kill>:

uint64
sys_kill(void)
{
    80002a36:	1101                	addi	sp,sp,-32
    80002a38:	ec06                	sd	ra,24(sp)
    80002a3a:	e822                	sd	s0,16(sp)
    80002a3c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a3e:	fec40593          	addi	a1,s0,-20
    80002a42:	4501                	li	a0,0
    80002a44:	de1ff0ef          	jal	80002824 <argint>
  return kill(pid);
    80002a48:	fec42503          	lw	a0,-20(s0)
    80002a4c:	ea0ff0ef          	jal	800020ec <kill>
}
    80002a50:	60e2                	ld	ra,24(sp)
    80002a52:	6442                	ld	s0,16(sp)
    80002a54:	6105                	addi	sp,sp,32
    80002a56:	8082                	ret

0000000080002a58 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a58:	1101                	addi	sp,sp,-32
    80002a5a:	ec06                	sd	ra,24(sp)
    80002a5c:	e822                	sd	s0,16(sp)
    80002a5e:	e426                	sd	s1,8(sp)
    80002a60:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a62:	00013517          	auipc	a0,0x13
    80002a66:	f3e50513          	addi	a0,a0,-194 # 800159a0 <tickslock>
    80002a6a:	98afe0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    80002a6e:	00005497          	auipc	s1,0x5
    80002a72:	fd24a483          	lw	s1,-46(s1) # 80007a40 <ticks>
  release(&tickslock);
    80002a76:	00013517          	auipc	a0,0x13
    80002a7a:	f2a50513          	addi	a0,a0,-214 # 800159a0 <tickslock>
    80002a7e:	a0efe0ef          	jal	80000c8c <release>
  return xticks;
}
    80002a82:	02049513          	slli	a0,s1,0x20
    80002a86:	9101                	srli	a0,a0,0x20
    80002a88:	60e2                	ld	ra,24(sp)
    80002a8a:	6442                	ld	s0,16(sp)
    80002a8c:	64a2                	ld	s1,8(sp)
    80002a8e:	6105                	addi	sp,sp,32
    80002a90:	8082                	ret

0000000080002a92 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002a92:	7179                	addi	sp,sp,-48
    80002a94:	f406                	sd	ra,40(sp)
    80002a96:	f022                	sd	s0,32(sp)
    80002a98:	ec26                	sd	s1,24(sp)
    80002a9a:	e84a                	sd	s2,16(sp)
    80002a9c:	e44e                	sd	s3,8(sp)
    80002a9e:	e052                	sd	s4,0(sp)
    80002aa0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002aa2:	00005597          	auipc	a1,0x5
    80002aa6:	ace58593          	addi	a1,a1,-1330 # 80007570 <etext+0x570>
    80002aaa:	00013517          	auipc	a0,0x13
    80002aae:	f0e50513          	addi	a0,a0,-242 # 800159b8 <bcache>
    80002ab2:	8c2fe0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ab6:	0001b797          	auipc	a5,0x1b
    80002aba:	f0278793          	addi	a5,a5,-254 # 8001d9b8 <bcache+0x8000>
    80002abe:	0001b717          	auipc	a4,0x1b
    80002ac2:	16270713          	addi	a4,a4,354 # 8001dc20 <bcache+0x8268>
    80002ac6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002aca:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ace:	00013497          	auipc	s1,0x13
    80002ad2:	f0248493          	addi	s1,s1,-254 # 800159d0 <bcache+0x18>
    b->next = bcache.head.next;
    80002ad6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ad8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ada:	00005a17          	auipc	s4,0x5
    80002ade:	a9ea0a13          	addi	s4,s4,-1378 # 80007578 <etext+0x578>
    b->next = bcache.head.next;
    80002ae2:	2b893783          	ld	a5,696(s2)
    80002ae6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ae8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002aec:	85d2                	mv	a1,s4
    80002aee:	01048513          	addi	a0,s1,16
    80002af2:	248010ef          	jal	80003d3a <initsleeplock>
    bcache.head.next->prev = b;
    80002af6:	2b893783          	ld	a5,696(s2)
    80002afa:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002afc:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b00:	45848493          	addi	s1,s1,1112
    80002b04:	fd349fe3          	bne	s1,s3,80002ae2 <binit+0x50>
  }
}
    80002b08:	70a2                	ld	ra,40(sp)
    80002b0a:	7402                	ld	s0,32(sp)
    80002b0c:	64e2                	ld	s1,24(sp)
    80002b0e:	6942                	ld	s2,16(sp)
    80002b10:	69a2                	ld	s3,8(sp)
    80002b12:	6a02                	ld	s4,0(sp)
    80002b14:	6145                	addi	sp,sp,48
    80002b16:	8082                	ret

0000000080002b18 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002b18:	7179                	addi	sp,sp,-48
    80002b1a:	f406                	sd	ra,40(sp)
    80002b1c:	f022                	sd	s0,32(sp)
    80002b1e:	ec26                	sd	s1,24(sp)
    80002b20:	e84a                	sd	s2,16(sp)
    80002b22:	e44e                	sd	s3,8(sp)
    80002b24:	1800                	addi	s0,sp,48
    80002b26:	892a                	mv	s2,a0
    80002b28:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002b2a:	00013517          	auipc	a0,0x13
    80002b2e:	e8e50513          	addi	a0,a0,-370 # 800159b8 <bcache>
    80002b32:	8c2fe0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002b36:	0001b497          	auipc	s1,0x1b
    80002b3a:	13a4b483          	ld	s1,314(s1) # 8001dc70 <bcache+0x82b8>
    80002b3e:	0001b797          	auipc	a5,0x1b
    80002b42:	0e278793          	addi	a5,a5,226 # 8001dc20 <bcache+0x8268>
    80002b46:	02f48b63          	beq	s1,a5,80002b7c <bread+0x64>
    80002b4a:	873e                	mv	a4,a5
    80002b4c:	a021                	j	80002b54 <bread+0x3c>
    80002b4e:	68a4                	ld	s1,80(s1)
    80002b50:	02e48663          	beq	s1,a4,80002b7c <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002b54:	449c                	lw	a5,8(s1)
    80002b56:	ff279ce3          	bne	a5,s2,80002b4e <bread+0x36>
    80002b5a:	44dc                	lw	a5,12(s1)
    80002b5c:	ff3799e3          	bne	a5,s3,80002b4e <bread+0x36>
      b->refcnt++;
    80002b60:	40bc                	lw	a5,64(s1)
    80002b62:	2785                	addiw	a5,a5,1
    80002b64:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b66:	00013517          	auipc	a0,0x13
    80002b6a:	e5250513          	addi	a0,a0,-430 # 800159b8 <bcache>
    80002b6e:	91efe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002b72:	01048513          	addi	a0,s1,16
    80002b76:	1fa010ef          	jal	80003d70 <acquiresleep>
      return b;
    80002b7a:	a889                	j	80002bcc <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002b7c:	0001b497          	auipc	s1,0x1b
    80002b80:	0ec4b483          	ld	s1,236(s1) # 8001dc68 <bcache+0x82b0>
    80002b84:	0001b797          	auipc	a5,0x1b
    80002b88:	09c78793          	addi	a5,a5,156 # 8001dc20 <bcache+0x8268>
    80002b8c:	00f48863          	beq	s1,a5,80002b9c <bread+0x84>
    80002b90:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002b92:	40bc                	lw	a5,64(s1)
    80002b94:	cb91                	beqz	a5,80002ba8 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002b96:	64a4                	ld	s1,72(s1)
    80002b98:	fee49de3          	bne	s1,a4,80002b92 <bread+0x7a>
  panic("bget: no buffers");
    80002b9c:	00005517          	auipc	a0,0x5
    80002ba0:	9e450513          	addi	a0,a0,-1564 # 80007580 <etext+0x580>
    80002ba4:	bf1fd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80002ba8:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002bac:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002bb0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002bb4:	4785                	li	a5,1
    80002bb6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002bb8:	00013517          	auipc	a0,0x13
    80002bbc:	e0050513          	addi	a0,a0,-512 # 800159b8 <bcache>
    80002bc0:	8ccfe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002bc4:	01048513          	addi	a0,s1,16
    80002bc8:	1a8010ef          	jal	80003d70 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002bcc:	409c                	lw	a5,0(s1)
    80002bce:	cb89                	beqz	a5,80002be0 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002bd0:	8526                	mv	a0,s1
    80002bd2:	70a2                	ld	ra,40(sp)
    80002bd4:	7402                	ld	s0,32(sp)
    80002bd6:	64e2                	ld	s1,24(sp)
    80002bd8:	6942                	ld	s2,16(sp)
    80002bda:	69a2                	ld	s3,8(sp)
    80002bdc:	6145                	addi	sp,sp,48
    80002bde:	8082                	ret
    virtio_disk_rw(b, 0);
    80002be0:	4581                	li	a1,0
    80002be2:	8526                	mv	a0,s1
    80002be4:	1ed020ef          	jal	800055d0 <virtio_disk_rw>
    b->valid = 1;
    80002be8:	4785                	li	a5,1
    80002bea:	c09c                	sw	a5,0(s1)
  return b;
    80002bec:	b7d5                	j	80002bd0 <bread+0xb8>

0000000080002bee <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002bee:	1101                	addi	sp,sp,-32
    80002bf0:	ec06                	sd	ra,24(sp)
    80002bf2:	e822                	sd	s0,16(sp)
    80002bf4:	e426                	sd	s1,8(sp)
    80002bf6:	1000                	addi	s0,sp,32
    80002bf8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002bfa:	0541                	addi	a0,a0,16
    80002bfc:	1f2010ef          	jal	80003dee <holdingsleep>
    80002c00:	c911                	beqz	a0,80002c14 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002c02:	4585                	li	a1,1
    80002c04:	8526                	mv	a0,s1
    80002c06:	1cb020ef          	jal	800055d0 <virtio_disk_rw>
}
    80002c0a:	60e2                	ld	ra,24(sp)
    80002c0c:	6442                	ld	s0,16(sp)
    80002c0e:	64a2                	ld	s1,8(sp)
    80002c10:	6105                	addi	sp,sp,32
    80002c12:	8082                	ret
    panic("bwrite");
    80002c14:	00005517          	auipc	a0,0x5
    80002c18:	98450513          	addi	a0,a0,-1660 # 80007598 <etext+0x598>
    80002c1c:	b79fd0ef          	jal	80000794 <panic>

0000000080002c20 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002c20:	1101                	addi	sp,sp,-32
    80002c22:	ec06                	sd	ra,24(sp)
    80002c24:	e822                	sd	s0,16(sp)
    80002c26:	e426                	sd	s1,8(sp)
    80002c28:	e04a                	sd	s2,0(sp)
    80002c2a:	1000                	addi	s0,sp,32
    80002c2c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c2e:	01050913          	addi	s2,a0,16
    80002c32:	854a                	mv	a0,s2
    80002c34:	1ba010ef          	jal	80003dee <holdingsleep>
    80002c38:	c135                	beqz	a0,80002c9c <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002c3a:	854a                	mv	a0,s2
    80002c3c:	17a010ef          	jal	80003db6 <releasesleep>

  acquire(&bcache.lock);
    80002c40:	00013517          	auipc	a0,0x13
    80002c44:	d7850513          	addi	a0,a0,-648 # 800159b8 <bcache>
    80002c48:	fadfd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002c4c:	40bc                	lw	a5,64(s1)
    80002c4e:	37fd                	addiw	a5,a5,-1
    80002c50:	0007871b          	sext.w	a4,a5
    80002c54:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002c56:	e71d                	bnez	a4,80002c84 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002c58:	68b8                	ld	a4,80(s1)
    80002c5a:	64bc                	ld	a5,72(s1)
    80002c5c:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002c5e:	68b8                	ld	a4,80(s1)
    80002c60:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002c62:	0001b797          	auipc	a5,0x1b
    80002c66:	d5678793          	addi	a5,a5,-682 # 8001d9b8 <bcache+0x8000>
    80002c6a:	2b87b703          	ld	a4,696(a5)
    80002c6e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002c70:	0001b717          	auipc	a4,0x1b
    80002c74:	fb070713          	addi	a4,a4,-80 # 8001dc20 <bcache+0x8268>
    80002c78:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002c7a:	2b87b703          	ld	a4,696(a5)
    80002c7e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002c80:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002c84:	00013517          	auipc	a0,0x13
    80002c88:	d3450513          	addi	a0,a0,-716 # 800159b8 <bcache>
    80002c8c:	800fe0ef          	jal	80000c8c <release>
}
    80002c90:	60e2                	ld	ra,24(sp)
    80002c92:	6442                	ld	s0,16(sp)
    80002c94:	64a2                	ld	s1,8(sp)
    80002c96:	6902                	ld	s2,0(sp)
    80002c98:	6105                	addi	sp,sp,32
    80002c9a:	8082                	ret
    panic("brelse");
    80002c9c:	00005517          	auipc	a0,0x5
    80002ca0:	90450513          	addi	a0,a0,-1788 # 800075a0 <etext+0x5a0>
    80002ca4:	af1fd0ef          	jal	80000794 <panic>

0000000080002ca8 <bpin>:

void
bpin(struct buf *b) {
    80002ca8:	1101                	addi	sp,sp,-32
    80002caa:	ec06                	sd	ra,24(sp)
    80002cac:	e822                	sd	s0,16(sp)
    80002cae:	e426                	sd	s1,8(sp)
    80002cb0:	1000                	addi	s0,sp,32
    80002cb2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002cb4:	00013517          	auipc	a0,0x13
    80002cb8:	d0450513          	addi	a0,a0,-764 # 800159b8 <bcache>
    80002cbc:	f39fd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    80002cc0:	40bc                	lw	a5,64(s1)
    80002cc2:	2785                	addiw	a5,a5,1
    80002cc4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002cc6:	00013517          	auipc	a0,0x13
    80002cca:	cf250513          	addi	a0,a0,-782 # 800159b8 <bcache>
    80002cce:	fbffd0ef          	jal	80000c8c <release>
}
    80002cd2:	60e2                	ld	ra,24(sp)
    80002cd4:	6442                	ld	s0,16(sp)
    80002cd6:	64a2                	ld	s1,8(sp)
    80002cd8:	6105                	addi	sp,sp,32
    80002cda:	8082                	ret

0000000080002cdc <bunpin>:

void
bunpin(struct buf *b) {
    80002cdc:	1101                	addi	sp,sp,-32
    80002cde:	ec06                	sd	ra,24(sp)
    80002ce0:	e822                	sd	s0,16(sp)
    80002ce2:	e426                	sd	s1,8(sp)
    80002ce4:	1000                	addi	s0,sp,32
    80002ce6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ce8:	00013517          	auipc	a0,0x13
    80002cec:	cd050513          	addi	a0,a0,-816 # 800159b8 <bcache>
    80002cf0:	f05fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002cf4:	40bc                	lw	a5,64(s1)
    80002cf6:	37fd                	addiw	a5,a5,-1
    80002cf8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002cfa:	00013517          	auipc	a0,0x13
    80002cfe:	cbe50513          	addi	a0,a0,-834 # 800159b8 <bcache>
    80002d02:	f8bfd0ef          	jal	80000c8c <release>
}
    80002d06:	60e2                	ld	ra,24(sp)
    80002d08:	6442                	ld	s0,16(sp)
    80002d0a:	64a2                	ld	s1,8(sp)
    80002d0c:	6105                	addi	sp,sp,32
    80002d0e:	8082                	ret

0000000080002d10 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002d10:	1101                	addi	sp,sp,-32
    80002d12:	ec06                	sd	ra,24(sp)
    80002d14:	e822                	sd	s0,16(sp)
    80002d16:	e426                	sd	s1,8(sp)
    80002d18:	e04a                	sd	s2,0(sp)
    80002d1a:	1000                	addi	s0,sp,32
    80002d1c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002d1e:	00d5d59b          	srliw	a1,a1,0xd
    80002d22:	0001b797          	auipc	a5,0x1b
    80002d26:	3727a783          	lw	a5,882(a5) # 8001e094 <sb+0x1c>
    80002d2a:	9dbd                	addw	a1,a1,a5
    80002d2c:	dedff0ef          	jal	80002b18 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002d30:	0074f713          	andi	a4,s1,7
    80002d34:	4785                	li	a5,1
    80002d36:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002d3a:	14ce                	slli	s1,s1,0x33
    80002d3c:	90d9                	srli	s1,s1,0x36
    80002d3e:	00950733          	add	a4,a0,s1
    80002d42:	05874703          	lbu	a4,88(a4)
    80002d46:	00e7f6b3          	and	a3,a5,a4
    80002d4a:	c29d                	beqz	a3,80002d70 <bfree+0x60>
    80002d4c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002d4e:	94aa                	add	s1,s1,a0
    80002d50:	fff7c793          	not	a5,a5
    80002d54:	8f7d                	and	a4,a4,a5
    80002d56:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002d5a:	711000ef          	jal	80003c6a <log_write>
  brelse(bp);
    80002d5e:	854a                	mv	a0,s2
    80002d60:	ec1ff0ef          	jal	80002c20 <brelse>
}
    80002d64:	60e2                	ld	ra,24(sp)
    80002d66:	6442                	ld	s0,16(sp)
    80002d68:	64a2                	ld	s1,8(sp)
    80002d6a:	6902                	ld	s2,0(sp)
    80002d6c:	6105                	addi	sp,sp,32
    80002d6e:	8082                	ret
    panic("freeing free block");
    80002d70:	00005517          	auipc	a0,0x5
    80002d74:	83850513          	addi	a0,a0,-1992 # 800075a8 <etext+0x5a8>
    80002d78:	a1dfd0ef          	jal	80000794 <panic>

0000000080002d7c <balloc>:
{
    80002d7c:	711d                	addi	sp,sp,-96
    80002d7e:	ec86                	sd	ra,88(sp)
    80002d80:	e8a2                	sd	s0,80(sp)
    80002d82:	e4a6                	sd	s1,72(sp)
    80002d84:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002d86:	0001b797          	auipc	a5,0x1b
    80002d8a:	2f67a783          	lw	a5,758(a5) # 8001e07c <sb+0x4>
    80002d8e:	0e078f63          	beqz	a5,80002e8c <balloc+0x110>
    80002d92:	e0ca                	sd	s2,64(sp)
    80002d94:	fc4e                	sd	s3,56(sp)
    80002d96:	f852                	sd	s4,48(sp)
    80002d98:	f456                	sd	s5,40(sp)
    80002d9a:	f05a                	sd	s6,32(sp)
    80002d9c:	ec5e                	sd	s7,24(sp)
    80002d9e:	e862                	sd	s8,16(sp)
    80002da0:	e466                	sd	s9,8(sp)
    80002da2:	8baa                	mv	s7,a0
    80002da4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002da6:	0001bb17          	auipc	s6,0x1b
    80002daa:	2d2b0b13          	addi	s6,s6,722 # 8001e078 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002dae:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002db0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002db2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002db4:	6c89                	lui	s9,0x2
    80002db6:	a0b5                	j	80002e22 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002db8:	97ca                	add	a5,a5,s2
    80002dba:	8e55                	or	a2,a2,a3
    80002dbc:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002dc0:	854a                	mv	a0,s2
    80002dc2:	6a9000ef          	jal	80003c6a <log_write>
        brelse(bp);
    80002dc6:	854a                	mv	a0,s2
    80002dc8:	e59ff0ef          	jal	80002c20 <brelse>
  bp = bread(dev, bno);
    80002dcc:	85a6                	mv	a1,s1
    80002dce:	855e                	mv	a0,s7
    80002dd0:	d49ff0ef          	jal	80002b18 <bread>
    80002dd4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002dd6:	40000613          	li	a2,1024
    80002dda:	4581                	li	a1,0
    80002ddc:	05850513          	addi	a0,a0,88
    80002de0:	ee9fd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    80002de4:	854a                	mv	a0,s2
    80002de6:	685000ef          	jal	80003c6a <log_write>
  brelse(bp);
    80002dea:	854a                	mv	a0,s2
    80002dec:	e35ff0ef          	jal	80002c20 <brelse>
}
    80002df0:	6906                	ld	s2,64(sp)
    80002df2:	79e2                	ld	s3,56(sp)
    80002df4:	7a42                	ld	s4,48(sp)
    80002df6:	7aa2                	ld	s5,40(sp)
    80002df8:	7b02                	ld	s6,32(sp)
    80002dfa:	6be2                	ld	s7,24(sp)
    80002dfc:	6c42                	ld	s8,16(sp)
    80002dfe:	6ca2                	ld	s9,8(sp)
}
    80002e00:	8526                	mv	a0,s1
    80002e02:	60e6                	ld	ra,88(sp)
    80002e04:	6446                	ld	s0,80(sp)
    80002e06:	64a6                	ld	s1,72(sp)
    80002e08:	6125                	addi	sp,sp,96
    80002e0a:	8082                	ret
    brelse(bp);
    80002e0c:	854a                	mv	a0,s2
    80002e0e:	e13ff0ef          	jal	80002c20 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002e12:	015c87bb          	addw	a5,s9,s5
    80002e16:	00078a9b          	sext.w	s5,a5
    80002e1a:	004b2703          	lw	a4,4(s6)
    80002e1e:	04eaff63          	bgeu	s5,a4,80002e7c <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002e22:	41fad79b          	sraiw	a5,s5,0x1f
    80002e26:	0137d79b          	srliw	a5,a5,0x13
    80002e2a:	015787bb          	addw	a5,a5,s5
    80002e2e:	40d7d79b          	sraiw	a5,a5,0xd
    80002e32:	01cb2583          	lw	a1,28(s6)
    80002e36:	9dbd                	addw	a1,a1,a5
    80002e38:	855e                	mv	a0,s7
    80002e3a:	cdfff0ef          	jal	80002b18 <bread>
    80002e3e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e40:	004b2503          	lw	a0,4(s6)
    80002e44:	000a849b          	sext.w	s1,s5
    80002e48:	8762                	mv	a4,s8
    80002e4a:	fca4f1e3          	bgeu	s1,a0,80002e0c <balloc+0x90>
      m = 1 << (bi % 8);
    80002e4e:	00777693          	andi	a3,a4,7
    80002e52:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002e56:	41f7579b          	sraiw	a5,a4,0x1f
    80002e5a:	01d7d79b          	srliw	a5,a5,0x1d
    80002e5e:	9fb9                	addw	a5,a5,a4
    80002e60:	4037d79b          	sraiw	a5,a5,0x3
    80002e64:	00f90633          	add	a2,s2,a5
    80002e68:	05864603          	lbu	a2,88(a2)
    80002e6c:	00c6f5b3          	and	a1,a3,a2
    80002e70:	d5a1                	beqz	a1,80002db8 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e72:	2705                	addiw	a4,a4,1
    80002e74:	2485                	addiw	s1,s1,1
    80002e76:	fd471ae3          	bne	a4,s4,80002e4a <balloc+0xce>
    80002e7a:	bf49                	j	80002e0c <balloc+0x90>
    80002e7c:	6906                	ld	s2,64(sp)
    80002e7e:	79e2                	ld	s3,56(sp)
    80002e80:	7a42                	ld	s4,48(sp)
    80002e82:	7aa2                	ld	s5,40(sp)
    80002e84:	7b02                	ld	s6,32(sp)
    80002e86:	6be2                	ld	s7,24(sp)
    80002e88:	6c42                	ld	s8,16(sp)
    80002e8a:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002e8c:	00004517          	auipc	a0,0x4
    80002e90:	73450513          	addi	a0,a0,1844 # 800075c0 <etext+0x5c0>
    80002e94:	e2efd0ef          	jal	800004c2 <printf>
  return 0;
    80002e98:	4481                	li	s1,0
    80002e9a:	b79d                	j	80002e00 <balloc+0x84>

0000000080002e9c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002e9c:	7179                	addi	sp,sp,-48
    80002e9e:	f406                	sd	ra,40(sp)
    80002ea0:	f022                	sd	s0,32(sp)
    80002ea2:	ec26                	sd	s1,24(sp)
    80002ea4:	e84a                	sd	s2,16(sp)
    80002ea6:	e44e                	sd	s3,8(sp)
    80002ea8:	1800                	addi	s0,sp,48
    80002eaa:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002eac:	47ad                	li	a5,11
    80002eae:	02b7e663          	bltu	a5,a1,80002eda <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002eb2:	02059793          	slli	a5,a1,0x20
    80002eb6:	01e7d593          	srli	a1,a5,0x1e
    80002eba:	00b504b3          	add	s1,a0,a1
    80002ebe:	0504a903          	lw	s2,80(s1)
    80002ec2:	06091a63          	bnez	s2,80002f36 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002ec6:	4108                	lw	a0,0(a0)
    80002ec8:	eb5ff0ef          	jal	80002d7c <balloc>
    80002ecc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002ed0:	06090363          	beqz	s2,80002f36 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002ed4:	0524a823          	sw	s2,80(s1)
    80002ed8:	a8b9                	j	80002f36 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002eda:	ff45849b          	addiw	s1,a1,-12
    80002ede:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002ee2:	0ff00793          	li	a5,255
    80002ee6:	06e7ee63          	bltu	a5,a4,80002f62 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002eea:	08052903          	lw	s2,128(a0)
    80002eee:	00091d63          	bnez	s2,80002f08 <bmap+0x6c>
      addr = balloc(ip->dev);
    80002ef2:	4108                	lw	a0,0(a0)
    80002ef4:	e89ff0ef          	jal	80002d7c <balloc>
    80002ef8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002efc:	02090d63          	beqz	s2,80002f36 <bmap+0x9a>
    80002f00:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002f02:	0929a023          	sw	s2,128(s3)
    80002f06:	a011                	j	80002f0a <bmap+0x6e>
    80002f08:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002f0a:	85ca                	mv	a1,s2
    80002f0c:	0009a503          	lw	a0,0(s3)
    80002f10:	c09ff0ef          	jal	80002b18 <bread>
    80002f14:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002f16:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002f1a:	02049713          	slli	a4,s1,0x20
    80002f1e:	01e75593          	srli	a1,a4,0x1e
    80002f22:	00b784b3          	add	s1,a5,a1
    80002f26:	0004a903          	lw	s2,0(s1)
    80002f2a:	00090e63          	beqz	s2,80002f46 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002f2e:	8552                	mv	a0,s4
    80002f30:	cf1ff0ef          	jal	80002c20 <brelse>
    return addr;
    80002f34:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002f36:	854a                	mv	a0,s2
    80002f38:	70a2                	ld	ra,40(sp)
    80002f3a:	7402                	ld	s0,32(sp)
    80002f3c:	64e2                	ld	s1,24(sp)
    80002f3e:	6942                	ld	s2,16(sp)
    80002f40:	69a2                	ld	s3,8(sp)
    80002f42:	6145                	addi	sp,sp,48
    80002f44:	8082                	ret
      addr = balloc(ip->dev);
    80002f46:	0009a503          	lw	a0,0(s3)
    80002f4a:	e33ff0ef          	jal	80002d7c <balloc>
    80002f4e:	0005091b          	sext.w	s2,a0
      if(addr){
    80002f52:	fc090ee3          	beqz	s2,80002f2e <bmap+0x92>
        a[bn] = addr;
    80002f56:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002f5a:	8552                	mv	a0,s4
    80002f5c:	50f000ef          	jal	80003c6a <log_write>
    80002f60:	b7f9                	j	80002f2e <bmap+0x92>
    80002f62:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002f64:	00004517          	auipc	a0,0x4
    80002f68:	67450513          	addi	a0,a0,1652 # 800075d8 <etext+0x5d8>
    80002f6c:	829fd0ef          	jal	80000794 <panic>

0000000080002f70 <iget>:
{
    80002f70:	7179                	addi	sp,sp,-48
    80002f72:	f406                	sd	ra,40(sp)
    80002f74:	f022                	sd	s0,32(sp)
    80002f76:	ec26                	sd	s1,24(sp)
    80002f78:	e84a                	sd	s2,16(sp)
    80002f7a:	e44e                	sd	s3,8(sp)
    80002f7c:	e052                	sd	s4,0(sp)
    80002f7e:	1800                	addi	s0,sp,48
    80002f80:	89aa                	mv	s3,a0
    80002f82:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002f84:	0001b517          	auipc	a0,0x1b
    80002f88:	11450513          	addi	a0,a0,276 # 8001e098 <itable>
    80002f8c:	c69fd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    80002f90:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002f92:	0001b497          	auipc	s1,0x1b
    80002f96:	11e48493          	addi	s1,s1,286 # 8001e0b0 <itable+0x18>
    80002f9a:	0001d697          	auipc	a3,0x1d
    80002f9e:	ba668693          	addi	a3,a3,-1114 # 8001fb40 <log>
    80002fa2:	a039                	j	80002fb0 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002fa4:	02090963          	beqz	s2,80002fd6 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002fa8:	08848493          	addi	s1,s1,136
    80002fac:	02d48863          	beq	s1,a3,80002fdc <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002fb0:	449c                	lw	a5,8(s1)
    80002fb2:	fef059e3          	blez	a5,80002fa4 <iget+0x34>
    80002fb6:	4098                	lw	a4,0(s1)
    80002fb8:	ff3716e3          	bne	a4,s3,80002fa4 <iget+0x34>
    80002fbc:	40d8                	lw	a4,4(s1)
    80002fbe:	ff4713e3          	bne	a4,s4,80002fa4 <iget+0x34>
      ip->ref++;
    80002fc2:	2785                	addiw	a5,a5,1
    80002fc4:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002fc6:	0001b517          	auipc	a0,0x1b
    80002fca:	0d250513          	addi	a0,a0,210 # 8001e098 <itable>
    80002fce:	cbffd0ef          	jal	80000c8c <release>
      return ip;
    80002fd2:	8926                	mv	s2,s1
    80002fd4:	a02d                	j	80002ffe <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002fd6:	fbe9                	bnez	a5,80002fa8 <iget+0x38>
      empty = ip;
    80002fd8:	8926                	mv	s2,s1
    80002fda:	b7f9                	j	80002fa8 <iget+0x38>
  if(empty == 0)
    80002fdc:	02090a63          	beqz	s2,80003010 <iget+0xa0>
  ip->dev = dev;
    80002fe0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002fe4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002fe8:	4785                	li	a5,1
    80002fea:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002fee:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002ff2:	0001b517          	auipc	a0,0x1b
    80002ff6:	0a650513          	addi	a0,a0,166 # 8001e098 <itable>
    80002ffa:	c93fd0ef          	jal	80000c8c <release>
}
    80002ffe:	854a                	mv	a0,s2
    80003000:	70a2                	ld	ra,40(sp)
    80003002:	7402                	ld	s0,32(sp)
    80003004:	64e2                	ld	s1,24(sp)
    80003006:	6942                	ld	s2,16(sp)
    80003008:	69a2                	ld	s3,8(sp)
    8000300a:	6a02                	ld	s4,0(sp)
    8000300c:	6145                	addi	sp,sp,48
    8000300e:	8082                	ret
    panic("iget: no inodes");
    80003010:	00004517          	auipc	a0,0x4
    80003014:	5e050513          	addi	a0,a0,1504 # 800075f0 <etext+0x5f0>
    80003018:	f7cfd0ef          	jal	80000794 <panic>

000000008000301c <fsinit>:
fsinit(int dev) {
    8000301c:	7179                	addi	sp,sp,-48
    8000301e:	f406                	sd	ra,40(sp)
    80003020:	f022                	sd	s0,32(sp)
    80003022:	ec26                	sd	s1,24(sp)
    80003024:	e84a                	sd	s2,16(sp)
    80003026:	e44e                	sd	s3,8(sp)
    80003028:	1800                	addi	s0,sp,48
    8000302a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000302c:	4585                	li	a1,1
    8000302e:	aebff0ef          	jal	80002b18 <bread>
    80003032:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003034:	0001b997          	auipc	s3,0x1b
    80003038:	04498993          	addi	s3,s3,68 # 8001e078 <sb>
    8000303c:	02000613          	li	a2,32
    80003040:	05850593          	addi	a1,a0,88
    80003044:	854e                	mv	a0,s3
    80003046:	cdffd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    8000304a:	8526                	mv	a0,s1
    8000304c:	bd5ff0ef          	jal	80002c20 <brelse>
  if(sb.magic != FSMAGIC)
    80003050:	0009a703          	lw	a4,0(s3)
    80003054:	102037b7          	lui	a5,0x10203
    80003058:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000305c:	02f71063          	bne	a4,a5,8000307c <fsinit+0x60>
  initlog(dev, &sb);
    80003060:	0001b597          	auipc	a1,0x1b
    80003064:	01858593          	addi	a1,a1,24 # 8001e078 <sb>
    80003068:	854a                	mv	a0,s2
    8000306a:	1f9000ef          	jal	80003a62 <initlog>
}
    8000306e:	70a2                	ld	ra,40(sp)
    80003070:	7402                	ld	s0,32(sp)
    80003072:	64e2                	ld	s1,24(sp)
    80003074:	6942                	ld	s2,16(sp)
    80003076:	69a2                	ld	s3,8(sp)
    80003078:	6145                	addi	sp,sp,48
    8000307a:	8082                	ret
    panic("invalid file system");
    8000307c:	00004517          	auipc	a0,0x4
    80003080:	58450513          	addi	a0,a0,1412 # 80007600 <etext+0x600>
    80003084:	f10fd0ef          	jal	80000794 <panic>

0000000080003088 <iinit>:
{
    80003088:	7179                	addi	sp,sp,-48
    8000308a:	f406                	sd	ra,40(sp)
    8000308c:	f022                	sd	s0,32(sp)
    8000308e:	ec26                	sd	s1,24(sp)
    80003090:	e84a                	sd	s2,16(sp)
    80003092:	e44e                	sd	s3,8(sp)
    80003094:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003096:	00004597          	auipc	a1,0x4
    8000309a:	58258593          	addi	a1,a1,1410 # 80007618 <etext+0x618>
    8000309e:	0001b517          	auipc	a0,0x1b
    800030a2:	ffa50513          	addi	a0,a0,-6 # 8001e098 <itable>
    800030a6:	acffd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    800030aa:	0001b497          	auipc	s1,0x1b
    800030ae:	01648493          	addi	s1,s1,22 # 8001e0c0 <itable+0x28>
    800030b2:	0001d997          	auipc	s3,0x1d
    800030b6:	a9e98993          	addi	s3,s3,-1378 # 8001fb50 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800030ba:	00004917          	auipc	s2,0x4
    800030be:	56690913          	addi	s2,s2,1382 # 80007620 <etext+0x620>
    800030c2:	85ca                	mv	a1,s2
    800030c4:	8526                	mv	a0,s1
    800030c6:	475000ef          	jal	80003d3a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800030ca:	08848493          	addi	s1,s1,136
    800030ce:	ff349ae3          	bne	s1,s3,800030c2 <iinit+0x3a>
}
    800030d2:	70a2                	ld	ra,40(sp)
    800030d4:	7402                	ld	s0,32(sp)
    800030d6:	64e2                	ld	s1,24(sp)
    800030d8:	6942                	ld	s2,16(sp)
    800030da:	69a2                	ld	s3,8(sp)
    800030dc:	6145                	addi	sp,sp,48
    800030de:	8082                	ret

00000000800030e0 <ialloc>:
{
    800030e0:	7139                	addi	sp,sp,-64
    800030e2:	fc06                	sd	ra,56(sp)
    800030e4:	f822                	sd	s0,48(sp)
    800030e6:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800030e8:	0001b717          	auipc	a4,0x1b
    800030ec:	f9c72703          	lw	a4,-100(a4) # 8001e084 <sb+0xc>
    800030f0:	4785                	li	a5,1
    800030f2:	06e7f063          	bgeu	a5,a4,80003152 <ialloc+0x72>
    800030f6:	f426                	sd	s1,40(sp)
    800030f8:	f04a                	sd	s2,32(sp)
    800030fa:	ec4e                	sd	s3,24(sp)
    800030fc:	e852                	sd	s4,16(sp)
    800030fe:	e456                	sd	s5,8(sp)
    80003100:	e05a                	sd	s6,0(sp)
    80003102:	8aaa                	mv	s5,a0
    80003104:	8b2e                	mv	s6,a1
    80003106:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003108:	0001ba17          	auipc	s4,0x1b
    8000310c:	f70a0a13          	addi	s4,s4,-144 # 8001e078 <sb>
    80003110:	00495593          	srli	a1,s2,0x4
    80003114:	018a2783          	lw	a5,24(s4)
    80003118:	9dbd                	addw	a1,a1,a5
    8000311a:	8556                	mv	a0,s5
    8000311c:	9fdff0ef          	jal	80002b18 <bread>
    80003120:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003122:	05850993          	addi	s3,a0,88
    80003126:	00f97793          	andi	a5,s2,15
    8000312a:	079a                	slli	a5,a5,0x6
    8000312c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000312e:	00099783          	lh	a5,0(s3)
    80003132:	cb9d                	beqz	a5,80003168 <ialloc+0x88>
    brelse(bp);
    80003134:	aedff0ef          	jal	80002c20 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003138:	0905                	addi	s2,s2,1
    8000313a:	00ca2703          	lw	a4,12(s4)
    8000313e:	0009079b          	sext.w	a5,s2
    80003142:	fce7e7e3          	bltu	a5,a4,80003110 <ialloc+0x30>
    80003146:	74a2                	ld	s1,40(sp)
    80003148:	7902                	ld	s2,32(sp)
    8000314a:	69e2                	ld	s3,24(sp)
    8000314c:	6a42                	ld	s4,16(sp)
    8000314e:	6aa2                	ld	s5,8(sp)
    80003150:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003152:	00004517          	auipc	a0,0x4
    80003156:	4d650513          	addi	a0,a0,1238 # 80007628 <etext+0x628>
    8000315a:	b68fd0ef          	jal	800004c2 <printf>
  return 0;
    8000315e:	4501                	li	a0,0
}
    80003160:	70e2                	ld	ra,56(sp)
    80003162:	7442                	ld	s0,48(sp)
    80003164:	6121                	addi	sp,sp,64
    80003166:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003168:	04000613          	li	a2,64
    8000316c:	4581                	li	a1,0
    8000316e:	854e                	mv	a0,s3
    80003170:	b59fd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    80003174:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003178:	8526                	mv	a0,s1
    8000317a:	2f1000ef          	jal	80003c6a <log_write>
      brelse(bp);
    8000317e:	8526                	mv	a0,s1
    80003180:	aa1ff0ef          	jal	80002c20 <brelse>
      return iget(dev, inum);
    80003184:	0009059b          	sext.w	a1,s2
    80003188:	8556                	mv	a0,s5
    8000318a:	de7ff0ef          	jal	80002f70 <iget>
    8000318e:	74a2                	ld	s1,40(sp)
    80003190:	7902                	ld	s2,32(sp)
    80003192:	69e2                	ld	s3,24(sp)
    80003194:	6a42                	ld	s4,16(sp)
    80003196:	6aa2                	ld	s5,8(sp)
    80003198:	6b02                	ld	s6,0(sp)
    8000319a:	b7d9                	j	80003160 <ialloc+0x80>

000000008000319c <iupdate>:
{
    8000319c:	1101                	addi	sp,sp,-32
    8000319e:	ec06                	sd	ra,24(sp)
    800031a0:	e822                	sd	s0,16(sp)
    800031a2:	e426                	sd	s1,8(sp)
    800031a4:	e04a                	sd	s2,0(sp)
    800031a6:	1000                	addi	s0,sp,32
    800031a8:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800031aa:	415c                	lw	a5,4(a0)
    800031ac:	0047d79b          	srliw	a5,a5,0x4
    800031b0:	0001b597          	auipc	a1,0x1b
    800031b4:	ee05a583          	lw	a1,-288(a1) # 8001e090 <sb+0x18>
    800031b8:	9dbd                	addw	a1,a1,a5
    800031ba:	4108                	lw	a0,0(a0)
    800031bc:	95dff0ef          	jal	80002b18 <bread>
    800031c0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800031c2:	05850793          	addi	a5,a0,88
    800031c6:	40d8                	lw	a4,4(s1)
    800031c8:	8b3d                	andi	a4,a4,15
    800031ca:	071a                	slli	a4,a4,0x6
    800031cc:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800031ce:	04449703          	lh	a4,68(s1)
    800031d2:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800031d6:	04649703          	lh	a4,70(s1)
    800031da:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800031de:	04849703          	lh	a4,72(s1)
    800031e2:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800031e6:	04a49703          	lh	a4,74(s1)
    800031ea:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800031ee:	44f8                	lw	a4,76(s1)
    800031f0:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800031f2:	03400613          	li	a2,52
    800031f6:	05048593          	addi	a1,s1,80
    800031fa:	00c78513          	addi	a0,a5,12
    800031fe:	b27fd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    80003202:	854a                	mv	a0,s2
    80003204:	267000ef          	jal	80003c6a <log_write>
  brelse(bp);
    80003208:	854a                	mv	a0,s2
    8000320a:	a17ff0ef          	jal	80002c20 <brelse>
}
    8000320e:	60e2                	ld	ra,24(sp)
    80003210:	6442                	ld	s0,16(sp)
    80003212:	64a2                	ld	s1,8(sp)
    80003214:	6902                	ld	s2,0(sp)
    80003216:	6105                	addi	sp,sp,32
    80003218:	8082                	ret

000000008000321a <idup>:
{
    8000321a:	1101                	addi	sp,sp,-32
    8000321c:	ec06                	sd	ra,24(sp)
    8000321e:	e822                	sd	s0,16(sp)
    80003220:	e426                	sd	s1,8(sp)
    80003222:	1000                	addi	s0,sp,32
    80003224:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003226:	0001b517          	auipc	a0,0x1b
    8000322a:	e7250513          	addi	a0,a0,-398 # 8001e098 <itable>
    8000322e:	9c7fd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    80003232:	449c                	lw	a5,8(s1)
    80003234:	2785                	addiw	a5,a5,1
    80003236:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003238:	0001b517          	auipc	a0,0x1b
    8000323c:	e6050513          	addi	a0,a0,-416 # 8001e098 <itable>
    80003240:	a4dfd0ef          	jal	80000c8c <release>
}
    80003244:	8526                	mv	a0,s1
    80003246:	60e2                	ld	ra,24(sp)
    80003248:	6442                	ld	s0,16(sp)
    8000324a:	64a2                	ld	s1,8(sp)
    8000324c:	6105                	addi	sp,sp,32
    8000324e:	8082                	ret

0000000080003250 <ilock>:
{
    80003250:	1101                	addi	sp,sp,-32
    80003252:	ec06                	sd	ra,24(sp)
    80003254:	e822                	sd	s0,16(sp)
    80003256:	e426                	sd	s1,8(sp)
    80003258:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000325a:	cd19                	beqz	a0,80003278 <ilock+0x28>
    8000325c:	84aa                	mv	s1,a0
    8000325e:	451c                	lw	a5,8(a0)
    80003260:	00f05c63          	blez	a5,80003278 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003264:	0541                	addi	a0,a0,16
    80003266:	30b000ef          	jal	80003d70 <acquiresleep>
  if(ip->valid == 0){
    8000326a:	40bc                	lw	a5,64(s1)
    8000326c:	cf89                	beqz	a5,80003286 <ilock+0x36>
}
    8000326e:	60e2                	ld	ra,24(sp)
    80003270:	6442                	ld	s0,16(sp)
    80003272:	64a2                	ld	s1,8(sp)
    80003274:	6105                	addi	sp,sp,32
    80003276:	8082                	ret
    80003278:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000327a:	00004517          	auipc	a0,0x4
    8000327e:	3c650513          	addi	a0,a0,966 # 80007640 <etext+0x640>
    80003282:	d12fd0ef          	jal	80000794 <panic>
    80003286:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003288:	40dc                	lw	a5,4(s1)
    8000328a:	0047d79b          	srliw	a5,a5,0x4
    8000328e:	0001b597          	auipc	a1,0x1b
    80003292:	e025a583          	lw	a1,-510(a1) # 8001e090 <sb+0x18>
    80003296:	9dbd                	addw	a1,a1,a5
    80003298:	4088                	lw	a0,0(s1)
    8000329a:	87fff0ef          	jal	80002b18 <bread>
    8000329e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800032a0:	05850593          	addi	a1,a0,88
    800032a4:	40dc                	lw	a5,4(s1)
    800032a6:	8bbd                	andi	a5,a5,15
    800032a8:	079a                	slli	a5,a5,0x6
    800032aa:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800032ac:	00059783          	lh	a5,0(a1)
    800032b0:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800032b4:	00259783          	lh	a5,2(a1)
    800032b8:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800032bc:	00459783          	lh	a5,4(a1)
    800032c0:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800032c4:	00659783          	lh	a5,6(a1)
    800032c8:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800032cc:	459c                	lw	a5,8(a1)
    800032ce:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800032d0:	03400613          	li	a2,52
    800032d4:	05b1                	addi	a1,a1,12
    800032d6:	05048513          	addi	a0,s1,80
    800032da:	a4bfd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    800032de:	854a                	mv	a0,s2
    800032e0:	941ff0ef          	jal	80002c20 <brelse>
    ip->valid = 1;
    800032e4:	4785                	li	a5,1
    800032e6:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800032e8:	04449783          	lh	a5,68(s1)
    800032ec:	c399                	beqz	a5,800032f2 <ilock+0xa2>
    800032ee:	6902                	ld	s2,0(sp)
    800032f0:	bfbd                	j	8000326e <ilock+0x1e>
      panic("ilock: no type");
    800032f2:	00004517          	auipc	a0,0x4
    800032f6:	35650513          	addi	a0,a0,854 # 80007648 <etext+0x648>
    800032fa:	c9afd0ef          	jal	80000794 <panic>

00000000800032fe <iunlock>:
{
    800032fe:	1101                	addi	sp,sp,-32
    80003300:	ec06                	sd	ra,24(sp)
    80003302:	e822                	sd	s0,16(sp)
    80003304:	e426                	sd	s1,8(sp)
    80003306:	e04a                	sd	s2,0(sp)
    80003308:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000330a:	c505                	beqz	a0,80003332 <iunlock+0x34>
    8000330c:	84aa                	mv	s1,a0
    8000330e:	01050913          	addi	s2,a0,16
    80003312:	854a                	mv	a0,s2
    80003314:	2db000ef          	jal	80003dee <holdingsleep>
    80003318:	cd09                	beqz	a0,80003332 <iunlock+0x34>
    8000331a:	449c                	lw	a5,8(s1)
    8000331c:	00f05b63          	blez	a5,80003332 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003320:	854a                	mv	a0,s2
    80003322:	295000ef          	jal	80003db6 <releasesleep>
}
    80003326:	60e2                	ld	ra,24(sp)
    80003328:	6442                	ld	s0,16(sp)
    8000332a:	64a2                	ld	s1,8(sp)
    8000332c:	6902                	ld	s2,0(sp)
    8000332e:	6105                	addi	sp,sp,32
    80003330:	8082                	ret
    panic("iunlock");
    80003332:	00004517          	auipc	a0,0x4
    80003336:	32650513          	addi	a0,a0,806 # 80007658 <etext+0x658>
    8000333a:	c5afd0ef          	jal	80000794 <panic>

000000008000333e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000333e:	7179                	addi	sp,sp,-48
    80003340:	f406                	sd	ra,40(sp)
    80003342:	f022                	sd	s0,32(sp)
    80003344:	ec26                	sd	s1,24(sp)
    80003346:	e84a                	sd	s2,16(sp)
    80003348:	e44e                	sd	s3,8(sp)
    8000334a:	1800                	addi	s0,sp,48
    8000334c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000334e:	05050493          	addi	s1,a0,80
    80003352:	08050913          	addi	s2,a0,128
    80003356:	a021                	j	8000335e <itrunc+0x20>
    80003358:	0491                	addi	s1,s1,4
    8000335a:	01248b63          	beq	s1,s2,80003370 <itrunc+0x32>
    if(ip->addrs[i]){
    8000335e:	408c                	lw	a1,0(s1)
    80003360:	dde5                	beqz	a1,80003358 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003362:	0009a503          	lw	a0,0(s3)
    80003366:	9abff0ef          	jal	80002d10 <bfree>
      ip->addrs[i] = 0;
    8000336a:	0004a023          	sw	zero,0(s1)
    8000336e:	b7ed                	j	80003358 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003370:	0809a583          	lw	a1,128(s3)
    80003374:	ed89                	bnez	a1,8000338e <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003376:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000337a:	854e                	mv	a0,s3
    8000337c:	e21ff0ef          	jal	8000319c <iupdate>
}
    80003380:	70a2                	ld	ra,40(sp)
    80003382:	7402                	ld	s0,32(sp)
    80003384:	64e2                	ld	s1,24(sp)
    80003386:	6942                	ld	s2,16(sp)
    80003388:	69a2                	ld	s3,8(sp)
    8000338a:	6145                	addi	sp,sp,48
    8000338c:	8082                	ret
    8000338e:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003390:	0009a503          	lw	a0,0(s3)
    80003394:	f84ff0ef          	jal	80002b18 <bread>
    80003398:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000339a:	05850493          	addi	s1,a0,88
    8000339e:	45850913          	addi	s2,a0,1112
    800033a2:	a021                	j	800033aa <itrunc+0x6c>
    800033a4:	0491                	addi	s1,s1,4
    800033a6:	01248963          	beq	s1,s2,800033b8 <itrunc+0x7a>
      if(a[j])
    800033aa:	408c                	lw	a1,0(s1)
    800033ac:	dde5                	beqz	a1,800033a4 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800033ae:	0009a503          	lw	a0,0(s3)
    800033b2:	95fff0ef          	jal	80002d10 <bfree>
    800033b6:	b7fd                	j	800033a4 <itrunc+0x66>
    brelse(bp);
    800033b8:	8552                	mv	a0,s4
    800033ba:	867ff0ef          	jal	80002c20 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800033be:	0809a583          	lw	a1,128(s3)
    800033c2:	0009a503          	lw	a0,0(s3)
    800033c6:	94bff0ef          	jal	80002d10 <bfree>
    ip->addrs[NDIRECT] = 0;
    800033ca:	0809a023          	sw	zero,128(s3)
    800033ce:	6a02                	ld	s4,0(sp)
    800033d0:	b75d                	j	80003376 <itrunc+0x38>

00000000800033d2 <iput>:
{
    800033d2:	1101                	addi	sp,sp,-32
    800033d4:	ec06                	sd	ra,24(sp)
    800033d6:	e822                	sd	s0,16(sp)
    800033d8:	e426                	sd	s1,8(sp)
    800033da:	1000                	addi	s0,sp,32
    800033dc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033de:	0001b517          	auipc	a0,0x1b
    800033e2:	cba50513          	addi	a0,a0,-838 # 8001e098 <itable>
    800033e6:	80ffd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800033ea:	4498                	lw	a4,8(s1)
    800033ec:	4785                	li	a5,1
    800033ee:	02f70063          	beq	a4,a5,8000340e <iput+0x3c>
  ip->ref--;
    800033f2:	449c                	lw	a5,8(s1)
    800033f4:	37fd                	addiw	a5,a5,-1
    800033f6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033f8:	0001b517          	auipc	a0,0x1b
    800033fc:	ca050513          	addi	a0,a0,-864 # 8001e098 <itable>
    80003400:	88dfd0ef          	jal	80000c8c <release>
}
    80003404:	60e2                	ld	ra,24(sp)
    80003406:	6442                	ld	s0,16(sp)
    80003408:	64a2                	ld	s1,8(sp)
    8000340a:	6105                	addi	sp,sp,32
    8000340c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000340e:	40bc                	lw	a5,64(s1)
    80003410:	d3ed                	beqz	a5,800033f2 <iput+0x20>
    80003412:	04a49783          	lh	a5,74(s1)
    80003416:	fff1                	bnez	a5,800033f2 <iput+0x20>
    80003418:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000341a:	01048913          	addi	s2,s1,16
    8000341e:	854a                	mv	a0,s2
    80003420:	151000ef          	jal	80003d70 <acquiresleep>
    release(&itable.lock);
    80003424:	0001b517          	auipc	a0,0x1b
    80003428:	c7450513          	addi	a0,a0,-908 # 8001e098 <itable>
    8000342c:	861fd0ef          	jal	80000c8c <release>
    itrunc(ip);
    80003430:	8526                	mv	a0,s1
    80003432:	f0dff0ef          	jal	8000333e <itrunc>
    ip->type = 0;
    80003436:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000343a:	8526                	mv	a0,s1
    8000343c:	d61ff0ef          	jal	8000319c <iupdate>
    ip->valid = 0;
    80003440:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003444:	854a                	mv	a0,s2
    80003446:	171000ef          	jal	80003db6 <releasesleep>
    acquire(&itable.lock);
    8000344a:	0001b517          	auipc	a0,0x1b
    8000344e:	c4e50513          	addi	a0,a0,-946 # 8001e098 <itable>
    80003452:	fa2fd0ef          	jal	80000bf4 <acquire>
    80003456:	6902                	ld	s2,0(sp)
    80003458:	bf69                	j	800033f2 <iput+0x20>

000000008000345a <iunlockput>:
{
    8000345a:	1101                	addi	sp,sp,-32
    8000345c:	ec06                	sd	ra,24(sp)
    8000345e:	e822                	sd	s0,16(sp)
    80003460:	e426                	sd	s1,8(sp)
    80003462:	1000                	addi	s0,sp,32
    80003464:	84aa                	mv	s1,a0
  iunlock(ip);
    80003466:	e99ff0ef          	jal	800032fe <iunlock>
  iput(ip);
    8000346a:	8526                	mv	a0,s1
    8000346c:	f67ff0ef          	jal	800033d2 <iput>
}
    80003470:	60e2                	ld	ra,24(sp)
    80003472:	6442                	ld	s0,16(sp)
    80003474:	64a2                	ld	s1,8(sp)
    80003476:	6105                	addi	sp,sp,32
    80003478:	8082                	ret

000000008000347a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000347a:	1141                	addi	sp,sp,-16
    8000347c:	e422                	sd	s0,8(sp)
    8000347e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003480:	411c                	lw	a5,0(a0)
    80003482:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003484:	415c                	lw	a5,4(a0)
    80003486:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003488:	04451783          	lh	a5,68(a0)
    8000348c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003490:	04a51783          	lh	a5,74(a0)
    80003494:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003498:	04c56783          	lwu	a5,76(a0)
    8000349c:	e99c                	sd	a5,16(a1)
}
    8000349e:	6422                	ld	s0,8(sp)
    800034a0:	0141                	addi	sp,sp,16
    800034a2:	8082                	ret

00000000800034a4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800034a4:	457c                	lw	a5,76(a0)
    800034a6:	0ed7eb63          	bltu	a5,a3,8000359c <readi+0xf8>
{
    800034aa:	7159                	addi	sp,sp,-112
    800034ac:	f486                	sd	ra,104(sp)
    800034ae:	f0a2                	sd	s0,96(sp)
    800034b0:	eca6                	sd	s1,88(sp)
    800034b2:	e0d2                	sd	s4,64(sp)
    800034b4:	fc56                	sd	s5,56(sp)
    800034b6:	f85a                	sd	s6,48(sp)
    800034b8:	f45e                	sd	s7,40(sp)
    800034ba:	1880                	addi	s0,sp,112
    800034bc:	8b2a                	mv	s6,a0
    800034be:	8bae                	mv	s7,a1
    800034c0:	8a32                	mv	s4,a2
    800034c2:	84b6                	mv	s1,a3
    800034c4:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800034c6:	9f35                	addw	a4,a4,a3
    return 0;
    800034c8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800034ca:	0cd76063          	bltu	a4,a3,8000358a <readi+0xe6>
    800034ce:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800034d0:	00e7f463          	bgeu	a5,a4,800034d8 <readi+0x34>
    n = ip->size - off;
    800034d4:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800034d8:	080a8f63          	beqz	s5,80003576 <readi+0xd2>
    800034dc:	e8ca                	sd	s2,80(sp)
    800034de:	f062                	sd	s8,32(sp)
    800034e0:	ec66                	sd	s9,24(sp)
    800034e2:	e86a                	sd	s10,16(sp)
    800034e4:	e46e                	sd	s11,8(sp)
    800034e6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800034e8:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800034ec:	5c7d                	li	s8,-1
    800034ee:	a80d                	j	80003520 <readi+0x7c>
    800034f0:	020d1d93          	slli	s11,s10,0x20
    800034f4:	020ddd93          	srli	s11,s11,0x20
    800034f8:	05890613          	addi	a2,s2,88
    800034fc:	86ee                	mv	a3,s11
    800034fe:	963a                	add	a2,a2,a4
    80003500:	85d2                	mv	a1,s4
    80003502:	855e                	mv	a0,s7
    80003504:	d97fe0ef          	jal	8000229a <either_copyout>
    80003508:	05850763          	beq	a0,s8,80003556 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000350c:	854a                	mv	a0,s2
    8000350e:	f12ff0ef          	jal	80002c20 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003512:	013d09bb          	addw	s3,s10,s3
    80003516:	009d04bb          	addw	s1,s10,s1
    8000351a:	9a6e                	add	s4,s4,s11
    8000351c:	0559f763          	bgeu	s3,s5,8000356a <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003520:	00a4d59b          	srliw	a1,s1,0xa
    80003524:	855a                	mv	a0,s6
    80003526:	977ff0ef          	jal	80002e9c <bmap>
    8000352a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000352e:	c5b1                	beqz	a1,8000357a <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003530:	000b2503          	lw	a0,0(s6)
    80003534:	de4ff0ef          	jal	80002b18 <bread>
    80003538:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000353a:	3ff4f713          	andi	a4,s1,1023
    8000353e:	40ec87bb          	subw	a5,s9,a4
    80003542:	413a86bb          	subw	a3,s5,s3
    80003546:	8d3e                	mv	s10,a5
    80003548:	2781                	sext.w	a5,a5
    8000354a:	0006861b          	sext.w	a2,a3
    8000354e:	faf671e3          	bgeu	a2,a5,800034f0 <readi+0x4c>
    80003552:	8d36                	mv	s10,a3
    80003554:	bf71                	j	800034f0 <readi+0x4c>
      brelse(bp);
    80003556:	854a                	mv	a0,s2
    80003558:	ec8ff0ef          	jal	80002c20 <brelse>
      tot = -1;
    8000355c:	59fd                	li	s3,-1
      break;
    8000355e:	6946                	ld	s2,80(sp)
    80003560:	7c02                	ld	s8,32(sp)
    80003562:	6ce2                	ld	s9,24(sp)
    80003564:	6d42                	ld	s10,16(sp)
    80003566:	6da2                	ld	s11,8(sp)
    80003568:	a831                	j	80003584 <readi+0xe0>
    8000356a:	6946                	ld	s2,80(sp)
    8000356c:	7c02                	ld	s8,32(sp)
    8000356e:	6ce2                	ld	s9,24(sp)
    80003570:	6d42                	ld	s10,16(sp)
    80003572:	6da2                	ld	s11,8(sp)
    80003574:	a801                	j	80003584 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003576:	89d6                	mv	s3,s5
    80003578:	a031                	j	80003584 <readi+0xe0>
    8000357a:	6946                	ld	s2,80(sp)
    8000357c:	7c02                	ld	s8,32(sp)
    8000357e:	6ce2                	ld	s9,24(sp)
    80003580:	6d42                	ld	s10,16(sp)
    80003582:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003584:	0009851b          	sext.w	a0,s3
    80003588:	69a6                	ld	s3,72(sp)
}
    8000358a:	70a6                	ld	ra,104(sp)
    8000358c:	7406                	ld	s0,96(sp)
    8000358e:	64e6                	ld	s1,88(sp)
    80003590:	6a06                	ld	s4,64(sp)
    80003592:	7ae2                	ld	s5,56(sp)
    80003594:	7b42                	ld	s6,48(sp)
    80003596:	7ba2                	ld	s7,40(sp)
    80003598:	6165                	addi	sp,sp,112
    8000359a:	8082                	ret
    return 0;
    8000359c:	4501                	li	a0,0
}
    8000359e:	8082                	ret

00000000800035a0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800035a0:	457c                	lw	a5,76(a0)
    800035a2:	10d7e063          	bltu	a5,a3,800036a2 <writei+0x102>
{
    800035a6:	7159                	addi	sp,sp,-112
    800035a8:	f486                	sd	ra,104(sp)
    800035aa:	f0a2                	sd	s0,96(sp)
    800035ac:	e8ca                	sd	s2,80(sp)
    800035ae:	e0d2                	sd	s4,64(sp)
    800035b0:	fc56                	sd	s5,56(sp)
    800035b2:	f85a                	sd	s6,48(sp)
    800035b4:	f45e                	sd	s7,40(sp)
    800035b6:	1880                	addi	s0,sp,112
    800035b8:	8aaa                	mv	s5,a0
    800035ba:	8bae                	mv	s7,a1
    800035bc:	8a32                	mv	s4,a2
    800035be:	8936                	mv	s2,a3
    800035c0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800035c2:	00e687bb          	addw	a5,a3,a4
    800035c6:	0ed7e063          	bltu	a5,a3,800036a6 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800035ca:	00043737          	lui	a4,0x43
    800035ce:	0cf76e63          	bltu	a4,a5,800036aa <writei+0x10a>
    800035d2:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800035d4:	0a0b0f63          	beqz	s6,80003692 <writei+0xf2>
    800035d8:	eca6                	sd	s1,88(sp)
    800035da:	f062                	sd	s8,32(sp)
    800035dc:	ec66                	sd	s9,24(sp)
    800035de:	e86a                	sd	s10,16(sp)
    800035e0:	e46e                	sd	s11,8(sp)
    800035e2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800035e4:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800035e8:	5c7d                	li	s8,-1
    800035ea:	a825                	j	80003622 <writei+0x82>
    800035ec:	020d1d93          	slli	s11,s10,0x20
    800035f0:	020ddd93          	srli	s11,s11,0x20
    800035f4:	05848513          	addi	a0,s1,88
    800035f8:	86ee                	mv	a3,s11
    800035fa:	8652                	mv	a2,s4
    800035fc:	85de                	mv	a1,s7
    800035fe:	953a                	add	a0,a0,a4
    80003600:	ce5fe0ef          	jal	800022e4 <either_copyin>
    80003604:	05850a63          	beq	a0,s8,80003658 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003608:	8526                	mv	a0,s1
    8000360a:	660000ef          	jal	80003c6a <log_write>
    brelse(bp);
    8000360e:	8526                	mv	a0,s1
    80003610:	e10ff0ef          	jal	80002c20 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003614:	013d09bb          	addw	s3,s10,s3
    80003618:	012d093b          	addw	s2,s10,s2
    8000361c:	9a6e                	add	s4,s4,s11
    8000361e:	0569f063          	bgeu	s3,s6,8000365e <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003622:	00a9559b          	srliw	a1,s2,0xa
    80003626:	8556                	mv	a0,s5
    80003628:	875ff0ef          	jal	80002e9c <bmap>
    8000362c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003630:	c59d                	beqz	a1,8000365e <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003632:	000aa503          	lw	a0,0(s5)
    80003636:	ce2ff0ef          	jal	80002b18 <bread>
    8000363a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000363c:	3ff97713          	andi	a4,s2,1023
    80003640:	40ec87bb          	subw	a5,s9,a4
    80003644:	413b06bb          	subw	a3,s6,s3
    80003648:	8d3e                	mv	s10,a5
    8000364a:	2781                	sext.w	a5,a5
    8000364c:	0006861b          	sext.w	a2,a3
    80003650:	f8f67ee3          	bgeu	a2,a5,800035ec <writei+0x4c>
    80003654:	8d36                	mv	s10,a3
    80003656:	bf59                	j	800035ec <writei+0x4c>
      brelse(bp);
    80003658:	8526                	mv	a0,s1
    8000365a:	dc6ff0ef          	jal	80002c20 <brelse>
  }

  if(off > ip->size)
    8000365e:	04caa783          	lw	a5,76(s5)
    80003662:	0327fa63          	bgeu	a5,s2,80003696 <writei+0xf6>
    ip->size = off;
    80003666:	052aa623          	sw	s2,76(s5)
    8000366a:	64e6                	ld	s1,88(sp)
    8000366c:	7c02                	ld	s8,32(sp)
    8000366e:	6ce2                	ld	s9,24(sp)
    80003670:	6d42                	ld	s10,16(sp)
    80003672:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003674:	8556                	mv	a0,s5
    80003676:	b27ff0ef          	jal	8000319c <iupdate>

  return tot;
    8000367a:	0009851b          	sext.w	a0,s3
    8000367e:	69a6                	ld	s3,72(sp)
}
    80003680:	70a6                	ld	ra,104(sp)
    80003682:	7406                	ld	s0,96(sp)
    80003684:	6946                	ld	s2,80(sp)
    80003686:	6a06                	ld	s4,64(sp)
    80003688:	7ae2                	ld	s5,56(sp)
    8000368a:	7b42                	ld	s6,48(sp)
    8000368c:	7ba2                	ld	s7,40(sp)
    8000368e:	6165                	addi	sp,sp,112
    80003690:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003692:	89da                	mv	s3,s6
    80003694:	b7c5                	j	80003674 <writei+0xd4>
    80003696:	64e6                	ld	s1,88(sp)
    80003698:	7c02                	ld	s8,32(sp)
    8000369a:	6ce2                	ld	s9,24(sp)
    8000369c:	6d42                	ld	s10,16(sp)
    8000369e:	6da2                	ld	s11,8(sp)
    800036a0:	bfd1                	j	80003674 <writei+0xd4>
    return -1;
    800036a2:	557d                	li	a0,-1
}
    800036a4:	8082                	ret
    return -1;
    800036a6:	557d                	li	a0,-1
    800036a8:	bfe1                	j	80003680 <writei+0xe0>
    return -1;
    800036aa:	557d                	li	a0,-1
    800036ac:	bfd1                	j	80003680 <writei+0xe0>

00000000800036ae <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800036ae:	1141                	addi	sp,sp,-16
    800036b0:	e406                	sd	ra,8(sp)
    800036b2:	e022                	sd	s0,0(sp)
    800036b4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800036b6:	4639                	li	a2,14
    800036b8:	edcfd0ef          	jal	80000d94 <strncmp>
}
    800036bc:	60a2                	ld	ra,8(sp)
    800036be:	6402                	ld	s0,0(sp)
    800036c0:	0141                	addi	sp,sp,16
    800036c2:	8082                	ret

00000000800036c4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800036c4:	7139                	addi	sp,sp,-64
    800036c6:	fc06                	sd	ra,56(sp)
    800036c8:	f822                	sd	s0,48(sp)
    800036ca:	f426                	sd	s1,40(sp)
    800036cc:	f04a                	sd	s2,32(sp)
    800036ce:	ec4e                	sd	s3,24(sp)
    800036d0:	e852                	sd	s4,16(sp)
    800036d2:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800036d4:	04451703          	lh	a4,68(a0)
    800036d8:	4785                	li	a5,1
    800036da:	00f71a63          	bne	a4,a5,800036ee <dirlookup+0x2a>
    800036de:	892a                	mv	s2,a0
    800036e0:	89ae                	mv	s3,a1
    800036e2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800036e4:	457c                	lw	a5,76(a0)
    800036e6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800036e8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800036ea:	e39d                	bnez	a5,80003710 <dirlookup+0x4c>
    800036ec:	a095                	j	80003750 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800036ee:	00004517          	auipc	a0,0x4
    800036f2:	f7250513          	addi	a0,a0,-142 # 80007660 <etext+0x660>
    800036f6:	89efd0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    800036fa:	00004517          	auipc	a0,0x4
    800036fe:	f7e50513          	addi	a0,a0,-130 # 80007678 <etext+0x678>
    80003702:	892fd0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003706:	24c1                	addiw	s1,s1,16
    80003708:	04c92783          	lw	a5,76(s2)
    8000370c:	04f4f163          	bgeu	s1,a5,8000374e <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003710:	4741                	li	a4,16
    80003712:	86a6                	mv	a3,s1
    80003714:	fc040613          	addi	a2,s0,-64
    80003718:	4581                	li	a1,0
    8000371a:	854a                	mv	a0,s2
    8000371c:	d89ff0ef          	jal	800034a4 <readi>
    80003720:	47c1                	li	a5,16
    80003722:	fcf51ce3          	bne	a0,a5,800036fa <dirlookup+0x36>
    if(de.inum == 0)
    80003726:	fc045783          	lhu	a5,-64(s0)
    8000372a:	dff1                	beqz	a5,80003706 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    8000372c:	fc240593          	addi	a1,s0,-62
    80003730:	854e                	mv	a0,s3
    80003732:	f7dff0ef          	jal	800036ae <namecmp>
    80003736:	f961                	bnez	a0,80003706 <dirlookup+0x42>
      if(poff)
    80003738:	000a0463          	beqz	s4,80003740 <dirlookup+0x7c>
        *poff = off;
    8000373c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003740:	fc045583          	lhu	a1,-64(s0)
    80003744:	00092503          	lw	a0,0(s2)
    80003748:	829ff0ef          	jal	80002f70 <iget>
    8000374c:	a011                	j	80003750 <dirlookup+0x8c>
  return 0;
    8000374e:	4501                	li	a0,0
}
    80003750:	70e2                	ld	ra,56(sp)
    80003752:	7442                	ld	s0,48(sp)
    80003754:	74a2                	ld	s1,40(sp)
    80003756:	7902                	ld	s2,32(sp)
    80003758:	69e2                	ld	s3,24(sp)
    8000375a:	6a42                	ld	s4,16(sp)
    8000375c:	6121                	addi	sp,sp,64
    8000375e:	8082                	ret

0000000080003760 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003760:	711d                	addi	sp,sp,-96
    80003762:	ec86                	sd	ra,88(sp)
    80003764:	e8a2                	sd	s0,80(sp)
    80003766:	e4a6                	sd	s1,72(sp)
    80003768:	e0ca                	sd	s2,64(sp)
    8000376a:	fc4e                	sd	s3,56(sp)
    8000376c:	f852                	sd	s4,48(sp)
    8000376e:	f456                	sd	s5,40(sp)
    80003770:	f05a                	sd	s6,32(sp)
    80003772:	ec5e                	sd	s7,24(sp)
    80003774:	e862                	sd	s8,16(sp)
    80003776:	e466                	sd	s9,8(sp)
    80003778:	1080                	addi	s0,sp,96
    8000377a:	84aa                	mv	s1,a0
    8000377c:	8b2e                	mv	s6,a1
    8000377e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003780:	00054703          	lbu	a4,0(a0)
    80003784:	02f00793          	li	a5,47
    80003788:	00f70e63          	beq	a4,a5,800037a4 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000378c:	9e4fe0ef          	jal	80001970 <myproc>
    80003790:	15053503          	ld	a0,336(a0)
    80003794:	a87ff0ef          	jal	8000321a <idup>
    80003798:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000379a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000379e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800037a0:	4b85                	li	s7,1
    800037a2:	a871                	j	8000383e <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    800037a4:	4585                	li	a1,1
    800037a6:	4505                	li	a0,1
    800037a8:	fc8ff0ef          	jal	80002f70 <iget>
    800037ac:	8a2a                	mv	s4,a0
    800037ae:	b7f5                	j	8000379a <namex+0x3a>
      iunlockput(ip);
    800037b0:	8552                	mv	a0,s4
    800037b2:	ca9ff0ef          	jal	8000345a <iunlockput>
      return 0;
    800037b6:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800037b8:	8552                	mv	a0,s4
    800037ba:	60e6                	ld	ra,88(sp)
    800037bc:	6446                	ld	s0,80(sp)
    800037be:	64a6                	ld	s1,72(sp)
    800037c0:	6906                	ld	s2,64(sp)
    800037c2:	79e2                	ld	s3,56(sp)
    800037c4:	7a42                	ld	s4,48(sp)
    800037c6:	7aa2                	ld	s5,40(sp)
    800037c8:	7b02                	ld	s6,32(sp)
    800037ca:	6be2                	ld	s7,24(sp)
    800037cc:	6c42                	ld	s8,16(sp)
    800037ce:	6ca2                	ld	s9,8(sp)
    800037d0:	6125                	addi	sp,sp,96
    800037d2:	8082                	ret
      iunlock(ip);
    800037d4:	8552                	mv	a0,s4
    800037d6:	b29ff0ef          	jal	800032fe <iunlock>
      return ip;
    800037da:	bff9                	j	800037b8 <namex+0x58>
      iunlockput(ip);
    800037dc:	8552                	mv	a0,s4
    800037de:	c7dff0ef          	jal	8000345a <iunlockput>
      return 0;
    800037e2:	8a4e                	mv	s4,s3
    800037e4:	bfd1                	j	800037b8 <namex+0x58>
  len = path - s;
    800037e6:	40998633          	sub	a2,s3,s1
    800037ea:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800037ee:	099c5063          	bge	s8,s9,8000386e <namex+0x10e>
    memmove(name, s, DIRSIZ);
    800037f2:	4639                	li	a2,14
    800037f4:	85a6                	mv	a1,s1
    800037f6:	8556                	mv	a0,s5
    800037f8:	d2cfd0ef          	jal	80000d24 <memmove>
    800037fc:	84ce                	mv	s1,s3
  while(*path == '/')
    800037fe:	0004c783          	lbu	a5,0(s1)
    80003802:	01279763          	bne	a5,s2,80003810 <namex+0xb0>
    path++;
    80003806:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003808:	0004c783          	lbu	a5,0(s1)
    8000380c:	ff278de3          	beq	a5,s2,80003806 <namex+0xa6>
    ilock(ip);
    80003810:	8552                	mv	a0,s4
    80003812:	a3fff0ef          	jal	80003250 <ilock>
    if(ip->type != T_DIR){
    80003816:	044a1783          	lh	a5,68(s4)
    8000381a:	f9779be3          	bne	a5,s7,800037b0 <namex+0x50>
    if(nameiparent && *path == '\0'){
    8000381e:	000b0563          	beqz	s6,80003828 <namex+0xc8>
    80003822:	0004c783          	lbu	a5,0(s1)
    80003826:	d7dd                	beqz	a5,800037d4 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003828:	4601                	li	a2,0
    8000382a:	85d6                	mv	a1,s5
    8000382c:	8552                	mv	a0,s4
    8000382e:	e97ff0ef          	jal	800036c4 <dirlookup>
    80003832:	89aa                	mv	s3,a0
    80003834:	d545                	beqz	a0,800037dc <namex+0x7c>
    iunlockput(ip);
    80003836:	8552                	mv	a0,s4
    80003838:	c23ff0ef          	jal	8000345a <iunlockput>
    ip = next;
    8000383c:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000383e:	0004c783          	lbu	a5,0(s1)
    80003842:	01279763          	bne	a5,s2,80003850 <namex+0xf0>
    path++;
    80003846:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003848:	0004c783          	lbu	a5,0(s1)
    8000384c:	ff278de3          	beq	a5,s2,80003846 <namex+0xe6>
  if(*path == 0)
    80003850:	cb8d                	beqz	a5,80003882 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003852:	0004c783          	lbu	a5,0(s1)
    80003856:	89a6                	mv	s3,s1
  len = path - s;
    80003858:	4c81                	li	s9,0
    8000385a:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    8000385c:	01278963          	beq	a5,s2,8000386e <namex+0x10e>
    80003860:	d3d9                	beqz	a5,800037e6 <namex+0x86>
    path++;
    80003862:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003864:	0009c783          	lbu	a5,0(s3)
    80003868:	ff279ce3          	bne	a5,s2,80003860 <namex+0x100>
    8000386c:	bfad                	j	800037e6 <namex+0x86>
    memmove(name, s, len);
    8000386e:	2601                	sext.w	a2,a2
    80003870:	85a6                	mv	a1,s1
    80003872:	8556                	mv	a0,s5
    80003874:	cb0fd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    80003878:	9cd6                	add	s9,s9,s5
    8000387a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000387e:	84ce                	mv	s1,s3
    80003880:	bfbd                	j	800037fe <namex+0x9e>
  if(nameiparent){
    80003882:	f20b0be3          	beqz	s6,800037b8 <namex+0x58>
    iput(ip);
    80003886:	8552                	mv	a0,s4
    80003888:	b4bff0ef          	jal	800033d2 <iput>
    return 0;
    8000388c:	4a01                	li	s4,0
    8000388e:	b72d                	j	800037b8 <namex+0x58>

0000000080003890 <dirlink>:
{
    80003890:	7139                	addi	sp,sp,-64
    80003892:	fc06                	sd	ra,56(sp)
    80003894:	f822                	sd	s0,48(sp)
    80003896:	f04a                	sd	s2,32(sp)
    80003898:	ec4e                	sd	s3,24(sp)
    8000389a:	e852                	sd	s4,16(sp)
    8000389c:	0080                	addi	s0,sp,64
    8000389e:	892a                	mv	s2,a0
    800038a0:	8a2e                	mv	s4,a1
    800038a2:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800038a4:	4601                	li	a2,0
    800038a6:	e1fff0ef          	jal	800036c4 <dirlookup>
    800038aa:	e535                	bnez	a0,80003916 <dirlink+0x86>
    800038ac:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038ae:	04c92483          	lw	s1,76(s2)
    800038b2:	c48d                	beqz	s1,800038dc <dirlink+0x4c>
    800038b4:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038b6:	4741                	li	a4,16
    800038b8:	86a6                	mv	a3,s1
    800038ba:	fc040613          	addi	a2,s0,-64
    800038be:	4581                	li	a1,0
    800038c0:	854a                	mv	a0,s2
    800038c2:	be3ff0ef          	jal	800034a4 <readi>
    800038c6:	47c1                	li	a5,16
    800038c8:	04f51b63          	bne	a0,a5,8000391e <dirlink+0x8e>
    if(de.inum == 0)
    800038cc:	fc045783          	lhu	a5,-64(s0)
    800038d0:	c791                	beqz	a5,800038dc <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038d2:	24c1                	addiw	s1,s1,16
    800038d4:	04c92783          	lw	a5,76(s2)
    800038d8:	fcf4efe3          	bltu	s1,a5,800038b6 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    800038dc:	4639                	li	a2,14
    800038de:	85d2                	mv	a1,s4
    800038e0:	fc240513          	addi	a0,s0,-62
    800038e4:	ce6fd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    800038e8:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038ec:	4741                	li	a4,16
    800038ee:	86a6                	mv	a3,s1
    800038f0:	fc040613          	addi	a2,s0,-64
    800038f4:	4581                	li	a1,0
    800038f6:	854a                	mv	a0,s2
    800038f8:	ca9ff0ef          	jal	800035a0 <writei>
    800038fc:	1541                	addi	a0,a0,-16
    800038fe:	00a03533          	snez	a0,a0
    80003902:	40a00533          	neg	a0,a0
    80003906:	74a2                	ld	s1,40(sp)
}
    80003908:	70e2                	ld	ra,56(sp)
    8000390a:	7442                	ld	s0,48(sp)
    8000390c:	7902                	ld	s2,32(sp)
    8000390e:	69e2                	ld	s3,24(sp)
    80003910:	6a42                	ld	s4,16(sp)
    80003912:	6121                	addi	sp,sp,64
    80003914:	8082                	ret
    iput(ip);
    80003916:	abdff0ef          	jal	800033d2 <iput>
    return -1;
    8000391a:	557d                	li	a0,-1
    8000391c:	b7f5                	j	80003908 <dirlink+0x78>
      panic("dirlink read");
    8000391e:	00004517          	auipc	a0,0x4
    80003922:	d6a50513          	addi	a0,a0,-662 # 80007688 <etext+0x688>
    80003926:	e6ffc0ef          	jal	80000794 <panic>

000000008000392a <namei>:

struct inode*
namei(char *path)
{
    8000392a:	1101                	addi	sp,sp,-32
    8000392c:	ec06                	sd	ra,24(sp)
    8000392e:	e822                	sd	s0,16(sp)
    80003930:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003932:	fe040613          	addi	a2,s0,-32
    80003936:	4581                	li	a1,0
    80003938:	e29ff0ef          	jal	80003760 <namex>
}
    8000393c:	60e2                	ld	ra,24(sp)
    8000393e:	6442                	ld	s0,16(sp)
    80003940:	6105                	addi	sp,sp,32
    80003942:	8082                	ret

0000000080003944 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003944:	1141                	addi	sp,sp,-16
    80003946:	e406                	sd	ra,8(sp)
    80003948:	e022                	sd	s0,0(sp)
    8000394a:	0800                	addi	s0,sp,16
    8000394c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000394e:	4585                	li	a1,1
    80003950:	e11ff0ef          	jal	80003760 <namex>
}
    80003954:	60a2                	ld	ra,8(sp)
    80003956:	6402                	ld	s0,0(sp)
    80003958:	0141                	addi	sp,sp,16
    8000395a:	8082                	ret

000000008000395c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000395c:	1101                	addi	sp,sp,-32
    8000395e:	ec06                	sd	ra,24(sp)
    80003960:	e822                	sd	s0,16(sp)
    80003962:	e426                	sd	s1,8(sp)
    80003964:	e04a                	sd	s2,0(sp)
    80003966:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003968:	0001c917          	auipc	s2,0x1c
    8000396c:	1d890913          	addi	s2,s2,472 # 8001fb40 <log>
    80003970:	01892583          	lw	a1,24(s2)
    80003974:	02892503          	lw	a0,40(s2)
    80003978:	9a0ff0ef          	jal	80002b18 <bread>
    8000397c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000397e:	02c92603          	lw	a2,44(s2)
    80003982:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003984:	00c05f63          	blez	a2,800039a2 <write_head+0x46>
    80003988:	0001c717          	auipc	a4,0x1c
    8000398c:	1e870713          	addi	a4,a4,488 # 8001fb70 <log+0x30>
    80003990:	87aa                	mv	a5,a0
    80003992:	060a                	slli	a2,a2,0x2
    80003994:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003996:	4314                	lw	a3,0(a4)
    80003998:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000399a:	0711                	addi	a4,a4,4
    8000399c:	0791                	addi	a5,a5,4
    8000399e:	fec79ce3          	bne	a5,a2,80003996 <write_head+0x3a>
  }
  bwrite(buf);
    800039a2:	8526                	mv	a0,s1
    800039a4:	a4aff0ef          	jal	80002bee <bwrite>
  brelse(buf);
    800039a8:	8526                	mv	a0,s1
    800039aa:	a76ff0ef          	jal	80002c20 <brelse>
}
    800039ae:	60e2                	ld	ra,24(sp)
    800039b0:	6442                	ld	s0,16(sp)
    800039b2:	64a2                	ld	s1,8(sp)
    800039b4:	6902                	ld	s2,0(sp)
    800039b6:	6105                	addi	sp,sp,32
    800039b8:	8082                	ret

00000000800039ba <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800039ba:	0001c797          	auipc	a5,0x1c
    800039be:	1b27a783          	lw	a5,434(a5) # 8001fb6c <log+0x2c>
    800039c2:	08f05f63          	blez	a5,80003a60 <install_trans+0xa6>
{
    800039c6:	7139                	addi	sp,sp,-64
    800039c8:	fc06                	sd	ra,56(sp)
    800039ca:	f822                	sd	s0,48(sp)
    800039cc:	f426                	sd	s1,40(sp)
    800039ce:	f04a                	sd	s2,32(sp)
    800039d0:	ec4e                	sd	s3,24(sp)
    800039d2:	e852                	sd	s4,16(sp)
    800039d4:	e456                	sd	s5,8(sp)
    800039d6:	e05a                	sd	s6,0(sp)
    800039d8:	0080                	addi	s0,sp,64
    800039da:	8b2a                	mv	s6,a0
    800039dc:	0001ca97          	auipc	s5,0x1c
    800039e0:	194a8a93          	addi	s5,s5,404 # 8001fb70 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800039e4:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800039e6:	0001c997          	auipc	s3,0x1c
    800039ea:	15a98993          	addi	s3,s3,346 # 8001fb40 <log>
    800039ee:	a829                	j	80003a08 <install_trans+0x4e>
    brelse(lbuf);
    800039f0:	854a                	mv	a0,s2
    800039f2:	a2eff0ef          	jal	80002c20 <brelse>
    brelse(dbuf);
    800039f6:	8526                	mv	a0,s1
    800039f8:	a28ff0ef          	jal	80002c20 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800039fc:	2a05                	addiw	s4,s4,1
    800039fe:	0a91                	addi	s5,s5,4
    80003a00:	02c9a783          	lw	a5,44(s3)
    80003a04:	04fa5463          	bge	s4,a5,80003a4c <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003a08:	0189a583          	lw	a1,24(s3)
    80003a0c:	014585bb          	addw	a1,a1,s4
    80003a10:	2585                	addiw	a1,a1,1
    80003a12:	0289a503          	lw	a0,40(s3)
    80003a16:	902ff0ef          	jal	80002b18 <bread>
    80003a1a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003a1c:	000aa583          	lw	a1,0(s5)
    80003a20:	0289a503          	lw	a0,40(s3)
    80003a24:	8f4ff0ef          	jal	80002b18 <bread>
    80003a28:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003a2a:	40000613          	li	a2,1024
    80003a2e:	05890593          	addi	a1,s2,88
    80003a32:	05850513          	addi	a0,a0,88
    80003a36:	aeefd0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003a3a:	8526                	mv	a0,s1
    80003a3c:	9b2ff0ef          	jal	80002bee <bwrite>
    if(recovering == 0)
    80003a40:	fa0b18e3          	bnez	s6,800039f0 <install_trans+0x36>
      bunpin(dbuf);
    80003a44:	8526                	mv	a0,s1
    80003a46:	a96ff0ef          	jal	80002cdc <bunpin>
    80003a4a:	b75d                	j	800039f0 <install_trans+0x36>
}
    80003a4c:	70e2                	ld	ra,56(sp)
    80003a4e:	7442                	ld	s0,48(sp)
    80003a50:	74a2                	ld	s1,40(sp)
    80003a52:	7902                	ld	s2,32(sp)
    80003a54:	69e2                	ld	s3,24(sp)
    80003a56:	6a42                	ld	s4,16(sp)
    80003a58:	6aa2                	ld	s5,8(sp)
    80003a5a:	6b02                	ld	s6,0(sp)
    80003a5c:	6121                	addi	sp,sp,64
    80003a5e:	8082                	ret
    80003a60:	8082                	ret

0000000080003a62 <initlog>:
{
    80003a62:	7179                	addi	sp,sp,-48
    80003a64:	f406                	sd	ra,40(sp)
    80003a66:	f022                	sd	s0,32(sp)
    80003a68:	ec26                	sd	s1,24(sp)
    80003a6a:	e84a                	sd	s2,16(sp)
    80003a6c:	e44e                	sd	s3,8(sp)
    80003a6e:	1800                	addi	s0,sp,48
    80003a70:	892a                	mv	s2,a0
    80003a72:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003a74:	0001c497          	auipc	s1,0x1c
    80003a78:	0cc48493          	addi	s1,s1,204 # 8001fb40 <log>
    80003a7c:	00004597          	auipc	a1,0x4
    80003a80:	c1c58593          	addi	a1,a1,-996 # 80007698 <etext+0x698>
    80003a84:	8526                	mv	a0,s1
    80003a86:	8eefd0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003a8a:	0149a583          	lw	a1,20(s3)
    80003a8e:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003a90:	0109a783          	lw	a5,16(s3)
    80003a94:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003a96:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003a9a:	854a                	mv	a0,s2
    80003a9c:	87cff0ef          	jal	80002b18 <bread>
  log.lh.n = lh->n;
    80003aa0:	4d30                	lw	a2,88(a0)
    80003aa2:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003aa4:	00c05f63          	blez	a2,80003ac2 <initlog+0x60>
    80003aa8:	87aa                	mv	a5,a0
    80003aaa:	0001c717          	auipc	a4,0x1c
    80003aae:	0c670713          	addi	a4,a4,198 # 8001fb70 <log+0x30>
    80003ab2:	060a                	slli	a2,a2,0x2
    80003ab4:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003ab6:	4ff4                	lw	a3,92(a5)
    80003ab8:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003aba:	0791                	addi	a5,a5,4
    80003abc:	0711                	addi	a4,a4,4
    80003abe:	fec79ce3          	bne	a5,a2,80003ab6 <initlog+0x54>
  brelse(buf);
    80003ac2:	95eff0ef          	jal	80002c20 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003ac6:	4505                	li	a0,1
    80003ac8:	ef3ff0ef          	jal	800039ba <install_trans>
  log.lh.n = 0;
    80003acc:	0001c797          	auipc	a5,0x1c
    80003ad0:	0a07a023          	sw	zero,160(a5) # 8001fb6c <log+0x2c>
  write_head(); // clear the log
    80003ad4:	e89ff0ef          	jal	8000395c <write_head>
}
    80003ad8:	70a2                	ld	ra,40(sp)
    80003ada:	7402                	ld	s0,32(sp)
    80003adc:	64e2                	ld	s1,24(sp)
    80003ade:	6942                	ld	s2,16(sp)
    80003ae0:	69a2                	ld	s3,8(sp)
    80003ae2:	6145                	addi	sp,sp,48
    80003ae4:	8082                	ret

0000000080003ae6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ae6:	1101                	addi	sp,sp,-32
    80003ae8:	ec06                	sd	ra,24(sp)
    80003aea:	e822                	sd	s0,16(sp)
    80003aec:	e426                	sd	s1,8(sp)
    80003aee:	e04a                	sd	s2,0(sp)
    80003af0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003af2:	0001c517          	auipc	a0,0x1c
    80003af6:	04e50513          	addi	a0,a0,78 # 8001fb40 <log>
    80003afa:	8fafd0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003afe:	0001c497          	auipc	s1,0x1c
    80003b02:	04248493          	addi	s1,s1,66 # 8001fb40 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003b06:	4979                	li	s2,30
    80003b08:	a029                	j	80003b12 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003b0a:	85a6                	mv	a1,s1
    80003b0c:	8526                	mv	a0,s1
    80003b0e:	c30fe0ef          	jal	80001f3e <sleep>
    if(log.committing){
    80003b12:	50dc                	lw	a5,36(s1)
    80003b14:	fbfd                	bnez	a5,80003b0a <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003b16:	5098                	lw	a4,32(s1)
    80003b18:	2705                	addiw	a4,a4,1
    80003b1a:	0027179b          	slliw	a5,a4,0x2
    80003b1e:	9fb9                	addw	a5,a5,a4
    80003b20:	0017979b          	slliw	a5,a5,0x1
    80003b24:	54d4                	lw	a3,44(s1)
    80003b26:	9fb5                	addw	a5,a5,a3
    80003b28:	00f95763          	bge	s2,a5,80003b36 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003b2c:	85a6                	mv	a1,s1
    80003b2e:	8526                	mv	a0,s1
    80003b30:	c0efe0ef          	jal	80001f3e <sleep>
    80003b34:	bff9                	j	80003b12 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003b36:	0001c517          	auipc	a0,0x1c
    80003b3a:	00a50513          	addi	a0,a0,10 # 8001fb40 <log>
    80003b3e:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003b40:	94cfd0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003b44:	60e2                	ld	ra,24(sp)
    80003b46:	6442                	ld	s0,16(sp)
    80003b48:	64a2                	ld	s1,8(sp)
    80003b4a:	6902                	ld	s2,0(sp)
    80003b4c:	6105                	addi	sp,sp,32
    80003b4e:	8082                	ret

0000000080003b50 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003b50:	7139                	addi	sp,sp,-64
    80003b52:	fc06                	sd	ra,56(sp)
    80003b54:	f822                	sd	s0,48(sp)
    80003b56:	f426                	sd	s1,40(sp)
    80003b58:	f04a                	sd	s2,32(sp)
    80003b5a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003b5c:	0001c497          	auipc	s1,0x1c
    80003b60:	fe448493          	addi	s1,s1,-28 # 8001fb40 <log>
    80003b64:	8526                	mv	a0,s1
    80003b66:	88efd0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003b6a:	509c                	lw	a5,32(s1)
    80003b6c:	37fd                	addiw	a5,a5,-1
    80003b6e:	0007891b          	sext.w	s2,a5
    80003b72:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003b74:	50dc                	lw	a5,36(s1)
    80003b76:	ef9d                	bnez	a5,80003bb4 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003b78:	04091763          	bnez	s2,80003bc6 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003b7c:	0001c497          	auipc	s1,0x1c
    80003b80:	fc448493          	addi	s1,s1,-60 # 8001fb40 <log>
    80003b84:	4785                	li	a5,1
    80003b86:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003b88:	8526                	mv	a0,s1
    80003b8a:	902fd0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003b8e:	54dc                	lw	a5,44(s1)
    80003b90:	04f04b63          	bgtz	a5,80003be6 <end_op+0x96>
    acquire(&log.lock);
    80003b94:	0001c497          	auipc	s1,0x1c
    80003b98:	fac48493          	addi	s1,s1,-84 # 8001fb40 <log>
    80003b9c:	8526                	mv	a0,s1
    80003b9e:	856fd0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80003ba2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003ba6:	8526                	mv	a0,s1
    80003ba8:	be2fe0ef          	jal	80001f8a <wakeup>
    release(&log.lock);
    80003bac:	8526                	mv	a0,s1
    80003bae:	8defd0ef          	jal	80000c8c <release>
}
    80003bb2:	a025                	j	80003bda <end_op+0x8a>
    80003bb4:	ec4e                	sd	s3,24(sp)
    80003bb6:	e852                	sd	s4,16(sp)
    80003bb8:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003bba:	00004517          	auipc	a0,0x4
    80003bbe:	ae650513          	addi	a0,a0,-1306 # 800076a0 <etext+0x6a0>
    80003bc2:	bd3fc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80003bc6:	0001c497          	auipc	s1,0x1c
    80003bca:	f7a48493          	addi	s1,s1,-134 # 8001fb40 <log>
    80003bce:	8526                	mv	a0,s1
    80003bd0:	bbafe0ef          	jal	80001f8a <wakeup>
  release(&log.lock);
    80003bd4:	8526                	mv	a0,s1
    80003bd6:	8b6fd0ef          	jal	80000c8c <release>
}
    80003bda:	70e2                	ld	ra,56(sp)
    80003bdc:	7442                	ld	s0,48(sp)
    80003bde:	74a2                	ld	s1,40(sp)
    80003be0:	7902                	ld	s2,32(sp)
    80003be2:	6121                	addi	sp,sp,64
    80003be4:	8082                	ret
    80003be6:	ec4e                	sd	s3,24(sp)
    80003be8:	e852                	sd	s4,16(sp)
    80003bea:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bec:	0001ca97          	auipc	s5,0x1c
    80003bf0:	f84a8a93          	addi	s5,s5,-124 # 8001fb70 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003bf4:	0001ca17          	auipc	s4,0x1c
    80003bf8:	f4ca0a13          	addi	s4,s4,-180 # 8001fb40 <log>
    80003bfc:	018a2583          	lw	a1,24(s4)
    80003c00:	012585bb          	addw	a1,a1,s2
    80003c04:	2585                	addiw	a1,a1,1
    80003c06:	028a2503          	lw	a0,40(s4)
    80003c0a:	f0ffe0ef          	jal	80002b18 <bread>
    80003c0e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003c10:	000aa583          	lw	a1,0(s5)
    80003c14:	028a2503          	lw	a0,40(s4)
    80003c18:	f01fe0ef          	jal	80002b18 <bread>
    80003c1c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003c1e:	40000613          	li	a2,1024
    80003c22:	05850593          	addi	a1,a0,88
    80003c26:	05848513          	addi	a0,s1,88
    80003c2a:	8fafd0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    80003c2e:	8526                	mv	a0,s1
    80003c30:	fbffe0ef          	jal	80002bee <bwrite>
    brelse(from);
    80003c34:	854e                	mv	a0,s3
    80003c36:	febfe0ef          	jal	80002c20 <brelse>
    brelse(to);
    80003c3a:	8526                	mv	a0,s1
    80003c3c:	fe5fe0ef          	jal	80002c20 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c40:	2905                	addiw	s2,s2,1
    80003c42:	0a91                	addi	s5,s5,4
    80003c44:	02ca2783          	lw	a5,44(s4)
    80003c48:	faf94ae3          	blt	s2,a5,80003bfc <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003c4c:	d11ff0ef          	jal	8000395c <write_head>
    install_trans(0); // Now install writes to home locations
    80003c50:	4501                	li	a0,0
    80003c52:	d69ff0ef          	jal	800039ba <install_trans>
    log.lh.n = 0;
    80003c56:	0001c797          	auipc	a5,0x1c
    80003c5a:	f007ab23          	sw	zero,-234(a5) # 8001fb6c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003c5e:	cffff0ef          	jal	8000395c <write_head>
    80003c62:	69e2                	ld	s3,24(sp)
    80003c64:	6a42                	ld	s4,16(sp)
    80003c66:	6aa2                	ld	s5,8(sp)
    80003c68:	b735                	j	80003b94 <end_op+0x44>

0000000080003c6a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003c6a:	1101                	addi	sp,sp,-32
    80003c6c:	ec06                	sd	ra,24(sp)
    80003c6e:	e822                	sd	s0,16(sp)
    80003c70:	e426                	sd	s1,8(sp)
    80003c72:	e04a                	sd	s2,0(sp)
    80003c74:	1000                	addi	s0,sp,32
    80003c76:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003c78:	0001c917          	auipc	s2,0x1c
    80003c7c:	ec890913          	addi	s2,s2,-312 # 8001fb40 <log>
    80003c80:	854a                	mv	a0,s2
    80003c82:	f73fc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003c86:	02c92603          	lw	a2,44(s2)
    80003c8a:	47f5                	li	a5,29
    80003c8c:	06c7c363          	blt	a5,a2,80003cf2 <log_write+0x88>
    80003c90:	0001c797          	auipc	a5,0x1c
    80003c94:	ecc7a783          	lw	a5,-308(a5) # 8001fb5c <log+0x1c>
    80003c98:	37fd                	addiw	a5,a5,-1
    80003c9a:	04f65c63          	bge	a2,a5,80003cf2 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003c9e:	0001c797          	auipc	a5,0x1c
    80003ca2:	ec27a783          	lw	a5,-318(a5) # 8001fb60 <log+0x20>
    80003ca6:	04f05c63          	blez	a5,80003cfe <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003caa:	4781                	li	a5,0
    80003cac:	04c05f63          	blez	a2,80003d0a <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003cb0:	44cc                	lw	a1,12(s1)
    80003cb2:	0001c717          	auipc	a4,0x1c
    80003cb6:	ebe70713          	addi	a4,a4,-322 # 8001fb70 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003cba:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003cbc:	4314                	lw	a3,0(a4)
    80003cbe:	04b68663          	beq	a3,a1,80003d0a <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003cc2:	2785                	addiw	a5,a5,1
    80003cc4:	0711                	addi	a4,a4,4
    80003cc6:	fef61be3          	bne	a2,a5,80003cbc <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003cca:	0621                	addi	a2,a2,8
    80003ccc:	060a                	slli	a2,a2,0x2
    80003cce:	0001c797          	auipc	a5,0x1c
    80003cd2:	e7278793          	addi	a5,a5,-398 # 8001fb40 <log>
    80003cd6:	97b2                	add	a5,a5,a2
    80003cd8:	44d8                	lw	a4,12(s1)
    80003cda:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003cdc:	8526                	mv	a0,s1
    80003cde:	fcbfe0ef          	jal	80002ca8 <bpin>
    log.lh.n++;
    80003ce2:	0001c717          	auipc	a4,0x1c
    80003ce6:	e5e70713          	addi	a4,a4,-418 # 8001fb40 <log>
    80003cea:	575c                	lw	a5,44(a4)
    80003cec:	2785                	addiw	a5,a5,1
    80003cee:	d75c                	sw	a5,44(a4)
    80003cf0:	a80d                	j	80003d22 <log_write+0xb8>
    panic("too big a transaction");
    80003cf2:	00004517          	auipc	a0,0x4
    80003cf6:	9be50513          	addi	a0,a0,-1602 # 800076b0 <etext+0x6b0>
    80003cfa:	a9bfc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    80003cfe:	00004517          	auipc	a0,0x4
    80003d02:	9ca50513          	addi	a0,a0,-1590 # 800076c8 <etext+0x6c8>
    80003d06:	a8ffc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    80003d0a:	00878693          	addi	a3,a5,8
    80003d0e:	068a                	slli	a3,a3,0x2
    80003d10:	0001c717          	auipc	a4,0x1c
    80003d14:	e3070713          	addi	a4,a4,-464 # 8001fb40 <log>
    80003d18:	9736                	add	a4,a4,a3
    80003d1a:	44d4                	lw	a3,12(s1)
    80003d1c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003d1e:	faf60fe3          	beq	a2,a5,80003cdc <log_write+0x72>
  }
  release(&log.lock);
    80003d22:	0001c517          	auipc	a0,0x1c
    80003d26:	e1e50513          	addi	a0,a0,-482 # 8001fb40 <log>
    80003d2a:	f63fc0ef          	jal	80000c8c <release>
}
    80003d2e:	60e2                	ld	ra,24(sp)
    80003d30:	6442                	ld	s0,16(sp)
    80003d32:	64a2                	ld	s1,8(sp)
    80003d34:	6902                	ld	s2,0(sp)
    80003d36:	6105                	addi	sp,sp,32
    80003d38:	8082                	ret

0000000080003d3a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003d3a:	1101                	addi	sp,sp,-32
    80003d3c:	ec06                	sd	ra,24(sp)
    80003d3e:	e822                	sd	s0,16(sp)
    80003d40:	e426                	sd	s1,8(sp)
    80003d42:	e04a                	sd	s2,0(sp)
    80003d44:	1000                	addi	s0,sp,32
    80003d46:	84aa                	mv	s1,a0
    80003d48:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003d4a:	00004597          	auipc	a1,0x4
    80003d4e:	99e58593          	addi	a1,a1,-1634 # 800076e8 <etext+0x6e8>
    80003d52:	0521                	addi	a0,a0,8
    80003d54:	e21fc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    80003d58:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003d5c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003d60:	0204a423          	sw	zero,40(s1)
}
    80003d64:	60e2                	ld	ra,24(sp)
    80003d66:	6442                	ld	s0,16(sp)
    80003d68:	64a2                	ld	s1,8(sp)
    80003d6a:	6902                	ld	s2,0(sp)
    80003d6c:	6105                	addi	sp,sp,32
    80003d6e:	8082                	ret

0000000080003d70 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003d70:	1101                	addi	sp,sp,-32
    80003d72:	ec06                	sd	ra,24(sp)
    80003d74:	e822                	sd	s0,16(sp)
    80003d76:	e426                	sd	s1,8(sp)
    80003d78:	e04a                	sd	s2,0(sp)
    80003d7a:	1000                	addi	s0,sp,32
    80003d7c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003d7e:	00850913          	addi	s2,a0,8
    80003d82:	854a                	mv	a0,s2
    80003d84:	e71fc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    80003d88:	409c                	lw	a5,0(s1)
    80003d8a:	c799                	beqz	a5,80003d98 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003d8c:	85ca                	mv	a1,s2
    80003d8e:	8526                	mv	a0,s1
    80003d90:	9aefe0ef          	jal	80001f3e <sleep>
  while (lk->locked) {
    80003d94:	409c                	lw	a5,0(s1)
    80003d96:	fbfd                	bnez	a5,80003d8c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003d98:	4785                	li	a5,1
    80003d9a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003d9c:	bd5fd0ef          	jal	80001970 <myproc>
    80003da0:	591c                	lw	a5,48(a0)
    80003da2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003da4:	854a                	mv	a0,s2
    80003da6:	ee7fc0ef          	jal	80000c8c <release>
}
    80003daa:	60e2                	ld	ra,24(sp)
    80003dac:	6442                	ld	s0,16(sp)
    80003dae:	64a2                	ld	s1,8(sp)
    80003db0:	6902                	ld	s2,0(sp)
    80003db2:	6105                	addi	sp,sp,32
    80003db4:	8082                	ret

0000000080003db6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003db6:	1101                	addi	sp,sp,-32
    80003db8:	ec06                	sd	ra,24(sp)
    80003dba:	e822                	sd	s0,16(sp)
    80003dbc:	e426                	sd	s1,8(sp)
    80003dbe:	e04a                	sd	s2,0(sp)
    80003dc0:	1000                	addi	s0,sp,32
    80003dc2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003dc4:	00850913          	addi	s2,a0,8
    80003dc8:	854a                	mv	a0,s2
    80003dca:	e2bfc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    80003dce:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003dd2:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003dd6:	8526                	mv	a0,s1
    80003dd8:	9b2fe0ef          	jal	80001f8a <wakeup>
  release(&lk->lk);
    80003ddc:	854a                	mv	a0,s2
    80003dde:	eaffc0ef          	jal	80000c8c <release>
}
    80003de2:	60e2                	ld	ra,24(sp)
    80003de4:	6442                	ld	s0,16(sp)
    80003de6:	64a2                	ld	s1,8(sp)
    80003de8:	6902                	ld	s2,0(sp)
    80003dea:	6105                	addi	sp,sp,32
    80003dec:	8082                	ret

0000000080003dee <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003dee:	7179                	addi	sp,sp,-48
    80003df0:	f406                	sd	ra,40(sp)
    80003df2:	f022                	sd	s0,32(sp)
    80003df4:	ec26                	sd	s1,24(sp)
    80003df6:	e84a                	sd	s2,16(sp)
    80003df8:	1800                	addi	s0,sp,48
    80003dfa:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003dfc:	00850913          	addi	s2,a0,8
    80003e00:	854a                	mv	a0,s2
    80003e02:	df3fc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003e06:	409c                	lw	a5,0(s1)
    80003e08:	ef81                	bnez	a5,80003e20 <holdingsleep+0x32>
    80003e0a:	4481                	li	s1,0
  release(&lk->lk);
    80003e0c:	854a                	mv	a0,s2
    80003e0e:	e7ffc0ef          	jal	80000c8c <release>
  return r;
}
    80003e12:	8526                	mv	a0,s1
    80003e14:	70a2                	ld	ra,40(sp)
    80003e16:	7402                	ld	s0,32(sp)
    80003e18:	64e2                	ld	s1,24(sp)
    80003e1a:	6942                	ld	s2,16(sp)
    80003e1c:	6145                	addi	sp,sp,48
    80003e1e:	8082                	ret
    80003e20:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003e22:	0284a983          	lw	s3,40(s1)
    80003e26:	b4bfd0ef          	jal	80001970 <myproc>
    80003e2a:	5904                	lw	s1,48(a0)
    80003e2c:	413484b3          	sub	s1,s1,s3
    80003e30:	0014b493          	seqz	s1,s1
    80003e34:	69a2                	ld	s3,8(sp)
    80003e36:	bfd9                	j	80003e0c <holdingsleep+0x1e>

0000000080003e38 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003e38:	1141                	addi	sp,sp,-16
    80003e3a:	e406                	sd	ra,8(sp)
    80003e3c:	e022                	sd	s0,0(sp)
    80003e3e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003e40:	00004597          	auipc	a1,0x4
    80003e44:	8b858593          	addi	a1,a1,-1864 # 800076f8 <etext+0x6f8>
    80003e48:	0001c517          	auipc	a0,0x1c
    80003e4c:	e4050513          	addi	a0,a0,-448 # 8001fc88 <ftable>
    80003e50:	d25fc0ef          	jal	80000b74 <initlock>
}
    80003e54:	60a2                	ld	ra,8(sp)
    80003e56:	6402                	ld	s0,0(sp)
    80003e58:	0141                	addi	sp,sp,16
    80003e5a:	8082                	ret

0000000080003e5c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003e5c:	1101                	addi	sp,sp,-32
    80003e5e:	ec06                	sd	ra,24(sp)
    80003e60:	e822                	sd	s0,16(sp)
    80003e62:	e426                	sd	s1,8(sp)
    80003e64:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003e66:	0001c517          	auipc	a0,0x1c
    80003e6a:	e2250513          	addi	a0,a0,-478 # 8001fc88 <ftable>
    80003e6e:	d87fc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003e72:	0001c497          	auipc	s1,0x1c
    80003e76:	e2e48493          	addi	s1,s1,-466 # 8001fca0 <ftable+0x18>
    80003e7a:	0001d717          	auipc	a4,0x1d
    80003e7e:	dc670713          	addi	a4,a4,-570 # 80020c40 <disk>
    if(f->ref == 0){
    80003e82:	40dc                	lw	a5,4(s1)
    80003e84:	cf89                	beqz	a5,80003e9e <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003e86:	02848493          	addi	s1,s1,40
    80003e8a:	fee49ce3          	bne	s1,a4,80003e82 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003e8e:	0001c517          	auipc	a0,0x1c
    80003e92:	dfa50513          	addi	a0,a0,-518 # 8001fc88 <ftable>
    80003e96:	df7fc0ef          	jal	80000c8c <release>
  return 0;
    80003e9a:	4481                	li	s1,0
    80003e9c:	a809                	j	80003eae <filealloc+0x52>
      f->ref = 1;
    80003e9e:	4785                	li	a5,1
    80003ea0:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003ea2:	0001c517          	auipc	a0,0x1c
    80003ea6:	de650513          	addi	a0,a0,-538 # 8001fc88 <ftable>
    80003eaa:	de3fc0ef          	jal	80000c8c <release>
}
    80003eae:	8526                	mv	a0,s1
    80003eb0:	60e2                	ld	ra,24(sp)
    80003eb2:	6442                	ld	s0,16(sp)
    80003eb4:	64a2                	ld	s1,8(sp)
    80003eb6:	6105                	addi	sp,sp,32
    80003eb8:	8082                	ret

0000000080003eba <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003eba:	1101                	addi	sp,sp,-32
    80003ebc:	ec06                	sd	ra,24(sp)
    80003ebe:	e822                	sd	s0,16(sp)
    80003ec0:	e426                	sd	s1,8(sp)
    80003ec2:	1000                	addi	s0,sp,32
    80003ec4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003ec6:	0001c517          	auipc	a0,0x1c
    80003eca:	dc250513          	addi	a0,a0,-574 # 8001fc88 <ftable>
    80003ece:	d27fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003ed2:	40dc                	lw	a5,4(s1)
    80003ed4:	02f05063          	blez	a5,80003ef4 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003ed8:	2785                	addiw	a5,a5,1
    80003eda:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003edc:	0001c517          	auipc	a0,0x1c
    80003ee0:	dac50513          	addi	a0,a0,-596 # 8001fc88 <ftable>
    80003ee4:	da9fc0ef          	jal	80000c8c <release>
  return f;
}
    80003ee8:	8526                	mv	a0,s1
    80003eea:	60e2                	ld	ra,24(sp)
    80003eec:	6442                	ld	s0,16(sp)
    80003eee:	64a2                	ld	s1,8(sp)
    80003ef0:	6105                	addi	sp,sp,32
    80003ef2:	8082                	ret
    panic("filedup");
    80003ef4:	00004517          	auipc	a0,0x4
    80003ef8:	80c50513          	addi	a0,a0,-2036 # 80007700 <etext+0x700>
    80003efc:	899fc0ef          	jal	80000794 <panic>

0000000080003f00 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003f00:	7139                	addi	sp,sp,-64
    80003f02:	fc06                	sd	ra,56(sp)
    80003f04:	f822                	sd	s0,48(sp)
    80003f06:	f426                	sd	s1,40(sp)
    80003f08:	0080                	addi	s0,sp,64
    80003f0a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003f0c:	0001c517          	auipc	a0,0x1c
    80003f10:	d7c50513          	addi	a0,a0,-644 # 8001fc88 <ftable>
    80003f14:	ce1fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003f18:	40dc                	lw	a5,4(s1)
    80003f1a:	04f05a63          	blez	a5,80003f6e <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80003f1e:	37fd                	addiw	a5,a5,-1
    80003f20:	0007871b          	sext.w	a4,a5
    80003f24:	c0dc                	sw	a5,4(s1)
    80003f26:	04e04e63          	bgtz	a4,80003f82 <fileclose+0x82>
    80003f2a:	f04a                	sd	s2,32(sp)
    80003f2c:	ec4e                	sd	s3,24(sp)
    80003f2e:	e852                	sd	s4,16(sp)
    80003f30:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003f32:	0004a903          	lw	s2,0(s1)
    80003f36:	0094ca83          	lbu	s5,9(s1)
    80003f3a:	0104ba03          	ld	s4,16(s1)
    80003f3e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003f42:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003f46:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003f4a:	0001c517          	auipc	a0,0x1c
    80003f4e:	d3e50513          	addi	a0,a0,-706 # 8001fc88 <ftable>
    80003f52:	d3bfc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    80003f56:	4785                	li	a5,1
    80003f58:	04f90063          	beq	s2,a5,80003f98 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003f5c:	3979                	addiw	s2,s2,-2
    80003f5e:	4785                	li	a5,1
    80003f60:	0527f563          	bgeu	a5,s2,80003faa <fileclose+0xaa>
    80003f64:	7902                	ld	s2,32(sp)
    80003f66:	69e2                	ld	s3,24(sp)
    80003f68:	6a42                	ld	s4,16(sp)
    80003f6a:	6aa2                	ld	s5,8(sp)
    80003f6c:	a00d                	j	80003f8e <fileclose+0x8e>
    80003f6e:	f04a                	sd	s2,32(sp)
    80003f70:	ec4e                	sd	s3,24(sp)
    80003f72:	e852                	sd	s4,16(sp)
    80003f74:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80003f76:	00003517          	auipc	a0,0x3
    80003f7a:	79250513          	addi	a0,a0,1938 # 80007708 <etext+0x708>
    80003f7e:	817fc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    80003f82:	0001c517          	auipc	a0,0x1c
    80003f86:	d0650513          	addi	a0,a0,-762 # 8001fc88 <ftable>
    80003f8a:	d03fc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80003f8e:	70e2                	ld	ra,56(sp)
    80003f90:	7442                	ld	s0,48(sp)
    80003f92:	74a2                	ld	s1,40(sp)
    80003f94:	6121                	addi	sp,sp,64
    80003f96:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003f98:	85d6                	mv	a1,s5
    80003f9a:	8552                	mv	a0,s4
    80003f9c:	336000ef          	jal	800042d2 <pipeclose>
    80003fa0:	7902                	ld	s2,32(sp)
    80003fa2:	69e2                	ld	s3,24(sp)
    80003fa4:	6a42                	ld	s4,16(sp)
    80003fa6:	6aa2                	ld	s5,8(sp)
    80003fa8:	b7dd                	j	80003f8e <fileclose+0x8e>
    begin_op();
    80003faa:	b3dff0ef          	jal	80003ae6 <begin_op>
    iput(ff.ip);
    80003fae:	854e                	mv	a0,s3
    80003fb0:	c22ff0ef          	jal	800033d2 <iput>
    end_op();
    80003fb4:	b9dff0ef          	jal	80003b50 <end_op>
    80003fb8:	7902                	ld	s2,32(sp)
    80003fba:	69e2                	ld	s3,24(sp)
    80003fbc:	6a42                	ld	s4,16(sp)
    80003fbe:	6aa2                	ld	s5,8(sp)
    80003fc0:	b7f9                	j	80003f8e <fileclose+0x8e>

0000000080003fc2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003fc2:	715d                	addi	sp,sp,-80
    80003fc4:	e486                	sd	ra,72(sp)
    80003fc6:	e0a2                	sd	s0,64(sp)
    80003fc8:	fc26                	sd	s1,56(sp)
    80003fca:	f44e                	sd	s3,40(sp)
    80003fcc:	0880                	addi	s0,sp,80
    80003fce:	84aa                	mv	s1,a0
    80003fd0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003fd2:	99ffd0ef          	jal	80001970 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003fd6:	409c                	lw	a5,0(s1)
    80003fd8:	37f9                	addiw	a5,a5,-2
    80003fda:	4705                	li	a4,1
    80003fdc:	04f76063          	bltu	a4,a5,8000401c <filestat+0x5a>
    80003fe0:	f84a                	sd	s2,48(sp)
    80003fe2:	892a                	mv	s2,a0
    ilock(f->ip);
    80003fe4:	6c88                	ld	a0,24(s1)
    80003fe6:	a6aff0ef          	jal	80003250 <ilock>
    stati(f->ip, &st);
    80003fea:	fb840593          	addi	a1,s0,-72
    80003fee:	6c88                	ld	a0,24(s1)
    80003ff0:	c8aff0ef          	jal	8000347a <stati>
    iunlock(f->ip);
    80003ff4:	6c88                	ld	a0,24(s1)
    80003ff6:	b08ff0ef          	jal	800032fe <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003ffa:	46e1                	li	a3,24
    80003ffc:	fb840613          	addi	a2,s0,-72
    80004000:	85ce                	mv	a1,s3
    80004002:	05093503          	ld	a0,80(s2)
    80004006:	ddcfd0ef          	jal	800015e2 <copyout>
    8000400a:	41f5551b          	sraiw	a0,a0,0x1f
    8000400e:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004010:	60a6                	ld	ra,72(sp)
    80004012:	6406                	ld	s0,64(sp)
    80004014:	74e2                	ld	s1,56(sp)
    80004016:	79a2                	ld	s3,40(sp)
    80004018:	6161                	addi	sp,sp,80
    8000401a:	8082                	ret
  return -1;
    8000401c:	557d                	li	a0,-1
    8000401e:	bfcd                	j	80004010 <filestat+0x4e>

0000000080004020 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004020:	7179                	addi	sp,sp,-48
    80004022:	f406                	sd	ra,40(sp)
    80004024:	f022                	sd	s0,32(sp)
    80004026:	e84a                	sd	s2,16(sp)
    80004028:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000402a:	00854783          	lbu	a5,8(a0)
    8000402e:	cfd1                	beqz	a5,800040ca <fileread+0xaa>
    80004030:	ec26                	sd	s1,24(sp)
    80004032:	e44e                	sd	s3,8(sp)
    80004034:	84aa                	mv	s1,a0
    80004036:	89ae                	mv	s3,a1
    80004038:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000403a:	411c                	lw	a5,0(a0)
    8000403c:	4705                	li	a4,1
    8000403e:	04e78363          	beq	a5,a4,80004084 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004042:	470d                	li	a4,3
    80004044:	04e78763          	beq	a5,a4,80004092 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004048:	4709                	li	a4,2
    8000404a:	06e79a63          	bne	a5,a4,800040be <fileread+0x9e>
    ilock(f->ip);
    8000404e:	6d08                	ld	a0,24(a0)
    80004050:	a00ff0ef          	jal	80003250 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004054:	874a                	mv	a4,s2
    80004056:	5094                	lw	a3,32(s1)
    80004058:	864e                	mv	a2,s3
    8000405a:	4585                	li	a1,1
    8000405c:	6c88                	ld	a0,24(s1)
    8000405e:	c46ff0ef          	jal	800034a4 <readi>
    80004062:	892a                	mv	s2,a0
    80004064:	00a05563          	blez	a0,8000406e <fileread+0x4e>
      f->off += r;
    80004068:	509c                	lw	a5,32(s1)
    8000406a:	9fa9                	addw	a5,a5,a0
    8000406c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000406e:	6c88                	ld	a0,24(s1)
    80004070:	a8eff0ef          	jal	800032fe <iunlock>
    80004074:	64e2                	ld	s1,24(sp)
    80004076:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004078:	854a                	mv	a0,s2
    8000407a:	70a2                	ld	ra,40(sp)
    8000407c:	7402                	ld	s0,32(sp)
    8000407e:	6942                	ld	s2,16(sp)
    80004080:	6145                	addi	sp,sp,48
    80004082:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004084:	6908                	ld	a0,16(a0)
    80004086:	388000ef          	jal	8000440e <piperead>
    8000408a:	892a                	mv	s2,a0
    8000408c:	64e2                	ld	s1,24(sp)
    8000408e:	69a2                	ld	s3,8(sp)
    80004090:	b7e5                	j	80004078 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004092:	02451783          	lh	a5,36(a0)
    80004096:	03079693          	slli	a3,a5,0x30
    8000409a:	92c1                	srli	a3,a3,0x30
    8000409c:	4725                	li	a4,9
    8000409e:	02d76863          	bltu	a4,a3,800040ce <fileread+0xae>
    800040a2:	0792                	slli	a5,a5,0x4
    800040a4:	0001c717          	auipc	a4,0x1c
    800040a8:	b4470713          	addi	a4,a4,-1212 # 8001fbe8 <devsw>
    800040ac:	97ba                	add	a5,a5,a4
    800040ae:	639c                	ld	a5,0(a5)
    800040b0:	c39d                	beqz	a5,800040d6 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800040b2:	4505                	li	a0,1
    800040b4:	9782                	jalr	a5
    800040b6:	892a                	mv	s2,a0
    800040b8:	64e2                	ld	s1,24(sp)
    800040ba:	69a2                	ld	s3,8(sp)
    800040bc:	bf75                	j	80004078 <fileread+0x58>
    panic("fileread");
    800040be:	00003517          	auipc	a0,0x3
    800040c2:	65a50513          	addi	a0,a0,1626 # 80007718 <etext+0x718>
    800040c6:	ecefc0ef          	jal	80000794 <panic>
    return -1;
    800040ca:	597d                	li	s2,-1
    800040cc:	b775                	j	80004078 <fileread+0x58>
      return -1;
    800040ce:	597d                	li	s2,-1
    800040d0:	64e2                	ld	s1,24(sp)
    800040d2:	69a2                	ld	s3,8(sp)
    800040d4:	b755                	j	80004078 <fileread+0x58>
    800040d6:	597d                	li	s2,-1
    800040d8:	64e2                	ld	s1,24(sp)
    800040da:	69a2                	ld	s3,8(sp)
    800040dc:	bf71                	j	80004078 <fileread+0x58>

00000000800040de <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800040de:	00954783          	lbu	a5,9(a0)
    800040e2:	10078b63          	beqz	a5,800041f8 <filewrite+0x11a>
{
    800040e6:	715d                	addi	sp,sp,-80
    800040e8:	e486                	sd	ra,72(sp)
    800040ea:	e0a2                	sd	s0,64(sp)
    800040ec:	f84a                	sd	s2,48(sp)
    800040ee:	f052                	sd	s4,32(sp)
    800040f0:	e85a                	sd	s6,16(sp)
    800040f2:	0880                	addi	s0,sp,80
    800040f4:	892a                	mv	s2,a0
    800040f6:	8b2e                	mv	s6,a1
    800040f8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800040fa:	411c                	lw	a5,0(a0)
    800040fc:	4705                	li	a4,1
    800040fe:	02e78763          	beq	a5,a4,8000412c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004102:	470d                	li	a4,3
    80004104:	02e78863          	beq	a5,a4,80004134 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004108:	4709                	li	a4,2
    8000410a:	0ce79c63          	bne	a5,a4,800041e2 <filewrite+0x104>
    8000410e:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004110:	0ac05863          	blez	a2,800041c0 <filewrite+0xe2>
    80004114:	fc26                	sd	s1,56(sp)
    80004116:	ec56                	sd	s5,24(sp)
    80004118:	e45e                	sd	s7,8(sp)
    8000411a:	e062                	sd	s8,0(sp)
    int i = 0;
    8000411c:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000411e:	6b85                	lui	s7,0x1
    80004120:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004124:	6c05                	lui	s8,0x1
    80004126:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000412a:	a8b5                	j	800041a6 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    8000412c:	6908                	ld	a0,16(a0)
    8000412e:	1fc000ef          	jal	8000432a <pipewrite>
    80004132:	a04d                	j	800041d4 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004134:	02451783          	lh	a5,36(a0)
    80004138:	03079693          	slli	a3,a5,0x30
    8000413c:	92c1                	srli	a3,a3,0x30
    8000413e:	4725                	li	a4,9
    80004140:	0ad76e63          	bltu	a4,a3,800041fc <filewrite+0x11e>
    80004144:	0792                	slli	a5,a5,0x4
    80004146:	0001c717          	auipc	a4,0x1c
    8000414a:	aa270713          	addi	a4,a4,-1374 # 8001fbe8 <devsw>
    8000414e:	97ba                	add	a5,a5,a4
    80004150:	679c                	ld	a5,8(a5)
    80004152:	c7dd                	beqz	a5,80004200 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004154:	4505                	li	a0,1
    80004156:	9782                	jalr	a5
    80004158:	a8b5                	j	800041d4 <filewrite+0xf6>
      if(n1 > max)
    8000415a:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    8000415e:	989ff0ef          	jal	80003ae6 <begin_op>
      ilock(f->ip);
    80004162:	01893503          	ld	a0,24(s2)
    80004166:	8eaff0ef          	jal	80003250 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000416a:	8756                	mv	a4,s5
    8000416c:	02092683          	lw	a3,32(s2)
    80004170:	01698633          	add	a2,s3,s6
    80004174:	4585                	li	a1,1
    80004176:	01893503          	ld	a0,24(s2)
    8000417a:	c26ff0ef          	jal	800035a0 <writei>
    8000417e:	84aa                	mv	s1,a0
    80004180:	00a05763          	blez	a0,8000418e <filewrite+0xb0>
        f->off += r;
    80004184:	02092783          	lw	a5,32(s2)
    80004188:	9fa9                	addw	a5,a5,a0
    8000418a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000418e:	01893503          	ld	a0,24(s2)
    80004192:	96cff0ef          	jal	800032fe <iunlock>
      end_op();
    80004196:	9bbff0ef          	jal	80003b50 <end_op>

      if(r != n1){
    8000419a:	029a9563          	bne	s5,s1,800041c4 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    8000419e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800041a2:	0149da63          	bge	s3,s4,800041b6 <filewrite+0xd8>
      int n1 = n - i;
    800041a6:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800041aa:	0004879b          	sext.w	a5,s1
    800041ae:	fafbd6e3          	bge	s7,a5,8000415a <filewrite+0x7c>
    800041b2:	84e2                	mv	s1,s8
    800041b4:	b75d                	j	8000415a <filewrite+0x7c>
    800041b6:	74e2                	ld	s1,56(sp)
    800041b8:	6ae2                	ld	s5,24(sp)
    800041ba:	6ba2                	ld	s7,8(sp)
    800041bc:	6c02                	ld	s8,0(sp)
    800041be:	a039                	j	800041cc <filewrite+0xee>
    int i = 0;
    800041c0:	4981                	li	s3,0
    800041c2:	a029                	j	800041cc <filewrite+0xee>
    800041c4:	74e2                	ld	s1,56(sp)
    800041c6:	6ae2                	ld	s5,24(sp)
    800041c8:	6ba2                	ld	s7,8(sp)
    800041ca:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800041cc:	033a1c63          	bne	s4,s3,80004204 <filewrite+0x126>
    800041d0:	8552                	mv	a0,s4
    800041d2:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800041d4:	60a6                	ld	ra,72(sp)
    800041d6:	6406                	ld	s0,64(sp)
    800041d8:	7942                	ld	s2,48(sp)
    800041da:	7a02                	ld	s4,32(sp)
    800041dc:	6b42                	ld	s6,16(sp)
    800041de:	6161                	addi	sp,sp,80
    800041e0:	8082                	ret
    800041e2:	fc26                	sd	s1,56(sp)
    800041e4:	f44e                	sd	s3,40(sp)
    800041e6:	ec56                	sd	s5,24(sp)
    800041e8:	e45e                	sd	s7,8(sp)
    800041ea:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800041ec:	00003517          	auipc	a0,0x3
    800041f0:	53c50513          	addi	a0,a0,1340 # 80007728 <etext+0x728>
    800041f4:	da0fc0ef          	jal	80000794 <panic>
    return -1;
    800041f8:	557d                	li	a0,-1
}
    800041fa:	8082                	ret
      return -1;
    800041fc:	557d                	li	a0,-1
    800041fe:	bfd9                	j	800041d4 <filewrite+0xf6>
    80004200:	557d                	li	a0,-1
    80004202:	bfc9                	j	800041d4 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004204:	557d                	li	a0,-1
    80004206:	79a2                	ld	s3,40(sp)
    80004208:	b7f1                	j	800041d4 <filewrite+0xf6>

000000008000420a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000420a:	7179                	addi	sp,sp,-48
    8000420c:	f406                	sd	ra,40(sp)
    8000420e:	f022                	sd	s0,32(sp)
    80004210:	ec26                	sd	s1,24(sp)
    80004212:	e052                	sd	s4,0(sp)
    80004214:	1800                	addi	s0,sp,48
    80004216:	84aa                	mv	s1,a0
    80004218:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000421a:	0005b023          	sd	zero,0(a1)
    8000421e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004222:	c3bff0ef          	jal	80003e5c <filealloc>
    80004226:	e088                	sd	a0,0(s1)
    80004228:	c549                	beqz	a0,800042b2 <pipealloc+0xa8>
    8000422a:	c33ff0ef          	jal	80003e5c <filealloc>
    8000422e:	00aa3023          	sd	a0,0(s4)
    80004232:	cd25                	beqz	a0,800042aa <pipealloc+0xa0>
    80004234:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004236:	8effc0ef          	jal	80000b24 <kalloc>
    8000423a:	892a                	mv	s2,a0
    8000423c:	c12d                	beqz	a0,8000429e <pipealloc+0x94>
    8000423e:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004240:	4985                	li	s3,1
    80004242:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004246:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000424a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000424e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004252:	00003597          	auipc	a1,0x3
    80004256:	4e658593          	addi	a1,a1,1254 # 80007738 <etext+0x738>
    8000425a:	91bfc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    8000425e:	609c                	ld	a5,0(s1)
    80004260:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004264:	609c                	ld	a5,0(s1)
    80004266:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000426a:	609c                	ld	a5,0(s1)
    8000426c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004270:	609c                	ld	a5,0(s1)
    80004272:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004276:	000a3783          	ld	a5,0(s4)
    8000427a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000427e:	000a3783          	ld	a5,0(s4)
    80004282:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004286:	000a3783          	ld	a5,0(s4)
    8000428a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000428e:	000a3783          	ld	a5,0(s4)
    80004292:	0127b823          	sd	s2,16(a5)
  return 0;
    80004296:	4501                	li	a0,0
    80004298:	6942                	ld	s2,16(sp)
    8000429a:	69a2                	ld	s3,8(sp)
    8000429c:	a01d                	j	800042c2 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000429e:	6088                	ld	a0,0(s1)
    800042a0:	c119                	beqz	a0,800042a6 <pipealloc+0x9c>
    800042a2:	6942                	ld	s2,16(sp)
    800042a4:	a029                	j	800042ae <pipealloc+0xa4>
    800042a6:	6942                	ld	s2,16(sp)
    800042a8:	a029                	j	800042b2 <pipealloc+0xa8>
    800042aa:	6088                	ld	a0,0(s1)
    800042ac:	c10d                	beqz	a0,800042ce <pipealloc+0xc4>
    fileclose(*f0);
    800042ae:	c53ff0ef          	jal	80003f00 <fileclose>
  if(*f1)
    800042b2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800042b6:	557d                	li	a0,-1
  if(*f1)
    800042b8:	c789                	beqz	a5,800042c2 <pipealloc+0xb8>
    fileclose(*f1);
    800042ba:	853e                	mv	a0,a5
    800042bc:	c45ff0ef          	jal	80003f00 <fileclose>
  return -1;
    800042c0:	557d                	li	a0,-1
}
    800042c2:	70a2                	ld	ra,40(sp)
    800042c4:	7402                	ld	s0,32(sp)
    800042c6:	64e2                	ld	s1,24(sp)
    800042c8:	6a02                	ld	s4,0(sp)
    800042ca:	6145                	addi	sp,sp,48
    800042cc:	8082                	ret
  return -1;
    800042ce:	557d                	li	a0,-1
    800042d0:	bfcd                	j	800042c2 <pipealloc+0xb8>

00000000800042d2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800042d2:	1101                	addi	sp,sp,-32
    800042d4:	ec06                	sd	ra,24(sp)
    800042d6:	e822                	sd	s0,16(sp)
    800042d8:	e426                	sd	s1,8(sp)
    800042da:	e04a                	sd	s2,0(sp)
    800042dc:	1000                	addi	s0,sp,32
    800042de:	84aa                	mv	s1,a0
    800042e0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800042e2:	913fc0ef          	jal	80000bf4 <acquire>
  if(writable){
    800042e6:	02090763          	beqz	s2,80004314 <pipeclose+0x42>
    pi->writeopen = 0;
    800042ea:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800042ee:	21848513          	addi	a0,s1,536
    800042f2:	c99fd0ef          	jal	80001f8a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800042f6:	2204b783          	ld	a5,544(s1)
    800042fa:	e785                	bnez	a5,80004322 <pipeclose+0x50>
    release(&pi->lock);
    800042fc:	8526                	mv	a0,s1
    800042fe:	98ffc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    80004302:	8526                	mv	a0,s1
    80004304:	f3efc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    80004308:	60e2                	ld	ra,24(sp)
    8000430a:	6442                	ld	s0,16(sp)
    8000430c:	64a2                	ld	s1,8(sp)
    8000430e:	6902                	ld	s2,0(sp)
    80004310:	6105                	addi	sp,sp,32
    80004312:	8082                	ret
    pi->readopen = 0;
    80004314:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004318:	21c48513          	addi	a0,s1,540
    8000431c:	c6ffd0ef          	jal	80001f8a <wakeup>
    80004320:	bfd9                	j	800042f6 <pipeclose+0x24>
    release(&pi->lock);
    80004322:	8526                	mv	a0,s1
    80004324:	969fc0ef          	jal	80000c8c <release>
}
    80004328:	b7c5                	j	80004308 <pipeclose+0x36>

000000008000432a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000432a:	711d                	addi	sp,sp,-96
    8000432c:	ec86                	sd	ra,88(sp)
    8000432e:	e8a2                	sd	s0,80(sp)
    80004330:	e4a6                	sd	s1,72(sp)
    80004332:	e0ca                	sd	s2,64(sp)
    80004334:	fc4e                	sd	s3,56(sp)
    80004336:	f852                	sd	s4,48(sp)
    80004338:	f456                	sd	s5,40(sp)
    8000433a:	1080                	addi	s0,sp,96
    8000433c:	84aa                	mv	s1,a0
    8000433e:	8aae                	mv	s5,a1
    80004340:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004342:	e2efd0ef          	jal	80001970 <myproc>
    80004346:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004348:	8526                	mv	a0,s1
    8000434a:	8abfc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    8000434e:	0b405a63          	blez	s4,80004402 <pipewrite+0xd8>
    80004352:	f05a                	sd	s6,32(sp)
    80004354:	ec5e                	sd	s7,24(sp)
    80004356:	e862                	sd	s8,16(sp)
  int i = 0;
    80004358:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000435a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000435c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004360:	21c48b93          	addi	s7,s1,540
    80004364:	a81d                	j	8000439a <pipewrite+0x70>
      release(&pi->lock);
    80004366:	8526                	mv	a0,s1
    80004368:	925fc0ef          	jal	80000c8c <release>
      return -1;
    8000436c:	597d                	li	s2,-1
    8000436e:	7b02                	ld	s6,32(sp)
    80004370:	6be2                	ld	s7,24(sp)
    80004372:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004374:	854a                	mv	a0,s2
    80004376:	60e6                	ld	ra,88(sp)
    80004378:	6446                	ld	s0,80(sp)
    8000437a:	64a6                	ld	s1,72(sp)
    8000437c:	6906                	ld	s2,64(sp)
    8000437e:	79e2                	ld	s3,56(sp)
    80004380:	7a42                	ld	s4,48(sp)
    80004382:	7aa2                	ld	s5,40(sp)
    80004384:	6125                	addi	sp,sp,96
    80004386:	8082                	ret
      wakeup(&pi->nread);
    80004388:	8562                	mv	a0,s8
    8000438a:	c01fd0ef          	jal	80001f8a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000438e:	85a6                	mv	a1,s1
    80004390:	855e                	mv	a0,s7
    80004392:	badfd0ef          	jal	80001f3e <sleep>
  while(i < n){
    80004396:	05495b63          	bge	s2,s4,800043ec <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    8000439a:	2204a783          	lw	a5,544(s1)
    8000439e:	d7e1                	beqz	a5,80004366 <pipewrite+0x3c>
    800043a0:	854e                	mv	a0,s3
    800043a2:	dd5fd0ef          	jal	80002176 <killed>
    800043a6:	f161                	bnez	a0,80004366 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800043a8:	2184a783          	lw	a5,536(s1)
    800043ac:	21c4a703          	lw	a4,540(s1)
    800043b0:	2007879b          	addiw	a5,a5,512
    800043b4:	fcf70ae3          	beq	a4,a5,80004388 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800043b8:	4685                	li	a3,1
    800043ba:	01590633          	add	a2,s2,s5
    800043be:	faf40593          	addi	a1,s0,-81
    800043c2:	0509b503          	ld	a0,80(s3)
    800043c6:	af2fd0ef          	jal	800016b8 <copyin>
    800043ca:	03650e63          	beq	a0,s6,80004406 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800043ce:	21c4a783          	lw	a5,540(s1)
    800043d2:	0017871b          	addiw	a4,a5,1
    800043d6:	20e4ae23          	sw	a4,540(s1)
    800043da:	1ff7f793          	andi	a5,a5,511
    800043de:	97a6                	add	a5,a5,s1
    800043e0:	faf44703          	lbu	a4,-81(s0)
    800043e4:	00e78c23          	sb	a4,24(a5)
      i++;
    800043e8:	2905                	addiw	s2,s2,1
    800043ea:	b775                	j	80004396 <pipewrite+0x6c>
    800043ec:	7b02                	ld	s6,32(sp)
    800043ee:	6be2                	ld	s7,24(sp)
    800043f0:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800043f2:	21848513          	addi	a0,s1,536
    800043f6:	b95fd0ef          	jal	80001f8a <wakeup>
  release(&pi->lock);
    800043fa:	8526                	mv	a0,s1
    800043fc:	891fc0ef          	jal	80000c8c <release>
  return i;
    80004400:	bf95                	j	80004374 <pipewrite+0x4a>
  int i = 0;
    80004402:	4901                	li	s2,0
    80004404:	b7fd                	j	800043f2 <pipewrite+0xc8>
    80004406:	7b02                	ld	s6,32(sp)
    80004408:	6be2                	ld	s7,24(sp)
    8000440a:	6c42                	ld	s8,16(sp)
    8000440c:	b7dd                	j	800043f2 <pipewrite+0xc8>

000000008000440e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000440e:	715d                	addi	sp,sp,-80
    80004410:	e486                	sd	ra,72(sp)
    80004412:	e0a2                	sd	s0,64(sp)
    80004414:	fc26                	sd	s1,56(sp)
    80004416:	f84a                	sd	s2,48(sp)
    80004418:	f44e                	sd	s3,40(sp)
    8000441a:	f052                	sd	s4,32(sp)
    8000441c:	ec56                	sd	s5,24(sp)
    8000441e:	0880                	addi	s0,sp,80
    80004420:	84aa                	mv	s1,a0
    80004422:	892e                	mv	s2,a1
    80004424:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004426:	d4afd0ef          	jal	80001970 <myproc>
    8000442a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000442c:	8526                	mv	a0,s1
    8000442e:	fc6fc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004432:	2184a703          	lw	a4,536(s1)
    80004436:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000443a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000443e:	02f71563          	bne	a4,a5,80004468 <piperead+0x5a>
    80004442:	2244a783          	lw	a5,548(s1)
    80004446:	cb85                	beqz	a5,80004476 <piperead+0x68>
    if(killed(pr)){
    80004448:	8552                	mv	a0,s4
    8000444a:	d2dfd0ef          	jal	80002176 <killed>
    8000444e:	ed19                	bnez	a0,8000446c <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004450:	85a6                	mv	a1,s1
    80004452:	854e                	mv	a0,s3
    80004454:	aebfd0ef          	jal	80001f3e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004458:	2184a703          	lw	a4,536(s1)
    8000445c:	21c4a783          	lw	a5,540(s1)
    80004460:	fef701e3          	beq	a4,a5,80004442 <piperead+0x34>
    80004464:	e85a                	sd	s6,16(sp)
    80004466:	a809                	j	80004478 <piperead+0x6a>
    80004468:	e85a                	sd	s6,16(sp)
    8000446a:	a039                	j	80004478 <piperead+0x6a>
      release(&pi->lock);
    8000446c:	8526                	mv	a0,s1
    8000446e:	81ffc0ef          	jal	80000c8c <release>
      return -1;
    80004472:	59fd                	li	s3,-1
    80004474:	a8b1                	j	800044d0 <piperead+0xc2>
    80004476:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004478:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000447a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000447c:	05505263          	blez	s5,800044c0 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004480:	2184a783          	lw	a5,536(s1)
    80004484:	21c4a703          	lw	a4,540(s1)
    80004488:	02f70c63          	beq	a4,a5,800044c0 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000448c:	0017871b          	addiw	a4,a5,1
    80004490:	20e4ac23          	sw	a4,536(s1)
    80004494:	1ff7f793          	andi	a5,a5,511
    80004498:	97a6                	add	a5,a5,s1
    8000449a:	0187c783          	lbu	a5,24(a5)
    8000449e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800044a2:	4685                	li	a3,1
    800044a4:	fbf40613          	addi	a2,s0,-65
    800044a8:	85ca                	mv	a1,s2
    800044aa:	050a3503          	ld	a0,80(s4)
    800044ae:	934fd0ef          	jal	800015e2 <copyout>
    800044b2:	01650763          	beq	a0,s6,800044c0 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800044b6:	2985                	addiw	s3,s3,1
    800044b8:	0905                	addi	s2,s2,1
    800044ba:	fd3a93e3          	bne	s5,s3,80004480 <piperead+0x72>
    800044be:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800044c0:	21c48513          	addi	a0,s1,540
    800044c4:	ac7fd0ef          	jal	80001f8a <wakeup>
  release(&pi->lock);
    800044c8:	8526                	mv	a0,s1
    800044ca:	fc2fc0ef          	jal	80000c8c <release>
    800044ce:	6b42                	ld	s6,16(sp)
  return i;
}
    800044d0:	854e                	mv	a0,s3
    800044d2:	60a6                	ld	ra,72(sp)
    800044d4:	6406                	ld	s0,64(sp)
    800044d6:	74e2                	ld	s1,56(sp)
    800044d8:	7942                	ld	s2,48(sp)
    800044da:	79a2                	ld	s3,40(sp)
    800044dc:	7a02                	ld	s4,32(sp)
    800044de:	6ae2                	ld	s5,24(sp)
    800044e0:	6161                	addi	sp,sp,80
    800044e2:	8082                	ret

00000000800044e4 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800044e4:	1141                	addi	sp,sp,-16
    800044e6:	e422                	sd	s0,8(sp)
    800044e8:	0800                	addi	s0,sp,16
    800044ea:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800044ec:	8905                	andi	a0,a0,1
    800044ee:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800044f0:	8b89                	andi	a5,a5,2
    800044f2:	c399                	beqz	a5,800044f8 <flags2perm+0x14>
      perm |= PTE_W;
    800044f4:	00456513          	ori	a0,a0,4
    return perm;
}
    800044f8:	6422                	ld	s0,8(sp)
    800044fa:	0141                	addi	sp,sp,16
    800044fc:	8082                	ret

00000000800044fe <exec>:

int
exec(char *path, char **argv)
{
    800044fe:	df010113          	addi	sp,sp,-528
    80004502:	20113423          	sd	ra,520(sp)
    80004506:	20813023          	sd	s0,512(sp)
    8000450a:	ffa6                	sd	s1,504(sp)
    8000450c:	fbca                	sd	s2,496(sp)
    8000450e:	0c00                	addi	s0,sp,528
    80004510:	892a                	mv	s2,a0
    80004512:	dea43c23          	sd	a0,-520(s0)
    80004516:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000451a:	c56fd0ef          	jal	80001970 <myproc>
    8000451e:	84aa                	mv	s1,a0

  begin_op();
    80004520:	dc6ff0ef          	jal	80003ae6 <begin_op>

  if((ip = namei(path)) == 0){
    80004524:	854a                	mv	a0,s2
    80004526:	c04ff0ef          	jal	8000392a <namei>
    8000452a:	c931                	beqz	a0,8000457e <exec+0x80>
    8000452c:	f3d2                	sd	s4,480(sp)
    8000452e:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004530:	d21fe0ef          	jal	80003250 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004534:	04000713          	li	a4,64
    80004538:	4681                	li	a3,0
    8000453a:	e5040613          	addi	a2,s0,-432
    8000453e:	4581                	li	a1,0
    80004540:	8552                	mv	a0,s4
    80004542:	f63fe0ef          	jal	800034a4 <readi>
    80004546:	04000793          	li	a5,64
    8000454a:	00f51a63          	bne	a0,a5,8000455e <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000454e:	e5042703          	lw	a4,-432(s0)
    80004552:	464c47b7          	lui	a5,0x464c4
    80004556:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000455a:	02f70663          	beq	a4,a5,80004586 <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000455e:	8552                	mv	a0,s4
    80004560:	efbfe0ef          	jal	8000345a <iunlockput>
    end_op();
    80004564:	decff0ef          	jal	80003b50 <end_op>
  }
  return -1;
    80004568:	557d                	li	a0,-1
    8000456a:	7a1e                	ld	s4,480(sp)
}
    8000456c:	20813083          	ld	ra,520(sp)
    80004570:	20013403          	ld	s0,512(sp)
    80004574:	74fe                	ld	s1,504(sp)
    80004576:	795e                	ld	s2,496(sp)
    80004578:	21010113          	addi	sp,sp,528
    8000457c:	8082                	ret
    end_op();
    8000457e:	dd2ff0ef          	jal	80003b50 <end_op>
    return -1;
    80004582:	557d                	li	a0,-1
    80004584:	b7e5                	j	8000456c <exec+0x6e>
    80004586:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004588:	8526                	mv	a0,s1
    8000458a:	c8efd0ef          	jal	80001a18 <proc_pagetable>
    8000458e:	8b2a                	mv	s6,a0
    80004590:	2c050b63          	beqz	a0,80004866 <exec+0x368>
    80004594:	f7ce                	sd	s3,488(sp)
    80004596:	efd6                	sd	s5,472(sp)
    80004598:	e7de                	sd	s7,456(sp)
    8000459a:	e3e2                	sd	s8,448(sp)
    8000459c:	ff66                	sd	s9,440(sp)
    8000459e:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045a0:	e7042d03          	lw	s10,-400(s0)
    800045a4:	e8845783          	lhu	a5,-376(s0)
    800045a8:	12078963          	beqz	a5,800046da <exec+0x1dc>
    800045ac:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800045ae:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045b0:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800045b2:	6c85                	lui	s9,0x1
    800045b4:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800045b8:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800045bc:	6a85                	lui	s5,0x1
    800045be:	a085                	j	8000461e <exec+0x120>
      panic("loadseg: address should exist");
    800045c0:	00003517          	auipc	a0,0x3
    800045c4:	18050513          	addi	a0,a0,384 # 80007740 <etext+0x740>
    800045c8:	9ccfc0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    800045cc:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800045ce:	8726                	mv	a4,s1
    800045d0:	012c06bb          	addw	a3,s8,s2
    800045d4:	4581                	li	a1,0
    800045d6:	8552                	mv	a0,s4
    800045d8:	ecdfe0ef          	jal	800034a4 <readi>
    800045dc:	2501                	sext.w	a0,a0
    800045de:	24a49a63          	bne	s1,a0,80004832 <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    800045e2:	012a893b          	addw	s2,s5,s2
    800045e6:	03397363          	bgeu	s2,s3,8000460c <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800045ea:	02091593          	slli	a1,s2,0x20
    800045ee:	9181                	srli	a1,a1,0x20
    800045f0:	95de                	add	a1,a1,s7
    800045f2:	855a                	mv	a0,s6
    800045f4:	a73fc0ef          	jal	80001066 <walkaddr>
    800045f8:	862a                	mv	a2,a0
    if(pa == 0)
    800045fa:	d179                	beqz	a0,800045c0 <exec+0xc2>
    if(sz - i < PGSIZE)
    800045fc:	412984bb          	subw	s1,s3,s2
    80004600:	0004879b          	sext.w	a5,s1
    80004604:	fcfcf4e3          	bgeu	s9,a5,800045cc <exec+0xce>
    80004608:	84d6                	mv	s1,s5
    8000460a:	b7c9                	j	800045cc <exec+0xce>
    sz = sz1;
    8000460c:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004610:	2d85                	addiw	s11,s11,1
    80004612:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004616:	e8845783          	lhu	a5,-376(s0)
    8000461a:	08fdd063          	bge	s11,a5,8000469a <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000461e:	2d01                	sext.w	s10,s10
    80004620:	03800713          	li	a4,56
    80004624:	86ea                	mv	a3,s10
    80004626:	e1840613          	addi	a2,s0,-488
    8000462a:	4581                	li	a1,0
    8000462c:	8552                	mv	a0,s4
    8000462e:	e77fe0ef          	jal	800034a4 <readi>
    80004632:	03800793          	li	a5,56
    80004636:	1cf51663          	bne	a0,a5,80004802 <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    8000463a:	e1842783          	lw	a5,-488(s0)
    8000463e:	4705                	li	a4,1
    80004640:	fce798e3          	bne	a5,a4,80004610 <exec+0x112>
    if(ph.memsz < ph.filesz)
    80004644:	e4043483          	ld	s1,-448(s0)
    80004648:	e3843783          	ld	a5,-456(s0)
    8000464c:	1af4ef63          	bltu	s1,a5,8000480a <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004650:	e2843783          	ld	a5,-472(s0)
    80004654:	94be                	add	s1,s1,a5
    80004656:	1af4ee63          	bltu	s1,a5,80004812 <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    8000465a:	df043703          	ld	a4,-528(s0)
    8000465e:	8ff9                	and	a5,a5,a4
    80004660:	1a079d63          	bnez	a5,8000481a <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004664:	e1c42503          	lw	a0,-484(s0)
    80004668:	e7dff0ef          	jal	800044e4 <flags2perm>
    8000466c:	86aa                	mv	a3,a0
    8000466e:	8626                	mv	a2,s1
    80004670:	85ca                	mv	a1,s2
    80004672:	855a                	mv	a0,s6
    80004674:	d5bfc0ef          	jal	800013ce <uvmalloc>
    80004678:	e0a43423          	sd	a0,-504(s0)
    8000467c:	1a050363          	beqz	a0,80004822 <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004680:	e2843b83          	ld	s7,-472(s0)
    80004684:	e2042c03          	lw	s8,-480(s0)
    80004688:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000468c:	00098463          	beqz	s3,80004694 <exec+0x196>
    80004690:	4901                	li	s2,0
    80004692:	bfa1                	j	800045ea <exec+0xec>
    sz = sz1;
    80004694:	e0843903          	ld	s2,-504(s0)
    80004698:	bfa5                	j	80004610 <exec+0x112>
    8000469a:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    8000469c:	8552                	mv	a0,s4
    8000469e:	dbdfe0ef          	jal	8000345a <iunlockput>
  end_op();
    800046a2:	caeff0ef          	jal	80003b50 <end_op>
  p = myproc();
    800046a6:	acafd0ef          	jal	80001970 <myproc>
    800046aa:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800046ac:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800046b0:	6985                	lui	s3,0x1
    800046b2:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800046b4:	99ca                	add	s3,s3,s2
    800046b6:	77fd                	lui	a5,0xfffff
    800046b8:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800046bc:	4691                	li	a3,4
    800046be:	6609                	lui	a2,0x2
    800046c0:	964e                	add	a2,a2,s3
    800046c2:	85ce                	mv	a1,s3
    800046c4:	855a                	mv	a0,s6
    800046c6:	d09fc0ef          	jal	800013ce <uvmalloc>
    800046ca:	892a                	mv	s2,a0
    800046cc:	e0a43423          	sd	a0,-504(s0)
    800046d0:	e519                	bnez	a0,800046de <exec+0x1e0>
  if(pagetable)
    800046d2:	e1343423          	sd	s3,-504(s0)
    800046d6:	4a01                	li	s4,0
    800046d8:	aab1                	j	80004834 <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800046da:	4901                	li	s2,0
    800046dc:	b7c1                	j	8000469c <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800046de:	75f9                	lui	a1,0xffffe
    800046e0:	95aa                	add	a1,a1,a0
    800046e2:	855a                	mv	a0,s6
    800046e4:	ed5fc0ef          	jal	800015b8 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800046e8:	7bfd                	lui	s7,0xfffff
    800046ea:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800046ec:	e0043783          	ld	a5,-512(s0)
    800046f0:	6388                	ld	a0,0(a5)
    800046f2:	cd39                	beqz	a0,80004750 <exec+0x252>
    800046f4:	e9040993          	addi	s3,s0,-368
    800046f8:	f9040c13          	addi	s8,s0,-112
    800046fc:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800046fe:	f3afc0ef          	jal	80000e38 <strlen>
    80004702:	0015079b          	addiw	a5,a0,1
    80004706:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000470a:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000470e:	11796e63          	bltu	s2,s7,8000482a <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004712:	e0043d03          	ld	s10,-512(s0)
    80004716:	000d3a03          	ld	s4,0(s10)
    8000471a:	8552                	mv	a0,s4
    8000471c:	f1cfc0ef          	jal	80000e38 <strlen>
    80004720:	0015069b          	addiw	a3,a0,1
    80004724:	8652                	mv	a2,s4
    80004726:	85ca                	mv	a1,s2
    80004728:	855a                	mv	a0,s6
    8000472a:	eb9fc0ef          	jal	800015e2 <copyout>
    8000472e:	10054063          	bltz	a0,8000482e <exec+0x330>
    ustack[argc] = sp;
    80004732:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004736:	0485                	addi	s1,s1,1
    80004738:	008d0793          	addi	a5,s10,8
    8000473c:	e0f43023          	sd	a5,-512(s0)
    80004740:	008d3503          	ld	a0,8(s10)
    80004744:	c909                	beqz	a0,80004756 <exec+0x258>
    if(argc >= MAXARG)
    80004746:	09a1                	addi	s3,s3,8
    80004748:	fb899be3          	bne	s3,s8,800046fe <exec+0x200>
  ip = 0;
    8000474c:	4a01                	li	s4,0
    8000474e:	a0dd                	j	80004834 <exec+0x336>
  sp = sz;
    80004750:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004754:	4481                	li	s1,0
  ustack[argc] = 0;
    80004756:	00349793          	slli	a5,s1,0x3
    8000475a:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffde210>
    8000475e:	97a2                	add	a5,a5,s0
    80004760:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004764:	00148693          	addi	a3,s1,1
    80004768:	068e                	slli	a3,a3,0x3
    8000476a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000476e:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004772:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004776:	f5796ee3          	bltu	s2,s7,800046d2 <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000477a:	e9040613          	addi	a2,s0,-368
    8000477e:	85ca                	mv	a1,s2
    80004780:	855a                	mv	a0,s6
    80004782:	e61fc0ef          	jal	800015e2 <copyout>
    80004786:	0e054263          	bltz	a0,8000486a <exec+0x36c>
  p->trapframe->a1 = sp;
    8000478a:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000478e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004792:	df843783          	ld	a5,-520(s0)
    80004796:	0007c703          	lbu	a4,0(a5)
    8000479a:	cf11                	beqz	a4,800047b6 <exec+0x2b8>
    8000479c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000479e:	02f00693          	li	a3,47
    800047a2:	a039                	j	800047b0 <exec+0x2b2>
      last = s+1;
    800047a4:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800047a8:	0785                	addi	a5,a5,1
    800047aa:	fff7c703          	lbu	a4,-1(a5)
    800047ae:	c701                	beqz	a4,800047b6 <exec+0x2b8>
    if(*s == '/')
    800047b0:	fed71ce3          	bne	a4,a3,800047a8 <exec+0x2aa>
    800047b4:	bfc5                	j	800047a4 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    800047b6:	4641                	li	a2,16
    800047b8:	df843583          	ld	a1,-520(s0)
    800047bc:	158a8513          	addi	a0,s5,344
    800047c0:	e46fc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    800047c4:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800047c8:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800047cc:	e0843783          	ld	a5,-504(s0)
    800047d0:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800047d4:	058ab783          	ld	a5,88(s5)
    800047d8:	e6843703          	ld	a4,-408(s0)
    800047dc:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800047de:	058ab783          	ld	a5,88(s5)
    800047e2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800047e6:	85e6                	mv	a1,s9
    800047e8:	ab4fd0ef          	jal	80001a9c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800047ec:	0004851b          	sext.w	a0,s1
    800047f0:	79be                	ld	s3,488(sp)
    800047f2:	7a1e                	ld	s4,480(sp)
    800047f4:	6afe                	ld	s5,472(sp)
    800047f6:	6b5e                	ld	s6,464(sp)
    800047f8:	6bbe                	ld	s7,456(sp)
    800047fa:	6c1e                	ld	s8,448(sp)
    800047fc:	7cfa                	ld	s9,440(sp)
    800047fe:	7d5a                	ld	s10,432(sp)
    80004800:	b3b5                	j	8000456c <exec+0x6e>
    80004802:	e1243423          	sd	s2,-504(s0)
    80004806:	7dba                	ld	s11,424(sp)
    80004808:	a035                	j	80004834 <exec+0x336>
    8000480a:	e1243423          	sd	s2,-504(s0)
    8000480e:	7dba                	ld	s11,424(sp)
    80004810:	a015                	j	80004834 <exec+0x336>
    80004812:	e1243423          	sd	s2,-504(s0)
    80004816:	7dba                	ld	s11,424(sp)
    80004818:	a831                	j	80004834 <exec+0x336>
    8000481a:	e1243423          	sd	s2,-504(s0)
    8000481e:	7dba                	ld	s11,424(sp)
    80004820:	a811                	j	80004834 <exec+0x336>
    80004822:	e1243423          	sd	s2,-504(s0)
    80004826:	7dba                	ld	s11,424(sp)
    80004828:	a031                	j	80004834 <exec+0x336>
  ip = 0;
    8000482a:	4a01                	li	s4,0
    8000482c:	a021                	j	80004834 <exec+0x336>
    8000482e:	4a01                	li	s4,0
  if(pagetable)
    80004830:	a011                	j	80004834 <exec+0x336>
    80004832:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004834:	e0843583          	ld	a1,-504(s0)
    80004838:	855a                	mv	a0,s6
    8000483a:	a62fd0ef          	jal	80001a9c <proc_freepagetable>
  return -1;
    8000483e:	557d                	li	a0,-1
  if(ip){
    80004840:	000a1b63          	bnez	s4,80004856 <exec+0x358>
    80004844:	79be                	ld	s3,488(sp)
    80004846:	7a1e                	ld	s4,480(sp)
    80004848:	6afe                	ld	s5,472(sp)
    8000484a:	6b5e                	ld	s6,464(sp)
    8000484c:	6bbe                	ld	s7,456(sp)
    8000484e:	6c1e                	ld	s8,448(sp)
    80004850:	7cfa                	ld	s9,440(sp)
    80004852:	7d5a                	ld	s10,432(sp)
    80004854:	bb21                	j	8000456c <exec+0x6e>
    80004856:	79be                	ld	s3,488(sp)
    80004858:	6afe                	ld	s5,472(sp)
    8000485a:	6b5e                	ld	s6,464(sp)
    8000485c:	6bbe                	ld	s7,456(sp)
    8000485e:	6c1e                	ld	s8,448(sp)
    80004860:	7cfa                	ld	s9,440(sp)
    80004862:	7d5a                	ld	s10,432(sp)
    80004864:	b9ed                	j	8000455e <exec+0x60>
    80004866:	6b5e                	ld	s6,464(sp)
    80004868:	b9dd                	j	8000455e <exec+0x60>
  sz = sz1;
    8000486a:	e0843983          	ld	s3,-504(s0)
    8000486e:	b595                	j	800046d2 <exec+0x1d4>

0000000080004870 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004870:	7179                	addi	sp,sp,-48
    80004872:	f406                	sd	ra,40(sp)
    80004874:	f022                	sd	s0,32(sp)
    80004876:	ec26                	sd	s1,24(sp)
    80004878:	e84a                	sd	s2,16(sp)
    8000487a:	1800                	addi	s0,sp,48
    8000487c:	892e                	mv	s2,a1
    8000487e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004880:	fdc40593          	addi	a1,s0,-36
    80004884:	fa1fd0ef          	jal	80002824 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004888:	fdc42703          	lw	a4,-36(s0)
    8000488c:	47bd                	li	a5,15
    8000488e:	02e7e963          	bltu	a5,a4,800048c0 <argfd+0x50>
    80004892:	8defd0ef          	jal	80001970 <myproc>
    80004896:	fdc42703          	lw	a4,-36(s0)
    8000489a:	01a70793          	addi	a5,a4,26
    8000489e:	078e                	slli	a5,a5,0x3
    800048a0:	953e                	add	a0,a0,a5
    800048a2:	611c                	ld	a5,0(a0)
    800048a4:	c385                	beqz	a5,800048c4 <argfd+0x54>
    return -1;
  if(pfd)
    800048a6:	00090463          	beqz	s2,800048ae <argfd+0x3e>
    *pfd = fd;
    800048aa:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800048ae:	4501                	li	a0,0
  if(pf)
    800048b0:	c091                	beqz	s1,800048b4 <argfd+0x44>
    *pf = f;
    800048b2:	e09c                	sd	a5,0(s1)
}
    800048b4:	70a2                	ld	ra,40(sp)
    800048b6:	7402                	ld	s0,32(sp)
    800048b8:	64e2                	ld	s1,24(sp)
    800048ba:	6942                	ld	s2,16(sp)
    800048bc:	6145                	addi	sp,sp,48
    800048be:	8082                	ret
    return -1;
    800048c0:	557d                	li	a0,-1
    800048c2:	bfcd                	j	800048b4 <argfd+0x44>
    800048c4:	557d                	li	a0,-1
    800048c6:	b7fd                	j	800048b4 <argfd+0x44>

00000000800048c8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800048c8:	1101                	addi	sp,sp,-32
    800048ca:	ec06                	sd	ra,24(sp)
    800048cc:	e822                	sd	s0,16(sp)
    800048ce:	e426                	sd	s1,8(sp)
    800048d0:	1000                	addi	s0,sp,32
    800048d2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800048d4:	89cfd0ef          	jal	80001970 <myproc>
    800048d8:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800048da:	0d050793          	addi	a5,a0,208
    800048de:	4501                	li	a0,0
    800048e0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800048e2:	6398                	ld	a4,0(a5)
    800048e4:	cb19                	beqz	a4,800048fa <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800048e6:	2505                	addiw	a0,a0,1
    800048e8:	07a1                	addi	a5,a5,8
    800048ea:	fed51ce3          	bne	a0,a3,800048e2 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800048ee:	557d                	li	a0,-1
}
    800048f0:	60e2                	ld	ra,24(sp)
    800048f2:	6442                	ld	s0,16(sp)
    800048f4:	64a2                	ld	s1,8(sp)
    800048f6:	6105                	addi	sp,sp,32
    800048f8:	8082                	ret
      p->ofile[fd] = f;
    800048fa:	01a50793          	addi	a5,a0,26
    800048fe:	078e                	slli	a5,a5,0x3
    80004900:	963e                	add	a2,a2,a5
    80004902:	e204                	sd	s1,0(a2)
      return fd;
    80004904:	b7f5                	j	800048f0 <fdalloc+0x28>

0000000080004906 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004906:	715d                	addi	sp,sp,-80
    80004908:	e486                	sd	ra,72(sp)
    8000490a:	e0a2                	sd	s0,64(sp)
    8000490c:	fc26                	sd	s1,56(sp)
    8000490e:	f84a                	sd	s2,48(sp)
    80004910:	f44e                	sd	s3,40(sp)
    80004912:	ec56                	sd	s5,24(sp)
    80004914:	e85a                	sd	s6,16(sp)
    80004916:	0880                	addi	s0,sp,80
    80004918:	8b2e                	mv	s6,a1
    8000491a:	89b2                	mv	s3,a2
    8000491c:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000491e:	fb040593          	addi	a1,s0,-80
    80004922:	822ff0ef          	jal	80003944 <nameiparent>
    80004926:	84aa                	mv	s1,a0
    80004928:	10050a63          	beqz	a0,80004a3c <create+0x136>
    return 0;

  ilock(dp);
    8000492c:	925fe0ef          	jal	80003250 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004930:	4601                	li	a2,0
    80004932:	fb040593          	addi	a1,s0,-80
    80004936:	8526                	mv	a0,s1
    80004938:	d8dfe0ef          	jal	800036c4 <dirlookup>
    8000493c:	8aaa                	mv	s5,a0
    8000493e:	c129                	beqz	a0,80004980 <create+0x7a>
    iunlockput(dp);
    80004940:	8526                	mv	a0,s1
    80004942:	b19fe0ef          	jal	8000345a <iunlockput>
    ilock(ip);
    80004946:	8556                	mv	a0,s5
    80004948:	909fe0ef          	jal	80003250 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000494c:	4789                	li	a5,2
    8000494e:	02fb1463          	bne	s6,a5,80004976 <create+0x70>
    80004952:	044ad783          	lhu	a5,68(s5)
    80004956:	37f9                	addiw	a5,a5,-2
    80004958:	17c2                	slli	a5,a5,0x30
    8000495a:	93c1                	srli	a5,a5,0x30
    8000495c:	4705                	li	a4,1
    8000495e:	00f76c63          	bltu	a4,a5,80004976 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004962:	8556                	mv	a0,s5
    80004964:	60a6                	ld	ra,72(sp)
    80004966:	6406                	ld	s0,64(sp)
    80004968:	74e2                	ld	s1,56(sp)
    8000496a:	7942                	ld	s2,48(sp)
    8000496c:	79a2                	ld	s3,40(sp)
    8000496e:	6ae2                	ld	s5,24(sp)
    80004970:	6b42                	ld	s6,16(sp)
    80004972:	6161                	addi	sp,sp,80
    80004974:	8082                	ret
    iunlockput(ip);
    80004976:	8556                	mv	a0,s5
    80004978:	ae3fe0ef          	jal	8000345a <iunlockput>
    return 0;
    8000497c:	4a81                	li	s5,0
    8000497e:	b7d5                	j	80004962 <create+0x5c>
    80004980:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004982:	85da                	mv	a1,s6
    80004984:	4088                	lw	a0,0(s1)
    80004986:	f5afe0ef          	jal	800030e0 <ialloc>
    8000498a:	8a2a                	mv	s4,a0
    8000498c:	cd15                	beqz	a0,800049c8 <create+0xc2>
  ilock(ip);
    8000498e:	8c3fe0ef          	jal	80003250 <ilock>
  ip->major = major;
    80004992:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004996:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000499a:	4905                	li	s2,1
    8000499c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800049a0:	8552                	mv	a0,s4
    800049a2:	ffafe0ef          	jal	8000319c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800049a6:	032b0763          	beq	s6,s2,800049d4 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    800049aa:	004a2603          	lw	a2,4(s4)
    800049ae:	fb040593          	addi	a1,s0,-80
    800049b2:	8526                	mv	a0,s1
    800049b4:	eddfe0ef          	jal	80003890 <dirlink>
    800049b8:	06054563          	bltz	a0,80004a22 <create+0x11c>
  iunlockput(dp);
    800049bc:	8526                	mv	a0,s1
    800049be:	a9dfe0ef          	jal	8000345a <iunlockput>
  return ip;
    800049c2:	8ad2                	mv	s5,s4
    800049c4:	7a02                	ld	s4,32(sp)
    800049c6:	bf71                	j	80004962 <create+0x5c>
    iunlockput(dp);
    800049c8:	8526                	mv	a0,s1
    800049ca:	a91fe0ef          	jal	8000345a <iunlockput>
    return 0;
    800049ce:	8ad2                	mv	s5,s4
    800049d0:	7a02                	ld	s4,32(sp)
    800049d2:	bf41                	j	80004962 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800049d4:	004a2603          	lw	a2,4(s4)
    800049d8:	00003597          	auipc	a1,0x3
    800049dc:	d8858593          	addi	a1,a1,-632 # 80007760 <etext+0x760>
    800049e0:	8552                	mv	a0,s4
    800049e2:	eaffe0ef          	jal	80003890 <dirlink>
    800049e6:	02054e63          	bltz	a0,80004a22 <create+0x11c>
    800049ea:	40d0                	lw	a2,4(s1)
    800049ec:	00003597          	auipc	a1,0x3
    800049f0:	d7c58593          	addi	a1,a1,-644 # 80007768 <etext+0x768>
    800049f4:	8552                	mv	a0,s4
    800049f6:	e9bfe0ef          	jal	80003890 <dirlink>
    800049fa:	02054463          	bltz	a0,80004a22 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    800049fe:	004a2603          	lw	a2,4(s4)
    80004a02:	fb040593          	addi	a1,s0,-80
    80004a06:	8526                	mv	a0,s1
    80004a08:	e89fe0ef          	jal	80003890 <dirlink>
    80004a0c:	00054b63          	bltz	a0,80004a22 <create+0x11c>
    dp->nlink++;  // for ".."
    80004a10:	04a4d783          	lhu	a5,74(s1)
    80004a14:	2785                	addiw	a5,a5,1
    80004a16:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004a1a:	8526                	mv	a0,s1
    80004a1c:	f80fe0ef          	jal	8000319c <iupdate>
    80004a20:	bf71                	j	800049bc <create+0xb6>
  ip->nlink = 0;
    80004a22:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004a26:	8552                	mv	a0,s4
    80004a28:	f74fe0ef          	jal	8000319c <iupdate>
  iunlockput(ip);
    80004a2c:	8552                	mv	a0,s4
    80004a2e:	a2dfe0ef          	jal	8000345a <iunlockput>
  iunlockput(dp);
    80004a32:	8526                	mv	a0,s1
    80004a34:	a27fe0ef          	jal	8000345a <iunlockput>
  return 0;
    80004a38:	7a02                	ld	s4,32(sp)
    80004a3a:	b725                	j	80004962 <create+0x5c>
    return 0;
    80004a3c:	8aaa                	mv	s5,a0
    80004a3e:	b715                	j	80004962 <create+0x5c>

0000000080004a40 <sys_dup>:
{
    80004a40:	7179                	addi	sp,sp,-48
    80004a42:	f406                	sd	ra,40(sp)
    80004a44:	f022                	sd	s0,32(sp)
    80004a46:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004a48:	fd840613          	addi	a2,s0,-40
    80004a4c:	4581                	li	a1,0
    80004a4e:	4501                	li	a0,0
    80004a50:	e21ff0ef          	jal	80004870 <argfd>
    return -1;
    80004a54:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004a56:	02054363          	bltz	a0,80004a7c <sys_dup+0x3c>
    80004a5a:	ec26                	sd	s1,24(sp)
    80004a5c:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004a5e:	fd843903          	ld	s2,-40(s0)
    80004a62:	854a                	mv	a0,s2
    80004a64:	e65ff0ef          	jal	800048c8 <fdalloc>
    80004a68:	84aa                	mv	s1,a0
    return -1;
    80004a6a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004a6c:	00054d63          	bltz	a0,80004a86 <sys_dup+0x46>
  filedup(f);
    80004a70:	854a                	mv	a0,s2
    80004a72:	c48ff0ef          	jal	80003eba <filedup>
  return fd;
    80004a76:	87a6                	mv	a5,s1
    80004a78:	64e2                	ld	s1,24(sp)
    80004a7a:	6942                	ld	s2,16(sp)
}
    80004a7c:	853e                	mv	a0,a5
    80004a7e:	70a2                	ld	ra,40(sp)
    80004a80:	7402                	ld	s0,32(sp)
    80004a82:	6145                	addi	sp,sp,48
    80004a84:	8082                	ret
    80004a86:	64e2                	ld	s1,24(sp)
    80004a88:	6942                	ld	s2,16(sp)
    80004a8a:	bfcd                	j	80004a7c <sys_dup+0x3c>

0000000080004a8c <sys_read>:
{
    80004a8c:	7179                	addi	sp,sp,-48
    80004a8e:	f406                	sd	ra,40(sp)
    80004a90:	f022                	sd	s0,32(sp)
    80004a92:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004a94:	fd840593          	addi	a1,s0,-40
    80004a98:	4505                	li	a0,1
    80004a9a:	da7fd0ef          	jal	80002840 <argaddr>
  argint(2, &n);
    80004a9e:	fe440593          	addi	a1,s0,-28
    80004aa2:	4509                	li	a0,2
    80004aa4:	d81fd0ef          	jal	80002824 <argint>
  if(argfd(0, 0, &f) < 0)
    80004aa8:	fe840613          	addi	a2,s0,-24
    80004aac:	4581                	li	a1,0
    80004aae:	4501                	li	a0,0
    80004ab0:	dc1ff0ef          	jal	80004870 <argfd>
    80004ab4:	87aa                	mv	a5,a0
    return -1;
    80004ab6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ab8:	0007ca63          	bltz	a5,80004acc <sys_read+0x40>
  return fileread(f, p, n);
    80004abc:	fe442603          	lw	a2,-28(s0)
    80004ac0:	fd843583          	ld	a1,-40(s0)
    80004ac4:	fe843503          	ld	a0,-24(s0)
    80004ac8:	d58ff0ef          	jal	80004020 <fileread>
}
    80004acc:	70a2                	ld	ra,40(sp)
    80004ace:	7402                	ld	s0,32(sp)
    80004ad0:	6145                	addi	sp,sp,48
    80004ad2:	8082                	ret

0000000080004ad4 <sys_write>:
{
    80004ad4:	7179                	addi	sp,sp,-48
    80004ad6:	f406                	sd	ra,40(sp)
    80004ad8:	f022                	sd	s0,32(sp)
    80004ada:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004adc:	fd840593          	addi	a1,s0,-40
    80004ae0:	4505                	li	a0,1
    80004ae2:	d5ffd0ef          	jal	80002840 <argaddr>
  argint(2, &n);
    80004ae6:	fe440593          	addi	a1,s0,-28
    80004aea:	4509                	li	a0,2
    80004aec:	d39fd0ef          	jal	80002824 <argint>
  if(argfd(0, 0, &f) < 0)
    80004af0:	fe840613          	addi	a2,s0,-24
    80004af4:	4581                	li	a1,0
    80004af6:	4501                	li	a0,0
    80004af8:	d79ff0ef          	jal	80004870 <argfd>
    80004afc:	87aa                	mv	a5,a0
    return -1;
    80004afe:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b00:	0007ca63          	bltz	a5,80004b14 <sys_write+0x40>
  return filewrite(f, p, n);
    80004b04:	fe442603          	lw	a2,-28(s0)
    80004b08:	fd843583          	ld	a1,-40(s0)
    80004b0c:	fe843503          	ld	a0,-24(s0)
    80004b10:	dceff0ef          	jal	800040de <filewrite>
}
    80004b14:	70a2                	ld	ra,40(sp)
    80004b16:	7402                	ld	s0,32(sp)
    80004b18:	6145                	addi	sp,sp,48
    80004b1a:	8082                	ret

0000000080004b1c <sys_close>:
{
    80004b1c:	1101                	addi	sp,sp,-32
    80004b1e:	ec06                	sd	ra,24(sp)
    80004b20:	e822                	sd	s0,16(sp)
    80004b22:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004b24:	fe040613          	addi	a2,s0,-32
    80004b28:	fec40593          	addi	a1,s0,-20
    80004b2c:	4501                	li	a0,0
    80004b2e:	d43ff0ef          	jal	80004870 <argfd>
    return -1;
    80004b32:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004b34:	02054063          	bltz	a0,80004b54 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004b38:	e39fc0ef          	jal	80001970 <myproc>
    80004b3c:	fec42783          	lw	a5,-20(s0)
    80004b40:	07e9                	addi	a5,a5,26
    80004b42:	078e                	slli	a5,a5,0x3
    80004b44:	953e                	add	a0,a0,a5
    80004b46:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004b4a:	fe043503          	ld	a0,-32(s0)
    80004b4e:	bb2ff0ef          	jal	80003f00 <fileclose>
  return 0;
    80004b52:	4781                	li	a5,0
}
    80004b54:	853e                	mv	a0,a5
    80004b56:	60e2                	ld	ra,24(sp)
    80004b58:	6442                	ld	s0,16(sp)
    80004b5a:	6105                	addi	sp,sp,32
    80004b5c:	8082                	ret

0000000080004b5e <sys_fstat>:
{
    80004b5e:	1101                	addi	sp,sp,-32
    80004b60:	ec06                	sd	ra,24(sp)
    80004b62:	e822                	sd	s0,16(sp)
    80004b64:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004b66:	fe040593          	addi	a1,s0,-32
    80004b6a:	4505                	li	a0,1
    80004b6c:	cd5fd0ef          	jal	80002840 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004b70:	fe840613          	addi	a2,s0,-24
    80004b74:	4581                	li	a1,0
    80004b76:	4501                	li	a0,0
    80004b78:	cf9ff0ef          	jal	80004870 <argfd>
    80004b7c:	87aa                	mv	a5,a0
    return -1;
    80004b7e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b80:	0007c863          	bltz	a5,80004b90 <sys_fstat+0x32>
  return filestat(f, st);
    80004b84:	fe043583          	ld	a1,-32(s0)
    80004b88:	fe843503          	ld	a0,-24(s0)
    80004b8c:	c36ff0ef          	jal	80003fc2 <filestat>
}
    80004b90:	60e2                	ld	ra,24(sp)
    80004b92:	6442                	ld	s0,16(sp)
    80004b94:	6105                	addi	sp,sp,32
    80004b96:	8082                	ret

0000000080004b98 <sys_link>:
{
    80004b98:	7169                	addi	sp,sp,-304
    80004b9a:	f606                	sd	ra,296(sp)
    80004b9c:	f222                	sd	s0,288(sp)
    80004b9e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ba0:	08000613          	li	a2,128
    80004ba4:	ed040593          	addi	a1,s0,-304
    80004ba8:	4501                	li	a0,0
    80004baa:	cb3fd0ef          	jal	8000285c <argstr>
    return -1;
    80004bae:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004bb0:	0c054e63          	bltz	a0,80004c8c <sys_link+0xf4>
    80004bb4:	08000613          	li	a2,128
    80004bb8:	f5040593          	addi	a1,s0,-176
    80004bbc:	4505                	li	a0,1
    80004bbe:	c9ffd0ef          	jal	8000285c <argstr>
    return -1;
    80004bc2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004bc4:	0c054463          	bltz	a0,80004c8c <sys_link+0xf4>
    80004bc8:	ee26                	sd	s1,280(sp)
  begin_op();
    80004bca:	f1dfe0ef          	jal	80003ae6 <begin_op>
  if((ip = namei(old)) == 0){
    80004bce:	ed040513          	addi	a0,s0,-304
    80004bd2:	d59fe0ef          	jal	8000392a <namei>
    80004bd6:	84aa                	mv	s1,a0
    80004bd8:	c53d                	beqz	a0,80004c46 <sys_link+0xae>
  ilock(ip);
    80004bda:	e76fe0ef          	jal	80003250 <ilock>
  if(ip->type == T_DIR){
    80004bde:	04449703          	lh	a4,68(s1)
    80004be2:	4785                	li	a5,1
    80004be4:	06f70663          	beq	a4,a5,80004c50 <sys_link+0xb8>
    80004be8:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004bea:	04a4d783          	lhu	a5,74(s1)
    80004bee:	2785                	addiw	a5,a5,1
    80004bf0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004bf4:	8526                	mv	a0,s1
    80004bf6:	da6fe0ef          	jal	8000319c <iupdate>
  iunlock(ip);
    80004bfa:	8526                	mv	a0,s1
    80004bfc:	f02fe0ef          	jal	800032fe <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004c00:	fd040593          	addi	a1,s0,-48
    80004c04:	f5040513          	addi	a0,s0,-176
    80004c08:	d3dfe0ef          	jal	80003944 <nameiparent>
    80004c0c:	892a                	mv	s2,a0
    80004c0e:	cd21                	beqz	a0,80004c66 <sys_link+0xce>
  ilock(dp);
    80004c10:	e40fe0ef          	jal	80003250 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004c14:	00092703          	lw	a4,0(s2)
    80004c18:	409c                	lw	a5,0(s1)
    80004c1a:	04f71363          	bne	a4,a5,80004c60 <sys_link+0xc8>
    80004c1e:	40d0                	lw	a2,4(s1)
    80004c20:	fd040593          	addi	a1,s0,-48
    80004c24:	854a                	mv	a0,s2
    80004c26:	c6bfe0ef          	jal	80003890 <dirlink>
    80004c2a:	02054b63          	bltz	a0,80004c60 <sys_link+0xc8>
  iunlockput(dp);
    80004c2e:	854a                	mv	a0,s2
    80004c30:	82bfe0ef          	jal	8000345a <iunlockput>
  iput(ip);
    80004c34:	8526                	mv	a0,s1
    80004c36:	f9cfe0ef          	jal	800033d2 <iput>
  end_op();
    80004c3a:	f17fe0ef          	jal	80003b50 <end_op>
  return 0;
    80004c3e:	4781                	li	a5,0
    80004c40:	64f2                	ld	s1,280(sp)
    80004c42:	6952                	ld	s2,272(sp)
    80004c44:	a0a1                	j	80004c8c <sys_link+0xf4>
    end_op();
    80004c46:	f0bfe0ef          	jal	80003b50 <end_op>
    return -1;
    80004c4a:	57fd                	li	a5,-1
    80004c4c:	64f2                	ld	s1,280(sp)
    80004c4e:	a83d                	j	80004c8c <sys_link+0xf4>
    iunlockput(ip);
    80004c50:	8526                	mv	a0,s1
    80004c52:	809fe0ef          	jal	8000345a <iunlockput>
    end_op();
    80004c56:	efbfe0ef          	jal	80003b50 <end_op>
    return -1;
    80004c5a:	57fd                	li	a5,-1
    80004c5c:	64f2                	ld	s1,280(sp)
    80004c5e:	a03d                	j	80004c8c <sys_link+0xf4>
    iunlockput(dp);
    80004c60:	854a                	mv	a0,s2
    80004c62:	ff8fe0ef          	jal	8000345a <iunlockput>
  ilock(ip);
    80004c66:	8526                	mv	a0,s1
    80004c68:	de8fe0ef          	jal	80003250 <ilock>
  ip->nlink--;
    80004c6c:	04a4d783          	lhu	a5,74(s1)
    80004c70:	37fd                	addiw	a5,a5,-1
    80004c72:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004c76:	8526                	mv	a0,s1
    80004c78:	d24fe0ef          	jal	8000319c <iupdate>
  iunlockput(ip);
    80004c7c:	8526                	mv	a0,s1
    80004c7e:	fdcfe0ef          	jal	8000345a <iunlockput>
  end_op();
    80004c82:	ecffe0ef          	jal	80003b50 <end_op>
  return -1;
    80004c86:	57fd                	li	a5,-1
    80004c88:	64f2                	ld	s1,280(sp)
    80004c8a:	6952                	ld	s2,272(sp)
}
    80004c8c:	853e                	mv	a0,a5
    80004c8e:	70b2                	ld	ra,296(sp)
    80004c90:	7412                	ld	s0,288(sp)
    80004c92:	6155                	addi	sp,sp,304
    80004c94:	8082                	ret

0000000080004c96 <sys_unlink>:
{
    80004c96:	7151                	addi	sp,sp,-240
    80004c98:	f586                	sd	ra,232(sp)
    80004c9a:	f1a2                	sd	s0,224(sp)
    80004c9c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004c9e:	08000613          	li	a2,128
    80004ca2:	f3040593          	addi	a1,s0,-208
    80004ca6:	4501                	li	a0,0
    80004ca8:	bb5fd0ef          	jal	8000285c <argstr>
    80004cac:	16054063          	bltz	a0,80004e0c <sys_unlink+0x176>
    80004cb0:	eda6                	sd	s1,216(sp)
  begin_op();
    80004cb2:	e35fe0ef          	jal	80003ae6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004cb6:	fb040593          	addi	a1,s0,-80
    80004cba:	f3040513          	addi	a0,s0,-208
    80004cbe:	c87fe0ef          	jal	80003944 <nameiparent>
    80004cc2:	84aa                	mv	s1,a0
    80004cc4:	c945                	beqz	a0,80004d74 <sys_unlink+0xde>
  ilock(dp);
    80004cc6:	d8afe0ef          	jal	80003250 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004cca:	00003597          	auipc	a1,0x3
    80004cce:	a9658593          	addi	a1,a1,-1386 # 80007760 <etext+0x760>
    80004cd2:	fb040513          	addi	a0,s0,-80
    80004cd6:	9d9fe0ef          	jal	800036ae <namecmp>
    80004cda:	10050e63          	beqz	a0,80004df6 <sys_unlink+0x160>
    80004cde:	00003597          	auipc	a1,0x3
    80004ce2:	a8a58593          	addi	a1,a1,-1398 # 80007768 <etext+0x768>
    80004ce6:	fb040513          	addi	a0,s0,-80
    80004cea:	9c5fe0ef          	jal	800036ae <namecmp>
    80004cee:	10050463          	beqz	a0,80004df6 <sys_unlink+0x160>
    80004cf2:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004cf4:	f2c40613          	addi	a2,s0,-212
    80004cf8:	fb040593          	addi	a1,s0,-80
    80004cfc:	8526                	mv	a0,s1
    80004cfe:	9c7fe0ef          	jal	800036c4 <dirlookup>
    80004d02:	892a                	mv	s2,a0
    80004d04:	0e050863          	beqz	a0,80004df4 <sys_unlink+0x15e>
  ilock(ip);
    80004d08:	d48fe0ef          	jal	80003250 <ilock>
  if(ip->nlink < 1)
    80004d0c:	04a91783          	lh	a5,74(s2)
    80004d10:	06f05763          	blez	a5,80004d7e <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004d14:	04491703          	lh	a4,68(s2)
    80004d18:	4785                	li	a5,1
    80004d1a:	06f70963          	beq	a4,a5,80004d8c <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004d1e:	4641                	li	a2,16
    80004d20:	4581                	li	a1,0
    80004d22:	fc040513          	addi	a0,s0,-64
    80004d26:	fa3fb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d2a:	4741                	li	a4,16
    80004d2c:	f2c42683          	lw	a3,-212(s0)
    80004d30:	fc040613          	addi	a2,s0,-64
    80004d34:	4581                	li	a1,0
    80004d36:	8526                	mv	a0,s1
    80004d38:	869fe0ef          	jal	800035a0 <writei>
    80004d3c:	47c1                	li	a5,16
    80004d3e:	08f51b63          	bne	a0,a5,80004dd4 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004d42:	04491703          	lh	a4,68(s2)
    80004d46:	4785                	li	a5,1
    80004d48:	08f70d63          	beq	a4,a5,80004de2 <sys_unlink+0x14c>
  iunlockput(dp);
    80004d4c:	8526                	mv	a0,s1
    80004d4e:	f0cfe0ef          	jal	8000345a <iunlockput>
  ip->nlink--;
    80004d52:	04a95783          	lhu	a5,74(s2)
    80004d56:	37fd                	addiw	a5,a5,-1
    80004d58:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004d5c:	854a                	mv	a0,s2
    80004d5e:	c3efe0ef          	jal	8000319c <iupdate>
  iunlockput(ip);
    80004d62:	854a                	mv	a0,s2
    80004d64:	ef6fe0ef          	jal	8000345a <iunlockput>
  end_op();
    80004d68:	de9fe0ef          	jal	80003b50 <end_op>
  return 0;
    80004d6c:	4501                	li	a0,0
    80004d6e:	64ee                	ld	s1,216(sp)
    80004d70:	694e                	ld	s2,208(sp)
    80004d72:	a849                	j	80004e04 <sys_unlink+0x16e>
    end_op();
    80004d74:	dddfe0ef          	jal	80003b50 <end_op>
    return -1;
    80004d78:	557d                	li	a0,-1
    80004d7a:	64ee                	ld	s1,216(sp)
    80004d7c:	a061                	j	80004e04 <sys_unlink+0x16e>
    80004d7e:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004d80:	00003517          	auipc	a0,0x3
    80004d84:	9f050513          	addi	a0,a0,-1552 # 80007770 <etext+0x770>
    80004d88:	a0dfb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004d8c:	04c92703          	lw	a4,76(s2)
    80004d90:	02000793          	li	a5,32
    80004d94:	f8e7f5e3          	bgeu	a5,a4,80004d1e <sys_unlink+0x88>
    80004d98:	e5ce                	sd	s3,200(sp)
    80004d9a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d9e:	4741                	li	a4,16
    80004da0:	86ce                	mv	a3,s3
    80004da2:	f1840613          	addi	a2,s0,-232
    80004da6:	4581                	li	a1,0
    80004da8:	854a                	mv	a0,s2
    80004daa:	efafe0ef          	jal	800034a4 <readi>
    80004dae:	47c1                	li	a5,16
    80004db0:	00f51c63          	bne	a0,a5,80004dc8 <sys_unlink+0x132>
    if(de.inum != 0)
    80004db4:	f1845783          	lhu	a5,-232(s0)
    80004db8:	efa1                	bnez	a5,80004e10 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004dba:	29c1                	addiw	s3,s3,16
    80004dbc:	04c92783          	lw	a5,76(s2)
    80004dc0:	fcf9efe3          	bltu	s3,a5,80004d9e <sys_unlink+0x108>
    80004dc4:	69ae                	ld	s3,200(sp)
    80004dc6:	bfa1                	j	80004d1e <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004dc8:	00003517          	auipc	a0,0x3
    80004dcc:	9c050513          	addi	a0,a0,-1600 # 80007788 <etext+0x788>
    80004dd0:	9c5fb0ef          	jal	80000794 <panic>
    80004dd4:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004dd6:	00003517          	auipc	a0,0x3
    80004dda:	9ca50513          	addi	a0,a0,-1590 # 800077a0 <etext+0x7a0>
    80004dde:	9b7fb0ef          	jal	80000794 <panic>
    dp->nlink--;
    80004de2:	04a4d783          	lhu	a5,74(s1)
    80004de6:	37fd                	addiw	a5,a5,-1
    80004de8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004dec:	8526                	mv	a0,s1
    80004dee:	baefe0ef          	jal	8000319c <iupdate>
    80004df2:	bfa9                	j	80004d4c <sys_unlink+0xb6>
    80004df4:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004df6:	8526                	mv	a0,s1
    80004df8:	e62fe0ef          	jal	8000345a <iunlockput>
  end_op();
    80004dfc:	d55fe0ef          	jal	80003b50 <end_op>
  return -1;
    80004e00:	557d                	li	a0,-1
    80004e02:	64ee                	ld	s1,216(sp)
}
    80004e04:	70ae                	ld	ra,232(sp)
    80004e06:	740e                	ld	s0,224(sp)
    80004e08:	616d                	addi	sp,sp,240
    80004e0a:	8082                	ret
    return -1;
    80004e0c:	557d                	li	a0,-1
    80004e0e:	bfdd                	j	80004e04 <sys_unlink+0x16e>
    iunlockput(ip);
    80004e10:	854a                	mv	a0,s2
    80004e12:	e48fe0ef          	jal	8000345a <iunlockput>
    goto bad;
    80004e16:	694e                	ld	s2,208(sp)
    80004e18:	69ae                	ld	s3,200(sp)
    80004e1a:	bff1                	j	80004df6 <sys_unlink+0x160>

0000000080004e1c <sys_open>:

uint64
sys_open(void)
{
    80004e1c:	7131                	addi	sp,sp,-192
    80004e1e:	fd06                	sd	ra,184(sp)
    80004e20:	f922                	sd	s0,176(sp)
    80004e22:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004e24:	f4c40593          	addi	a1,s0,-180
    80004e28:	4505                	li	a0,1
    80004e2a:	9fbfd0ef          	jal	80002824 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004e2e:	08000613          	li	a2,128
    80004e32:	f5040593          	addi	a1,s0,-176
    80004e36:	4501                	li	a0,0
    80004e38:	a25fd0ef          	jal	8000285c <argstr>
    80004e3c:	87aa                	mv	a5,a0
    return -1;
    80004e3e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004e40:	0a07c263          	bltz	a5,80004ee4 <sys_open+0xc8>
    80004e44:	f526                	sd	s1,168(sp)

  begin_op();
    80004e46:	ca1fe0ef          	jal	80003ae6 <begin_op>

  if(omode & O_CREATE){
    80004e4a:	f4c42783          	lw	a5,-180(s0)
    80004e4e:	2007f793          	andi	a5,a5,512
    80004e52:	c3d5                	beqz	a5,80004ef6 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004e54:	4681                	li	a3,0
    80004e56:	4601                	li	a2,0
    80004e58:	4589                	li	a1,2
    80004e5a:	f5040513          	addi	a0,s0,-176
    80004e5e:	aa9ff0ef          	jal	80004906 <create>
    80004e62:	84aa                	mv	s1,a0
    if(ip == 0){
    80004e64:	c541                	beqz	a0,80004eec <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004e66:	04449703          	lh	a4,68(s1)
    80004e6a:	478d                	li	a5,3
    80004e6c:	00f71763          	bne	a4,a5,80004e7a <sys_open+0x5e>
    80004e70:	0464d703          	lhu	a4,70(s1)
    80004e74:	47a5                	li	a5,9
    80004e76:	0ae7ed63          	bltu	a5,a4,80004f30 <sys_open+0x114>
    80004e7a:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004e7c:	fe1fe0ef          	jal	80003e5c <filealloc>
    80004e80:	892a                	mv	s2,a0
    80004e82:	c179                	beqz	a0,80004f48 <sys_open+0x12c>
    80004e84:	ed4e                	sd	s3,152(sp)
    80004e86:	a43ff0ef          	jal	800048c8 <fdalloc>
    80004e8a:	89aa                	mv	s3,a0
    80004e8c:	0a054a63          	bltz	a0,80004f40 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004e90:	04449703          	lh	a4,68(s1)
    80004e94:	478d                	li	a5,3
    80004e96:	0cf70263          	beq	a4,a5,80004f5a <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004e9a:	4789                	li	a5,2
    80004e9c:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004ea0:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004ea4:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004ea8:	f4c42783          	lw	a5,-180(s0)
    80004eac:	0017c713          	xori	a4,a5,1
    80004eb0:	8b05                	andi	a4,a4,1
    80004eb2:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004eb6:	0037f713          	andi	a4,a5,3
    80004eba:	00e03733          	snez	a4,a4
    80004ebe:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004ec2:	4007f793          	andi	a5,a5,1024
    80004ec6:	c791                	beqz	a5,80004ed2 <sys_open+0xb6>
    80004ec8:	04449703          	lh	a4,68(s1)
    80004ecc:	4789                	li	a5,2
    80004ece:	08f70d63          	beq	a4,a5,80004f68 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004ed2:	8526                	mv	a0,s1
    80004ed4:	c2afe0ef          	jal	800032fe <iunlock>
  end_op();
    80004ed8:	c79fe0ef          	jal	80003b50 <end_op>

  return fd;
    80004edc:	854e                	mv	a0,s3
    80004ede:	74aa                	ld	s1,168(sp)
    80004ee0:	790a                	ld	s2,160(sp)
    80004ee2:	69ea                	ld	s3,152(sp)
}
    80004ee4:	70ea                	ld	ra,184(sp)
    80004ee6:	744a                	ld	s0,176(sp)
    80004ee8:	6129                	addi	sp,sp,192
    80004eea:	8082                	ret
      end_op();
    80004eec:	c65fe0ef          	jal	80003b50 <end_op>
      return -1;
    80004ef0:	557d                	li	a0,-1
    80004ef2:	74aa                	ld	s1,168(sp)
    80004ef4:	bfc5                	j	80004ee4 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80004ef6:	f5040513          	addi	a0,s0,-176
    80004efa:	a31fe0ef          	jal	8000392a <namei>
    80004efe:	84aa                	mv	s1,a0
    80004f00:	c11d                	beqz	a0,80004f26 <sys_open+0x10a>
    ilock(ip);
    80004f02:	b4efe0ef          	jal	80003250 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004f06:	04449703          	lh	a4,68(s1)
    80004f0a:	4785                	li	a5,1
    80004f0c:	f4f71de3          	bne	a4,a5,80004e66 <sys_open+0x4a>
    80004f10:	f4c42783          	lw	a5,-180(s0)
    80004f14:	d3bd                	beqz	a5,80004e7a <sys_open+0x5e>
      iunlockput(ip);
    80004f16:	8526                	mv	a0,s1
    80004f18:	d42fe0ef          	jal	8000345a <iunlockput>
      end_op();
    80004f1c:	c35fe0ef          	jal	80003b50 <end_op>
      return -1;
    80004f20:	557d                	li	a0,-1
    80004f22:	74aa                	ld	s1,168(sp)
    80004f24:	b7c1                	j	80004ee4 <sys_open+0xc8>
      end_op();
    80004f26:	c2bfe0ef          	jal	80003b50 <end_op>
      return -1;
    80004f2a:	557d                	li	a0,-1
    80004f2c:	74aa                	ld	s1,168(sp)
    80004f2e:	bf5d                	j	80004ee4 <sys_open+0xc8>
    iunlockput(ip);
    80004f30:	8526                	mv	a0,s1
    80004f32:	d28fe0ef          	jal	8000345a <iunlockput>
    end_op();
    80004f36:	c1bfe0ef          	jal	80003b50 <end_op>
    return -1;
    80004f3a:	557d                	li	a0,-1
    80004f3c:	74aa                	ld	s1,168(sp)
    80004f3e:	b75d                	j	80004ee4 <sys_open+0xc8>
      fileclose(f);
    80004f40:	854a                	mv	a0,s2
    80004f42:	fbffe0ef          	jal	80003f00 <fileclose>
    80004f46:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80004f48:	8526                	mv	a0,s1
    80004f4a:	d10fe0ef          	jal	8000345a <iunlockput>
    end_op();
    80004f4e:	c03fe0ef          	jal	80003b50 <end_op>
    return -1;
    80004f52:	557d                	li	a0,-1
    80004f54:	74aa                	ld	s1,168(sp)
    80004f56:	790a                	ld	s2,160(sp)
    80004f58:	b771                	j	80004ee4 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80004f5a:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80004f5e:	04649783          	lh	a5,70(s1)
    80004f62:	02f91223          	sh	a5,36(s2)
    80004f66:	bf3d                	j	80004ea4 <sys_open+0x88>
    itrunc(ip);
    80004f68:	8526                	mv	a0,s1
    80004f6a:	bd4fe0ef          	jal	8000333e <itrunc>
    80004f6e:	b795                	j	80004ed2 <sys_open+0xb6>

0000000080004f70 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004f70:	7175                	addi	sp,sp,-144
    80004f72:	e506                	sd	ra,136(sp)
    80004f74:	e122                	sd	s0,128(sp)
    80004f76:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004f78:	b6ffe0ef          	jal	80003ae6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004f7c:	08000613          	li	a2,128
    80004f80:	f7040593          	addi	a1,s0,-144
    80004f84:	4501                	li	a0,0
    80004f86:	8d7fd0ef          	jal	8000285c <argstr>
    80004f8a:	02054363          	bltz	a0,80004fb0 <sys_mkdir+0x40>
    80004f8e:	4681                	li	a3,0
    80004f90:	4601                	li	a2,0
    80004f92:	4585                	li	a1,1
    80004f94:	f7040513          	addi	a0,s0,-144
    80004f98:	96fff0ef          	jal	80004906 <create>
    80004f9c:	c911                	beqz	a0,80004fb0 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004f9e:	cbcfe0ef          	jal	8000345a <iunlockput>
  end_op();
    80004fa2:	baffe0ef          	jal	80003b50 <end_op>
  return 0;
    80004fa6:	4501                	li	a0,0
}
    80004fa8:	60aa                	ld	ra,136(sp)
    80004faa:	640a                	ld	s0,128(sp)
    80004fac:	6149                	addi	sp,sp,144
    80004fae:	8082                	ret
    end_op();
    80004fb0:	ba1fe0ef          	jal	80003b50 <end_op>
    return -1;
    80004fb4:	557d                	li	a0,-1
    80004fb6:	bfcd                	j	80004fa8 <sys_mkdir+0x38>

0000000080004fb8 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004fb8:	7135                	addi	sp,sp,-160
    80004fba:	ed06                	sd	ra,152(sp)
    80004fbc:	e922                	sd	s0,144(sp)
    80004fbe:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004fc0:	b27fe0ef          	jal	80003ae6 <begin_op>
  argint(1, &major);
    80004fc4:	f6c40593          	addi	a1,s0,-148
    80004fc8:	4505                	li	a0,1
    80004fca:	85bfd0ef          	jal	80002824 <argint>
  argint(2, &minor);
    80004fce:	f6840593          	addi	a1,s0,-152
    80004fd2:	4509                	li	a0,2
    80004fd4:	851fd0ef          	jal	80002824 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004fd8:	08000613          	li	a2,128
    80004fdc:	f7040593          	addi	a1,s0,-144
    80004fe0:	4501                	li	a0,0
    80004fe2:	87bfd0ef          	jal	8000285c <argstr>
    80004fe6:	02054563          	bltz	a0,80005010 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004fea:	f6841683          	lh	a3,-152(s0)
    80004fee:	f6c41603          	lh	a2,-148(s0)
    80004ff2:	458d                	li	a1,3
    80004ff4:	f7040513          	addi	a0,s0,-144
    80004ff8:	90fff0ef          	jal	80004906 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004ffc:	c911                	beqz	a0,80005010 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004ffe:	c5cfe0ef          	jal	8000345a <iunlockput>
  end_op();
    80005002:	b4ffe0ef          	jal	80003b50 <end_op>
  return 0;
    80005006:	4501                	li	a0,0
}
    80005008:	60ea                	ld	ra,152(sp)
    8000500a:	644a                	ld	s0,144(sp)
    8000500c:	610d                	addi	sp,sp,160
    8000500e:	8082                	ret
    end_op();
    80005010:	b41fe0ef          	jal	80003b50 <end_op>
    return -1;
    80005014:	557d                	li	a0,-1
    80005016:	bfcd                	j	80005008 <sys_mknod+0x50>

0000000080005018 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005018:	7135                	addi	sp,sp,-160
    8000501a:	ed06                	sd	ra,152(sp)
    8000501c:	e922                	sd	s0,144(sp)
    8000501e:	e14a                	sd	s2,128(sp)
    80005020:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005022:	94ffc0ef          	jal	80001970 <myproc>
    80005026:	892a                	mv	s2,a0
  
  begin_op();
    80005028:	abffe0ef          	jal	80003ae6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000502c:	08000613          	li	a2,128
    80005030:	f6040593          	addi	a1,s0,-160
    80005034:	4501                	li	a0,0
    80005036:	827fd0ef          	jal	8000285c <argstr>
    8000503a:	04054363          	bltz	a0,80005080 <sys_chdir+0x68>
    8000503e:	e526                	sd	s1,136(sp)
    80005040:	f6040513          	addi	a0,s0,-160
    80005044:	8e7fe0ef          	jal	8000392a <namei>
    80005048:	84aa                	mv	s1,a0
    8000504a:	c915                	beqz	a0,8000507e <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000504c:	a04fe0ef          	jal	80003250 <ilock>
  if(ip->type != T_DIR){
    80005050:	04449703          	lh	a4,68(s1)
    80005054:	4785                	li	a5,1
    80005056:	02f71963          	bne	a4,a5,80005088 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000505a:	8526                	mv	a0,s1
    8000505c:	aa2fe0ef          	jal	800032fe <iunlock>
  iput(p->cwd);
    80005060:	15093503          	ld	a0,336(s2)
    80005064:	b6efe0ef          	jal	800033d2 <iput>
  end_op();
    80005068:	ae9fe0ef          	jal	80003b50 <end_op>
  p->cwd = ip;
    8000506c:	14993823          	sd	s1,336(s2)
  return 0;
    80005070:	4501                	li	a0,0
    80005072:	64aa                	ld	s1,136(sp)
}
    80005074:	60ea                	ld	ra,152(sp)
    80005076:	644a                	ld	s0,144(sp)
    80005078:	690a                	ld	s2,128(sp)
    8000507a:	610d                	addi	sp,sp,160
    8000507c:	8082                	ret
    8000507e:	64aa                	ld	s1,136(sp)
    end_op();
    80005080:	ad1fe0ef          	jal	80003b50 <end_op>
    return -1;
    80005084:	557d                	li	a0,-1
    80005086:	b7fd                	j	80005074 <sys_chdir+0x5c>
    iunlockput(ip);
    80005088:	8526                	mv	a0,s1
    8000508a:	bd0fe0ef          	jal	8000345a <iunlockput>
    end_op();
    8000508e:	ac3fe0ef          	jal	80003b50 <end_op>
    return -1;
    80005092:	557d                	li	a0,-1
    80005094:	64aa                	ld	s1,136(sp)
    80005096:	bff9                	j	80005074 <sys_chdir+0x5c>

0000000080005098 <sys_exec>:

uint64
sys_exec(void)
{
    80005098:	7121                	addi	sp,sp,-448
    8000509a:	ff06                	sd	ra,440(sp)
    8000509c:	fb22                	sd	s0,432(sp)
    8000509e:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800050a0:	e4840593          	addi	a1,s0,-440
    800050a4:	4505                	li	a0,1
    800050a6:	f9afd0ef          	jal	80002840 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800050aa:	08000613          	li	a2,128
    800050ae:	f5040593          	addi	a1,s0,-176
    800050b2:	4501                	li	a0,0
    800050b4:	fa8fd0ef          	jal	8000285c <argstr>
    800050b8:	87aa                	mv	a5,a0
    return -1;
    800050ba:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800050bc:	0c07c463          	bltz	a5,80005184 <sys_exec+0xec>
    800050c0:	f726                	sd	s1,424(sp)
    800050c2:	f34a                	sd	s2,416(sp)
    800050c4:	ef4e                	sd	s3,408(sp)
    800050c6:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800050c8:	10000613          	li	a2,256
    800050cc:	4581                	li	a1,0
    800050ce:	e5040513          	addi	a0,s0,-432
    800050d2:	bf7fb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800050d6:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800050da:	89a6                	mv	s3,s1
    800050dc:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800050de:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800050e2:	00391513          	slli	a0,s2,0x3
    800050e6:	e4040593          	addi	a1,s0,-448
    800050ea:	e4843783          	ld	a5,-440(s0)
    800050ee:	953e                	add	a0,a0,a5
    800050f0:	eaafd0ef          	jal	8000279a <fetchaddr>
    800050f4:	02054663          	bltz	a0,80005120 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800050f8:	e4043783          	ld	a5,-448(s0)
    800050fc:	c3a9                	beqz	a5,8000513e <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800050fe:	a27fb0ef          	jal	80000b24 <kalloc>
    80005102:	85aa                	mv	a1,a0
    80005104:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005108:	cd01                	beqz	a0,80005120 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000510a:	6605                	lui	a2,0x1
    8000510c:	e4043503          	ld	a0,-448(s0)
    80005110:	ed4fd0ef          	jal	800027e4 <fetchstr>
    80005114:	00054663          	bltz	a0,80005120 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005118:	0905                	addi	s2,s2,1
    8000511a:	09a1                	addi	s3,s3,8
    8000511c:	fd4913e3          	bne	s2,s4,800050e2 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005120:	f5040913          	addi	s2,s0,-176
    80005124:	6088                	ld	a0,0(s1)
    80005126:	c931                	beqz	a0,8000517a <sys_exec+0xe2>
    kfree(argv[i]);
    80005128:	91bfb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000512c:	04a1                	addi	s1,s1,8
    8000512e:	ff249be3          	bne	s1,s2,80005124 <sys_exec+0x8c>
  return -1;
    80005132:	557d                	li	a0,-1
    80005134:	74ba                	ld	s1,424(sp)
    80005136:	791a                	ld	s2,416(sp)
    80005138:	69fa                	ld	s3,408(sp)
    8000513a:	6a5a                	ld	s4,400(sp)
    8000513c:	a0a1                	j	80005184 <sys_exec+0xec>
      argv[i] = 0;
    8000513e:	0009079b          	sext.w	a5,s2
    80005142:	078e                	slli	a5,a5,0x3
    80005144:	fd078793          	addi	a5,a5,-48
    80005148:	97a2                	add	a5,a5,s0
    8000514a:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    8000514e:	e5040593          	addi	a1,s0,-432
    80005152:	f5040513          	addi	a0,s0,-176
    80005156:	ba8ff0ef          	jal	800044fe <exec>
    8000515a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000515c:	f5040993          	addi	s3,s0,-176
    80005160:	6088                	ld	a0,0(s1)
    80005162:	c511                	beqz	a0,8000516e <sys_exec+0xd6>
    kfree(argv[i]);
    80005164:	8dffb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005168:	04a1                	addi	s1,s1,8
    8000516a:	ff349be3          	bne	s1,s3,80005160 <sys_exec+0xc8>
  return ret;
    8000516e:	854a                	mv	a0,s2
    80005170:	74ba                	ld	s1,424(sp)
    80005172:	791a                	ld	s2,416(sp)
    80005174:	69fa                	ld	s3,408(sp)
    80005176:	6a5a                	ld	s4,400(sp)
    80005178:	a031                	j	80005184 <sys_exec+0xec>
  return -1;
    8000517a:	557d                	li	a0,-1
    8000517c:	74ba                	ld	s1,424(sp)
    8000517e:	791a                	ld	s2,416(sp)
    80005180:	69fa                	ld	s3,408(sp)
    80005182:	6a5a                	ld	s4,400(sp)
}
    80005184:	70fa                	ld	ra,440(sp)
    80005186:	745a                	ld	s0,432(sp)
    80005188:	6139                	addi	sp,sp,448
    8000518a:	8082                	ret

000000008000518c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000518c:	7139                	addi	sp,sp,-64
    8000518e:	fc06                	sd	ra,56(sp)
    80005190:	f822                	sd	s0,48(sp)
    80005192:	f426                	sd	s1,40(sp)
    80005194:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005196:	fdafc0ef          	jal	80001970 <myproc>
    8000519a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000519c:	fd840593          	addi	a1,s0,-40
    800051a0:	4501                	li	a0,0
    800051a2:	e9efd0ef          	jal	80002840 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800051a6:	fc840593          	addi	a1,s0,-56
    800051aa:	fd040513          	addi	a0,s0,-48
    800051ae:	85cff0ef          	jal	8000420a <pipealloc>
    return -1;
    800051b2:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800051b4:	0a054463          	bltz	a0,8000525c <sys_pipe+0xd0>
  fd0 = -1;
    800051b8:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800051bc:	fd043503          	ld	a0,-48(s0)
    800051c0:	f08ff0ef          	jal	800048c8 <fdalloc>
    800051c4:	fca42223          	sw	a0,-60(s0)
    800051c8:	08054163          	bltz	a0,8000524a <sys_pipe+0xbe>
    800051cc:	fc843503          	ld	a0,-56(s0)
    800051d0:	ef8ff0ef          	jal	800048c8 <fdalloc>
    800051d4:	fca42023          	sw	a0,-64(s0)
    800051d8:	06054063          	bltz	a0,80005238 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800051dc:	4691                	li	a3,4
    800051de:	fc440613          	addi	a2,s0,-60
    800051e2:	fd843583          	ld	a1,-40(s0)
    800051e6:	68a8                	ld	a0,80(s1)
    800051e8:	bfafc0ef          	jal	800015e2 <copyout>
    800051ec:	00054e63          	bltz	a0,80005208 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800051f0:	4691                	li	a3,4
    800051f2:	fc040613          	addi	a2,s0,-64
    800051f6:	fd843583          	ld	a1,-40(s0)
    800051fa:	0591                	addi	a1,a1,4
    800051fc:	68a8                	ld	a0,80(s1)
    800051fe:	be4fc0ef          	jal	800015e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005202:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005204:	04055c63          	bgez	a0,8000525c <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005208:	fc442783          	lw	a5,-60(s0)
    8000520c:	07e9                	addi	a5,a5,26
    8000520e:	078e                	slli	a5,a5,0x3
    80005210:	97a6                	add	a5,a5,s1
    80005212:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005216:	fc042783          	lw	a5,-64(s0)
    8000521a:	07e9                	addi	a5,a5,26
    8000521c:	078e                	slli	a5,a5,0x3
    8000521e:	94be                	add	s1,s1,a5
    80005220:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005224:	fd043503          	ld	a0,-48(s0)
    80005228:	cd9fe0ef          	jal	80003f00 <fileclose>
    fileclose(wf);
    8000522c:	fc843503          	ld	a0,-56(s0)
    80005230:	cd1fe0ef          	jal	80003f00 <fileclose>
    return -1;
    80005234:	57fd                	li	a5,-1
    80005236:	a01d                	j	8000525c <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005238:	fc442783          	lw	a5,-60(s0)
    8000523c:	0007c763          	bltz	a5,8000524a <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005240:	07e9                	addi	a5,a5,26
    80005242:	078e                	slli	a5,a5,0x3
    80005244:	97a6                	add	a5,a5,s1
    80005246:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000524a:	fd043503          	ld	a0,-48(s0)
    8000524e:	cb3fe0ef          	jal	80003f00 <fileclose>
    fileclose(wf);
    80005252:	fc843503          	ld	a0,-56(s0)
    80005256:	cabfe0ef          	jal	80003f00 <fileclose>
    return -1;
    8000525a:	57fd                	li	a5,-1
}
    8000525c:	853e                	mv	a0,a5
    8000525e:	70e2                	ld	ra,56(sp)
    80005260:	7442                	ld	s0,48(sp)
    80005262:	74a2                	ld	s1,40(sp)
    80005264:	6121                	addi	sp,sp,64
    80005266:	8082                	ret
	...

0000000080005270 <kernelvec>:
    80005270:	7111                	addi	sp,sp,-256
    80005272:	e006                	sd	ra,0(sp)
    80005274:	e40a                	sd	sp,8(sp)
    80005276:	e80e                	sd	gp,16(sp)
    80005278:	ec12                	sd	tp,24(sp)
    8000527a:	f016                	sd	t0,32(sp)
    8000527c:	f41a                	sd	t1,40(sp)
    8000527e:	f81e                	sd	t2,48(sp)
    80005280:	e4aa                	sd	a0,72(sp)
    80005282:	e8ae                	sd	a1,80(sp)
    80005284:	ecb2                	sd	a2,88(sp)
    80005286:	f0b6                	sd	a3,96(sp)
    80005288:	f4ba                	sd	a4,104(sp)
    8000528a:	f8be                	sd	a5,112(sp)
    8000528c:	fcc2                	sd	a6,120(sp)
    8000528e:	e146                	sd	a7,128(sp)
    80005290:	edf2                	sd	t3,216(sp)
    80005292:	f1f6                	sd	t4,224(sp)
    80005294:	f5fa                	sd	t5,232(sp)
    80005296:	f9fe                	sd	t6,240(sp)
    80005298:	c12fd0ef          	jal	800026aa <kerneltrap>
    8000529c:	6082                	ld	ra,0(sp)
    8000529e:	6122                	ld	sp,8(sp)
    800052a0:	61c2                	ld	gp,16(sp)
    800052a2:	7282                	ld	t0,32(sp)
    800052a4:	7322                	ld	t1,40(sp)
    800052a6:	73c2                	ld	t2,48(sp)
    800052a8:	6526                	ld	a0,72(sp)
    800052aa:	65c6                	ld	a1,80(sp)
    800052ac:	6666                	ld	a2,88(sp)
    800052ae:	7686                	ld	a3,96(sp)
    800052b0:	7726                	ld	a4,104(sp)
    800052b2:	77c6                	ld	a5,112(sp)
    800052b4:	7866                	ld	a6,120(sp)
    800052b6:	688a                	ld	a7,128(sp)
    800052b8:	6e6e                	ld	t3,216(sp)
    800052ba:	7e8e                	ld	t4,224(sp)
    800052bc:	7f2e                	ld	t5,232(sp)
    800052be:	7fce                	ld	t6,240(sp)
    800052c0:	6111                	addi	sp,sp,256
    800052c2:	10200073          	sret
	...

00000000800052ce <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800052ce:	1141                	addi	sp,sp,-16
    800052d0:	e422                	sd	s0,8(sp)
    800052d2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800052d4:	0c0007b7          	lui	a5,0xc000
    800052d8:	4705                	li	a4,1
    800052da:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800052dc:	0c0007b7          	lui	a5,0xc000
    800052e0:	c3d8                	sw	a4,4(a5)
}
    800052e2:	6422                	ld	s0,8(sp)
    800052e4:	0141                	addi	sp,sp,16
    800052e6:	8082                	ret

00000000800052e8 <plicinithart>:

void
plicinithart(void)
{
    800052e8:	1141                	addi	sp,sp,-16
    800052ea:	e406                	sd	ra,8(sp)
    800052ec:	e022                	sd	s0,0(sp)
    800052ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800052f0:	e54fc0ef          	jal	80001944 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800052f4:	0085171b          	slliw	a4,a0,0x8
    800052f8:	0c0027b7          	lui	a5,0xc002
    800052fc:	97ba                	add	a5,a5,a4
    800052fe:	40200713          	li	a4,1026
    80005302:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005306:	00d5151b          	slliw	a0,a0,0xd
    8000530a:	0c2017b7          	lui	a5,0xc201
    8000530e:	97aa                	add	a5,a5,a0
    80005310:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005314:	60a2                	ld	ra,8(sp)
    80005316:	6402                	ld	s0,0(sp)
    80005318:	0141                	addi	sp,sp,16
    8000531a:	8082                	ret

000000008000531c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000531c:	1141                	addi	sp,sp,-16
    8000531e:	e406                	sd	ra,8(sp)
    80005320:	e022                	sd	s0,0(sp)
    80005322:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005324:	e20fc0ef          	jal	80001944 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005328:	00d5151b          	slliw	a0,a0,0xd
    8000532c:	0c2017b7          	lui	a5,0xc201
    80005330:	97aa                	add	a5,a5,a0
  return irq;
}
    80005332:	43c8                	lw	a0,4(a5)
    80005334:	60a2                	ld	ra,8(sp)
    80005336:	6402                	ld	s0,0(sp)
    80005338:	0141                	addi	sp,sp,16
    8000533a:	8082                	ret

000000008000533c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000533c:	1101                	addi	sp,sp,-32
    8000533e:	ec06                	sd	ra,24(sp)
    80005340:	e822                	sd	s0,16(sp)
    80005342:	e426                	sd	s1,8(sp)
    80005344:	1000                	addi	s0,sp,32
    80005346:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005348:	dfcfc0ef          	jal	80001944 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000534c:	00d5151b          	slliw	a0,a0,0xd
    80005350:	0c2017b7          	lui	a5,0xc201
    80005354:	97aa                	add	a5,a5,a0
    80005356:	c3c4                	sw	s1,4(a5)
}
    80005358:	60e2                	ld	ra,24(sp)
    8000535a:	6442                	ld	s0,16(sp)
    8000535c:	64a2                	ld	s1,8(sp)
    8000535e:	6105                	addi	sp,sp,32
    80005360:	8082                	ret

0000000080005362 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005362:	1141                	addi	sp,sp,-16
    80005364:	e406                	sd	ra,8(sp)
    80005366:	e022                	sd	s0,0(sp)
    80005368:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000536a:	479d                	li	a5,7
    8000536c:	04a7ca63          	blt	a5,a0,800053c0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005370:	0001c797          	auipc	a5,0x1c
    80005374:	8d078793          	addi	a5,a5,-1840 # 80020c40 <disk>
    80005378:	97aa                	add	a5,a5,a0
    8000537a:	0187c783          	lbu	a5,24(a5)
    8000537e:	e7b9                	bnez	a5,800053cc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005380:	00451693          	slli	a3,a0,0x4
    80005384:	0001c797          	auipc	a5,0x1c
    80005388:	8bc78793          	addi	a5,a5,-1860 # 80020c40 <disk>
    8000538c:	6398                	ld	a4,0(a5)
    8000538e:	9736                	add	a4,a4,a3
    80005390:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005394:	6398                	ld	a4,0(a5)
    80005396:	9736                	add	a4,a4,a3
    80005398:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000539c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800053a0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800053a4:	97aa                	add	a5,a5,a0
    800053a6:	4705                	li	a4,1
    800053a8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800053ac:	0001c517          	auipc	a0,0x1c
    800053b0:	8ac50513          	addi	a0,a0,-1876 # 80020c58 <disk+0x18>
    800053b4:	bd7fc0ef          	jal	80001f8a <wakeup>
}
    800053b8:	60a2                	ld	ra,8(sp)
    800053ba:	6402                	ld	s0,0(sp)
    800053bc:	0141                	addi	sp,sp,16
    800053be:	8082                	ret
    panic("free_desc 1");
    800053c0:	00002517          	auipc	a0,0x2
    800053c4:	3f050513          	addi	a0,a0,1008 # 800077b0 <etext+0x7b0>
    800053c8:	bccfb0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    800053cc:	00002517          	auipc	a0,0x2
    800053d0:	3f450513          	addi	a0,a0,1012 # 800077c0 <etext+0x7c0>
    800053d4:	bc0fb0ef          	jal	80000794 <panic>

00000000800053d8 <virtio_disk_init>:
{
    800053d8:	1101                	addi	sp,sp,-32
    800053da:	ec06                	sd	ra,24(sp)
    800053dc:	e822                	sd	s0,16(sp)
    800053de:	e426                	sd	s1,8(sp)
    800053e0:	e04a                	sd	s2,0(sp)
    800053e2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800053e4:	00002597          	auipc	a1,0x2
    800053e8:	3ec58593          	addi	a1,a1,1004 # 800077d0 <etext+0x7d0>
    800053ec:	0001c517          	auipc	a0,0x1c
    800053f0:	97c50513          	addi	a0,a0,-1668 # 80020d68 <disk+0x128>
    800053f4:	f80fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800053f8:	100017b7          	lui	a5,0x10001
    800053fc:	4398                	lw	a4,0(a5)
    800053fe:	2701                	sext.w	a4,a4
    80005400:	747277b7          	lui	a5,0x74727
    80005404:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005408:	18f71063          	bne	a4,a5,80005588 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000540c:	100017b7          	lui	a5,0x10001
    80005410:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005412:	439c                	lw	a5,0(a5)
    80005414:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005416:	4709                	li	a4,2
    80005418:	16e79863          	bne	a5,a4,80005588 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000541c:	100017b7          	lui	a5,0x10001
    80005420:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005422:	439c                	lw	a5,0(a5)
    80005424:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005426:	16e79163          	bne	a5,a4,80005588 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000542a:	100017b7          	lui	a5,0x10001
    8000542e:	47d8                	lw	a4,12(a5)
    80005430:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005432:	554d47b7          	lui	a5,0x554d4
    80005436:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000543a:	14f71763          	bne	a4,a5,80005588 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000543e:	100017b7          	lui	a5,0x10001
    80005442:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005446:	4705                	li	a4,1
    80005448:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000544a:	470d                	li	a4,3
    8000544c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000544e:	10001737          	lui	a4,0x10001
    80005452:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005454:	c7ffe737          	lui	a4,0xc7ffe
    80005458:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd9df>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000545c:	8ef9                	and	a3,a3,a4
    8000545e:	10001737          	lui	a4,0x10001
    80005462:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005464:	472d                	li	a4,11
    80005466:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005468:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000546c:	439c                	lw	a5,0(a5)
    8000546e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005472:	8ba1                	andi	a5,a5,8
    80005474:	12078063          	beqz	a5,80005594 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005478:	100017b7          	lui	a5,0x10001
    8000547c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005480:	100017b7          	lui	a5,0x10001
    80005484:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005488:	439c                	lw	a5,0(a5)
    8000548a:	2781                	sext.w	a5,a5
    8000548c:	10079a63          	bnez	a5,800055a0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005490:	100017b7          	lui	a5,0x10001
    80005494:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005498:	439c                	lw	a5,0(a5)
    8000549a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000549c:	10078863          	beqz	a5,800055ac <virtio_disk_init+0x1d4>
  if(max < NUM)
    800054a0:	471d                	li	a4,7
    800054a2:	10f77b63          	bgeu	a4,a5,800055b8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    800054a6:	e7efb0ef          	jal	80000b24 <kalloc>
    800054aa:	0001b497          	auipc	s1,0x1b
    800054ae:	79648493          	addi	s1,s1,1942 # 80020c40 <disk>
    800054b2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800054b4:	e70fb0ef          	jal	80000b24 <kalloc>
    800054b8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800054ba:	e6afb0ef          	jal	80000b24 <kalloc>
    800054be:	87aa                	mv	a5,a0
    800054c0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800054c2:	6088                	ld	a0,0(s1)
    800054c4:	10050063          	beqz	a0,800055c4 <virtio_disk_init+0x1ec>
    800054c8:	0001b717          	auipc	a4,0x1b
    800054cc:	78073703          	ld	a4,1920(a4) # 80020c48 <disk+0x8>
    800054d0:	0e070a63          	beqz	a4,800055c4 <virtio_disk_init+0x1ec>
    800054d4:	0e078863          	beqz	a5,800055c4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    800054d8:	6605                	lui	a2,0x1
    800054da:	4581                	li	a1,0
    800054dc:	fecfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    800054e0:	0001b497          	auipc	s1,0x1b
    800054e4:	76048493          	addi	s1,s1,1888 # 80020c40 <disk>
    800054e8:	6605                	lui	a2,0x1
    800054ea:	4581                	li	a1,0
    800054ec:	6488                	ld	a0,8(s1)
    800054ee:	fdafb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    800054f2:	6605                	lui	a2,0x1
    800054f4:	4581                	li	a1,0
    800054f6:	6888                	ld	a0,16(s1)
    800054f8:	fd0fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800054fc:	100017b7          	lui	a5,0x10001
    80005500:	4721                	li	a4,8
    80005502:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005504:	4098                	lw	a4,0(s1)
    80005506:	100017b7          	lui	a5,0x10001
    8000550a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000550e:	40d8                	lw	a4,4(s1)
    80005510:	100017b7          	lui	a5,0x10001
    80005514:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005518:	649c                	ld	a5,8(s1)
    8000551a:	0007869b          	sext.w	a3,a5
    8000551e:	10001737          	lui	a4,0x10001
    80005522:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005526:	9781                	srai	a5,a5,0x20
    80005528:	10001737          	lui	a4,0x10001
    8000552c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005530:	689c                	ld	a5,16(s1)
    80005532:	0007869b          	sext.w	a3,a5
    80005536:	10001737          	lui	a4,0x10001
    8000553a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000553e:	9781                	srai	a5,a5,0x20
    80005540:	10001737          	lui	a4,0x10001
    80005544:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005548:	10001737          	lui	a4,0x10001
    8000554c:	4785                	li	a5,1
    8000554e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005550:	00f48c23          	sb	a5,24(s1)
    80005554:	00f48ca3          	sb	a5,25(s1)
    80005558:	00f48d23          	sb	a5,26(s1)
    8000555c:	00f48da3          	sb	a5,27(s1)
    80005560:	00f48e23          	sb	a5,28(s1)
    80005564:	00f48ea3          	sb	a5,29(s1)
    80005568:	00f48f23          	sb	a5,30(s1)
    8000556c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005570:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005574:	100017b7          	lui	a5,0x10001
    80005578:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000557c:	60e2                	ld	ra,24(sp)
    8000557e:	6442                	ld	s0,16(sp)
    80005580:	64a2                	ld	s1,8(sp)
    80005582:	6902                	ld	s2,0(sp)
    80005584:	6105                	addi	sp,sp,32
    80005586:	8082                	ret
    panic("could not find virtio disk");
    80005588:	00002517          	auipc	a0,0x2
    8000558c:	25850513          	addi	a0,a0,600 # 800077e0 <etext+0x7e0>
    80005590:	a04fb0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005594:	00002517          	auipc	a0,0x2
    80005598:	26c50513          	addi	a0,a0,620 # 80007800 <etext+0x800>
    8000559c:	9f8fb0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    800055a0:	00002517          	auipc	a0,0x2
    800055a4:	28050513          	addi	a0,a0,640 # 80007820 <etext+0x820>
    800055a8:	9ecfb0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    800055ac:	00002517          	auipc	a0,0x2
    800055b0:	29450513          	addi	a0,a0,660 # 80007840 <etext+0x840>
    800055b4:	9e0fb0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    800055b8:	00002517          	auipc	a0,0x2
    800055bc:	2a850513          	addi	a0,a0,680 # 80007860 <etext+0x860>
    800055c0:	9d4fb0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    800055c4:	00002517          	auipc	a0,0x2
    800055c8:	2bc50513          	addi	a0,a0,700 # 80007880 <etext+0x880>
    800055cc:	9c8fb0ef          	jal	80000794 <panic>

00000000800055d0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800055d0:	7159                	addi	sp,sp,-112
    800055d2:	f486                	sd	ra,104(sp)
    800055d4:	f0a2                	sd	s0,96(sp)
    800055d6:	eca6                	sd	s1,88(sp)
    800055d8:	e8ca                	sd	s2,80(sp)
    800055da:	e4ce                	sd	s3,72(sp)
    800055dc:	e0d2                	sd	s4,64(sp)
    800055de:	fc56                	sd	s5,56(sp)
    800055e0:	f85a                	sd	s6,48(sp)
    800055e2:	f45e                	sd	s7,40(sp)
    800055e4:	f062                	sd	s8,32(sp)
    800055e6:	ec66                	sd	s9,24(sp)
    800055e8:	1880                	addi	s0,sp,112
    800055ea:	8a2a                	mv	s4,a0
    800055ec:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800055ee:	00c52c83          	lw	s9,12(a0)
    800055f2:	001c9c9b          	slliw	s9,s9,0x1
    800055f6:	1c82                	slli	s9,s9,0x20
    800055f8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800055fc:	0001b517          	auipc	a0,0x1b
    80005600:	76c50513          	addi	a0,a0,1900 # 80020d68 <disk+0x128>
    80005604:	df0fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    80005608:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000560a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000560c:	0001bb17          	auipc	s6,0x1b
    80005610:	634b0b13          	addi	s6,s6,1588 # 80020c40 <disk>
  for(int i = 0; i < 3; i++){
    80005614:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005616:	0001bc17          	auipc	s8,0x1b
    8000561a:	752c0c13          	addi	s8,s8,1874 # 80020d68 <disk+0x128>
    8000561e:	a8b9                	j	8000567c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005620:	00fb0733          	add	a4,s6,a5
    80005624:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005628:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000562a:	0207c563          	bltz	a5,80005654 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000562e:	2905                	addiw	s2,s2,1
    80005630:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005632:	05590963          	beq	s2,s5,80005684 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005636:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005638:	0001b717          	auipc	a4,0x1b
    8000563c:	60870713          	addi	a4,a4,1544 # 80020c40 <disk>
    80005640:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005642:	01874683          	lbu	a3,24(a4)
    80005646:	fee9                	bnez	a3,80005620 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005648:	2785                	addiw	a5,a5,1
    8000564a:	0705                	addi	a4,a4,1
    8000564c:	fe979be3          	bne	a5,s1,80005642 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005650:	57fd                	li	a5,-1
    80005652:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005654:	01205d63          	blez	s2,8000566e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005658:	f9042503          	lw	a0,-112(s0)
    8000565c:	d07ff0ef          	jal	80005362 <free_desc>
      for(int j = 0; j < i; j++)
    80005660:	4785                	li	a5,1
    80005662:	0127d663          	bge	a5,s2,8000566e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005666:	f9442503          	lw	a0,-108(s0)
    8000566a:	cf9ff0ef          	jal	80005362 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000566e:	85e2                	mv	a1,s8
    80005670:	0001b517          	auipc	a0,0x1b
    80005674:	5e850513          	addi	a0,a0,1512 # 80020c58 <disk+0x18>
    80005678:	8c7fc0ef          	jal	80001f3e <sleep>
  for(int i = 0; i < 3; i++){
    8000567c:	f9040613          	addi	a2,s0,-112
    80005680:	894e                	mv	s2,s3
    80005682:	bf55                	j	80005636 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005684:	f9042503          	lw	a0,-112(s0)
    80005688:	00451693          	slli	a3,a0,0x4

  if(write)
    8000568c:	0001b797          	auipc	a5,0x1b
    80005690:	5b478793          	addi	a5,a5,1460 # 80020c40 <disk>
    80005694:	00a50713          	addi	a4,a0,10
    80005698:	0712                	slli	a4,a4,0x4
    8000569a:	973e                	add	a4,a4,a5
    8000569c:	01703633          	snez	a2,s7
    800056a0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800056a2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800056a6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800056aa:	6398                	ld	a4,0(a5)
    800056ac:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800056ae:	0a868613          	addi	a2,a3,168
    800056b2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800056b4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800056b6:	6390                	ld	a2,0(a5)
    800056b8:	00d605b3          	add	a1,a2,a3
    800056bc:	4741                	li	a4,16
    800056be:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800056c0:	4805                	li	a6,1
    800056c2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800056c6:	f9442703          	lw	a4,-108(s0)
    800056ca:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800056ce:	0712                	slli	a4,a4,0x4
    800056d0:	963a                	add	a2,a2,a4
    800056d2:	058a0593          	addi	a1,s4,88
    800056d6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800056d8:	0007b883          	ld	a7,0(a5)
    800056dc:	9746                	add	a4,a4,a7
    800056de:	40000613          	li	a2,1024
    800056e2:	c710                	sw	a2,8(a4)
  if(write)
    800056e4:	001bb613          	seqz	a2,s7
    800056e8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800056ec:	00166613          	ori	a2,a2,1
    800056f0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800056f4:	f9842583          	lw	a1,-104(s0)
    800056f8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800056fc:	00250613          	addi	a2,a0,2
    80005700:	0612                	slli	a2,a2,0x4
    80005702:	963e                	add	a2,a2,a5
    80005704:	577d                	li	a4,-1
    80005706:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000570a:	0592                	slli	a1,a1,0x4
    8000570c:	98ae                	add	a7,a7,a1
    8000570e:	03068713          	addi	a4,a3,48
    80005712:	973e                	add	a4,a4,a5
    80005714:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005718:	6398                	ld	a4,0(a5)
    8000571a:	972e                	add	a4,a4,a1
    8000571c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005720:	4689                	li	a3,2
    80005722:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005726:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000572a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000572e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005732:	6794                	ld	a3,8(a5)
    80005734:	0026d703          	lhu	a4,2(a3)
    80005738:	8b1d                	andi	a4,a4,7
    8000573a:	0706                	slli	a4,a4,0x1
    8000573c:	96ba                	add	a3,a3,a4
    8000573e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005742:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005746:	6798                	ld	a4,8(a5)
    80005748:	00275783          	lhu	a5,2(a4)
    8000574c:	2785                	addiw	a5,a5,1
    8000574e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005752:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005756:	100017b7          	lui	a5,0x10001
    8000575a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000575e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005762:	0001b917          	auipc	s2,0x1b
    80005766:	60690913          	addi	s2,s2,1542 # 80020d68 <disk+0x128>
  while(b->disk == 1) {
    8000576a:	4485                	li	s1,1
    8000576c:	01079a63          	bne	a5,a6,80005780 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005770:	85ca                	mv	a1,s2
    80005772:	8552                	mv	a0,s4
    80005774:	fcafc0ef          	jal	80001f3e <sleep>
  while(b->disk == 1) {
    80005778:	004a2783          	lw	a5,4(s4)
    8000577c:	fe978ae3          	beq	a5,s1,80005770 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005780:	f9042903          	lw	s2,-112(s0)
    80005784:	00290713          	addi	a4,s2,2
    80005788:	0712                	slli	a4,a4,0x4
    8000578a:	0001b797          	auipc	a5,0x1b
    8000578e:	4b678793          	addi	a5,a5,1206 # 80020c40 <disk>
    80005792:	97ba                	add	a5,a5,a4
    80005794:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005798:	0001b997          	auipc	s3,0x1b
    8000579c:	4a898993          	addi	s3,s3,1192 # 80020c40 <disk>
    800057a0:	00491713          	slli	a4,s2,0x4
    800057a4:	0009b783          	ld	a5,0(s3)
    800057a8:	97ba                	add	a5,a5,a4
    800057aa:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800057ae:	854a                	mv	a0,s2
    800057b0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800057b4:	bafff0ef          	jal	80005362 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800057b8:	8885                	andi	s1,s1,1
    800057ba:	f0fd                	bnez	s1,800057a0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800057bc:	0001b517          	auipc	a0,0x1b
    800057c0:	5ac50513          	addi	a0,a0,1452 # 80020d68 <disk+0x128>
    800057c4:	cc8fb0ef          	jal	80000c8c <release>
}
    800057c8:	70a6                	ld	ra,104(sp)
    800057ca:	7406                	ld	s0,96(sp)
    800057cc:	64e6                	ld	s1,88(sp)
    800057ce:	6946                	ld	s2,80(sp)
    800057d0:	69a6                	ld	s3,72(sp)
    800057d2:	6a06                	ld	s4,64(sp)
    800057d4:	7ae2                	ld	s5,56(sp)
    800057d6:	7b42                	ld	s6,48(sp)
    800057d8:	7ba2                	ld	s7,40(sp)
    800057da:	7c02                	ld	s8,32(sp)
    800057dc:	6ce2                	ld	s9,24(sp)
    800057de:	6165                	addi	sp,sp,112
    800057e0:	8082                	ret

00000000800057e2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800057e2:	1101                	addi	sp,sp,-32
    800057e4:	ec06                	sd	ra,24(sp)
    800057e6:	e822                	sd	s0,16(sp)
    800057e8:	e426                	sd	s1,8(sp)
    800057ea:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800057ec:	0001b497          	auipc	s1,0x1b
    800057f0:	45448493          	addi	s1,s1,1108 # 80020c40 <disk>
    800057f4:	0001b517          	auipc	a0,0x1b
    800057f8:	57450513          	addi	a0,a0,1396 # 80020d68 <disk+0x128>
    800057fc:	bf8fb0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005800:	100017b7          	lui	a5,0x10001
    80005804:	53b8                	lw	a4,96(a5)
    80005806:	8b0d                	andi	a4,a4,3
    80005808:	100017b7          	lui	a5,0x10001
    8000580c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000580e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005812:	689c                	ld	a5,16(s1)
    80005814:	0204d703          	lhu	a4,32(s1)
    80005818:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000581c:	04f70663          	beq	a4,a5,80005868 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005820:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005824:	6898                	ld	a4,16(s1)
    80005826:	0204d783          	lhu	a5,32(s1)
    8000582a:	8b9d                	andi	a5,a5,7
    8000582c:	078e                	slli	a5,a5,0x3
    8000582e:	97ba                	add	a5,a5,a4
    80005830:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005832:	00278713          	addi	a4,a5,2
    80005836:	0712                	slli	a4,a4,0x4
    80005838:	9726                	add	a4,a4,s1
    8000583a:	01074703          	lbu	a4,16(a4)
    8000583e:	e321                	bnez	a4,8000587e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005840:	0789                	addi	a5,a5,2
    80005842:	0792                	slli	a5,a5,0x4
    80005844:	97a6                	add	a5,a5,s1
    80005846:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005848:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000584c:	f3efc0ef          	jal	80001f8a <wakeup>

    disk.used_idx += 1;
    80005850:	0204d783          	lhu	a5,32(s1)
    80005854:	2785                	addiw	a5,a5,1
    80005856:	17c2                	slli	a5,a5,0x30
    80005858:	93c1                	srli	a5,a5,0x30
    8000585a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000585e:	6898                	ld	a4,16(s1)
    80005860:	00275703          	lhu	a4,2(a4)
    80005864:	faf71ee3          	bne	a4,a5,80005820 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005868:	0001b517          	auipc	a0,0x1b
    8000586c:	50050513          	addi	a0,a0,1280 # 80020d68 <disk+0x128>
    80005870:	c1cfb0ef          	jal	80000c8c <release>
}
    80005874:	60e2                	ld	ra,24(sp)
    80005876:	6442                	ld	s0,16(sp)
    80005878:	64a2                	ld	s1,8(sp)
    8000587a:	6105                	addi	sp,sp,32
    8000587c:	8082                	ret
      panic("virtio_disk_intr status");
    8000587e:	00002517          	auipc	a0,0x2
    80005882:	01a50513          	addi	a0,a0,26 # 80007898 <etext+0x898>
    80005886:	f0ffa0ef          	jal	80000794 <panic>
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
