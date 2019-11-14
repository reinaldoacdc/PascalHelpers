unit untArquivoXLS;

interface

uses Classes, SysUtils, System;

type TColumns = array of String;

type TArquivoXLS = class
private

  Frowcount :Integer;
  Fcolumncount :Integer;
  Farquivo :variant;
  Fcolumns :TColumns;

  function getColumnCount :Integer;
  function getColumnsNames :TColumns;
  function getRowCount :Integer;

protected

public
  function getCell(column, line: Integer) :String;

  constructor Create(filename :String);
  destructor Destroy; override;

published
  property RowCount :Integer read Frowcount;
  property columnCount :Integer read Fcolumncount;
  property columns :TColumns read Fcolumns;
end;


implementation
uses Dialogs, ComObj, Variants;

{ TArquivoXLS }

constructor TArquivoXLS.Create(filename :String);
var
  I: Integer;
begin
   Farquivo := CreateOleObject('Excel.Application');
   Farquivo.Workbooks.open(filename);

   Frowcount := getRowCount;
   Fcolumncount := getColumnCount;
   Fcolumns := getColumnsNames;

   //Frowcount := Farquivo.WorkSheets[1].UsedRange[1].Rows.Count;
   //Fcolumncount := Farquivo.WorkSheets[1].UsedRange[1].Cols.Count;
end;

destructor TArquivoXLS.Destroy;
begin
  FArquivo.Quit;
  VarClear(FArquivo);
  inherited;
end;

function TArquivoXLS.getColumnCount: Integer;
var
  L :Integer;
  str :String;
begin
  L := 1;
  str := Farquivo.WorkSheets[1].Cells[1, L].Value;
  while (str <> '') do
  begin
    Inc(L);
    str := Farquivo.WorkSheets[1].Cells[1, L].Value;
  end;

  Result := L-1;
end;

function TArquivoXLS.getColumnsNames: TColumns;
var
  str :String;
  i, c :Integer;
begin
  c := Fcolumncount;
  SetLength(Result, c+1);

  for i := 1 to c  do
  begin
   str := Farquivo.WorkSheets[1].Cells[1, i].Value;
   Result[i] := str;
  end;
end;


function TArquivoXLS.getRowCount: Integer;
var
  L :Integer;
  str :String;
begin
  L := 1;
  str := Farquivo.WorkSheets[1].Cells[L, 1].Value;
  while (str <> '') do
  begin
    Inc(L);
    str := Farquivo.WorkSheets[1].Cells[L, 1].Value;
  end;

  Result := L-1;
end;

function TArquivoXLS.getCell(column, line: Integer) :String;
var
  linha :String;
begin
  linha := Farquivo.WorkSheets[1].Cells[line, column].Value;
  Result := linha;
end;

end.
