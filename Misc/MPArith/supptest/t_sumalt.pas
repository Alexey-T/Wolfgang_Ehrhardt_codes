{Test program for mp_real/mpf_sumalt, (c) W.Ehrhardt 2009}

program t_sumalt;

{$i STD.INC}
{$i mp_conf.inc}

{$x+}  {pchar I/O}
{$i+}  {RTE on I/O error}

{$ifdef VER70}
{$N+,F+}
{$endif}


{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT}
    WinCRT,
  {$endif}
  {$ifdef MPC_Diagnostic}
    mp_supp,
  {$endif}
  HRTimer, mp_types, mp_base, mp_real;


{---------------------------------------------------------------------------}
function catalan_term(k: longint; var num, den: longint): boolean;
begin
  if (k>=0) and (k<$8000) then begin
    if odd(k) then num := -1 else num := 1;
    den := sqr(2*k+1);
    catalan_term := true;
  end
  else catalan_term := false;
end;


{---------------------------------------------------------------------------}
function gregory_term(k: longint; var num, den: longint): boolean;
begin
  if (k>=0) and (k<$40000000) then begin
    if odd(k) then num := -1 else num := 1;
    den := 2*k+1;
    gregory_term := true;
  end
  else gregory_term := false;
end;


{---------------------------------------------------------------------------}
function ln2_term(k: longint; var num, den: longint): boolean;
begin
  if (k>=0) and (k<Maxlongint) then begin
    if odd(k) then num := -1 else num := 1;
    den := k+1;
    ln2_term := true;
  end
  else ln2_term := false;
end;


{---------------------------------------------------------------------------}
function zeta2_term(k: longint; var num, den: longint): boolean;
begin
  if (k>=0) and (k<46340) then begin
    if odd(k) then num := -1 else num := 1;
    den := sqr(k+1);
    zeta2_term := true;
  end
  else zeta2_term := false;
end;

{---------------------------------------------------------------------------}
function zeta2_fterm(k: longint; var term: mp_float): boolean;
begin
  if (k>=0) and (k<46340) then begin
    mpf_set_int(term,sqr(k+1));
    mpf_inv(term,term);
    if odd(k) then s_mpf_chs(term);
    zeta2_fterm := true;
  end
  else zeta2_fterm := false;
end;


{---------------------------------------------------------------------------}
function apery_term(k: longint; var num, den: longint): boolean;
begin
  if (k>=0) and (k<1290) then begin
    apery_term := true;
    if odd(k) then num := -1 else num := 1;
    den := sqr(k+1)*(k+1);
  end
  else apery_term := false;
end;

{---------------------------------------------------------------------------}
function apery_fterm(k: longint; var term: mp_float): boolean;
begin
  if (k>=0) and (k<46340) then begin
    apery_fterm := true;
    mpf_set_int(term,sqr(k+1));
    mpf_mul_int(term,k+1,term);
    mpf_inv(term,term);
    if odd(k) then s_mpf_chs(term);
  end
  else apery_fterm := false;
end;


var
  a,b,c,d,e: mp_float;
  HR: THRTimer;
  Err: integer;

{$ifdef BIT32or64}
  {$ifdef MP_32BIT}
    const DPREC = 20*100;
  {$else}
    const DPREC = 20*100;
  {$endif}
{$else}
    const DPREC = 4*100;
{$endif}


