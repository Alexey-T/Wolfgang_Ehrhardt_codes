program T_PBit16;

{-Support program for mp_base.pas/mp_pbits.inc, we Oct. 2005 }
{ calculate bit flag array for 16 bit prime tests via sieving}

{$i STD.INC}
{$ifdef APPCONS}
  {$apptype console}
{$endif}


{---------------------------------------------------------------------------}
function HexByte(b: byte): string;
  {-byte ss hex string}
const
  nib: array[0..15] of char = '0123456789abcdef';
begin
  HexByte := nib[b div 16] + nib[b and 15];
end;


var
  pbits: array[0..4095] of byte;      {Bit flag array}
  pbool: array[0..$7FFF] of boolean;  {pbool[i] = isprime(2i+1)}
var
  i,j,d,p: word;
begin
  writeln('Sieving ... ');
  {Build prime sieve in pbool}
  fillchar(pbool,sizeof(pbool), ord(true));
  pbool[0] := false;
  for i:=1 to 127 do begin
    if pbool[i] then begin
      d := 2*i+1;
      j := d+i;
      while j<=$7fff do begin
        pbool[j] := false;
        inc(j,d);
      end;
    end;
  end;
  {Build bit mask array from primes in pbool}
  fillchar(pbits, sizeof(pbits),0);
  p:=0;
  for i:=0 to $7fff do begin
    if pbool[i] then begin
      j := i shr 3;
      pbits[j] := pbits[j] or (1 shl (i and 7));
      inc(p);
    end;
  end;
  {Output bit mask array}
  writeln('Prime cnt = ',p+1);   {cnt including 2}
  for i:=0 to 4095 do begin
    write('$', HexByte(pbits[i]),',');
    if i and 15 = 15 then writeln;
  end;
end.
