{-Test prog for Whirlpool}

program t_whirl;

{$i STD.INC}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT,{$endif}
  mem_util, whirl512;

begin
  writeln('WhirlPool self test passed: ', Whirl_SelfTest);
end.
