{Test program timing for Binary and Lehmer (X)GCD, (c) W.Ehrhardt 2008}

program t_gcdblx;


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

uses CRT,
     hrtimer,
     mp_types, mp_base, mp_modul, mp_numth, mp_prng, mp_supp;

var
  a,b,c,d,e: mp_int;
  HR: THRTimer;


{---------------------------------------------------------------------------}
procedure fibtest(mode: integer);
var
  f: integer;
{$ifdef BIT16}
  const fmax=1000;
{$else}
  const fmax=3000;
{$endif}
begin
  for f:=1 to fmax do begin
    mp_fib2(f,a,b);
    case mode of
        1: mp_gcd_ml(a,b,c);
        2: mp_gcd(a,b,c);
        3: mp_xgcd(a,b,@c,@d,@e);
        4: mp_xgcd_bin(a,b,@c,@d,@e);
      else ;
    end;
  end;
end;



{---------------------------------------------------------------------------}
procedure merstest(mode: integer);
var
  m: integer;
{$ifdef BIT16}
  const mmax=1000;
{$else}
  const mmax=3000;
{$endif}
begin
  for m:=1 to mmax do begin
    mp_mersenne(m,a);
    mp_add_d(a,2,b);
    case mode of
        1: mp_gcd_ml(a,b,c);
        2: mp_gcd(a,b,c);
        3: mp_xgcd(a,b,@c,@d,@e);
        4: mp_xgcd_bin(a,b,@c,@d,@e);
      else ;
    end;
  end;
end;


{---------------------------------------------------------------------------}
procedure RandTest(mode: integer; digs: word);
var
  k: integer;
begin
  mp_random_seed1(mode);
  for k:=1 to 500 do begin
    mp_rand_ex(a,digs,false);
    mp_rand_ex(b,digs,false);
    case mode of
        1: mp_gcd_ml(a,b,c);
        2: mp_gcd(a,b,c);
        3: mp_xgcd(a,b,@c,@d,@e);
        4: mp_xgcd_bin(a,b,@c,@d,@e);
      else ;
    end;
  end;
end;


const
  MaxMode=4;

var
  times: array[0..MaxMode] of double;
  m,mm: integer;
  digs: word;

const
  Alg: array[0..MaxMode] of pchar = ('Empty', ' GCD E/L', ' GCD Bin', 'XGCD E/L', 'XGCD Bin');

begin
  mp_random_randomize;
  StartTimer(HR);
  mp_init5(a,b,c,d,e);
  writeln('Test of MPArith V', MP_VERSION, ' [gcd functions]  (c) W.Ehrhardt 2008');
  writeln('Karatsuba  cutoffs: mul/sqr = ',mp_mul_cutoff,'/',mp_sqr_cutoff);
  writeln('Toom-3, BZ cutoffs: mul/sqr = ',mp_t3m_cutoff,'/',mp_t3s_cutoff,  ',  div = ',mp_bz_cutoff);
  if paramstr(1)<>'' then mm:=2 else mm:=MaxMode;

  for m:=0 to mm do begin
    write('Fib test - ',Alg[m]:12);
    RestartTimer(HR);
    fibtest(m);
    times[m] := ReadSeconds(HR);
    if m>0 then times[m] := times[m]-times[0];
    writeln(times[m]:8:3, 's');
  end;

  for m:=0 to mm do begin
    write('Mersenne test - ',Alg[m]:12);
    RestartTimer(HR);
    merstest(m);
    times[m] := ReadSeconds(HR);
    if m>0 then times[m] := times[m]-times[0];
    writeln(times[m]:8:3, 's');
  end;

  {$ifdef BIT16}
    digs := 64;
  {$else}
    {$ifdef MP_32BIT}
      digs := 128;
    {$else}
      digs := 256;
    {$endif}
  {$endif}

  for m:=0 to mm do begin
    write('Random test ', digs*DIGIT_BIT:3, ' bits - ',Alg[m]:12);
    RestartTimer(HR);
    RandTest(m, digs);
    times[m] := ReadSeconds(HR);
    if m>0 then times[m] := times[m]-times[0];
    writeln(times[m]:8:3, 's');
  end;

{---------------------------------------------------------------------------}
  mp_clear5(a,b,c,d,e);
  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}
end.
