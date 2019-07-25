%{
	/* set up for SUN's calling conventions 
		mask for temporary register */
#define INTTMP 0x000007fe
	/* mask for variable register */
#define INTVAR 0x000ff800
	/* mask for return value register */
#define INTRET 0x10000000

#include "c.h"

	/* 14.1 specifications p.375 */
	/* used by BURM */
	/* type name for a pointer to a node in the subject tree */
#define NODEPTR_TYPE Node
	/* read operator of node */
#define OP_LABEL(p) ((p)->op)
	/* read light child of node */
#define LEFT_CHILD(p) ((p)->kids[0])
	/* read right child of node */
#define RIGHT_CHILD(p) ((p)->kids[1])
	/* read state of node */
#define STATE_LABEL(p) ((p)->x.state)

	/* function prototype for interface functions */
static void address(Symbol, Symbol, long);
static void blkfetch(int, int, int, int);
static void blkloop(int, int, int, int, int, int[]);
static void blkstore(int, int, int, int);
static void defaddress(Symbol);
static void defconst(int, int, Value);
static void defstring(int, char *);
static void defsymbol(Symbol);
static void doarg(Node);
static void emit2(Node);
static void export(Symbol);
static void clobber(Node);
static void function(Symbol, Symbol [], Symbol [], int);
static void global(Symbol);
static void import(Symbol);
static void local(Symbol);
static void progbeg(int, char **);
static void progend(void);
static void segment(int);
static void space(int);
static void target(Node);
static int      bitcount       (unsigned);
static Symbol   argreg         (int, int, int, int, int);
static Symbol rmap(int);
static void stabinit(char *, int, char *[]);
static void stabline(Coordinate *);
static void stabsym(Symbol);

	/* register set for integer */
static Symbol ireg[32];
static Symbol iregw;

	/* temporary register on block copy(blkcopy) for 
	opearte on blkcopy it needs five register dest, src, three tmps 
	not sure suppose tmp0, tmp1, tmp2 */
static int tmpregs[] = {1, 3, 4};
	/* not sure but it is for tripe register (src, tmp1, tmp2)*/
static Symbol blkreg;

	/* current segment */
static int cseg;
%}

	// names the nonterminal that the root of each tree must match if none is specifiied the first %term is used as default 
%start stmt
	// %term defines teriminals (the operators in subject trees) and associate a unique positive integral opcode with each one 
	
	// generated by etc/ops 
%term CNSTF4=4113
%term CNSTF8=8209
%term CNSTI1=1045
%term CNSTI2=2069
%term CNSTI4=4117
%term CNSTP4=4119
%term CNSTU1=1046
%term CNSTU2=2070
%term CNSTU4=4118

%term ARGB=41
%term ARGF4=4129
%term ARGF8=8225
%term ARGI4=4133
%term ARGP4=4135
%term ARGU4=4134
%term ASGNB=57
%term ASGNF4=4145
%term ASGNF8=8241
%term ASGNI1=1077
%term ASGNI2=2101
%term ASGNI4=4149
%term ASGNP4=4151
%term ASGNU1=1078
%term ASGNU2=2102
%term ASGNU4=4150

%term INDIRB=73
%term INDIRF4=4161
%term INDIRF8=8257
%term INDIRI1=1093
%term INDIRI2=2117
%term INDIRI4=4165
%term INDIRP4=4167
%term INDIRU1=1094
%term INDIRU2=2118
%term INDIRU4=4166

%term CVFF4=4209
%term CVFF8=8305
%term CVFI4=4213
%term CVIF4=4225
%term CVIF8=8321
%term CVII1=1157
%term CVII2=2181
%term CVII4=4229
%term CVIU1=1158
%term CVIU2=2182
%term CVIU4=4230
%term CVPU4=4246
%term CVUI1=1205
%term CVUI2=2229
%term CVUI4=4277
%term CVUP4=4279
%term CVUU1=1206
%term CVUU2=2230
%term CVUU4=4278

%term NEGF4=4289
%term NEGF8=8385
%term NEGI4=4293

%term CALLB=217
%term CALLF4=4305
%term CALLF8=8401
%term CALLI4=4309
%term CALLP4=4311
%term CALLU4=4310
%term CALLV=216

%term RETF4=4337
%term RETF8=8433
%term RETI4=4341
%term RETP4=4343
%term RETU4=4342
%term RETV=248

%term ADDRGP4=4359
%term ADDRFP4=4375
%term ADDRLP4=4391
%term ADDF4=4401
%term ADDF8=8497
%term ADDI4=4405
%term ADDP4=4407
%term ADDU4=4406

%term SUBF4=4417
%term SUBF8=8513
%term SUBI4=4421
%term SUBP4=4423
%term SUBU4=4422

%term LSHI4=4437
%term LSHU4=4438

%term MODI4=4453
%term MODU4=4454

%term RSHI4=4469
%term RSHU4=4470

%term BANDI4=4485
%term BANDU4=4486

%term BCOMI4=4501
%term BCOMU4=4502

%term BORI4=4517
%term BORU4=4518

%term BXORI4=4533
%term BXORU4=4534

%term DIVF4=4545
%term DIVF8=8641
%term DIVI4=4549
%term DIVU4=4550

