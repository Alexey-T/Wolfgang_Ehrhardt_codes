{Test program for mp library, (c) W.Ehrhardt 2008}

program t_rsa3;


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
  HRTimer,
  {$ifdef MPC_Diagnostic}
    mp_supp,
  {$endif}
   mp_types, mp_base, mp_modul, mp_rsa;

{Test values from oaep-int.txt available in}
{ftp://ftp.rsasecurity.com/pub/pkcs/pkcs-1/pkcs-1v2-1-vec.zip}

const
  pps = 'eecfae81b1b9b3c908810b10a1b5600199eb9f44aef4fda493b81a9e3d84f632'+
        '124ef0236e5d1e3b7e28fae7aa040a2d5b252176459d1f397541ba2a58fb6599';

  pqs = 'c97fb1f027f453f6341233eaaad1d9353f6c42d08866b1d05a0f2035028b9d86'+
        '9840b41666b42e92ea0da3b43204b5cfce3352524d0416a5a441e700af461503';

  ems =   'eb7a19ace9e3006350e329504b45e2ca82310b26dcd87d5c68f1eea8f55267'+
        'c31b2e8bb4251f84d7e0b2c04626f5aff93edcfb25c9c2b3ff8ae10e839a2ddb'+
        '4cdcfe4ff47728b4a1b7c1362baad29ab48d2869d5024121435811591be392f9'+
        '82fb3e87d095aeb40448db972f3ac14f7bc275195281ce32d2f1b76d4d353e2d';


var
  n,d,e,p,q,dp,dq,qinv,m,t: mp_int;
  c,m1,m2,h: mp_int;
  prk: TPrivateKey;
  HR: THRTimer;


{.$define dumpall}

procedure calc_manual_CRT;
begin
  {calulate d = e^-1 mod lcm(p-1,q-1)}
  mp_sub_d(p,1,t);
  mp_sub_d(q,1,d);
  mp_lcm(t,d,t);
  mp_invmod(e,t,d);
{$ifdef dumpall}
  write('    d = ');  mp_output_radix(d,16); writeln; writeln;
{$endif}

  mp_mul(p,q,n);
{$ifdef dumpall}
  write('    n = ');  mp_output_radix(n,16); writeln; writeln;
{$endif}

  mp_sub_d(p,1,t);
  mp_invmod(e,t,dp);
{$ifdef dumpall}
  write('   dp = ');  mp_output_radix(dp,16); writeln; writeln;
{$endif}

  mp_sub_d(q,1,t);
  mp_invmod(e,t,dq);
{$ifdef dumpall}
  write('   dq = ');  mp_output_radix(dq,16); writeln; writeln;
{$endif}

  mp_invmod(q,p,qinv);
{$ifdef dumpall}
  write(' qinv = ');  mp_output_radix(qinv,16); writeln; writeln;
  write('   em = ');  mp_output_radix(m,16); writeln; writeln;
{$endif}

  mp_exptmod(m,e,n,c);
{$ifdef dumpall}
  write(' ciph = ');  mp_output_radix(c,16); writeln; writeln;
{$endif}

  {no need to reduce c mod p, will be done implicitely in mp_exptmod}
  mp_exptmod(c,dp,p,m1);
{$ifdef dumpall}
  write('   m1 = ');  mp_output_radix(m1,16); writeln; writeln;
{$endif}

  mp_exptmod(c,dq,q,m2);
{$ifdef dumpall}
  write('   m2 = ');  mp_output_radix(m2,16); writeln; writeln;
{$endif}

  mp_submod(m1,m2,p,h);
  mp_mulmod(h,qinv,p,h);
{$ifdef dumpall}
  write('    h = ');  mp_output_radix(h,16); writeln; writeln;
{$endif}

  mp_mul(q,h,t);
  mp_add(t,m2,t);
  write(' decr = ');  mp_output_radix(t,16); writeln; writeln;
end;

begin
  StartTimer(HR);

  writeln('Test of MPArith V', MP_VERSION, '   (c) W.Ehrhardt 2008');
  writeln('Karatsuba  cutoffs: mul/sqr = ',mp_mul_cutoff,'/',mp_sqr_cutoff);
  writeln('Toom-3, BZ cutoffs: mul/sqr = ',mp_t3m_cutoff,'/',mp_t3s_cutoff,  ',  div = ',mp_bz_cutoff);

{---------------------------------------------------------------------------}

  mp_clearzero := true;
  mp_init5(n,d,e,m,t);
  mp_init5(p,q,dp,dq,qinv);
  mp_init4(c,m1,m2,h);
  mp_rsa_init_private(prk);

  mp_read_radix(p,pps,16);
  mp_read_radix(q,pqs,16);
  mp_read_radix(m,ems,16);
  mp_set(e,$11);

  RestartTimer(HR);
  writeln('*** Manual CRT');
  calc_manual_CRT;
  mp_sub(t,m,t);
  write('check = ');  mp_output_radix(t,16); writeln;
  writeln('Time [s]: ',ReadSeconds(HR):1:3);

  RestartTimer(HR);
  writeln;
  writeln('*** Without CRT');
  mp_rsadp(c,d,n,t);
  write('   dd = ');  mp_output_radix(t,16); writeln; writeln;
  mp_sub(t,m,t);
  write('check = ');  mp_output_radix(t,16); writeln;
  writeln('Time [s]: ',ReadSeconds(HR):1:3);

  RestartTimer(HR);
  writeln;
  writeln('*** mp_rsadp2');
  mp_rsa_calc_private(e, p, q, prk);
  mp_rsadp2(c,prk,t);
  write('  dp2 = ');  mp_output_radix(t,16); writeln; writeln;
  mp_sub(t,m,t);
  write('check = ');  mp_output_radix(t,16); writeln;
  writeln('Time [s]: ',ReadSeconds(HR):1:3);
{---------------------------------------------------------------------------}
  mp_clear4(c,m1,m2,h);
  mp_clear5(n,d,e,m,t);
  mp_clear5(p,q,dp,dq,qinv);
  mp_rsa_clear_private(prk);
  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}
end.
