unit Encriptacao;

interface

uses
  SysUtils;

const
  kCh = 'jçljaçsfiajrlkwqeru43980487-12jk2j8789uçkfj987a9fu1k41';
  CHAVE: String = '2@/-1RTMP20F1II';

type
  TActionCrypto = (crEncriptar, crDecriptar);

function Crypt(aAcao: TActionCrypto; aFonte, aKey: string): string;

implementation

// Encriptação de strings
{$HINTS OFF}

function Crypt(aAcao: TActionCrypto; aFonte, aKey: string): string;
var
  Dest: string;
  Range: Integer;
  KeyLen: Integer;
  KeyPos: Integer;
  OffSet: Integer;
  SrcPos: Integer;
  SrcAsc: Integer;
  TmpSrcAsc: Integer;
begin
  Result := '';

  if (aFonte = '') then
    Exit;

  try
    Dest := '';
    KeyLen := Length(aKey);
    KeyPos := 0;
    SrcPos := 0;
    SrcAsc := 0;
    Range := 256;

    case aAcao of
      crEncriptar:
        begin
          Randomize;
          OffSet := Random(Range);
          Dest := Format('%1.2x', [OffSet]);

          for SrcPos := 1 to Length(aFonte) do
          begin
            SrcAsc := (Ord(aFonte[SrcPos]) + OffSet) mod 255;

            if KeyPos < KeyLen then
              KeyPos := KeyPos + 1
            else
              KeyPos := 1;

            SrcAsc := SrcAsc xor Ord(aKey[KeyPos]);
            Dest := Dest + Format('%1.2x', [SrcAsc]);
            OffSet := SrcAsc;
          end;
        end;

      crDecriptar:
        begin
          OffSet := StrToInt('$' + copy(aFonte, 1, 2));
          SrcPos := 3;

          repeat
            SrcAsc := StrToInt('$' + copy(aFonte, SrcPos, 2));

            if (KeyPos < KeyLen) then
              KeyPos := KeyPos + 1
            else
              KeyPos := 1;

            TmpSrcAsc := SrcAsc xor Ord(aKey[KeyPos]);

            if TmpSrcAsc <= OffSet then
              TmpSrcAsc := 255 + TmpSrcAsc - OffSet
            else
              TmpSrcAsc := TmpSrcAsc - OffSet;

            Dest := Dest + Chr(TmpSrcAsc);
            OffSet := SrcAsc;
            SrcPos := SrcPos + 2;

          until (SrcPos >= Length(aFonte));
        end;
    end;

    Result := Dest;
  except
  end;
end;
{$HINTS ON}

end.
