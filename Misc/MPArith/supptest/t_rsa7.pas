{Test program for MPArith, (c) W.Ehrhardt 2014}
{Factor RSA modulus with Fermat}

program t_tf;


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
  {$ifdef MPC_Diagnostic}
    mp_supp,
  {$endif}
  hrtimer,
  mp_types, mp_base, mp_pfu;

var
  a,b,c,d,n: mp_int;
  HR: THRTimer;


{---------------------------------------------------------------------------}
procedure test1;
  {-Factor n with Fermat}
begin
  RestartTimer(HR);
  writeln('n=',mp_decimal(n));
  mp_fermat_factor(n,a,1000);
  if mp_is0(a) then writeln('* No factor found')
  else begin
    writeln('Time [s]: ',ReadSeconds(HR):1:3);
    mp_divrem(n,a,@b,@c);
    if not mp_is0(c) then writeln('* Internal error n mod p <> 0')
    else begin
      writeln('p=', mp_decimal(a));
      writeln('q=', mp_decimal(b));
      mp_mul(a,b,c);
      mp_sub(c,n,d);
      writeln('n - p*q = ', mp_decimal(d));
    end;
  end;
end;

begin
  StartTimer(HR);
  mp_init5(a,b,c,d,n);
  writeln('----------------------------------------------------------------------------');
  writeln('Test of MP library version ', MP_VERSION, '   (c) W.Ehrhardt 2014');
  writeln('*** Check bad RSA moduli with Fermat factorization ***');

  {--------------------------------------------------------}
  writeln;
  writeln('Example 1 (from math.stackexchange):');
  {http://math.stackexchange.com/questions/863225/powermod-solving-for-the-base}
  mp_read_decimal(n,'152415787532388368909312594615759791673');
  test1;

  {--------------------------------------------------------}
  writeln;
  writeln('Example 2:');
  mp_read_decimal(n,'1606938044258990275541962091078582604694884852567413570404019');
  test1;

  {--------------------------------------------------------}
  writeln;
  writeln('Example 3:');
  mp_read_decimal(n,'4131599804939053743449470675204818998927529268526869847010801'+
                    '2978726014194113323289259404997966112092019307499445413028793');
  test1;

  {--------------------------------------------------------}
  writeln;
  writeln('Example 4:');
  mp_read_decimal(n,'1248699420126396892552638891917266522299439257065988460343673848955150555'+
                    '2173566050893992593875210581444896438235703831373366024894920628068974479');
  test1;

  mp_clear5(a,b,c,d,n);
  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}
end.
