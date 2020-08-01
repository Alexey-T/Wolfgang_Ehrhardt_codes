{calculate bit arrays for s_mp_is_pth_power, (C) Oct.2008 W.Ehrhardt}

program t_pmtabs;

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
  tab: array[0..63] of byte;
  ba : array[0..7] of byte;

{---------------------------------------------------------------------------}
procedure gentab(k,m: byte);
  {-generate/print table for kth power mod m}
var
  i,c: byte;
begin
  fillchar(tab,sizeof(tab),0);
  for i:=0 to m-1 do tab[pow64(i,k,m)] := 1;
  write(k:3, ' | ');
  c := 0;
  for i:=0 to m-1 do begin
    write(tab[i]);
    if tab[i]<>0 then inc(c);
  end;
  writeln(' | ', c/m:3:2);
end;


{---------------------------------------------------------------------------}
procedure makevec(k,m: byte);
  {-generate/print const vector for kth power mod m}
var
  i,c,x: byte;
begin
  fillchar(ba,sizeof(ba),0);
  for i:=0 to m-1 do _setbit(ba,pow64(i,k,m));
  write(k:3, ' | ');
  c := 0;
  x := 0;
  for i:=0 to m-1 do begin
    if _isbit(ba,i) then begin
      write('1');
      inc(c);
      x := i;
    end
    else write('0');
  end;
  writeln(' | ', c/m:3:2);
  x := x shr 3;
  write('const ba_',k,'_',m,' : array[0..',x,'] of byte = (');
  for i:=0 to x do begin
    write('$', hexbyte(ba[i]));
    if i=x then writeln(');') else write(',');
  end;
end;


{---------------------------------------------------------------------------}
procedure make2(k,m: byte);
  {-generate/print table and const vector for kth power mod m}
begin
  gentab(k,m);
  makevec(k,m);
end;

begin
  make2(3,64);
  make2(3,13);
  make2(3,61);
  make2(3,63);
  make2(5,64);
  make2(5,25);
  make2(5,41);
  make2(5,44);
  make2(7,64);
  make2(7,29);
  make2(7,43);
  make2(7,49);
  make2(11,64);
  make2(11,23);
  make2(11,36);
  make2(13,64);
  make2(13,53);
  make2(17,64);
  make2(19,64);
  make2(23,64);
  make2(29,64);
  make2(31,64);
  make2(37,64);
  make2(41,64);
  make2(43,64);
  make2(53,64);
end.
