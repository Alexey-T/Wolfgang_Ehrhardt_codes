{-Test prog for SHA224, we 02.01.04}

program t_sha224;

{$i STD.INC}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT,{$endif}
  sha224;

begin
  writeln('SHA224 self test passed: ', SHA224SelfTest);
end.
