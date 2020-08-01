{-Test prog for SHA1, we 14.03.02}

program t_sha1;

{$i STD.INC}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT, {$endif}
  sha1;

begin
  writeln('SHA1 self test passed: ',SHA1SelfTest);
end.
