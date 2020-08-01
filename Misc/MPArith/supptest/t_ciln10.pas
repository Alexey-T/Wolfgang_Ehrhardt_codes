{-Test prog for mp_arith, we Jan.2008, generate include file for bits of ln(10)}

program t_ciln10;

{$i STD.INC}
{$i mp_conf.inc}

{$x+}

{$ifdef APPCONS}
  {$apptype console}
{$endif}


uses {$ifdef WINCRT} WinCRT, {$endif}
     mem_util, mp_types, mp_base, mp_supp;


const
  Radix   = 16;
  ndigits = 50100;

var
  sum, sump: mp_int;
  buf: array[1..26000] of byte;
  digs: word;
  x: longint;
  i,j: word;
  f: text;
begin

  mp_init2(sum,sump);

  {ln(10) = 46*atanh(1/31) + 34*atanh(1/49) + 20*atanh(1/161)}
  mp_atanhw(46,  31, Radix, ndigits, sum);
  mp_atanhw(34,  49, Radix, ndigits, sump);  mp_add(sum, sump, sum);
  mp_atanhw(20, 161, Radix, ndigits, sump);  mp_add(sum, sump, sum);

  x := mp_bitsize(sum) and 7;
  if x<>0 then mp_shl(sum,8-x,sum);
  digs := mp_to_unsigned_bin_n(sum,buf,sizeof(buf));

  {
  assign(f,'ln10.bin');
  rewrite(f,1);
  blockwrite(f,buf,25000);
  close(f);
  }

  assign(f,'ln10.inc');
  rewrite(f);
  i := 0;
  while i<25000 do begin
    write(f,'      db ');
    for j:=1 to 24 do write(f,'$',hexbyte(buf[i+j]),',');
    inc(i,25);
    writeln(f,'$',hexbyte(buf[i]));
  end;
  close(f);

  mp_clear2(sum,sump);

end.

