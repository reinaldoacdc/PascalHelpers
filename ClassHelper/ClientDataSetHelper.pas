unit ClientDataSetHelper;

interface

uses DbClient;

type TClientDataSetHelper = class helper for TClientDataSet
  procedure InitializeDataSet;
end;

implementation

{ TClientDataSetHelper }
procedure TClientDataSetHelper.InitializeDataSet;
begin
  if Self.Active then
    Self.EmptyDataSet
  else
    Self.CreateDataSet;
end;

end.
