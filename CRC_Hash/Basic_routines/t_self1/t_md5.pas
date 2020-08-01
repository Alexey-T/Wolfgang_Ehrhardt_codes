{-Test prog for MD5, we 14.03.02}

program t_md5;

{$i STD.INC}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT, {$endif}
  md5;

begin
  writeln('MD5 self test passed: ',MD5SelfTest);
end.
