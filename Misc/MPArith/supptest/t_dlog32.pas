{Test program for MPArith/dlog32, (c) W.Ehrhardt 2014}

program t_dlog32;

{$i STD.INC}
{$i mp_conf.inc}

{$i+}  {RTE on I/O error}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

{$ifndef FPC}
{$N+}
{$endif}

uses
  {$ifdef WINCRT}
    WinCRT,
  {$endif}
  {$ifdef MPC_Diagnostic}
    mp_supp,
  {$endif}
  mp_types, mp_base, mp_prime, mp_prng;

{$ifdef BIT16}
const
  n1 = 300;
  n2 = 4000;
  fn = 2.25;
  km = 200;
{$else}
const
  n1 = 700;
  n2 = 8000;
  fn = 1.75;
  km = 400;
{$endif}

var
  x,y,n,g,b,k,f: longint;
  rs: longint;
  pr: boolean;
begin
  writeln('Test of MPArith V', MP_VERSION, '  [dlog32]  (c) W.Ehrhardt 2014');
  n := 1;
  f := 0;

  randomize;
  {randseed := 73271230;}
  rs := randseed;
  mp_random_seed(rs);

  writeln('Complete test for all primitive roots:');
  while n < n1 do begin
    n := safeprime32(n+1);
    writeln(' n=',n);
    x := (n-1) div 2;
    for g:=2 to n-2 do begin
      if exptmod32(g,x,n)=n-1 then begin
        {g is primitive root}
        for b:=1 to n-1 do begin
          x := dlog32(g,b,n);
          y := exptmod32(g,x,n);
          if y<>b then begin
            writeln(x:12, y:12, b:10, g:8);
            inc(f);
          end;
        end;
      end;
    end;
  end;

  writeln('Complete test a random primitive root:');
  while n < n2 do begin
    n := safeprime32(n+1);
    x := (n-1) div 2;
    {look for random primitive root}
    for k:=1 to 5 do begin
      g := 2 + random(n-3);
      if exptmod32(g,x,n)=n-1 then break;
      g := 0;
    end;
    if g=0 then g := primroot32(n);
    writeln(' n=',n, '  g=',g);

    for b:=1 to n-1 do begin
      x := dlog32(g,b,n);
      y := exptmod32(g,x,n);
      if y<>b then begin
        writeln(x:12, y:12, b:10, g:8);
        inc(f);
      end;
    end;
  end;

  writeln('Recover ',km,' random powers for each safe prime:');
  while n<1073741824 do begin
    n := safeprime32(round(fn*n)+42);
    writeln(' n=',n);
    g := 2 + mp_random_long mod (n-3);
    for k:=1 to km do begin
      b := exptmod32(g,2 + mp_random_long mod (n-3),n);
      x := dlog32(g,b,n);
      y := exptmod32(g,x,n);
      if y<>b then begin
        pr := exptmod32(g,(n-1) div 2,n)=n-1;
        writeln(x:12, y:12, b:10, g:8, pr:8);
        inc(f);
      end;
    end;
  end;

  writeln('Recover ',km,' prime root powers for each prime:');
  n := MaxLongint div 256;
  while n < MaxLongint div 3 do begin
    n := nextprime32(round(n*fn));
    writeln(' n=',n);
    {look for random primitive root}
    for k:=1 to 5 do begin
      g := 2 + mp_random_long mod (n-3);
      if is_primroot32(g,n) then break;
      g := 0;
    end;
    if g=0 then g := primroot32(n);
    for k:=1 to km do begin
      b := exptmod32(g,2 + mp_random_long mod (n-3),n);
      x := dlog32(g,b,n);
      y := exptmod32(g,x,n);
      if y<>b then begin
        writeln(x:12, y:12, b:10, g:8);
        inc(f);
      end;
    end;
  end;

  if f>0 then writeln('Failed ',f,'   start randseed = ', rs)
  else writeln('Done. No failures found.');

  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}
end.
