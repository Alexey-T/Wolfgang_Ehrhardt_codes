{Test program for MPArith/Toom-3, (c) W.Ehrhardt 2009}

program t_toom;


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

uses
  {$ifdef FPC}
    {$ifdef WIN32}
      cmem,
    {$endif}
  {$endif}
  hrtimer,
  mp_types, mp_base, mp_numth, mp_supp;


label
  done;

var
  a,b,c,d,e: mp_int;
  i,j,NR: longint;
  HR: THRTimer;

begin
  StartTimer(HR);
  mp_init5(a,b,c,d,e);
  writeln('Test of MPArith V ', MP_VERSION, '   (c) W.Ehrhardt 2009');
  writeln('Karatsuba  cutoffs: mul/sqr = ',mp_mul_cutoff,'/',mp_sqr_cutoff);
  writeln('Toom-3, BZ cutoffs: mul/sqr = ',mp_t3m_cutoff,'/',mp_t3s_cutoff,  ',  div = ',mp_bz_cutoff);
{---------------------------------------------------------------------------}

  NR := 8;
{$ifdef MSDOS}
  mp_fib(150000,a);
  mp_fib(120000,b);
{$else}
  mp_fib(330000,a);
  mp_fib(300000,b);
{$endif}

  writeln('-------- Multiply --------');
  mp_chs(a,a);
  writeln('bsa/bsb = ', mp_bitsize(a)/mp_bitsize(b):1:1);

  for j:=1 to 2 do mp_mul(a,b,d);

  ReStartTimer(HR);
  for j:=1 to NR do mp_mul(a,b,d);
  writeln(mp_t3m_cutoff:4,'  Toom [s]: ',ReadSeconds(HR):1:3);

  mp_t3m_cutoff := 60000;
  ReStartTimer(HR);
  for j:=1 to NR do s_mp_karatsuba_mul(a,b,c);
  if (a.sign<>b.sign) and (c.used>0) then c.sign := MP_NEG;

  writeln('Kara [s]: ',ReadSeconds(HR):1:3);

  writeln('Toom=Kara: ', mp_is_eq(c,d));

  mp_chs(b,b);

  writeln('a.used = ',a.used, '  ->  ', mp_bitsize(a), ' bits');
  for i:=1 to 9 do begin
    mp_t3m_cutoff := i*mp_mul_cutoff;
    ReStartTimer(HR);
    for j:=1 to NR do mp_mul(a,b,d);
    writeln(i:2,'K = ',mp_t3m_cutoff:4,'  Toom [s]: ',ReadSeconds(HR):1:3);
  end;

  mp_t3m_cutoff := 60000;
  ReStartTimer(HR);
  for j:=1 to NR do mp_mul(a,b,c);
  writeln('Kara [s]: ',ReadSeconds(HR):1:3);
  writeln('Toom=Kara: ', mp_is_eq(c,d));


  writeln('-------- Squaring --------');
  for j:=1 to 2 do mp_sqr(a,d);
  ReStartTimer(HR);
  for j:=1 to NR do mp_sqr(a,d);
  writeln(mp_t3s_cutoff:4,'  Toom [s]: ',ReadSeconds(HR):1:3);

  mp_t3s_cutoff := 60000;
  ReStartTimer(HR);
  for j:=1 to NR do mp_sqr(a,c);
  writeln('Kara [s]: ',ReadSeconds(HR):1:3);
  writeln('Toom=Kara: ', mp_is_eq(c,d));

  writeln('a.used = ',a.used, '  ->  ', mp_bitsize(a), ' bits');
  for i:=1 to 9 do begin
    mp_t3s_cutoff := i*mp_sqr_cutoff;
    ReStartTimer(HR);
    for j:=1 to NR do mp_sqr(a,d);
    writeln(i:2,'K = ',mp_t3s_cutoff:4,'  Toom [s]: ',ReadSeconds(HR):1:3);
  end;

  mp_t3s_cutoff := 60000;
  ReStartTimer(HR);
  for j:=1 to NR do mp_sqr(a,c);
  writeln('Kara [s]: ',ReadSeconds(HR):1:3);
  writeln('Toom=Kara: ', mp_is_eq(c,d));

done:

{---------------------------------------------------------------------------}
  mp_clear5(a,b,c,d,e);
  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}
end.

