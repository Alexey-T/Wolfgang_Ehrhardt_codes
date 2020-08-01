{Test program for mpf_numpart, (c) W.Ehrhardt 2009-2012}

program t_part;


{$i STD.INC}
{$i mp_conf.inc}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

{$ifdef BIT16}
{$N+}
{$endif}

uses
  {$ifdef WINCRT}
    WinCRT,
  {$endif}
  hrtimer,
  mp_types, mp_base, mp_supp,
  mp_real;


{---------------------------------------------------------------------------}
procedure EulerTest(n: longint);
var
  x,y: mp_int;
  k,m: longint;
begin
  {Compute p(n) with mpf_numpart and via Euler's recursive}
  {pentagonal algorithm and check if both are equal}
  mp_init2(x,y);
  if mp_error=MP_OKAY then begin
    writeln('Euler test for n=',n);
    mp_zero(x);
    k :=1;
    repeat
      m := k*(3*k-1) div 2;
      if m>n then break;
      write(n-m:5);
      mpf_numbpart(n-m,y);
      if odd(k) then mp_add(x,y,x) else mp_sub(x,y,x);
      m := k*(3*k+1) div 2;
      if m>n then break;
      write(n-m:5);
      mpf_numbpart(n-m,y);
      if odd(k) then mp_add(x,y,x) else mp_sub(x,y,x);
      inc(k);
    until false;
    mpf_numbpart(n,y);
    writeln;
    if mp_is_ne(x,y) then begin
      writeln('Failed:',n);
      writeln('x='); mp_output_decimal(x); writeln;
      writeln('y='); mp_output_decimal(y); writeln;
    end
    else writeln('OK!');
    mp_clear2(x,y);
  end;
end;


{---------------------------------------------------------------------------}
procedure RamanujanTest(n: longint);
var
  p: mp_int;
  i,j: longint;
  r,x: mp_digit;
begin
  {Check Ramanujan's simple congruences:
    5  is a factor of p(n) if n==4(mod 5)
    7  is a factor of p(n) if n==5(mod 7)
    11 is a factor of p(n) if n==6(mod 11)
  }
  mp_init(p);
  writeln('Ramanujan tests mod 5,7,11 for n=',n,'+i, i=1..100');
  if mp_error=MP_OKAY then begin
    for j:=1 to 100 do begin
      i := n+j;
      if (i mod 5 =4) or (i mod 7 = 5) or (i mod 11 = 6) then begin
        write(i,#13);
        mpf_numbpart(i,p);
        mp_mod_d(p,5*7*11,x);
        if (i mod 5)=4 then begin
          r := x mod 5;
          if r<>0 then writeln('i=',i, '  m=5,   r=',r);
        end;
        if (i mod 7)=5 then begin
          r := x mod 7;
          if r<>0 then writeln('i=',i, '  m=7,   r=',r);
        end;
        if (i mod 11)=6 then begin
          r := x mod 11;
          if r<>0 then writeln('i=',i, '  m=11,   r=',r);
        end;
      end;
    end;
    mp_clear(p);
  end;
end;

{---------------------------------------------------------------------------}
procedure timetest(n: longint);
var
  x: mp_int;
begin
  mp_init(x);
  if mp_error=MP_OKAY then begin
    mpf_numbpart(n,x);
    mp_clear(x);
  end;
end;


var
  HR: THRTimer;
begin
  writeln('Test of MPArith V', MP_VERSION, ' [mpf_numpart]   (c) W.Ehrhardt 2009');
  writeln('Current mp_float default bit precision = ', mpf_get_default_prec,
          ',  decimal precision = ', mpf_get_default_prec*ln(2)/ln(10):1:1);
  StartTimer(HR);

  Eulertest(1000);
  Eulertest(10000);

  RamanujanTest(100);
  RamanujanTest(1000);
  RamanujanTest(10000);
{$ifdef BIT32or64}
  RamanujanTest(100000);
  RamanujanTest(1000000);
{$endif}

  RestartTimer(HR);
{$ifdef BIT16}
  timetest(1000000);
{$else}
  timetest(10000000);  {P4 1.7 GHz,  D10: 1.983s  Pari 2.3.4:  31.623 s}
{$endif}
  writeln('Time [s]: ',ReadSeconds(HR):1:3);
  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}
end.
