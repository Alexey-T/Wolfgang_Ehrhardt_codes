{Test program for mp_ratio: calculate harmonic numbers   (c) W.Ehrhardt 2009}

program t_harm;


{$i STD.INC}
{$i mp_conf.inc}

{$ifdef VER70}
{$N+}
{$endif}

{$x+}  {pchar I/O}
{$i+}  {RTE on I/O error}

{$ifdef APPCONS}
  {$apptype console}
{$endif}


uses
  {$ifdef WINCRT} WinCRT, {$else} CRT, {$endif}
  hrtimer,
  mp_types,
  {$ifdef MPC_Diagnostic}
    mp_supp,
  {$endif}
  mp_numth,mp_ratio;

{$ifdef BIT32or64}
const
  nmax=20000;
{$else}
const
  nmax=10000;
{$endif}
var
  a,b,c,d,z: mp_rat;
  HR: THRTimer;
  n:longint;
begin

  StartTimer(HR);
  mpr_init5(a,b,c,d,z);

  writeln('Test of MPArith V', MP_VERSION, '  [Harmonic numbers]  (c) W.Ehrhardt 2009');
  writeln('Karatsuba  cutoffs: mul/sqr = ',mp_mul_cutoff,'/',mp_sqr_cutoff);
  writeln('Toom-3, BZ cutoffs: mul/sqr = ',mp_t3m_cutoff,'/',mp_t3s_cutoff,  ',  div = ',mp_bz_cutoff);

  writeln('Iterative calculation of H(n):');
  mpr_zero(z);
  n:=0;
  repeat
    inc(n);
    mpr_set_int(a,1,n);
    mpr_add(z,a,z);
    if n<=25 then writeln('H(',n:2,') = ', mpr_todouble(z), ' = ', mpr_decimal(z));
    if n and 255 = 0 then begin
      {$ifdef WINCRT}
        write('.');
      {$else}
        write(n:8, z.num.used+z.den.used:8,#13);
      {$endif}
      if keypressed and (readkey=#27) then break;
    end;
  until n>=nmax;
  {$ifdef WINCRT}
    writeln;
  {$endif}
  writeln('H(',n,') = ', mpr_todouble(z), '  CS=',mpr_checksum(z):12, ',   Time [s]: ',ReadSeconds(HR):1:3);

  n := nmax;
  writeln('Binary splitting calculation of H(n):');
  ReStartTimer(HR);
  mpr_harmonic(n,z);
  writeln('H(',n,') = ', mpr_todouble(z), '  CS=',mpr_checksum(z):12, ',   Time [s]: ',ReadSeconds(HR):1:3);
  ReStartTimer(HR);
  mpr_harmonic(2*n,z);
  writeln('H(',2*n,') = ', mpr_todouble(z), '  CS=',mpr_checksum(z):12, ',   Time [s]: ',ReadSeconds(HR):1:3);

  mpr_clear5(a,b,c,d,z);
  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}
end.
