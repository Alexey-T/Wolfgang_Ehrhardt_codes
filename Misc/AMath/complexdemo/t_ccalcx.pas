{Test program for AMCmplx / AMCcalc units, (c) W.Ehrhardt 2018}

program t_ccalcx;

{$i STD.INC}

{$x+}  {pchar I/O}
{$i+}  {RTE on I/O error}

{$ifdef BIT16}
{$N+}
{$endif}

{$ifdef Delphi}
{$J+}
{$endif}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

(*
2018-10-17: Initial BP version derived from MPArith/t_rcalc
2018-10-17: Mask exceptions
2018-10-26: hex, fix, help
2018-11-20: Renamed to t_ccalx
*)

uses
  BTypes, AMath, AMCmplx, AMCcalc;


{---------------------------------------------------------------------------}
procedure ShowInfo;
begin
  writeln;
  writeln('Operators:  +  -  *  /  ^             Constants: i, pi, e, ln2, ln10');
  writeln;
  writeln('Functions:  abs, agm, arccos, arccosh, arccot, arccotc, arccoth, arccsc,');
  writeln('            arccsch, arcsec, arcsech, arcsin, arcsinh, arctan, arctanh, arg,');
  writeln('            cbrt, ck, cn, conj, cos, cosh, cot, coth, csc, csch, dilog, dn,');
  writeln('            e1, ei, ee, ek, erf, erfc, exp, expm1, gamma, im, lambertw, li,');
  writeln('            ln, ln1p, lngamma, log10, nroot, psi, re, rstheta, sec, sech, ');
  writeln('            sin, sinh, sn, sqr, sqrt, surd, tan, tanh, wk, zeta');
  writeln;
  writeln('Variables:  x  y  z,  Syntax: Var=expression[;] or Var=_[;]');
  writeln;
  writeln('Other    :  sci,  fix:  display results using scientific/fixed format');
  writeln('            hex         displays last result with hex numbers');
  writeln('            "_<enter>"  re-displays last result');
  writeln;
end;


{---------------------------------------------------------------------------}
procedure HelpLine;
begin
  writeln('Type "?<enter>" to get some info about commands, "\q" or "quit" to end.');
end;



var
  evr: TFEval;
  use_sci: boolean;


{---------------------------------------------------------------------------}
procedure display_result;
begin
  if use_sci then begin
    write(evr.Res.re:26);
    if evr.res.im < 0 then write(' - ')
    else write('  + ');
    writeln(abs(evr.Res.im):26, ' *I');
  end
  else begin
    write(evr.Res.re:1:18);
    if evr.res.im < 0 then write(' - ')
    else write('  + ');
    writeln(abs(evr.Res.im):1:18, ' * i');
  end;
end;


(*********
Notes
sn(1+i, 4)

Maple
  evalf(JacobiSN(1+I, 4));
  0.486949144307539469421299036463 -0 .362598768386387074211432613645*I

Mathematica
  N[JacobiSN[1 + I, 4^2], 30]
  -0.486949144307539469421299036471 + 0.362598768386387074211432613661 i;

MPMath
  >>> ellipfun('sn',1+j,4**2)
  mpc(real='-0.48694914430753946942129903647067', imag='0.36259876838638707421143261366119')

Maxima
  (%i9)	float(jacobi_sn(1+%i,16));
  (%o9)	0.3625987683863873*%i-0.4869491443075384

t_ccalcx
  sn(1+i,4)
  -0.486949144307539470  + 0.362598768386387074 * i
*)



var
  EP,i: integer;
  ac: char8;
  print,script: boolean;
  s: string[255];
  cmd: string[20];
  rc: string[10];

var
  emask: byte;
begin

  GetExceptionMask(emask);
  SetExceptionMask(emask or $3F);

  amc_init_eval(evr);

  use_sci := false;
  script := false;
  rc := '=> ';

  for i:=1 to paramcount do begin
    if (paramstr(i)='/s') or (paramstr(i)='/S') then script := true;
  end;
  writeln('Test of AMCmplx V', AMCmplx_Version, ' / AMCcalc   [t_ccalcx]   (c) W.Ehrhardt 2018');

  if not script then HelpLine;
  writeln;

  repeat
    ac := #0;
    if not script then write(rc);
    readln(s);
    while (s<>'') and (s[1]=' ') do delete(s,1,1);
    while (s<>'') and (s[length(s)]=' ') do delete(s,length(s),1);
    if s='' then continue;

    if s='?' then begin
      ShowInfo;
      continue;
    end;
    if s[1]='"' then begin
      delete(s,1,1);
      writeln(s);
      continue;
    end;

    cmd := s;
    for i:=1 to length(cmd) do cmd[i] := upcase(cmd[i]);

    if (cmd='\Q') or (cmd='Q') or (cmd='QUIT') or (cmd='\@') then break;
    if (cmd='FIX') or (cmd='SCI') then begin
      use_sci := cmd='SCI';
      continue;
    end;
    if (cmd='HEX') then begin
      writeln('Hex result = ', Ext2Hex(evr.Res.re), ' + ', Ext2Hex(evr.Res.im) + ' * i');
      continue;
    end;

    {Echo input in script mode}
    if script then writeln('[Expr] = ',s);

    {Check for trailing ";", i.e. dont print the result}
    if (s<>'') and (s[length(s)]=';') then begin
      delete(s,length(s),1);
      while (s<>'') and (s[length(s)]=' ') do delete(s,length(s),1);
      print := false;
    end
    else print := true;
    if s='' then continue;

    if s<>'_' then begin
      s := s + #0;
      ac := #0;
      if (length(s)>1) and (upcase(s[1]) in ['X','Y','Z']) then begin
        {Check if we have an assignment to x,y,z. Analyse first non-blank}
        {char; next while/if statements are OK because s has trailing #0}
        while (s[2]=' ') and (s[3]=' ') do delete(s,2,1);
        if (s[2]=' ') and (s[3]='=') then delete(s,2,1);
        if s[2]='=' then begin
          ac := upcase(s[1]);
          delete(s,1,2);
          while (s<>'') and (s[1]=' ') do delete(s,1,1);
        end;
      end;
      if s<>'_'#0 then begin
        amc_calculate(@s[1],evr,EP);
      end;
    end
    else if evr.Err>0 then continue;

    if evr.Err>0 then begin
      writeln('Error ', evr.Err,', ',amc_calc_errorstr(evr.Err),':  <',copy(s,EP+1,length(s)-EP-1), '>');
      if evr.Err=Err_Unknown_Function then HelpLine;
    end
    else if evr.Err<0 then writeln(#7'Error: ', evr.Err, ' [',amc_calc_errorstr(evr.Err),']')
    else begin
      if ac in ['X', 'Y', 'Z'] then begin
        case ac of
          'X':  evr.X := evr.Res;
          'Y':  evr.Y := evr.Res;
          'Z':  evr.Z := evr.Res;
        end;
        write(ac,' = ');
      end
      else write('Result = ');
      if print then display_result;
    end;
    evr.Err := 0;
    writeln;
  until false;
end.

