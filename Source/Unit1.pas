unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, graphics, Controls, Forms,
  StdCtrls, ShellApi;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  screenleft, screenwidth,screenheight,screentop: integer;
  Start: Integer;
  procedure NoMove(var Msg: TWMWindowPosChanging); message WM_WINDOWPOSChanging;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
  xxx : hrgn;
  xxy : hrgn;
  CmdLine: string;
  WorkingDirP: PChar;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  SEInfo: TShellExecuteInfo;
  ExecuteFile, ParamString: string;
  Fault :Integer;
  ExitCode: DWORD;
begin
    xxx := Createrectrgn(0,0,width,height);
    xxy := CreateRectRgn(width-clientwidth-5, height-clientheight-6, ClientWidth+6, ClientHeight+27);
    combinergn(xxx,xxy,xxx, rgn_xor);
    deleteObject(xxy);
  SetWindowRgn (handle, xxx, true);
//  SetWindowPos(Form1.Handle, HWND_TOPMOST, 0, 0, 0, 0,SWP_NoMove or SWP_NoSize);


  button1.Visible := false;
  form1.Color := clRed;
  refresh;
  screenleft:= Form1.left+ width-clientwidth-5;
  screenwidth := ClientWidth-5;
  screenheight:= clientheight-5;
  screentop :=  Form1.top + height-clientheight-6;
  Fault := 0;
  Start := 1;
  WorkingDirP := pchar(ExtractFilePath(Application.ExeName));
  CmdLine := format('vlc.exe --qt-minimal-view --no-autoscale screen:// :screen-fps=5.000000 :live-caching=1 :screen-left=%d :screen-width=%d :screen-height=%d :screen-top=%d',[screenleft, screenwidth, screenheight, screentop]);
  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
  StartupInfo.wShowWindow := 1;
if not CreateProcess(nil,
    pchar(CmdLine),
    nil,
    nil,
    False,
    0,
    nil,
    WorkingDirP,
    StartupInfo,
    ProcessInfo)
    then
    Fault := 1 else
  with ProcessInfo do
    begin
    Close;
      CloseHandle(hThread);
      WaitForInputIdle(hProcess, INFINITE);
        repeat
          Application.ProcessMessages;
        until MsgWaitForMultipleObjects(1, hProcess, false, INFINITE, QS_ALLINPUT) <> WAIT_OBJECT_0 + 1;
      CloseHandle(hProcess);
    end;
  if (Fault = 1) then
  begin
    ExecuteFile:='VLC.exe';
    ParamString := format('--qt-minimal-view --no-autoscale screen:// :screen-fps=5.000000 :live-caching=1 :screen-left=%d :screen-width=%d :screen-height=%d :screen-top=%d',[screenleft, screenwidth, screenheight, screentop]);
    FillChar(SEInfo, SizeOf(SEInfo), 0);
    SEInfo.cbSize := SizeOf(TShellExecuteInfo);
    with SEInfo do begin
      fMask := SEE_MASK_NOCLOSEPROCESS;
      Wnd := Application.Handle;
      lpFile := PChar(ExecuteFile);
      lpParameters := PChar(ParamString);
      lpDirectory := PChar(WorkingDirP);
      nShow := SW_SHOWNORMAL;
    end;
    if ShellExecuteEx(@SEInfo) then
    begin
    close;
      repeat
        Application.ProcessMessages;
        GetExitCodeProcess(SEInfo.hProcess, ExitCode);
      until (ExitCode <> STILL_ACTIVE)
    end;
  end;
end;

procedure TForm1.NoMove(var Msg: TWMWindowPosChanging);
begin
 if (Start = 1 )then
  Msg.WindowPos^.Flags := Msg.WindowPos^.Flags or
                          SWP_NOMOVE or
                          SWP_NOSIZE or
                          SWP_NOZORDER;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Start := 0;
end;

end.
