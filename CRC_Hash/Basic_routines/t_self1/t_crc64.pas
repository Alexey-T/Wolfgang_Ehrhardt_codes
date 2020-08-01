{-Test prog for CRC64, we 07.07.03}

program t_crc64;

{$i STD.INC}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT, {$endif}
  crc64;

begin
  writeln('CRC64  self test passed: ',CRC64SelfTest);
end.
