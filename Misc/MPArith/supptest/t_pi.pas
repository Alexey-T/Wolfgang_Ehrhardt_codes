{-Test prog for mp_int, we 01.08.04}
{ Compute pi to max 60000 digits with arctan formulas}

program t_pi;

{$i STD.INC}
{$i mp_conf.inc}

{$x+}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses {$ifdef WINCRT} WinCRT, {$endif}
     mp_types, mp_base, mp_supp;

const
  MPD   = 60000;

var
  sum, sump: mp_int;
  Radix: mp_digit;
  rw,ndigits: word;
{$ifdef VirtualPascal}
  err: longint;
{$else}
  {$ifdef FPC}
    err: longint;
  {$else}
    err: integer;
  {$endif}
{$endif}
begin


  if pos('?', paramstr(1))>0 then begin
    writeln('Usage: T_PI [<number of digits>] [<radix>] [<noprint>]');
    halt;
  end;

  {
  if MP_DIGIT_BIT<13 then begin
    writeln('MP_DIGIT_BIT<13');
    halt;
  end;
  }
  rw := 10;

  mp_init2(sum,sump);

  val(paramstr(1),ndigits,err);
  if (err<>0) or (ndigits>MPD) then ndigits := 70;

  if paramcount>1 then begin
    val(paramstr(2),rw,err);
    if (err<>0) or (rw>MaxRadix) or (rw<2) then rw := 10;
  end;

  Radix := mp_digit(rw);

  if MP_DIGIT_BIT<13 then begin
    {pi = 8*arctan(1/3) + 4*arctan(1/7)}        {Perf: 5.42}
    mp_arctan(8, 3, Radix, ndigits, sum);
    mp_arctan(4, 7, Radix, ndigits, sump);
    mp_add(sum, sump, sum);
  end
  else if MP_DIGIT_BIT<16 then begin
    {pi = 20*arctan(1/7) + 8*arctan(1/43)+ 8*arctan(1/68)}    {2.34}
    mp_arctan(20, 7, Radix, ndigits, sum);
    mp_arctan(8, 43, Radix, ndigits, sump);
    mp_add(sum, sump, sum);
    mp_arctan(8, 68, Radix, ndigits, sump);
    mp_add(sum, sump, sum);
  end
  else begin
    {pi = 16 * arctan(1/5) - 4 * arctan(1/239)}     {1.85}
    mp_arctan(16, 5, Radix, ndigits, sum);
    mp_arctan(4, 239, Radix, ndigits, sump);
    mp_sub(sum, sump, sum);
  end;

  {Write the output}
  if paramcount<3 then begin
    mp_output_radix(sum, Radix);
    writeln;
  end;

  mp_clear2(sum,sump);

  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}

end.

