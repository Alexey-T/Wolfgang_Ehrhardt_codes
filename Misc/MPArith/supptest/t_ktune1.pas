program t_ktune1;

{Approach to tune Karatsuba cutoffs, uses HRTimer unit}
{Not very stable for FPC, VPC}

{$i STD.INC}

{$ifndef FPC}
  {$N+}
{$endif}

{$x+}  {pchar I/O}
{$i+}  {RTE on I/O error}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses CRT, hrtimer,
     mp_types, mp_base, mp_prng;

{$ifdef BIT16}
const
  LOOP = 1 shl 8;
{$else}
const
  LOOP = 1 shl 10;
{$endif}

var
  HR: THRTimer;

var
  a,b,c: mp_int;

var
  seed0: longint;
  abort: boolean;

{---------------------------------------------------------------------------}
function time_mul(size,s: word): comp;
var
  x: longint;
begin
  mp_rand(a, size+1);
  mp_rand(b, size+1);
  if s=1 then mp_mul_cutoff := size else mp_mul_cutoff:=30000;
  StartTimer(HR);
  for x:=1 to LOOP do mp_mul(a,b,c);
  time_mul := Readcycles(HR);
end;

{---------------------------------------------------------------------------}
function time_sqr(size,s: word): comp;
var
  x: longint;
begin
  mp_rand(a, size+1);
  if s=1 then mp_sqr_cutoff := size else mp_sqr_cutoff:=30000;
  StartTimer(HR);
  for x:=1 to LOOP do mp_sqr(a,b);
  time_sqr := Readcycles(HR);
end;


{---------------------------------------------------------------------------}
procedure tune;
const
  MD = 3;
var
  t1, t2: comp;
  t1a, t2a: array[1..MD+1] of comp;
  i,ic: integer;
  done: boolean;
  imul,isqr: word;
  seed:longint;
begin
  abort := true;
  imul := 8;
  for i:=1 to MD do begin
    t1a[i] := 0;
    t2a[i] := 0;
  end;
  ic := 0;
  writeln('CutOff':6, 'cyc std mul':16, 'cyc Kara mul':16, 'Kara - std':16);
  while imul<30000 do begin
    inc(ic);
    seed := seed0+imul;
    mp_random_seed(seed);
    t1 := time_mul(imul, 0);
    mp_random_seed(seed);
    t2 := time_mul(imul, 1);
{$ifdef BIT64}
    writeln(imul:6, t1:16, t2:16, t2-t1:16);
{$else}
    writeln(imul:6, t1:16:0, t2:16:0, t2-t1:16:0);
{$endif}
    t1a[MD+1] := t1;
    t2a[MD+1] := t2;
    done := true;
    for i:=1 to MD do begin
      t1a[i] := t1a[i+1];
      t2a[i] := t2a[i+1];
      done := done and (t1a[i]>t2a[i]);
    end;
    if keypressed and (readkey=#27) then exit;
    if (ic>=MD) and done then break;
    inc(imul,2);
  end;

  isqr := 8;
  for i:=1 to MD do begin
    t1a[i] := 0;
    t2a[i] := 0;
  end;
  ic := 0;
  writeln('CutOff':6, 'cyc std sqr':16, 'cyc Kara sqr':16, 'Kara - std':16);
  while isqr<30000 do begin
    inc(ic);
    seed := seed0+isqr;
    mp_random_seed(seed);
    t1 := time_sqr(isqr, 0);
    t2 := time_sqr(isqr, 1);
{$ifdef BIT64}
    writeln(isqr:6, t1:16, t2:16, t2-t1:16);
{$else}
    writeln(isqr:6, t1:16:0, t2:16:0, t2-t1:16:0);
{$endif}
    t1a[MD+1] := t1;
    t2a[MD+1] := t2;
    done := true;
    for i:=1 to MD do begin
      t1a[i] := t1a[i+1];
      t2a[i] := t2a[i+1];
      done := done and (t1a[i]>t2a[i]);
    end;
    if keypressed and (readkey=#27) then exit;
    if (ic>=MD) and done then break;
    inc(isqr,2);
  end;
  abort := false;

end;

begin

  writeln('T_KTune  - Tune Karatsuba cutoffs    (c) 2005  W.Ehrhardt');
  writeln('Test of MP Lib Version ', MP_VERSION);

  mp_t3m_cutoff := 30000;
  mp_t3s_cutoff := 30000;

  mp_init(a);
  mp_init(b);
  mp_init(c);

  randomize;
  seed0 := randseed;

  if mp_error=0 then tune;
  if not abort then begin
    writeln('Karatsuba mul cutoff: ',mp_mul_cutoff);
    writeln('Karatsuba sqr cutoff: ',mp_sqr_cutoff);
  end;

  mp_clear(a);
  mp_clear(b);
  mp_clear(c);

end.

