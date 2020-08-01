{-Demo prog for AES CTR, we 03.2005}


(*
** Please note: This is a very simple example to demonstrate just the basics.
** Key exchange, authentication etc is not handled.
*)

program Sample2;

{$ifdef win32}
  {$ifndef VirtualPascal}
    {$apptype console}
  {$endif}
{$endif}

{$X+}

uses
  BTypes, aes_type, aes_ctr;

type
   TMySelf = packed record
               Name : array [0..10] of char8;
               Age  : integer;
               Sex  : boolean;
             end;


{Shared session key between server and client}
const
  SharedKey: array[0..15] of char8 = 'Demo session key';


{---------------------------------------------------------------------------}
procedure Client(const CR: TMySelf; const IV: TAESBlock);
  {-Receive an encrypted TMyself and IV, decrypt and display}
var
  MyRec: TMySelf;
  Client_CTX: TAESContext;
begin
  AES_CTR_Init(SharedKey, 128, IV, Client_CTX);
  AES_CTR_Decrypt(@CR, @MyRec, sizeof(MyRec), Client_CTX);
  with MyRec do begin
    writeln;
    writeln('Received record:');
    writeln(' Name: ', Name);
    writeln(' Age : ', Age);
    writeln(' Sex : ', Sex);
    writeln;
  end;
end;



{---------------------------------------------------------------------------}
procedure server;
  {-Sample server proc, encrypt and send messages}
const
  Msg: array[1..2] of TMySelf = ( (Name: 'Susi Spice'; Age:21; Sex:true),
                                  (Name: 'James Bond'; Age:67; Sex:false));
var
  IV: TAESBlock;
  Server_CTX: TAESContext;
  CR: TMySelf;
  i: integer;
begin
  {Setup IV, low part=msg number, high part = random}
  for i:=0 to 15 do begin
    if i<8 then IV[i]:=0 else IV[i]:=random(256);
  end;

  for i:=1 to 2 do begin
    {Setup CTR mode with 128 Bit shared key and IV for msg}
    AES_CTR_Init(SharedKey, 128, IV, Server_CTX);
    {encrypt msg}
    AES_CTR_Encrypt(@Msg[i], @CR, sizeof(CR), Server_CTX);
    {Send to client}
    Client(CR, IV);
    {Inc low part of IV used as msg number}
    AES_IncLSBPart(IV);
  end;
end;


begin
  randomize;
  server;
end.
