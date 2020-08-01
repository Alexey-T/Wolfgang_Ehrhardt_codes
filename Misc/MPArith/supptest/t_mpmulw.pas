{Test program for mp_mul_w, (c) W.Ehrhardt 2004-2006}

program t_mpmulw;


{$i STD.INC}
{$i mp_conf.inc}

{$i+}  {RTE on I/O error}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

{$ifndef FPC} {$N+} {$endif}

uses CRT,
     hrtimer,
     mp_types, mp_base,
     {$ifdef MPC_Diagnostic}
       mp_supp,
     {$endif}
     mp_numth,mp_prng;

{$ifdef BIT32or64}
const
  IMAX=200;
{$else}
const
  IMAX=50;
{$endif}

var
  a,b,c,d,e: mp_int;
  err: boolean;
  i,digs: integer;
  w: word;
  mwc: longint;
begin
  mp_init5(a,b,c,d,e);
  writeln('Test of MPArith V', MP_VERSION, '   (c) W.Ehrhardt 2005');
  writeln('Karatsuba cutoffs: mul/sqr = ',mp_mul_cutoff,'/',mp_sqr_cutoff);
{---------------------------------------------------------------------------}
  err := false;
  mwc := 0;
  for digs:=1 to 200 do begin
    if digs mod 10 = 0 then write(digs,#13);
    if (err) or (keypressed and (readkey=#27)) then break;
    for i:=1 to IMAX do begin
      mp_rand(a,digs);
      w := mp_random_word;
      mp_set_w(b,w);
      mp_set_int(c,w);
      mp_mul_w(a,w,d); inc(mwc);
      mp_mul(a,c,e);
      if mp_is_ne(d,e) then begin
        writeln;
        write('Error w=',w,'  a=');
        mp_output_decimal(a);
        writeln;
        err := true;
        break;
      end;
    end;
  end;
{---------------------------------------------------------------------------}
  mp_clear5(a,b,c,d,e);
  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}
  writeln(' mp_mul_w count: ', mwc);
end.
