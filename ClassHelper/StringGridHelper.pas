unit StringGridHelper;

interface
uses Vcl.Grids;

type
  TStringGridHelper = class helper for TStringGrid
    procedure Clear;
  end;

implementation

procedure TStringGridHelper.Clear;
var lin, col: integer;
begin
     for lin := 1 to Self.RowCount - 1 do
       for col := 0 to Self.ColCount - 1 do
         Self.Cells[col, lin] := '';
end;

end.