unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, ToolWin, Menus, ImgList, ListUnit, CheckLst,
  IniFiles, Buttons;

type
  TfrmMain = class(TForm)
    barStatus: TStatusBar;
    tblToolBar: TToolBar;
    splSplitter: TSplitter;
    btnFind: TToolButton;
    imgList: TImageList;
    mnuMainMenu: TMainMenu;
    mnuInterrupts: TMenuItem;
    mnuHelp: TMenuItem;
    mnuAbout: TMenuItem;
    mnuSearch: TMenuItem;
    mnuSeparator: TMenuItem;
    mnuExit: TMenuItem;
    btnSeparator2: TToolButton;
    btnChange: TToolButton;
    btnSeparator3: TToolButton;
    btnCopy: TToolButton;
    lstInterrupt: TListBox;
    pnlEditPanel: TPanel;
    edtSearch: TEdit;
    timStart: TTimer;
    timStatusBar: TTimer;
    btnFindNext: TToolButton;
    btnPrint: TToolButton;
    mnuWindow: TMenuItem;
    mnuScreenSize: TMenuItem;
    mnuSplitLeft: TMenuItem;
    mnuSplitRight: TMenuItem;
    mnuFindNext: TMenuItem;
    mnuChangeTitles: TMenuItem;
    mnuEdit: TMenuItem;
    mnuCopy: TMenuItem;
    mnuFont: TMenuItem;
    dlgFonts: TFontDialog;
    mnuExtSelect: TMenuItem;
    edtViewText: TMemo;
    mnuPrint: TMenuItem;
    ToolButton1: TToolButton;
    btnAbout: TToolButton;
    btnExit: TToolButton;
    Timer1: TTimer;
    procedure FormResize(Sender: TObject);
    procedure splSplitterCanResize(Sender: TObject; var NewSize: Integer;
      var Accept: Boolean);
    procedure OnLoadComplete;
    procedure lstInterruptClick(Sender: TObject);
    procedure lstInterruptKeyPress(Sender: TObject; var Key: Char);
    procedure edtSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtSearchKeyPress(Sender: TObject; var Key: Char);
    procedure ShowText;
    procedure lstInterruptsClick(Sender: TObject);
    procedure edtViewTextEnter(Sender: TObject);
    procedure edtViewTextKeyPress(Sender: TObject; var Key: Char);
    procedure timStartTimer(Sender: TObject);
    procedure edtSearchChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnChangeClick(Sender: TObject);
    procedure timStatusBarTimer(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure OnLoad(Count: Integer; var BreakReq: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnFindClick(Sender: TObject);
    procedure mnuScreenSizeClick(Sender: TObject);
    procedure mnuSplitLeftClick(Sender: TObject);
    procedure mnuSplitRightClick(Sender: TObject);
    procedure mnuFontClick(Sender: TObject);
    procedure dlgFontsApply(Sender: TObject; Wnd: HWND);
    procedure FormCreate(Sender: TObject);
    procedure mnuExtSelectClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnFindNextClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;
  InterruptItem: TInterrupt;
  InterruptList: TInterruptsList;
  LastIndex: Integer = -1;

  NoChange: Boolean = False;
  Titles: Boolean = False;
  Changing: Boolean = False;
  Printing: Boolean = False;
  ExitReq: Boolean = False;
  ShowAbout: Boolean = False;
  UpdateFont: Boolean = False;
  Searching: Boolean = False;
  FindNext: Boolean = False;

  IniFile: TIniFile;

const
  FILE_NAME = 'INTER.LST';
  VK_PGUP = 33;
  VK_PGDN = 34;
  MIN_VIEW_WIDTH = 190;

implementation

{$R *.DFM}
uses Printers, WinSpool, AboutUnit, FindUnit;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  if (lstInterrupt.Width > frmMain.Width) then
    lstInterrupt.Width := frmMain.Width div 2;

  if (edtViewText.Width < MIN_VIEW_WIDTH) then
    lstInterrupt.Width := (frmMain.Width + edtViewText.Width); 

  pnlEditPanel.Width := lstInterrupt.Width;
  edtSearch.Left := 0;
  edtSearch.Width := lstInterrupt.Width;
  splSplitter.Refresh;
  barStatus.Panels[0].Width := lstInterrupt.Width + 1;
end;

procedure TfrmMain.splSplitterCanResize(Sender: TObject; var NewSize: Integer;
  var Accept: Boolean);
begin
  if NewSize < 200 then
    Accept := False;
end;

procedure TfrmMain.OnLoadComplete;
begin
  barStatus.Panels[0].Text := Format('Loaded %d indexes.',[InterruptList.Count]);
end;

procedure TfrmMain.lstInterruptClick(Sender: TObject);
begin
  ShowText;
  edtSearch.Text := '';
end;

procedure TfrmMain.lstInterruptKeyPress(Sender: TObject; var Key: Char);
begin
  if UpCase(key) in ['0'..'9','A'..'Z',#8] then begin
    edtSearch.SetFocus;
    SendMessage(edtSearch.Handle,WM_CHAR,Integer(key),0);
    key := #0;
  end;
  if key = #13 then
    edtViewText.SetFocus;
end;



procedure TfrmMain.edtSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ([ssCtrl]*Shift = [ssCtrl]) then begin
    case key of
      VK_LEFT: if lstInterrupt.Width > 200 then lstInterrupt.Width := lstInterrupt.Width - 20;
      VK_RIGHT: if lstInterrupt.Width < Round(frmMain.Width / 1.4) then lstInterrupt.Width := lstInterrupt.Width + 20;
    end;
    if key in [VK_LEFT, VK_RIGHT] then key := 0;
    frmMain.Resize;
  end;

  if key in [VK_UP,VK_DOWN,VK_HOME,VK_END,VK_PGDN,VK_PGUP] then begin
    lstInterrupt.SetFocus;
    SendMessage(lstInterrupt.Handle,WM_KEYDOWN,key,0);
  end;
end;

procedure TfrmMain.edtSearchKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then begin
    key := #0;
    edtViewText.SetFocus;
  end;
end;

procedure TfrmMain.ShowText;
var
  i, j: integer;
  classified: string;
begin
  if (Changing) then
    exit;

  j := lstInterrupt.ItemIndex;
  if ((LastIndex <> lstInterrupt.ItemIndex)) or (UpdateFont) then begin
    LastIndex := lstInterrupt.ItemIndex;
    timStatusBar.Enabled := True;
    edtViewText.Clear;
    edtViewText.Lines.BeginUpdate;

    i := 0;
    while (i < InterruptList.Items[j].Text.Count) and (lstInterrupt.ItemIndex = j) do begin
      Application.ProcessMessages;
      edtViewText.Lines.Add(InterruptList.Items[j].Text[i]);
      inc(i);
    end;
    edtViewText.Lines.EndUpdate;
  end;

  timStatusBar.Enabled := False;

  classified := '';
  case InterruptList.Items[j].FullInfo[9] of
    'A' : classified := 'applications';
    'a' : classified := 'access software (screen readers, etc)';
    'B' : classified := 'BIOS';
    'b' : classified := 'vendor-specific BIOS extensions';
    'C' : classified := 'CPU-generated';
    'c' : classified := 'caches/spoolers';
    'D' : classified := 'DOS kernel';
    'd' : classified := 'disk I/O enhancements';
    'E' : classified := 'DOS extenders';
    'e' : classified := 'electronic mail';
    'F' : classified := 'FAX';
    'f' : classified := 'file manipulation';
    'G' : classified := 'debuggers/debugging tools';
    'g' : classified := 'games';
    'H' : classified := 'hardware';
    'h' : classified := 'vendor-specific hardware';
    'I' : classified := 'IBM workstation/terminal emulators';
    'i' : classified := 'system info/monitoring';
    'J' : classified := 'Japanese';
    'j' : classified := 'joke programs';
    'K' : classified := 'keyboard enhancers';
    'k' : classified := 'file/disk compression';
    'l' : classified := 'shells/command interpreters';
    'M' : classified := 'mouse/pointing device';
    'm' : classified := 'memory management';
    'N' : classified := 'network';
    'n' : classified := 'non-traditional input devices';
    'O' : classified := 'other operating systems';
    'P' : classified := 'printer enhancements';
    'p' : classified := 'power management';
    'Q' : classified := 'DESQview/TopView and Quarterdeck programs';
    'R' : classified := 'remote control/file access';
    'r' : classified := 'runtime support';
    'S' : classified := 'serial I/O';
    's' : classified := 'sound/speech';
    'T' : classified := 'DOS-based task switchers/multitaskers';
    't' : classified := 'TSR libraries';
    'U' : classified := 'resident utilities';
    'u' : classified := 'emulators';
    'V' : classified := 'video';
    'v' : classified := 'virus/antivirus';
    'W' : classified := 'MS Windows';
    'X' : classified := 'expansion bus BIOSes';
    'x' : classified := 'non-volatile config storage';
    'y' : classified := 'security';
    '*' : classified := 'reserved (not classified)';
  end;
  barStatus.Panels[1].Text := classified;
  barStatus.Panels[0].Text := format('INT %s', [Copy(InterruptList.Items[lstInterrupt.ItemIndex].IntInfo,1,2)]);
end;

procedure TfrmMain.lstInterruptsClick(Sender: TObject);
begin
  ShowText;
  NoChange := True;
  edtSearch.Text := '';
  NoChange := False;
end;

procedure TfrmMain.edtViewTextEnter(Sender: TObject);
begin
  edtViewText.SelStart := 0;
  edtViewText.SelLength := 0;
end;

procedure TfrmMain.edtViewTextKeyPress(Sender: TObject; var Key: Char);
begin
  if key in [#27,#13] then
    lstInterrupt.SetFocus;
end;

procedure TfrmMain.timStartTimer(Sender: TObject);
begin
  timStart.Enabled := False;
  barStatus.Panels[0].Text := 'Loading data...';
  barStatus.Refresh;
  if ShowAbout then
    frmAbout.Show;
  InterruptList := TInterruptsList.Create;
  InterruptList.OnLoadComplete := OnLoadComplete;
  InterruptList.OnLoad := OnLoad;
  Changing := True;
  InterruptList.LoadFromFile(FILE_NAME,InterruptList, lstInterrupt);
  Changing := False;
  lstInterrupt.ItemIndex := 0;
  edtSearch.SetFocus;
  ShowText;
  frmAbout.Hide;
  frmAbout.Caption := 'About this program';
  lstInterrupt.Selected[0] := True;
end;

procedure TfrmMain.edtSearchChange(Sender: TObject);
var
  i: integer;
  w: integer;
begin

  if (NoChange) or (Changing) then
    exit;

  lstInterrupt.Selected[LastIndex] := False;
  Changing := True;
  i := lstInterrupt.ItemIndex;
  if i > lstInterrupt.Items.Count - 1 then
    i := 0;
  barStatus.Panels[0].Text := 'Searching...';
  w := 0;
  while (not ExitReq) and (w <> lstInterrupt.Items.Count) and (StrLComp(StrUpper(PChar(lstInterrupt.Items[i])),StrUpper(PChar(edtSearch.Text)),Length(edtSearch.Text)) <> 0) do begin
    inc(i);
    inc(w);
    if i = lstInterrupt.Items.Count - 1 then
      i := 0;
    Application.ProcessMessages;
  end;
  Changing := False;

  if w = lstInterrupt.Items.Count then
    barStatus.Panels[0].Text := Format('"%s" not found.',[edtSearch.Text])
  else begin
    lstInterrupt.ItemIndex := i;
    ShowText;
    if lstInterrupt.ExtendedSelect then
      lstInterrupt.Selected[lstInterrupt.ItemIndex] := True;
  end;

  if edtSearch.Text = '' then begin
    lstInterrupt.ItemIndex := 0;
  end;

end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  lstInterrupt.Font := dlgFonts.Font;
  edtViewText.Font := dlgFonts.Font;
  edtSearch.Font := dlgFonts.Font;
  barStatus.Font := dlgFonts.Font;

  if Screen.Width = 640 then begin
    Left := 0;
    Top := 0;
  end else
  begin
    Left := (Screen.Width div 2) - (Width div 2);
    Top := (Screen.Height div 2) - (Height div 2);
  end;
  Application.HintPause := 10;
end;


procedure TfrmMain.btnChangeClick(Sender: TObject);
var
  i: integer;
  _Info: String;
  ci: integer;
begin
  if (Changing) or (Searching) then
    exit;
  Changing := True;
  Titles := not Titles;
  ci := lstInterrupt.ItemIndex;

  lstInterrupt.Items.BeginUpdate;
  lstInterrupt.Items.Clear;
  barStatus.Panels[0].Text := 'Please wait...';
  if Titles then begin
    for i := 0 to InterruptList.Last do
     begin
      lstInterrupt.Items.Add(Format('%s %s',[InterruptList.Items[i].Description, InterruptList.Items[i].IntInfo]));
      if (i mod 10) = 0 then
        Application.ProcessMessages;
     end;
     edtSearch.CharCase := ecNormal;
   end
   else begin
    for i := 0 to InterruptList.Last do
     begin
      _Info := InterruptList.Items[i].FullInfo;
      _Info := Copy(_Info,11,Pos('------------',_Info) - 11);
       while Length(_Info) < 15 do _Info := _Info + ' ';
      _Info := _Info + InterruptList.Items[i].Description;
      lstInterrupt.Items.Add(_Info);
      if (i mod 10) = 0 then
        Application.ProcessMessages;
     end;
     edtSearch.CharCase := ecUpperCase;
   end;
  lstInterrupt.Items.EndUpdate;
  barStatus.Panels[0].Text := '';
  lstInterrupt.ItemIndex := ci;
  if lstInterrupt.ExtendedSelect then
    lstInterrupt.Selected[lstInterrupt.ItemIndex] := True;
  lstInterrupt.SetFocus;
  Changing := False;
end;

procedure TfrmMain.timStatusBarTimer(Sender: TObject);
begin
  timStatusBar.Enabled := False;
  barStatus.Panels[0].Text := 'Reading text...';
end;

procedure TfrmMain.btnCopyClick(Sender: TObject);
begin
  edtViewText.Lines.BeginUpdate;
  edtViewText.SelectAll;
  edtViewText.CopyToClipboard;
  edtViewText.SelLength := 0;
  edtViewText.Lines.EndUpdate;
end;

procedure TfrmMain.OnLoad(Count: Integer;var BreakReq: Boolean);
begin
  Application.ProcessMessages;
  if ExitReq then
    BreakReq := True;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Changing then
    exit;
  try
    IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName) + '\inter.ini');
    with IniFile do begin
      WriteString('CFG','FontName',dlgFonts.Font.Name);
      WriteInteger('CFG','FontSize',dlgFonts.Font.Size);
      WriteInteger('CFG','ShowAbout',Integer(ShowAbout));
    end;
  finally
    IniFile.Free;
    Halt;
  end;
end;


procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  ExitReq := True;
end;

procedure TfrmMain.btnFindClick(Sender: TObject);
var
  Found: Boolean;
  FoundAt: Integer;
  FindText: String;
  FindIndex: Integer;

begin
  if (Searching) or (Changing) then
    exit;

  FindIndex := 0;
  if not FindNext then
    frmFind.ShowModal
  else
    if lstInterrupt.ItemIndex < lstInterrupt.Items.Count - 1 then
      FindIndex := lstInterrupt.ItemIndex + 1;

  if (frmFind.Search) or (FindNext) then begin
    Searching := True;
    FindNext := False;    
    Found := False;
    barStatus.Panels[1].Text := '';
    barStatus.Panels[0].Text := 'Searching text...';
    edtViewText.SelLength := 0;
    edtViewText.Lines.BeginUpdate;
    lstInterrupt.Items.BeginUpdate;
    lstInterrupt.Enabled := False;


    FoundAt := -1;
    while (FindIndex < lstInterrupt.Items.Count ) and (not Found) and (not ExitReq) do begin
      Application.ProcessMessages;
      if not frmFind.CaseSensitive then
        FindText := StrUpper(PChar(InterruptList.Items[FindIndex].AllText))
      else
        FindText := InterruptList.Items[FindIndex].AllText;
      FoundAt := Pos(frmFind.SearchText, FindText);
      if FoundAt > 0 then Found := True;
      inc(FindIndex);
      barStatus.Panels[0].Text := Format('Searching... %3d%%',[(FindIndex * 100) div lstInterrupt.Items.Count]);
    end;

    lstInterrupt.Items.EndUpdate;
    edtViewText.Lines.EndUpdate;

    lstInterrupt.Enabled := True;

    if not Found then begin
      barStatus.Panels[0].Text := Format('Text "%s" not found.',[frmFind.SearchText]);
      lstInterrupt.SetFocus;
    end
    else begin
      lstInterrupt.ItemIndex := FindIndex - 1;
      ShowText;
      if lstInterrupt.ExtendedSelect then begin
        if lstInterrupt.ItemIndex > 0 then begin
          lstInterrupt.Selected[lstInterrupt.ItemIndex - 1] := True;
          SendMessage(lstInterrupt.Handle,WM_KEYDOWN,VK_DOWN,0);
        end;
      end;
      edtViewText.SetFocus;
      edtViewText.SelStart := FoundAt - 1;
      edtViewText.SelLength := Length(frmFind.SearchText);
    end;
    Searching := False;
  end;
end;

procedure TfrmMain.mnuScreenSizeClick(Sender: TObject);
begin
  if WindowState = wsMaximized then
    WindowState := wsNormal
  else
    WindowState := wsMaximized;
  Resize; 
end;

procedure TfrmMain.mnuSplitLeftClick(Sender: TObject);
begin
  edtViewText.Lines.BeginUpdate;
  if lstInterrupt.Width > 200 then
    lstInterrupt.Width := lstInterrupt.Width - 20;
  frmMain.Resize;
  edtViewText.Lines.EndUpdate;
end;

procedure TfrmMain.mnuSplitRightClick(Sender: TObject);
begin
  edtViewText.Lines.BeginUpdate;
  if btnExit.Left + btnExit.Width * 2 < tblToolBar.Width then
    lstInterrupt.Width := lstInterrupt.Width + 20;
  Resize;
  edtViewText.Lines.EndUpdate;
end;

procedure TfrmMain.mnuFontClick(Sender: TObject);
begin
  if dlgFonts.Execute then begin
    lstInterrupt.Font := dlgFonts.Font;
    edtViewText.Font := dlgFonts.Font;
    edtSearch.Font := dlgFonts.Font;
    barStatus.Font := dlgFonts.Font;
    UpdateFont := True;
    ShowText;
    UpdateFont := False;    
  end;
end;

procedure TfrmMain.dlgFontsApply(Sender: TObject; Wnd: HWND);
begin
  lstInterrupt.Font := dlgFonts.Font;
  edtViewText.Font := dlgFonts.Font;
  edtSearch.Font := dlgFonts.Font;
  barStatus.Font := dlgFonts.Font;
  edtViewText.Refresh;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  try
    IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName) + '\inter.ini');
    with IniFile do begin
      dlgFonts.Font.Name := ReadString('CFG','FontName','FixedSys');
      dlgFonts.Font.Size := ReadInteger('CFG','FontSize',8);
      ShowAbout := Boolean(ReadInteger('CFG','ShowAbout',1));
    end;
  finally
    IniFile.Free;
  end;
  splSplitter.MinSize := MIN_VIEW_WIDTH;
