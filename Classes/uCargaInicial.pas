unit uCargaInicial;

interface

procedure OnCargaInicialExecute(Sender: TObject; Params: Pointer);

implementation

uses System.Classes, System.SysUtils, Vcl.Dialogs,
     uCOnfigINI, uDtmPrincipal, uPrincipal, uTerminal;

procedure OnCargaInicialExecute(Sender: TObject; Params: Pointer);
var
  list :TStringList;
  I: Integer;
  term :Terminal;
begin

  term.IP := dtmPrincipal.tbPDVSIP.AsString;
  term.Nome := dtmPrincipal.tbPDVSNOME.AsString;
  term.Caminho := dtmPrincipal.tbPDVSCAMINHO.AsString;
  term.Nome := dtmPrincipal.tbPDVSNOME.AsString;

  try
    dtmPrincipal.ConectarPDV(term, False);

    //dao.CreateUser
  list := TStringList.Create;
  list.Add('TBEMPRESA');
  list.Add('TBREPRESENTANTE');
  list.Add('TBCARTAO');

  list.Add('TBPLANOCONTAS');
  list.Add('TBCENTROCUSTO');
  list.Add('TBFINALIZADORA');

  list.Add('TBDEPARTAMENTO');
  list.Add('TBSECAO');
  list.Add('TBUNIDADE');
  list.Add('TBPARCELAMENTO');

  list.Add('TBTIPOTRIBUTACAO');
  list.Add('TBPRODUTO');
  list.Add('TBPRODUTO_MULTI');
  list.Add('TBEAN');
  list.Add('TB_PRODUTO_KIT');
  list.Add('TBPROMOCAO');
  list.Add('TBPROMOCAO_ITEM');

  list.Add('TB_NFELETRONICA_CFG');

  list.Add('USUARIOS');
  if ConfigINI.Opcoes.UsuarioControle then
    list.Add('USUARIOS_CONTROLES');

  if ConfigINI.Opcoes.UsiarioPermissao then
    list.Add('USUARIOS_PERMISSOES');

    dtmPrincipal.ConectarPDV(term);

    frmprincipal.ThreadInfoText := 'Inicializando';


    for I := 0 to list.count-1 do
    begin
      frmprincipal.ThreadInfoText := 'Carga Tabela: ' + list[i];
      frmprincipal.ThreadInfoProgressBarPosition := i;

      dtmPrincipal.batchReader.TableName := list[i];
      dtmPrincipal.batchWriter.TableName := list[i];
      dtmPrincipal.batchMove.Execute;
    end;

    AtualizarPDV( dtmPrincipal.tbPDVSCODIGO.AsInteger  , Now, Now);
    frmprincipal.threadCargaInicial.Terminate;
  except on E :Exception do
    begin
      frmprincipal.threadCargaInicial.Terminate;
      ShowMessage('Houve um erro ao executar a Carga Inicial: ' + E.Message);
    end;
  end;

end;

end.
