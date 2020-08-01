{Plugin code for standard 32 bit AES decrypt primitive}
{Fully unrolled round loop, some cycles faster than std}

{Uses special MakeDecrKey with inverted order of the round keys}


{---------------------------------------------------------------------------}
procedure AES_Decrypt(var ctx: TAESContext; const BI: TAESBlock; var BO: TAESBlock);
  {-decrypt one block (in ECB mode)}
var
  pK: PAWk;                {pointer to loop rount key   }
  s0,s1,s2,s3: longint;    {TAESBlock s as separate variables}
  t0,t1,t2,t3: longint;    {TAESBlock t as separate variables}
begin
  {Setup key pointer}
  pK := PAWk(@ctx.RK);
  {Initialize with input block}
  s0 := TWA4(BI)[0] xor pK^[0];
  s1 := TWA4(BI)[1] xor pK^[1];
  s2 := TWA4(BI)[2] xor pK^[2];
  s3 := TWA4(BI)[3] xor pK^[3];

  {Round 1}
  t0 := Td0[s0 and $ff] xor Td1[s3 shr 8 and $ff] xor Td2[s2 shr 16 and $ff] xor Td3[s1 shr 24] xor pK^[4];
  t1 := Td0[s1 and $ff] xor Td1[s0 shr 8 and $ff] xor Td2[s3 shr 16 and $ff] xor Td3[s2 shr 24] xor pK^[5];
  t2 := Td0[s2 and $ff] xor Td1[s1 shr 8 and $ff] xor Td2[s0 shr 16 and $ff] xor Td3[s3 shr 24] xor pK^[6];
  t3 := Td0[s3 and $ff] xor Td1[s2 shr 8 and $ff] xor Td2[s1 shr 16 and $ff] xor Td3[s0 shr 24] xor pK^[7];
  {Round 2}
  s0 := Td0[t0 and $ff] xor Td1[t3 shr 8 and $ff] xor Td2[t2 shr 16 and $ff] xor Td3[t1 shr 24] xor pK^[8];
  s1 := Td0[t1 and $ff] xor Td1[t0 shr 8 and $ff] xor Td2[t3 shr 16 and $ff] xor Td3[t2 shr 24] xor pK^[9];
  s2 := Td0[t2 and $ff] xor Td1[t1 shr 8 and $ff] xor Td2[t0 shr 16 and $ff] xor Td3[t3 shr 24] xor pK^[10];
  s3 := Td0[t3 and $ff] xor Td1[t2 shr 8 and $ff] xor Td2[t1 shr 16 and $ff] xor Td3[t0 shr 24] xor pK^[11];
  {Round 3}
  t0 := Td0[s0 and $ff] xor Td1[s3 shr 8 and $ff] xor Td2[s2 shr 16 and $ff] xor Td3[s1 shr 24] xor pK^[12];
  t1 := Td0[s1 and $ff] xor Td1[s0 shr 8 and $ff] xor Td2[s3 shr 16 and $ff] xor Td3[s2 shr 24] xor pK^[13];
  t2 := Td0[s2 and $ff] xor Td1[s1 shr 8 and $ff] xor Td2[s0 shr 16 and $ff] xor Td3[s3 shr 24] xor pK^[14];
  t3 := Td0[s3 and $ff] xor Td1[s2 shr 8 and $ff] xor Td2[s1 shr 16 and $ff] xor Td3[s0 shr 24] xor pK^[15];
  {Round 4}
  s0 := Td0[t0 and $ff] xor Td1[t3 shr 8 and $ff] xor Td2[t2 shr 16 and $ff] xor Td3[t1 shr 24] xor pK^[16];
  s1 := Td0[t1 and $ff] xor Td1[t0 shr 8 and $ff] xor Td2[t3 shr 16 and $ff] xor Td3[t2 shr 24] xor pK^[17];
  s2 := Td0[t2 and $ff] xor Td1[t1 shr 8 and $ff] xor Td2[t0 shr 16 and $ff] xor Td3[t3 shr 24] xor pK^[18];
  s3 := Td0[t3 and $ff] xor Td1[t2 shr 8 and $ff] xor Td2[t1 shr 16 and $ff] xor Td3[t0 shr 24] xor pK^[19];
  {Round 5}
  t0 := Td0[s0 and $ff] xor Td1[s3 shr 8 and $ff] xor Td2[s2 shr 16 and $ff] xor Td3[s1 shr 24] xor pK^[20];
  t1 := Td0[s1 and $ff] xor Td1[s0 shr 8 and $ff] xor Td2[s3 shr 16 and $ff] xor Td3[s2 shr 24] xor pK^[21];
  t2 := Td0[s2 and $ff] xor Td1[s1 shr 8 and $ff] xor Td2[s0 shr 16 and $ff] xor Td3[s3 shr 24] xor pK^[22];
  t3 := Td0[s3 and $ff] xor Td1[s2 shr 8 and $ff] xor Td2[s1 shr 16 and $ff] xor Td3[s0 shr 24] xor pK^[23];
  {Round 6}
  s0 := Td0[t0 and $ff] xor Td1[t3 shr 8 and $ff] xor Td2[t2 shr 16 and $ff] xor Td3[t1 shr 24] xor pK^[24];
  s1 := Td0[t1 and $ff] xor Td1[t0 shr 8 and $ff] xor Td2[t3 shr 16 and $ff] xor Td3[t2 shr 24] xor pK^[25];
  s2 := Td0[t2 and $ff] xor Td1[t1 shr 8 and $ff] xor Td2[t0 shr 16 and $ff] xor Td3[t3 shr 24] xor pK^[26];
  s3 := Td0[t3 and $ff] xor Td1[t2 shr 8 and $ff] xor Td2[t1 shr 16 and $ff] xor Td3[t0 shr 24] xor pK^[27];
  {Round 7}
  t0 := Td0[s0 and $ff] xor Td1[s3 shr 8 and $ff] xor Td2[s2 shr 16 and $ff] xor Td3[s1 shr 24] xor pK^[28];
  t1 := Td0[s1 and $ff] xor Td1[s0 shr 8 and $ff] xor Td2[s3 shr 16 and $ff] xor Td3[s2 shr 24] xor pK^[29];
  t2 := Td0[s2 and $ff] xor Td1[s1 shr 8 and $ff] xor Td2[s0 shr 16 and $ff] xor Td3[s3 shr 24] xor pK^[30];
  t3 := Td0[s3 and $ff] xor Td1[s2 shr 8 and $ff] xor Td2[s1 shr 16 and $ff] xor Td3[s0 shr 24] xor pK^[31];
  {Round 8}
  s0 := Td0[t0 and $ff] xor Td1[t3 shr 8 and $ff] xor Td2[t2 shr 16 and $ff] xor Td3[t1 shr 24] xor pK^[32];
  s1 := Td0[t1 and $ff] xor Td1[t0 shr 8 and $ff] xor Td2[t3 shr 16 and $ff] xor Td3[t2 shr 24] xor pK^[33];
  s2 := Td0[t2 and $ff] xor Td1[t1 shr 8 and $ff] xor Td2[t0 shr 16 and $ff] xor Td3[t3 shr 24] xor pK^[34];
  s3 := Td0[t3 and $ff] xor Td1[t2 shr 8 and $ff] xor Td2[t1 shr 16 and $ff] xor Td3[t0 shr 24] xor pK^[35];
  {Round 9}
  t0 := Td0[s0 and $ff] xor Td1[s3 shr 8 and $ff] xor Td2[s2 shr 16 and $ff] xor Td3[s1 shr 24] xor pK^[36];
  t1 := Td0[s1 and $ff] xor Td1[s0 shr 8 and $ff] xor Td2[s3 shr 16 and $ff] xor Td3[s2 shr 24] xor pK^[37];
  t2 := Td0[s2 and $ff] xor Td1[s1 shr 8 and $ff] xor Td2[s0 shr 16 and $ff] xor Td3[s3 shr 24] xor pK^[38];
  t3 := Td0[s3 and $ff] xor Td1[s2 shr 8 and $ff] xor Td2[s1 shr 16 and $ff] xor Td3[s0 shr 24] xor pK^[39];
  if ctx.rounds>10 then begin
    {Round 10}
    s0 := Td0[t0 and $ff] xor Td1[t3 shr 8 and $ff] xor Td2[t2 shr 16 and $ff] xor Td3[t1 shr 24] xor pK^[40];
    s1 := Td0[t1 and $ff] xor Td1[t0 shr 8 and $ff] xor Td2[t3 shr 16 and $ff] xor Td3[t2 shr 24] xor pK^[41];
    s2 := Td0[t2 and $ff] xor Td1[t1 shr 8 and $ff] xor Td2[t0 shr 16 and $ff] xor Td3[t3 shr 24] xor pK^[42];
    s3 := Td0[t3 and $ff] xor Td1[t2 shr 8 and $ff] xor Td2[t1 shr 16 and $ff] xor Td3[t0 shr 24] xor pK^[43];
    {Round 11}
    t0 := Td0[s0 and $ff] xor Td1[s3 shr 8 and $ff] xor Td2[s2 shr 16 and $ff] xor Td3[s1 shr 24] xor pK^[44];
    t1 := Td0[s1 and $ff] xor Td1[s0 shr 8 and $ff] xor Td2[s3 shr 16 and $ff] xor Td3[s2 shr 24] xor pK^[45];
    t2 := Td0[s2 and $ff] xor Td1[s1 shr 8 and $ff] xor Td2[s0 shr 16 and $ff] xor Td3[s3 shr 24] xor pK^[46];
    t3 := Td0[s3 and $ff] xor Td1[s2 shr 8 and $ff] xor Td2[s1 shr 16 and $ff] xor Td3[s0 shr 24] xor pK^[47];
    if ctx.rounds>12 then begin
      {Round 12}
      s0 := Td0[t0 and $ff] xor Td1[t3 shr 8 and $ff] xor Td2[t2 shr 16 and $ff] xor Td3[t1 shr 24] xor pK^[48];
      s1 := Td0[t1 and $ff] xor Td1[t0 shr 8 and $ff] xor Td2[t3 shr 16 and $ff] xor Td3[t2 shr 24] xor pK^[49];
      s2 := Td0[t2 and $ff] xor Td1[t1 shr 8 and $ff] xor Td2[t0 shr 16 and $ff] xor Td3[t3 shr 24] xor pK^[50];
      s3 := Td0[t3 and $ff] xor Td1[t2 shr 8 and $ff] xor Td2[t1 shr 16 and $ff] xor Td3[t0 shr 24] xor pK^[51];
      {Round 13}
      t0 := Td0[s0 and $ff] xor Td1[s3 shr 8 and $ff] xor Td2[s2 shr 16 and $ff] xor Td3[s1 shr 24] xor pK^[52];
      t1 := Td0[s1 and $ff] xor Td1[s0 shr 8 and $ff] xor Td2[s3 shr 16 and $ff] xor Td3[s2 shr 24] xor pK^[53];
      t2 := Td0[s2 and $ff] xor Td1[s1 shr 8 and $ff] xor Td2[s0 shr 16 and $ff] xor Td3[s3 shr 24] xor pK^[54];
      t3 := Td0[s3 and $ff] xor Td1[s2 shr 8 and $ff] xor Td2[s1 shr 16 and $ff] xor Td3[s0 shr 24] xor pK^[55];
    end;
  end;

  inc(Ptr2Inc(pK), (ctx.rounds shl 2)*sizeof(longint));

