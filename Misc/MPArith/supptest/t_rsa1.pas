{Test program for mp_rsa unit, (c) W.Ehrhardt 2005}

program t_rsa1;


{$i STD.INC}
{$i mp_conf.inc}

{$x+}  {pchar I/O}
{$i+}  {RTE on I/O error}

{$ifdef APPCONS}
  {$apptype console}
{$endif}


uses
  BTypes, mp_types, mp_base,
  {$ifdef WINCRT}
    WinCRT,
  {$endif}
  {$ifdef MPC_Diagnostic}
    mp_supp,
  {$endif}
  mp_numth, mp_rsa, mem_util;

{Data from modified MPI test program mptest-rsa.c}
const
 s_mod = '83274231253085465096943841678296886335681962490673038705724389198'+
         '65474669167807962621458902263032323334899267161962205385173787115'+
         '612127292324765919274701';
 s_e   = '65537';
 s_d   = '19960555087274662728045086118137323762870255714573184079653088025'+
         '41567993316053323488373760710861512967149119329674542725895098992'+
         '464916732941604352939501';
const
 msg: array[0..43] of char8 = 'You can''t keep a secret for the life of you.';

const
  eout: array[0..63] of byte = (
          $1F,$96,$30,$D4,$AF,$7B,$00,$2A,$4C,$92,$A6,$E7,$AD,$A1,$67,$FE,
          $73,$94,$16,$68,$7A,$F1,$87,$63,$19,$A2,$AF,$B5,$82,$2E,$F0,$EB,
          $0D,$C4,$D0,$14,$DB,$BC,$0C,$FD,$68,$92,$93,$5C,$14,$84,$A4,$90,
          $76,$76,$5F,$C3,$55,$BD,$BE,$F9,$C5,$B2,$85,$41,$E5,$6B,$05,$62);

var
  modulus,d,e: mp_int;
  OK: boolean;
  i: integer;
  pt: array[0..1000] of char8;
  ct: array[0..1000] of byte;
  plen,clen: word;

begin
  HexUpper := true;
  writeln('Test of MPArith V', MP_VERSION, ' [mp_rsa unit]   (c) W.Ehrhardt 2009');
  writeln('Karatsuba  cutoffs: mul/sqr = ',mp_mul_cutoff,'/',mp_sqr_cutoff);
  writeln('Toom-3, BZ cutoffs: mul/sqr = ',mp_t3m_cutoff,'/',mp_t3s_cutoff,  ',  div = ',mp_bz_cutoff);

{---------------------------------------------------------------------------}

  mp_clearzero := true;
  mp_init3(modulus,d,e);

  mp_show_plus := true;
  mp_read_radix(modulus, s_mod, 10);
  mp_read_radix(e, s_e, 10);
  mp_read_radix(d, s_d, 10);

  writeln('Maximum message length: ', mp_pkcs1v15_maxlen(modulus));

  mp_pkcs1v15_decrypt(d, modulus, @eout, @pt, 64, sizeof(pt), plen);
  if plen>0 then begin
    pt[plen] := #0;
    writeln('Plaintext: ',pt);
  end;
  OK := (plen=sizeof(msg)) and CompMem(@pt, @msg, plen);
  writeln('mp_pkcs1v15_decrypt check OK: ', OK);

  mp_pkcs1v15_encrypt(e, modulus, $33, @msg, @ct, sizeof(msg), sizeof(ct), clen);
  OK := (clen=sizeof(eout)) and CompMem(@ct, @eout, clen);
  writeln('mp_pkcs1v15_encrypt check OK: ', OK);
  writeln('Ciphertext:');
  for i:=1 to clen do begin
    write(HexByte(ct[i-1]):3);
    if i and 15 = 0 then writeln;
  end;

{---------------------------------------------------------------------------}
  mp_clear3(modulus,d,e);
  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}

end.
