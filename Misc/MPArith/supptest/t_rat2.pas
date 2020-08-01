{Test program for mpr_cmp, (c) W.Ehrhardt 2004-2005}

program t_rat2;


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
  {$ifdef WINCRT} WinCRT,{$endif}
  hrtimer,
  mp_types, mp_base,
  {$ifdef MPC_Diagnostic}
    mp_supp,
  {$endif}
  mp_numth,mp_prng,mp_ratio;

label
  panik;

const
  N=8;
  M=5*DIGIT_BIT;
var
  a,b,c,d,z: mp_rat;
  an,ad,bn,bd,x,t: mp_int;
  HR: THRTimer;
  i,j,k,l: mp_digit;
  c1,c2: integer;
begin
  mp_random_randomize;
  StartTimer(HR);
  mpr_init5(a,b,c,d,z);
  mp_init6(an,ad,bn,bd,x,t);

  writeln('Test of MP library version ', MP_VERSION, '   (c) W.Ehrhardt 2007');
{---------------------------------------------------------------------------}

  mpr_zero(z);
  mp_mersenne(M,x);
  mp_sub_d(x, N div 2, x);
  for i:=1 to N do begin
    mp_add_d(x,i,an);
    for j:=1 to N do begin
      mp_add_d(x,j,ad);
      mpr_set(a,an,ad);
      for k:=1 to N do begin
         mp_add_d(x,k,bn);
         for l:=1 to N do begin
           mp_add_d(x,l,bd);
           mpr_set(b,bn,bd);
           mpr_sub(a,b,c);
           c1 := mpr_cmp(a,b);
           c2 := mp_cmp_d(c.num,0);
           if c1<>c2 then begin
             mp_sub(b.num,b.den,t);
             writeln('a=',mpr_decimal(a));
             writeln('b=',mpr_decimal(b));
             writeln('c=',mpr_decimal(c));
             writeln('t=',mp_decimal(t));
             writeln(c1:3, c2:3);
             writeln(i:3,j:3,k:3,l:3);
             goto panik;
           end;
         end;
      end;
    end;
  end;

panik:

{---------------------------------------------------------------------------}
  writeln('Time [s]: ',ReadSeconds(HR):1:3);
  mp_clear6(an,ad,bn,bd,x,t);
  mpr_clear5(a,b,c,d,z);
  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}
end.
