unit AboutUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, StdCtrls, ShellApi;

type
  TfrmAbout = class(TForm)
    imgIcon: TImage;
    lblTitle: TLabel;
    memInfo: TMemo;
    bevTitleLine: TBevel;
    btnClose: TButton;
    chkStartUp: TCheckBox;
    lblAutor: TLabel;
    lblEmail: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure memInfoEnter(Sender: TObject);
    procedure lblEmailClick(Sender: TObject);
    procedure chkStartUpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

uses MainUnit;

{$R *.DFM}

procedure TfrmAbout.FormCreate(Sender: TObject);
begin
  imgIcon.Picture.Icon:=Application.Icon;
end;

procedure TfrmAbout.FormShow(Sender: TObject);
begin
  Left := frmMain.Left + (frmMain.Width div 2) - (Width div 2);
  Top := frmMain.Left + (frmMain.Height div 2) - (Height div 2);
  chkStartUp.Checked := ShowAbout;
end;

procedure TfrmAbout.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmAbout.memInfoEnter(Sender: TObject);
begin
  btnClose.SetFocus;
end;

procedure TfrmAbout.lblEmailClick(Sender: TObject);
begin
  ShellExecute(GetDesktopWindow(), 'open', PChar('mailto:mat@elzab.com.pl?Subject='), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmAbout.chkStartUpClick(Sender: TObject);
begin
  ShowAbout := chkStartUp.Checked; 
end;

end.
