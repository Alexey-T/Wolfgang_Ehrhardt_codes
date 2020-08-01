{Support program for next/prev prime  (c) we 10.2005}
{Calculates tables for prime residue classes mod 30 or mod 210}

{$i STD.INC}
{$ifdef APPCONS}
  {$apptype console}
{$endif}

{.$define USERC30}

{$ifdef USERC30}
const
  NPMOD = 30;
{$else}
const
  NPMOD = 210;
{$endif}

function gcd32(a,b: longint): longint;
var
  r: longint;
begin
  while b<>0 do begin
    r := a mod b;
    a := b;
    b := r;
  end;
  gcd32 := a;
end;

var
  prct,OddIdx: array[0..NPMOD-1] of integer;
  next: array[0..NPMOD div 2 -1] of byte;
  n,i,k: integer;
begin
  n:=0;
  for i:=0 to pred(NPMOD) do begin
    if gcd32(i,NPMOD)=1 then begin
      prct[n] := i;
      OddIdx[i] := n;
      inc(n);
    end
    else OddIdx[i] := -1;
  end;
  writeln('Prime residue classes mod ',NPMOD,'. Cnt = ',n);
  for i:=0 to n-2 do begin
     write(prct[i]:3,', ');
     if i mod 12=11 then writeln;
  end;
  writeln(prct[n-1]:3);

  writeln;
  writeln('Differences:');
  for i:=1 to n-1 do begin
    write(prct[i]-prct[i-1]:2,',');
    if i mod 16=0 then writeln;
  end;
  writeln(NPMOD+prct[0]-prct[n-1]:2);

  writeln;
  writeln('Odd indices:');
  for i:=0 to pred(NPMOD) do begin
    if odd(i) then begin
      write(OddIdx[i]:3,',');
      if i mod 30 = 29 then writeln;
    end;
  end;
  writeln;

  for i:=1 to pred(NPMOD) do begin
    if odd(i) then begin
      k := i;
      n := OddIdx[k];
      while n=-1 do begin
        k := k+2;
        if k>(NPMOD-1) then halt;
        n := OddIdx[k];
      end;
      next[i div 2] := k;
    end;
  end;

  writeln('Next prct for odd n:');
  for i:=0 to pred(NPMOD div 2) do begin
    write(next[i]:3,',');
    if i mod 15 = 14 then writeln;
  end;

  writeln;
  writeln('Initial increments:');
  for i:=0 to pred(NPMOD) do begin
    n := i;
    if n and 1 = 0 then inc(n);
    n := n mod NPMOD;
    k := next[n div 2];
    if k>n then n := (k-n) else n:=0;
    write(n:3);
    if i mod 15 = 14 then writeln;
  end;
end.