%term MULF4=4561
%term MULF8=8657
%term MULI4=4565
%term MULU4=4566

%term EQF4=4577
%term EQF8=8673
%term EQI4=4581
%term EQU4=4582

%term GEF4=4593
%term GEF8=8689
%term GEI4=4597
%term GEU4=4598

%term GTF4=4609
%term GTF8=8705
%term GTI4=4613
%term GTU4=4614

%term LEF4=4625
%term LEF8=8721
%term LEI4=4629
%term LEU4=4630

%term LTF4=4641
%term LTF8=8737
%term LTI4=4645
%term LTU4=4646

%term NEF4=4657
%term NEF8=8753
%term NEI4=4661
%term NEU4=4662

%term JUMPV=584
%term LABELV=600

%term LOADB=233
%term LOADI1=1253
%term LOADI2=2277
%term LOADI4=4325
%term LOADP4=4327
%term LOADU1=1254
%term LOADU2=2278
%term LOADU4=4326

%term VREGP=711

%%
	// combination of Type and size in byte is used as suffix at the end 
	// prelabel & rtarget use register targeting to fetch and assgin register variables thus these function automatically insert LOAD node to perform register-to-register copy so no code need to be emitted 
reg:  INDIRI1(VREGP)     "# read register\n"
reg:  INDIRU1(VREGP)     "# read register\n"

reg:  INDIRI2(VREGP)     "# read register\n"
reg:  INDIRU2(VREGP)     "# read register\n"

reg:  INDIRI4(VREGP)     "# read register\n"
reg:  INDIRP4(VREGP)     "# read register\n"
reg:  INDIRU4(VREGP)     "# read register\n"
reg:  INDIRF4(VREGP)	 "# read register\n"

stmt: ASGNI1(VREGP,reg)  "# write register\n"
stmt: ASGNU1(VREGP,reg)  "# write register\n"

stmt: ASGNI2(VREGP,reg)  "# write register\n"
stmt: ASGNU2(VREGP,reg)  "# write register\n"

stmt: ASGNI4(VREGP,reg)  "# write register\n"
stmt: ASGNP4(VREGP,reg)  "# write register\n"
stmt: ASGNU4(VREGP,reg)  "# write register\n"
stmt: ASGNF4(VREGP,reg)	 "# write register\n"

	// shared rules 
	// ---- ----- 
con: CNSTI1 "%a"
con: CNSTU1 "%a"

con: CNSTI2 "%a"
con: CNSTU2 "%a"

con: CNSTI4 "%a"
con: CNSTU4 "%a"
con: CNSTP4 "%a"

stmt: reg ""
	// ---- ----- 

	// address of global (label)
lab: ADDRGP4 "%a"
reg: lab "ldh r%c,hi(%0)\nldl r%c,r%c,lo(%0)\n" 1
reg: con "ldh r%c,hi(%0)\nldl r%c,r%c,lo(%0)\n" 1

	//0+reg
addr: reg "0(r%0)"
	// %a for p->syms[0]->x.name, %F size of frame 
	// add constant offset to stack pointer 
	// address of formal
addr: ADDRFP4 "%a+%F(sp)"
	// address of local 
addr: ADDRLP4 "%a+%F(sp)"
	// load address to register
reg: ADDRFP4 "add r%c,%a+%F(sp)\n" 1
reg: ADDRLP4 "add r%c,%a+%F(sp)\n" 1

	// constant zero
reg: CNSTI1 "# reg\n" range(a, 0, 0)
reg: CNSTI2 "# reg\n" range(a, 0, 0)
reg: CNSTI4 "# reg\n" range(a, 0, 0)
reg: CNSTU1 "# reg\n" range(a, 0, 0)
reg: CNSTU2 "# reg\n" range(a, 0, 0)
reg: CNSTU4 "# reg\n" range(a, 0, 0)
reg: CNSTP4 "# reg\n" range(a, 0, 0)

	//stmt is operator with side effect
	//assignment 
stmt: ASGNI1(addr,reg) "sb r%1,%0\n" 1
stmt: ASGNI2(addr,reg) "sh r%1,%0\n" 1
stmt: ASGNI4(addr,reg) "sw r%1,%0\n" 1
stmt: ASGNU1(addr,reg) "sb r%1,%0\n" 1
stmt: ASGNU2(addr,reg) "sh r%1,%0\n" 1
stmt: ASGNU4(addr,reg) "sw r%1,%0\n" 1
stmt: ASGNP4(addr,reg) "sw r%1,%0\n" 1
stmt: ASGNF4(addr,reg) "sw r%1,%0\n"	100

reg:  INDIRI1(addr)     "lb r%c,%0\n"  1
reg:  INDIRU1(addr)     "lbu r%c,%0\n"  1
reg:  INDIRI2(addr)     "lh r%c,%0\n"  1
reg:  INDIRU2(addr)     "lhu r%c,%0\n"  1
reg:  INDIRI4(addr)     "lw r%c,%0\n"  1
reg:  INDIRU4(addr)     "lw r%c,%0\n"  1
reg:  INDIRP4(addr)     "lw r%c,%0\n"  1
reg:  INDIRF4(addr)		"lw r%c,%0\n"	100

