{-Test prog for MD4, we 18.02.07}

program t_md4;

{$i STD.INC}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT, {$endif}
  md4;

begin
  writeln('MD4 self test passed: ',MD4SelfTest);
end.
