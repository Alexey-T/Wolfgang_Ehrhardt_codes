{Plugin code for standard 32 bit AES decrypt primitive}
{Uses pointer version, no local temp variables t0..t4 }

{---------------------------------------------------------------------------}
procedure AES_Decrypt(var ctx: TAESContext; const BI: TAESBlock; var BO: TAESBlock);
  {-decrypt one block (in ECB mode)}
var
  r: integer;             {round loop countdown counter     }
  pK,pO: PLong;           {pointer to RK[] and and BO[]     }
  s0,s1,s2,s3: longint;   {TAESBlock s as separate variables}
begin

  pK := PLong(@ctx.RK[ctx.Rounds]);
  pO := PLong(@BO);

  s0 := TWA4(BI)[0] xor pK^; inc(pK);
  s1 := TWA4(BI)[1] xor pK^; inc(pK);
  s2 := TWA4(BI)[2] xor pK^; inc(pK);
  s3 := TWA4(BI)[3] xor pK^; dec(pK,4);

  for r:=ctx.Rounds-1 downto 1 do begin
    {pO -> BO[0]}
    pO^ := Td0[s0 and $ff] xor Td1[s3 shr 8 and $ff] xor Td2[s2 shr 16 and $ff] xor Td3[s1 shr 24]; inc(PO);
    pO^ := Td0[s1 and $ff] xor Td1[s0 shr 8 and $ff] xor Td2[s3 shr 16 and $ff] xor Td3[s2 shr 24]; inc(pO);
    pO^ := Td0[s2 and $ff] xor Td1[s1 shr 8 and $ff] xor Td2[s0 shr 16 and $ff] xor Td3[s3 shr 24]; inc(pO);
(*
**  Next two statements can be merged:
**  pO^ := Td0[s3 and $ff] xor Td1[s2 shr 8 and $ff] xor Td2[s1 shr 16 and $ff] xor Td3[s0 shr 24];
**  s3  := pO^ xor pK^; dec(pK); dec(pO);}
*)
    s3  :=(Td0[s3 and $ff] xor Td1[s2 shr 8 and $ff] xor Td2[s1 shr 16 and $ff] xor Td3[s0 shr 24]) xor PK^;  dec(pK); dec(pO);
    s2  := pO^ xor pK^; dec(pK); dec(pO);
    s1  := pO^ xor pK^; dec(pK); dec(pO);
    s0  := pO^ xor pK^; dec(pK);
  end;

  inc(pO,3); {pO -> BO[3]}

{$ifdef AES_DECR_LongBox}
  {Use expanded longint InvSBox table Td4 from [2]}
  pO^ := (Td4[s3 and $ff       ] and X000000ff) xor
         (Td4[s2 shr  8 and $ff] and X0000ff00) xor
         (Td4[s1 shr 16 and $ff] and X00ff0000) xor
         (Td4[s0 shr 24        ] and Xff000000) xor pK^;
  dec(PO);
  Dec(pK);

  pO^ := (Td4[s2 and $ff       ] and X000000ff) xor
         (Td4[s1 shr  8 and $ff] and X0000ff00) xor
         (Td4[s0 shr 16 and $ff] and X00ff0000) xor
         (Td4[s3 shr 24        ] and Xff000000) xor pK^;
  dec(PO);
  Dec(pK);

  pO^ := (Td4[s1        and $ff] and X000000ff) xor
         (Td4[s0 shr  8 and $ff] and X0000ff00) xor
         (Td4[s3 shr 16 and $ff] and X00ff0000) xor
         (Td4[s2 shr 24        ] and Xff000000) xor pK^;
  dec(PO);
  Dec(pK);

  pO^ := (Td4[s0        and $ff] and X000000ff) xor
         (Td4[s3 shr  8 and $ff] and X0000ff00) xor
         (Td4[s2 shr 16 and $ff] and X00ff0000) xor
         (Td4[s1 shr 24        ] and Xff000000) xor pK^;
{$else}
  {Uses InvSbox and shl, needs type cast longint() for   }
  {16 bit compilers: here InvSbox is byte, Td4 is longint}
  pO^ := (longint(InvSBox[s3 and $ff       ])        xor
          longint(InvSBox[s2 shr  8 and $ff]) shl  8 xor
          longint(InvSBox[s1 shr 16 and $ff]) shl 16 xor
          longint(InvSBox[s0 shr 24        ]) shl 24    ) xor pK^;
  dec(PO);
  Dec(pK);

  pO^ := (longint(InvSBox[s2 and $ff       ])        xor
          longint(InvSBox[s1 shr  8 and $ff]) shl  8 xor
          longint(InvSBox[s0 shr 16 and $ff]) shl 16 xor
          longint(InvSBox[s3 shr 24        ]) shl 24    ) xor pK^;
  dec(PO);
  Dec(pK);

  pO^ := (longint(InvSBox[s1        and $ff])        xor
          longint(InvSBox[s0 shr  8 and $ff]) shl  8 xor
          longint(InvSBox[s3 shr 16 and $ff]) shl 16 xor
          longint(InvSBox[s2 shr 24        ]) shl 24    ) xor pK^;
  dec(PO);
  Dec(pK);

  pO^ := (longint(InvSBox[s0        and $ff])        xor
          longint(InvSBox[s3 shr  8 and $ff]) shl  8 xor
          longint(InvSBox[s2 shr 16 and $ff]) shl 16 xor
          longint(InvSBox[s1 shr 24        ]) shl 24    ) xor pK^;
{$endif}

end;

