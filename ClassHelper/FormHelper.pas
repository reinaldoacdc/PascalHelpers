unit FormHelper;

interface

uses Forms;

type
  TFormHelper = class helper for TForm
  procedure ClearForm;
  end;

implementation

{ TFormHelper }

uses

{$IF COMPILERVERSION >= 22.0}
  Vcl.Mask, Vcl.StrCtrl;
{$ELSE}
  Mask, StdCtrls, ZDataSet;
{$IFEND}

procedure TFormHelper.ClearForm;
var
  i : Integer;
begin
  for i := 0 to Self.ComponentCount - 1 do
    if (Self.Components [i] is TMaskEdit) then
       (Self.Components [i] as TMaskEdit).Clear
    else if (Self.Components [i] is TCombobox) then
       (Self.Components [i] as TCombobox).ItemIndex := -1
    else if (Self.Components[i] is TCustomEdit) then
       (Self.Components [i] as TCustomEdit).Text := ''
    else if (Self.Components[i] is TMemo) then
       (Self.Components [i] as TMemo).Text := ''
    else if (Self.Components[i] is TCheckBox) then
       (Self.Components [i] as TCheckBox).Checked := False
    else if (Self.Components[i] is TZQuery) then
        (Self.Components[i] as TZQuery).EmptyDataSet;
end;

end.