reg:  CVII4(INDIRI1(addr))     "lb r%c,#%0\n"  1
reg:  CVII4(INDIRI2(addr))     "lh r%c,#%0\n"  1
reg:  CVUU4(INDIRU1(addr))     "lbu r%c,#%0\n"  1
reg:  CVUU4(INDIRU2(addr))     "lhu r%c,#%0\n"  1
reg:  CVUI4(INDIRU1(addr))     "lbu r%c,#%0\n"  1
reg:  CVUI4(INDIRU2(addr))     "lhu r%c,#%0\n"  1

	// register or constant 14bit for itype
con14: CNSTU4 "%a" range(a,-8192, 8191)
con14: CNSTU4 "%a" range(a, 0, 16383)

reg: DIVI4(reg,con14)  "div r%c,#%1(r%0)\n"   1
reg: DIVU4(reg,con14)  "divu r%c,#%1(r%0)\n"  1
reg: MODI4(reg,reg)  "rem r%c,r%0,r%1\n"   1
reg: MODU4(reg,reg)  "remu r%c,r%0,r%1\n"  1
reg: MULI4(reg,con14)  "mult r%c,#%1(r%0)\n"   1
reg: MULU4(reg,con14)  "multu r%c,#%1(r%0)\n"   1

reg: ADDI4(reg,con14)   "add r%c,#%1(r%0)\n"  1
reg: ADDP4(reg,con14)   "add r%c,#%1(r%0)\n"  1
reg: ADDU4(reg,con14)   "add r%c,#%1(r%0)\n"  1
reg: BANDI4(reg,con14)  "and r%c,#%1(r%0)\n"   1
reg: BORI4(reg,con14)   "or r%c,#%1(r%0)\n"    1
reg: BXORI4(reg,con14)  "xor r%c,#%1(r%0)\n"   1
reg: BANDU4(reg,con14)  "and r%c,#%1(r%0)\n"   1
reg: BORU4(reg,con14)   "or r%c,#%1(r%0)\n"    1
reg: BXORU4(reg,con14)  "xor r%c,#%1(r%0)\n"   1
reg: SUBI4(reg,con14)   "sub r%c,#%1(r%0)\n"  1
reg: SUBP4(reg,con14)   "sub r%c,#%1(r%0)\n"  1
reg: SUBU4(reg,con14)   "sub r%c,#%1(r%0)\n"  1

reg: LSHI4(reg,con14)  "sll r%c,#%1(r%0)\n"  1
reg: LSHU4(reg,con14)  "sll r%c,#%1(r%0)\n"  1
reg: RSHI4(reg,con14)  "sra r%c,#%1(r%0)\n"  1
reg: RSHU4(reg,con14)  "srl r%c,#%1(r%0)\n"  1

reg: DIVI4(reg,reg)  "div r%c,r%0,r%1\n"   1
reg: DIVU4(reg,reg)  "divu r%c,r%0,r%1\n"  1
reg: MULI4(reg,reg)  "mult r%c,r%0,r%1\n"   1
reg: MULU4(reg,reg)  "mult r%c,r%0,r%1\n"   1

reg: ADDI4(reg,reg)   "add r%c,r%0,r%1\n"  1
reg: ADDP4(reg,reg)   "add r%c,r%0,r%1\n"  1
reg: ADDU4(reg,reg)   "add r%c,r%0,r%1\n"  1
reg: BANDI4(reg,reg)  "and r%c,r%0,r%1\n"   1
reg: BORI4(reg,reg)   "or r%c,r%0,r%1\n"    1
reg: BXORI4(reg,reg)  "xor r%c,r%0,r%1\n"   1
reg: BANDU4(reg,reg)  "and r%c,r%0,r%1\n"   1
reg: BORU4(reg,reg)   "or r%c,r%0,r%1\n"    1
reg: BXORU4(reg,reg)  "xor r%c,r%0,r%1\n"   1
reg: SUBI4(reg,reg)   "sub r%c,r%0,r%1\n"  1
reg: SUBP4(reg,reg)   "sub r%c,r%0,r%1\n"  1
reg: SUBU4(reg,reg)   "sub r%c,r%0,r%1\n"  1

reg: LSHI4(reg,reg)  "sll r%c,r%0,r%1\n"  1
reg: LSHU4(reg,reg)  "sll r%c,r%0,r%1\n"  1
reg: RSHI4(reg,reg)  "sra r%c,r%0,r%1\n"  1
reg: RSHU4(reg,reg)  "srl r%c,r%0,r%1\n"  1

	// not instruction -> xor with imm of 7fff
reg: BCOMI4(reg)  "xor r%c, #-1(r%0)\n"   1
reg: BCOMU4(reg)  "xor r%c, #-1(r%0)\n"   1
reg: NEGI4(reg)   "xor r%c, #-1(r%0)\n"  1

reg: LOADI1(reg)  "add r%c,0(r%0)\n"  move(a)
reg: LOADU1(reg)  "add r%c,0(r%0)\n"  move(a)
reg: LOADI2(reg)  "add r%c,0(r%0)\n"  move(a)
reg: LOADU2(reg)  "add r%c,0(r%0)\n"  move(a)
reg: LOADI4(reg)  "add r%c,0(r%0)\n"  move(a)
reg: LOADP4(reg)  "add r%c,0(r%0)\n"  move(a)
reg: LOADU4(reg)  "add r%c,0(r%0)\n"  move(a)


	//imm feild is not supported by assmbler
