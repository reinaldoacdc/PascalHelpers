unit uDAO;

interface

uses System.SysUtils, Firedac.Comp.Client;

type TDadosAcesso = record
  Servidor :String;
  Caminho :String;
  Usuario :String;
  Senha :String;
end;

type TDao = class(TObject)
private

  Fparams :TDadosAcesso;
  Fquery :TFDQuery;

  procedure AbreBanco;
  procedure FechaBanco;  
protected
  Fconnection :TFDConnection;
public
  procedure CreateUser(username, password :String);
  procedure GrantPermission(objectName, userName :String);

  constructor Create; overload;
  constructor Create(params :TDadosAcesso); overload;
  destructor Destroy; override;
  
published

end;

implementation

  uses Variants, uConfigINI, Encriptacao;

{ TDao }

procedure TDao.AbreBanco;
begin
  Fconnection.DriverName := 'FB';
  Fconnection.Params.Values['Server'] := Fparams.Servidor;
  Fconnection.Params.Database := Fparams.Caminho;
  Fconnection.Params.UserName := Fparams.Usuario;
  Fconnection.Params.Password := Fparams.Senha; //Crypt(crDecriptar, Fparams.Senha, kCh);

  Fconnection.Connected := True;
end;

constructor TDao.Create;
begin
  if Self.Fparams.Caminho = '' then
  begin
    Fparams.Servidor :=  ConfigINI.AcessoBanco.Servidor;
    Fparams.Caminho  :=  ConfigINI.AcessoBanco.Caminho;
    Fparams.Usuario  :=  ConfigINI.AcessoBanco.Usuario;
    Fparams.Senha    :=  ConfigINI.AcessoBanco.Senha;
  end;
  

  Fconnection := TFDConnection.Create(nil);
  Fquery := TFDQuery.Create(nil);

  Fquery.Connection := Fconnection;
  AbreBanco;
end;

constructor TDao.Create(params: TDadosAcesso);
begin
  Fparams := params;
  Self.Create();
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
  Fquery.SQL.Text := Format('grant select, delete, insert, update on  %s  to %s ;',
                            [objectName, username]);
  Fquery.ExecSQL;
end;

end.
