unit ApplicationHelper;

interface
uses Forms;

type
  TApplicationHelper = class helper for TApplication
    procedure OpenForm( frm :TForm; obj :TFormClass);
    procedure CloseAllForms;
    Function VersaoExe(Arquivo : String): String;
    procedure Log(text: String);
    //
    procedure RegistryInicialization;
    procedure UnregistryInicialization;
  end;

implementation

uses

{$IF COMPILERVERSION >= 22.0}
  WinApi.Windows, System.SysUtils, System.IOUtils, System.Win.Registry;
{$ELSE}
  Windows, SysUtils, IOUtils, Registry;
{$IFEND}



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

procedure TApplicationHelper.RegistryInicialization;
var
  Reg :TRegistry;
  filePath, fileName :string;
begin
  Reg := TRegistry.Create;
  filePath := ExtractFileDir(Application.ExeName)+'\'+ExtractFileName(Application.ExeName);
  fileName := TPath.GetFileNameWithoutExtension(Application.ExeName);
  Reg.rootkey:=HKEY_LOCAL_MACHINE;
  Reg.Openkey('SOFTWARE\MICROSOFT\WINDOWS\CURRENTVERSION\RUN',false);
  Reg.WriteString(fileName, filePath);
  Reg.closekey;
  Reg.Free;
  //Showmessage('Valor Gravado!');
end;

procedure TApplicationHelper.UnregistryInicialization;
var
  Reg :TRegistry;
  filePath, fileName :string;
begin
  Reg := TRegistry.Create;
  filePath :=ExtractFileDir(Application.ExeName)+'\'+ExtractFileName(Application.ExeName);
  fileName := TPath.GetFileNameWithoutExtension(Application.ExeName);
  Reg.rootkey:=HKEY_LOCAL_MACHINE;
  Reg.Openkey('SOFTWARE\MICROSOFT\WINDOWS\CURRENTVERSION\RUN',false);
  Reg.DeleteValue(fileName);
  Reg.closekey;
  Reg.Free;
  //Showmessage('Valor Excluido!');
end;

function TApplicationHelper.VersaoExe(Arquivo: String): String;
type
   PFFI = ^vs_FixedFileInfo;
var
   F : PFFI;
   Handle : Dword;
   Len : Longint;
   Data : Pchar;
   Buffer : Pointer;
   Tamanho : Dword;
   Parquivo: Pchar;
begin
   Parquivo := StrAlloc(Length(Arquivo) + 1);
   StrPcopy(Parquivo, Arquivo);
   Len := GetFileVersionInfoSize(Parquivo, Handle);
   Result := '';
   if Len > 0 then
   begin
      Data:=StrAlloc(Len+1);
      if GetFileVersionInfo(Parquivo,Handle,Len,Data) then
      begin
         VerQueryValue(Data, '\',Buffer,Tamanho);
            F := PFFI(Buffer);
            Result := Format('%d.%d.%d.%d',
            [HiWord(F^.dwFileVersionMs),
            LoWord(F^.dwFileVersionMs),
            HiWord(F^.dwFileVersionLs),
            Loword(F^.dwFileVersionLs)]
            );
      end;
      StrDispose(Data);
   end;
   StrDispose(Parquivo);
end;

end.