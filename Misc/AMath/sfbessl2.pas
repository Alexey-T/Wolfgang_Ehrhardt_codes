unit sfBessl2;

{Common code for Bessel functions Part2: Airy, Kelvin, Struve, Coulomb}

interface

{$i std.inc}

{$ifdef BIT16}
{$N+}
{$endif}

{.$define S1Med_Cheb}  {Chebyshev approximations for sfc_synchf}


(*************************************************************************

 DESCRIPTION   :  Bessel functions Part2: Airy, Kelvin, Struve, Coulomb

 REQUIREMENTS  :  BP7, D2-D7/D9-D10/D12/D17-D18/D25, FPC, VP, WDOSX

 EXTERNAL DATA :  ---

 MEMORY USAGE  :  ---

 DISPLAY MODE  :  ---

 REMARK        :  Define S1Med_Cheb to use Chebyshev approximations for
                  the first synchrotron function F(x) if x < 4

 REFERENCES    :  References used in this unit, main index in amath_info.txt/references

                  [1] [HMF]: M. Abramowitz, I.A. Stegun. Handbook of Mathematical Functions, New York, 1970
                      http://www.math.sfu.ca/~cbm/aands/
                 [13] [NR]: W.H. Press et al, Numerical Recipes in C, 2nd ed., Cambridge, 1992,
                      http://www.nrbook.com/a/bookcpdf.html
                 [22] A.J. MacLeod, MISCFUN: A software package to compute uncommon special functions.
                      ACM Trans. on Math. Soft. 22 (1996), pp.288-301.
                      Fortran source: http://netlib.org/toms/757
                 [30] [NIST]: F.W.J. Olver, D.W. Lozier, R.F. Boisvert, C.W. Clark, NIST Handbook
                      of Mathematical Functions, Cambridge, 2010. Online resource: NIST Digital
                      Library of Mathematical Functions, http://dlmf.nist.gov/
                 [79] W.J. Cody, K.E. Hillstrom, Chebyshev approximations for the
                      Coulomb phase shift, Math. Comp. 24 (1970), 671-677,
                      https://doi.org/10.1090/S0025-5718-1970-0273785-4
                 [80] E.R. Barnett, Coulomb and Bessel functions,
                      http://www.fresco.org.uk/programs/barnett/index.htm

 Version  Date      Author      Modification
 -------  --------  -------     ------------------------------------------
 1.51.00  16.09.18  W.Ehrhardt  New unit with Airy/Kelvin/Struve functions from sfBessel
 1.51.01  16.09.18  we          sfc_coulcl
 1.51.02  17.09.18  we          sfc_cshift
 1.51.03  28.09.18  we          sfc_coul_ffp, sfc_coul_ggp, sfc_coul_f

 1.52.00  16.10.18  we          sfc_synchf
 1.52.01  17.10.18  we          sfc_synchg

 1.53.00  19.11.18  we          Make skp4hx/sinkp4 global
 1.53.01  19.11.18  we          sfc_kelvin_der: derivatives of all Kelvin functions
 1.53.02  20.11.18  we          Separate functions sfc_berp/beip/kerp/keip
 1.53.03  21.11.18  we          Fix NaN results in sfc_berp/beip/kerp/keip

***************************************************************************)


(*-------------------------------------------------------------------------
 (C) Copyright 2009-2018 Wolfgang Ehrhardt

 This software is provided 'as-is', without any express or implied warranty.
 In no event will the authors be held liable for any damages arising from
 the use of this software.

 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:

 1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software in
    a product, an acknowledgment in the product documentation would be
    appreciated but is not required.

 2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.

 3. This notice may not be removed or altered from any source distribution.
----------------------------------------------------------------------------*)

(*-------------------------------------------------------------------------
  This Pascal code uses material and ideas from open source and public
  domain libraries, see the file '3rdparty.ama' for the licenses.
---------------------------------------------------------------------------*)


function sfc_airy_ai(x: extended): extended;
  {-Return the Airy function Ai(x)}

