{Test program for mp library, (c) W.Ehrhardt 2009}
{Exhaustive test of sqrt, cbrt mod p^k for small p and k}

program t_rootpk;


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
  bitarray, {from util archive}
  mp_types, mp_base, mp_numth, mp_supp;

var
  a,b,c,d,e: mp_int;
  BA: TBitArray;

{---------------------------------------------------------------------------}
function TestSQRTpk(p: longint; k: word): boolean;
var
  i: longint;
  Err: integer;
  pk,t,cnt,x: longint;
  OK: boolean;
begin
  writeln('Testing mp_sqrtmodpk with p=',p,' and k=',k);
  pk := 1;
  for i:=1 to k do pk := pk*p;
  BA_Init(BA,pk,OK);
  TestSQRTpk := OK;
  if not OK then begin
    writeln('Error BA_Init');
    exit;
  end;
  cnt := 0;
  mp_set_int(b,p);
  for i:=0 to pk-1 do begin
    if i and $1FF = 0 then write(i,#13);
    t := exptmod32(i,2,pk);;
    if not BA_TestBit(BA,t) then begin
      BA_SetBit(BA,t);
      inc(cnt);
      mp_set_int(a,t);
      mp_sqrtmodpk(a,b,k,c,Err);
      if Err<>0 then begin
        writeln('i=',i,',  Err=',Err);
        OK := false;
        break;
      end;
      if not mp_is_longint(c,x) then begin
        writeln('i=',i,',  no longint: ', mp_decimal(c));
        OK := false;
        break;
      end;
      if x<>i then begin
        if exptmod32(i,2,pk)<>t then begin
           writeln('i=',i,',  ',x,'^2 <> ',t);
           OK := false;
           break;
        end;
      end;
    end;
  end;
  writeln('Quadratic residue cnt: ',cnt);
  for i:=0 to pk-1 do begin
    if i and $1FF = 0 then write(i,#13);
    if not BA_TestBit(BA,i) then begin
      mp_set_int(a,i);
      mp_sqrtmodpk(a,b,k,c,Err);
      if Err=0 then begin
        writeln('i=',i,',  Err=0 for QNR');
        OK := false;
        break;
      end;
    end;
  end;
  if OK then writeln('Tests OK');
  TestSQRTpk := OK;
  BA_Free(BA);
end;


{---------------------------------------------------------------------------}
function TestCBRTpk(p: longint; k: word): boolean;
var
  i: longint;
  Err: integer;
  pk,t,cnt,x: longint;
  OK: boolean;
begin
  writeln('Testing mp_cbrtmodpk with p=',p,' and k=',k);
  pk := 1;
  for i:=1 to k do pk := pk*p;
  BA_Init(BA,pk,OK);
  TestCBRTpk := OK;
  if not OK then exit;
  cnt := 0;
  mp_set_int(b,p);
  for i:=0 to pk-1 do begin
    if i and $1FF = 0 then write(i,#13);
    t := exptmod32(i,3,pk);;
    if not BA_TestBit(BA,t) then begin
      BA_SetBit(BA,t);
      inc(cnt);
      mp_set_int(a,t);
      mp_cbrtmodpk(a,b,k,c,Err);
      if Err<>0 then begin
        writeln('i=',i,',  Err=',Err);
        OK := false;
        break;
      end;
      if not mp_is_longint(c,x) then begin
        writeln('i=',i,',  no longint: ', mp_decimal(c));
        OK := false;
        break;
      end;
      if x<>i then begin
        if exptmod32(i,3,pk)<>t then begin
           writeln('i=',i,',  ',x,'^3 <> ',t);
           OK := false;
           break;
        end;
      end;
    end;
  end;
  writeln('Cubic residue cnt: ',cnt);
  for i:=0 to pk-1 do begin
    if i and $1FF = 0 then write(i,#13);
    if not BA_TestBit(BA,i) then begin
      mp_set_int(a,i);
      mp_cbrtmodpk(a,b,k,c,Err);
      if Err=0 then begin
        writeln('i=',i,',  Err=0 for CNR');
        OK := false;
        break;
      end;
    end;
  end;
  if OK then writeln('Tests OK');
  TestCBRTpk := OK;
  BA_Free(BA);
end;


begin
  writeln('Test of MPArith ', MP_VERSION, ': mp_[sq/cb]rtmodpk   (c) W.Ehrhardt 2009');
  mp_init5(a,b,c,d,e);

{$ifdef BIT32or64}
  if TestSQRTpk( 2,18) and
     TestSQRTpk( 3,10) and
     TestSQRTpk( 5, 7) and
     TestSQRTpk( 7, 6) and
     TestSQRTpk(17, 4) and
     TestSQRTpk(41, 3) then writeln('*** ALL mp_sqrtmodpk tests OK');
     writeln;
  if TestCBRTpk( 2,18) and
     TestCBRTpk( 3,11) and
     TestCBRTpk( 5, 7) and
     TestCBRTpk( 7, 6) then writeln('*** ALL mp_cbrtmodpk tests OK');
{$else}
  if TestSQRTpk( 2,16) and
     TestSQRTpk( 3, 9) and
     TestSQRTpk( 5, 6) and
     TestSQRTpk( 7, 5) and
     TestSQRTpk(17, 3) and
     TestSQRTpk(41, 3) then writeln('*** ALL mp_sqrtmodpk tests OK');
     writeln;
  if TestCBRTpk( 2,16) and
     TestCBRTpk( 3, 9) and
     TestCBRTpk( 5, 6) and
     TestCBRTpk( 7, 5) then writeln('*** ALL mp_cbrtmodpk tests OK');
{$endif}

  mp_clear5(a,b,c,d,e);
  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}
end.
