unit ApplicationHelper;

interface
uses Vcl.Forms;

type
  TApplicationHelper = class helper for TApplication
    procedure OpenForm( frm :TForm; obj :TFormClass);
    procedure CloseAllForms;
    procedure Log(text: String);
  end;

implementation

{ TApplicationHelper }
procedure TApplicationHelper.CloseAllForms;
var
  n : integer;
  Form : TForm;
begin
  // Fecha os forms criados no formulário principal
  n := 0;
  While n <= ( Application.MainForm.ComponentCount - 1 ) do
  Begin
    if ( Application.MainForm.Components[ n ] is TForm ) then
    Begin
      Form := TForm(Application.MainForm.Components[n]);
      If ( Form <> Application.MainForm ) then
      Begin
        N := -1;
        Form.Close;
        Form.Free;
      End;
    End;
    Inc(n);
  end;
end;

procedure TApplicationHelper.Log(text: String);
var
  NomeDoLog: string;
  Arquivo: TextFile;
begin
  NomeDoLog := ExtractFilePath(Application.ExeName)+'Log.txt';
  AssignFile(Arquivo, NomeDoLog);
  if FileExists(NomeDoLog) then
    Append(Arquivo)
  else
    ReWrite(Arquivo);
  try
    Writeln(arquivo, text);
  finally
    CloseFile(arquivo)
  end;
end;

procedure TApplicationHelper.OpenForm(frm: TForm; obj: TFormClass);
begin
  if frm = nil then
    frm := obj.Create(nil);
  frm.Show;
end;

end.