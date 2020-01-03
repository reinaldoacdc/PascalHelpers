unit JsonObjectHelper;

interface

uses DBXJSON, Character;

type  TJsonObjectHelper = class helper for TJsonObject
  public
    //Helper to find a JSON pair based on the pair string part
    function Get(const PairName: UnicodeString): TJSONPair; overload;
  end;

implementation

{ TJsonObjectHelper }

function TJsonObjectHelper.Get(const PairName: UnicodeString): TJSONPair;
var
  Candidate: TJSONPair;
  I: Integer;
begin
  for i := 0 to Size - 1 do
  begin
    Candidate := Get(i);
    if (Candidate.JsonString.Value = PairName) then
      Exit(Candidate);
  end;
  Result := nil;
end;

end.
