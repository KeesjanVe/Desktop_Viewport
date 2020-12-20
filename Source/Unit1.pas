unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, fcStatusBar, Mask, RzEdit, RzButton,ShellApi;

type
  TForm1 = class(TForm)
    Button1: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Button2: TButton;
    RzNumericTop: TRzNumericEdit;
    RzNumericLeft: TRzNumericEdit;
    RzNumericWidth: TRzNumericEdit;
    RzNumericHeight: TRzNumericEdit;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
 procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;    
  private
    { Private declarations }
    screenleft, screenwidth,screenheight,screentop: integer;
    Start: Integer;
    Stop: Boolean;
    procedure WMNCPaint(var Msg: TWMNCPaint); message WM_NCPAINT;
    procedure FormFrame;
    procedure WMNCActivate(var Msg: TWMNCActivate); message WM_NCACTIVATE;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure NoMove(var Msg: TWMWindowPosChanging); message WM_WINDOWPOSChanging;
    procedure WMEnterSizeMove(var Message: TMessage) ; message WM_ENTERSIZEMOVE;
    procedure WMMove(var Message: TMessage) ; message WM_MOVE;
    procedure WMExitSizeMove(var Message: TMessage) ; message WM_EXITSIZEMOVE;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  isDraging: boolean;
  X0, Y0: single;


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
  xxy := CreateRectRgn(2,2,ClientWidth-2,ClientHeight-2);
  combinergn(xxx,xxy,xxx, rgn_xor);
  deleteObject(xxy);
  SetWindowRgn (handle, xxx, true);

  button1.Visible := false;
  Button3.Visible := False;
  GroupBox1.Visible := False;
  
  refresh;
  application.processmessages;
  stop := True;

  screentop := Form1.Top+2;
  screenleft:= Form1.left+2;

  screenwidth := Form1.ClientWidth-3;
  screenheight:= Form1.ClientHeight-3;


  Fault := 0;
  Start := 1;
  WorkingDirP := pchar(ExtractFilePath(Application.ExeName));
  CmdLine := format('vlc.exe --qt-minimal-view --no-autoscale screen:// :screen-fps=5.000000 :live-caching=1 :screen-top=%d :screen-left=%d :screen-width=%d :screen-height=%d',[screentop, screenleft, screenwidth, screenheight]);
//      showmessage(CmdLine);
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
 stop := True;
end;

procedure TForm1.CreateParams(var Params: TCreateParams);
begin
 BorderStyle := bsNone;
 inherited  CreateParams(Params);
     Params.ExStyle:= Params.ExStyle or WS_EX_APPWINDOW;
// Params.ExStyle := Params.ExStyle or WS_EX_STATICEDGE;
// Params.Style := Params.Style or WS_SIZEBOX;

end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  isDraging := True;
  X0 := X;
  Y0 := Y;
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   if isDraging then
  begin
    Form1.Left := Trunc(Form1.Left + X - X0);
    Form1.Top := Trunc(Form1.Top + Y - Y0);
  end;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  isDraging := False;
end;

procedure TForm1.WMNCHitTest(var Message: TWMNCHitTest);
const
  EDGEDETECT = 7; // adjust
var
  deltaRect: TRect;
begin
  inherited;
  if BorderStyle = bsNone then
    with Message, deltaRect do
    begin
      Left := XPos - BoundsRect.Left;
      Right := BoundsRect.Right - XPos;
      Top := YPos - BoundsRect.Top;
      Bottom := BoundsRect.Bottom - YPos;
      if (Top < EDGEDETECT) and (Left < EDGEDETECT) then
        Result := HTTOPLEFT
      else if (Top < EDGEDETECT) and (Right < EDGEDETECT) then
        Result := HTTOPRIGHT
      else if (Bottom < EDGEDETECT) and (Left < EDGEDETECT) then
        Result := HTBOTTOMLEFT
      else if (Bottom < EDGEDETECT) and (Right < EDGEDETECT) then
        Result := HTBOTTOMRIGHT
      else if (Top < EDGEDETECT) then
        Result := HTTOP
      else if (Left < EDGEDETECT) then
        Result := HTLEFT
      else if (Bottom < EDGEDETECT) then
        Result := HTBOTTOM
      else if (Right < EDGEDETECT) then
        Result := HTRIGHT
    end;
end;



procedure TForm1.WMNCPaint(var Msg: TWMNCPaint);
begin
  inherited;
  if not stop then FormFrame;
end;

procedure TForm1.FormFrame;
var
  dc: hDc;
  Pen: hPen;
  OldPen: hPen;
  OldBrush: hBrush;
begin
  if stop then exit;
  dc := GetWindowDC(Handle);

  canvas.brush.color := clBtnFace;
  Canvas.fillrect(Canvas.ClipRect);
//  PatBlt(Canvas.Handle, 0, 0, ClientWidth, ClientHeight,WHITENESS	);

  Pen := CreatePen(PS_SOLID, 1, RGB(255, 0, 0));
  OldPen := SelectObject(dc, Pen);
  OldBrush := SelectObject(dc, GetStockObject(NULL_BRUSH));
  Rectangle(dc, 0, 0, Form1.Width, Form1.Height);
  SelectObject(dc, OldBrush);
  SelectObject(dc, OldPen);
  DeleteObject(Pen);
  ReleaseDC(Handle, Canvas.Handle);
end;

procedure TForm1.WMNCActivate(var Msg: TWMNCActivate);
begin
  inherited;
  if not stop then FormFrame;
