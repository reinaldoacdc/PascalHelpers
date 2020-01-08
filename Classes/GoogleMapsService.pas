unit GoogleMapsService;

interface

uses SysUtils, Classes;

type Tcoordinates = Record
  latitude :Double;
  longitude :Double;
End;

type TGoogleMapsService = class
private
  class function StripNonXml(s: string): string;
  class function ParseCoordinatesXML(xml :String) :TCoordinates;
  class function ParseDistancesXML(xml :String) :Double;
protected

public
  class function GetCoordinatesFromAddress(address, api_key :String) :Tcoordinates;
  class function GetAddressMapURL(address, api_key :String) :String;
  class function GetDistanceBetween(origem, destino, api_key :String) :Double;
  class function GetDirectionsMap(origem :String; destino :String; pontos :Array of String; api_key :String) :String;
  class function GetDirectionsShareLink(origem :String; destino :String; pontos :Array of String) :String;
published

end;


implementation

uses IdHTTP, IdSSLOpenSSL, IdURI,
     XmlDoc, XMLIntf,
     Character;
{ TGoogleMapsService }

class function TGoogleMapsService.GetAddressMapURL(address,
  api_key: String): String;
var
  HTMLCODE :String;
  IdURI :TIdURI;
  url, url_base, url_origin, url_key :String;
begin
  IdURI   := TIdURI.Create();

  url_base   := 'https://www.google.com/maps/embed/v1/place';
  url_origin := '?q=' + address;
  //url_key    := '&key=' + api_key;
  url_key    := '&' + api_key;

  url := IdURI.URLEncode(url_base + url_origin + url_key);

  HTMLCODE := '<iframe width="600" height="450" frameborder="0" style="border:0" '+
  ' src="'+ url +'" allowfullscreen></iframe>';

  Result := 'data:text/html,'+HTMLCODE;
end;

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
    //url_key := '&key=' + api_key;
    url_key := '&' + api_key;
    url := IdURI.UrlEncode(url_base + url_address + url_key);
    xml := UTF8Decode(IdHTTP1.Get(url));
    Result := ParseCoordinatesXML(xml);
  finally
    IdSSLIOHandlerSocket1.Free;
    IdHTTP1.Free;
  end;
end;

class function TGoogleMapsService.GetDirectionsMap(origem, destino: String;
  pontos: array of String; api_key :String): String;
var
  HTMLStr :AnsiString;
  html, js, initmap, calcDisplay :String;
  str :TStringlist;
  I :Integer;
begin
  str := TStringList.Create;

  str.Add('<div id="map" style="width: 600;height: 450;"></div> ');
  //str.Add(' <script async defer src="https://maps.googleapis.com/maps/api/js?key=' + api_key + '&callback=initMap"> ');
  str.Add(' <script async defer src="https://maps.googleapis.com/maps/api/js?' + api_key + '&callback=initMap"> ');
  str.Add(' </script> ');

  str.Add(' <script type="text/javascript"> ');
  str.Add(' window.onload = function(){initMap()}');


  str.Add(' function initMap() { ');
  str.Add(' var directionsService = new google.maps.DirectionsService; ');
  str.Add(' var directionsRenderer = new google.maps.DirectionsRenderer; ');
  str.Add('  var map = new google.maps.Map(document.getElementById(''map''), { ');
  str.Add('    zoom: 6 }); ');
  str.Add('  directionsRenderer.setMap(map); ');
  str.Add('  calculateAndDisplayRoute(directionsService, directionsRenderer); } ');

  str.Add('function calculateAndDisplayRoute(directionsService, directionsRenderer) { ');
  str.Add(' var waypts = []; ');
  str.Add(' var checkboxArray = document.getElementById(''waypoints''); ');

  if Length(pontos) > 0 then
  begin
    for I := 0 to Length(pontos)- 1 do
    begin
      str.Add(' waypts.push({ ');
      str.Add('   location: ' + QuotedStr(pontos[i]) + ', ');
      str.Add('   stopover: true ');
      str.Add(' }) ');
    end;
  end;


  str.Add(' directionsService.route({ ');
  str.Add('   origin: ' + QuotedStr(origem) + ', ');
  str.Add('   destination: ' + QuotedStr(destino) + ', ');
  str.Add( '   waypoints: waypts, ');
  str.Add('   optimizeWaypoints: true, ');
  str.Add( '   travelMode: ''DRIVING'' ');
  str.Add( ' }, function(response, status) { ');
  str.Add( '   if (status === ''OK'') { ');
  str.Add( '     directionsRenderer.setDirections(response); ');
  str.Add( '   } ');
  str.Add( ' }); } ');
  str.Add( ' </script> ');

  Result := str.text;
end;

class function TGoogleMapsService.GetDirectionsShareLink(origem,
  destino: String; pontos: array of String): String;
var
  IdURI :TIdURI;
  url, url_base :String;
begin
  IdURI   := TIdURI.Create();
  { TODO : add waypoints }
  url_base   := 'https://www.google.com/maps/dir/';
  url := IdURI.URLEncode(url_base + origem + '/' + destino);

  Result := url;
end;

class function TGoogleMapsService.GetDistanceBetween(origem, destino, api_key: String): Double;
var
  IdSSLIOHandlerSocket1 :TIdSSLIOHandlerSocketOpenSSL;
  IdHTTP1 :TIdHTTP;
  IdURI :TIdURI;
  xml, url, url_base, url_origem, url_destino, url_key :String;
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


    url_base    := 'https://maps.googleapis.com/maps/api/distancematrix/xml?';
    url_origem  := 'origins=' + origem;
    url_destino := '&destinations=' + destino;
    //url_key     := '&key=' + api_key;
    url_key     := '&' + api_key;
    url := IdURI.URLEncode(url_base + origem + url_destino + url_key);

    xml := UTF8Decode(IdHTTP1.Get(url));
    Result := ParseDistancesXML(xml);
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
  { TODO : Fix-me - Remove DecimalSeparator }
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
    DecimalSeparator := ',';
  end;
end;

class function TGoogleMapsService.ParseDistancesXML(xml: String): Double;
var
  XMLDocument1 :IXMLDocument;
  row, element, duration, distance, response :Ixmlnode;
  status :String;
begin
  { TODO : Fix-me - Remove DecimalSeparator }
  DecimalSeparator := '.';
  XMLDocument1 := TXMLDocument.Create(nil);
  try
    //Remove first tag
    Delete(xml, 1, pos('?>', xml)+2);
    XMLDocument1.LoadFromXML(StripNonXml(xml));
    response := XMLDocument1.DocumentElement.ChildNodes.FindNode('DistanceMatrixResponse') ;

    //
    status := response.ChildNodes['status'].Text;

    //
    row := response.ChildNodes.FindNode('row');
    element := row.ChildNodes.FindNode('element');

    //Duration
    duration := element.ChildNodes.FindNode('duration');

    //Distance
    distance := element.ChildNodes.FindNode('distance');

    Result := StrToFloat(distance.ChildNodes['value'].Text);
  finally
    XMLDocument1 := nil;
    DecimalSeparator := ',';
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
