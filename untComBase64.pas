unit untComBase64;
 
// Version Unicode by gta126
 
interface
 
uses SysUtils;
 
function encode64(s: string): string;
function decode64(s: string): string;
 
implementation
 
const
  tabChar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
 
function encode64(s: string): string;
var
  i       : Integer; // compteur
  charCode: Integer; // code du caractère dans la table Unicode
  valToDec: Integer; // valeur à décrémenter au fur à mesure de la conversion
  nbrBits : Integer; // nombre de bits actuellement dans vaToDec (maximum 16 + 4)
  charPos : Integer; // position dans le tableau de codage en base64
begin
  Result   := '';
  charCode := 0;
  nbrBits  := 0;
  valToDec := 0;
 
  //parcours des caractères
  for i := 1 to Length(s) do
  begin
    charCode := Ord(s[i]);
    nbrBits  := nbrBits + 16;
    valToDec := (valToDec shl 16) + charCode;
 
    // traiter les bits tant que l'on sais faire des groupements de 6
    while (nbrBits - 6) >= 0 do
    begin
      nbrBits  := nbrBits - 6;
      charPos  := valToDec shr nbrBits;
      valToDec := valToDec - (charPos shl nbrBits);
      Result   := Result + tabChar[charPos + 1];
    end;
  end;
 
  // gestion des desniers bits + ajout des compléments
  if nbrBits > 0 then
  begin
    charPos := valToDec shl (6 - nbrBits);
    Result  := Result + tabChar[charPos + 1];
 
    for i := 1 to (6 - nbrBits) div 2 do
      Result := Result + '=';
  end;
end;
 
function decode64(s: string): string;
var
  i       : Integer; // compteur
  charPos : Integer; // position dans le tableau de codage en base64
  valToDec: Integer; // valeur à décrémenter au fur à mesure de la conversion
  nbrBits : Integer; // nombre de bits actuellement dans vaToDec (maximum 14 + 6)
  charCode: Integer; // code du caractère dans la table Unicode
  quitLoop: Boolean; // quitter la boucle oui / non
begin
  Result   := '';
  nbrBits  := 0;
  valToDec := 0;
  quitLoop := False;
 
  // parcours des caractères
  for i := 1 to Length(s) do
  begin
    charPos  := Pos(s[i], tabChar) - 1;
    nbrBits  := nbrBits + 6;
    valToDec := (valToDec shl 6) + charPos;
 
    // cas des derniers bits trop long ( signe = )
    if (i + 1 <= Length(s)) and (s[i+1] = '=') then
    begin
      valToDec := valToDec shr 2;
      nbrBits := nbrBits - 2;
 
      if (i + 2 <= Length(s)) and (s[i+2] = '=') then
      begin
        valToDec := valToDec shr 2;
        nbrBits := nbrBits - 2;
      end;
 
      quitLoop := True;
    end;
 
    // traitement des bits dès qu'un groupe de 16 est possible
    if (nbrBits - 16) >= 0 then
    begin
      nbrBits  := nbrBits - 16;
      charCode := valToDec shr nbrBits;
      valToDec := valToDec - (charCode shl nbrBits);
      Result   := Result + Char(charCode);
    end;
 
    // quitter la boucle en ignorant les autres caractères ( ignorer les = )
    if quitLoop then
      Break;
  end;
 
  // vérification
  if nbrBits > 0 then
    Result:= '';
end;
 
end.