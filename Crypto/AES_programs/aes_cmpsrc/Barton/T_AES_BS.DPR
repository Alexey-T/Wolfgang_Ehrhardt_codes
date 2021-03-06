{AES speed test program for Barton dcpcrypt2 , W.Ehrhardt Dec 2003}
{compile with !C_LT.BAT in dcpcrypt2 base direytory}

program t_aes_bs;


{$apptype console}

{$J+}

uses
  SysUtils, Classes,
  DCPcrypt2, DCPblockciphers, DCPrijndael;

var
  AES: TDCP_rijndael;

var
  key128 : array[0..15] of byte = ($2b,$7e,$15,$16,$28,$ae,$d2,$a6,
                                   $ab,$f7,$15,$88,$09,$cf,$4f,$3c);

      IV : array[0..15] of byte = ($00,$01,$02,$03,$04,$05,$06,$07,
                                   $08,$09,$0a,$0b,$0c,$0d,$0e,$0f);

     CTR : array[0..15] of byte = ($f0,$f1,$f2,$f3,$f4,$f5,$f6,$f7,
                                   $f8,$f9,$fa,$fb,$fc,$fd,$fe,$ff);

  plain  : array[0..63] of byte = ($6b,$c1,$be,$e2,$2e,$40,$9f,$96,
                                   $e9,$3d,$7e,$11,$73,$93,$17,$2a,
                                   $ae,$2d,$8a,$57,$1e,$03,$ac,$9c,
                                   $9e,$b7,$6f,$ac,$45,$af,$8e,$51,
                                   $30,$c8,$1c,$46,$a3,$5c,$e4,$11,
                                   $e5,$fb,$c1,$19,$1a,$0a,$52,$ef,
                                   $f6,$9f,$24,$45,$df,$4f,$9b,$17,
                                   $ad,$2b,$41,$7b,$e6,$6c,$37,$10);

  ct_cbc : array[0..63] of byte = ($76,$49,$ab,$ac,$81,$19,$b2,$46,
                                   $ce,$e9,$8e,$9b,$12,$e9,$19,$7d,
                                   $50,$86,$cb,$9b,$50,$72,$19,$ee,
                                   $95,$db,$11,$3a,$91,$76,$78,$b2,
                                   $73,$be,$d6,$b8,$e3,$c1,$74,$3b,
                                   $71,$16,$e6,$9e,$22,$22,$95,$16,
                                   $3f,$f1,$ca,$a1,$68,$1f,$ac,$09,
                                   $12,$0e,$ca,$30,$75,$86,$e1,$a7);

  ct_cfb : array[0..63] of byte = ($3b,$3f,$d9,$2e,$b7,$2d,$ad,$20,
                                   $33,$34,$49,$f8,$e8,$3c,$fb,$4a,
                                   $c8,$a6,$45,$37,$a0,$b3,$a9,$3f,
                                   $cd,$e3,$cd,$ad,$9f,$1c,$e5,$8b,
                                   $26,$75,$1f,$67,$a3,$cb,$b1,$40,
                                   $b1,$80,$8c,$f1,$87,$a4,$f4,$df,
                                   $c0,$4b,$05,$35,$7c,$5d,$1c,$0e,
                                   $ea,$c4,$c6,$6f,$9f,$f7,$f2,$e6);

  ct_ctr : array[0..63] of byte = ($87,$4d,$61,$91,$b6,$20,$e3,$26,
                                   $1b,$ef,$68,$64,$99,$0d,$b6,$ce,
                                   $98,$06,$f6,$6b,$79,$70,$fd,$ff,
                                   $86,$17,$18,$7b,$b9,$ff,$fd,$ff,
                                   $5a,$e4,$df,$3e,$db,$d5,$d3,$5e,
                                   $5b,$4f,$09,$02,$0d,$b0,$3e,$ab,
                                   $1e,$03,$1d,$da,$2f,$be,$03,$d1,
                                   $79,$21,$70,$a0,$f3,$00,$9c,$ee);

  ct_ofb : array[0..63] of byte = ($3b,$3f,$d9,$2e,$b7,$2d,$ad,$20,
                                   $33,$34,$49,$f8,$e8,$3c,$fb,$4a,
                                   $77,$89,$50,$8d,$16,$91,$8f,$03,
                                   $f5,$3c,$52,$da,$c5,$4e,$d8,$25,
                                   $97,$40,$05,$1e,$9c,$5f,$ec,$f6,
                                   $43,$44,$f7,$a8,$22,$60,$ed,$cc,
                                   $30,$4c,$65,$28,$f6,$59,$c7,$78,
                                   $66,$a5,$10,$d9,$c1,$d6,$ae,$5e);

var
  ct: array[0..63] of byte;

const
  N : longint = 8*1000000;


{---------------------------------------------------------------------------}
function CompMem(psrc, pdest: pointer; size: word): boolean;
  {-compare memory block}
var
  i: word;
begin
  CompMem := false;
  for i:=1 to size do begin
    if pByte(psrc)^<>pByte(pdest)^ then exit;
    inc(longint(psrc));
    inc(longint(pdest));
  end;
  CompMem := true;
end;


{---------------------------------------------------------------------------}
function test(px,py: pointer): string;
var
  i: integer;
begin
  if compmem(px,py,64) then test := 'OK' else test := 'Error';
end;


procedure TestCFB;
var
  i: integer;
begin
   AES.CipherMode := cmCFBBlock;
   AES.Init(key128,128,@IV);
   for i:=1 to N do AES.EncryptCFBblock(plain,ct,sizeof(plain));
   if N=1 then begin
     writeln('CFB test: ', test(@ct,@ct_cfb));
   end;
end;

procedure TestCTR;
var
  i: integer;
begin
   AES.CipherMode := cmCTR;
   AES.Init(key128,128,@CTR);
   for i:=1 to N do AES.EncryptCTR(plain,ct,sizeof(plain));
   if N=1 then begin
     writeln('CTR test: ', test(@ct,@ct_ctr));
   end;
end;

procedure TestOFB;
var
  i: integer;
begin
   AES.CipherMode := cmOFB;
   AES.Init(key128,128,@IV);
   for i:=1 to N do AES.EncryptOFB(plain,ct,sizeof(plain));
   if N=1 then begin
     writeln('OFB test: ', test(@ct,@ct_ofb));
   end;
end;

procedure TestCBC;
var
  i: integer;
begin
   AES.CipherMode := cmCBC;
   AES.Init(key128,128,@IV);
   for i:=1 to N do AES.EncryptCBC(plain,ct,sizeof(plain));
   if N=1 then begin
     writeln('CBC test: ', test(@ct,@ct_cbc));
   end;
end;

var
  s: string;
begin
  AES := TDCP_rijndael.Create(nil);
  s := Uppercase(paramstr(1));
  if s='TEST' then begin
    N := 1;
    TestCBC;
    TestCFB;
    TestCTR;
    TestOFB;
  end
  else if s='CBC' then TestCBC
  else if s='CFB' then TestCFB
  else if s='CTR' then TestCTR
  else if s='OFB' then TestOFB
  else writeln('Usage: ', ExtractFilename(paramstr(0)), '  [ TEST | CBC | CFB | CTR | OFB ]');
  if DebugHooK>0 then begin
    write('Enter'); readln;
  end;
end.