end;

procedure TForm1.WMSize(var Msg: TWMSize);
begin
  inherited;
  if not stop then FormFrame;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  Button2.tag := 0;
  application.processmessages;
  sendmessage(Self.handle,WM_Size, 0,0);
  Stop := False;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  close;
end;

procedure TForm1.NoMove(var Msg: TWMWindowPosChanging);
begin
 if (Start = 1 )then
  Msg.WindowPos^.Flags := Msg.WindowPos^.Flags or
                          SWP_NOMOVE or
                          SWP_NOSIZE or
                          SWP_NOZORDER;
end;

procedure TForm1.WMEnterSizeMove(var Message: TMessage);
begin
  inherited;
end;

procedure TForm1.WMExitSizeMove(var Message: TMessage);
var x: Integer;
begin
  if ClientWidth < 137 then
    ClientWidth := 137;
  RzNumericWidth.Value := ClientWidth-4;

  if ClientHeight < 223 then
    ClientHeight := 223;
  RzNumericHeight.Value := clientheight-4;

  RzNumericLeft.Value := Form1.left+2;
  RzNumericTop.Value := Form1.Top+2;

  for x := 0 to Form1.ControlCount-1 do
    controls[x].repaint;

  for x := 0 to GroupBox1.ControlCount-1 do
    GroupBox1.controls[x].repaint;

end;

procedure TForm1.WMMove(var Message: TMessage);
begin
   if Button2.tag = 1 then exit;
  RzNumericWidth.Value := ClientWidth-4;
  RzNumericHeight.Value := clientheight-4;
  RzNumericLeft.Value := TWMMove(Message).XPos+2;
  RzNumericTop.Value := TWMMove(Message).YPos+2;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Button2.tag := 1;
  try
    Form1.left := trunc(RzNumericLeft.Value)-2;
    Form1.top  := trunc(RzNumericTop.Value)-2;
    ClientWidth := trunc(RzNumericWidth.value)+4;
    clientheight := Trunc(RzNumericHeight.value)+4;
  finally
  Button2.tag := 0;
  repaint;
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i: Integer;
  T, L, R, B, W, H : integer;
  Fault: String;
begin
  Start := 0;
  Self.top := (Screen.Height div 2) - 144;
  T := Self.top;
  Self.Left := (Screen.Width div 2) - 74;
  L:= Self.Left;

  W:= 146;
  H:= 261;
  R := Self.Left + 146;
  B := Self.Top + 288;
  for i := 1 to ParamCount do
  begin
    try
      Fault := '-T';
      if ParamStr(i) = '-T' then T := StrToInt(ParamStr(i+1));
      Fault := '-L';
      if ParamStr(i) = '-L' then L := StrToInt(ParamStr(i+1));
      Fault := '-R';
      if ParamStr(i) = '-R' then R := StrToInt(ParamStr(i+1));
      Fault := '-B';
      if ParamStr(i) = '-B' then B := StrToInt(ParamStr(i+1));
      Fault := '-W';
      if ParamStr(i) = '-W' then W := StrToInt(ParamStr(i+1));
      Fault := '-H';
      if ParamStr(i) = '-H' then H := StrToInt(ParamStr(i+1));
    except
    Begin
      Showmessage('Wrong parameter value for parameter: '+Fault +' ' +ParamStr(i+1));
      exit;
    end;
    end;
  end;
    try
      if (T < 0) then Raise exception.create('Negative parameter value for parameter: -T '+IntToStr(T));
      if (L < 0) then Raise exception.create('Negative parameter value for parameter: -L '+IntToStr(L));
      if (R < 0) then Raise exception.create(Format('Negative parameter value for parameter: -R %d',[R]));
      if (B < 0) then Raise exception.create(Format('Negative parameter value for parameter: -B %d',[B]));

      if (W < 146) then Raise exception.create('Parameter value for parameter: -W '+IntToStr(W)+ 'is to small: min value = 146');
      if (H < 261) then Raise exception.create('Parameter value for parameter: -H '+IntToStr(H)+ ' is to small: min value = 261');
      if (R-L < 146) then Raise exception.create(Format('Parameter value for parameters: -R - -L (%d - %d < min width: 146)',[R, L]));
      if (B-T < 261) then Raise exception.create(Format('Parameter value for parameters: -B - -T (%d - %d < min height: 261)',[B, T]));
    except
      raise;
   end;
   if FindCmdLineSwitch('T', ['-'], false) then Self.Top := T-2;
   if FindCmdLineSwitch('L', ['-'], false) then Self.Left := L-2;

   if FindCmdLineSwitch('R', ['-'], false) then Self.Width := (R - L) + 4;
   if FindCmdLineSwitch('B', ['-'], false) then Self.Height := (B - T) +4;

//   if FindCmdLineSwitch('W', ['-'], false) then Self.Width := W+4;
//   if FindCmdLineSwitch('H', ['-'], false) then Self.Height := H+4;

   if FindCmdLineSwitch('W', ['-'], false) then Self.ClientWidth := W;
   if FindCmdLineSwitch('H', ['-'], false) then Self.ClientHeight := H;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  if not stop then FormFrame;
  inherited;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  RzNumericWidth.Value := ClientWidth-4;
  RzNumericHeight.Value := clientheight-4;
  RzNumericLeft.Value := Form1.left+2;
  RzNumericTop.Value := Form1.Top+2;
end;


end.
