{-Test prog for RIPEMD-160, we 31.01.06}

program t_rmd160;

{$i STD.INC}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT, {$endif}
  rmd160;

begin
  writeln('RIPEMD-160 self test passed: ',RMD160SelfTest);
end.
