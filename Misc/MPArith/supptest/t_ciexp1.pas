{-Test prog for mp_arith, we 06.2010, generate include file for bits of exp1}

program t_ciexp1;

{$i STD.INC}
{$i mp_conf.inc}

{$x+}

{$ifdef APPCONS}
  {$apptype console}
{$endif}


uses {$ifdef WINCRT} WinCRT, {$endif}
     mem_util, mp_types, mp_base, mp_supp;


{---------------------------------------------------------------------------}
procedure mp_exp1w(Radix, prec: word; var sum: mp_int);
  {-compute exp(1) to prec Radix digits, word version.}
var
  t,v:  mp_int;
  x,rd: word;
const
  EXTRA = 100;
begin

  if mp_error<>MP_OKAY then exit;
  {$ifdef MPC_ArgCheck}
    if mp_not_init(sum) then begin
      {$ifdef MPC_HaltOnArgCheck}
        {$ifdef MPC_UseExceptions}
          raise MPXNotInit.Create('mp_exp1w');
        {$else}
          RunError(MP_RTE_NOTINIT);
        {$endif}
      {$else}
        set_mp_error(MP_NOTINIT);
        exit;
      {$endif}
    end;
  {$endif}

  mp_init2(t,v);
  if mp_error<>MP_OKAY then exit;

  {Increase precision to guard against rounding errors}
  mp_set_w(t, Radix);
  mp_expt_w(t, prec + EXTRA, t);
  mp_copy(t,sum);
  x := 1;
  {calculate sum(1/x!, x=1..), t holds scaled x!}
  repeat
    mp_div_w(t, x, @t, rd);
    mp_add(sum, t, sum);
    inc(x);
    if x=0 then begin
      writeln('x overflow');
      halt;
    end;
  until mp_iszero(t) or (mp_error<>MP_OKAY);
  {Chop off extra precision}
  {sum := trunc(sum/Radix^EXTRA + 0.5}
  mp_set(v,Radix);
  mp_expt_w(v,EXTRA,v);
  mp_div_2(v,t);
  mp_add(sum,t,sum);
  mp_div(sum, v, sum);

  mp_clear2(v,t);
end;


const
  Radix   = 16;
  ndigits = 50100;

var
  sum, sump: mp_int;
  buf: array[1..26000] of byte;
  x: longint;
  i,j: word;
  f: text;
begin

  mp_init2(sum,sump);

  mp_exp1w(Radix, ndigits, sum);

  (*
  writeln;
  write('e=');
  mp_output_radix(sum, radix);
  halt;
  *)

  x := mp_bitsize(sum) and 7;
  if x<>0 then mp_shl(sum,8-x,sum);
  mp_to_unsigned_bin_n(sum,buf,sizeof(buf));

  assign(f,'e.inc');
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

