{-Test prog for mp_arith, we Jan.2008, generate include file for bits of ln(2)}

program t_ciln2;

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

  {ln(2) = 14*atanh(1/31) + 10*atanh(1/49) + 6*atanh(1/161)}
  mp_atanhw(14,  31, Radix, ndigits, sum);
  mp_atanhw(10,  49, Radix, ndigits, sump);  mp_add(sum, sump, sum);
  mp_atanhw( 6, 161, Radix, ndigits, sump);  mp_add(sum, sump, sum);


  x := mp_bitsize(sum) and 7;
  if x<>0 then mp_shl(sum,8-x,sum);
  digs := mp_to_unsigned_bin_n(sum,buf,sizeof(buf));

  {
  assign(f,'ln2.bin');
  rewrite(f,1);
  blockwrite(f,buf,25000);
  close(f);
  }

  assign(f,'ln2.inc');
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