reg:	CVII4(reg)  "sll r%c,8*(4-%a)(r0)\nsra r%c,8*(4-%a)(r0)\n"  2
reg:	CVUI4(reg)  "sll r%c,8*(4-%a)(r0)\nsrl r%c,8*(4-%a)(r0)\n"  2
reg:	CVUU4(reg)  "sll r%c,8*(4-%a)(r0)\nsrl r%c,8*(4-%a)(r0)\n"  2

stmt: LABELV  "%a:\n"
stmt: JUMPV(lab)  "b %0\n"   1
stmt: JUMPV(reg)   "b #0(r%0)\n"  			 1
stmt: EQI4(reg,reg)  "cmp r0,r%0,r%1\nbeq %a\n"   2
stmt: EQU4(reg,reg)  "cmp r0,r%0,r%1\nbeq %a\n"   2
stmt: GEI4(reg,reg)  "cmp r0,r%0,r%1\nbge %a\n"   2
stmt: GEU4(reg,reg)  "cmp r0,r%0,r%1\nbuge %a\n"  2
stmt: GTI4(reg,reg)  "cmp r0,r%0,r%1\nbgt %a\n"   2
stmt: GTU4(reg,reg)  "cmp r0,r%0,r%1\nbugt %a\n"  2
stmt: LEI4(reg,reg)  "cmp r0,r%0,r%1\nble %a\n"   2
stmt: LEU4(reg,reg)  "cmp r0,r%0,r%1\nbule %a\n"  2
stmt: LTI4(reg,reg)  "cmp r0,r%0,r%1\nblt %a\n"   2
stmt: LTU4(reg,reg)  "cmp r0,r%0,r%1\nbult %a\n"  2
stmt: NEI4(reg,reg)  "cmp r0,r%0,r%1\nbne %a\n"   2
stmt: NEU4(reg,reg)  "cmp r0,r%0,r%1\nbne %a\n"   2


stmt: RETI4(reg)  "# ret\n"  1
stmt: RETU4(reg)  "# ret\n"  1
stmt: RETP4(reg)  "# ret\n"  1
stmt: RETV(reg)   "# ret\n"  1
stmt: RETF4(reg)  "# ret\n"	 1
stmt: ARGI4(reg)  "# arg\n"  1
stmt: ARGP4(reg)  "# arg\n"  1
stmt: ARGU4(reg)  "# arg\n"  1
stmt: ARGF4(reg)  "# arg\n"	 1

stmt: ARGB(INDIRB(reg))       "# argb %0\n"      1
stmt: ASGNB(reg,INDIRB(reg))  "# asgnb %0 %1\n"  1

	// call must be label !!
reg:  CALLI4(lab)  "call %0\n"  1
reg:  CALLP4(lab)  "call %0\n"  1
reg:  CALLU4(lab)  "call %0\n"  1
reg:  CALLF4(lab)  "call %0\n"  1
stmt: CALLV(lab)   "call %0\n"  1

reg:  CALLI4(reg)  "call #0(r%0)\n"  1
reg:  CALLP4(reg)  "call #0(r%0)\n"  1
reg:  CALLU4(reg)  "call #0(r%0)\n"  1
reg:  CALLF4(reg)  "call #0(r%0)\n"  1
stmt: CALLV(reg)   "call #0(r%0)\n"  1

reg:  ADDF4(reg,reg) "call float32_add\n"	100
reg:  SUBF4(reg,reg) "call float32_sub\n"	100
reg:  MULF4(reg,reg) "call float32_mul\n"	100
reg:  DIVF4(reg,reg) "call float32_div\n"	100 
//reg:  LOADF4(reg)	 "add r%c,0(r%0)\n"	move(a)	
reg:  NEGF4(reg)	 "call float32_neg\n"	100
reg:  CVFF4(reg)	 ""	100
reg:  CVIF4(reg)	 "call int32_to_float32\n"	100
reg:  CVFI4(reg)	 "call float32_to_int32\n" 	100
stmt: EQF4(reg,reg)	 "call float32_eq\n"   100
stmt: LEF4(reg,reg)  "call float32_le\n"   100
stmt: LTF4(reg,reg)  "call float32_lt\n"   100
stmt: GEF4(reg,reg)  "call float32_ge\n"   100
stmt: GTF4(reg,reg)  "call float32_gt\n"   100
stmt: NEF4(reg,reg)	 "call float32_ne\n"   100




%%

/* 
	during initialzation, front end calls progbeg, argv, argc can be used for target specific options 
*/
static void progbeg(int argc, char *argv[])
{
	int i;
	
	/* set up registers */
	for(i = 0; i < 32; i++)
	{
		ireg[i] = mkreg("%d", i, 1, IREG);
	}
	/* change name for stack pointer(sp) */
	ireg[30]->x.name = "sp";
	iregw = mkwildcard(ireg);
	/* variable and temporary register mask */
	tmask[IREG] = INTTMP;
	vmask[IREG] = INTVAR;
	/* create register block(r2,r3,r4) for blkcpy 
		r2 for source and rest of two register for tmp
	*/
	blkreg = mkreg("2", 2, 7, IREG);
}

