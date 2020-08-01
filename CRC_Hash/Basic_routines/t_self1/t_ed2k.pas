{-Test prog for ED2K, we 19.02.07}

program t_ek2k;

{$i STD.INC}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT, {$endif}
  ed2k;

begin
  writeln('ED2K self test passed: ',ed2k_SelfTest);
end.
