{Test program for mp library, (c) W.Ehrhardt 2014}
{Check if nextprime versions with and without sieve produce same results}

program t_nps;


{$i STD.INC}
{$i mp_conf.inc}

{$x+}  {pchar I/O}
{$i+}  {RTE on I/O error}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

{$ifndef FPC}
{$N+}
{$endif}

uses
  CRT,
  mp_types, mp_base, mp_numth, mp_prng, mp_supp, mp_prime;


var
  a,b,c,d,e: mp_int;
  i,k,kk,s,tb: longint;
label
  leave;
const
  IMAX = 1000;
{$ifdef BIT16}
  FAC = 4;
{$else}
  {$ifdef MP_32BIT}
    FAC = 16;
  {$else}
    FAC = 8;
  {$endif}
{$endif}

begin
  mp_random_randomize;
  mp_init5(a,b,c,d,e);
  writeln('Test of MP library version ', MP_VERSION, '   (c) W.Ehrhardt 2014');
  writeln('Check if nextprime versions with and without sieve produce same results.');
  
  tb := 0;
  for i:=1 to IMAX do begin
    s := round(sqrt(5+random(16380)))*FAC;
    mp_rand_bits(a,s);
    write(i:5, s:6, #13);
    if s <= 256 then kk:=5 else kk := 2;
    for k:=1 to kk do begin
      if keypressed and (readkey=#27) then goto leave;
      inc(tb, mp_bitsize(a));
      mp_inc(a);
      mp_copy(a,b);
      mp_copy(a,c);
      s_mp_nextprime_sieve(false,b);
      mp_nextprime_ex(c, mp_digit(MP_DIGIT_MAX and $3FFF));
      if mp_is_ne(c,b) then begin
        writeln('*** Difference found ***');
        writeln('a',mp_adecimal(a));
        writeln('b',mp_adecimal(b));
        writeln('c',mp_adecimal(c));
        goto leave;
      end;
      mp_exch(c,a);
    end;
  end;
leave:
  writeln;
  writeln('Total bitsize: ',tb);
  mp_clear5(a,b,c,d,e);
  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}
end.
