{Test program for mp library, (c) W.Ehrhardt 2017}

program t_lpsp;


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
  hrtimer, mp_types, mp_base, mp_numth, mp_prime;

var
  a,b,c,d,e: mp_int;
  i: longint;
  HR: THRTimer;


{$ifdef BIT64}
const
  IMAX = 100000000;
{$else }
  {$ifdef BIT32}
  const
    IMAX = 10000000;
  {$else }
  const
    IMAX = 1000000;
  {$endif}
{$endif}

var
  ts,tn: text;

begin
  mp_init5(a,b,c,d,e);
  writeln('Test of MP library version ', MP_VERSION, '   (c) W.Ehrhardt 2017');
  writeln('List of (strong) Lucas pseudo primes up to ',IMAX);
  assign(ts,'~slpsp.txt');
  rewrite(ts);
  assign(tn,'~lpsp.txt');
  rewrite(tn);
  StartTimer(HR);
  for i:=3 to IMAX do begin
    if odd(i) and not isprime32(i) then begin
      mp_set_int(a,i);
      if s_mp_is_lpsp(a, false) then begin
        write(i);
        writeln(tn, i);
        if s_mp_is_lpsp(a, true) then begin
          write('    S');
          writeln(ts, i);
        end;
        writeln;
      end;
    end;
  end;
  close(ts);
  close(tn);
  writeln('Time [s]: ',ReadSeconds(HR):1:3);
  writeln('Tables written to ~lpsp.txt and ~slpsp.txt');
  mp_clear5(a,b,c,d,e);
end.
