{-Test prog for CRC16, we 18.03.02}

program t_crc16;

{$i STD.INC}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT, {$endif}
  crc16;

begin
  writeln('CRC16 self test passed: ',CRC16SelfTest);
end.
