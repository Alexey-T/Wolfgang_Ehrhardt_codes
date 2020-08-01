{Plugin code for standard 32 bit AES encrypt primitive}
{Uses pointer version, no local temp variables t0..t4 }

{---------------------------------------------------------------------------}
procedure AES_Encrypt(var ctx: TAESContext; const BI: TAESBlock; var BO: TAESBlock);
  {-encrypt one block, not checked: key must be encryption key}
var
  r: integer;              {round loop countdown counter     }
  pK,pO: PLong;            {pointer to RK[] and and BO[]     }
  s0,s1,s2,s3: longint;    {TAESBlock s as separate variables}
begin

  pK := PLong(@ctx.RK);
  pO := PLong(@TWA4(BO)[3]);

  s0 := TWA4(BI)[0] xor pK^; inc(pK);
  s1 := TWA4(BI)[1] xor pK^; inc(pK);
  s2 := TWA4(BI)[2] xor pK^; inc(pK);
  s3 := TWA4(BI)[3] xor pK^; inc(pK);

  for r := ctx.Rounds-1 downto 1 do begin
    {pO -> BO[3]}
    pO^ := Te0[s3 and $ff] xor Te1[s0 shr 8 and $ff] xor Te2[s1 shr 16 and $ff] xor Te3[s2 shr 24]; dec(PO);
    pO^ := Te0[s2 and $ff] xor Te1[s3 shr 8 and $ff] xor Te2[s0 shr 16 and $ff] xor Te3[s1 shr 24]; dec(pO);
    pO^ := Te0[s1 and $ff] xor Te1[s2 shr 8 and $ff] xor Te2[s3 shr 16 and $ff] xor Te3[s0 shr 24]; dec(pO);
(*
**  Next two statements can be merged;
**  pO^ := Te0[s0 and $ff] xor Te1[s1 shr 8 and $ff] xor Te2[s2 shr 16 and $ff] xor Te3[s3 shr 24];
**  s0  := pO^ xor pK^; inc(pK); inc(pO);
*)
    s0  :=(Te0[s0 and $ff] xor Te1[s1 shr 8 and $ff] xor Te2[s2 shr 16 and $ff] xor Te3[s3 shr 24]) xor pK^; inc(pK); inc(pO);
    s1  := pO^ xor pK^; inc(pK); inc(pO);
    s2  := pO^ xor pK^; inc(pK); inc(pO);
    s3  := pO^ xor pK^; inc(pK);
  end;

  dec(pO,3);  {pO -> BO[0]}

{$ifdef AES_ENCR_LongBox}
  {Use expanded longint SBox table Te4 from [2]}
  pO^ := (Te4[s0        and $ff] and X000000ff) xor
         (Te4[s1 shr  8 and $ff] and X0000ff00) xor
         (Te4[s2 shr 16 and $ff] and X00ff0000) xor
         (Te4[s3 shr 24 and $ff] and Xff000000) xor pK^;
  inc(pO);
  inc(pK);

  pO^ := (Te4[s1        and $ff] and X000000ff) xor
         (Te4[s2 shr  8 and $ff] and X0000ff00) xor
         (Te4[s3 shr 16 and $ff] and X00ff0000) xor
         (Te4[s0 shr 24 and $ff] and Xff000000) xor pK^;
  inc(pO);
  inc(pK);

  pO^ := (Te4[s2        and $ff] and X000000ff) xor
         (Te4[s3 shr  8 and $ff] and X0000ff00) xor
         (Te4[s0 shr 16 and $ff] and X00ff0000) xor
         (Te4[s1 shr 24 and $ff] and Xff000000) xor pK^;
  inc(pO);
  inc(pK);

  pO^ := (Te4[s3        and $ff] and X000000ff) xor
         (Te4[s0 shr  8 and $ff] and X0000ff00) xor
         (Te4[s1 shr 16 and $ff] and X00ff0000) xor
         (Te4[s2 shr 24 and $ff] and Xff000000) xor pK^;
{$else}
  {Uses InvSbox and shl, needs type cast longint() for}
  {16 bit compilers: here Sbox is byte, Te4 is longint}
  pO^ := (longint(SBox[s0        and $ff])        xor
          longint(SBox[s1 shr  8 and $ff]) shl  8 xor
          longint(SBox[s2 shr 16 and $ff]) shl 16 xor
          longint(SBox[s3 shr 24])         shl 24    ) xor pK^;
  inc(pO);
  inc(pK);

  pO^ := (longint(SBox[s1        and $ff])        xor
          longint(SBox[s2 shr  8 and $ff]) shl  8 xor
          longint(SBox[s3 shr 16 and $ff]) shl 16 xor
          longint(SBox[s0 shr 24])         shl 24    ) xor pK^;
  inc(pO);
  inc(pK);

  pO^ := (longint(SBox[s2        and $ff])        xor
          longint(SBox[s3 shr  8 and $ff]) shl  8 xor
          longint(SBox[s0 shr 16 and $ff]) shl 16 xor
          longint(SBox[s1 shr 24])         shl 24    ) xor pK^;
  inc(pO);
  inc(pK);

  pO^ := (longint(SBox[s3        and $ff])        xor
          longint(SBox[s0 shr  8 and $ff]) shl  8 xor
          longint(SBox[s1 shr 16 and $ff]) shl 16 xor
          longint(SBox[s2 shr 24])         shl 24    ) xor pK^;

{$endif}

end;

