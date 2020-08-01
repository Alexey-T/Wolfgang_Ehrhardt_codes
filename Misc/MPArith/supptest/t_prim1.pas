{Benchmark and partial validation for IsPrime32,  we Aug.2005}
program t_prim1;

{$i STD.INC}

{$x+,i+}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT, {$else} CRT, {$endif}
  mp_types, mp_prime, mp_base, mp_numth;


procedure Vali;
var
  N: word;
begin
  write('Vali ... ,  ');
  for N:=$FFFF downto 1 do begin
    if IsPrime32(N)<>IsPrime16(N) then begin
      writeln('IsPrime16 <> IsPrime32 for N =', N);
      halt;
    end;
  end;
end;


procedure Bench;
const
  f = 0.99999;
var
  c,i,n: longint;
begin
  write('Bench ...  ');
  i := MaxLongint;
  c := 0;
  while i>2 do begin
    n := 1 + i shl 1;
    if is_spsp32(n,2) and not IsPrime32(n) then inc(c);
    i := trunc(f*i);
  end;
  writeln;
  writeln('Found ',c,' base 2 spsp numbers that are not prime.');
end;


begin
  writeln('Test of MP library version ', MP_VERSION, '   (c) W.Ehrhardt 2005');
  writeln('Testing is_spsp32, IsPrime32, and IsPrime16');
  Vali;
  Bench;
end.
