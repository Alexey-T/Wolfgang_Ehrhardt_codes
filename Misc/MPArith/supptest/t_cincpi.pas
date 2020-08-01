{-Test prog for mp_arith, we Nov.2007, generate include file for bits of pi}

program t_cincpi;

{$i STD.INC}
{$i mp_conf.inc}

{$x+}

{$ifdef APPCONS}
  {$apptype console}
{$endif}


uses {$ifdef WINCRT} WinCRT, {$endif}
     mem_util, mp_types, mp_base, mp_supp;

{ Compute pi to max 64000 digits with arctan Machin type formula
  pi = 48*arctan(1/18) + 32*arctan(1/57) - 20*arctan(1/239)     }

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

  {pi = 48*arctan(1/18) + 32*arctan(1/57) - 20*arctan(1/239)}  {Perf 1.79}
  mp_arctanw(48, 18, Radix, ndigits, sum);
  mp_arctanw(32, 57, Radix, ndigits, sump);
  mp_add(sum, sump, sum);
  mp_arctanw(20, 239, Radix, ndigits, sump);
  mp_sub(sum, sump, sum);

  x := mp_bitsize(sum) and 7;
  if x<>0 then mp_shl(sum,8-x,sum);
  digs := mp_to_unsigned_bin_n(sum,buf,sizeof(buf));

  {
  assign(f,'pi.bin');
  rewrite(f,1);
  blockwrite(f,buf,25000);
  close(f);
  }

  assign(f,'pi.inc');
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

