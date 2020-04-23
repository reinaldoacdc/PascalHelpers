unit untArquivoXLSX;

interface

uses Classes, SysUtils, ZDataSet, Grids;

type TColumns = array of String;

type TArquivoXLS = class
private
  //
  FStream: TFileStream;
  procedure WriteCell(XlsStream: TStream; const ACol, ARow: Word; const AValue: string);
protected

public
  //
  procedure SaveStringGrid(AGrid: TStringGrid; AFileName: string);
  procedure SaveQuery(qry :TZQuery);

  constructor Create(filename :String);
  destructor Destroy; override;
end;


implementation

constructor TArquivoXLS.Create(filename :String);
begin
   FStream := TFileStream.Create(PChar(fileName), fmCreate or fmOpenWrite);
end;

destructor TArquivoXLS.Destroy;
begin
  FStream.Free;
  inherited;
end;

procedure TArquivoXLS.SaveQuery(qry: TZQuery);
const
  {$J+} CXlsBof: array[0..5] of Word = ($809, 8, 00, $10, 0, 0); {$J-}
  CXlsEof: array[0..1] of Word = ($0A, 00);
var
  I, J: Integer;
begin

    CXlsBof[4] := 0;
    FStream.WriteBuffer(CXlsBof, SizeOf(CXlsBof));
    qry.First;
    for i := 0 to qry.RecordCount - 1 do
    begin
      for j := 0 to qry.FieldCount - 1 do
       WriteCell(FStream, J, I,   qry.Fields[j].Value);
      qry.Next;
    end;
    FStream.WriteBuffer(CXlsEof, SizeOf(CXlsEof));
end;

procedure TArquivoXLS.SaveStringGrid(AGrid: TStringGrid; AFileName: string);
const
  {$J+} CXlsBof: array[0..5] of Word = ($809, 8, 00, $10, 0, 0); {$J-}
  CXlsEof: array[0..1] of Word = ($0A, 00);
var
  I, J: Integer;
begin
    CXlsBof[4] := 0;
    FStream.WriteBuffer(CXlsBof, SizeOf(CXlsBof));
    for i := 0 to AGrid.ColCount - 1 do
      for j := 0 to AGrid.RowCount - 1 do
        WriteCell(FStream, I, J, AGrid.cells[i, j]+ '          ' );
    FStream.WriteBuffer(CXlsEof, SizeOf(CXlsEof));
end;

procedure TArquivoXLS.WriteCell(XlsStream: TStream; const ACol, ARow: Word; const AValue: string);
var
  L: Word;
const
  {$J+}
  CXlsLabel: array[0..5] of Word = ($204, 0, 0, 0, 0, 0);
  {$J-}
begin
  L := Length(AValue);
  CXlsLabel[1] := 8 + L;
  CXlsLabel[2] := ARow;
  CXlsLabel[3] := ACol;
  CXlsLabel[5] := L;
  XlsStream.WriteBuffer(CXlsLabel, SizeOf(CXlsLabel));
  XlsStream.WriteBuffer(Pointer(AValue)^, L);
end;

end.
