unit SEA_CFB;

(*************************************************************************

 DESCRIPTION     :  SEED CFB128 functions
                    Because of buffering en/decrypting is associative

 REQUIREMENTS    :  TP5-7, D1-D7/D9-D10/D12, FPC, VP

 EXTERNAL DATA   :  ---

 MEMORY USAGE    :  ---

 DISPLAY MODE    :  ---

 REFERENCES      :  B.Schneier, Applied Cryptography, 2nd ed., ch. 9.6


 Version  Date      Author      Modification
 -------  --------  -------     ------------------------------------------
 0.10     07.06.07  W.Ehrhardt  Initial version analog TF_CFB
 0.11     23.11.08  we          Uses BTypes
 0.12     26.07.10  we          Longint ILen
**************************************************************************)


(*-------------------------------------------------------------------------
 (C) Copyright 2007-2010 Wolfgang Ehrhardt

 This software is provided 'as-is', without any express or implied warranty.
 In no event will the authors be held liable for any damages arising from
 the use of this software.

 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:

 1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software in
    a product, an acknowledgment in the product documentation would be
    appreciated but is not required.

 2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.

 3. This notice may not be removed or altered from any source distribution.
----------------------------------------------------------------------------*)

{$i STD.INC}

interface


uses
  BTypes, SEA_Base;

{$ifdef CONST}

function  SEA_CFB_Init(const Key; KeyBits: word; const IV: TSEABlock; var ctx: TSEAContext): integer;
  {-SEED key expansion, error if invalid key size, encrypt IV}
  {$ifdef DLL} stdcall; {$endif}

procedure SEA_CFB_Reset(const IV: TSEABlock; var ctx: TSEAContext);
  {-Clears ctx fields bLen and Flag, encrypt IV}
  {$ifdef DLL} stdcall; {$endif}

{$else}

function  SEA_CFB_Init(var Key; KeyBits: word; var IV: TSEABlock; var ctx: TSEAContext): integer;
  {-SEED key expansion, error if invalid key size, encrypt IV}

procedure SEA_CFB_Reset(var IV: TSEABlock; var ctx: TSEAContext);
  {-Clears ctx fields bLen and Flag, encrypt IV}

{$endif}

function  SEA_CFB_Encrypt(ptp, ctp: Pointer; ILen: longint; var ctx: TSEAContext): integer;
  {-Encrypt ILen bytes from ptp^ to ctp^ in CFB128 mode}
  {$ifdef DLL} stdcall; {$endif}

function  SEA_CFB_Decrypt(ctp, ptp: Pointer; ILen: longint; var ctx: TSEAContext): integer;
  {-Decrypt ILen bytes from ctp^ to ptp^ in CFB128 mode}
  {$ifdef DLL} stdcall; {$endif}


implementation


{---------------------------------------------------------------------------}
{$ifdef CONST}
function SEA_CFB_Init(const Key; KeyBits: word; const IV: TSEABlock; var ctx: TSEAContext): integer;
{$else}
function SEA_CFB_Init(var Key; KeyBits: word; var IV: TSEABlock; var ctx: TSEAContext): integer;
{$endif}
  {-SEED key expansion, error if invalid key size, encrypt IV}
var
  err: integer;
begin
  err := SEA_Init(Key, KeyBits, ctx);
  SEA_CFB_Init := err;
  if err=0 then begin
    {encrypt IV}
    SEA_Encrypt(ctx, IV, ctx.IV);
  end;
end;


{---------------------------------------------------------------------------}
procedure SEA_CFB_Reset({$ifdef CONST}const {$else} var {$endif} IV: TSEABlock; var ctx: TSEAContext);
  {-Clears ctx fields bLen and Flag, encrypt IV}
begin
  SEA_Reset(ctx);
  SEA_Encrypt(ctx, IV, ctx.IV);
end;


{---------------------------------------------------------------------------}
function SEA_CFB_Encrypt(ptp, ctp: Pointer; ILen: longint; var ctx: TSEAContext): integer;
  {-Encrypt ILen bytes from ptp^ to ctp^ in CFB128 mode}
begin
  SEA_CFB_Encrypt := 0;

  if (ptp=nil) or (ctp=nil) then begin
    if ILen>0 then begin
      SEA_CFB_Encrypt := SEA_Err_NIL_Pointer;
      exit;
    end;
  end;

  {$ifdef BIT16}
    if (ofs(ptp^)+ILen>$FFFF) or (ofs(ctp^)+ILen>$FFFF) then begin
      SEA_CFB_Encrypt := SEA_Err_Invalid_16Bit_Length;
      exit;
    end;
  {$endif}

  if ctx.blen=0 then begin
    {Handle full blocks first}
    while ILen>=SEABLKSIZE do with ctx do begin
      {Cipher text = plain text xor encr(IV/CT)}
      SEA_XorBlock(PSEABlock(ptp)^, IV, PSEABlock(ctp)^);
      SEA_Encrypt(ctx, PSEABlock(ctp)^, IV);
      inc(Ptr2Inc(ptp), SEABLKSIZE);
      inc(Ptr2Inc(ctp), SEABLKSIZE);
      dec(ILen, SEABLKSIZE);
    end;
  end;

  {Handle remaining bytes}
  while ILen>0 do with ctx do begin
    {Test buffer empty}
    if bLen>=SEABLKSIZE then begin
      SEA_Encrypt(ctx, buf, IV);
      bLen := 0;
    end;
    buf[bLen] := IV[bLen] xor pByte(ptp)^;
    pByte(ctp)^ := buf[bLen];
    inc(bLen);
    inc(Ptr2Inc(ptp));
    inc(Ptr2Inc(ctp));
    dec(ILen);
  end;
end;


{---------------------------------------------------------------------------}
function SEA_CFB_Decrypt(ctp, ptp: Pointer; ILen: longint; var ctx: TSEAContext): integer;
  {-Decrypt ILen bytes from ctp^ to ptp^ in CFB128 mode}
begin
  SEA_CFB_Decrypt := 0;

  if (ptp=nil) or (ctp=nil) then begin
    if ILen>0 then begin
      SEA_CFB_Decrypt := SEA_Err_NIL_Pointer;
      exit;
    end;
  end;

  {$ifdef BIT16}
    if (ofs(ptp^)+ILen>$FFFF) or (ofs(ctp^)+ILen>$FFFF) then begin
      SEA_CFB_Decrypt := SEA_Err_Invalid_16Bit_Length;
      exit;
    end;
  {$endif}

  if ctx.blen=0 then begin
    {Handle full blocks first}
    while ILen>=SEABLKSIZE do with ctx do begin
      {plain text = cypher text xor encr(IV/CT)}
      {must use buf, otherwise overwrite bug if ctp=ptp}
      buf := PSEABlock(ctp)^;
      SEA_XorBlock(buf, IV, PSEABlock(ptp)^);
      SEA_Encrypt(ctx, buf, IV);
      inc(Ptr2Inc(ptp), SEABLKSIZE);
      inc(Ptr2Inc(ctp), SEABLKSIZE);
      dec(ILen, SEABLKSIZE);
    end;
  end;

  {Handle remaining bytes}
  while ILen>0 do with ctx do begin
    {Test buffer empty}
    if bLen>=SEABLKSIZE then begin
      SEA_Encrypt(ctx, buf, IV);
      bLen := 0;
    end;
    buf[bLen] := pByte(ctp)^;
    pByte(ptp)^ := buf[bLen] xor IV[bLen];
    inc(bLen);
    inc(Ptr2Inc(ptp));
    inc(Ptr2Inc(ctp));
    dec(ILen);
  end;
end;


end.
