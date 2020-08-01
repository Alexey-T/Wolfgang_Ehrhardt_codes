{Test mp_popcount, we Jan.2006}

program t_popcnt;


{$i STD.INC}
{$i mp_conf.inc}

{$x+}  {pchar I/O}
{$i+}  {RTE on I/O error}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

{$ifndef FPC} {$N+} {$endif}

uses CRT,
     mp_types, mp_base,
     mp_numth;


{---------------------------------------------------------------------------}
function popcount32p(l: longint): word;
  {-simple/stupid reference implementation}
var
  pc: word;
begin
  pc := 0;
  while l<>0 do begin
    if odd(l) then inc(pc);
    l := l shr 1;
  end;
  popcount32p := pc;
end;


{---------------------------------------------------------------------------}
procedure test_pop16;
var
  w,i: word;
begin
  writeln('Test popcount16');
  w := 0;
  for i:=0 to 15 do begin
    w := w shl 1 or 1;
    {$ifdef StrictLong} {$r-} {$endif}
    if (popcount16(1 shl i)<>1) or (popcount16(w)<>(i+1)) or (popcount16($FFFF shr i) <> 16-i) then begin
      writeln('--- ',i); halt;
    end;
    {$ifdef StrictLong} {$r-} {$endif}
  end;
  for w:=0 to $FFFF do begin
    if popcount16(w) <> popcount32(w) then begin
      writeln('*** ',w); halt;
    end;
    if popcount16(w) <> popcount32p(w) then begin
      writeln('>>> ',w); halt;
    end;
  end;
  writeln('passed');
end;



{---------------------------------------------------------------------------}
procedure test_pop32;
var
  i: word;
  l: longint;
{$ifdef BIT32or64}
const
  fac=0.99999;
{$else}
const
  fac=0.9999;
{$endif}
begin
  writeln('Test popcount32');
  l := 0;
  {$ifdef StrictLong} {$R-} {$endif}
  for i:=0 to 31 do begin
    l := l shl 1 or 1;
    if (popcount32(longint(1) shl i)<>1) or (popcount32(l)<>(i+1)) or (popcount32($FFFFFFFF shr i) <> 32-i) then begin
      writeln('--- ',i); halt;
    end;
    if (popcount32p(longint(1) shl i)<>1) or (popcount32p(l)<>(i+1)) or (popcount32p($FFFFFFFF shr i) <> 32-i) then begin
      writeln('--- ',i); halt;
    end;
  end;
  {$ifdef StrictLong}
    {$ifdef RangeChecks_on}
      {$R+}
    {$endif}
  {$endif}
  {$ifdef FULLRANGE}
    for l:=0 to $FFFFFFF do begin
      if popcount32p(l) <> popcount32(l) then begin
        writeln('*** ',l); halt;
      end;
      if l and $FFFFF = 0 then write(l,#13);
    end;
  {$else}
    l:=MaxLongint;
    while l>0 do begin
      if popcount32p(l) <> popcount32(l) then begin
        writeln('*** ',l); halt;
      end;
      l := trunc(fac*l);
    end;
  {$endif}
  writeln('passed       ');
end;


{---------------------------------------------------------------------------}
procedure test_mp_pop;
var
  a: mp_int;
  i,k: longint;
{$ifdef BIT32or64}
const
  fac=0.9;  {Mar.2014: Adjusted for MAXDigits = $1000000 with 32-bit compilers}
{$else}
const
  fac=0.99;
{$endif}

begin
  mp_init(a);
  writeln('Test mp_popcount for a = 2^i, a-1, a+1');
  i:=MaxMersenne-1;
  k:=0;
  while i>0 do begin
    if k and $f = 0 then write(i:8,#13);
    if keypressed and (readkey=#27) then halt;
    mp_mersenne(i,a);
    if i<>mp_popcount(a) then begin
      writeln('M(i) err: ', i);
      halt;
    end;
    mp_inc(a);
    if 1<>mp_popcount(a) then begin
      writeln('M(i)+1 err: ', i);
      halt;
    end;
    mp_inc(a);
    if 2<>mp_popcount(a) then begin
      writeln('M(i)+2 err: ', i);
      halt;
    end;
    i := trunc(fac*i);
    inc(k);
  end;
  mp_clear(a);
  writeln('passed       ');
end;

begin
  writeln('Test of MP library version ', MP_VERSION, '   (c) W.Ehrhardt 2006-2014');
  test_pop16;
  test_pop32;
  test_mp_pop;
end.
