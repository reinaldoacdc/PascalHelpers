unit StringHelper;

interface

type TStringHelper = record helper for String
  function OnlyNumbers :String;
end;

implementation

{ TStringHelper }

function TStringHelper.OnlyNumbers: String;
var i :Integer;
begin
  Result := '' ;
  for i := 1 to length( Self ) do
  begin
      if Self[ i ] in ['0'..'9'] then
      Result := Result + Self[ i ] ;
  end ;
end;

end.