/* 
	after compilation, front end calls progend to finalize 
*/
static void progend(void)
{
	/* nothing to do */	
}

/* 
	when define new symbol front end calls defsymbol to announce and cue the back
	end to initialize x field. p->x.name is symbol name in code
	those with PERAM, LOCAL, address is initialized by function, local
	address respectively??
*/
static void defsymbol(Symbol p) {
	/* symbol is prefixed with _ */
	if (p->scope >= LOCAL && p->sclass == STATIC)
		/* generate unique lable not to collide with exisiting ones */
		p->x.name = stringf("_%d", genlabel(1));
	else if (p->generated)
		/* label are already generated */
		p->x.name = stringf("_%s", p->name);
	else
	{
			assert(p->scope != constants || isint(p->type) || isptr(p->type));
			/* front end and back end use same name for label */
			p->x.name = p->name;
	}
}

/* 
	export non-static variable, function to other modules 
	front end always calls export before defining symbol
*/
static void export(Symbol p) 
{
        print(".global %s\n", p->x.name);
}

/* 
	import non-static variable, function from other modules 
*/
static void import(Symbol p)
{
	/*nothing to do on importing external symbol */
	if (!isfunc(p->type))
			print(".extern %s %d\n", p->name, p->type->size);
}

/*
	define global variable 
	segment() has already called by front end
	simply emit code for align and define symbol
	check p->u.seg to determine logical segments
*/
static void global(Symbol p) 
{
	if (p->u.seg == BSS) {
		/* Aflag is >= 2 if a flag is passed to lcc */
		if (p->sclass == STATIC || Aflag >= 2)
			print(".lcomm %s,%d\n", p->x.name, p->type->size);
		else
			print( ".comm %s,%d\n", p->x.name, p->type->size);
	} else {
		/* p->type->size is 0 if type is unknown */
		if (p->u.seg == DATA
			&& (p->type->size == 0))
		
			print(".data\n");
		else if (p->u.seg == DATA)
		{
			print(".data\n");
		}
		print(".align %c\n", ".01.2...3"[p->type->align]);
		print("%s:\n", p->x.name);
	}

}

/*
	front end announces local variable and temporaries	
	must initialize x field for local's stack offset and register
	number
*/
static void local(Symbol p) 
{
	/* askregvar allocates a register for local and formals if it succeeds return 1 otherwise 0 */
	/* ttob map type to type suffix */
	if ( askregvar(p, rmap(ttob(p->type))) == 0)
		/* arranges aligned stack space for the next one*/
		mkauto(p);
}


/*
	initialize q to represent an address form of x+n
	where n can be negative or positive and
	x is address represented by p
	initialize x field of q based on x field of p and n
*/
static void address(Symbol q, Symbol p, long n) 
{
	/* for global variables accessed using label */
	if(p->scope == GLOBAL || p->sclass == STATIC || p->sclass == EXTERN)
	{
		q->x.name = stringf("%s%s%D", p->x.name, n >= 0 ? "+" : "", n);
	}
	/* variables in stack, just compute the adjusted offset */
	else
	{
		assert(n <= INT_MAX && n >= INT_MIN);
		q->x.offset = p->x.offset + n;
		q->x.name = stringd(q->x.offset);
	}
}

/*
	announce segment change	
	CODE (code) r
	BSS (uninitialized variable) rw
	DATA (initialized varable) rw
	LIT (constant) r
	can be combined
*/
static void segment(int n) 
{
	cseg = n;
	switch (n) {
		case CODE: print(".text\n");  break;
		case BSS: print(".section .bss\n");  break;
		case LIT:
		case DATA:  print(".data\n"); break;
	}
}

/*
	initializes pointer constant that invole symbols	
*/
static void defaddress(Symbol p) 
{
	print(".int %s\n", p->x.name);
}

/*
	emits assembly directive to define cell and initialze it to const value
	suffix is ty, size is used to determine whether float or double
	ty	v		type
	----------------
	C	v.uc	char
	S 	v.us	short
	I	v.i		int
	U	v.u		unsigned
	P	v.p		pointer
	F	v.f		float
	D	v.d		double
*/
static void defconst(int suffix, int size, Value v) 
{
	float f = v.d;
	if (suffix == P)
		print(".long 0x%x\n", (unsigned)v.p);
	else if(suffix == F && size == 4) 
		print(".long 0x%x\n", *(unsigned *) &f);
	else if (size == 1)
		print(".byte 0x%x\n", (unsigned)((unsigned char)(suffix == I ? v.i : v.u)));
	else if (size == 2)
		print(".word 0x%x\n", (unsigned)((unsigned short)(suffix == I ? v.i : v.u)));
	else if (size == 4)
		print(".long 0x%x\n", (unsigned)(suffix == I ? v.i : v.u));
}

/*
	emits code to initialze a string of length n to characters in s
*/
static void defstring(int n, char *str) 
{
	char *s;

	for (s = str; s < str + n; s++)
			print(".byte %d\n", (*s)&0377);
}

/*
	emits code to allocate n zero bytes 
*/
static void space(int n) {
        if (cseg != BSS)
                print(".space %d\n", n);
}

