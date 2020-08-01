{-Test prog for CRC24, we 02.04.06}

program t_crc24;

{$i STD.INC}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT, {$endif}
  crc24;

begin
  writeln('CRC24 self test passed: ',CRC24SelfTest);
end.
