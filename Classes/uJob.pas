unit uJob;

interface

uses Vcl.Forms, System.Classes, System.SysUtils, JvThread, JvThreadDialog;

Type
TJob = class
private
  Thread: TJvThread;
  ThreadDialog: TJvThreadSimpleDialog;
  ThreadInfoProgressBarPosition: Integer;
  ThreadInfoText: string;

  procedure ThreadDialogChangeThreadDialogOptions(DialogOptions: TJvThreadBaseDialogOptions);
  procedure OnThreadExecute(Sender: TObject; Params: Pointer);
protected

public
  procedure Execute;

  constructor Create(obj :TComponent);
  destructor Destroy; override;
published

end;

implementation

{ TJob }

constructor TJob.Create(obj :TComponent);
begin
  thread := TJvThread.Create(obj);
  ThreadDialog := TJvThreadSimpleDialog.Create(obj);
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
  for i := 0 to 20 do
  begin
    ThreadInfoProgressBarPosition := i;
    case i mod 5 of
      1 : ThreadInfoText := 'Das ist ein Test';
      2 : ThreadInfoText := 'ist ein Test';
      3 : ThreadInfoText := 'Das ist ein sehr sehr sehr langer Test der nicht zu umbrüchen führt';
      4 : ThreadInfoText := 'Das ist ein langer Test der nicht zu umbrüchen führt';
      5 : ThreadInfoText := 'Das ist ein langer Test der zu umbrüchen führt';
      else
        ThreadInfoText := 'Das ist ein anderer Test der auch zu lang wird und daher nicht passt';
    end;
    Sleep(1000);
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
