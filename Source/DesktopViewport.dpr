program DesktopViewport;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Desktop Viewport';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
