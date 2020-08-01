{Test program for MPArith: Newton vs. Karatsuba sqrt, (c) W.Ehrhardt 2009}

program t_ksqrt;


{$i STD.INC}
{$i mp_conf.inc}

{$x+}  {pchar I/O}
{$i+}  {RTE on I/O error}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

{$ifndef FPC}
{$N+}
{$endif}


uses BTypes, CRT,
     hrtimer,
     mp_types, mp_base,
     {$ifdef MPC_Diagnostic}
       mp_supp,
     {$endif}
     mp_numth,mp_prng;



{$ifdef BIT16}
const
  imax=50;
{$else}
  {$ifdef MP_32BIT}
  const
    imax=100;
  {$else}
  const
    imax=200;
  {$endif}
{$endif}


var
  a,b,c,d,e: mp_int;
  HR: THRTimer;


{---------------------------------------------------------------------------}
procedure testrange;
  {-Test matching results of recursive Newton and Karatsuba over range of bits}
var
  i,j: integer;
  bs: longint;
begin
  randseed := 12345;
  mp_random_seed1(randseed);
  writeln('Max bitsize: ', longint(5*imax div 4)*16*DIGIT_BIT+3, ' - Press Esc to exit');
  StartTimer(HR);
  for i:= 1 to 5*imax div 4 do begin
    bs := 16*i*DIGIT_BIT;
    write('Bits: ',bs,#13);
    if keypressed and (readkey=#27) then break;
    for j:=0 to 3 do begin
      mp_rand_bits(a,bs+j);
      s_mp_sqrt(a,c);
      mp_sqrt(a,b);
      if mp_is_ne(c,b) then begin
        writeln;
        writeln('Diff for ');
        mp_writeln('a=',a);
        mp_writeln('b=',b);
        mp_writeln('c=',c);
        exit;
      end;
    end;
  end;
  writeln('No differences found, max bitsize: ', mp_bitsize(a));
end;



{---------------------------------------------------------------------------}
procedure CompareRange;
  {-Compare timing recursive Newton vs. Karatsuba with default mp_sqrt_cutoff}
const
  bs: array[1..14] of longint = (20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000, 200000, 300000);
var
  i,j: integer;
  s: longint;
  ot,nt,q: double;
begin
  StartTimer(HR);
  writeln('mp_sqrt_cutoff = ', mp_sqrt_cutoff);
  writeln('bitsize':8,'Standard':12,'Karatsuba':12);
  for i:=1 to 14 do begin
    {$ifdef BIT16}
      if i=12 then break;
    {$endif}
    mp_rand_bits(a, bs[i]);
    RestartTimer(HR);
    for j:=0 to 500000 div bs[i] do s_mp_sqrt(a,c);
    ot := ReadSeconds(HR);
    RestartTimer(HR);
    for j:=0 to 500000 div bs[i] do mp_sqrt(a,b);
    nt := ReadSeconds(HR);
    q  := ot/nt;
    s  := mp_bitsize(a);
    writeln(s:8, ot:12:6, nt:12:6, q:8:2);
    if keypressed and (readkey=#27) then break;
  end;
end;



{---------------------------------------------------------------------------}
procedure CompareRange2;
  {-Compare timing recursive Newton vs. Karatsuba with variable mp_sqrt_cutoff}
const
  bs: array[1..14] of longint = (20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000, 200000, 300000);
var
  i,j,jm,k,ks: word;
  ot,nt: double;
begin
  mp_random_randomize;
  StartTimer(HR);
  writeln('bitsize':8,'Standard':12,'Kara 4':10,'Kara 8':10,'Kara 16':10,'Kara 32':10,'Calls':10);
  for i:=1 to 14 do begin
    {$ifdef BIT16}
      if i=12 then break;
    {$endif}
    mp_rand_bits(a, bs[i]);
    write(mp_bitsize(a):8);
    RestartTimer(HR);
    jm := 800000 div bs[i];
    for j:=0 to jm do s_mp_sqrt(a,c);
    ot := ReadSeconds(HR);
    write(ot:12:3);
    ks := mp_sqrt_cutoff;
    for k:=1 to 4 do begin
      mp_sqrt_cutoff := 2 shl k;
      RestartTimer(HR);
      for j:=0 to jm do mp_sqrt(a,b);
      nt := ReadSeconds(HR);
      write(nt:10:3);
    end;
    mp_sqrt_cutoff := ks;
    writeln(succ(jm):10);
    if keypressed and (readkey=#27) then break;
  end;
end;



{---------------------------------------------------------------------------}
procedure testmersenne;
var
  m: longint;
begin
  writeln('Checking results for Mersenne numbers - Press Esc to exit');
  for m:=1 to MaxMersenne do begin
    mp_mersenne(m,a);
    s_mp_sqrt(a,c);
    mp_sqrt(a,b);
    if mp_is_ne(c,b) then begin
      writeln;
      writeln('Diff for ');
      mp_writeln('a=',a);
      mp_writeln('b=',b);
      mp_writeln('c=',c);
      exit;
    end;
    if m and 255 = 0 then begin
      write(m,#13);
      if keypressed and (readkey=#27) then break;
    end;
  end;
end;


var
  ch: char8;
begin
  mp_init5(a,b,c,d,e);
  writeln;
  writeln('Test of MPArith ', MP_VERSION, '   (c) W.Ehrhardt 2009');
  writeln('Karatsuba  cutoffs: mul/sqr = ',mp_mul_cutoff,'/',mp_sqr_cutoff);
  writeln('Toom-3, BZ cutoffs: mul/sqr = ',mp_t3m_cutoff,'/',mp_t3s_cutoff,  ',  div = ',mp_bz_cutoff);
  {---------------------------------------------------------------------------}

  writeln;
  writeln('Compare recursive Newton vs. Karatsuba square root');
  writeln;
  writeln('1 Test match over range of bits');
  writeln('2 Test match for Mersenne numbers');
  writeln('3 Compare timing with default mp_sqrt_cutoff');
  writeln('4 Compare timing with variable mp_sqrt_cutoff');
  writeln;
  writeln('0 Exit');

  writeln;
  write('Choose test type [0..4]: ');

  repeat
    ch := readkey;
  until pos(ch,{$ifdef D12Plus}str255{$endif}('12340'))>0;
  writeln(ch);

  case ch of
    '1':  testrange;
    '2':  testmersenne;
    '3':  CompareRange;
    '4':  CompareRange2;
  end;

  {---------------------------------------------------------------------------}
  mp_clear5(a,b,c,d,e);
  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}
end.


