
unit uXlsWriter;

interface

uses
  Classes, Sysutils, Variants,
  ZDataset;

type
  TCnXlsWriter = class(TObject)
  private
    FStream: TMemoryStream;
    procedure SetCells(const ACol: Byte; const ARow: Word; const Value: Variant);
  protected
    procedure XlsBeginStream(XlsStream: TStream; const BuildNumber: Word);
    procedure XlsEndStream(XlsStream: TStream);
    procedure XlsWriteCellRk(XlsStream: TStream; const ACol: Byte; const ARow: Word;
      const AValue: Integer);
    procedure XlsWriteCellNumber(XlsStream: TStream; const ACol: Byte; const ARow: Word;
      const AValue: Double);
    procedure XlsWriteCellLabel(XlsStream: TStream; const ACol: Byte; const ARow: Word;
      const AValue: AnsiString);
    procedure XlsWriteCellBlank(XlsStream: TStream; const ACol: Byte; const ARow: Word);
  public
    constructor Create;
    destructor  Destroy; override;

    procedure   NewXls;
    procedure   SaveToXls(const FileName: string);
    property    Cells[const ACol: Byte; const ARow: Word]: Variant write SetCells;
    procedure parseQuery(qry :TZQuery);
  end;

implementation

var
  CXlsBof: array[0..5] of Word = ($809, 8, 00, $10, 0, 0);
  CXlsEof: array[0..1] of Word = ($0A, 00);
  CXlsLabel: array[0..5] of Word = ($204, 0, 0, 0, 0, 0);
  CXlsNumber: array[0..4] of Word = ($203, 14, 0, 0, 0);
  CXlsRk: array[0..4] of Word = ($27E, 10, 0, 0, 0);
  CXlsBlank: array[0..4] of Word = ($201, 6, 0, 0, $17);

procedure TCnXlsWriter.XlsBeginStream(XlsStream: TStream; const BuildNumber: Word);
begin
  CXlsBof[4] := BuildNumber;
  XlsStream.WriteBuffer(CXlsBof, SizeOf(CXlsBof));
end;

procedure TCnXlsWriter.XlsEndStream(XlsStream: TStream);
begin
  XlsStream.WriteBuffer(CXlsEof, SizeOf(CXlsEof));
end;

procedure TCnXlsWriter.XlsWriteCellRk(XlsStream: TStream; const ACol: Byte; const ARow: Word;
  const AValue: Integer);
var
  V: Integer;
begin
  CXlsRk[2] := ARow;
  CXlsRk[3] := ACol;
  XlsStream.WriteBuffer(CXlsRk, SizeOf(CXlsRk));
  V := (AValue shl 2) or 2;
  XlsStream.WriteBuffer(V, 4);
end;

procedure TCnXlsWriter.XlsWriteCellNumber(XlsStream: TStream; const ACol: Byte; const ARow: Word;
  const AValue: Double);
begin
  CXlsNumber[2] := ARow;
  CXlsNumber[3] := ACol;
  XlsStream.WriteBuffer(CXlsNumber, SizeOf(CXlsNumber));
  XlsStream.WriteBuffer(AValue, 8);
end;

procedure TCnXlsWriter.XlsWriteCellLabel(XlsStream: TStream; const ACol: Byte; const ARow: Word;
  const AValue: AnsiString);
var
  L: Word;
begin
  L := Length(AValue);
  CXlsLabel[1] := 8 + L;
  CXlsLabel[2] := ARow;
  CXlsLabel[3] := ACol;
  CXlsLabel[5] := L;
  XlsStream.WriteBuffer(CXlsLabel, SizeOf(CXlsLabel));
  XlsStream.WriteBuffer(Pointer(AValue)^, L);
end;


procedure TCnXlsWriter.XlsWriteCellBlank(XlsStream: TStream; const ACol: Byte;
const ARow: Word);
begin
  CXlsBlank[2] := ARow;
  CXlsBlank[3] := ACol;
  XlsStream.WriteBuffer(CXlsBlank, SizeOf(CXlsBlank));
end;

constructor TCnXlsWriter.Create;
begin
  inherited Create;
  FStream := TMemoryStream.Create;
  NewXls;
end;

destructor TCnXlsWriter.Destroy;
begin
  FreeAndNil(FStream);
  inherited Destroy;
end;

procedure TCnXlsWriter.SaveToXls(const FileName: string);
var
  ExcelApp: Variant;
  ExcelWork: Variant;
  TargetFileName: string;
begin
  if Trim(FileName) = '' then
    Exit;
  XlsEndStream(FStream);
  FStream.SaveToFile(FileName);
end;

procedure TCnXlsWriter.NewXls;
begin
  FStream.Size := 0;
  XlsBeginStream(FStream, 0);
end;

procedure TCnXlsWriter.parseQuery(qry: TZQuery);
var I, J :Integer;
begin
  //ColumnNames
  for I := 0 to qry.Fields.Count - 1 do
    Self.Cells[I, 0] := qry.Fields[i].name;

  //DataRows
  qry.First;
  for i := 1 to qry.RecordCount do
  begin
    for j := 0 to qry.FieldCount - 1 do
     Self.Cells[j, i] := qry.Fields[j].Value;
    qry.Next;
  end;
  FStream.WriteBuffer(CXlsEof, SizeOf(CXlsEof));

end;

procedure TCnXlsWriter.SetCells(const ACol: Byte; const ARow: Word; const Value: Variant);
var
  aStr: string;
  aInt: Integer;
  aFloat: Double;
  aCode: Integer;
{$IFDEF UNICODE}
  aUStr: string;
{$ENDIF}
begin
  case VarType(Value) of
    varSmallint, varInteger, varByte:
      XlsWriteCellRk(FStream, ACol, ARow, Value);
    varSingle, varDouble, varCurrency:
      XlsWriteCellNumber(FStream, ACol, ARow, Value);
    varString, varOleStr:
      begin
        aStr := VarToStr(Value);
        Val(aStr, aInt, aCode);
        if aCode = 0 then
        begin
          XlsWriteCellLabel(FStream, ACol, ARow, AnsiString('''' + aStr));
          Exit;
        end;
        Val(aStr, aFloat, aCode);
        if aCode = 0 then
        begin
          XlsWriteCellLabel(FStream, ACol, ARow, AnsiString('''' + aStr));
          Exit;
        end;

        XlsWriteCellLabel(FStream, ACol, ARow, AnsiString(VarToStr(Value)));
      end;
{$IFDEF UNICODE}
    varUString:
      begin
        aUStr := VarToWideStr(Value);
        aStr := WideCharToString(PWideChar(aUStr));
        XlsWriteCellLabel(FStream, ACol, ARow, AnsiString(aStr));
      end;
{$ENDIF}
    varDate:
      XlsWriteCellLabel(FStream, ACol, ARow, AnsiString(DateTimeToStr(Value)));
  else
    XlsWriteCellBlank(FStream, ACol, ARow);
  end;
end;

end.
