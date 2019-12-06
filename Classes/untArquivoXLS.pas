unit untArquivoXLS;

interface

uses Classes, SysUtils;

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
  procedure SaveFile(lines :TStringList; path :String);

  constructor Create(filename :String);
  destructor Destroy; override;

published
  property RowCount :Integer read Frowcount;
  property columnCount :Integer read Fcolumncount;
  property columns :TColumns read Fcolumns;
end;


implementation
uses Dialogs, ComObj, Variants, Windows;

{ TArquivoXLS }
function Split(Expression:string; Delimiter:string):TColumns;
var
  Res:        TColumns;
  ResCount:   DWORD;
  dLength:    DWORD;
  StartIndex: DWORD;
  sTemp:      string;
begin
  dLength := Length(Expression);
  StartIndex := 1;
  ResCount := 0;
  repeat
    sTemp := Copy(Expression, StartIndex, Pos(Delimiter, Copy(Expression, StartIndex, Length(Expression))) - 1);
    SetLength(Res, Length(Res) + 1);
    SetLength(Res[ResCount], Length(sTemp));
    Res[ResCount] := sTemp;
    StartIndex := StartIndex + Length(sTemp) + Length(Delimiter);
    ResCount := ResCount + 1;
  until StartIndex > dLength;
  Result := Res;
end;

constructor TArquivoXLS.Create(filename :String);
var
  I: Integer;
begin
   Farquivo := CreateOleObject('Excel.Application');

   if filename <> '' then
   begin
     Farquivo.Workbooks.open(filename);
     Frowcount := getRowCount;
     Fcolumncount := getColumnCount;
     Fcolumns := getColumnsNames;
   end;

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

procedure TArquivoXLS.SaveFile(lines: TStringList; path :String);
var
  I, C: Integer;
  fields :TColumns;
begin
  Farquivo.WorkBooks.Add(1);
  for I := 1 to lines.count -1 do
  begin
    fields := Split( lines[i], ';' );

    for C := 1 to Length(fields) do
    begin
      Farquivo.WorkSheets[1].Cells[I, C] := lines[i];
    end;
  end;
  Farquivo.ActiveWorkBook.Saveas(path);
end;

function TArquivoXLS.getCell(column, line: Integer) :String;
var
  linha :String;
begin
  linha := Farquivo.WorkSheets[1].Cells[line, column].Value;
  Result := linha;
end;

end.
