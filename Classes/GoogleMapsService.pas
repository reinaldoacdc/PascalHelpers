unit GoogleMapsService;

interface

uses SysUtils;

type Tcoordinates = Record
  latitude :Double;
  longitude :Double;
End;

type TGoogleMapsService = class
private
  class function StripNonXml(s: string): string;
  class function ParseCoordinatesXML(xml :String) :TCoordinates;
protected

public
  class function GetCoordinatesFromAddress(address, api_key :String) :Tcoordinates;
published

end;


implementation

uses IdHTTP, IdSSLOpenSSL, IdURI,
     XmlDoc, XMLIntf,
     Character;
{ TGoogleMapsService }

class function TGoogleMapsService.GetCoordinatesFromAddress(address, api_key :String): Tcoordinates;
var
  IdSSLIOHandlerSocket1 :TIdSSLIOHandlerSocketOpenSSL;
  IdHTTP1 :TIdHTTP;
  IdURI :TIdURI;
  url, url_base, url_address, url_key, xml :String;
begin
  IdSSLIOHandlerSocket1 := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  IdHTTP1 := TIdHTTP.Create(nil);
  IdURI   := TIdURI.Create();

  try
    IdSSLIOHandlerSocket1.SSLOptions.Method := sslvTLSv1;
    IdSSLIOHandlerSocket1.SSLOptions.Mode   := sslmUnassigned;
    IdHTTP1.IOHandler := IdSSLIOHandlerSocket1;


    IdHTTP1.Request.Accept := 'text/html, */*';
    IdHTTP1.Request.UserAgent := 'Mozilla/3.0 (compatible; IndyLibrary)';
    IdHTTP1.Request.ContentType := 'application/x-www-form-urlencoded';
    IdHTTP1.HandleRedirects := True;

    url_base := 'https://maps.google.com/maps/api/geocode/xml?sensor=false';
    url_address := '&address=' + address;
    url_key := '&key=' + api_key;
    url := IdURI.UrlEncode(url_base + url_address + url_key);
    xml := UTF8Decode(IdHTTP1.Get(url));
    Result := ParseCoordinatesXML(xml);
  finally
    IdSSLIOHandlerSocket1.Free;
    IdHTTP1.Free;
  end;
end;

class function TGoogleMapsService.ParseCoordinatesXML(xml: String): TCoordinates;
var
  XMLDocument1 :IXMLDocument;
  geometry, location, results :Ixmlnode;
  lat, lng :String;
begin
  DecimalSeparator := '.';
  XMLDocument1 := TXMLDocument.Create(nil);
  try
    //Remove first tag
    Delete(xml, 1, pos('?>', xml)+2);
    XMLDocument1.LoadFromXML(StripNonXml(xml));
    results := XMLDocument1.DocumentElement.ChildNodes.FindNode('result') ;
    geometry := results.ChildNodes.FindNode('geometry') ;
    location := geometry.ChildNodes.FindNode('location');


    Result.latitude  := StrToFloat(location.ChildNodes['lat'].Text);
    Result.longitude := StrToFloat(location.ChildNodes['lng'].Text);
  finally
    XMLDocument1 := nil;
  end;
end;

class function TGoogleMapsService.StripNonXml(s: string): string;
var
  ch: char;
  inString: boolean;
begin
  Result := '';
  inString := false;
  for ch in s do
  begin
    if ch = '"' then
      inString := not inString;
    if TCharacter.IsWhiteSpace(ch) and not inString then
      continue;
    Result := Result + ch;
  end;
end;

end.
