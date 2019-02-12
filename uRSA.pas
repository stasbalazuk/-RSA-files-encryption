unit uRSA;

interface

uses
Windows, SysUtils, uBigIntsV4, Math;

type
TByteArray = Array of Byte;

TKeyInt = TInteger;

TKeyObj = class(TObject)
ID: String;
{Keep all four the following four values for debugging}
{The public key is the pair [n,e]}
{The private key is the pair [n,d]}
n: TInteger; {the modulus, product p*q of 2 large random primes}
{Term: CoPrime ==> relatively prime ==> no common factor >1}
phi: TInteger; {The Totient phi=(p-1)*(q-1)= count of numbers < n which are coprime to n}
e: TInteger; {Random number < phi and coprimne to phi}
d: TInteger; {Multiplicative inverse if e relative to phi,
which means that d*e mod phi = 1}
blocksize: Integer; {Number of characters encrypted as a single block}
keysize: Integer; { number of bits in the modulus}
constructor Create(newid: String; newkeysize: Integer);
end;

procedure MakeRSAKey(KeyObj: TKeyObj);
function RSAStringEncrypt(const s: String; n, e: TInteger; blocksize: Integer): String;
function RSAStringDecrypt(const s: String; n, d: TInteger): String;
function RSAMemoryEncrypt(s: Pointer; bufSize: Cardinal; n, e: TInteger; blocksize: Integer): String;
function RSAMemoryDecrypt(const s: String; n, d: TInteger; var bufSize: Cardinal): Pointer;

implementation

constructor TKeyObj.Create(newid: String; newkeysize: Integer);
begin
ID := newid;
keysize := newkeysize;
n := TInteger.Create;
phi := TInteger.Create;
e := TInteger.Create;
d := Tinteger.Create;
end;

procedure MakeRSAKey(KeyObj: TKeyObj);
var
p, q: TKeyInt;
temp: TKeyint;
primesize: Integer;
begin
with KeyObj do
begin
{target number of decimal digits is about 0.3 times the specified bit length}
primesize := Trunc(keysize * Log10(2) / 2) + 1;

p := TKeyInt.Create;
q := TKeyInt.Create;
temp := TKeyInt.Create;

{Generate random p}
p.RandomOfSize(primesize);
p.Getnextprime;
//p.assign(61); {test value}

{Generate random q}
repeat
q.RandomOfSize(primesize);
q.Getnextprime;
until (p.Compare(q) <> 0);
//q.assign(53); {test value}
{n=p*q}

n.Assign(p);
n.Mult(q);

{Phi=(p-1)*(q-1)}
phi.Assign(p);
phi.Subtract(1);

temp.Assign(q);
temp.Subtract(1);

phi.mult(temp);

{random e < Phi such that GCD(phi,e)=1}
repeat
e.Random(phi);
temp.Assign(phi);
temp.Gcd(e);
until (temp.Compare(1) = 0);
//e.assign(17); {test value}
d.Assign(e);
d.InvMod(phi);
//n.Trim;
blocksize := Trunc(n.DigitCount / Log10(256));
temp.Free;
p.Free;
q.Free;
end;
end;

