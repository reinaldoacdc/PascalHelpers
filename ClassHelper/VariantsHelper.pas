unit VariantsHelper;

interface

function VarToIntDef(const V: Variant; const ADefault: Integer): Integer;

implementation

uses Variants;

function VarToIntDef(const V: Variant; const ADefault: Integer): Integer;
begin
  if not VarIsNull(V) then
    Result := V
  else
    Result := ADefault;
end;

end.
