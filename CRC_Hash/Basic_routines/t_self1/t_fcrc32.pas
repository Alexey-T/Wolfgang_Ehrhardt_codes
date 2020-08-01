{-Test prog for FCRC32, we 28.06.07}

program t_fcrc32;

{$i STD.INC}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT, {$endif}
  fcrc32;

begin
  writeln('FCRC32 self test passed: ',FCRC32SelfTest);
end.
