{Test program for mp_rsa unit, (c) W.Ehrhardt 2005}

program t_rsa2;


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

const
  msg: array[0..44] of char8 = 'You can''t keep a secret for the life of you.'#0;

const
  osize = ((sizeof(msg)+15) and $FFF0)+RSA_MINSIZE;

var
  n,d,e: mp_int;
  pt: array[0..1000] of char8;
  ct: array[0..1000] of byte;
  plen,clen: word;

begin
  HexUpper := true;
  writeln('Test of MPArith V', MP_VERSION, ' [mp_rsa unit]   (c) W.Ehrhardt 2005');
  writeln('Karatsuba  cutoffs: mul/sqr = ',mp_mul_cutoff,'/',mp_sqr_cutoff);
  writeln('Toom-3, BZ cutoffs: mul/sqr = ',mp_t3m_cutoff,'/',mp_t3s_cutoff,  ',  div = ',mp_bz_cutoff);

{---------------------------------------------------------------------------}

  mp_clearzero := true;
  mp_show_plus := true;

  mp_init3(n,d,e);
  mp_set_int(e,65537);
  write('RSA key generation: ...');
  mp_rsa_keygen1(e, osize, d, n);
  writeln;
  writeln('e = ', mp_decimal(e));
  writeln('d = ', mp_decimal(d));
  writeln('n = ', mp_decimal(n));
  writeln('Maximum message length: ', mp_pkcs1v15_maxlen(n));
  writeln(' Plaintext: ', msg);
  writeln('Encrypting ...');
  mp_pkcs1v15_encrypt(e, n, 0, @msg, @ct, sizeof(msg), sizeof(ct), clen);
  writeln('Ciphertext: ', Base64Str(@ct, clen));
  writeln('Decrypting ...');
  mp_pkcs1v15_decrypt(d, n, @ct, @pt, clen, sizeof(pt), plen);
  if plen>0 then begin
    writeln('Plaintext: ',pt);
    writeln('Recovered: ', compmem(@msg, @pt, sizeof(msg)));
  end
  else writeln('*** Failed');

{---------------------------------------------------------------------------}
  mp_clear3(n,d,e);
  {$ifdef MPC_Diagnostic}
    mp_dump_meminfo;
    mp_dump_diagctr;
  {$endif}

end.
