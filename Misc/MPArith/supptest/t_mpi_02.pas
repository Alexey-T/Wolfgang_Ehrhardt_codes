{-Test prog for MP Lib V0.3+, we 26.08.04}
{ test mp_xxx_int}

program t_mpi_02;

{$i STD.INC}

{$i+}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses {$ifdef WINCRT} WinCRT, {$endif}
     mp_types, mp_base, mp_supp;

{.$i mp_conf.inc}

var
  a,b: mp_int;
  i: integer;
  l,g: longint;
  s: shortint;

begin
  writeln('Test of MP Lib Version ', MP_VERSION);
  mp_init_set_int(a,-100000000);
  mp_init_set_int(b,1);

  for i:=1 to 20 do begin
    mp_mul(b,a,b);
    writeln('b=',mp_decimal(b));
  end;

  l := -MaxLongint;
  mp_set_int(a,l);
  g:=mp_get_int(a);
  if g<>l then begin
    writeln(l:10, g:10);
    halt;
  end;

  l := MaxLongint;
  mp_set_int(a,l);
  g:=mp_get_int(a);
  if g<>l then begin
    writeln(l:10, g:10);
    halt;
  end;

  l := Longint($80000000);
  mp_set_int(a,l);
  g:=mp_get_int(a);
  writeln('l=',l);
  writeln('a=',mp_decimal(a));
  writeln('g=',g);

  for s:=low(shortint) to high(shortint) do begin
    mp_set_short(a,s);
    g:=mp_get_int(a);
    if g<>s then begin
      writeln(s:5, g:10);
      halt;
    end;
    {$ifdef VirtualPascal}
      {Serious VP Bug!!!}
      if s= high(shortint) then break;
    {$endif}
  end;


  for l:=-$2000000 to $2000000 do begin
    if l and $1FFFFF=0 then write('ø');
    mp_set_int(a,l);
    g:=mp_get_int(a);
    if g<>l then begin
      writeln(l:10, g:10);
      halt;
    end;
  end;

  writeln;
  mp_clear(a);
  mp_clear(b);

  mp_dump_meminfo;

end.

