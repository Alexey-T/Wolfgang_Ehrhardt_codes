{-Test prog for bCRC32, we 06.07.03}

program t_bcrc32;

{$i STD.INC}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT, {$endif}
  bcrc32;

begin
  writeln('bCRC32 self test passed: ',bCRC32SelfTest);
end.
