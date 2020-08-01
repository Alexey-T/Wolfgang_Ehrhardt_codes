{-Test prog for mp_int, we Mar.2006, calculates pi with arctan formula}

program t_piw;

{$i STD.INC}
{$i mp_conf.inc}

{$ifdef APPCONS}
  {$apptype console}
{$endif}


uses {$ifdef WINCRT} WinCRT, {$endif}
     mp_types, mp_base, mp_supp;


{ Compute pi to max 64000 digits with arctan Machin type formula
  pi = 48*arctan(1/18) + 32*arctan(1/57) - 20*arctan(1/239)     }

const
  MPD   = 64000;

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
    writeln('Usage: T_PIW [<number of digits>] [<radix>] [<noprint>]');
    halt;
  end;

  mp_init2(sum,sump);
  if mp_error<>MP_OKAY then begin
    writeln('Error return from mp_init2(sum,sump)');
    halt;
  end;

  rw := 10;
  val(paramstr(1),ndigits,err);
  if (err<>0) or (ndigits>MPD) then ndigits := 70;

  if paramcount>1 then begin
    val(paramstr(2),rw,err);
    if (err<>0) or (rw>MaxRadix) or (rw<2) then rw := 10;
  end;

  Radix := mp_digit(rw);

  {pi = 48*arctan(1/18) + 32*arctan(1/57) - 20*arctan(1/239)}  {Perf 1.79}
  mp_arctanw(48, 18, Radix, ndigits, sum);
  mp_arctanw(32, 57, Radix, ndigits, sump);
  mp_add(sum, sump, sum);
  mp_arctanw(20, 239, Radix, ndigits, sump);
  mp_sub(sum, sump, sum);

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