{$ifdef AES_DECR_LongBox}
  {Use expanded longint InvSBox table Td4 from [2]}
  TWA4(BO)[0] := (Td4[t0        and $ff] and X000000ff) xor
                 (Td4[t3 shr  8 and $ff] and X0000ff00) xor
                 (Td4[t2 shr 16 and $ff] and X00ff0000) xor
                 (Td4[t1 shr 24        ] and Xff000000) xor pK^[0];
  TWA4(BO)[1] := (Td4[t1        and $ff] and X000000ff) xor
                 (Td4[t0 shr  8 and $ff] and X0000ff00) xor
                 (Td4[t3 shr 16 and $ff] and X00ff0000) xor
                 (Td4[t2 shr 24        ] and Xff000000) xor pK^[1];
  TWA4(BO)[2] := (Td4[t2 and $ff       ] and X000000ff) xor
                 (Td4[t1 shr  8 and $ff] and X0000ff00) xor
                 (Td4[t0 shr 16 and $ff] and X00ff0000) xor
                 (Td4[t3 shr 24        ] and Xff000000) xor pK^[2];
  TWA4(BO)[3] := (Td4[t3 and $ff       ] and X000000ff) xor
                 (Td4[t2 shr  8 and $ff] and X0000ff00) xor
                 (Td4[t1 shr 16 and $ff] and X00ff0000) xor
                 (Td4[t0 shr 24        ] and Xff000000) xor pK^[3];
{$else}
  {Uses InvSbox and shl, needs type cast longint() for   }
  {16 bit compilers: here InvSbox is byte, Td4 is longint}
  TWA4(BO)[0] := (longint(InvSBox[t0        and $ff])        xor
                  longint(InvSBox[t3 shr  8 and $ff]) shl  8 xor
                  longint(InvSBox[t2 shr 16 and $ff]) shl 16 xor
                  longint(InvSBox[t1 shr 24        ]) shl 24    ) xor pK^[0];
  TWA4(BO)[1] := (longint(InvSBox[t1        and $ff])        xor
                  longint(InvSBox[t0 shr  8 and $ff]) shl  8 xor
                  longint(InvSBox[t3 shr 16 and $ff]) shl 16 xor
                  longint(InvSBox[t2 shr 24        ]) shl 24    ) xor pK^[1];
  TWA4(BO)[2] := (longint(InvSBox[t2 and $ff       ])        xor
                  longint(InvSBox[t1 shr  8 and $ff]) shl  8 xor
                  longint(InvSBox[t0 shr 16 and $ff]) shl 16 xor
                  longint(InvSBox[t3 shr 24        ]) shl 24    ) xor pK^[2];
  TWA4(BO)[3] := (longint(InvSBox[t3 and $ff       ])        xor
                  longint(InvSBox[t2 shr  8 and $ff]) shl  8 xor
                  longint(InvSBox[t1 shr 16 and $ff]) shl 16 xor
                  longint(InvSBox[t0 shr 24        ]) shl 24    ) xor pK^[3];
{$endif}

