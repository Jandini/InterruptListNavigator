unit FindUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,    StdCtrls;

type
  TfrmFind = class(TForm)
    lblFind: TLabel;
    edtTextFind: TEdit;
    btnFind: TButton;
    btnClose: TButton;
    chkCase: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnFindClick(Sender: TObject);
    procedure edtTextFindKeyDown(Sender: TObject; var Key: Word;        Shift: TShiftState);
  private
    FSearchText: String;
    FSearch: Boolean;
    FCaseSensitive: Boolean;
    procedure SetSearchText(const Value: String);
    { Private declarations }
  public
    property SearchText: String read FSearchText write SetSearchText;
    property Search: Boolean read FSearch;
    property CaseSensitive: Boolean read FCaseSensitive;

    function FindInText(SearchStr: string; StartPos, _Length: Integer): Integer;
    { Public declarations }
  end;

var
  frmFind: TfrmFind;

implementation

uses MainUnit;

{$R *.DFM}

procedure TfrmFind.FormShow(Sender: TObject);
begin
  Left := frmMain.Left + (frmMain.Width div 2) - (Width div 2);
  Top := frmMain.Left + (frmMain.Height div 2) - (Height div 2);
  edtTextFind.SetFocus;
  edtTextFind.SelectAll;
end;

procedure TfrmFind.btnCloseClick(Sender: TObject);
begin
  FSearch := False;
  Close;
end;


procedure TfrmFind.btnFindClick(Sender: TObject);
begin
  FSearch := True;
  FCaseSensitive := chkCase.Checked;
  FSearchText := edtTextFind.Text;
  if not FCaseSensitive then
   FSearchText := StrUpper(PChar(FSearchText));
  if FSearchText = '' then FSearch := False;
  Close;
end;



function TfrmFind.FindInText(SearchStr: string; StartPos, _Length: Integer): Integer;
var
  s: string;
begin
  if StartPos < 0 then begin
    Result := -1;
    Exit;
  end;
  s := Copy(SearchStr, StartPos + 1 , _Length + 1);
  if not FCaseSensitive then
    s := StrUpper(PChar(s));

  Result := Pos(SearchText, s) - 1;
  if Result >= 0 then begin
    Result := StartPos + Result
  end else
    Result := -1;
end;

procedure TfrmFind.SetSearchText(const Value: String);
begin
  FSearchText := Value;
end;

procedure TfrmFind.edtTextFindKeyDown(Sender: TObject; var Key: Word;    Shift: TShiftState);
begin
  case key of
    VK_UP: btnClose.SetFocus;
    VK_DOWN: chkCase.SetFocus;
  end;
end;

end.