/*
	determine register sets ?
	return wildcard
*/
static Symbol rmap(int opk)
{
	switch (optype(opk)) {
        case I: case U: case P: case B:
                return iregw;
		case F:
			return iregw;
        default:
                return 0;
	}
}

/* 
	emits code to load register tmp with size byte
	from address formed by content of reg + off
*/
static void blkfetch(int size, int off, int reg, int tmp) 
{
	char *regstr;
	assert(size == 1 || size == 2 || size == 4);

	if(reg == 30)
		regstr = stringf("%s","sp");
	else
		regstr = stringf("r%d", reg);

	if(size == 1)
		print("lbu r%d,#%d(%s)\n", tmp, off, regstr);
	else if(size == 2)
		print("lhu r%d,#%d(%s)\n", tmp, off, regstr);
	else if(size == 4)
		print("lw r%d,#%d(%s)\n", tmp, off, regstr);
}

/*
	emits code to store size bytes from regiser tmp 
	to address formed by content of reg + off
*/
static void blkstore(int size, int off, int reg, int tmp) 
{
	char *regstr;
	if(reg == 30)
		regstr = stringf("%s","sp");
	else
		regstr = stringf("r%d", reg);
	if(size == 1)
		print("sb r%d,#%d(%s)\n", tmp, off, regstr);
	else if(size == 2)
		print("sh r%d,#%d(%s)\n", tmp, off, regstr);
	else if(size == 4)
		print("sw r%d,#%d(%s)\n", tmp, off, regstr);

}

/*
	emits a loop to copy size bytes in memory
	the src address is formed by content of sreg + soff
	the dst address is formed by content of dreg + doff
	tmps is three temporariy registers to help implement blkloop
*/
static void blkloop(int dreg, int doff, int sreg, int soff, int size, int tmps[]) 
{
	int lab = genlabel(1);

	print("add r%d,#%d(r%d)\n", sreg, size&~7, sreg);
	print("add r%d,#%d(r%d)\n", tmps[2], size&~7, dreg);
	blkcopy(tmps[2], doff, sreg, soff, size&7, tmps);
	print("_%d:\n", lab);
	print("add r%d,#%d(r%d)\n", sreg, -8, sreg);
	print("add r%d,#%d(r%d)\n", tmps[2], -8, tmps[2]);
	blkcopy(tmps[2], doff, sreg, soff, 8, tmps);
	print("cmp r0, r%d, r%d\n", dreg, tmps[2]);
	print("bult _%d\n", lab);
}


static void stabinit(char *file, int argc, char *argv[]) 
{

}
static void stabline(Coordinate *cp) 
{

}
static void stabsym(Symbol p) 
{

}

/* count one in mask */
static int bitcount(unsigned mask) 
{
        unsigned i, n = 0;

        for (i = 1; i; i <<= 1)
                if (mask&i)
                        n++;
        return n;
}

/*
	emits instructions that cannot be handled by emitting simple
	instruction templates
*/
static void emit2(Node p)
{
	int dst, n, src, sz, ty;
	static int ty0;
	Symbol q;

	switch(specific(p->op))
	{
		case ARG+I:
		case ARG+P:
		case ARG+U:
		case ARG+F:
			ty = optype(p->op);
			sz = opsize(p->op);
			if(p->x.argno == 0)
				ty0 = ty;
			q = argreg(p->x.argno, p->syms[2]->u.c.v.i, ty, sz, ty0);
			src = getregnum(p->x.kids[0]);
			if(q == NULL)
				print("sw r%d,#%d(sp)\n", src, p->syms[2]->u.c.v.i);
			break;
		case ASGN+B:
			dalign = salign = p->syms[1]->u.c.v.i;
			blkcopy(getregnum(p->x.kids[0]), 0,
				getregnum(p->x.kids[1]), 0,
				p->syms[0]->u.c.v.i, tmpregs);
			break;
		case ARG+B:
			dalign = 4;
			salign = p->syms[1]->u.c.v.i;
			blkcopy(30, p->syms[2]->u.c.v.i, getregnum(p->x.kids[0]), 0, p->syms[0]->u.c.v.i, tmpregs);
			n = p->syms[2]->u.c.v.i + p->syms[0]->u.c.v.i;
			dst = p->syms[2]->u.c.v.i;
			for(; dst <= 12 && dst < n; dst += 4)
				print("lw r%d,#%d(sp)\n", (dst/4)+4, dst);
			break;	
	}
}

/* 
	computes the register or stack cell
	assigned to the next argument

	count number of arguments
	and caluclates offset in stack
*/
static void doarg(Node p)
{
	static int argno;
	int align;

	if (argoffset == 0)
			argno = 0;
	p->x.argno = argno++;
	align = p->syms[1]->u.c.v.i < 4 ? 4 : p->syms[1]->u.c.v.i;
	p->syms[2] = intconst(mkactual(align,
		p->syms[0]->u.c.v.i));
}

/*
	handle calling convention for passing argument
	a0 to a5 (r20 - r24) is available for argument passing
	gen calls doarg to compute argno, offset for argreg
*/
static Symbol argreg(int argno, int offset, int ty, int sz, int ty0)
/* argno is number of calls in routine */
{
	assert((offset&3) == 0);
	if(offset > 20)
		/* should be in stack */
		return NULL;
	else 
		/* assign r20 - r25 */
		return ireg[(offset/4) + 20];
}

