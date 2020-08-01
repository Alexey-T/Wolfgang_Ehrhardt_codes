{-Test prog for bCRC64, we 07.07.03}

program t_bcrc64;

{$i STD.INC}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT, {$endif}
  bcrc64;

begin
  writeln('bCRC64 self test passed: ',bCRC64SelfTest);
end.
