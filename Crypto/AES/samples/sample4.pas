{-Demo for AES CBC file encrypt/decrypt, we 12.2006}

(*
 * This simple sample program uses AES CBC with 128 bit keys to first
 * encrypt its source code to sample4.enc, then to decrypt sample4.enc
 * to sample4.dec.
 *
 * The IV is generated with pseudo random bytes; it is written to the
 * first 16 bytes of sample4.enc. The decrypt function reads back the IV.
 *
 * Please note that this sample only shows the basic logic without
 * IO checking, pass phrase handling, authentication/verification etc.
 *
 * For a more complete sample look at the fca demo program.
 *)


program Sample4;

{$ifdef win32} {$ifndef VirtualPascal}
  {$apptype console}
{$endif} {$endif}

{$i+}

uses
  BTypes, aes_type, aes_cbc;

type
  TKey128 = array[0..15] of char8;

const
  BufSize = $4000; {must be a multiple of AESBLKSIZE=16 for CBC}

const
  SampleKey: TKey128 = 'Key for Sample 4';

var
  SampleIV: TAESBlock;
  buffer  : array[0..BufSize-1] of byte;


{---------------------------------------------------------------------------}
procedure EncryptFile(var ptf, ctf: file; key: TKey128; IV: TAESBlock);
  {-Encrypt file ptf to file ctf with AES-CBC, files will be closed}
var
  len: longint;
  err: integer;
  n: word;
  ctx: TAESContext;
begin
  len := filesize(ptf);
  err := AES_CBC_Init_Encr(Key, 128, IV, ctx);
  if err<>0 then begin
    writeln('Encrypt init error: ', err);
    halt;
  end;
  blockwrite(ctf,IV,sizeof(IV));
  while len>0 do begin
    if len>sizeof(buffer) then n:=sizeof(buffer) else n:=len;
    blockread(ptf,buffer,n);
    dec(len,n);
    err := AES_CBC_Encrypt(@buffer, @buffer, n, ctx);
    if err<>0 then begin
      writeln('Encrypt error: ', err);
      halt;
    end;
    blockwrite(ctf,buffer,n);
  end;
  close(ptf);
  close(ctf);
end;

{---------------------------------------------------------------------------}
procedure DecryptFile(var ctf, ptf: file; key: TKey128);
  {-Decrypt file ctf to file ptf with AES-CBC, files will be closed}
  { first 16 bytes of ctf must contain IV}
var
  len: longint;
  err: integer;
  n: word;
  ctx: TAESContext;
  IV: TAESBlock;
begin
  len := filesize(ctf)-sizeof(IV);
  blockread(ctf,IV,sizeof(IV));
  err := AES_CBC_Init_Decr(Key, 128, IV, ctx);
  if err<>0 then begin
    writeln('Decrypt init error: ', err);
    halt;
  end;
  while len>0 do begin
    if len>sizeof(buffer) then n:=sizeof(buffer) else n:=len;
    blockread(ctf,buffer,n);
    dec(len,n);
    err := AES_CBC_Decrypt(@buffer, @buffer, n, ctx);
    if err<>0 then begin
      writeln('Decrypt error: ', err);
      halt;
    end;
    blockwrite(ptf,buffer,n);
  end;
  close(ptf);
  close(ctf);
end;


var
  ctf, ptf: file;
  i: integer;
begin
  filemode := 0;
  randomize;

  writeln('Encrypting ...');
  for i:=0 to 15 do SampleIV[i] := random(256) and $FF;
  assign(ptf,'sample4.pas');  reset(ptf,1);
  assign(ctf,'sample4.enc');  rewrite(ctf,1);
  EncryptFile(ptf, ctf, Samplekey, SampleIV);

  writeln('Decrypting ...');
  assign(ctf,'sample4.enc');  reset(ctf,1);
  assign(ptf,'sample4.dec');  rewrite(ptf,1);
  DecryptFile(ctf, ptf, Samplekey);

  writeln('Done.');

end.
