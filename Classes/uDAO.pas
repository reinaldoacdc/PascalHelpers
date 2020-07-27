unit uDAO;

interface

uses System.SysUtils, Firedac.Comp.Client;

type TDao = class(TObject)
private
  Fconnection :TFDConnection;
  Fquery :TFDQuery;

  procedure AbreBanco;
  procedure FechaBanco;  
protected

public
  procedure CreateUser(username, password :String);
  procedure GrantPermission(objectName, userName :String);

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
  Fquery := TFDQuery.Create(nil);

  Fquery.Connection := Fconnection;
  AbreBanco;
end;

procedure TDao.CreateUser(username, password: String);
begin
  Fquery.SQL.Text := Format('CREATE USER %s password ''%s'' ;',
                            [username, password]);
  Fquery.ExecSQL;
end;

destructor TDao.Destroy;
begin
  FechaBanco;
  FreeAndNil(Fquery);
  FreeAndNil(Fconnection);
  inherited;
end;

procedure TDao.FechaBanco;
begin
  Fconnection.Connected := False;
end;

procedure TDao.GrantPermission(objectName, userName: String);
begin

end;

end.
