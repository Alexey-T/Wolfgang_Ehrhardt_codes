{Benchmark and partial validation for next/prevprim32,  we Oct.2005}

program t_prim2;

{$i STD.INC}

{$x+,i+}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT, {$else} CRT, {$endif}
  mp_types, mp_base, mp_prime, mp_numth;


{---------------------------------------------------------------------------}
function reference_np32(n: longint): longint;
  {-simple version that test all odd n}
begin
  if (n>=-4) and (n<=7) then begin
    if n<0 then reference_np32 := 0
    else if n<=2 then reference_np32 := 2
    else if n<=3 then reference_np32 := 3
    else if n<=5 then reference_np32 := 5
    else  reference_np32 := 7;
    exit;
  end;
  if n and 1 = 0 then inc(n);
  repeat
    if IsPrime32(n) then begin
      reference_np32 := n;
      exit;
    end;
    inc(n,2);
  until false;
end;


{---------------------------------------------------------------------------}
function reference_pp32(n: longint): longint;
  {-simple version that test all odd n}
begin
  if (n>=0) and (n<11) then begin
    if n<2 then reference_pp32 := 0
    else if n<3 then reference_pp32 := 2
    else if n<5 then reference_pp32 := 3
    else if n<7 then reference_pp32 := 5
    else reference_pp32 := 7;
    exit;
  end;
  if n and 1 = 0 then dec(n);
  repeat
    if IsPrime32(n) then begin
      reference_pp32 := n;
      exit;
    end;
    dec(n,2);
  until false;
end;



{---------------------------------------------------------------------------}
procedure nprange(n: longint);
  {-Test range of next 1000 primes}
var
  i: integer;
  np,nv: longint;
begin
  for i:=1 to 500 do begin
    nv := reference_np32(n);
    np := nextprime32(n);
    if np<>nv then begin
      writeln('Diff at n = ', n);
      halt;
    end;
    n := np+1;
  end;
end;



{---------------------------------------------------------------------------}
procedure pprange(n: longint);
  {-Test range of next 1000 primes}
var
  i: integer;
  np,nv: longint;
begin
  for i:=1 to 500 do begin
    nv := reference_pp32(n);
    np := prevprime32(n);
    if np<>nv then begin
      writeln('Diff at n = ', n);
      halt;
    end;
    n := np-1;
  end;
end;



{---------------------------------------------------------------------------}
procedure prevnext32test;
  {-test prev/nextprime32 for ranges <2^31 and >2^31}
{$ifdef BIT32or64}
const f = 0.7;
{$else}
const f = 0.7;
{$endif}
var
  n: longint;
begin
  n := MaxLongint;
  while n>10 do begin
    write('.');
    nprange(n);
    nprange(-n);
    pprange(n);
    pprange(-n);
    n := trunc(n*f);
  end;
  writeln;
end;


begin
  writeln('Test of MP library version ', MP_VERSION, '   (c) W.Ehrhardt 2005');
  writeln('Testing nextprime32 and prevprime32');
  prevnext32test;
end.
