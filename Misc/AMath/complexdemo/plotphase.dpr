program plotphase;

uses
  Forms,
  uphase in 'uphase.pas' {Form1};

{$R *.RES}
{.$R windowsxp.RES}

begin
{$ifdef VER320}
  {$ifdef MSWINDOWS}
    {$warn SYMBOL_PLATFORM OFF}
    ReportMemoryLeaksOnShutdown := DebugHook <> 0;
  {$endif}
{$endif}
  Application.Initialize;
  Application.Title := ' Phase plot';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
