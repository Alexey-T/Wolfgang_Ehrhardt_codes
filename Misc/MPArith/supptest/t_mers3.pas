{-Calculate Mersenne primes using Lucas-Lehmer test, we 09.2005}

program t_mers3;

{$i STD.INC}

{$x+,i+}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT, {$else} CRT, {$endif}
  mp_types, mp_numth, mp_supp;


var
  s,sm: longint;
begin
  writeln('Test of MPArith V', MP_VERSION, '   (c) W.Ehrhardt 2005');
  writeln('Karatsuba  cutoffs: mul/sqr = ',mp_mul_cutoff,'/',mp_sqr_cutoff);
  writeln('Toom-3, BZ cutoffs: mul/sqr = ',mp_t3m_cutoff,'/',mp_t3s_cutoff,  ',  div = ',mp_bz_cutoff);
  writeln('Calculate Mersenne primes using Lucas-Lehmer test - press Esc to cancel');
  s := 1;
  if paramstr(1)='-t' then begin
    {$ifdef BIT32or64}
      sm:=2500
    {$else}
      sm:=1500
    {$endif}
  end
  else sm:=MaxMersenne;
  repeat
    {$ifndef WINCRT}
    {write(s,#13);}
    {$endif}
    if mp_isMersennePrime(s) then writeln('Prime: 2^',s,'-1');
    inc(s,2);
    if mp_error<>MP_OKAY then break;
  until (s>sm) or (keypressed and (readkey=#27));
  mp_dump_meminfo;
  mp_dump_diagctr;
end.