begin
  StartTimer(HR);
  mpf_set_default_prec(trunc(1+DPREC*ln(10)/ln(2)));

  writeln('Test of MPArith V', MP_VERSION, '  [mpf_sumalt/f]   (c) 2009 W.Ehrhardt ');
  writeln('Current mp_float default bit precision = ', mpf_get_default_prec,
          ',  decimal precision = ', mpf_get_default_prec*ln(2)/ln(10):1:1);
  writeln;

  mpf_initp5(a,b,c,d,e,mpf_get_default_prec);


  RestartTimer(HR);
  mpf_sumalt({$ifdef FPC_ProcVar}@{$endif}gregory_term, 0, a, Err);
  writeln('Time [s]: ',ReadSeconds(HR):1:3);
  if Err<>0 then writeln('Sumalt for Gregory,  Err=', Err)
  else begin
    mpf_mul_2k(a,2,a);
    mpf_writeln('4*Gregory = ',a, DPREC);
    mpf_set_pi(b);
    mpf_sub(b,a,b);
    mpf_writeln('Check = ',b, 60);
  end;
  writeln;

  RestartTimer(HR);
  mpf_sumalt({$ifdef FPC_ProcVar}@{$endif}ln2_term, 0, a, Err);
  writeln('Time [s]: ',ReadSeconds(HR):1:3);
  if Err<>0 then writeln('Sumalt for ln2,  Err=', Err)
  else begin
    mpf_writeln('ln2 = ',a, DPREC);
    mpf_set_ln2(b);
    mpf_sub(b,a,b);
    mpf_writeln('Check = ',b, 60);
  end;
  writeln;

  RestartTimer(HR);
  mpf_sumalt({$ifdef FPC_ProcVar}@{$endif}catalan_term, 0, a, Err);
  writeln('Time [s]: ',ReadSeconds(HR):1:3);
  if Err<>0 then writeln('Sumalt for Catalan,  Err=', Err)
  else begin
    mpf_writeln('Catalan = ',a, DPREC);
  end;
  writeln;

  RestartTimer(HR);
  mpf_sumalt({$ifdef FPC_ProcVar}@{$endif}zeta2_term, 0, a, Err);
  writeln('Time [s]: ',ReadSeconds(HR):1:3);
  if Err<>0 then writeln('Sumalt for Zeta(2),  Err=', Err)
  else begin
    mpf_mul_2k(a,1,a);
    mpf_writeln('R Zeta(2) = ',a, DPREC);
    mpf_set_pi(b);
    mpf_sqr(b,b);
    mpf_div_d(b,6,b);
    mpf_sub(b,a,b);
    mpf_writeln('Check = ',b, 60);
  end;
  writeln;

  RestartTimer(HR);
  mpf_sumaltf({$ifdef FPC_ProcVar}@{$endif}zeta2_fterm, 0, a, Err);
  writeln('Time [s]: ',ReadSeconds(HR):1:3);
  if Err<>0 then writeln('Sumaltf for Zeta(2),  Err=', Err)
  else begin
    mpf_mul_2k(a,1,a);
    mpf_writeln('F Zeta(2) = ',a, DPREC);
    mpf_set_pi(b);
    mpf_sqr(b,b);
    mpf_div_d(b,6,b);
    mpf_sub(b,a,b);
    mpf_writeln('Check = ',b, 60);
  end;
  writeln;

  RestartTimer(HR);
  mpf_sumalt({$ifdef FPC_ProcVar}@{$endif}apery_term, 0, a, Err);
  writeln('Time [s]: ',ReadSeconds(HR):1:3);
  if Err<>0 then begin
    writeln('Sumalt for Apery = Zeta(3),  Err=', Err);
    mpf_set0(a);
  end
  else begin
    mpf_mul_2k(a,2,a);
    mpf_div_d(a,3,a);
    mpf_writeln('[num/den term] Apery = Zeta(3) = ',a, DPREC);
  end;
  writeln;


  RestartTimer(HR);
  mpf_sumaltf({$ifdef FPC_ProcVar}@{$endif}apery_fterm, 0, d, Err);
  writeln('Time [s]: ',ReadSeconds(HR):1:3);
  if Err<>0 then begin
    writeln('Sumaltf for Apery = Zeta(3),  Err=', Err);
    mpf_set0(e);
  end
  else begin
    mpf_mul_2k(d,2,d);
    mpf_div_d(d,3,d);
    mpf_writeln('  [Float term] Apery = Zeta(3) = ',d, DPREC);
  end;
  writeln;
  if (not mpf_is0(a)) and (not mpf_is0(d)) then begin
    mpf_sub(a,d,e);
    mpf_writeln('num/den - float = ',e, 50);
  end;

  mpf_clear5(a,b,c,d,e);

  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}
end.

