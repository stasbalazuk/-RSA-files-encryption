unit rsaunit;

interface

uses
  Forms,
  SysUtils,
  Classes,
  Math;

type
  Int = Cardinal;

  TInt = Int64;

  TBuf = array of Byte;

procedure Encrypt(var AFileIn, AFileOut: TFileStream; P, Q, E: TInt);
procedure Decrypt(var AFileIn, AFileOut: TFileStream; P, Q, E: TInt);
function GetD(Fi, E: TInt; var Eobr: TInt): TInt;

implementation

uses interfaceunit;

function DecToBin(AInt: TInt): string;
const
  mdArr: array [0..1] of Char = ('0', '1');
var
  DV: TInt;
  MD: TInt;
  ST: String;
begin
  DV := AInt;
  MD := 0;
  ST := '';
  Result := '';
  while (DV / 2 > 0) do
  begin
    MD := DV mod 2;
    DV := DV div 2;
    ST := Concat(mdArr[MD], ST);
  end;
  Result := ST;
end;

function PowMod(A, B, M: TInt): TInt;
var
  strB: string;
  I : Int;
  J : Int;
  L : Int;
  T : TInt;
begin
  Result := 1;
  strB := DecToBin(B);
  L := Length(strB);
  for I := 1 to L do
    if strB[i] = '1' then
    begin
      T := A;
      if I = L then
        T := A mod M
      else
        for J := 1 to L - I do
          T := (T * T) mod M;
      Result := (Result * T) mod M;
    end;
end;

function Pow(I: Int): TInt;
var
  K: Int;
begin
  Result := 256;
  if I = 0 then
    Result := 1
  else
    for K := 2 to I do
      Result := Result * 256;
end;

function GetBigInt(ABuf: TBuf): TInt;
var
  I: Int;
begin
  Result := 0;
  for I := Low(ABuf) to High(ABuf) do
    Result := Result + ABuf[I] * Pow(High(ABuf) - I);
end;

procedure FillStream1(A: TInt; ASize: Int; var AFileStream: TFileStream);
var
  I: Int;
  Octet: Byte;
begin
  AFileStream.Seek(0, soFromEnd);
  for I := ASize downto 1 do
  begin
    if I - 1 = 0 then
      Octet := A
    else
      Octet := A div Pow(I - 1);
    AFileStream.Write(Octet, SizeOf(Octet));
    A := A - Octet * Pow(I - 1);
  end;
end;

procedure Encrypt(var AFileIn, AFileOut: TFileStream; P, Q, E: TInt);
var
  I: Int;
  N: TInt;
  K: TInt;
  T: TInt;
  y: Integer;
  Buf: TBuf;
  Octet: Byte;
begin
  N := P * Q;
  if N <= 255 then
    Exit;
  K := trunc(LogN(256, N - 1));
  SetLength(Buf, 0);
  AFileIn.Seek(0, soFromBeginning);
  I := 0;
  y := 0;
  while AFileIn.Position <= AFileIn.Size - 1 do
  begin
    AFileIn.Read(Octet, SizeOf(Octet));
    SetLength(Buf, Length(Buf) + 1);
    Buf[High(Buf)] := Octet;
    Form1.Panel1.Caption:=IntToStr(AFileIn.Position)+' / '+IntToStr(AFileIn.Size)+' byte.';
    Form1.Gauge1.MaxValue:=AFileIn.Size;
    Form1.Gauge1.Progress:=AFileIn.Position+1;
    inc(I);
    inc(y);
    Application.ProcessMessages;
    if (I = K) or (AFileIn.Position = AFileIn.Size - 1) then
    begin
      if (AFileIn.Position = AFileIn.Size - 1) then
      begin
        AFileIn.Read(Octet, SizeOf(Octet));
        SetLength(Buf, Length(Buf) + 1);
        Buf[High(Buf)] := Octet;
      end;
      T := GetBigInt(Buf);
      T := PowMod(T, E, N);
      FillStream1(T, K + 1, AFileOut);
      I := 0;
      SetLength(Buf, 0);
    end;
  end;
end;

procedure swap(var n1,n2,n3: TInt);
begin
  n1 := n2;
  n2 := n3;
end;

function GetD(Fi, E: TInt; var Eobr: TInt): TInt;
var
  q: TInt;
  _e: TInt;
  r: array [1..3] of TInt;
  x: array [1..3] of TInt;
  y: array [1..3] of TInt;
begin
  _e := e;
  if (fi < e) then
  begin
    q := fi;
    fi := e;
    e := q;
  end;
  r[1] := fi;
  r[2] := e;
  x[1] := 1;
  x[2] := 0;
  y[1] := 0;
  y[2] := 1;
  while true do
  begin
    r[3] := r[1] mod r[2];
    q := r[1] div r[2];
    x[3] := x[1] - q * x[2];
    y[3] := y[1] - q * y[2];
    if (r[3] = 0) then
      Break;
    swap(r[1], r[2], r[3]);
    swap(x[1], x[2], x[3]);
    swap(y[1], y[2], y[3]);
  end;
  Result := r[2];
  if e = _e then
    Eobr := y[2]
  else
    Eobr := x[2];
end;

procedure Decrypt(var AFileIn, AFileOut: TFileStream; P, Q, E: TInt);
var
  N: TInt;
  K: TInt;
  D: TInt;
  T: TInt;
  I: Int;
  y: Integer;
  Buf: TBuf;
  Octet: Byte;
begin
  N := P * Q;
  if N <= 255 then
    Exit;
  K := trunc(LogN(256, N - 1)) + 1;
  GetD((P - 1) * (q - 1), E, D);
  SetLength(Buf, 0);
  AFileIn.Seek(0, soFromBeginning);
  I := 0;
  y := 0;
  Application.ProcessMessages;
  while AFileIn.Position <= AFileIn.Size - 1 do
  begin
    AFileIn.Read(Octet, SizeOf(Octet));
    SetLength(Buf, Length(Buf) + 1);
    Buf[High(Buf)] := Octet;
    Form1.Panel1.Caption:=IntToStr(AFileIn.Position)+' / '+IntToStr(AFileIn.Size)+' byte.';
    Form1.Gauge1.MaxValue:=AFileIn.Size;
    Form1.Gauge1.Progress:=AFileIn.Position+1;
    inc(I);
    inc(y);
    Application.ProcessMessages;
    if (I = K) or (AFileIn.Position = AFileIn.Size - 1) then
    begin
      if (AFileIn.Position = AFileIn.Size - 1) then
      begin
        AFileIn.Read(Octet, SizeOf(Octet));
        SetLength(Buf, Length(Buf) + 1);
        Buf[High(Buf)] := Octet;
      end;
      T := GetBigInt(Buf);
      T := PowMod(T, D, N);
      FillStream1(T, K - 1, AFileOut);
      I := 0;
      SetLength(Buf, 0);
    end;
  end;
end;

end.