end;


procedure TfrmMain.mnuExtSelectClick(Sender: TObject);
begin
  with lstInterrupt do begin
    barStatus.Panels[0].Text := 'Please wait...';
    barStatus.Panels[1].Text := '';
    barStatus.Update;
    ExtendedSelect := not ExtendedSelect;
    if ExtendedSelect then begin
      barStatus.Panels[0].Text := 'Extended select OFF';
      lstInterrupt.Selected[lstInterrupt.ItemIndex] := True;
    end
    else
      barStatus.Panels[0].Text := 'Extended select ON';
    mnuExtSelect.Checked := not ExtendedSelect;
    SetFocus;
  end;
end;

procedure TfrmMain.btnPrintClick(Sender: TObject);
var
  i,j : integer;
  Size, n: DWord;
  H: THandle;
  Info: PAddJobInfo1;
  F: TextFile;
  sPrinterName, sPort, sDriver : array[0..255] of Char;
begin

  if (Printer.Printers.Text = '') or (Printing) or (lstInterrupt.SelCount = 0) or (Searching) then
    exit;
  if MessageDlg(Format('Print %d selected item(s)?',[lstInterrupt.SelCount]), mtConfirmation, [mbYes, mbNo], 0) = mrNo then
    exit;
  Printer.GetPrinter(sPrinterName,sDriver,sPort,h);
  if sPrinterName = '' then
    Exit;
  Printing := True;
  barStatus.Panels[0].Text := Format('Printing to %s...',[sPrinterName]);
  OpenPrinter(sPrinterName,H,nil);
  try
    AddJob(H,1,nil,0,Size);
    GetMem(Info,Size);
    try
      AddJob(H,1,Info,Size,n);
      AssignFile(F,Info^.Path);
      Rewrite(F);
      try
        for i := 0 to lstInterrupt.Items.Count - 1 do
        if lstInterrupt.Selected[i] then begin
          Write(F,chr(27)+chr(69));
          Writeln(F,InterruptList.Items[i].Text.Strings[0]);
          Write(F,chr(27)+chr(70));
          for j := 1 to InterruptList.Items[i].Text.Count - 1 do
            Writeln(F,InterruptList.Items[i].Text.Strings[j]);
          Writeln(F);
        end;
      finally
        CloseFile(F);
      end;
    ScheduleJob(H,Info^.JobId);
   finally
      FreeMem(Info,Size);
    end;
  finally
    ClosePrinter(H);
  end;
  Printing := False;
  barStatus.Panels[0].Text := '';
end;


procedure TfrmMain.btnFindNextClick(Sender: TObject);
var
  FoundAt: LongInt;
  StartPos, ToEnd: integer;
begin
  if (frmFind.SearchText = '') then begin
    btnFind.Click;
    exit;
  end;  
  if (Changing) then
    exit;
    
  with edtViewText do
  begin
    if SelLength <> 0 then
      StartPos := SelStart + SelLength
    else
      StartPos := 0;
    ToEnd := Length(edtViewText.Text) - StartPos;
    FoundAt := frmFind.FindInText(edtViewText.Text, StartPos, ToEnd);
    if FoundAt <> -1 then
    begin
      SetFocus;
      SelStart := FoundAt;
      SelLength := Length(frmFind.SearchText);
    end else begin
      FindNext := True;
      btnFind.Click;
    end;  
  end;
end;


procedure TfrmMain.btnAboutClick(Sender: TObject);
begin
  frmAbout.Show;
end;

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
  Caption := IntToStr(AllocMemSize);
end;

end.



