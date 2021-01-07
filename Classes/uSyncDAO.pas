unit uSyncDAO;

interface
uses uDao
   , FireDAC.Comp.Client
   , FireDAC.Comp.BatchMove, FireDAC.Comp.BatchMove.SQL;

type
  TSyncDAO = class(TDao)
    private

      Fparams :TDadosAcesso;
      FbatReader: TFDBatchMoveSQLReader;
      FbatWriter :TFDBatchMoveSQLWriter;
      FbatMove :TFDBatchMove;
    public
      QuerySync :TFDQuery;

      constructor Create(params :TDadosAcesso);

      procedure SetReaderTableName(table :String);
      procedure SetWriterTableName(table :String);

      procedure SetReaderSQL(sql :String);

      procedure ExecuteSync(batReader :TFDBatchMoveSQLReader; batWriter :TFDBatchMoveSQLWriter);
    published
      property batReader :TFDBatchMoveSQLReader read FbatReader;
      property batWriter :TFDBatchMoveSQLWriter read FbatWriter;
  end;




implementation

{ TSyncDAO }

constructor TSyncDAO.Create(params: TDadosAcesso);
begin
  Fparams := params;
  inherited;

   FbatReader := TFDBatchMoveSQLReader.Create(nil);
   FbatReader.Connection := Self.Fconnection;

   FbatWriter := TFDBatchMoveSQLWriter.Create(nil);
   FbatWriter.Connection := Self.Fconnection;

   FbatMove   := TFDBatchMove.Create(nil);
   FbatMove.Reader := FbatReader;
   FbatMove.Writer := FbatWriter;

   QuerySync := TFDQuery.Create(nil);
   QuerySync.SQL.Text := 'SELECT * FROM SINCRONISMO WHERE STATUS = ''N'' ';
   QuerySync.Connection := Self.Fconnection;
end;

procedure TSyncDAO.ExecuteSync(batReader :TFDBatchMoveSQLReader; batWriter :TFDBatchMoveSQLWriter);
begin
  batWriter.GeneratorName := 'NEW_GENERATOR';

  Self.FbatMove.Reader := batReader;
  Self.FbatMove.Writer := batWriter;

  Self.FbatMove.Mode := dmAppendUpdate;
  Self.FbatMove.Execute;
end;

procedure TSyncDAO.SetReaderSQL(sql: String);
begin
  Self.batReader.ReadSQL := sql;
end;

procedure TSyncDAO.SetReaderTableName(table: String);
begin
  Self.FbatReader.TableName := table;
end;

procedure TSyncDAO.SetWriterTableName(table: String);
begin
  Self.FbatWriter.TableName := table;
end;

end.
