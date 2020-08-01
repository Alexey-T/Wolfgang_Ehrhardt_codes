{Test program for mp_mod_w, (c) W.Ehrhardt 2006}

program t_mpmodw;


{$i STD.INC}
{$i mp_conf.inc}

{$x+}  {pchar I/O}
{$i+}  {RTE on I/O error}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

{$ifndef FPC} {$N+} {$endif}

uses CRT,
     hrtimer,
     mp_types, mp_base,
     {$ifdef MPC_Diagnostic}
       mp_supp,
     {$endif}
     mp_numth,mp_prng;

var
  a,b,c,d,e: mp_int;
  done: boolean;
  i: longint;
  HR: THRTimer;
  n,r: word;
begin
  done:=false;
  StartTimer(HR);
  mp_init5(a,b,c,d,e);
  writeln('Test of MPArith V', MP_VERSION, ' [mp_mod_w]   (c) W.Ehrhardt 2006');
  writeln('Karatsuba cutoffs: mul/sqr = ',mp_mul_cutoff,'/',mp_sqr_cutoff);
  mp_show_plus := true;
  {---------------------------------------------------------------------------}
  repeat
    mp_rand_radix(a,10,1+random(76));
    if random(2)=0 then mp_chs(a,a);
    writeln(mp_decimal(a));
    for n:=1 to $ffff do begin
      if n and $fff = 0 then begin
        if keypressed and (readkey=#27) then begin
          done := true;
          break;
        end;
        write(n,#13);
      end;
      mp_mod_int(a,n,i);
      if i<0 then i:=i+n;
      mp_mod_w(a,n,r);
      if r<>i then begin
        writeln('Err: ',n, ',  r:',r,',  i:',i);
        halt;
      end;
    end;
 until done;
{---------------------------------------------------------------------------}
  mp_clear5(a,b,c,d,e);
  {$ifdef MPC_Diagnostic}
     mp_dump_meminfo;
     mp_dump_diagctr;
  {$endif}

end.
