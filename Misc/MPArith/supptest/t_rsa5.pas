{Test program for MPArith [mp_rsa_wiener], (c) W.Ehrhardt 2009}
{Wiener's attack on small RSA secret exponents: Recover p,q,d from e,n}

program t_rsa5;

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
  mp_types, mp_base, mp_modul, mp_prng, mp_numth, mp_rsa;

var
  n,d,e,p,q,m,t,g: mp_int;
  HR: THRTimer;
  fail: boolean;

{$ifdef BIT32or64}
const
  osize = 128;
{$else}
const
  osize = 64;
{$endif}


const
  usephi: boolean = false;
var
  ms: string[10];
begin
  StartTimer(HR);

  writeln('Test of MPArith V', MP_VERSION, ' [mp_rsa_wiener]   (c) W.Ehrhardt 2009');
  writeln('Karatsuba  cutoffs: mul/sqr = ',mp_mul_cutoff,'/',mp_sqr_cutoff);
  writeln('Toom-3, BZ cutoffs: mul/sqr = ',mp_t3m_cutoff,'/',mp_t3s_cutoff,  ',  div = ',mp_bz_cutoff);

{---------------------------------------------------------------------------}

  mp_clearzero := true;
  mp_random_randomize;
  mp_init8(n,d,e,p,q,m,t,g);

{$ifdef MPC_Trace}
  mp_verbose := 2;
{$endif}

  RestartTimer(HR);

  mp_rand_bits(d, osize*2-2);  {<n^0.25/4: recovery should never fail if usephi}
  mp_nextprime(d);
  writeln(mp_decimal(d));

  writeln('*** Prime generation');
  mp_rsa_calc_npq(d,osize,n,p,q);

  {calc e=d^-1 mod phi or lam}
  mp_sub_d(p,1,m);
  mp_sub_d(q,1,t);
  mp_gcd(m,t,g);

  if usephi then begin
    mp_mul(m,t,m);
    ms := 'phi';
  end
  else begin
    mp_lcm(m,t,m);
    ms := 'lambda';
  end;
  mp_invmod(d,m,e);
  mp_mulmod(e,d,m,t);

  writeln('Time [s]: ',ReadSeconds(HR):1:3, ',   bit size n = ', mp_bitsize(n));
  mp_writeln('p = ',p);
  mp_writeln('q = ',q);
  mp_writeln('n = ',n);
  mp_writeln('e = ',e);
  mp_writeln('d = ',d);
  mp_writeln(ms+' = ',m);
  mp_writeln('e*d mod '+ms+' = ',t);
  mp_writeln('gcd(p-1,q-1) = ', g);

  writeln('Running Wiener algorithm (mp_rsa_wiener)');
  RestartTimer(HR);
  mp_rsa_wiener(e,n,m,t,g,fail);
  writeln('Time [s]: ',ReadSeconds(HR):1:3);
  if not fail then begin
    if mp_is_eq(p,m) and mp_is_eq(q,t) and mp_is_eq(d,g) then writeln('Recovered p,q,d')
    else fail := true;
  end;
  if fail then begin
    writeln('** Recovery failed:'#7);
  end;

{---------------------------------------------------------------------------}
  mp_clear8(n,d,e,p,q,m,t,g);
  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}
end.
