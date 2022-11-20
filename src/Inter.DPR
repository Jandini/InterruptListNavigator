program Inter;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {frmMain},
  ListUnit in 'ListUnit.pas',
  AboutUnit in 'AboutUnit.pas' {frmAbout},
  FindUnit in 'FindUnit.pas' {frmFind};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Interrupt List Navigator';
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmFind, frmFind);
  Application.Run;
end.
