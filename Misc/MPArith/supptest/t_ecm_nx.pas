{Test program for [mp_ecm_factor], (c) W.Ehrhardt 2006}

program t_ecm_nx;


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
  CRT,
  hrtimer,
  mp_types, mp_base,
  {$ifdef MPC_Diagnostic}
    mp_supp,
  {$endif}
  mp_numth, mp_pfu, mp_prng;


{---------------------------------------------------------------------------}
procedure progress(checkonly: boolean; cnt,maxcnt: longint; var cancel: boolean); {$ifdef BIT16} far; {$endif}
  {-standard progress function}
begin
  if (cnt > 0) and not checkonly then write('.');
  cancel := (keypressed and (readkey=#27));
end;


var
  n,f,r: mp_int;
  HR: THRTimer;
  Seed: longint;

begin
  mp_random_randomize;
  StartTimer(HR);
  mp_init3(n,f,r);
  writeln('Test of MPArith V', MP_VERSION, ' [mp_ecm_factor]   (c) W.Ehrhardt 2006');
  writeln('Karatsuba cutoffs: mul/sqr = ',mp_mul_cutoff,'/',mp_sqr_cutoff);

  {$ifdef FPC}
    mp_set_progress(@progress);
  {$else}
    mp_set_progress(progress);
  {$endif}

  mp_show_progress := true;

  mp_mersenne(139,n);         {41,59,67,101,103,139,#137,149}

  seed := 123;
  mp_ecm_simple(n,f,Seed);
  writeln;
  writeln('   N: ',mp_decimal(n));
  writeln('   f: ',mp_decimal(f));
  if not mp_is0(f) then begin
    mp_mod(n,f,r);
    writeln('   r: ', mp_decimal(r));
  end;
  writeln('Seed: ', seed, ',  time [s]: ',ReadSeconds(HR):1:3);

  mp_clear3(n,f,r);
  {$ifdef MPC_Diagnostic}
     mp_dump_meminfo;
     mp_dump_diagctr;
  {$endif}

end.
