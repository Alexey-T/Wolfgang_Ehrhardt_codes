{Test program for mp library [mp_provable_prime], (c) W.Ehrhardt 2009}

program t_provp;


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

uses {CRT,}
     hrtimer,
     mp_types, mp_base, mp_numth, mp_prng, mp_supp;

{$ifdef BIT32or64}
const
  bitsize=2048;
{$else}
const
  bitsize=1024;
{$endif}

var
  a,b,c,d,e: mp_int;
  HR: THRTimer;
begin
  { mp_random_randomize;}
  StartTimer(HR);
  mp_init5(a,b,c,d,e);
  writeln('Test of MPArith V', MP_VERSION, ' [mp_provable_prime]  (c) W.Ehrhardt 2009');
  {$ifdef MPC_TRACE}
    mp_verbose := 3;
  {$endif}

{---------------------------------------------------------------------------}
  mp_provable_prime(bitsize,a);
  writeln(mp_bitsize(a):8,mp_is_pprime(a):6,'  ', mp_decimal(a));
{---------------------------------------------------------------------------}
  writeln('Time [s]: ',ReadSeconds(HR):1:3);
  mp_clear5(a,b,c,d,e);
  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}
end.
