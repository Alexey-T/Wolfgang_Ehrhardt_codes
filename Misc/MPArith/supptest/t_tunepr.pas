{Test program for mp library: tune mp_primor_cutoff, (c) W.Ehrhardt 2007}

program t_tunepr;


{$i STD.INC}
{$i mp_conf.inc}

{$x+}  {pchar I/O}
{$i+}  {RTE on I/O error}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

{$ifndef FPC} {$N+} {$endif}

uses
  {$ifdef WINCRT} WinCRT, {$else} CRT, {$endif}
  hrtimer,
  mp_types, mp_base,
  {$ifdef MPC_Diagnostic}
    mp_supp,
  {$endif}
  mp_numth,mp_prng;

var
  a,b: mp_int;
  HR: THRTimer;


{---------------------------------------------------------------------------}
procedure primor(i, cut: longint; var a: mp_int);
  {-primorial with mp_primor_cutoff := cut}
begin
  mp_primor_cutoff := cut;
  mp_primorial(i,a);
end;



{---------------------------------------------------------------------------}
function getiter(i: longint): longint;
  {-get iteration count for total recursive call calibrated to at most 0.2s}
var
  j: longint;
begin
  RestartTimer(HR);
  j:=0;
  repeat
    inc(j);
    primor(i,1,a);
  until ReadSeconds(HR)>0.2;
  getiter := j;
end;

var
  i,j,bs,jmax: longint;
  t1,tm,q1,q0,f: double;
  lf: text;


begin
  mp_init2(a,b);
  StartTimer(HR);
  writeln('Test of MPArith V', MP_VERSION, ' [mp_primorial]   (c) W.Ehrhardt 2007');
  writeln('Karatsuba  cutoffs: mul/sqr = ',mp_mul_cutoff,'/',mp_sqr_cutoff);
  writeln('Toom-3, BZ cutoffs: mul/sqr = ',mp_t3m_cutoff,'/',mp_t3s_cutoff,  ',  div = ',mp_bz_cutoff);
  writeln('Tune mp_primor_cutoff, recursive function calibrated to about 0.2s');
{---------------------------------------------------------------------------}

  assign(lf,'primor.log');
  rewrite(lf);

  i := 2;
  f := 1.3;
  q0 := 0;

  writeln(' n':10,'bits(n#)':10,'equal':8,'rec[s]':10,'iter[s]':10,'i/r':7);
  writeln(lf, ' n':10,'bits(n#)':10,'equal':8,'rec[s]':10,'iter[s]':10,'i/r':7);
  while (i<=MaxPrimorial) and (i>0) do begin
    jmax := getiter(i);
    RestartTimer(HR);
    for j:=1 to jmax do primor(i, 1, a);
    t1 := ReadSeconds(HR);
    RestartTimer(HR);
    for j:=1 to jmax do primor(i, MaxPrimorial, b);
    tm := ReadSeconds(HR);
    bs := mp_bitsize(a);
    if t1>0.0 then q1 := tm/t1 else q1 := 0.0;
    writeln(i:10, bs:10, mp_is_eq(a,b):8, t1:10:3, tm:10:3, q1:7:2);
    writeln(lf,i:10, bs:10, mp_is_eq(a,b):8, t1:10:3, tm:10:3, q1:7:2);
    if i>=MaxPrimorial then break;
    if (q0>1.05) and (q1>q0) then break;
    if (q1>0.6) and (i>10) then f := 1.05;
    q0 := q1;
    i := round(i*f);
    if i>=MaxPrimorial then i:=MaxPrimorial;
    if keypressed and (readkey=#27) then break;
  end;

{---------------------------------------------------------------------------}
  close(lf);
  mp_clear2(a,b);
  {$ifdef MPC_Diagnostic}
     mp_dump_meminfo;
     mp_dump_diagctr;
  {$endif}

end.