function sfc_airy_aip(x: extended): extended;
  {-Return the Airy function Ai'(x)}

function sfc_airy_ais(x: extended): extended;
  {-Return the scaled Airy function Ai(x) if x <= 0, Ai(x)*exp(2/3*x^1.5) for x > 0}

function sfc_airy_bi(x: extended): extended;
  {-Return the Airy function Bi(x)}

function sfc_airy_bip(x: extended): extended;
  {-Return the Airy function Bi'(x)}

function sfc_airy_bis(x: extended): extended;
  {-Return the scaled Airy function Bi(x) if x <= 0, Bi(x)*exp(-2/3*x^1.5) for x > 0}

function sfc_airy_gi(x: extended): extended;
  {-Return the Airy/Scorer function Gi(x) = 1/Pi*integral(sin(x*t+t^3/3), t=0..INF)}

function sfc_airy_hi(x: extended): extended;
  {-Return the Airy/Scorer function Hi(x) = 1/Pi*integral(exp(x*t-t^3/3), t=0..INF)}


function sfc_ber(x: extended): extended;
  {-Return the Kelvin function ber(x)}

function sfc_bei(x: extended): extended;
  {-Return the Kelvin function bei(x)}

function sfc_ker(x: extended): extended;
  {-Return the Kelvin function ker(x), x > 0}

function sfc_kei(x: extended): extended;
  {-Return the Kelvin function kei(x), x >= 0}

procedure sfc_ker_kei(x: extended; var kr, ki: extended);
  {-Return the Kelvin functions kr=ker(x), ki=kei(x), x > 0}

procedure sfc_ber_bei(x: extended; var br, bi: extended);
  {-Return the Kelvin functions br=ber(x), bi=bei(x)}

procedure sfc_kelvin_der(x: extended; var berp, beip, kerp, keip: extended);
  {-Return the derivatives of the zero order Kelvin functions, x >= 0}

function sfc_berp(x: extended): extended;
  {-Return the Kelvin function ber'(x), x >= 0}

function sfc_beip(x: extended): extended;
  {-Return the Kelvin function bei'(x), x >= 0}

function sfc_kerp(x: extended): extended;
  {-Return the Kelvin function ker'(x), x > 0}

function sfc_keip(x: extended): extended;
  {-Return the Kelvin function kei'(x), x >= 0}


function sfc_struve_h0(x: extended): extended;
 {-Return H0(x), the Struve function of order 0}

function sfc_struve_h1(x: extended): extended;
  {-Return H1(x), the Struve function of order 1}

function sfc_struve_h(v,x: extended): extended;
  {-Return H_v(x), the Struve function of order v, x < 0 only if v is an integer.}

function sfc_struve_l0(x: extended): extended;
  {-Return L0(x), the modified Struve function of order 0}

function sfc_struve_l1(x: extended): extended;
  {-Return L1(x), the modified Struve function of order 1}

function sfc_struve_l(v, x: extended): extended;
  {-Return L_v(x), the modified Struve function of order v, x < 0 only if v is an integer.}


function sfc_coulcl(L: integer; eta: extended): extended;
  {-Normalizing constant CL for Coulomb wave function, L >= 0}

function sfc_cshift(L: integer; eta: extended): extended;
  {-Return the Coulomb phase shift sigma_L(eta) for L >= 0}

function sfc_coul_f(L: integer; eta, x: extended): extended;
  {-Return the regular Coulomb wave functions FL(eta,x) for L >= 0, x > 0}

procedure sfc_coul_ffp(L: integer; eta, x: extended; var fc,fcp: extended; var ifail: integer);
  {-Return the regular Coulomb wave functions fc=FL(eta,x) and fcp=FL'(eta,x)}
  { for L >= 0, x > 0. No error if ifail=0, failure if ifail < 0, if ifail=1 }
  { then the very inaccurate JWKB approximation has been computed.}

procedure sfc_coul_ggp(L: integer; eta, x: extended; var gc,gcp: extended; var ifail: integer);
  {-Return the irregular Coulomb wave functions gc=GL(eta,x) and gcp=GL'(eta,x)}
  { for  L >= 0, x > 0. No error if ifail=0, failure if ifail < 0, if ifail=1  }
  { then the very inaccurate JWKB approximation has been computed.}


function sfc_synchf(x: extended): extended;
  {-Return the first synchrotron function F(x) = integral(x*BesselK(5/3,t), t=x..INF) for x >= 0}

function sfc_synchg(x: extended): extended;
  {-Return the second synchrotron function G(x) = x*BesselK(2/3,x) for x >= 0}


implementation


uses
  AMath,
  sfBasic,  {Basic common code}
  sfBessel, {Basic Bessel functions}
  sfGamma;  {Gamma function and related}


{---------------------------------------------------------------------------}
{---------------------------------------------------------------------------}

{---------------------------------------------------------------------------}
function Airy_small(x,f0,f1: extended): extended;
  {-Compute Ai(x) or Bi(x) via Maclaurin series, x small, f0=f(0), f1=f'(0)}
var
  ai,da,t1,t2,x3: extended;
  k: integer;
const
  MAXIT3 = 120;
begin
  {Maclaurin series NIST[30], 9.4.1/9.4.3}
  t1 := f0;
  t2 := f1*x;
  ai := t1 + t2;
  x3 := x*sqr(x);
  k  := 3;
  while k<MAXIT3 do begin
    t1 := t1*x3/(k*(k-1));
    t2 := t2*x3/(k*(k+1));
    da := t1 + t2;
    ai := ai + da;
    if abs(da) < abs(ai)*eps_x then begin
      Airy_small := ai;
      exit;
    end;
    inc(k,3);
  end;
  {No convergence}
  if RTE_NoConvergence>0 then RunError(byte(RTE_NoConvergence));
  Airy_small := ai;
end;


const
  {  Ai(0) =  0.35502805388781723926 =  3^(-2/3)/gamma(2/3)  NIST[30], 9.2.3}
  { Ai'(0) = -0.25881940379280679840 = -3^(-1/3)/gamma(1/3)  NIST[30], 9.2.4}
  {  Bi(0) =  0.61492662744600073516 =  3^(-1/6)/gamma(2/3)  NIST[30], 9.2.5}
  { Bi'(0) =  0.44828835735382635789 =  3^(+1/6)/gamma(1/3)  NIST[30], 9.2.6}
  rt3h: THexExtW = ($539E,$C265,$D742,$DDB3,$3FFF); {+1.7320508075688772936}
  ai0h: THexExtW = ($C2F5,$38AD,$3CB1,$B5C6,$3FFD); {+3.5502805388781723926E-1}
  ai1h: THexExtW = ($545D,$B87C,$FA15,$8483,$BFFD); {-2.5881940379280679839E-1}
  bi0h: THexExtW = ($4BAB,$51F5,$D4DA,$9D6B,$3FFE); {+6.1492662744600073516E-1}
  bi1h: THexExtW = ($0458,$0645,$0D34,$E586,$3FFD); {+4.4828835735382635791E-1}
var
  rt3: extended absolute rt3h; { = 3^0.5  }
  ai0: extended absolute ai0h; { =  Ai(0) }
  ai1: extended absolute ai1h; { = Ai'(0) }
  bi0: extended absolute bi0h; { =  Bi(0) }
  bi1: extended absolute bi1h; { = Bi'(0) }


{---------------------------------------------------------------------------}
function sfc_airy_ai(x: extended): extended;
  {-Return the Airy function Ai(x)}
var
  z,Jv,Yv: extended;
begin
  if IsNaNorInf(x) then begin
    sfc_airy_ai := NaN_x;
    exit;
  end;
  if (x <= 1.0) and (x >= -2.0) then begin
    sfc_airy_ai := Airy_small(x,ai0,ai1);
  end
  else begin
    z := abs(x);
    z := 2.0*z*sqrt(z)/THREE;
    if x>0.0 then begin
      {NR[13], 6.7.41}
      z := sfc_kv(1/3, z);   {Fix311}
      sfc_airy_ai := sqrt(x/THREE)*z/Pi;
    end
    else begin
      {NR[13], 6.7.46}
      sfc_bess_jyv(1/3, z, Jv, Yv);   {Fix311}
      z := Jv - Yv/rt3;
      sfc_airy_ai := 0.5*sqrt(-x)*z;
    end;
  end;
end;


{---------------------------------------------------------------------------}
function sfc_airy_bi(x: extended): extended;
  {-Return the Airy function Bi(x)}
var
  z,bij,bky: extended;
begin
  if IsNaNorInf(x) then begin
    sfc_airy_bi := NaN_x;
    exit;
  end;
  z := abs(x);
  if z < 1.0 then begin
    sfc_airy_bi := Airy_small(x,bi0,bi1);
  end
  else begin
    z := 2.0*z*sqrt(z)/THREE;
    if x>0.0 then begin
      {NR[13], 6.7.44}
      sfc_bess_ikv(1/3,z,bij,bky);  {Fix311}
      z := 2.0*bij/rt3 + bky/Pi;
      sfc_airy_bi := sqrt(x)*z;
    end
    else begin
      {NR[13], 6.7.46}
      sfc_bess_jyv(1/3, z, bij, bky);  {Fix311}
      z := bij/rt3 + bky;
      sfc_airy_bi := (-0.5)*sqrt(-x)*z;
    end;
  end;
end;


{---------------------------------------------------------------------------}
function sfc_airy_ais(x: extended): extended;
  {-Return the scaled Airy function Ai(x) if x <= 0, Ai(x)*exp(2/3*x^1.5) for x > 0}
var
  z: extended;
const
  xs = 1.0;             { if x<=xs use Ai(x) else BesselK}
  xl = 2199023255552.0; {> (3d_1/eps)^(2/3)}
begin
  if IsNaNorInf(x) then begin
    sfc_airy_ais := NaN_x;
    exit;
  end;
  if x<=0.0 then sfc_airy_ais := sfc_airy_ai(x)
  else if x < xl then begin
    z := 2.0*x*sqrt(x)/THREE;
    if x<=xs then begin
      z := exp(z);
      sfc_airy_ais := sfc_airy_ai(x)*z;
    end
    else begin
      z := sfc_kve(1/3, z);  {Fix311}
      sfc_airy_ais := sqrt(x/THREE)*z/Pi;
    end;
  end
  else begin
    {HMF[1], 10.4.59}
    z := sqrt(x);
    sfc_airy_ais := 0.5/sqrtPi/sqrt(z);
  end;
end;


{---------------------------------------------------------------------------}
function sfc_airy_bis(x: extended): extended;
  {-Return the scaled Airy function Bi(x) if x <= 0, Bi(x)*exp(-2/3*x^1.5) for x > 0}
var
  z,bij,bky: extended;
const
  xt = 1e-20;           {for 0<=x<xt, exp(..)=1       }
  xk = 12.0;            {K(1/3,..) negligible if x>xk }
  xl = 2199023255552.0; {> (3d_1/eps)^(2/3)           }
begin
  if IsNaNorInf(x) then begin
    sfc_airy_bis := NaN_x;
    exit;
  end;
  if x<=xt then sfc_airy_bis := sfc_airy_bi(x)
  else if x<xl then begin
    z := 2.0*x*sqrt(x)/THREE;
    bessel_ik(1/3,z,true,true,bij,bky);  {Fix311}
    bij := 2.0*bij/rt3;
    if x<xk then
      bij := bij + bky/Pi*exp(-2*z);
    sfc_airy_bis := sqrt(x)*bij;
  end
  else begin
    z := sqrt(x);
    sfc_airy_bis := 1.0/sqrtPi/sqrt(z);
  end;
end;


{---------------------------------------------------------------------------}
function AiryP_small(x,f0,f1: extended): extended;
  {-Compute Ai'(x) or Bi'(x) via Maclaurin series, x small, f0=f(0), f1=f'(0)}
var
  ai,da,t1,t2,x3: extended;
  k: integer;
const
  MAXIT3 = 120;
begin
  {Maclaurin series NIST[30], 9.4.2/9.4.4}
  t1 := f1;
  t2 := 0.5*f0*x*x;
  ai := t1 + t2;
  x3 := x*sqr(x);
  k  := 3;
  while k<MAXIT3 do begin
    t1 := t1*x3/(k*(k-2));
    t2 := t2*x3/(k*(k+2));
    da := t1 + t2;
    ai := ai + da;
    if abs(da) < abs(ai)*eps_x then begin
      AiryP_small := ai;
      exit;
    end;
    inc(k,3);
  end;
  AiryP_small := ai;
end;


{---------------------------------------------------------------------------}
function sfc_airy_aip(x: extended): extended;
  {-Return the Airy function Ai'(x)}
var
  z,Jv,Yv: extended;
begin
  if IsNaNorInf(x) then begin
    sfc_airy_aip := NaN_x;
    exit;
  end;
  z := abs(x);
  if z <= 1.0 then begin
    sfc_airy_aip := AiryP_small(x,ai0,ai1);
  end
  else begin
    z := 2.0*z*sqrt(z)/THREE;
    if x>0.0 then begin
      {NR[13], 6.7.45}
      z := sfc_kv(2.0/THREE, z);
      sfc_airy_aip := -x/rt3*z/Pi;
    end
    else begin
      {NR[13], 6.7.46}
      sfc_bess_jyv(2.0/THREE, z, Jv, Yv);
      z := Jv + Yv/rt3;
      sfc_airy_aip := (-0.5)*x*z;
    end;
  end;
end;


{---------------------------------------------------------------------------}
function sfc_airy_bip(x: extended): extended;
  {-Return the Airy function Bi'(x)}
var
  z,bij,bky: extended;
begin
  if IsNaNorInf(x) then begin
    sfc_airy_bip := NaN_x;
    exit;
  end;
  z := abs(x);
  if z <= 1.0 then begin
    sfc_airy_bip := AiryP_small(x,bi0,bi1);
  end
  else begin
    z := 2.0*z*sqrt(z)/THREE;
    if x>0.0 then begin
      {NR[13], 6.7.45}
      sfc_bess_ikv(2.0/THREE,z,bij,bky);
      z := 2.0*bij/rt3 + bky/Pi;
      sfc_airy_bip := x*z;
    end
    else begin
      {NR[13], 6.7.46}
      sfc_bess_jyv(2.0/THREE, z, bij, bky);
      z := bij/rt3 - bky;
      sfc_airy_bip := (-0.5)*x*z;
    end;
  end;
end;


{---------------------------------------------------------------------------}
function gipos7(x: extended): extended;
  {-Return Airy/Scorer Gi(x) for x >= 7}
const
  ntip2 = 30;
  argip2: array[0..ntip2-1] of extended = (
            2.00473712275801486391e0,
            0.294184139364406724e-2,
            0.71369249006340167e-3,
            0.17526563430502267e-3,
            0.4359182094029882e-4,
            0.1092626947604307e-4,
            0.272382418399029e-5,
            0.66230900947687e-6,
            0.15425323370315e-6,
            0.3418465242306e-7,
            0.728157724894e-8,
            0.151588525452e-8,
            0.30940048039e-9,
            0.6149672614e-10,
            0.1202877045e-10,
            0.233690586e-11,
            0.43778068e-12,
            0.7996447e-13,
            0.1494075e-13,
            0.246790e-14,
            0.37672e-15,
            0.7701e-16,
            0.354e-17,
           -0.49e-18,
            0.62e-18,
           -0.40e-18,
           -0.1e-19,
            0.2e-19,
           -0.3e-19,
            0.1e-19);
const
  xmax = 2642245.94963; {> cbrt(2/eps_x); double: 208063.8307}
var
  x3, t: extended;
begin
  {Ref: MacLeod's [22], MISCFUN, function airy_gi}
  gipos7 := 0.0;
  if x<7.0 then exit
  else if x <= xmax then begin
    x3 := x*x*x;
    t := (1200.0 - x3)/(514.0 + x3);
    t := CSEvalX(t, argip2, ntip2);
    gipos7 := t/x/Pi;
  end
  else gipos7 := 1.0/Pi/x;
end;


{---------------------------------------------------------------------------}
function hineg8(x: extended): extended;
  {-Return Airy/Scorer Hi(x) for x <= -8}
var
  x3, t: extended;
const
  xmin = -2642245.9496;  {< cbrt(2/eps_x); double: -208063.831}
const
  ntin2 = 16;
  arhin2: array[0..ntin2-1] of extended = (
             1.99647720399779650525e0,
             -0.187563779407173213e-2,
             -0.12186470897787339e-3,
             -0.814021609659287e-5,
             -0.55050925953537e-6,
             -0.3763008043303e-7,
             -0.258858362365e-8,
             -0.17931829265e-9,
             -0.1245916873e-10,
             -0.87171247e-12,
             -0.6084943e-13,
             -0.431178e-14,
             -0.29787e-15,
             -0.2210e-16,
             -0.136e-17,
             -0.14e-18);
begin
  {Ref: MacLeod's [22], MISCFUN, function airy_hi}
  hineg8 := 0.0;
  if x > -8.0 then exit;
  if x <= xmin then  hineg8 := (-1.0)/Pi/x
  else begin
    x3 := x*x*x;
    t  := (x3 + 1200.0)/(176.0 - x3);
    t  := CSEvalX(t, arhin2, ntin2);
    hineg8 := -t/Pi/x;
  end;
end;


{---------------------------------------------------------------------------}
function sfc_airy_hi(x: extended): extended;
  {-Return the Airy/Scorer function Hi(x) = 1/Pi*integral(exp(x*t-t^3/3), t=0..INF)}
const
  hizero = 0.4099510849640004901;  {Hi(0) = 2/Gamma(2/3)/3^(7/6)}
var
  t: extended;
const
  ntin4 = 22;
  arhin1: array[0..ntin4-1] of extended = (
            0.31481017206423404116e0,
           -0.16414499216588964341e0,
            0.6176651597730913071e-1,
           -0.1971881185935933028e-1,
            0.536902830023331343e-2,
           -0.124977068439663038e-2,
            0.24835515596994933e-3,
           -0.4187024096746630e-4,
            0.590945437979124e-5,
           -0.68063541184345e-6,
            0.6072897629164e-7,
           -0.367130349242e-8,
            0.7078017552e-10,
            0.1187894334e-10,
           -0.120898723e-11,
            0.1189656e-13,
            0.594128e-14,
           -0.32257e-15,
           -0.2290e-16,
            0.253e-17,
            0.9e-19,
           -0.2e-19);
const
  ntip1 = 32;
  arhip : array[0..ntip1-1] of extended = (
            1.24013562561762831114,
            0.64856341973926535804,
            0.55236252592114903246,
            0.20975122073857566794,
            0.12025669118052373568,
            0.3768224931095393785e-1,
            0.1651088671548071651e-1,
            0.455922755211570993e-2,
            0.161828480477635013e-2,
            0.40841282508126663e-3,
            0.12196479721394051e-3,
            0.2865064098657610e-4,
            0.742221556424344e-5,
            0.163536231932831e-5,
            0.37713908188749e-6,
            0.7815800336008e-7,
            0.1638447121370e-7,
            0.319857665992e-8,
            0.61933905307e-9,
            0.11411161191e-9,
            0.2064923454e-10,
            0.360018664e-11,
            0.61401849e-12,
            0.10162125e-12,
            0.1643701e-13,
            0.259084e-14,
            0.39931e-15,
            0.6014e-16,
            0.886e-17,
            0.128e-17,
            0.18e-18,
            0.3e-19);
const
  xmax = 662.1358350378; {overflow threshold}
begin
  {Pascal port of A.J. MacLeod's [22] MISCFUN function airy_hi. }
  {AMath uses airy_bi instead of another Chebyshev approximation}
  if x < 0.0 then begin
    if x > -eps_x then sfc_airy_hi := hizero
    else if x <= -8.0 then sfc_airy_hi := hineg8(x)
    else begin
      t := (4.0*x + 12.0)/(x - 12.0);
      sfc_airy_hi := CSEvalX(t,arhin1, ntin4);
    end
  end
  else begin
    if x < eps_x then sfc_airy_hi := hizero
    else if x > 7.0 then begin
      if x>xmax then sfc_airy_hi := PosInf_x
      else begin
        t := gipos7(x);
        sfc_airy_hi := sfc_airy_bi(x) - t;
      end;
    end
    else begin
      t := 2.0*x/7.0 - 1.0;
      t := CSEvalX(t,arhip, ntip1);
      sfc_airy_hi := t*exp(1.5*x);
    end;
  end;
end;


{---------------------------------------------------------------------------}
function sfc_airy_gi(x: extended): extended;
  {-Return the Airy/Scorer function Gi(x) = 1/Pi*integral(sin(x*t+t^3/3), t=0..INF)}
const
  ntin3 = 43;
  argin1: array[0..ntin3-1] of extended = (
           -0.20118965056732089130e0,
           -0.7244175303324530499e-1,
            0.4505018923894780120e-1,
           -0.24221371122078791099e0,
            0.2717884964361678294e-1,
           -0.5729321004818179697e-1,
           -0.18382107860337763587e0,
            0.7751546082149475511e-1,
            0.18386564733927560387e0,
            0.2921504250185567173e-1,
           -0.6142294846788018811e-1,
           -0.2999312505794616238e-1,
            0.585937118327706636e-2,
            0.822221658497402529e-2,
            0.132579817166846893e-2,
           -0.96248310766565126e-3,
           -0.45065515998211807e-3,
            0.772423474325474e-5,
            0.5481874134758052e-4,
            0.1245898039742876e-4,
           -0.246196891092083e-5,
           -0.169154183545285e-5,
           -0.16769153169442e-6,
            0.9636509337672e-7,
            0.3253314928030e-7,
            0.5091804231e-10,
           -0.209180453553e-8,
           -0.41237387870e-9,
            0.4163338253e-10,
            0.3032532117e-10,
            0.340580529e-11,
           -0.88444592e-12,
           -0.31639612e-12,
           -0.1505076e-13,
            0.1104148e-13,
            0.246508e-14,
           -0.3107e-16,
           -0.9851e-16,
           -0.1453e-16,
            0.118e-17,
            0.67e-18,
            0.6e-19,
           -0.1e-19);
const
  ntip1 = 31;
  argip1: array[0..ntip1-1] of extended = (
            0.26585770795022745082e0,
           -0.10500333097501922907e0,
            0.841347475328454492e-2,
            0.2021067387813439541e-1,
           -0.1559576113863552234e-1,
            0.564342939043256481e-2,
           -0.59776844826655809e-3,
           -0.42833850264867728e-3,
            0.22605662380909027e-3,
           -0.3608332945592260e-4,
           -0.785518988788901e-5,
            0.473252480746370e-5,
           -0.59743513977694e-6,
           -0.15917609165602e-6,
            0.6336129065570e-7,
           -0.276090232648e-8,
           -0.256064154085e-8,
            0.47798676856e-9,
            0.4488131863e-10,
           -0.2346508882e-10,
            0.76839085e-12,
            0.73227985e-12,
           -0.8513687e-13,
           -0.1630201e-13,
            0.356769e-14,
            0.25001e-15,
           -0.10859e-15,
           -0.158e-17,
            0.275e-17,
           -0.5e-19,
           -0.6e-19);
const
  gizero = 0.204975542482000245050307456365; {Gi(0) = 1/Gamma(2/3)/3^(7/6)}
var
  t: extended;
begin
  {Pascal port of A.J. MacLeod's [22] MISCFUN function airy_gi. }
  {AMath uses airy_bi instead of another Chebyshev approximation}
  if x < -8.0 then begin
    t := hineg8(x);
    sfc_airy_gi := sfc_airy_bi(x) - t;
  end
  else if x <= -eps_x then begin
    t := -(x+4.0)/4.0;
    sfc_airy_gi := CSEvalX(t,argin1, ntin3);
  end
  else if x < eps_x then begin
    {abs(x) < eps_x}
    sfc_airy_gi := gizero;
  end
  else if x < 7.0 then begin
    t := (9.0*x - 28.0)/(x + 28.0);
    sfc_airy_gi := CSEvalX(t,argip1,ntip1);
  end
  else begin
    {x > 7}
    sfc_airy_gi := gipos7(x);
  end;
end;


{---------------------------------------------------------------------------}
{---------------------------------------------------------------------------}

{---------------------------------------------------------------------------}
function ber_sm(x: extended): extended;
  {-Return the Kelvin function ber(x), 0<=x<20}
var
  f,s,t,x4: extended;
  k: integer;
begin
  {Ref: HMF [1], 9.9.9/10}
  k := 1;
  s := 1.0;
  t := 1.0;
  x4:= -0.0625*sqr(sqr(x));
  repeat
    f := sqr(2*k);
    f := f*sqr(2*k-1);
    t := t/f*x4;
    s := s+t;
    k := k+1;
  until abs(t) < eps_x*abs(s);
  ber_sm := s;
end;


{---------------------------------------------------------------------------}
function bei_sm(x: extended): extended;
  {-Return the Kelvin function bei(x), 0<=x<20}
var
  f,s,t,x4: extended;
  k: integer;
begin
  {Ref: HMF [1], 9.9.9/10}
  k := 1;
  t := 0.25*sqr(x);
  s := t;
  x4:= -sqr(t);
  repeat
    f := sqr(2*k);
    f := f*sqr(2*k+1);
    t := t/f*x4;
    s := s+t;
    k := k+1;
  until abs(t) < eps_x*abs(s);
  bei_sm := s;
end;


{---------------------------------------------------------------------------}
function ker_sm(x: extended): extended;
  {-Return the Kelvin function ker(x), 0<x<3}
var
  f,h,s,t,x4: extended;
  k: integer;
begin
  {Ref: HMF [1], 9.9.12}
  k := 1;
  h := 0.0;
  t := 1.0;
  x := abs(x);
  x4:= -0.0625*sqr(sqr(x));
  s := Pi_4*bei_sm(x);
  f := ln(0.5*x) + EulerGamma;
  {bei/ber are accurate, but the cancellation for s is too large for x>3}
  s := s - f*ber_sm(x);
  repeat
    f := sqr(2*k);
    f := f*sqr(2*k-1);
    t := t/f*x4;
    h := h + 1/(2*k) + 1/(2*k-1);
    f := t*h;
    s := s+f;
    k := k+1;
  until abs(f) < eps_x*abs(s);
  ker_sm := s;
end;


{---------------------------------------------------------------------------}
function kei_sm(x: extended): extended;
  {-Return the Kelvin function kei(x), 0<x<3}
var
  f,h,s,t,x4: extended;
  k: integer;
begin
  {Ref: HMF [1], 9.9.12}
  k := 1;
  h := 1.0;
  t := 0.25*sqr(x);
  x := abs(x);
  x4:= -sqr(t);
  f := ln(0.5*x) + EulerGamma;
  s := t - Pi_4*ber_sm(x);
  {bei/ber are accurate, but the cancellation for s is too large for x>3}
  s := s - f*bei_sm(x);
  repeat
    f := sqr(2*k);
    f := f*sqr(2*k+1);
    t := t/f*x4;
    h := h + 1/(2*k) + 1/(2*k+1);
    f := t*h;
    s := s+f;
    k := k+1;
  until abs(f) < eps_x*abs(s);
  kei_sm := s;
end;


{---------------------------------------------------------------------------}
{Constants used for Kelvin functions and derivatives}
const
  skp4hx: array[0..7] of THexExtW = (         { sin(k*Pi/4), k=0..7  }
            ($0000,$0000,$0000,$0000,$0000),  { 0.0000000000000000000}
            ($6484,$F9DE,$F333,$B504,$3FFE),  { 0.7071067811865475244}
            ($0000,$0000,$0000,$8000,$3FFF),  { 1.0000000000000000000}
            ($6484,$F9DE,$F333,$B504,$3FFE),  { 0.7071067811865475244}
            ($0000,$0000,$0000,$0000,$0000),  { 0.0000000000000000000}
            ($6484,$F9DE,$F333,$B504,$BFFE),  {-0.7071067811865475244}
            ($0000,$0000,$0000,$8000,$BFFF),  {-1.0000000000000000000}
            ($6484,$F9DE,$F333,$B504,$BFFE)); {-0.7071067811865475244}
var
  sinkp4: array[0..7] of extended absolute skp4hx;


{---------------------------------------------------------------------------}
procedure kelvin_large(x: extended; cb: boolean; var br, bi, kr, ki: extended);
  {-Return all four Kelvin functions for x >= 20 using asymptotic expansions}
  { ker/kei are always calculated, ber/bei only if cb=true}
var
  f0p, {f0(+x)}
  f0n, {f0(-x)}
  g0p, {g0(+x)}
  g0n, {g0(-x)}
  tk,  {term k}
  tc,  {cos() term}
  ts,  {sin() term}
  fac,xt: extended;
  k: integer;
  cbp,          {calc f0p,f0p}
  ckn: boolean; {calc f0n,g0n}
const
  kmax   = 40;       {Note: for k > 2*x the terms are increasing}
  xlarge = 16060.55; {>~ ln_MaxExt*sqrt(2)}
begin

  if x > xlarge then begin
    kr := 0.0;
    ki := 0.0;
    if cb then begin
      {may nan_x?}
      br := PosInf_x;
      bi := PosInf_x;
    end;
    exit;
  end;

  {The functions are calculated using formula from HMF[1], section 9.10}
  {with nu=0 and x >= 20.}

  f0p := 1.0;    {k=0 term of sum for function f0(+x): 9.10.6}
  f0n := 1.0;    {k=0 term of sum for function f0(-x): 9.10.6}
  g0p := 0.0;    {k=0 term of sum for function g0(+x): 9.10.7}
  g0n := 0.0;    {k=0 term of sum for function g0(-x): 9.10.7}
  tk  := 1.0;    {term k of sum = prod(2j-1, j=1..k)/k!/(8x)^k}
  fac := 1.0;    {factor (+-)^k}
  cbp := cb;     {calc ber/bei}
  ckn := true;   {calc ker/kei}
  xt  := 8.0*x;

  k := 0;
  while (k<kmax) and (cbp or ckn) do begin
    fac := -fac;
    inc(k);
    tk := tk*sqr(2*k-1)/xt/k;       {term k = prod(2j-1, j=1..k)/k!/(8x)^k}
    tc := tk*sinkp4[(k+2) and 7];   {tk*cos(k*Pi/4)}
    ts := tk*sinkp4[k and 7];       {tk*sin(k*Pi/4)}
    if ckn then begin
      f0n := f0n + fac*tc;          {update and conv check f0(-x), g0(-x)}
      g0n := g0n + fac*ts;
      ckn := tk >= eps_x*minx(abs(f0n), abs(g0n));
    end;
    if cbp then begin
      f0p := f0p + tc;              {update and conv check f0(+x), g0(+x)}
      g0p := g0p + ts;
      cbp := tk >= eps_x*minx(abs(f0p),abs(g0p));
    end;
  end;

  xt := x/Sqrt2;
  if xt>=ln_MaxExt then tk := PosInf_x else tk := exp(xt);

  {get sin(beta), cos(beta), beta = x/sqrt(2) + Pi/8, HMF 9.10.5}
  sincos(xt + 0.125*Pi, ts, tc);
  fac := sqrt(Pi_2/x)/tk;
  kr  :=  fac*(f0n*tc - g0n*ts);    {HMF 9.10.3}
  ki  := -fac*(f0n*ts + g0n*tc);    {HMF 9.10.4}

  if cb then begin
    {get sin(alpha), cos(alpha), alpha = x/sqrt(2) - Pi/8, HMF 9.10.5}
    sincos(xt - 0.125*Pi, ts, tc);
    fac := tk/sqrt(TwoPi*x);
    br  := fac*(f0p*tc + g0p*ts) - ki/Pi;   {HMF 9.10.1}
    bi  := fac*(f0p*ts - g0p*tc) + kr/Pi;   {HMF 9.10.2}
  end;
end;


{---------------------------------------------------------------------------}
procedure ker_kei_med(x: extended; var kr, ki: extended);
  {-Return Kelvin function kr=ker(x), ki=kei(x), 3<=x<=20}
var
  fac,ts,tc,f0,g0,z: extended;
const
  csfh: array[0..25] of THexExtW = (
          ($506A,$C602,$4284,$B261,$BFFC),  {-1.7419914183983770261E-1}
          ($37E4,$0D89,$9DC9,$D2BF,$3FF5),  {+1.6078834637723389439E-3}
          ($B72F,$221B,$B883,$8A8D,$3FF3),  {+2.6427001320521815227E-4}
          ($7504,$9B4C,$5152,$C85E,$BFF0),  {-4.7771555992520623486E-5}
          ($A6EA,$3952,$4677,$D2A5,$3FED),  {+6.2777282736162430502E-6}
          ($3707,$0164,$D168,$C112,$BFEA),  {-7.1925486544564774167E-7}
          ($4D18,$0370,$0118,$8FF8,$3FE7),  {+6.7040681229020080687E-8}
          ($7415,$1767,$0678,$B619,$BFE2),  {-2.6498710934646215641E-9}
          ($FEC8,$4C88,$946A,$8596,$BFE1),  {-9.7198209650154837839E-10}
          ($E222,$BBE5,$0103,$DBFA,$3FDF),  {+4.0013506437635697668E-10}
          ($4AE8,$FC28,$ADF6,$E954,$BFDD),  {-1.0610655385424269996E-10}
          ($A63B,$64ED,$B4A5,$D09E,$3FDB),  {+2.3717341712233160606E-11}
          ($586B,$FBCD,$9CA8,$A4CB,$BFD9),  {-4.6837658144710679937E-12}
          ($CD0E,$0302,$4074,$E09E,$3FD6),  {+7.9800404853834490867E-13}
          ($8DEB,$A62B,$4A33,$E479,$BFD3),  {-1.0146274419705259356E-13}
          ($9F62,$F52D,$5074,$B70A,$3FCD),  {+1.2700971536601990071E-15}
          ($6511,$0AEE,$C2FA,$BFBF,$3FCF),  {+5.3221057799364269748E-15}
          ($413D,$7650,$9726,$BA4C,$BFCE),  {-2.5854205078178475222E-15}
          ($2E9B,$951C,$02B0,$82A2,$3FCD),  {+9.0644751109753703700E-16}
          ($BCE2,$D446,$1B75,$9DF4,$BFCB),  {-2.7400572090870253519E-16}
          ($CC25,$B66D,$E144,$AC37,$3FC9),  {+7.4687773792482686324E-17}
          ($4BC9,$34AF,$577E,$A9FB,$BFC7),  {-1.8429464094897889406E-17}
          ($69D4,$72A0,$72B6,$933D,$3FC5),  {+3.9909490541622123671E-18}
          ($079B,$B0F6,$92EA,$C713,$BFC2),  {-6.7449728433925005994E-19}
          ($6C07,$F752,$0C2B,$B1FE,$3FBE),  {+3.7691351120612689369E-20}
          ($0B6E,$6263,$A0E4,$B1CA,$3FBE)); {+3.7648818270236777832E-20}
const
  csgh: array[0..26] of THexExtW = (
          ($2C6C,$7C98,$35C1,$A0FA,$BFFC),  {-1.5720447534035757322E-1}
          ($1BB1,$7184,$DFBC,$968E,$3FF8),  {+9.1893372462197369193E-3}
          ($5940,$1F5D,$C613,$948D,$BFF4),  {-5.6668778850565061864E-4}
          ($AED3,$254C,$35E7,$FED3,$3FEF),  {+3.0377512126347748295E-5}
          ($FEB1,$50B7,$D101,$D390,$BFE8),  {-1.9703590233373688640E-7}
          ($868B,$90B5,$2B3C,$C764,$BFE9),  {-3.7139520931598000832E-7}
          ($0D6C,$2DF4,$EB31,$CE90,$3FE7),  {+9.6189830799939401844E-8}
          ($7AA9,$25FC,$4836,$9EB6,$BFE5),  {-1.8476513139939364061E-8}
          ($6C6A,$1B34,$E66D,$D293,$3FE2),  {+3.0643093454233132330E-9}
          ($467C,$8D52,$1ED2,$EFDD,$BFDF),  {-4.3630962238885554609E-10}
          ($1D8F,$78AC,$219D,$C8E6,$3FDC),  {+4.5679132751061958419E-11}
          ($A387,$C1DC,$D1E6,$D64D,$3FD3),  {+9.5170086962745579158E-14}
          ($7363,$CD4C,$A383,$8CF3,$BFD8),  {-2.0030443265088914950E-12}
          ($B346,$C4C0,$457A,$E4DC,$3FD6),  {+8.1307559857898340689E-13}
          ($2AE0,$9369,$58AB,$895D,$BFD5),  {-2.4400860754197408382E-13}
          ($223A,$973B,$0306,$8EAB,$3FD3),  {+6.3357326016347255195E-14}
          ($4DC2,$F451,$CC15,$84B5,$BFD1),  {-1.4733785897064301269E-14}
          ($7B1B,$CCA2,$8E46,$DA49,$3FCE),  {+3.0293452082666044179E-15}
          ($EA69,$9E74,$328C,$9268,$BFCC),  {-5.0795139386674074074E-16}
          ($23CA,$CB49,$432B,$D00B,$3FC8),  {+4.5112349988246225192E-17}
          ($623D,$DBB3,$E9F1,$F918,$3FC6),  {+1.3503592759696792310E-17}
          ($88F8,$A531,$E00E,$C0B5,$BFC6),  {-1.0446854432502786340E-17}
          ($DB22,$B28E,$3865,$A6CC,$3FC5),  {+4.5210616813281396687E-18}
          ($51BE,$BCAA,$F012,$EE1D,$BFC3),  {-1.6135431781668171227E-18}
          ($FEAA,$9029,$7A0E,$97EC,$3FC2),  {+5.1473764432777121521E-19}
          ($43D2,$C671,$99B4,$B156,$BFC0),  {-1.5021136840019478519E-19}
          ($DA1A,$83DE,$2FDA,$BCD0,$3FBE)); {+3.9982756711602287398E-20}
var
  csf0: array[0..25] of extended absolute csfh;
  csg0: array[0..26] of extended absolute csgh;

begin
  {Medium range ker/kei: 3 <= x <= 20. The series for small x become}
  {inaccurate for x >= 3 due to the difference of the ber/bei terms.}
  z := x/Sqrt2;
  {get sin(beta), cos(beta), beta = x/sqrt(2) + Pi/8}
  sincos(z + 0.125*Pi, ts, tc);
  fac:= sqrt(Pi_2/x)*exp(-z);
  {get (asymptotic functions) f0,g0 via Chebyshev expansions}
  z  := 6.0/x - 1.0;
  f0 := 1.0 + CSEvalX(z,csf0,26)/x;
  g0 := CSEvalX(z,csg0,27)/x;
  kr :=  fac*(f0*tc - g0*ts);
  ki := -fac*(f0*ts + g0*tc);
end;


{---------------------------------------------------------------------------}
procedure sfc_ker_kei(x: extended; var kr, ki: extended);
  {-Return the Kelvin functions kr=ker(x), ki=kei(x), x > 0}
var
  br, bi: extended;
const
  Omg = 0.422784335098467139393488;  {1-gamma}
begin
  if IsNaN(x) or (x<=0.0) then begin
    {$ifopt R+}
      if RTE_ArgumentRange>0 then RunError(byte(RTE_ArgumentRange));
    {$endif}
    kr := NaN_x;
    ki := NaN_x;
  end
  else if x<=1e-10 then begin
    kr := -(ln(0.5*x)+EulerGamma);
    ki := -Pi_4;
  end
  else if x<=1e-5 then begin
    {ker(x) = -gamma - ln(x/2) + 1/16*(Pi-3/8*x^2)*x^2 }
    {kei(x) = 0.25*(-Pi + (1-gamma-ln(x/2))*x^2)       }
    br := ln(0.5*x);
     x := sqr(x);
    kr := -Eulergamma - br + 0.0625*(Pi-0.375*x)*x;
    ki := 0.25*((Omg - br)*x - Pi);
  end
  else if x<3.0 then begin
    kr := ker_sm(x);
    ki := kei_sm(x);
  end
  else if x<=20.0 then ker_kei_med(x,kr,ki)
  else kelvin_large(x,false,br,bi,kr,ki);
end;


{---------------------------------------------------------------------------}
procedure sfc_ber_bei(x: extended; var br, bi: extended);
  {-Return the Kelvin functions br=ber(x), bi=bei(x)}
var
  kr, ki: extended;
begin
  if IsNaNorInf(x) then begin
    {$ifopt R+}
      if RTE_ArgumentRange>0 then RunError(byte(RTE_ArgumentRange));
    {$endif}
    br := NaN_x;
    bi := NaN_x;
  end
  else begin
    x := abs(x);
    if x<=1e-5 then begin
      br := 1.0;
      bi := 0.25*sqr(x);
    end
    else if x<20.0 then begin
      br := ber_sm(x);
      bi := bei_sm(x);
    end
    else kelvin_large(x,true,br,bi,kr,ki);
  end;
end;


{---------------------------------------------------------------------------}
function sfc_ber(x: extended): extended;
  {-Return the Kelvin function ber(x)}
var
  br,bi,kr,ki: extended;
begin
  if IsNaNorInf(x) then begin
    {$ifopt R+}
      if RTE_ArgumentRange>0 then RunError(byte(RTE_ArgumentRange));
    {$endif}
    sfc_ber := NaN_x;
  end
  else begin
    x := abs(x);
    if x<=1e-5 then sfc_ber := 1.0
    else if x<20.0 then sfc_ber := ber_sm(x)
    else begin
      kelvin_large(x,true,br,bi,kr,ki);
      sfc_ber := br;
    end;
  end;
end;


{---------------------------------------------------------------------------}
function sfc_bei(x: extended): extended;
  {-Return the Kelvin function bei(x)}
var
  br,bi,kr,ki: extended;
begin
  if IsNaNorInf(x) then begin
    {$ifopt R+}
      if RTE_ArgumentRange>0 then RunError(byte(RTE_ArgumentRange));
    {$endif}
    sfc_bei := NaN_x;
  end
  else begin
    x := abs(x);
    if x<=1e-5 then sfc_bei := 0.25*sqr(x)
    else if x<20.0 then sfc_bei := bei_sm(x)
    else begin
      kelvin_large(x,true,br,bi,kr,ki);
      sfc_bei := bi;
    end;
  end;
end;


{---------------------------------------------------------------------------}
function sfc_ker(x: extended): extended;
  {-Return the Kelvin function ker(x), x > 0}
var
  kr, ki: extended;
begin
  if IsNaN(x) or (x<=1e-5) or (x>=3.0) then begin
    sfc_ker_kei(x,kr,ki);
    sfc_ker := kr;
  end
  else sfc_ker := ker_sm(x);
end;


{---------------------------------------------------------------------------}
function sfc_kei(x: extended): extended;
  {-Return the Kelvin function kei(x), x >= 0}
var
  kr, ki: extended;
begin
  if IsNaN(x) or (x<=1e-5) or (x>=3.0) then begin
    if x=0.0 then sfc_kei := -Pi_4
    else begin
      sfc_ker_kei(x,kr,ki);
      sfc_kei := ki;
    end;
  end
  else sfc_kei := kei_sm(x);
end;


{---------------------------------------------------------------------------}
procedure kelvin_der_small(x: extended; ckk: boolean; var berp, beip, kerp, keip: extended);
  {-Return all derivatives using asymptotic expansions}
var
  s,t,h,x4,f: extended;
  k,m: integer;
const
  kmax = 64;
begin
  f  :=  0.25*sqr(x);
  x4 := -0.25*sqr(f);

  {Ref: HMF [1], 9.9.9}
  s  := -0.25*x*f;
  t  := s;
  for k:=1 to kmax do begin
    f := sqr(k+k+1);
    f := f*(k*(k+1));
    t := t*x4/f;
    s := s + t;
    if abs(t) < eps_x*abs(s) then break;
  end;
  berp := s;

  {Ref: HMF [1], 9.9.9}
  s  := 0.5*x;
  t  := s;
  for k:=1 to kmax do begin
    f := sqr(k);
    f := f*(4.0*f-1.0);
    t := t*x4/f;
    s := s + t;
    if abs(t) < eps_x*abs(s) then break;
  end;
  beip := s;

  if not ckk then exit;

  {Ref: HMF [1], 9.9.11}
  t :=  0.25*sqr(x);
  t := -0.25*x*t;
  h := 1.5;
  s := 1.5*t - ber_sm(x)/x - (ln(0.5*x)+EulerGamma)*berp + 0.25*pi*beip;
  for k:=1 to kmax do begin
    m := k+k+1;
    f := sqr(m);
    f := f*(k*(k+1));
    t := t/f*x4;
    h := h + 1/m + 1/(m+1);
    f := t*h;
    s := s + f;
    if abs(f) < abs(s)*eps_x then break;
  end;
  kerp := s;

  {Ref: HMF [1], 9.9.11}
  t := 0.5*x;
  h := 1.0;
  s := t - bei_sm(x)/x - (ln(t)+EulerGamma)*beip -0.25*pi*berp;
  for k:=1 to kmax do begin
    m := k+k;
    f := sqr(k);
    f := f*(m+1)*(m-1);
    t := t/f*x4;
    h := h + 1/m + 1/(m+1);
    f := t*h;
    s := s + f;
    if abs(f) < abs(s)*eps_x then break;
  end;
  keip := s;

end;


{---------------------------------------------------------------------------}
procedure kelvin_der_large(x: extended; var berp, beip, kerp, keip: extended);
  {-Return all derivatives using asymptotic expansions}
var
  f0p, {f0'(+x)}
  f0n, {f0'(-x)}
  g0p, {g0'(+x)}
  g0n, {g0'(-x)}
  tk,  {term k}
  tc,  {cos() term}
  ts,  {sin() term}
  fac,xt,x8,ak: extended;
  k: integer;
  cp, cn: boolean;
const
  kmax = 40;
begin
  f0p := 1.0;
  f0n := 1.0;
  g0p := 0.0;
  g0n := 0.0;
  tk  := 1.0;
  fac := 1.0;
  x8  := 8.0*x;
  cp  := true;
  cn  := true;
  k := 0;
  while (k<kmax) and (cp or cn) do begin
    fac := -fac;
    inc(k);
    tk := tk * (4 - sqr(k+k-1)) / k / x8;
    ts := tk*sinkp4[k and 7];       {tk*sin(k*Pi/4)}
    tc := tk*sinkp4[(k+2) and 7];   {tk*cos(k*Pi/4)}
    ak := abs(tk);
    if cp then begin
      f0p := f0p + fac * tc;
      g0p := g0p + fac * ts;
      cp  := ak >= eps_x*minx(abs(f0p), abs(g0p));
    end;
    if cn then begin
      f0n := f0n + tc;
      g0n := g0n + ts;
      cn  := ak >= eps_x*minx(abs(f0n), abs(g0n));
    end;
  end;

  xt := x / sqrt2;
  if xt>=ln_MaxExt then tk := Infinity else tk := exp(xt);

  fac := sqrt(pi_2/x) / tk;
  sincos(xt - 0.125*Pi, ts, tc);
  kerp := fac * (-f0n*tc + g0n*ts);
  keip := fac * ( f0n*ts + g0n*tc);

  fac := tk/sqrt(TwoPi*x);
  sincos(xt + 0.125*Pi, ts, tc);
  berp := fac * (f0p*tc + g0p*ts) - keip / Pi;
  beip := fac * (f0p*ts - g0p*tc) + kerp / Pi;
end;


{---------------------------------------------------------------------------}
procedure sfc_kelvin_der(x: extended; var berp, beip, kerp, keip: extended);
  {-Return the derivatives of the zero order Kelvin functions, x >= 0}
begin
  if IsNanOrInf(x) or (x<0.0) then begin
    kerp := Nan;
    keip := Nan;
    berp := Nan;
    beip := Nan;
  end
  else if x=0.0 then begin
    kerp := NegInfinity;
    keip := 0.0;
    berp := 0.0;
    beip := 0.0;
  end
  else if x<13.0 then begin
    {Use series for all}
    kelvin_der_small(x, true, berp, beip, kerp, keip);
  end
  else if x<20.0 then begin
    {Series for berp/beip, asymptotic expansion for kerp/keip}
    kelvin_der_large(x, berp, beip, kerp, keip);
    {Do not recompute kerp/keip}
    kelvin_der_small(x, false, berp, beip, kerp, keip);
  end
  else begin
    {Asymptotic expansion for all}
    kelvin_der_large(x, berp, beip, kerp, keip);
  end;
end;


{---------------------------------------------------------------------------}
function sfc_berp(x: extended): extended;
  {-Return the Kelvin function ber'(x), x >= 0}
var
  kerp, keip, berp, beip: extended;
begin
  if IsNanOrInf(x) then berp := Nan
  else if x < 20.0 then begin
    kelvin_der_small(x, false, berp, beip, kerp, keip);
  end
  else begin
    kelvin_der_large(x, berp, beip, kerp, keip);
  end;
  sfc_berp := berp;
end;


{---------------------------------------------------------------------------}
function sfc_beip(x: extended): extended;
  {-Return the Kelvin function bei'(x), x >= 0}
var
  kerp, keip, berp, beip: extended;
begin
  if IsNanOrInf(x) then beip := Nan
  else if x < 20.0 then begin
    kelvin_der_small(x, false, berp, beip, kerp, keip);
  end
  else begin
    kelvin_der_large(x, berp, beip, kerp, keip);
  end;
  sfc_beip := beip;
end;


{---------------------------------------------------------------------------}
function sfc_kerp(x: extended): extended;
  {-Return the Kelvin function ker'(x), x > 0}
var
  kerp, keip, berp, beip: extended;
begin
  if IsNanOrInf(x) then kerp := Nan
  else if x < 13.0 then begin
    kelvin_der_small(x, true, berp, beip, kerp, keip);
  end
  else begin
    kelvin_der_large(x, berp, beip, kerp, keip);
  end;
  sfc_kerp := kerp;
end;


{---------------------------------------------------------------------------}
function sfc_keip(x: extended): extended;
  {-Return the Kelvin function kei'(x), x >= 0}
var
  kerp, keip, berp, beip: extended;
begin
  if IsNanOrInf(x) then keip := Nan
  else if x < 13.0 then begin
    kelvin_der_small(x, true, berp, beip, kerp, keip);
  end
  else begin
    kelvin_der_large(x, berp, beip, kerp, keip);
  end;
  sfc_keip := keip;
end;



{---------------------------------------------------------------------------}
{---------------------------------------------------------------------------}

{---------------------------------------------------------------------------}
function sfc_struve_h0(x: extended): extended;
  {-Return H0(x), the Struve function of order 0}
var
  t,y: extended;
const
  xlow = 0.69849193096160888673e-9;  {3*sqrt(eps_x/2)}
const
  nh0 = 20;
  axh0:  array[0..nh0-1] of THexExtW = (
            ($9F2C,$C6D9,$0F59,$92ED,$3FFD),  {+0.28696487399013225740e0}
            ($DE82,$3B23,$4714,$8213,$BFFD),  {-0.25405332681618352305e0}
            ($8711,$10A5,$DD5A,$D4B9,$3FFC),  {+0.20774026739323894439e0}
            ($F9CC,$10C4,$14E7,$D087,$BFFC),  {-0.20364029560386585140e0}
            ($C7CC,$F1A2,$5930,$83FA,$3FFC),  {+0.12888469086866186016e0}
            ($87A0,$18A8,$6D74,$C5A8,$BFFA),  {-0.4825632815622261202e-1}
            ($31A7,$87EF,$DE12,$BF77,$3FF8),  {+0.1168629347569001242e-1}
            ($460F,$1F15,$B522,$81D6,$BFF6),  {-0.198118135642418416e-2 }
            ($3178,$47EF,$0ED9,$828B,$3FF3),  {+0.24899138512421286e-3  }
            ($0E9A,$7FFB,$EF15,$CAE7,$BFEF),  {-0.2418827913785950e-4   }
            ($D62A,$7E05,$0D14,$FB93,$3FEB),  {+0.187437547993431e-5    }
            ($EF41,$7DB2,$690C,$FEFA,$BFE7),  {-0.11873346074362e-6     }
            ($E718,$3DD5,$2DC9,$D76E,$3FE3),  {+0.626984943346e-8       }
            ($CC7A,$7D13,$9920,$9A2E,$BFDF),  {-0.28045546793e-9        }
            ($9EE3,$921E,$1EBE,$BD75,$3FDA),  {+0.1076941205e-10        }
            ($3BC6,$C05F,$428C,$CA20,$BFD5),  {-0.35904793e-12          }
            ($EA6E,$8AF3,$3358,$BD0D,$3FD0),  {+0.1049447e-13           }
            ($C405,$2B9A,$9488,$9C54,$BFCB),  {-0.27119e-15             }
            ($D8CE,$9204,$223A,$E637,$3FC5),  {+0.624e-17               }
            ($E5DF,$B6AD,$16D1,$997A,$BFC0)); {-0.13e-18                }

const
  nh0a = 21;
  axh0a:  array[0..nh0a-1] of THexExtW = (
            ($C0A6,$509B,$F712,$FF17,$3FFF),  {+1.99291885751992305515e0}
            ($657A,$1628,$8B76,$FBCF,$BFF6),  {-0.384232668701456887e-2 }
            ($7575,$3164,$0B09,$AC58,$BFF3),  {-0.32871993712353050e-3  }
            ($ED70,$1238,$62AA,$F6B9,$BFEF),  {-0.2941181203703409e-4   }
            ($B3B1,$FF97,$6D82,$B364,$BFEC),  {-0.267315351987066e-5    }
            ($F307,$0D0B,$59CF,$8481,$BFE9),  {-0.24681031075013e-6     }
            ($B8D3,$814C,$E917,$C523,$BFE5),  {-0.2295014861143e-7      }
            ($BE24,$6B2C,$3830,$9437,$BFE2),  {-0.215682231833e-8       }
            ($1EBF,$E875,$4A46,$DF3D,$BFDE),  {-0.20303506483e-9        }
            ($12D5,$7691,$C488,$AA2A,$BFDB),  {-0.1934575509e-10        }
            ($4A93,$FC5B,$7B86,$809D,$BFD8),  {-0.182773144e-11         }
            ($EFF0,$0A68,$FECE,$C80D,$BFD4),  {-0.17768424e-12          }
            ($A940,$9638,$D370,$9403,$BFD1),  {-0.1643296e-13           }
            ($5CDC,$E8C4,$C9E6,$F741,$BFCD),  {-0.171569e-14            }
            ($B4D6,$0EAD,$5F39,$9A1F,$BFCA),  {-0.13368e-15             }
            ($98EC,$FEA2,$C6A2,$BF91,$BFC7),  {-0.2077e-16              }
            ($1AEB,$9211,$0864,$BCE5,$3FBD),  {+0.2e-19                 }
            ($B322,$6D86,$D336,$A254,$BFC2),  {-0.55e-18                }
            ($61A5,$B695,$4A7D,$EC1E,$3FBF),  {+0.10e-18                }
            ($1AEB,$9211,$0864,$BCE5,$BFBE),  {-0.4e-19                 }
            ($1AEB,$9211,$0864,$BCE5,$3FBC)); {+0.1e-19                 }
var
  arrh0:  array[0..nh0-1]  of extended absolute axh0;
  arrh0a: array[0..nh0a-1] of extended absolute axh0a;
begin
  if IsNaN(x) then begin
    {$ifopt R+}
      if RTE_ArgumentRange>0 then RunError(byte(RTE_ArgumentRange));
    {$endif}
    sfc_struve_h0 := NaN_x;
    exit;
  end;
  {See MISCFUN [22], function STRVH0 for Chebyshev coefficients and hints. }
  {As pointed out the phase of Y0(x) is very sensitive for |x| > 1/eps_x.  }
  {Therefore in high accuracy tests x must have exactly the same value in  }
  {both calculations. My implementation uses Y0, [22] has two other series.}
  t := abs(x);
  if t <= 11.0 then begin
    if t<xlow then begin
      {H0(x) = 2/Pi*x*(1-1/9*x^2+1/225*x^4+O(x^5))}
      sfc_struve_h0 := x/Pi_2;
    end
    else begin
      t := sqr(x)/60.5 - 1.0;
      t := CSEvalX(t,arrh0,nh0);
      sfc_struve_h0 := 2.0*x*t/Pi;
    end;
  end
  else begin
    y := sfc_y0(t);
    {Correct sign if x<0 since H0 is an odd function}
    if x<0.0 then y := -y;
    if t >= 1e10 then begin
      {Avoid squaring overflow and/or unnecessary calculations}
      {H0(x) = Y0(x) + 2/Pi/x*(1 - 1/x^2 + ..}
      sfc_struve_h0 := y + 2.0/Pi/x;
    end
    else begin
      t := sqr(x);
      t := (302.5 - t) / (60.5 + t);
      t := CSEvalX(t,arrh0a,nh0a);
      t := t/Pi_2/x;
      sfc_struve_h0 := y + t;
    end;
  end;
end;


{---------------------------------------------------------------------------}
function sfc_struve_h1(x: extended): extended;
  {-Return H1(x), the Struve function of order 1}
var
  t,y: extended;
const
  xlow = 0.9017492053581906681e-9;  {sqrt(15*eps_x/2)}
const
  arrh1:  array[0..17] of extended = (
            +0.17319061083675439319e0,
            -0.12606917591352672005e0,
             0.7908576160495357500e-1,
            -0.3196493222321870820e-1,
             0.808040581404918834e-2,
            -0.136000820693074148e-2,
             0.16227148619889471e-3,
            -0.1442352451485929e-4,
             0.99219525734072e-6,
            -0.5441628049180e-7,
             0.243631662563e-8,
            -0.9077071338e-10,
             0.285926585e-11,
            -0.7716975e-13,
             0.180489e-14,
            -0.3694e-16,
             0.67e-18,
            -0.1e-19);

  arrh1a: array[0..21] of extended = (
            +2.01083504951473379407e0,
             0.592218610036099903e-2,
             0.55274322698414130e-3,
             0.5269873856311036e-4,
             0.506374522140969e-5,
             0.49028736420678e-6,
             0.4763540023525e-7,
             0.465258652283e-8,
             0.45465166081e-9,
             0.4472462193e-10,
             0.437308292e-11,
             0.43568368e-12,
             0.4182190e-13,
             0.441044e-14,
             0.36391e-15,
             0.5558e-16,
            -0.4e-19,
             0.163e-17,
            -0.34e-18,
             0.13e-18,
            -0.4e-19,
             0.1e-19);
begin
  if IsNaN(x) then begin
    {$ifopt R+}
      if RTE_ArgumentRange>0 then RunError(byte(RTE_ArgumentRange));
    {$endif}
    sfc_struve_h1 := NaN_x;
    exit;
  end;
  {See MISCFUN [22], function STRVH1 for Chebyshev coefficients and hints.}
  {As pointed out the phase of Y1(x) is very sensitive for |x| > 1/eps_x. }
  {Therefore in high accuracy tests x must have exactly the same value in }
  {both calculations; for |x| > 1/eps_x^2 the uncertainty vanishes and the}
  {value of H1 is 2/Pi to machine precision, not 0 as in [22]. My function}
  {uses Y1, whereas MISCFUN has two other Chebyshev series.}
  t := abs(x);
  if t <= 9.0 then begin
    y := sqr(t);
    if t < xlow then begin
      {H1(x) = 2/Pi*x^2*(1/3 - 1/45*x^2 + O(x^4))}
      {Note that the factor 1/3 is missing in [22], but xlow is correct}
      sfc_struve_h1 := y/THREE/Pi_2;
    end
    else begin
      t := y/40.5 - 1.0;
      t := CSEvalX(t,arrh1,18);
      sfc_struve_h1 := y*t/Pi_2;
    end;
  end
  else begin
    if t >= 1e40 then begin
      {Avoid squaring overflow and/or unnecessary calculations}
      {H1(x) = Y1(x) + 2/Pi(1 - 1/x^2 + ...) }
      {H1(x) = 2/Pi - (2/Pi)^(1/2)*sin(x+Pi/4)*(1/x)^(1/2) + O((1/x)^(3/2))}
      sfc_struve_h1 := 2.0/Pi;
    end
    else begin
      y := sfc_y1(t);
      t := sqr(t);
      t := (202.5 - t) / (40.5 + t);
      t := CSEvalX(t,arrh1a,22);
      sfc_struve_h1 := y + t/Pi_2;
    end;
  end;
end;


{---------------------------------------------------------------------------}
function strv_sum(c, x: extended; var err: extended): extended;
  {-Sum from Struve power series: sum(x^k/((1.5)_k*(c)_k)}
var
  bn,cn,max,z,sum,t: extended;
  e,y,w: extended;
  n: integer;
const
  NMAX = 200;
begin
  n := 0;
  t := 1.0;
  e := 0.0;
  bn  := 1.5;
  cn  := c;
  sum := 1.0;
  max := 0.0;

  {Kahan summation}
  while n<NMAX do begin
    z := bn*cn;
    t := t*(x/z);
    w := t - e;
    y := sum + w;
    e := (y - sum) - w;
    sum := y;
    z := abs(t);
    if z>max then max := z;
    if z <= eps_x*abs(sum) then break;
    bn := bn+1.0;
    cn := cn+1.0;
    inc(n);
  end;

  if n>=NMAX then begin
    {No convergence}
    if RTE_NoConvergence>0 then RunError(byte(RTE_NoConvergence));
  end;
  err := max*eps_x/abs(sum);
  strv_sum := sum;
end;


{---------------------------------------------------------------------------}
function strv_ae(v,x: extended): extended;
  {-Asymptotic expansion for H_v and L_v, x large (about 40 for H_v, 30 for L_v)}
var
  s,b,c,max,z,sum,conv,conv1: extended;
  k: integer;
const
  KMAX = 1000;
begin
  k := 0;
  b := 0.5;
  c := 0.5-v;
  s := 1.0;
  sum := 1.0;
  max := 0.0;
  conv  := MaxExtended;
  conv1 := conv;

  while k<KMAX do begin
    s := s*b*c*x;
    sum := sum + s;
    z := abs(s);
    if z > max then max := z
    else if (z >= conv) and (z > conv1) then break;
    if z <= eps_x*abs(sum) then break;
    conv1 := conv;
    conv  := z;
    b := b+1.0;
    c := c+1.0;
    k := k+1;
  end;

  if k>=KMAX then begin
    {No convergence}
    if RTE_NoConvergence>0 then RunError(byte(RTE_NoConvergence));
  end;
  strv_ae := sum;
end;


{---------------------------------------------------------------------------}
type
  ti_rec  = record
              v: extended;
              x: extended;
            end;
  pti_rec = ^ti_rec;


{---------------------------------------------------------------------------}
function fsh(t: extended; param: pointer): extended; {$ifdef BIT16} far;{$endif}
  {-Integrand (e^(-xt)(1+t^2)^(v-0.5)}
var
  d,z: extended;
begin
  with pti_rec(param)^ do begin
    z := -t*x;
    if z >= ln_MinExt then begin
      d := exp(z);
      z := power(1.0 + t*t, v - 0.5);
      fsh := d*z;
    end
    else fsh := 0.0;
  end;
end;


{---------------------------------------------------------------------------}
function sfc_struve_h(v,x: extended): extended;
  {-Return H_v(x), the Struve function of order v, x < 0 only if v is an integer.}
var
  g,p,f,y,z,err: extended;
  neval: longint;
  ierr: integer;
  param: ti_rec;
begin
  if IsNaNorInf(x) or IsNaNorInf(v) or ((x<0.0) and (frac(v)<>0.0)) then begin
    {$ifopt R+}
      if RTE_ArgumentRange>0 then RunError(byte(RTE_ArgumentRange));
    {$endif}
    sfc_struve_h := NaN_x;
    exit;
  end;
  if x=0.0 then begin
    if (v>-1.0) or (frac(v)=-0.5) then sfc_struve_h := 0.0
    else if v=-1.0 then sfc_struve_h := 2.0/Pi  {http://functions.wolfram.com/03.09.03.0018.01}
    else begin
      {$ifopt R+}
        if RTE_ArgumentRange>0 then RunError(byte(RTE_ArgumentRange));
      {$endif}
      sfc_struve_h := NaN_x;
    end;
  end
  else if v=0.0 then sfc_struve_h := sfc_struve_h0(x)
  else if v=1.0 then sfc_struve_h := sfc_struve_h1(x)
  else if v=0.5 then sfc_struve_h := vers(x)/sqrt(Pi_2*x)  {HMF[1],12.1.16}
  else if frac(v)=-0.5 then sfc_struve_h := sfc_yv(v,x)
  else begin
    {First compute H_v for |x|}
    z := abs(x);
    y := abs(v);
    p := power(0.5*z, v-1.0);
    if (z>=maxx(20,y)) or (z >= maxx(4,3*y)) then begin
      g := sfc_gamma(v+0.5);
      if z < maxx(40, 1.5*y) then begin
        {Compute integral(e^(-|x|t)(1+t^2)^(v-0.5), t=0..INF)}
        param.x := abs(x);
        param.v := v;
        sfc_intdei_p({$ifdef FPC_ProcVar}@{$endif}fsh, @param, 0, 10*eps_x, f, err, neval, ierr);
        f := z*f*p/(SqrtPi*g);
      end
      else begin
        f := strv_ae(v, -sqr(2.0/z));
        f := f*p/(SqrtPi*g);
      end;
      y := sfc_yv(v,z);
      f := f + y;
    end
    else begin
      y := 0.25*z*z;
      f := strv_sum(1.5+v, -y, err);
      g := sfc_gamma(v + 1.5);
      f := y*p*f/(0.5*sqrtPI*g);
    end;
    if (x<0.0) and (f<>0.0) and (frac(0.5*v)=0.0) then f := -f;
    sfc_struve_h := f;
  end;
end;


{---------------------------------------------------------------------------}
function sfc_struve_l(v, x: extended): extended;
  {-Return L_v(x), the modified Struve function of order v, x < 0 only if v is an integer.}
var
  f,g,z,p,err: extended;
begin
  if IsNaNorInf(x) or IsNaNorInf(v) or ((x<0.0) and (frac(v)<>0.0)) then begin
    {$ifopt R+}
      if RTE_ArgumentRange>0 then RunError(byte(RTE_ArgumentRange));
    {$endif}
    sfc_struve_l := NaN_x;
    exit;
  end;
  if x=0.0 then begin
    if (v>-1.0) or (frac(v)=-0.5) then sfc_struve_l := 0.0
    else if v=-1.0 then sfc_struve_l := 2.0/Pi  {http://functions.wolfram.com/03.10.03.0018.01}
    else begin
      {$ifopt R+}
        if RTE_ArgumentRange>0 then RunError(byte(RTE_ArgumentRange));
      {$endif}
      sfc_struve_l := NaN_x;
    end;
  end
  else if v=0.5 then sfc_struve_l := coshm1(x)/sqrt(Pi_2*x)  {NIST[30],11.4.7}
  else if frac(v)=-0.5 then sfc_struve_l := sfc_iv(-v,x)
  else begin
    z := abs(x);
    p := power(0.5*z, v-1.0);
    if z >= maxx(30,1.5*abs(v)) then begin
      g := sfc_gamma(v+0.5);
      f := strv_ae(v,sqr(2.0/z));
      f := f*p/(sqrtPI*g);
      z := sfc_iv(-v,z);
      f := z - f;
    end
    else begin
      g := sfc_gamma(v + 1.5);
      z := sqr(0.5*z);
      f := strv_sum(1.5+v, z, err);
      f := f*p*z/(0.5*SqrtPi*g);
    end;
    if (x<0.0) and (f<>0.0) and (frac(0.5*v)=0.0) then f := -f;
    sfc_struve_l := f;
  end;
end;


{---------------------------------------------------------------------------}
function sfc_struve_l0(x: extended): extended;
  {-Return L0(x), the modified Struve function of order 0}
begin
  sfc_struve_l0 := sfc_struve_l(0,x);
end;


{---------------------------------------------------------------------------}
function sfc_struve_l1(x: extended): extended;
  {-Return L1(x), the modified Struve function of order 1}
begin
  sfc_struve_l1 := sfc_struve_l(1,x);
end;


{---------------------------------------------------------------------------}
{---------------------- Coulomb related functiona --------------------------}
{---------------------------------------------------------------------------}


{---------------------------------------------------------------------------}
function sfc_coulcl(L: integer; eta: extended): extended;
  {-Return the normalizing constant CL for Coulomb wave function, L >= 0}
var
  x,p: extended;
  k: longint;
const
  epi = 23.0 + 0.1406926327792690057; {exp(pi)}
begin
  if IsNanOrInf(eta) or (L<0) then begin
    sfc_coulcl := Nan_x;
    exit;
  end;
  {Compute C0 with HMF [1], 14.1.8}
  x := TwoPi * eta;
  if eta < 45.0 then p := 1.0/sqrt(exprel(x))
  else begin
     {Using power is more accurate than exp here,}
     {but the error can still be rather large!   }
     p := sqrt(x)*power(epi,-eta)
  end;
  {Recursion using HMF [1], 14.1.10 or NIST [30], 33.2.6}
  x := sqr(eta);
  for k:=1 to L do begin
    p := sqrt(k*k + x)*p/k/(2*k+1);
    if p=0.0 then break;
  end;
  sfc_coulcl := p;
end;


{---------------------------------------------------------------------------}
function cshift0(eta: extended): extended;
  {-Return the Coulomb phase shift for L=0}
const
  x1 = 1.8055419921875;             {high part of zero}
  x2 = 0.5079417606919876367e-5;    {low  part of zero}
  x0 = x1+x2;                       {zero of sigma0}
  z3 = 0.4006856343865314285;       {Zeta(3)/3}
  xlarge = 1e18; {double: 5e14}
const
  p1: array[0..9] of extended = (   {[xx] Table II, n=9}
        1.08871504904797411683e5,
        3.64707573081160914640e5,
        4.88801471582878013158e5,
        3.36275736298197324009e5,
        1.26899226277838479804e5,
        2.60795543527084582682e4,
        2.73352480554497990544e3,
        1.26447543569902963184e2,
        1.85446022125533909390e0,
        1.90716219990037648146e-3);

  q1: array[0..9] of extended = (   {[xx] Table II, n=9}
        6.14884786346071135090e5,
        2.29801588515708014282e6,
        3.50310844128424021934e6,
        2.81194990286041080264e6,
        1.28236441994358406742e6,
        3.35209348711803753154e5,
        4.84319580247948701171e4,
        3.54877039006873206531e3,
        1.11207201299804390166e2,
        1.00000000000000000000);

  p2: array[0..9] of extended = (   {[xx] Table III, n=9}
       -1.044100987526487618670e10,
       -1.508574107180079913696e10,
       -5.582652833355901160542e09,
        4.052529174369477275446e08,
        5.461712273118594275192e08,
        9.510404403068169395714e07,
        6.281126609997342119416e06,
        1.651178048950518520416e05,
        1.498824421329341285521e03,
        2.974686506595477984776);

  q2: array[0..9] of extended = (   {[xx] Table III, n=9}
        1.808868161493543887787e10,
        3.869142051704700267785e10,
        3.003264575147162634046e10,
        1.075554651494601843525e10,
        1.901298501823290694245e09,
        1.665999832151229472632e08,
        6.952188089169487375936e06,
        1.253235080625688652718e05,
        7.904420414560291396996e02,
        1.000000000000000000000);

  p3: array[0..6] of extended = (   {[xx] Table IV, n=6}
        7.08638611024520906826e-3,
       -6.54026368947801591128e-2,
        2.92684143106158043933e-1,
        4.66821392319665609167,
       -3.43943790382690949054,
       -7.72786486869252994370,
       -9.88841771200290647461e-1);

  q3: array[0..6] of extended = (   {[xx] Table IV, n=6}
       -7.08638611024520908189e-3,
        6.59931690706339630254e-2,
       -2.98754421632058618922e-1,
       -4.63752355513412248006,
        3.79700454098863541593,
        7.06184065426336718524,
        1.00000000000000000000);
var
  r,x,z: extended;
begin
  {Ref: Cody/Hillstrom[79] with my improvements for very small and large eta}
  x := abs(eta);
  if x <= 1e-5 then begin
    {Use Im(ln(1+ix)) = x*gamma + zeta(3)/3 x^3 + O(x^5) }
    r := x*(z3*x*x - Eulergamma);
  end
  else if x <= 2.0 then begin
    z := sqr(x);
    r := PolEvalX(z,p1,10);
    r := r / PolEvalX(z,q1,10);
    r := x*((x-x1)-x2)*(x+x0)*r;
  end
  else if x <= 4.0 then begin
    z := sqr(x);
    r := PolEvalX(z,p2,10);
    r := r / PolEvalX(z,q2,10);
    r := x*r;
  end
  else if x < xlarge then begin
    z := 1.0/sqr(x);
    r := PolEvalX(z,p3,7);
    r := r / PolEvalX(z,q3,7);
    r := r + 0.5*ln(1.0 + x*x);
    r := 0.5*arctan(x) + x*r;
  end
  else begin
    {Simplified version of previous case: Avoid overflow  }
    {and unnecessary computation of polynomials and arctan}
    r := x*(ln(x)-1.0);
  end;
  if eta < 0 then r := -r;
  cshift0 := r;
end;


{---------------------------------------------------------------------------}
function sfc_cshift(L: integer; eta: extended): extended;
  {-Return the Coulomb phase shift sigma_L(eta) for L >= 0}
var
  s: extended;
begin
  if IsNanOrInf(eta) or (L<0) then sfc_cshift := Nan_x
  else if eta=0.0 then sfc_cshift := 0.0
  else begin
    s := 0.0;
    {Recursion HMF [1] 14.5.7}
    while L > 0 do begin
      s := s + arctan2(eta, L);
      dec(L);
    end;
    sfc_cshift := cshift0(eta) + s;
  end;
end;


{---------------------------------------------------------------------------}
procedure CoulombSeries(L: integer; eta, x: extended; var fc, fcp: extended; var OK: boolean);
  {-Return FL and FL' using series}
var
  a0,a1,a2: extended;
  d0,d1,dp,xp,s,sp,xm: extended;
  k,l1,l2: longint;
const
  KMAX = 500;
begin
  {Ref: HMF[1], 14.1.4-13,  NIST 33.6.1-3}
  a2 := 1.0;
  l1 := L+1;
  a1 := eta/l1;
  xp := x;
  s  := a2 + a1*x;
  sp := l1*a2 + (L+2)*a1*x;
  d1 := abs(a1*x);
  l2 := 2*L + 1;
  OK := false;
  xm := 0.5*MaxExtended;
  if x>1.0 then xm := xm/x;  {avoid overflow in x^k}
  for k:=2 to KMAX do begin
    if xp>xm then exit;
    xp := xp*x;
    a0 := (2.0*eta*a1 - a2)/(k*(l2 + k));
    d0 := a0*xp;
    dp := d0*(l1 + k);
    s  := s  + d0;
    sp := sp + dp;
    d0 := abs(d0);
    if abs(dp) <= eps_x*abs(sp) then begin
      a2 := eps_x * abs(s);
      if (d0<=a2) and (d1<=a2) then begin
        OK := true;
        break;
      end;
    end;
    a2 := a1;
    a1 := a0;
    d1 := d0;
  end;

  a0  := power(x,L)*sfc_coulcl(L,eta);
  fc  := s*x*a0;
  fcp := sp*a0;
end;


{---------------------------------------------------------------------------}
procedure jwkb(const x, eta, xl: extended; var fjwkb, gjwkb: extended; var iexp: integer);
const
  one   = 1.0;
  aloge = 0.4342944819032518277;
const
  maxexp = 4800;  {double: 300}
var
  gh, hl, sl, gh2, rl2, hll, phi, xll1, phi10: extended;
begin
  {Ref [80]: computes JWKB approximations to Coulomb functions for xl=L >= 0}

  {WE Note: This approximation rather inaccurate. In my implementation it is}
  {called if the series of F,F' does not converge within 500 steps!}
  gh2  := x*(eta + eta - x);
  xll1 := maxx(xl * xl + xl, 0.0);
  if gh2 + xll1 <= 0.0 then exit;   {WE: error return??}

  hll := xll1 + 6/35;
  hl  := sqrt(hll);
  sl  := eta/hl + hl/x;
  rl2 := one + eta*eta / hll;
  gh  := sqrt(gh2 + hll) / x;
  phi := x*gh - 0.5*( hl*ln(sqr(gh + sl) / rl2) - ln(gh) );
  if eta <> 0.0 then begin
    phi := phi - eta * arctan2(x*gh, x - eta);
  end;
  phi10 := -phi * aloge;
  iexp  := trunc(phi10);
  if iexp > maxexp then gjwkb := exp10(phi10 - iexp)
  else begin
    gjwkb := exp(-phi);
    iexp  := 0;
  end;
  fjwkb := 0.5 / (gh * gjwkb)
end;


(* Development revisions:
 0.01  04.09.18  W.Ehrhardt  Initial BP7 port from Fortran
 0.02  05.09.18  we          Removed labels
 0.03  05.09.18  we          Adjusted consts/parameters, some formatting
 0.05  20.09.18  we          cleanup
 0.05  20.09.18  we          removed lrange, kfn, results no vectors
 0.06  20.09.18  we          removed some variables/consts, new ifail codes
 0.07  24.09.18  we          integer lambda, if xlturn then CoulombSeries
 0.08  24.09.18  we          if x<acch then CoulombSeries, check x<=0
 0.09  25.09.18  we          xlow, try CoulombSeries if CF2 does not converge
 0.10  26.09.18  we          some code rearrangements, parameter FOnly
 0.11  27.09.18  we          xm in CoulombSeries
 0.12  27.09.18  we          l -> loop, lambda -> L
*)

{---------------------------------------------------------------------------}
procedure sfc_coul90(L: integer; eta, x: extended; FOnly: boolean;
                     var fc,gc,fcp,gcp: extended; var ifail: integer);
  {-Computes the Coulomb functions fc=F(), fcp=F'(), gc=G(), gcp=G'()}
  { for arguments L >= 0, eta, x > 0 based on A.R. Barnett's coul90.f}
  { subroutine. If FOnly is true, only the F,F' values are computed  }
  { and where many inaccuracies and failure of the original can be   }
  { avoided by using a series approximation if x is small or if the  }
  { second continued fraction does not converge.                     }

  {Pascal port of Barnett [80]. (changed) ifail codes:
   1   JWKB approximation, reduced accuracy
   0   OK
  -1   x < acch
  -2   L <= -1
  -3   cf1 does not converge
  -4   cf2 does not converge}

const
  one   = 1.0;
  limit = 20000;
  xlow  = 0.125;   {argument x <= xlow are handled with series}
var
  a, b, c, d: extended;
  iexp: integer;
  loop: longint;
  ai, bi, di, ar, br, dp, dr, dq, pk, tk, wi,
  pk1, rk2, den, dcf1, acch, e2mm1, etak: extended;
  xinv, omega, accur, small, fjwkb, gjwkb: extended;
  cf1, p, q, f, gamma: extended;
var
  xlturn, SerOK: boolean;
begin
  accur := 2*eps_x;
  acch  := sqrt(accur);
  small := Sqrt_MinExt;
  ifail := 0;
  iexp  := 1;
  gjwkb := 0.0;
  if L < 0  then begin
    ifail := -2;
    exit;
  end;

  if x < 0.0 then begin
    ifail := -1;
    exit;
  end;

  e2mm1  := L;
  e2mm1  := e2mm1*(e2mm1 + 1.0);
  xlturn := (x * (x - 2.0*eta)) < e2mm1;
  e2mm1  := e2mm1 + eta * eta;

  SerOK := true;
  if FOnly then begin
    {For F only: try the series first and exit if OK}
    if xlturn or (x <= xlow) then begin
      CoulombSeries(L, eta, x, fc, fcp, SerOK);
      if SerOK then exit;
    end;
  end;
  if x < acch then begin
    ifail := -1;
    exit;
  end;

  {--- evaluate cf1 = f = df(l,eta,x)/dx / f(l,eta,x) ---}
  xinv := one/x;
  den  := one;   {unnormalised f(maxl,eta,x)}
  pk   := L + one;
  cf1  := eta / pk + pk * xinv;
  if abs(cf1) < small then cf1 := small;
  rk2 := 1.0;
  d   := 0.0;
  c   := cf1;

  {cf1 loop on pk = k starting at L + 1: Lentz-Thompson }
  for loop:=1 to limit do begin
    pk1 := pk + one;
    if eta<>0.0 then begin
      etak := eta / pk;
      rk2  := one + etak * etak;
      tk   := (pk + pk1) * (xinv + etak / pk1);
    end
    else tk := (pk + pk1) * xinv;
    d := tk - rk2 * d; {direct  ratio of b convergents}
    c := tk - rk2 / c; {inverse ratio of a convergents}
    if abs(c) < small then c := small;
    if abs(d) < small then d := small;
    d := one / d;
    dcf1 := d * c;
    cf1 := cf1 * dcf1;
    if d < 0.0 then den := -den;
    pk := pk1;
    if abs(dcf1 - one) < accur then break;
    if loop=limit then begin
      {abort if reach limit}
      {WE: this code has not been hit for millions of random tests}
      {with reasonable parameter values if only F,F' are computed,}
      {i.e. if the series is used for small x.}
      ifail := -3;
      exit;
    end;
  end;

  f := cf1;
  {---------------------------------------------------------------------}
  {-----   evaluate cf2 = p + i.q  using steed's algorithm (no zeros)   }
  {---------------------------------------------------------------------}
  if xlturn then begin
    jwkb(x, eta, L, fjwkb, gjwkb, iexp);
    ifail := 1;
  end;

  if (iexp > 1) or (gjwkb > one/(100.*acch)) then begin
    omega := fjwkb;
    gamma := gjwkb * omega;
    p := f;
    q := one;
  end
  else begin
    {evaluate CF2}
    xlturn := false;
    pk := 0.0;
    wi := eta + eta;
    p  := 0.0;
    q  := one - eta * xinv;
    ar := -e2mm1;
    ai := eta;
    br := 2.0 * (x - eta);
    bi := 2.0;
    dr := br / (br * br + bi * bi);
    di := -bi / (br * br + bi * bi);
    dp := -xinv * (ar * di + ai * dr);
    dq := xinv * (ar * dr - ai * di);
    for loop:=1 to limit do begin
      p  := p + dp;
      q  := q + dq;
      pk := pk + 2.0;
      ar := ar + pk;
      ai := ai + wi;
      bi := bi + 2.0;
      d  := ar * dr - ai * di + br;
      di := ai * dr + ar * di + bi;
      c  := one / (d*d + di * di);
      dr := c*d;
      di := -c*di;
      a  := br * dr - bi * di - one;
      b  := bi * dr + br * di;
      c  := dp * a - dq * b;
      dq := dp * b + dq * a;
      dp := c;
      if (abs(dp) + abs(dq) < (abs(p) + abs(q)) * accur) then break;
      if loop=limit then begin
        if FOnly and SerOK then begin
          {CF2 does not converge, test series (this has not}
          {been done, otherwise SerOK would be false here) }
          CoulombSeries(L, eta, x, fc, fcp, SerOK);
          if SerOK then exit;
        end;
        ifail := -4;
        exit;
      end;
    end;
    {--------------------------------}
    { solve normalising factor omega }
    {--------------------------------}
    gamma := (f - p)/q;
    omega := hypot(1, gamma);
    omega := one / (omega * sqrt(q));
  end;

  fc := copysign(omega, den);
  if xlturn then gc := gjwkb else gc := fc * gamma;
  gcp := gc * (p - q/gamma);
  fcp := fc * f;
end;


{---------------------------------------------------------------------------}
procedure sfc_coul_ffp(L: integer; eta, x: extended; var fc,fcp: extended; var ifail: integer);
  {-Return the regular Coulomb wave functions fc=FL(eta,x) and fcp=FL'(eta,x)}
  { for L >= 0, x > 0. No error if ifail=0, failure if ifail < 0, if ifail=1 }
  { then the very inaccurate JWKB approximation has been computed.}
var
  gc, gcp: extended;
begin
  sfc_coul90(L, eta, x, true, fc, gc, fcp, gcp, ifail);
end;


{---------------------------------------------------------------------------}
function sfc_coul_f(L: integer; eta, x: extended): extended;
  {-Return the regular Coulomb wave functions FL(eta,x) for L >= 0, x > 0}
var
  fc, fcp, gc, gcp: extended;
  ifail: integer;
begin
  sfc_coul90(L, eta, x, true, fc, gc, fcp, gcp, ifail);
  if ifail < 0 then fc := Nan_x;
  sfc_coul_f := fc;
end;


{---------------------------------------------------------------------------}
procedure sfc_coul_ggp(L: integer; eta, x: extended; var gc,gcp: extended; var ifail: integer);
  {-Return the irregular Coulomb wave functions gc=GL(eta,x) and gcp=GL'(eta,x)}
  { for  L >= 0, x > 0. No error if ifail=0, failure if ifail < 0, if ifail=1  }
  { then the very inaccurate JWKB approximation has been computed.}
var
  fc, fcp: extended;
begin
  sfc_coul90(L, eta, x, false, fc, gc, fcp, gcp, ifail);
end;


{---------------------------------------------------------------------------}
{---------------------------------------------------------------------------}

{$ifdef S1Med_Cheb}
{---------------------------------------------------------------------------}
function s1med(x: extended): extended;
  {-First synchrotron function F for x<=4}
const
  pibrt3 = 1.81379936423421785059;
const
  na1 = 15;
  async1h: array[0..na1-1] of THexExtW = (
            ($B81C,$59FF,$DEE9,$F2EA,$4003),  {+3.0364682982501076274E+1}
            ($3F7C,$BF68,$99FD,$88A2,$4003),  {+1.7079395277408394575E+1}
            ($2E54,$6079,$9A39,$91EC,$4001),  {+4.5601321335450728887}
            ($0E50,$0365,$B21F,$8C9D,$3FFE),  {+5.4928124673041997961E-1}
            ($7D85,$6185,$6047,$98C5,$3FFA),  {+3.7297607506930117240E-2}
            ($3DE0,$D842,$3F35,$D380,$3FF5),  {+1.6136243020104124153E-3}
            ($2256,$39F5,$6B5D,$CA21,$3FF0),  {+4.8191677212037073728E-5}
            ($F3AE,$B37E,$6B12,$8D18,$3FEB),  {+1.0512425288938391263E-6}
            ($8BDF,$936D,$69CE,$9603,$3FE5),  {+1.7463850466969204449E-8}
            ($9323,$F51C,$E2AB,$FADB,$3FDE),  {+2.2815486544076691450E-10}
            ($7047,$283B,$5FFB,$A932,$3FD8),  {+2.4044308170103656287E-12}
            ($5855,$04A1,$719F,$BBF1,$3FD1),  {+2.0865880131657537836E-14}
            ($340B,$FA25,$0BA4,$AEDD,$3FCA),  {+1.5166987364826055287E-16}
            ($3180,$C936,$8AD7,$8A3C,$3FC3),  {+9.3672691656568045018E-19}
            ($06D5,$3169,$9B69,$BBFB,$3FBB)); {+4.9758643472029115264E-21}
const
  na2 = 13;
  async2h: array[0..na2-1] of THexExtW = (
            ($00A3,$B3DB,$C955,$E5EC,$3FFD),  {+4.4907216235326608442E-1}
            ($CE2B,$C7F4,$9AF5,$B7FB,$3FFB),  {+8.9835367799418721788E-2}
            ($7CF6,$C408,$8ED8,$84C8,$3FF8),  {+8.1044573772151289397E-3}
            ($0EBC,$CB62,$CC14,$DF6F,$3FF3),  {+4.2617169910891618537E-4}
            ($AD73,$6B90,$DA98,$F7A5,$3FEE),  {+1.4760963127074604820E-5}
            ($9028,$A2BB,$8F87,$C2CF,$3FE9),  {+3.6286336153997505848E-7}
            ($773F,$03A5,$98B6,$E4F4,$3FE3),  {+6.6634807498436372065E-9}
            ($A8DC,$76E0,$4B6B,$D0B4,$3FDD),  {+9.4907716545346839275E-11}
            ($A95D,$97DE,$928B,$97DF,$3FD7),  {+1.0791249128317921126E-12}
            ($E4FD,$F593,$5D53,$B48A,$3FD0),  {+1.0022010253449084350E-14}
            ($CF06,$752F,$CB51,$B298,$3FC9),  {+7.7454038143881772764E-17}
            ($317F,$72B9,$47D9,$9550,$3FC2),  {+5.0589414227490090265E-19}
            ($66CD,$0433,$EBBE,$D5C5,$3FBA)); {+2.8292637966413522328E-21}
var
  async1: array[0..na1-1] of extended absolute async1h;
  async2: array[0..na2-1] of extended absolute async2h;
var
  xp,t,cheb1, cheb2: extended;
begin
  {Evaluation with two Chebyshev series from MISCFUN[22], recomputed}
  {with Maple. This fast but has rel. errors up to about 4000 eps_x.}
  xp := cbrt(x);
  t :=  0.125*x*x - 1.0;
  cheb1 := CSEvalx(t, async1, na1);
  cheb2 := CSEvalx(t, async2, na2);
  {The large errors are a result from cancellation in the differences}
  t := xp*cheb1 - power(xp,11)*cheb2;
  s1med := t - pibrt3 * x;
end;

{$else}

{---------------------------------------------------------------------------}
function syncf(t: extended; p: pointer): extended; {$ifdef BIT16} far;{$endif}
  {-Integrand BesselK(5/3, t)}
begin
  syncf := sfc_kv(5/3, t);
end;


{---------------------------------------------------------------------------}
function s1med(x: extended): extended;
  {-First synchrotron function F for x<=4}
var
  z,t: extended;
var
  neval: longint;
  ier: integer;
const
  c4  = 0.01318359375 + 0.232554244667045742e-4; { = F(4)/4}
begin
  {Integral from x to 4 plus x*const computed with DE integrator. This}
  {is very slow but has much smaller rel. errors (up to about 8 eps_x)}
  sfc_intde_p({$ifdef FPC_ProcVar}@{$endif}syncf, nil, x, 4.0, 8*eps_x, z, t, neval, ier);
  s1med := x*(z + c4);
end;
{$endif}


{---------------------------------------------------------------------------}
function sfc_synchf(x: extended): extended;
  {-Return the first synchrotron function F(x) = integral(x*BesselK(5/3,t), t=x..INF) for x >= 0}
var
  z,t: extended;
const
  xhigh = 11400.0; {double = 745.0}
  xlow  = 0.01;    {double = 0.025}
const
  {Power series in z=x^(1/3), y=z^2}
  s1a : array[0..9] of extended = (
           2.14952824153447863671029126209,        {y^0}
          -1.81379936423421785059407825764,        {y^1}
           0,
           0.403036545287714744383179611642,       {y^3}
           0,
          -0.142393403724728280966288464992,       {y^5}
           0.604554817931572116574769417463e-1,    {y^6}
           0,
          -0.762821805668187219462259633884e-2,    {y^8}
           0.236154225754520358037019303696e-2);   {y^9}
const
  asynca: array[0..24] of extended = (
            2.13293051613550009848,
            0.7413528649542002401e-1,
            0.869680999099641978e-2,
            0.117038262487756921e-2,
            0.16451057986191915e-3,
            0.2402010214206403e-4,
            0.358277563893885e-5,
            0.54477476269837e-6,
            0.8388028561957e-7,
            0.1306988268416e-7,
            0.205309907144e-8,
            0.32518753688e-9,
            0.5179140412e-10,
            0.830029881e-11,
            0.133527277e-11,
            0.21591498e-12,
            0.3499673e-13,
            0.569942e-14,
            0.92906e-15,
            0.15222e-15,
            0.2491e-16,
            0.411e-17,
            0.67e-18,
            0.11e-18,
            0.2e-19);
begin
  if IsNan(x) or (x<0.0) then begin
    sfc_synchf := Nan_x;
    exit;
  end;
  if x <= xlow then begin
    {Power series}
    z := cbrt(x);
    sfc_synchf := z*PolEvalX(z*z, s1a, 10);
  end
  else if x <= 4.0  then sfc_synchf := s1med(x)
  else if x > xhigh then sfc_synchf := 0.0
  else begin
    {MISCFUN[22], Chebyshev series for x > 4}
    t := (12.0 - x) / (x + 4.0);
    z := CSEvalx(t, asynca, 25);
    t := exp(-x)*sqrt(x*Pi_2);
    sfc_synchf := t*z;
  end;
end;


{---------------------------------------------------------------------------}
function sfc_synchg(x: extended): extended;
  {-Return the second synchrotron function G(x) = x*BesselK(2/3,x) for x >= 0}
var
  z,t: extended;
const
  xhigh = 11400.0; {double = 745.0 }
  xlow  = 4e-10;   {double = 1.7e-8}
  c0    = 1.074764120767239318;
  c1    = 1.265719144219806942;
begin
  if IsNan(x) or (x<0.0) then begin
    sfc_synchg := Nan_x;
    exit;
  end;
  if x <= xlow then begin
    {zero and small x}
    z := cbrt(x);
    t := sqr(sqr(z));
    sfc_synchg := z*(c0-t*c1);
  end
  else if x > xhigh then sfc_synchg := 0.0
  else begin
    {K_v has good performance for small and large x, the  }
    {lowest performance is for x ~ 2 (the boundary between}
    {Temme and CF code). But here the Chebyshev expansion }
    {from MISCFUN[22] is too inaccurate.}
    sfc_synchg := x * sfc_kv(2/3,x)
  end;
end;

end.
