{-Test prog for SHA256, we 03.01.02}

program t_sha256;

{$i STD.INC}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT, {$endif}
  sha256;

begin
  writeln('SHA256 self test passed: ', SHA256SelfTest);
end.