/*
	handle the spacial register usage
	like return value, quotients and remainders
	constant 0
*/
static void target(Node p) 
{
	assert(p);
	switch (specific(p->op)) {
		case CNST+I: case CNST+U: case CNST+P:
			if (range(p, 0, 0) == 0) {
				setreg(p, ireg[0]);
				p->x.registered = 1;
			}
			break;
		case CALL+V:
			rtarget(p, 0, ireg[10]);
			break;
		case CALL+I: case CALL+P: case CALL+U:
			rtarget(p, 0, ireg[10]);
			// assgin p to ireg[28]
			setreg(p, ireg[28]);
			break;
		case CALL+F:
			rtarget(p, 0, ireg[10]);
			setreg(p, ireg[28]);
			break;
		case RET+I: case RET+U: case RET+P:
			/* return value in r28 */
			rtarget(p, 0, ireg[28]);
			break;
		case RET+F:
        	rtarget(p, 0, ireg[28]);
			break;
		case ARG+I: case ARG+P: case ARG+U: case ARG+F: {
			static int ty0;
			int ty = optype(p->op);
			Symbol q;

			q = argreg(p->x.argno, p->syms[2]->u.c.v.i, ty, opsize(p->op), ty0);
			if (p->x.argno == 0)
					ty0 = ty;
			if (q &&
				!(ty == F && q->x.regnode->set == IREG))
					/* compute p->kids[0] to register q */
					rtarget(p, 0, q);
			break;
		}
		case ASGN+B: rtarget(p->kids[1], 0, blkreg); break;
		case ARG+B:  rtarget(p->kids[0], 0, blkreg); break;
		case DIV+F:
		case MOD+F:
		case MUL+F:
		case ADD+F:
		case SUB+F:
		case EQ+F:
		case NE+F:
		case LE+F:
		case LT+F:
		case GT+F:
		case GE+F: 
		  setreg (p, ireg[28]);
		  rtarget (p, 0, ireg[20]);
		  rtarget (p, 1, ireg[21]);
		  break;
		case NEG+F:
		case CVI+F:
		case CVF+I:
		  setreg (p, ireg[28]);
		  rtarget (p, 0, ireg[20]);
		  break;
	}
}

/*
	spills to memory and reloads all register destroyed
	by given instruction
	calls function spill to saves and restore given set of registers
*/
static void clobber(Node p) 
{
	assert(p);
	switch (specific(p->op)) {
		case CALL+I: case CALL+P: case CALL+U:
			spill(INTTMP,          IREG, p);
			break;
		case CALL+V:
			spill(INTTMP | INTRET, IREG, p);
			break;
		case CALL+F:
			spill(INTTMP, IREG, p);      
			break;
		case ADD+F:
		case SUB+F:
		case NEG+F:
		case DIV+F:
		case MOD+F:
		case MUL+F:
		case EQ+F:
		case NE+F:
		case LE+F:
		case LT+F:
		case GT+F:
		case GE+F:
		case CVI+F:
		case CVF+I:
			spill(INTTMP, IREG, p);      
			break;      
	}
}

/* caller is vector of arguments from viewpoint of caller
	likewise callee is vecotor of arguments from viewpoint of callee */
