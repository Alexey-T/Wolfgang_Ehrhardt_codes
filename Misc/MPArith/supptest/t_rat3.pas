{Test program rational rounding/read_double, (c) W.Ehrhardt 2007}

program t_rat3;


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
  {$ifdef WINCRT}
    WinCRT,
  {$endif}
  BTypes, hrtimer,
  mp_types, mp_base,
  {$ifdef MPC_Diagnostic}
    mp_supp,
  {$endif}
  mp_numth,mp_prng,mp_ratio;

var
  a,b,c,d,e: mp_int;
  r,w,x,y,z: mp_rat;
  HR: THRTimer;

procedure check(s: pchar8);
begin
  mpr_read_decimal(r,s);
  writeln('****** r = ', mpr_decimal(r));
  mpr_floor(r,a);
  writeln('floor(r) = ', mp_decimal(a));
  mpr_ceil(r,a);
  writeln('ceil(r)  = ', mp_decimal(a));
  mpr_trunc(r,a);
  writeln('trunc(r) = ', mp_decimal(a));
  mpr_round(r,a);
  writeln('round(r) = ', mp_decimal(a));
  mpr_frac(r,w);
  writeln('frac(r)  = ', mpr_decimal(w));
end;


procedure t_read_double;
const
  EpsDbl = 2.220446049250313E-16;   { 2^(-52) }
  MaxDbl = 1.797693134862315E+308;  { 2^1024 }
  MinDbl = 2.225073858507202E-308;  { 2^(-1022) }
var
  i,e: integer;
  h: double;
  procedure onetest(d: double);
  var
    g: double;
  begin
    mpr_read_double(r,d);
    g := mpr_todouble(r);
    if abs(d-g)>EpsDbl*abs(d) then begin
      writeln('d=',d, '    g=',g);
    end;
  end;
begin
  onetest(0.0);
  onetest(EpsDbl);
  onetest(MaxDbl);
  onetest(MinDbl);
  onetest(-EpsDbl);
  onetest(-MaxDbl);
  onetest(-MinDbl);
  for i:=1 to 100 do begin
    h := random-0.5;
    e := random(2040);
    h := ldexpd(h,e-1020);
    onetest(h);
  end;
end;

begin
  mp_random_randomize;
  StartTimer(HR);
  mp_init5(a,b,c,d,e);
  mpr_init5(r,w,x,y,z);

  writeln('Test of MP library version ', MP_VERSION, '   (c) W.Ehrhardt 2007');

{---------------------------------------------------------------------------}

  {
  mp_roundfloat := true;
  mpr_read_decimal(r,'-3/2');
  writeln(mpr_tofloat_str(r, 10, 1));
  }

  check('5/1');
  check('-5/1');

  check('5/3');
  check('-5/3');

  check('2/5');
  check('-2/5');

  check('1/6');


  mpr_read_float_decimal(r,'3.1415');
  writeln(mpr_decimal(r));
  mp_roundfloat := true;
  {$ifdef BIT32or64}
    writeln(mpr_tofloat_astr(r,10,3));
  {$else}
    writeln(mpr_tofloat_str(r,10,3));
  {$endif}

  t_read_double;

{---------------------------------------------------------------------------}
  writeln('Time [s]: ',ReadSeconds(HR):1:3);
  mpr_clear5(r,w,x,y,z);
  mp_clear5(a,b,c,d,e);
  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}
end.
