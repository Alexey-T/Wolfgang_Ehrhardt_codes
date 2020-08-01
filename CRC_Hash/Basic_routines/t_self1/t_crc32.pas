{-Test prog for CRC32, we 18.03.02}

program t_crc32;

{$i STD.INC}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT, {$endif}
  crc32;

begin
  writeln('CRC32 self test passed: ',CRC32SelfTest);
end.
