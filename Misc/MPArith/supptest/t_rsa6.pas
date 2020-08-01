{Test program for MPArith , (c) W.Ehrhardt 2009}
{Common modulus attack on RSA}

program t_rsa6;

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
  mp_types, mp_base, mp_numth, mp_prng, mp_modul, mp_rsa;


var
  n,d,e1,e2,p,q,m,c1,c2,u,v,g,p1,p2,t: mp_int;
  HR: THRTimer;

{$ifdef BIT32or64}
const
  osize = 128;
{$else}
const
  osize = 64;
{$endif}

begin
  StartTimer(HR);

  writeln('Test of MPArith V', MP_VERSION, '   (c) W.Ehrhardt 2010');
  writeln('Karatsuba  cutoffs: mul/sqr = ',mp_mul_cutoff,'/',mp_sqr_cutoff);
  writeln('Toom-3, BZ cutoffs: mul/sqr = ',mp_t3m_cutoff,'/',mp_t3s_cutoff,  ',  div = ',mp_bz_cutoff);

{---------------------------------------------------------------------------}

  mp_clearzero := true;
  mp_random_randomize;
{  mp_random_seed1(0);}

  mp_init9(n,d,e1,e2,p,q,m,c1,c2);
  mp_init6(g,u,v,p1,p2,t);

  writeln('----------------------------');
  writeln('Common modulus attack on RSA');
  writeln('----------------------------');

  {Let n=p*q a RSA modulus, e1,e2 two public exponents with gcd(e1,e2)=1,}
  {0 <= m < n a message, c1 = m^e1 mod n, c2 = m^e2 mod n. Then m can be }
  {recovered from n,e1,e2,c1,c2. Let e1*u + e2*v = gcd(e1,e2) = 1, then  }
  {m = c1^u*c2^v mod n. Since one of u,v is negative the corresponding   }
  {cx must be inverted. In most cases gcd(cx,n)=1 and cx^-1 mod n exists,}
  {If gcd(cx,n)<>1, n can be factored and the (ex,n) system is completely}
  {broken. This will not be handled in this demo code.}

  writeln('*** Generate p,q,n,e1,e2');
  {
  mp_set_int(e1,257);
  mp_set_int(e2,65537);
  }
  {
  mp_provable_prime(osize*2, e1);
  mp_provable_prime(osize*2, e2);
  }
  RestartTimer(HR);
  mp_rand_prime(osize*2, pt_normal, e1);
  mp_rand_prime(osize*2, pt_normal, e2);
  mp_rsa_calc_npq(e1,osize,n,p,q);
  writeln('Time [s]: ',ReadSeconds(HR):1:3, ',   bit size n = ', mp_bitsize(n));
  mp_writeln('n  = ',n);
  mp_writeln('e1 = ',e1);
  mp_writeln('e2 = ',e2);

  RestartTimer(HR);
  writeln('*** Generate / encrypt messages');
  mp_rand_bits(m, osize*8-2);
  mp_exptmod(m,e1,n,c1);
  mp_exptmod(m,e2,n,c2);
  writeln('Time [s]: ',ReadSeconds(HR):1:3);
  mp_writeln('m  = ',m);
  mp_writeln('c1 = ',c1);
  mp_writeln('c2 = ',c2);

  RestartTimer(HR);
  writeln('*** Common modulus attack');
  {e1*u + e2*v = g}
  mp_xgcd(e1,e2,@u,@v,@g);
  mp_exptmod(c1,u,n,p1);
  mp_exptmod(c2,v,n,p2);
  mp_mulmod(p1,p2,n,t);
  writeln('Time [s]: ',ReadSeconds(HR):1:3);
  mp_writeln(' u = ',u);
  mp_writeln(' v = ',v);
  mp_writeln(' g = ',g);
  mp_writeln(' t = ',t);
     writeln(' t = m ? ', mp_is_eq(m,t));

{---------------------------------------------------------------------------}
  mp_clear6(g,u,v,p1,p2,t);
  mp_clear9(n,d,e1,e2,p,q,m,c1,c2);
  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}
end.
