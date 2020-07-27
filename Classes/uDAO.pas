unit uDAO;

interface

uses System.SysUtils, Firedac.Comp.Client;

type TDao = class(TObject)
private
  Fconnection :TFDConnection;

  procedure AbreBanco;
  procedure FechaBanco;  
protected

public
  constructor Create;
  destructor Destroy; override;
  
published

end;

implementation

  uses uConfigINI;

{ TDao }

procedure TDao.AbreBanco;
begin
  Fconnection.DriverName := 'FB';
  Fconnection.Params.Database := ConfigINI.AcessoBanco.PathDB;
  Fconnection.Params.UserName := ConfigINI.AcessoBanco.UserName;
  Fconnection.Params.Password := ConfigINI.AcessoBanco.Password;

  Fconnection.Connected := True;
end;

constructor TDao.Create;
begin
  Fconnection := TFDConnection.Create(nil);
  AbreBanco;
end;

destructor TDao.Destroy;
begin
  FechaBanco;
  FreeAndNil(Fconnection);
  inherited;
end;

procedure TDao.FechaBanco;
begin
  Fconnection.Connected := False;
end;

end.
