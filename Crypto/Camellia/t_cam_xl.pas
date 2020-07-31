{-Test prog for Camellia modes, ILen > $FFFF for 32 bit, we July 2010}

program T_CAM_XL;

{$i STD.INC}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

{$ifndef FPC}
  {$N+}
{$endif}

uses
  {$ifdef WINCRT}
     wincrt,
  {$endif}
  {$ifdef USEDLL}
    {$ifdef VirtualPascal}
      CAM_Intv,
    {$else}
      CAM_Intf,
    {$endif}
  {$else}
    CAM_Base, CAM_CTR, CAM_CFB, CAM_OFB, CAM_CBC, CAM_ECB, CAM_OMAC, CAM_EAX,
  {$endif}
  BTypes, mem_util;

const
  key128 : array[0..15] of byte = ($2b,$7e,$15,$16,$28,$ae,$d2,$a6,
                                   $ab,$f7,$15,$88,$09,$cf,$4f,$3c);

      IV : array[0..15] of byte = ($00,$01,$02,$03,$04,$05,$06,$07,
                                   $08,$09,$0a,$0b,$0c,$0d,$0e,$0f);

     CTR : array[0..15] of byte = ($f0,$f1,$f2,$f3,$f4,$f5,$f6,$f7,
                                   $f8,$f9,$fa,$fb,$fc,$fd,$fe,$ff);

{$ifndef BIT16}
const BSIZE=400000;
{$else}
const BSIZE=10000;
{$endif}

const
  BS1 = CAMBLKSIZE*(BSIZE div (2*CAMBLKSIZE));

type
  TBuf = array[0..BSIZE-1] of byte;

var
  pt, ct, dt: Tbuf;

var
  Context: TCAMContext;


{---------------------------------------------------------------------------}
function test(px,py: pointer): Str255;
begin
  if compmemxl(px,py,sizeof(TBuf)) then test := 'OK' else test := 'Error';
end;


{---------------------------------------------------------------------------}
procedure TestCFB;
begin
  fillchar(dt,sizeof(dt),0);
  if CAM_CFB_Init(key128, 8*sizeof(key128), TCAMBlock(IV), context)<>0 then begin
    writeln('*** Error CFB_Init');
    exit;
  end;
  if CAM_CFB_Encrypt(@pt, @ct, BS1, context)<>0 then begin
    writeln('*** Error CFB_Encrypt 1');
    exit;
  end;
  if CAM_CFB_Encrypt(@pt[BS1], @ct[BS1], sizeof(TBuf)-BS1, context)<>0 then begin
    writeln('*** Error CFB_Encrypt 2');
    exit;
  end;
  if CAM_CFB_Init(key128, 8*sizeof(key128), TCAMBlock(IV), context)<>0 then begin
    writeln('*** Error CFB_Init');
    exit;
  end;
  if CAM_CFB_Decrypt(@ct, @dt, sizeof(TBuf), context)<>0 then begin
    writeln('*** Error CFB_Decrypt');
    exit;
  end;
  writeln('CFB  test: ', test(@pt,@dt));
end;



{---------------------------------------------------------------------------}
procedure TestCBC;
begin
  fillchar(dt,sizeof(dt),0);
  if CAM_CBC_Init(key128, 8*sizeof(key128), TCAMBlock(IV), context)<>0 then begin
    writeln('*** Error CBC_Init');
    exit;
  end;
  if CAM_CBC_Encrypt(@pt, @ct, BS1, context)<>0 then begin
    writeln('*** Error CBC_Encrypt 1');
    exit;
  end;
  if CAM_CBC_Encrypt(@pt[BS1], @ct[BS1], sizeof(TBuf)-BS1, context)<>0 then begin
    writeln('*** Error CBC_Encrypt 2');
    exit;
  end;
  if CAM_CBC_Init(key128, 8*sizeof(key128), TCAMBlock(IV), context)<>0 then begin
    writeln('*** Error CBC_Init');
    exit;
  end;
  if CAM_CBC_Decrypt(@ct, @dt, sizeof(TBuf), context)<>0 then begin
    writeln('*** Error CBC_Decrypt');
    exit;
  end;
  writeln('CBC  test: ', test(@pt,@dt));
end;


{---------------------------------------------------------------------------}
procedure TestECB;
begin
  fillchar(dt,sizeof(dt),0);
  if CAM_ECB_Init(key128, 8*sizeof(key128), context)<>0 then begin
    writeln('*** Error ECB_Init');
    exit;
  end;
  if CAM_ECB_Encrypt(@pt, @ct, BS1, context)<>0 then begin
    writeln('*** Error ECB_Encrypt 1');
    exit;
  end;
  if CAM_ECB_Encrypt(@pt[BS1], @ct[BS1], sizeof(TBuf)-BS1, context)<>0 then begin
    writeln('*** Error ECB_Encrypt 2');
    exit;
  end;
  if CAM_ECB_Init(key128, 8*sizeof(key128), context)<>0 then begin
    writeln('*** Error ECB_Init');
    exit;
  end;
  if CAM_ECB_Decrypt(@ct, @dt, sizeof(TBuf), context)<>0 then begin
    writeln('*** Error ECB_Decrypt');
    exit;
  end;
  writeln('ECB  test: ', test(@pt,@dt));
