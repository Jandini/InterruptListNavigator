unit ListUnit;

interface

uses
  Classes, SysUtils, StdCtrls, ComCtrls;

const
  INFO_CHAR = '--------';
  END_CHAR = '------------';
  END_CHAR_LEN = Length(END_CHAR) - 1;
  TAB_SIZE = 15;

type
  TLoadEvent = procedure (Count: Integer; var BreakReq: Boolean) of object;
  TLoadComplete = procedure of object;

  TInterrupt = class (TObject)
  private
    FFullInfo: String;
    FText: TStringList;

    procedure SetFullInfo(const Value: String);
    procedure SetText(const Value: TStringList);
    function GetDescription: String;
    function GetIntInfo: String;
    function GetAllText: String;
  public
    constructor Create; overload;
    constructor Create(_info: String; _Text: TStringList); overload;
    property FullInfo: String read FFullInfo write SetFullInfo;
    property Text: TStringList read FText write SetText;
    property AllText: String read GetAllText;
    property Description: String read GetDescription;
    property IntInfo: String read GetIntInfo;

  end;


  TInterruptsList = class (TObject)
  private
    IntList: TList;
    FOnLoad: TLoadEvent;
    FOnLoadComplete: TLoadComplete;

    InterruptFile: TextFile;
    InterruptStrings: TStringList;

    function GetItems(Index: integer): TInterrupt;
    procedure SetItems(Index: integer; const Value: TInterrupt);
    function GetLast: integer;
    function GetCount: integer;
    procedure SetOnLoad(const Value: TLoadEvent);
    procedure SetOnLoadComplete(const Value: TLoadComplete);

  public
    constructor Create;
    procedure Add(Item: TInterrupt); overload;
    procedure Add(Info: String; Text: TStringList); overload;
    procedure LoadFromFile(FileName: String; var IntList: TInterruptsList; var ListBox: TListBox);

    property Count: integer read GetCount;
    property Last: integer read GetLast;
    property Items[Index: integer]: TInterrupt read GetItems write SetItems;
    property OnLoad: TLoadEvent read FOnLoad write SetOnLoad;
    property OnLoadComplete: TLoadComplete read FOnLoadComplete write SetOnLoadComplete;


  end;



implementation

{ TInterrupList }

procedure TInterruptsList.Add(Item: TInterrupt);
begin
  IntList.Add(Item);
end;

procedure TInterruptsList.Add(Info: String; Text: TStringList);
begin
  IntList.Add(TInterrupt.Create(Info,Text));
end;

constructor TInterruptsList.Create;
begin
  inherited Create;
  IntList := TList.Create;
end;

function TInterruptsList.GetCount: integer;
begin
  Result := IntList.Count;
end;

function TInterruptsList.GetItems(Index: integer): TInterrupt;
begin
  Result := TInterrupt(IntList.Items[Index]);
end;

function TInterruptsList.GetLast: integer;
begin
  Result := IntList.Count - 1;
end;

procedure TInterruptsList.LoadFromFile(FileName: String; var IntList: TInterruptsList; var ListBox: TListBox);
var
  Lines: String;
  _Info: String;
  FullInfo: String;
  Stop: Boolean;
begin
  AssignFile(InterruptFile,FileName);
  Reset(InterruptFile);
  if IoResult <> 0 then
    raise Exception.Create('File Open Error.');
  try
    ListBox.Items.BeginUpdate;

    while (StrLComp(PChar(Lines),INFO_CHAR,8) <> 0) and (not eof(InterruptFile)) do
    ReadLn(InterruptFile, Lines);
    
    while (not eof(InterruptFile)) and (not Stop) do begin
      if StrLComp(PChar(Lines),INFO_CHAR,8) = 0 then begin
        _Info := Lines;
        FullInfo := Lines;
        Lines := '';
        InterruptStrings := TStringList.Create;
        while (StrLComp(PChar(Lines),INFO_CHAR,8) <> 0) and (not eof(InterruptFile)) do begin
          ReadLn(InterruptFile, Lines);
          if (Copy(Lines,1,8) <> INFO_CHAR) then
            InterruptStrings.Add(Lines);
        end;
        _Info := Copy(_Info, END_CHAR_LEN, Pos(END_CHAR,_Info) - END_CHAR_LEN);
        while Length(_Info) < TAB_SIZE do _Info := _Info + ' ';
        IntList.Add(FullInfo,InterruptStrings);
        _Info := _Info + IntList.Items[IntList.Count - 1].Description;
        ListBox.Items.Add(_Info);
        if Assigned(FOnLoad) then FOnLoad(IntList.Count, Stop);
      end;
    end;
  finally
    CloseFile(InterruptFile);
    ListBox.Items.EndUpdate;
  end;
  if Assigned(FOnLoadComplete) then FOnLoadComplete;
end;


procedure TInterruptsList.SetItems(Index: integer; const Value: TInterrupt);
begin
  IntList.Items[Index] := Value;
end;

{ TInterrupt }
constructor TInterrupt.Create(_info: String; _Text: TStringList);
begin
  inherited Create;
  FFullInfo := _Info;
  FText := _Text;
end;

constructor TInterrupt.Create;
begin
  inherited Create;
end;

function TInterrupt.GetAllText: String;
var
  i: integer;
begin
  i := 0;
  Result := '';
  while (i < FText.Count) do begin
    Result := Result + FText.Strings[i] + #10#13;
    inc(i);
  end;    
end;

function TInterrupt.GetDescription: String;
begin
  Result := Copy(Text.Strings[0],Pos('-',Text.Strings[0]) + 2,Length(Text.Strings[0]));
end;

function TInterrupt.GetIntInfo: String;
begin
  Result := Copy(FullInfo,11,Pos('------------',FullInfo) - 11);
end;

procedure TInterrupt.SetFullInfo(const Value: String);
begin
  FFullInfo := Value;
end;

procedure TInterrupt.SetText(const Value: TStringList);
begin
  FText := Value;
end;

procedure TInterruptsList.SetOnLoad(const Value: TLoadEvent);
begin
  FOnLoad := Value;
end;

procedure TInterruptsList.SetOnLoadComplete(const Value: TLoadComplete);
begin
  FOnLoadComplete := Value;
end;


end.
