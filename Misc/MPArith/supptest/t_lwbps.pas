{Calculate Lambert W branch point series coefficients, (c) W.Ehrhardt 2010}

program t_lwbps;


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

{$define doubleout}


uses
  {$ifdef WINCRT} WinCRT,{$endif}
  mp_types, mp_base,
  {$ifdef MPC_Diagnostic}
    mp_supp,
  {$endif}
  mp_numth, mp_real, mp_ratio;


{---------------------------------------------------------------------------}
function HexW(w: word): mp_string;
  {-longint as hex string, LSB first}
var
  i: integer;
  s: string[8];
begin
  s := '';
  for i:=0 to 3 do begin
    s := mp_ucrmap[w and $F] + s;
    w := w shr 4;
  end;
  HexW := s;
end;


{---------------------------------------------------------------------------}
function HexExtended(x: extended): mp_string;
  {-Extended as Hex array of word}
var
  xa: array[0..4] of word absolute x;
begin
  HexExtended := '($'+HexW(xa[0])+',$'+HexW(xa[1])+',$'+HexW(xa[2])+',$'+HexW(xa[3])+',$'+HexW(xa[4])+')';
end;


{---------------------------------------------------------------------------}
function HexDouble(d: double): mp_string;
var
  da: TMPHexDblW;
begin
  da := TMPHexDblW(d);
  HexDouble := '($'+HexW(da[0])+',$'+HexW(da[1])+',$'+HexW(da[2])+',$'+HexW(da[3])+')';
end;


const
  NC = 20;
var
  a,m: array[0..NC] of mp_rat;
  x,y,z: mp_rat;
  k,j: integer;
  u,v,w: mp_float;
  tx: extended;
  td: double;
begin
  writeln('Test MPArith ', MP_ShortVERS, ':  Lambert W branch point series    (c) 2010 W.Ehrhardt');
  writeln('Current mp_float default bit precision = ', mpf_get_default_prec,
          ',  decimal precision = ', mpf_get_default_prec*ln(2)/ln(10):1:1);
  writeln;

  mpr_init_multi(a);
  mpr_init_multi(m);
  mpr_init3(x,y,z);
  mpf_init3(u,v,w);

  mpr_set_int(a[0],2,1);
  mpr_set_int(a[1],-1,1);
  mpr_set_int(m[0],-1,1);
  mpr_set_int(m[1],1,1);

  {R.M. Corless, G.H. Gonnet, D.E.G. Hare, D.J.Jeffrey, D.E.Knuth, On}
  {the Lambert W Function, Adv. Comput. Math., 5 (1996), pp. 329-359.}
  {Formulas 4.23 and 4.24}

  writeln('Lambert W: Branch point series coefficients mu[k]');
  writeln('mu[ 0] = ', mpr_decimal(m[0]));
  writeln('mu[ 1] = ', mpr_decimal(m[1]));
  for k:=2 to NC do begin
    mpr_zero(z);
    for j:=2 to k-1 do begin
      mpr_mul(m[j],m[k+1-j],x);
      mpr_add(z,x,z);
    end;
    mpr_copy(z,a[k]);
    mpr_div_2(m[k-2],x);
    mpr_div_2k(a[k-2],2,y);
    mpr_add(x,y,z);
    mpr_mul_int(z,k-1,z);
    mpr_div_int(z,k+1,z);
    mpr_div_2(a[k],x);
    mpr_sub(z,x,z);
    mpr_div_int(m[k-1],k+1,x);
    mpr_sub(z,x,m[k]);
    writeln('mu[',k:2,'] = ', mpr_decimal(m[k]));
  end;

  writeln;
  mp_show_plus := true;
  for k:=0 to NC do begin
    mpf_set_mpi(u,m[k].num);
    mpf_div_mpi(u,m[k].den,u);
    {$ifdef doubleout}
      td := mpf_todouble(u);
      writeln(HexDouble(td), '  {',mpf_decimal(u,20),'}');
    {$else}
      tx := mpf_toextended(u);
      writeln(HexExtended(tx), '  {',mpf_decimal(u,20),'}');
    {$endif}
  end;

  writeln;
  writeln('Lambert W: Scaled branch point series coefficients mu[k]*sqrt(2e)^k');
  {v = sqrt(2e)}
  mpf_set_dbl(v,1);
  mpf_exp(v,v);
  mpf_mul_2k(v,1,v);
  mpf_sqrt(v,v);
  mpf_set1(w);
  for k:=0 to NC do begin
    {here w = v^k = sqrt(2e)^k}
    mpf_set_mpi(u,m[k].num);
    mpf_div_mpi(u,m[k].den,u);
    mpf_mul(u,w,u);
    mpf_mul(w,v,w);
    {$ifdef doubleout}
      td := mpf_todouble(u);
      writeln(HexDouble(td), '  {',mpf_decimal(u,20),'}');
    {$else}
      tx := mpf_toextended(u);
      writeln(HexExtended(tx), '  {',mpf_decimal(u,20),'}');
    {$endif}
  end;

  mpf_clear3(u,v,w);
  mpr_clear_multi(a);
  mpr_clear_multi(m);
  mpr_clear3(x,y,z);
  {$ifdef MPC_Diagnostic}
     mp_dump_meminfo;
     mp_dump_diagctr;
  {$endif}
end.