end;


{---------------------------------------------------------------------------}
procedure TestCTR;
begin
  fillchar(dt,sizeof(dt),0);
  if CAM_CTR_Init(key128, 8*sizeof(key128), TCAMBlock(CTR), context)<>0 then begin
    writeln('*** Error CTR_Init');
    exit;
  end;
  if CAM_CTR_Encrypt(@pt, @ct, BS1, context)<>0 then begin
    writeln('*** Error CTR_Encrypt 1');
    exit;
  end;
  if CAM_CTR_Encrypt(@pt[BS1], @ct[BS1], sizeof(TBuf)-BS1, context)<>0 then begin
    writeln('*** Error CTR_Encrypt 2');
    exit;
  end;
  if CAM_CTR_Init(key128, 8*sizeof(key128), TCAMBlock(CTR), context)<>0 then begin
    writeln('*** Error CTR_Init');
    exit;
  end;
  if CAM_CTR_Decrypt(@ct, @dt, sizeof(TBuf), context)<>0 then begin
    writeln('*** Error CTR_Decrypt');
    exit;
  end;
  writeln('CTR  test: ', test(@pt,@dt));
end;


{---------------------------------------------------------------------------}
procedure TestOFB;
begin
  fillchar(dt,sizeof(dt),0);
  if CAM_OFB_Init(key128, 8*sizeof(key128), TCAMBlock(IV), context)<>0 then begin
    writeln('*** Error OFB_Init');
    exit;
  end;
  if CAM_OFB_Encrypt(@pt, @ct, BS1, context)<>0 then begin
    writeln('*** Error OFB_Encrypt 1');
    exit;
  end;
  if CAM_OFB_Encrypt(@pt[BS1], @ct[BS1], sizeof(TBuf)-BS1, context)<>0 then begin
    writeln('*** Error OFB_Encrypt 2');
    exit;
  end;
  if CAM_OFB_Init(key128, 8*sizeof(key128), TCAMBlock(IV), context)<>0 then begin
    writeln('*** Error OFB_Init');
    exit;
  end;
  if CAM_OFB_Decrypt(@ct, @dt, sizeof(TBuf), context)<>0 then begin
    writeln('*** Error OFB_Decrypt');
    exit;
  end;
  writeln('OFB  test: ', test(@pt,@dt));
end;


{---------------------------------------------------------------------------}
procedure TestEAX;
const
  hex32: array[1..32] of byte = ($00,$01,$02,$03,$04,$05,$06,$07,
                                 $08,$09,$0a,$0b,$0c,$0d,$0e,$0f,
                                 $10,$11,$12,$13,$14,$15,$16,$17,
                                 $18,$19,$1a,$1b,$1c,$1d,$1e,$1f);
var
  ctx: TCAM_EAXContext;
  te,td: TCAMBlock;
begin
  fillchar(dt,sizeof(dt),0);
  if CAM_EAX_Init(key128, 128, hex32, sizeof(hex32), ctx) <>0 then begin
    writeln('*** Error EAX_Init');
    exit;
  end;
  if CAM_EAX_Provide_Header(@hex32, sizeof(hex32),ctx) <>0 then begin
    writeln('*** Error EAX_Provide_Header');
    exit;
  end;
  if CAM_EAX_Encrypt(@pt, @ct, BS1, ctx) <>0 then begin
    writeln('*** Error EAX_Encrypt 1');
    exit;
  end;
  if CAM_EAX_Encrypt(@pt[BS1], @ct[BS1], sizeof(TBuf)-BS1, ctx) <>0 then begin
    writeln('*** Error EAX_Encrypt 2');
    exit;
  end;
  CAM_EAX_Final(te, ctx);

  if CAM_EAX_Init(key128, 128, hex32, sizeof(hex32), ctx) <>0 then begin
    writeln('*** Error EAX_Init');
    exit;
  end;
  if CAM_EAX_Provide_Header(@hex32, sizeof(hex32),ctx) <>0 then begin
    writeln('*** Error EAX_Provide_Header');
    exit;
  end;
  if CAM_EAX_Decrypt(@ct, @dt, sizeof(TBuf), ctx) <>0 then begin
    writeln('*** Error EAX_Encrypt');
    exit;
  end;
  CAM_EAX_Final(td, ctx);

  if not compmemxl(@pt, @dt, sizeof(TBuf)) then begin
    writeln('*** Dec EAX diff buf');
    exit;
  end;
  if not compmem(@te, @td, sizeof(td)) then begin
    writeln('*** Dec EAX diff tag');
    exit;
  end;
  write('EAX  test: OK');
end;


begin
  {$ifdef USEDLL}
    writeln('Test program for CAM_DLL V',CAM_DLL_Version,'   (C) 2010  W.Ehrhardt');
  {$else}
    writeln('Test program for Camellia modes    (C) 2010  W.Ehrhardt');
  {$endif}
  writeln('Test of encrypt/decrypt routines using single calls with ',BS1,'/',BSize, ' bytes.');
  RandMemXL(@pt, sizeof(TBuf));
  TestCBC;
  TestCFB;
  TestCTR;
  TestECB;
  TestOFB;
  TestEAX;
  writeln;
end.
