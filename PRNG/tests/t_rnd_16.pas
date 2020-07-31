{Simple test for taus88 unit, we Aug.2017}

program t_rnd_16;

{$i STD.INC}

{$ifdef BIT16}
  {$N+}
{$endif}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT}
     wincrt,
  {$endif}
  hrtimer,
  taus88;

{$ifdef BIT16}
const
  NMAX = 5000000;
{$else}
const
  NMAX = 100000000;
{$endif}

var
  n: longint;
  rng: taus88_ctx;
  HR: THRTimer;
  cps,sec: double;
begin
  writeln('Test for taus88 unit: ', NMAX, ' taus88_next calls     (c) 2017 W.Ehrhardt');
  writeln('Selftest: ', taus88_selftest);
  taus88_init(rng,1);
  StartTimer(HR);
  for n:=1 to NMAX do begin
    taus88_next(rng);
  end;
  sec := readseconds(HR);
  cps := NMAX/sec;
  writeln('Done. Time ', sec:1:3, 's,  calls/sec ', cps:1:0);
end.
