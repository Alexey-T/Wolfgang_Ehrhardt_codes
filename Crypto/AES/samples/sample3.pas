{-Demo for AES CTR for string encrypt/decrypt, we 03.2005}

program Sample3;

{$ifdef win32}
  {$apptype console}
{$endif}


uses
  aes_type, aes_ctr, mem_util;

var
  Context: TAESContext;
  Err : integer;

{---------------------------------------------------------------------------}
procedure CheckError;
begin
  if Err<>0 then writeln('Error ',Err);
end;


{---------------------------------------------------------------------------}
procedure SimpleDemo;
  {-Simple encrypt/decrypt test for AES-CTR mode}
const
  Key128  : array[0..15] of byte = ($00,$01,$02,$03,$04,$05,$06,$07,
                                    $08,$09,$0a,$0b,$0c,$0d,$0e,$0f);
const
  sample = 'This is a short test sample text for AES CTR mode'#0;

var
  IV  : TAESBlock;
  i   : integer;
  org, pt  : string[80];

begin
  randseed := 42;
  for i:=0 to 15 do IV[i] := random(256);
  org := sample;
  pt  := org;
  writeln('Org. plain text: ', pt);

  {Encrypt plain text}
  Err := AES_CTR_Init(key128, 128, IV, context);
  Err := AES_CTR_Encrypt(@pt[1], @pt[1], length(pt), Context);
  CheckError;

  {Write encrypted string, beware of the gibberish!}
  writeln(' Text Encrypted: ', pt);

  {Decrypt encrypted string}
  Err := AES_CTR_Init(key128, 128, IV, context);
  Err := AES_CTR_Decrypt(@pt[1], @pt[1], length(pt), Context);
  CheckError;

  {Write encrypted & decrypted string}
  writeln(' Text Encr/decr: ', pt);

  {Compare encrypted/decrypted string against org text}
  writeln(' Decr(Encr)=Id : ',CompMem(@pt, @org, length(org)));

end;

begin
  SimpleDemo;
end.
