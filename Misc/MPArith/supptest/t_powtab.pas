{Calculate tables for AMath.power function   (c) 2010 W.Ehrhardt}

program t_powtab;

{$i STD.INC}

{$ifdef AppCons}
  {$apptype console}
{$endif}

{$ifdef BIT64}
  {$message error 'Not for 64 bit, this MUST have 10-bytes extendeds'}
{$endif}


{.$define longformat} {One entry per line Hex / Dec}

{$ifdef BIT16}
{$N+}
{$F+}
{$endif}

{$x+}

uses
  {$ifdef WINCRT}
    WinCRT,
  {$endif}
  {$ifdef MPC_Diagnostic}
    mp_supp,
  {$endif}
  mp_types, mp_base, mp_real;


const
  NP = 512;  {Size of power table, must be power of two, 512 is used in amath}

{---------------------------------------------------------------------------}
function HexW(w: word): mp_string;
  {-longint as hex string, LSB first}
var
  i: integer;
  s: string[8];
begin
  s := '';
  for i:=0 to 3 do begin
    s := mp_lcrmap[w and $F] + s;
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
const
  NP2 = NP div 2;
var
  pa: array[0..NP] of extended;
  pb: array[0..NP2] of extended;
var
  a,b,c: mp_float;
var
  i: integer;

begin
  writeln('Test MP_Arith V', MP_VERSION, '   (c) 2010 W.Ehrhardt');
  writeln('Karatsuba  cutoffs: mul/sqr = ',mp_mul_cutoff,'/',mp_sqr_cutoff);
  writeln('Toom-3, BZ cutoffs: mul/sqr = ',mp_t3m_cutoff,'/',mp_t3s_cutoff,  ',  div = ',mp_bz_cutoff);
  writeln('Current mp_float default bit precision = ', mpf_get_default_prec,
          ',  decimal precision = ', mpf_get_default_prec*ln(2)/ln(10):1:1);
  writeln;
  writeln('T_PowTab - Calculate tables for AMath.power function');
  writeln;
  writeln;
  mp_show_plus := true;

  mpf_initp3(a,b,c,mpf_get_default_prec);

  for i:=0 to NP do begin
    {a = 2^(-i/NP)}
    mpf_set_ext(a,i);
    mpf_div_ext(a,-NP,a);
    mpf_exp2(a,a);
    pa[i] := mpf_toextended(a);
    if i and 1 = 0 then begin
      mpf_sub_ext(a,pa[i],b);
      pb[i div 2] := mpf_toextended(b);
    end;
  end;

{$ifdef longformat}
  for i:=0 to NP  do writeln('  ', HexExtended(pa[i]),',    {',pa[i]:26,'}');
  writeln;
  for i:=0 to NP2 do writeln('  ', HexExtended(pa[i]),',    {',pb[i]:26,'}');
{$else}
  writeln('const NXT = ',NP,';');
  writeln('const A: array[0..NXT] of THexExtW = (');
  for i:=0 to NP do begin
    write('  ', HexExtended(pa[i]));
    if i<>NP then write(',') else write(');');
    if i mod 3 = 2 then writeln;
  end;
  writeln;
  writeln;
  writeln('const B: array[0..NXT div 2] of THexExtW = (');
  for i:=0 to NP2 do begin
    write('  ', HexExtended(pb[i]));
    if i<>NP2 then write(',') else write(');');
    if i mod 3 = 2 then writeln;
  end;
  writeln;
{$endif}

  mpf_clear3(a,b,c);

  {$ifdef MPC_Diagnostic}
    writeln;
    writeln;
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}

end.
