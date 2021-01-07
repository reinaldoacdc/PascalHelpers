unit uJobSincronismo;

interface

uses
  Vcl.Forms, System.Classes, System.SysUtils, JvThread, JvThreadDialog
, uDao, uSyncDAO;

Type
  TJobSync = class
private
  FserverParam :TDadosAcesso;
  FclientParam :TDadosAcesso;
  //
  Thread: TJvThread;
  ThreadDialog: TJvThreadSimpleDialog;
  ThreadInfoProgressBarPosition: Integer;
  ThreadInfoText: string;

  FdaoServer :TSyncDAO;
  FdaoPDV :TSyncDao;

  Flist :TStringList;

  procedure ThreadDialogChangeThreadDialogOptions(DialogOptions: TJvThreadBaseDialogOptions);
  procedure OnThreadExecute(Sender: TObject; Params: Pointer);
protected

public
  procedure Execute;

  constructor Create(obj :TComponent); overload;
  constructor Create(obj :TComponent; ServerParams, ClientParams :TDadosAcesso; tables :TStrings); overload;
  destructor Destroy; override;
published

end;

implementation

{ TJob }

constructor TJobSync.Create(obj :TComponent);
begin
  thread := TJvThread.Create(obj);
  ThreadDialog := TJvThreadSimpleDialog.Create(obj);

  FdaoServer := TSyncDao.Create(FserverParam);
  FdaoPDV := TSyncDao.Create(FclientParam);
end;

constructor TJobSync.Create(obj: TComponent; ServerParams,
  ClientParams: TDadosAcesso; tables :TStrings);
begin
  FserverParam := ServerParams;
  FclientParam := ClientParams;

  Flist := TStringList.Create;
  Flist.AddStrings(tables);

  Self.Create(obj);
end;

destructor TJobSync.Destroy;
begin
  FreeAndNil(ThreadDialog);
  FreeAndNil(Thread);
  inherited;
end;

procedure TJobSync.Execute;
begin
    //ThreadDialog.DialogOptions.ShowModal := True;
    //ThreadDialog.DialogOptions.ShowDialog := True;
    //ThreadDialog.DialogOptions.ShowProgressBar := True;
    //ThreadDialog.DialogOptions.ShowElapsedTime := True;
    //ThreadDialog.DialogOptions.ShowCancelButton := False;
    //ThreadDialog.DialogOptions.FormStyle := fsNormal;

    Thread.Name := 'Thread';
    Thread.Exclusive := True;
    Thread.MaxCount := 0;
    Thread.RunOnCreate := True;
    Thread.FreeOnTerminate := True;
    Thread.ThreadDialog := ThreadDialog;
    Thread.OnExecute := OnThreadExecute;
    ThreadDialog.Name := 'ThreadDialog';
    //Thread.ThreadDialog.DialogOptions.Assign(ThreadDialog.DialogOptions);
    //ThreadDialog.ChangeThreadDialogOptions :=  ThreadDialogChangeThreadDialogOptions;
    ThreadDialog.DialogOptions.Caption := 'Sizing Thread Sample';
    Thread.Execute(nil);
end;


procedure TJobSync.OnThreadExecute(Sender: TObject; Params: Pointer);
var
  i: Integer;
begin
  FdaoServer.QuerySync.Open;
  FdaoServer.QuerySync.First;

  for i := 0 to FdaoServer.QuerySync.RecordCount-1 do
  begin
    ThreadInfoProgressBarPosition := i;
    ThreadInfoText := FdaoServer.QuerySync.FieldByName('TABELA').AsString;

    //FdaoServer
    FdaoServer.SetReaderSQL(Format('SELECT * FROM %s where CODIGO = %d'
                           ,[FdaoServer.QuerySync.FieldByName('TABELA').AsString
                           , FdaoServer.QuerySync.FieldByName('PK1').AsInteger]));
    FdaoPDV.SetWriterTableName(FdaoServer.QuerySync.FieldByName('TABELA').AsString);
    FdaoPDV.ExecuteSync(FdaoServer.batReader, FdaoPDV.batWriter );

    FdaoServer.QuerySync.Next;
  end;
end;

procedure TJobSync.ThreadDialogChangeThreadDialogOptions(
  DialogOptions: TJvThreadBaseDialogOptions);
begin
  DialogOptions.InfoText := ThreadInfoText;
  if DialogOptions is TJvThreadSimpleDialogOptions then
    TJvThreadSimpleDialogOptions(DialogOptions).ProgressbarPosition := ThreadInfoProgressBarPosition;
end;

end.