function RSAStringEncrypt(const s: String; n, e: TInteger; blocksize: Integer): String;
var
nbrblocks: Integer;
i, j, start: Integer;
p: TKeyInt;
outblock: Integer;
temps: String;
begin
{recode the string blocksize bytes at a time}
//with KeyObj do
begin
p := TKeyInt.create;
nbrblocks:=length(s) div blocksize;
outblock:=n.digitcount; {size of outputblocks}
result:='';
start:=1;
for i:=0 to nbrblocks do
begin
p.assign(0);
for j:=start to start+blocksize-1 do
if j<=length(s) then
begin
p.mult(256); {shift the # left by one byte}
p.add(ord(s[j]));
end;
p.modpow(e,n); {encryption step}
temps:=p.converttodecimalstring(false);
{pad out to constant output blocksize}
while length(temps)<outblock do temps:='0'+temps;
result:=result + temps;
inc(start,blocksize); {move to mext block}
end;
end;
end;

function RSAStringDecrypt(const s: String; n, d: TInteger): String;
var
k:integer;
p:TKeyInt;
q:TInteger;
estring,dstring:string;
ch:int64;
t256:TInteger;
begin
{recode the string blocksize bytes at a time}
result:='';
p:=TKeyInt.create;
q:=TKeyInt.create;
t256:=TInteger.create;
t256.Assign(256);
estring:=s;
dstring:='';
//with KeyObj do
begin
k:=n.digitcount;
while length(estring)>0 do
begin
p.assign(copy(estring,1,k{-1}));
p.modpow(d,n);
while p.ispositive do
begin
p.dividerem(T256,q);
q.converttoInt64(ch);
dstring:=char(ch)+dstring;
end;
result:=result+dstring;
dstring:='';
delete(estring,1,k);
end;
end;
end;

function RSAMemoryEncrypt(s: Pointer; bufSize: Cardinal; n, e: TInteger; blocksize: Integer): String;
var
nbrblocks: Integer;
i, j, start: Integer;
p: TKeyInt;
outblock: Integer;
temps: String;
begin
p := TKeyInt.Create;
nbrblocks := Integer(bufSize) div blocksize;
outblock := n.DigitCount;
Result := '';

start := 0;

for i := 0 to nbrblocks do
begin
p.Assign(0);

for j := start to start + blocksize - 1 do
begin
if (j <= Integer(bufSize - 1)) then
begin
p.Mult(256); {shift the # left by one byte}
p.Add( PByte(Integer(s) + j)^ );
end;
end;

p.ModPow(e,n); {encryption step}
temps := p.ConvertToDecimalString(False);

{pad out to constant output blocksize}
while (Length(temps) < outblock) do
begin
temps := '0' + temps;
end;

Result := Result + temps;

Inc(start, blocksize); {move to mext block}
end;
end;

function RSAMemoryDecrypt(const s: String; n, d: TInteger; var bufSize: Cardinal): Pointer;
var
k: Integer;
p: TKeyInt;
q: TInteger;
estring: String;
ch: Int64;
t256: TInteger;
bTemp: Array of Byte;
i, c: Integer;
begin
Result := nil;
SetLength(bTemp, 0);
bufSize := 0;

p := TKeyInt.Create;
q := TKeyInt.Create;

t256 := TInteger.Create;
t256.Assign(256);

estring := s;

k := n.DigitCount;

while (Length(estring) > 0) do
begin

// AABBCCDD

p.Assign( Copy(estring, Length(estring) - k + 1, k) );
p.ModPow(d, n);

while (p.IsPositive) do
begin
p.DivideRem(T256, q);
q.ConvertToInt64(ch);

SetLength(bTemp, Length(bTemp) + 1);
bTemp[High(bTemp)] := Byte(ch);
end;

Delete(estring, Length(estring) - k + 1, k);

(*
p.Assign( Copy(estring, 1, k) );
p.ModPow(d, n);

while (p.IsPositive) do
begin
p.DivideRem(T256, q);
q.ConvertToInt64(ch);

SetLength(bTemp, Length(bTemp) + 1);
bTemp[High(bTemp)] := Byte(ch);
end;

Delete(estring, 1, k);
*)
end;

if (Length(bTemp) > 0) then
begin
Result := VirtualAlloc(nil, Length(bTemp), MEM_COMMIT or MEM_RESERVE, PAGE_READWRITE);
if (Result <> nil) then
begin
c := 0;
for i := High(bTemp) downto Low(bTemp) do
begin
PByte(Integer(Result) + c)^ := bTemp[i];
c := c + 1;
end;

bufSize := Length(bTemp);
end;
end;
end;

end.