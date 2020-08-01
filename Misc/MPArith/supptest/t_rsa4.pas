{Test program for mp library, (c) W.Ehrhardt 2008}
{Demo for small encryption exponent attack on raw RSA}

program t_rsa4;


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
  HRTimer,
  BTypes, mp_types, mp_base, mp_modul, mp_numth, mp_rsa;

const
  EMAX = 65;  {Max. small exponent}

{---------------------------------------------------------------------------}
procedure usage;
begin
  writeln('Usage: T_RSA4 [ee],  ee: odd RSA encryption exponent 3 <= ee <= ', EMAX);
  halt;
end;


{$ifdef debug}
const
  msg: array[0..17] of char8 = 'Sample message RSA';
{$else}
const
  msg: array[0..61] of char8 = 'Sample message for small encryption exponent attack on raw RSA';
{$endif}

const
  BS = ((8*sizeof(msg)+31) div 32)*32;

var
  c: array[1..EMAX] of mp_int;
  d: array[1..EMAX] of mp_int;
  n: array[1..EMAX] of mp_int;
  t: array[0..200] of char8;
var
  m,x,e,r: mp_int;
  HR: THRTimer;
  i,j,ee: integer;
  OK: boolean;
{$ifdef D12Plus}
  s: string;
{$else}
  s: string[10];
{$endif}

begin

  writeln('Test of MP library version ', MP_VERSION, '   (c) W.Ehrhardt 2008');
  writeln('Demo for small encryption exponent attack on raw RSA');

  s := paramstr(1);
  if s='' then ee := 3
  else begin
    if pos('?',s)>0 then usage;
    val(s,ee,i);
    if (i<>0) or (ee<3) or (ee>EMAX) or (ee and 1 = 0) then usage;
  end;

  mp_clearzero := true;

  StartTimer(HR);
  mp_init_multi(n);
  mp_init_multi(c);
  mp_init_multi(d);
  mp_init4(e,m,x,r);

  mp_set(e,ee);

  mp_os2ip(@msg, sizeof(msg), m);
  writeln('Exponent: ',ee, ',   ASCII bits: ', 8*sizeof(msg), ',   RSA bits: ',BS);
  writeln('m = $', mp_hex(m));

  write('RSA key generation: ');
  for i:=1 to EE do begin
    OK := true;
    write(' ',i);
    repeat
      {Note: The n[i] are chosen as pairwise co-prime. Otherwise if  }
      {gcd(n[i], n[j])>1, n[i] and n[j] could be factored and m could}
      {be recovered by calculating the private key and decryption.   }
      mp_rsa_keygen1(e, BS div 8, d[i], n[i]);
      for j:=1 to i-1 do begin
        mp_gcd(n[i],n[j],x);
        if not mp_is1(x) then begin
          OK := false;
          break;
        end;
      end;
    until OK;
  end;
  writeln;

  write(' Encrypt and check: ');
  for i:=1 to EE do begin
    write(' ',i);
    mp_rsaep(m, e, n[i], c[i]);
    mp_rsadp(c[i], d[i], n[i], x);
    mp_sub(x,m,x);
    if not mp_is0(x) then begin
      writeln('failed m-x = ', mp_hex(x));
      break;
    end;
  end;
  writeln;

  {Here we have e modular relations  c[i] = m^e mod n[i]}
  {1. Calculate x via CRT with x mod n[i] = c[i]}
  {2. Since m<=min(n[i)) we have m^e < product(n[i]) and therefore x=m^e}
  {3. Calculate integer root r = x^(1/e) = m}

  writeln('Start attack ...');
  StartTimer(HR);
  writeln('Calculate m^',EE,' via CRT');
  mp_crt_single(EE,n,c,x);
  writeln('Calculate ',EE,'th root');
  mp_n_root(x,EE,r);
  writeln('Time [s]: ',ReadSeconds(HR):1:3);

  writeln('r = $', mp_hex(r));
  writeln('Message recovered: ', mp_is_eq(r,m));

  mp_i2pchar(r,@t,sizeof(t));
  writeln('Message: ', t);

  mp_clear_multi(n);
  mp_clear_multi(c);
  mp_clear_multi(d);
  mp_clear4(e,m,x,r);
  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}
end.
