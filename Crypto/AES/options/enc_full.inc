{Plugin code for standard 32 bit AES encrypt primitive}
{Fully unrolled round loop, some cycles faster than std}

{---------------------------------------------------------------------------}
procedure AES_Encrypt(var ctx: TAESContext; const BI: TAESBlock; var BO: TAESBlock);
  {-encrypt one block, not checked: key must be encryption key}
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
  t0 := Te0[s0 and $ff] xor Te1[s1 shr 8 and $ff] xor Te2[s2 shr 16 and $ff] xor Te3[s3 shr 24] xor pK^[4];
  t1 := Te0[s1 and $ff] xor Te1[s2 shr 8 and $ff] xor Te2[s3 shr 16 and $ff] xor Te3[s0 shr 24] xor pK^[5];
  t2 := Te0[s2 and $ff] xor Te1[s3 shr 8 and $ff] xor Te2[s0 shr 16 and $ff] xor Te3[s1 shr 24] xor pK^[6];
  t3 := Te0[s3 and $ff] xor Te1[s0 shr 8 and $ff] xor Te2[s1 shr 16 and $ff] xor Te3[s2 shr 24] xor pK^[7];
  {Round 2}
  s0 := Te0[t0 and $ff] xor Te1[t1 shr 8 and $ff] xor Te2[t2 shr 16 and $ff] xor Te3[t3 shr 24] xor pK^[8];
  s1 := Te0[t1 and $ff] xor Te1[t2 shr 8 and $ff] xor Te2[t3 shr 16 and $ff] xor Te3[t0 shr 24] xor pK^[9];
  s2 := Te0[t2 and $ff] xor Te1[t3 shr 8 and $ff] xor Te2[t0 shr 16 and $ff] xor Te3[t1 shr 24] xor pK^[10];
  s3 := Te0[t3 and $ff] xor Te1[t0 shr 8 and $ff] xor Te2[t1 shr 16 and $ff] xor Te3[t2 shr 24] xor pK^[11];
  {Round 3}
  t0 := Te0[s0 and $ff] xor Te1[s1 shr 8 and $ff] xor Te2[s2 shr 16 and $ff] xor Te3[s3 shr 24] xor pK^[12];
  t1 := Te0[s1 and $ff] xor Te1[s2 shr 8 and $ff] xor Te2[s3 shr 16 and $ff] xor Te3[s0 shr 24] xor pK^[13];
  t2 := Te0[s2 and $ff] xor Te1[s3 shr 8 and $ff] xor Te2[s0 shr 16 and $ff] xor Te3[s1 shr 24] xor pK^[14];
  t3 := Te0[s3 and $ff] xor Te1[s0 shr 8 and $ff] xor Te2[s1 shr 16 and $ff] xor Te3[s2 shr 24] xor pK^[15];
  {Round 4}
  s0 := Te0[t0 and $ff] xor Te1[t1 shr 8 and $ff] xor Te2[t2 shr 16 and $ff] xor Te3[t3 shr 24] xor pK^[16];
  s1 := Te0[t1 and $ff] xor Te1[t2 shr 8 and $ff] xor Te2[t3 shr 16 and $ff] xor Te3[t0 shr 24] xor pK^[17];
  s2 := Te0[t2 and $ff] xor Te1[t3 shr 8 and $ff] xor Te2[t0 shr 16 and $ff] xor Te3[t1 shr 24] xor pK^[18];
  s3 := Te0[t3 and $ff] xor Te1[t0 shr 8 and $ff] xor Te2[t1 shr 16 and $ff] xor Te3[t2 shr 24] xor pK^[19];
  {Round 5}
  t0 := Te0[s0 and $ff] xor Te1[s1 shr 8 and $ff] xor Te2[s2 shr 16 and $ff] xor Te3[s3 shr 24] xor pK^[20];
  t1 := Te0[s1 and $ff] xor Te1[s2 shr 8 and $ff] xor Te2[s3 shr 16 and $ff] xor Te3[s0 shr 24] xor pK^[21];
  t2 := Te0[s2 and $ff] xor Te1[s3 shr 8 and $ff] xor Te2[s0 shr 16 and $ff] xor Te3[s1 shr 24] xor pK^[22];
  t3 := Te0[s3 and $ff] xor Te1[s0 shr 8 and $ff] xor Te2[s1 shr 16 and $ff] xor Te3[s2 shr 24] xor pK^[23];
  {Round 6}
  s0 := Te0[t0 and $ff] xor Te1[t1 shr 8 and $ff] xor Te2[t2 shr 16 and $ff] xor Te3[t3 shr 24] xor pK^[24];
  s1 := Te0[t1 and $ff] xor Te1[t2 shr 8 and $ff] xor Te2[t3 shr 16 and $ff] xor Te3[t0 shr 24] xor pK^[25];
  s2 := Te0[t2 and $ff] xor Te1[t3 shr 8 and $ff] xor Te2[t0 shr 16 and $ff] xor Te3[t1 shr 24] xor pK^[26];
  s3 := Te0[t3 and $ff] xor Te1[t0 shr 8 and $ff] xor Te2[t1 shr 16 and $ff] xor Te3[t2 shr 24] xor pK^[27];
  {Round 7}
  t0 := Te0[s0 and $ff] xor Te1[s1 shr 8 and $ff] xor Te2[s2 shr 16 and $ff] xor Te3[s3 shr 24] xor pK^[28];
  t1 := Te0[s1 and $ff] xor Te1[s2 shr 8 and $ff] xor Te2[s3 shr 16 and $ff] xor Te3[s0 shr 24] xor pK^[29];
  t2 := Te0[s2 and $ff] xor Te1[s3 shr 8 and $ff] xor Te2[s0 shr 16 and $ff] xor Te3[s1 shr 24] xor pK^[30];
  t3 := Te0[s3 and $ff] xor Te1[s0 shr 8 and $ff] xor Te2[s1 shr 16 and $ff] xor Te3[s2 shr 24] xor pK^[31];
  {Round 8}
  s0 := Te0[t0 and $ff] xor Te1[t1 shr 8 and $ff] xor Te2[t2 shr 16 and $ff] xor Te3[t3 shr 24] xor pK^[32];
  s1 := Te0[t1 and $ff] xor Te1[t2 shr 8 and $ff] xor Te2[t3 shr 16 and $ff] xor Te3[t0 shr 24] xor pK^[33];
  s2 := Te0[t2 and $ff] xor Te1[t3 shr 8 and $ff] xor Te2[t0 shr 16 and $ff] xor Te3[t1 shr 24] xor pK^[34];
  s3 := Te0[t3 and $ff] xor Te1[t0 shr 8 and $ff] xor Te2[t1 shr 16 and $ff] xor Te3[t2 shr 24] xor pK^[35];
  {Round 9}
  t0 := Te0[s0 and $ff] xor Te1[s1 shr 8 and $ff] xor Te2[s2 shr 16 and $ff] xor Te3[s3 shr 24] xor pK^[36];
  t1 := Te0[s1 and $ff] xor Te1[s2 shr 8 and $ff] xor Te2[s3 shr 16 and $ff] xor Te3[s0 shr 24] xor pK^[37];
  t2 := Te0[s2 and $ff] xor Te1[s3 shr 8 and $ff] xor Te2[s0 shr 16 and $ff] xor Te3[s1 shr 24] xor pK^[38];
  t3 := Te0[s3 and $ff] xor Te1[s0 shr 8 and $ff] xor Te2[s1 shr 16 and $ff] xor Te3[s2 shr 24] xor pK^[39];
  if ctx.rounds>10 then begin
    {Round 10}
    s0 := Te0[t0 and $ff] xor Te1[t1 shr 8 and $ff] xor Te2[t2 shr 16 and $ff] xor Te3[t3 shr 24] xor pK^[40];
    s1 := Te0[t1 and $ff] xor Te1[t2 shr 8 and $ff] xor Te2[t3 shr 16 and $ff] xor Te3[t0 shr 24] xor pK^[41];
    s2 := Te0[t2 and $ff] xor Te1[t3 shr 8 and $ff] xor Te2[t0 shr 16 and $ff] xor Te3[t1 shr 24] xor pK^[42];
    s3 := Te0[t3 and $ff] xor Te1[t0 shr 8 and $ff] xor Te2[t1 shr 16 and $ff] xor Te3[t2 shr 24] xor pK^[43];
    {Round 11}
    t0 := Te0[s0 and $ff] xor Te1[s1 shr 8 and $ff] xor Te2[s2 shr 16 and $ff] xor Te3[s3 shr 24] xor pK^[44];
    t1 := Te0[s1 and $ff] xor Te1[s2 shr 8 and $ff] xor Te2[s3 shr 16 and $ff] xor Te3[s0 shr 24] xor pK^[45];
    t2 := Te0[s2 and $ff] xor Te1[s3 shr 8 and $ff] xor Te2[s0 shr 16 and $ff] xor Te3[s1 shr 24] xor pK^[46];
    t3 := Te0[s3 and $ff] xor Te1[s0 shr 8 and $ff] xor Te2[s1 shr 16 and $ff] xor Te3[s2 shr 24] xor pK^[47];
    if ctx.rounds>12 then begin
      {Round 12}
      s0 := Te0[t0 and $ff] xor Te1[t1 shr 8 and $ff] xor Te2[t2 shr 16 and $ff] xor Te3[t3 shr 24] xor pK^[48];
      s1 := Te0[t1 and $ff] xor Te1[t2 shr 8 and $ff] xor Te2[t3 shr 16 and $ff] xor Te3[t0 shr 24] xor pK^[49];
      s2 := Te0[t2 and $ff] xor Te1[t3 shr 8 and $ff] xor Te2[t0 shr 16 and $ff] xor Te3[t1 shr 24] xor pK^[50];
      s3 := Te0[t3 and $ff] xor Te1[t0 shr 8 and $ff] xor Te2[t1 shr 16 and $ff] xor Te3[t2 shr 24] xor pK^[51];
      {Round 13}
      t0 := Te0[s0 and $ff] xor Te1[s1 shr 8 and $ff] xor Te2[s2 shr 16 and $ff] xor Te3[s3 shr 24] xor pK^[52];
      t1 := Te0[s1 and $ff] xor Te1[s2 shr 8 and $ff] xor Te2[s3 shr 16 and $ff] xor Te3[s0 shr 24] xor pK^[53];
      t2 := Te0[s2 and $ff] xor Te1[s3 shr 8 and $ff] xor Te2[s0 shr 16 and $ff] xor Te3[s1 shr 24] xor pK^[54];
      t3 := Te0[s3 and $ff] xor Te1[s0 shr 8 and $ff] xor Te2[s1 shr 16 and $ff] xor Te3[s2 shr 24] xor pK^[55];
    end;
  end;

  inc(Ptr2Inc(pK), (ctx.rounds shl 2)*sizeof(longint));

