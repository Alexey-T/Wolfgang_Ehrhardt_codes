{Test program for MPArith, (c) W.Ehrhardt 2012}
{complete check and bench for icbrt32}

program t_icbrt;


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
  HRTimer,
  mp_types,mp_base;

{$ifdef bit16}
  {$ifdef debug}
    const
      MaxI = MaxLongint div 100;
      Mask = $FFFFF;
  {$else}
    const
      MaxI = MaxLongint-794648;
      Mask = $FFFFFF;
  {$endif}
{$else}
  const
    MaxI = MaxLongint-794648;
    Mask = $FFFFFF;
{$endif}


var
  HR: THRTimer;
  glob: longint;


{---------------------------------------------------------------------------}
function xcbrt(n: longint): longint;
  {-Return the cube root of x}
var
  x,y: double;
begin
  x := abs(n);
  if x<1.5 then xcbrt := n
  else begin
    y := exp(ln(x)/3.0);
    {perform one Newton step}
    y := y - (y - x/sqr(y))/3.0;
    if n>0 then xcbrt := trunc(y)
    else xcbrt := -trunc(y);
  end;
end;


{---------------------------------------------------------------------------}
procedure testlarge;
var
  n,i,x: longint;
begin
  writeln('Test icbrt32 (large arguments)');
  for n:=MaxLongint downto MaxLongint-794648 do begin
     i := icbrt32(n);
     x := xcbrt(n);
     if i<>x then begin
       writeln('Error: ',n:15, i:15, x:15);
       halt;
     end;
  end;
end;


{---------------------------------------------------------------------------}
procedure test(max: longint);
var
  n,s,t,x: longint;
begin
  writeln('Test icbrt32');
  for n:=max downto 0 do begin
    s := icbrt32(n);
    x := s+1;
    t := s*sqr(s);
    if (t>n) or (x*sqr(x)<=n) then begin
      writeln('Failed: n s ',n, '  ',s);
      halt;
    end;
    if n and Mask = 0 then write(n:12,#13);
  end;
  writeln('Done - no failure.');
  writeln;
end;


{---------------------------------------------------------------------------}
procedure bench(max: longint);
var
  n: longint;
begin
  writeln('Bench icbrt32');
  RestartTimer(HR);
  for n:=0 to max do glob := icbrt32(n);
  writeln('Time [s]: ',ReadSeconds(HR):1:3);
  if glob<0 then writeln;
  writeln;
end;

begin
  writeln('MPArith V',MP_ShortVERS, ': Complete check and bench for icbrt32  (c) W.Ehrhardt 2012');
  testlarge;
  test(maxi);
  if paramcount>0 then begin
    StartTimer(HR);
    bench(maxi);
  end;
end.
