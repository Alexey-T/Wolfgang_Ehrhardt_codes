{calculate bit arrays for mp_is_square2, (c) Jan.2009 W.Ehrhardt}

program t_pmtab2;

{$i STD.INC}
{$ifdef APPCONS}
  {$apptype console}
{$endif}

{---------------------------------------------------------------------------}
function HexByte(b: byte): string;
  {-byte as hex string}
const
  nib: array[0..15] of char = '0123456789abcdef';
begin
  HexByte := nib[b div 16] + nib[b and 15];
end;


{---------------------------------------------------------------------------}
function  _isbit(const ba: array of byte; k: word): boolean;
  {-test if bit k is set}
var
  i: integer;
begin
  i := k shr 3;
  _isbit := (i <= high(ba)) and (ba[i] and (1 shl (k and 7)) <> 0);
end;


{---------------------------------------------------------------------------}
procedure _setbit(var ba: array of byte; k: word);
  {-set bit k}
var
  i: integer;
begin
  i := k shr 3;
  ba[i] := ba[i] or (1 shl (k and 7));
end;


{---------------------------------------------------------------------------}
procedure _clrbit(var ba: array of byte; k: word);
  {-set bit k}
var
  i: integer;
begin
  i := k shr 3;
  ba[i] := ba[i] and (not(1 shl (k and 7)));
end;


{---------------------------------------------------------------------------}
function pow64(i,k,m: byte): byte;
  {-calculate i^k mod m}
var
  p:word;
begin
  if k=0 then begin
    pow64 := 1;
    exit;
  end
  else if k=1 then begin
    pow64 := i mod m;
    exit;
  end;
  if (i=0) or (i=1) then begin
    pow64 := i;
    exit;
  end;
  {i>1, k>1}
  p := i;
  while k>1 do begin
    p := p*i mod m;
    dec(k);
  end;
  pow64 := p;
end;


var
  ba : array[0..15] of byte;


{---------------------------------------------------------------------------}
procedure makevec(k,m: byte);
  {-generate/print const vector for kth power mod m}
var
  i,c,x: byte;
begin
  fillchar(ba,sizeof(ba),0);
  for i:=0 to m-1 do _setbit(ba,i);
  for i:=0 to m-1 do _clrbit(ba,pow64(i,k,m));
  write(k:3, ' | ');
  c := 0;
  x := 0;
  for i:=0 to m-1 do begin
    if _isbit(ba,i) then begin
      {write('1');}
      inc(c);
      x := i;
    end
    else {write('0')};
  end;
  writeln(m:3,' | ', c/m:3:4);
  x := x shr 3;
  write('const ba_',k,'_',m,' : array[0..',x,'] of byte = (');
  for i:=0 to x do begin
    write('$', hexbyte(ba[i]));
    if i=x then writeln(');') else write(',');
  end;
  writeln;
end;


var
  p: byte;
begin
  for p:=3 to 127 do if odd(p) then makevec(2,p);
  makevec(2,128);
end.