{$ifdef AES_ENCR_LongBox}
  {Use expanded longint SBox table Te4 from [2]}
  TWA4(BO)[0] := (Te4[t0        and $ff] and X000000ff) xor
                 (Te4[t1 shr  8 and $ff] and X0000ff00) xor
                 (Te4[t2 shr 16 and $ff] and X00ff0000) xor
                 (Te4[t3 shr 24 and $ff] and Xff000000) xor pK^[0];
  TWA4(BO)[1] := (Te4[t1        and $ff] and X000000ff) xor
                 (Te4[t2 shr  8 and $ff] and X0000ff00) xor
                 (Te4[t3 shr 16 and $ff] and X00ff0000) xor
                 (Te4[t0 shr 24 and $ff] and Xff000000) xor pK^[1];
  TWA4(BO)[2] := (Te4[t2        and $ff] and X000000ff) xor
                 (Te4[t3 shr  8 and $ff] and X0000ff00) xor
                 (Te4[t0 shr 16 and $ff] and X00ff0000) xor
                 (Te4[t1 shr 24 and $ff] and Xff000000) xor pK^[2];
  TWA4(BO)[3] := (Te4[t3        and $ff] and X000000ff) xor
                 (Te4[t0 shr  8 and $ff] and X0000ff00) xor
                 (Te4[t1 shr 16 and $ff] and X00ff0000) xor
                 (Te4[t2 shr 24 and $ff] and Xff000000) xor pK^[3];
{$else}
  {Uses InvSbox and shl, needs type cast longint() for}
  {16 bit compilers: here Sbox is byte, Te4 is longint}
  TWA4(BO)[0] := (longint(SBox[t0        and $ff])        xor
                  longint(SBox[t1 shr  8 and $ff]) shl  8 xor
                  longint(SBox[t2 shr 16 and $ff]) shl 16 xor
                  longint(SBox[t3 shr 24])         shl 24    ) xor pK^[0];
  TWA4(BO)[1] := (longint(SBox[t1        and $ff])        xor
                  longint(SBox[t2 shr  8 and $ff]) shl  8 xor
                  longint(SBox[t3 shr 16 and $ff]) shl 16 xor
                  longint(SBox[t0 shr 24])         shl 24    ) xor pK^[1];
  TWA4(BO)[2] := (longint(SBox[t2        and $ff])        xor
                  longint(SBox[t3 shr  8 and $ff]) shl  8 xor
                  longint(SBox[t0 shr 16 and $ff]) shl 16 xor
                  longint(SBox[t1 shr 24])         shl 24    ) xor pK^[2];
  TWA4(BO)[3] := (longint(SBox[t3        and $ff])        xor
                  longint(SBox[t0 shr  8 and $ff]) shl  8 xor
                  longint(SBox[t1 shr 16 and $ff]) shl 16 xor
                  longint(SBox[t2 shr 24])         shl 24    ) xor pK^[3];

{$endif}

end;
