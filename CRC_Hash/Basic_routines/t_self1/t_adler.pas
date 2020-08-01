{-Test prog for Adler32, we 30.08.03}

program t_adler;

{$i STD.INC}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT, {$endif}
  Adler32;

begin
  writeln('Adler32 self test passed: ',Adler32SelfTest);
end.
