{Part 0 of regression test for SPECFUNX unit  (c) 2010  W.Ehrhardt}

unit t_sfx0;

{$i STD.INC}

{$ifdef BIT16}
{$N+}
{$endif}

interface

var
  total_cnt, total_failed: longint;

procedure testrel(nbr, neps: integer; fx, y: extended; var cnt, failed: integer);
  {-Check if relative error |(fx-y)/y| is <= neps*eps_x, absolute if y=0}

procedure testrele(nbr: integer; eps,fx, y: extended; var cnt, failed: integer);
  {-Check if relative error |(fx-y)/y| is <= neps*eps_x, absolute if y=0}

procedure testabs(nbr, neps: integer; fx, y: extended; var cnt, failed: integer);
  {-Check if absolute error |(fx-y)| is <= neps*eps_x, equality if y=Inf}


implementation

uses
  AMath;

{---------------------------------------------------------------------------}
procedure testrel(nbr, neps: integer; fx, y: extended; var cnt, failed: integer);
  {-Check if relative error |(fx-y)/y| is <= neps*eps_x, absolute if y=0}
var
  err: extended;
begin
  if IsNan(fx) or IsNan(y) then begin
    inc(failed);
    writeln('Test ', nbr:2, ' failed, at least one value is NaN.');
  end
  else begin
    err := abs(fx-y);
    if (err<>0.0) and (y<>0.0) then err := abs(err/y);
    if err > neps*eps_x then begin
      inc(failed);
      writeln('Test ', nbr:2, ' failed, rel. error = ', err/eps_x:10:3, ' eps > ',neps, ' eps ');
      writeln('      f(x) =',fx:27, ' vs. ',y:27);
    end;
  end;
  inc(cnt);
end;


{---------------------------------------------------------------------------}
procedure testrele(nbr: integer; eps,fx, y: extended; var cnt, failed: integer);
  {-Check if relative error |(fx-y)/y| is <= neps*eps_x, absolute if y=0}
var
  err: extended;
begin
  if IsNan(fx) or IsNan(y) then begin
    inc(failed);
    writeln('Test ', nbr:2, ' failed, at least one value is NaN.');
  end
  else begin
    err := abs(fx-y);
    if (err<>0.0) and (y<>0.0) then err := abs(err/y);
    if err > eps then begin
      inc(failed);
      writeln('Test ', nbr:2, ' failed, rel. error = ', err:15, ' > ', eps:15);
      writeln('      f(x) =',fx:27, ' vs. ',y:27);
    end;
  end;
  inc(cnt);
end;


{---------------------------------------------------------------------------}
procedure testabs(nbr, neps: integer; fx, y: extended; var cnt, failed: integer);
  {-Check if absolute error |(fx-y)| is <= neps*eps_x, equality if y=Inf}
var
  err: extended;
begin
  if IsNan(fx) or IsNan(y) then begin
    inc(failed);
    writeln('Test ', nbr:2, ' failed, at least one value is NaN.');
  end
  else if IsInf(y) then begin
    if fx<>y then begin
      inc(failed);
      writeln('Test ', nbr:2, ' failed: f(x) = ', fx:1, ' <> ',y:1);
    end;
  end
  else begin
    err :=  abs(fx-y);
    if err > neps*eps_x then begin
      inc(failed);
      writeln('Test ', nbr:2, ' failed, abs. error ', err,' > ',neps, ' eps');
      writeln('      f(x) =',fx, ' vs. ',y);
    end;
  end;
  inc(cnt);
end;


end.
