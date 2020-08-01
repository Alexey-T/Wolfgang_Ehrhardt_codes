{-Test prog for SHA512/256 and SHA512/256, we 15.02.11}

program t_sha5t;

{$i STD.INC}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT, {$endif}
  sha5_224,sha5_256;

begin
  writeln('SHA512/224 self test passed: ', SHA5_224SelfTest);
  writeln('SHA512/256 self test passed: ', SHA5_256SelfTest);
end.