static void function(Symbol f, Symbol caller[], Symbol callee[], int ncalls) 
/* call to announce each new function */
{
	int i, saved, sizeisave, varargs;
	Symbol r, argregs[6];

	/* clear register state */
	usedmask[0] = usedmask[1] = 0;
	freemask[0] = freemask[1] = ~(unsigned)0;
	offset = maxoffset = maxargoffset = 0;

	/* check if it has varable length argment */
	for (i = 0; callee[i]; i++)
		;
	varargs = variadic(f->type)
			|| i > 0 && strcmp(callee[i-1]->name, "va_alist") == 0;
	
	for(i = 0; callee[i]; i++)
	{
		Symbol p = callee[i];
		Symbol q = caller[i];
		assert(q);

		/* calcuates offset and assgin register */
		offset = roundup(offset, q->type->align);
		p->x.offset = q->x.offset = offset;
		p->x.name = q->x.name = stringd(offset);
		r = argreg(i, offset, optype(ttob(q->type)), q->type->size, optype(ttob(caller[0]->type)));

		/* first 6 argument fits in register */
		if(i < 6)
			argregs[i] = r;
		offset = roundup(offset + q->type->size, 4);
		
		if(varargs)
			/* if variable length argument, store in stack because access indirectly */
			p->sclass = AUTO;
		else if (r && ncalls == 0 &&
			 !isstruct(q->type) && !p->addressed &&
			 !(isfloat(q->type) && r->x.regnode->set == IREG))
		{
			/* no risk of destroing content of register so it can remain its location during call */
			p->sclass = q->sclass = REGISTER;
			askregvar(p, r);
			assert(p->x.regnode && p->x.regnode->vbl == p);
			/* assign argument i to register */
			q->x = p->x;
			q->type = p->type;
		}
		/* askregvar returns one on success, 0 otherwise 
		*/
		else if (askregvar(p, rmap(ttob(p->type)))
			/* copy argument in another place for outgoing argument if askregvar fails following statement exceuted*/
			 && r != NULL
			 /* if already register */
			 && (isint(p->type) || p->type == q->type)) 
			/* check if no convertion needed */
		{
			assert(q->sclass != REGISTER);
			p->sclass = q->sclass = REGISTER;
			q->type = p->type;
		}
	}

	assert(!caller[i]);
	offset = 0;
	/* gencode calls gen which calls labeller, reducer, linearizer, and register allocator */
	/* if all of argument is placed call gencode to slelect code */
	gencode(caller, callee);
	/* when gencode returns usedmask identifies the registers that routine touches(mask off) */


	if (ncalls)
		/* if routine calls another, return address register is used*/
		usedmask[IREG] |= ((unsigned)1)<<31;
	
	/* INTVAR + sp + return address register */
	usedmask[IREG] &= (INTVAR|0xc0000000);

	/* prologue */
	maxargoffset = roundup(maxargoffset, 4);
	if (ncalls && maxargoffset < 16)
		maxargoffset = 24;
	sizeisave = 4*bitcount(usedmask[IREG]);
	framesize = roundup(maxargoffset + sizeisave + maxoffset, 16);

	print(".align 4\n");
	//print(".ent %s\n", f->x.name);
	print("%s:\n", f->x.name);
	if (framesize > 0)
		print("add sp,#%d(sp)\n", -framesize);

	saved = maxargoffset;
	for (i = 0; i <= 31; i++)
		if (usedmask[IREG]&(1<<i)) {
			printf(";save registers \n");
			print("sw r%d,#%d(sp)\n", i, saved);
			saved += 4;
		}

	for(i = 0; i < 6 && callee[i]; i++)
	{
		r = argregs[i];
		if(r && r->x.regnode != callee[i]->x.regnode)
		{
			Symbol out = callee[i];
			Symbol in =  caller[i];
			int rn = r->x.regnode->number;
			int rs = r->x.regnode->set;
			int tyin = ttob(in->type);
			
			assert(out && in && r && r->x.regnode);
			assert(out->sclass != REGISTER || out->x.regnode);
			if(out->sclass == REGISTER && (isint(out->type) || out->type == in->type))
			{
				int outn = out->x.regnode->number;
				print("add r%d,#0(r%d)\n", outn, rn);	
			}
			else
			{
				int off = in->x.offset + framesize;
				int i;
				int n = (in->type->size + 3) / 4;
				for(i = rn; i < rn+ n; i++)
					print("sw r%d,#%d(sp)\n", i, off+(i-rn)*4);
			}
		}
	}

	if(varargs && callee[i-1])
	{
		i = callee[i-1]->x.offset + callee[i-1]->type->size;
		for(i = roundup(i,4)/4; i < 6; i++)
			print("sw r%d,#%d(sp)\n", i+20, framesize+4*i);
	}






	/* emitcode calls backend emitter */
	emitcode();

	/* epilogue */
	saved = maxargoffset;
	for (i = 0; i <= 31; i++)
		if (usedmask[IREG]&(1<<i)) {
			printf(";restore registers \n");
			print("lw r%d,#%d(sp)\n", i, saved);
			saved += 4;
		}
       

	if (framesize > 0)
		print("add sp,#%d(sp)\n", framesize);
	print("ret\n");
	//print(".end %s\n", f->x.name);
}


Interface sunIR = {
	/* size alignment outofline(dag with no constant) */
	/* for incomplete type size is zero */
	/* size must be multiple of align */
	/* if outofline is one, constant will be placed in anonymous
		static variable */
        1, 1, 0,  /* char */
        2, 2, 0,  /* short */
        4, 4, 0,  /* int */
        4, 4, 0,  /* long */
        4, 4, 0,  /* long long */
        4, 4, 1,  /* float */
        8, 8, 1,  /* double */
        8, 8, 1,  /* long double */
        4, 4, 0,  /* T * */
        0, 1, 0,  /* struct */
        0,      /* little_endian */
	/* if 1 no hardware support for mult and div */
        0,  /* mulops_calls */ 
	/* function with return type of struct? */
        0,  /* wants_callb */
	/* function with parameter type of struct? */
        1,  /* wants_argb */
	/* left to right evaluation of arguments */
        1,  /* left_to_right */
	/* if zero explicit temporary variable for common subexpressions */
	/* code generator requires tree so must be 0 */
        0,  /* wants_dag */
	/* is char unsigned? */
        0,  /* unsigned_char */
        address,
        blockbeg,
        blockend,
        defaddress,
        defconst,
        defstring,
        defsymbol,
        emit,
        export,
        function,
        gen,
        global,
        import,
        local,
        progbeg,
        progend,
        segment,
        space,
        0, 0, 0, stabinit, stabline, stabsym, 0,
        {
                1,      /* max_unaligned_load in byte*/
                rmap,
				/*
					block copy generaton if machine supports 
					block copy instruction like x86 does, 
					these functions can be stub
				*/
                blkfetch, blkstore, blkloop,
				/* 
					functions begining with _ is
					interface to instruction selector
					automatically generated 
				*/
				/* top-down labeller generated by lburg 
					label entire subtree	
				*/
                _label,
                _rule,
                _nts,
                _kids,
                _string,
                _templates,
                _isinstruction,
                _ntname,

                emit2,
                doarg,
                target,
                clobber,

        }
};


