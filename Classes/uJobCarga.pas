unit uJobCarga;

interface

uses
  Vcl.Forms, System.Classes, System.SysUtils, JvThread, JvThreadDialog
, uDao, uSyncDAO;

Type
TJob = class
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

constructor TJob.Create(obj :TComponent);
begin
  thread := TJvThread.Create(obj);
  ThreadDialog := TJvThreadSimpleDialog.Create(obj);

  FdaoServer := TSyncDao.Create(FserverParam);
  FdaoPDV := TSyncDao.Create(FclientParam);
end;

constructor TJob.Create(obj: TComponent; ServerParams,
  ClientParams: TDadosAcesso; tables :TStrings);
begin
  FserverParam := ServerParams;
  FclientParam := ClientParams;

  Flist := TStringList.Create;
  Flist.AddStrings(tables);

  Self.Create(obj);
end;

destructor TJob.Destroy;
begin
  FreeAndNil(ThreadDialog);
  FreeAndNil(Thread);
  inherited;
end;

procedure TJob.Execute;
begin
    ThreadDialog.DialogOptions.ShowModal := True;
    ThreadDialog.DialogOptions.ShowDialog := True;
    ThreadDialog.DialogOptions.ShowProgressBar := True;
    ThreadDialog.DialogOptions.ShowElapsedTime := True;
    ThreadDialog.DialogOptions.ShowCancelButton := False;
    ThreadDialog.DialogOptions.FormStyle := fsNormal;

    Thread.Name := 'Thread';
    Thread.Exclusive := True;
    Thread.MaxCount := 0;
    Thread.RunOnCreate := True;
    Thread.FreeOnTerminate := True;
    Thread.ThreadDialog := ThreadDialog;
    Thread.OnExecute := OnThreadExecute;
    ThreadDialog.Name := 'ThreadDialog';
    Thread.ThreadDialog.DialogOptions.Assign(ThreadDialog.DialogOptions);
    ThreadDialog.ChangeThreadDialogOptions :=  ThreadDialogChangeThreadDialogOptions;
    ThreadDialog.DialogOptions.Caption := 'Sizing Thread Sample';
    Thread.ExecuteWithDialog(nil);
end;

procedure TJob.OnThreadExecute(Sender: TObject; Params: Pointer);
var
  i: Integer;
begin
  for i := 0 to FList.Count-1 do
  begin
    ThreadInfoProgressBarPosition := i;
    ThreadInfoText := Flist[i];

    //FdaoServer
    FdaoServer.SetReaderTableName(Flist[i]);
    FdaoPDV.SetWriterTableName(Flist[i]);
    FdaoPDV.ExecuteSync(FdaoServer.batReader, FdaoPDV.batWriter );

  end;

end;

procedure TJob.ThreadDialogChangeThreadDialogOptions(
  DialogOptions: TJvThreadBaseDialogOptions);
begin
  DialogOptions.InfoText := ThreadInfoText;
  if DialogOptions is TJvThreadSimpleDialogOptions then
    TJvThreadSimpleDialogOptions(DialogOptions).ProgressbarPosition := ThreadInfoProgressBarPosition;
end;

end.
