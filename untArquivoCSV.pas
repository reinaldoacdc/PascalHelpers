unit untArquivoCSV;

interface

uses Classes, SysUtils;

type TColumns = array of String;

type TArquivoCSV = class
private
  Frowcount :Integer;
  Fcolumncount :Integer;
  Farquivo :TStringList;
  Fcolumns :TColumns;

  function getColumnCount :Integer;
  function getColumnsNames :TColumns;


protected

public
  function getCell(column, line: Integer) :String;

  constructor Create(filename :String);
  destructor Destroy; override;

published
  property rowcount :Integer read Frowcount;
  property columnCount :Integer read Fcolumncount;
  property columns :TColumns read Fcolumns;
end;


implementation
uses Dialogs;
{ TArquivoCSV }

constructor TArquivoCSV.Create(filename :String);
var
  I: Integer;
begin
   Farquivo := TStringList.Create;
   Farquivo.LoadFromFile(filename);

   Frowcount := Farquivo.Count;
   Fcolumncount := getColumnCount;
   Fcolumns := getColumnsNames;
end;

destructor TArquivoCSV.Destroy;
begin
  Farquivo.Free;
  inherited;
end;

function TArquivoCSV.getColumnCount: Integer;
var
  linha :String;
  i :Integer;
begin
  linha := Farquivo[0];

  i := 0;
  while Pos(';', linha) > 0 do
  begin
    linha := Copy(linha, Pos(';', linha)+1, Length(linha));
    Inc(i);
  end;
  Result := i;
end;

function TArquivoCSV.getColumnsNames: TColumns;
var
  linha, str :String;
  i :Integer;
begin
  SetLength(Result, Fcolumncount);

  linha := Farquivo[0];
  i := 0;
  while Pos(';', linha) > 0 do
  begin
    if i=0 then
    begin
      str := Copy(linha,0, Pos(';', linha)-1);
      linha := Copy(linha, Pos(';', linha)+1, Length(linha));
    end
    else
    begin
      str := Copy(linha,0, Pos(';', linha)-1);
      linha := Copy(linha, Pos(';', linha)+1, Length(linha));
    end;
    Result[i] := str;
    Inc(i);
  end;
end;


function TArquivoCSV.getCell(column, line: Integer) :String;
var
  linha :String;
  i: INteger;
begin
  linha := Farquivo[line];


  i := 0;
  while Pos(';', linha) > 0 do
  begin
    if i=column then
    begin
      Result := Copy(linha,0, Pos(';', linha)-1);
      Break;
    end;

    linha := Copy(linha, Pos(';', linha)+1, Length(linha));
    Inc(i);
  end;
end;

end.
