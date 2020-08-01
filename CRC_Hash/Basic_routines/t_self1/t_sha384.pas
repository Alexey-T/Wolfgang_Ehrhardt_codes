{-Test prog for SHA384, we 19.11.03}

program t_sha384;

{$i STD.INC}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT,{$endif}
  sha384;

begin
  writeln('SHA384 self test passed: ', SHA384SelfTest);
end.