end;


{---------------------------------------------------------------------------}
procedure MakeDecrKey(var ctx: TAESContext);
  {-Calculate decryption key from encryption key}
var
  i,j: integer;
  p: PLong;
  x: longint;
begin
  {Warning inversion is needed only for fully unrolled version}
  {invert the order of the round keys}
  i := 0;
  j := 4*ctx.Rounds;
  while i<j do begin
    x:=TAWk(ctx.RK)[i  ];  TAWk(ctx.RK)[i  ]:=TAWk(ctx.RK)[j  ];  TAWk(ctx.RK)[j  ]:=x;
    x:=TAWk(ctx.RK)[i+1];  TAWk(ctx.RK)[i+1]:=TAWk(ctx.RK)[j+1];  TAWk(ctx.RK)[j+1]:=x;
    x:=TAWk(ctx.RK)[i+2];  TAWk(ctx.RK)[i+2]:=TAWk(ctx.RK)[j+2];  TAWk(ctx.RK)[j+2]:=x;
    x:=TAWk(ctx.RK)[i+3];  TAWk(ctx.RK)[i+3]:=TAWk(ctx.RK)[j+3];  TAWk(ctx.RK)[j+3]:=x;
    inc(i,4);
    dec(j,4);
  end;
  p := PLong(@ctx.RK[1]);
  for i:=1 to 4*(ctx.Rounds-1) do begin
    x  := p^;
    p^ := Td3[SBox[x shr 24]] xor Td2[SBox[x shr 16 and $ff]] xor Td1[SBox[x shr 8 and $ff]] xor Td0[SBox[x and $ff]];
    inc(p);
  end;
end;
