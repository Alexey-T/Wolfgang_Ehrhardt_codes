{Test program for mp library, (c) W.Ehrhardt 2016}

program t_carmic;


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
  hrtimer,
  mp_prime, mp_base,
  mp_types;

{$ifdef BIT16}
const
  N_MAX = 10000000;
{$else}
const
  N_MAX = 1000000000; {MaxLongint}
{$endif}

var
  cnt,n: longint;
  b,w,i: longint;
  FR: TFactors32;
  HR: THRTimer;

begin
  writeln('Test of MP library version ', MP_VERSION, '   (c) W.Ehrhardt 2016');
  writeln('Compute Carmichael numbers up to ',N_MAX);
  writeln;
  writeln('#cnt (number) (smallest SPSP) (smallest non-SPSP) (prime factorization)');
  writeln;
  cnt := 0;
  StartTimer(HR);
  for n:=1 to N_MAX do begin
    if is_carmichael32(n) then begin
      inc(cnt);
      b := 0;
      w := 0;
      for i := 2 to n-1 do begin
        if is_spsp32(n,i) then begin
          if b=0 then b := i
        end
        else begin
          if w=0 then w := i;
        end;
        if (b>0) and (w>0) then break;
      end;
      PrimeFactor32(n, FR);
      write(cnt:4, n:12, b:8, w:4, ':  ');
      with FR do begin
        for i:=1 to pcount do begin
          if i>1 then write(' * ');
          write(primes[i]);
          if pexpo[i]>1 then begin
            writeln('Err expo > 1');
            halt;
          end;
        end;
      end;
      writeln;
    end;
  end;
  writeln('Time [s]: ',ReadSeconds(HR):1:3);
end.
