{-Demo prog for AES CTR via pointer wrapper routines, we 03.2005}

program Sample1;

{$ifdef win32}
  {$apptype console}
{$endif}


uses
  aes_type, aes_ctr, BTypes, mem_util;

var
  Context: TAESContext;
  Err : integer;


(*
** Wrapper functions for pointer versions.  Please note: If you supply
** OutDataLen<InDataLen you get error -1, normally OutDataLen should be
** = InDataLen. And a TAESContext should be in the propedure parameter list,
** here a global TAESContext is used.
*)

{---------------------------------------------------------------------------}
function CryptData(InData: pointer; InDataLen: integer; OutData: pointer; OutDataLen: integer): integer;
begin
  if InDataLen>OutDataLen then CryptData := -1
  else CryptData := AES_CTR_Encrypt(InData, OutData, InDataLen, context);
end;



{---------------------------------------------------------------------------}
function DeCryptData(InData: pointer; InDataLen: integer; OutData: pointer; OutDataLen: integer): integer;
begin
  if InDataLen>OutDataLen then DeCryptData := -1
  else DeCryptData := AES_CTR_Decrypt(InData, OutData, InDataLen, context);
end;


{Stripped down sample from T_AESCTR}


{---------------------------------------------------------------------------}
procedure CheckError;
begin
  if Err<>0 then writeln('Error ',Err);
end;


{---------------------------------------------------------------------------}
procedure SimpleDemo;
  {-Simple encrypt/decrypt test for AES-CTR mode}
const
  Key128  : array[0..15] of byte = ($00, $01, $02, $03, $04, $05, $06, $07,
                                    $08, $09, $0a, $0b, $0c, $0d, $0e, $0f);
const
  sample = 'This is a short test sample text for AES CTR mode'#0;

var
  IV  : TAESBlock;
  i   : integer;
  ct, pt, plain: array[1..length(sample)] of char8;

begin
  for i:=0 to 15 do IV[i] := random(256);
  plain := sample;
  pt  := plain;
  writeln('Org. plain text: ', plain);

  {Encrypt plain text}
  Err := AES_CTR_Init(key128, 128, IV, context);
  Err := CryptData(@pt, sizeof(plain), @ct, sizeof(ct));
  CheckError;

  {Decrypt encrypted text}
  pt := ct;
  Err := AES_CTR_Init(key128, 128, IV, context);
  Err := DeCryptData(@pt, sizeof(pt), @pt, sizeof(pt));
  CheckError;

  {Write encrypted & decrypted text}
  writeln('Block Encr/decr: ', pt);

  {Compare encrypted/decrypted text against org text}
  writeln('Decr(Encr)=Id  : ',CompMem(@pt, @plain, sizeof(plain)));

end;

begin
  SimpleDemo;
end.
