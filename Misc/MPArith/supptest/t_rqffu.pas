{Test program for mp library, (c) W.Ehrhardt 2016}
{Fundamental units of Q(sqrt(n)), n<2^31         }

program t_rqffu;

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
  mp_types, mp_base, mp_numth, mp_prime;

var
  a,b,c: mp_int;
  n,d: longint;

begin
  mp_init3(a,b,c);
  writeln('Test of MP library version ', MP_VERSION, '   (c) W.Ehrhardt 2016');
  writeln('Fundamental units of Q(sqrt(n)), n<2^31');
{---------------------------------------------------------------------------}
  repeat
    write('Enter n (exit with n<=0): ');
    readln(n);
    if n<=0 then break;
    n := core32(n);
    case n and 3 of
        0: d := 0;
        1: d := n;
      else d := 4*n;
    end;
    if (d=0) or (mp_rqffu(d,a,b)=0) then writeln('Error: invalid d')
    else begin
      write('e = ');
      if n and 3 = 1 then begin
        if mp_iseven(a) then begin
          mp_shr1(a);
          write(mp_adecimal(a));
        end
        else write(mp_adecimal(a),'/2');
        write(' + ');
        if mp_iseven(b) then begin
          mp_shr1(b);
          write(mp_adecimal(b));
        end
        else write(mp_adecimal(b),'/2');
      end
      else begin
        if mp_iseven(a) then mp_shr1(a);
        write(mp_adecimal(a));
        write(' + ');
        write(mp_adecimal(b));
      end;
      writeln(' * sqrt(',n,')');
    end;
  until false;
{---------------------------------------------------------------------------}
  mp_clear3(a,b,c);
end.
