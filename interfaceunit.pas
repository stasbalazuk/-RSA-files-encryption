unit interfaceunit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, XPMan, rsaunit, uRSA, uBigIntsV4, Math,
  Gauges, DCPsha512, DCPsha256, DCPcrypt2, DCPsha1, DCPice, DCPtwofish,
  DCPtea, DCPserpent, DCPdes, DCPblockciphers, DCPrijndael, DCPrc4,
  DCPcast128, DCPblowfish, DCPrc2, untComBase64;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    Edit1: TEdit;
    Button1: TButton;
    GroupBox2: TGroupBox;
    Edit2: TEdit;
    GroupBox4: TGroupBox;
    Button3: TButton;
    Button4: TButton;
    Panel1: TPanel;
    OpenDialog1: TOpenDialog;
    btn1: TButton;
    Gauge1: TGauge;
    grp1: TGroupBox;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    LabeledEdit4: TLabeledEdit;
    LabeledEdit5: TLabeledEdit;
    DCP_rijndael1: TDCP_rijndael;
    DCP_sha5121: TDCP_sha512;
    chk1: TCheckBox;
    chk2: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure chk1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chk2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  p,q,e,d,n2n:word;
  n,m:longword;
  keys,keyp: TStringList;
  icp: integer;
  scp: string;
  cp: TStringList;
  KeyRelease:string = 'DJFDKSFghjyg;KH9bn6CRTXCx4hUGLB.8.nkVTJ6FJfjylk7gl7GLUHm'+
                      'HG7gnkBk8jhKkKJHK87HkjkFGF6PCbV9KaK81WWYgP[CR[yjILWv2_SBE]AsLEz_8sBZ3LV5N'+
                      'Go0NLL1om4;XbALjhgkk7sda823r23;d923NrUdkzPp5/DkJ2_8JvYmWFn/LR3CRxyfswsto'+
                      'HG7gnkBk8jhKkKJHK87HkjkFGF6PCbV9KaK81WWYgP[CR[yjILWv2_SBE]AsLEz_8sBZ3LV5N'+
                      'Go0NLL1om4;XbALjhgkk7sda823r23;d923NrUdkzPp5/DkJ2_8JvYmWFn/LR3CRxyfswsto'+
                      'HG7gnkBk8jhKkKJHK87HkjkFGF6PCbV9KaK81WWYgP[CR[yjILWv2_SBE]AsLEz_8sBZ3LV5N'+
                      'Go823r23;d923NrUdkzPp5,DkJ2_8JvYmWFn0NLL1om4:XbALjhgkk7sda,LR3CRxyfswsto'+                      
                      'cvnkscv78h2lk8HHKhlkjdfvsd;vlkvsd0vvds;ldvhyB[NXzl5y5Z';

implementation

{$R *.dfm}

//Для зашифрования строки
function EncryptString(Source, Password: string): string;
var
  DCP_rijndael1: TDCP_rijndael;
begin
  DCP_rijndael1 := TDCP_rijndael.Create(nil);   // создаём объект
  DCP_rijndael1.InitStr(Password, TDCP_sha512);    // инициализируем
  Result := DCP_rijndael1.EncryptString(Source); // шифруем
  DCP_rijndael1.Burn;                            // стираем инфо о ключе
  DCP_rijndael1.Free;                            // уничтожаем объект
end;

//Для расшифрования строки
function DecryptString(Source, Password: string): string;
var
  DCP_rijndael1: TDCP_rijndael;
begin
  DCP_rijndael1 := TDCP_rijndael.Create(nil);   // создаём объект
  DCP_rijndael1.InitStr(Password, TDCP_sha512);    // инициализируем
  Result := DCP_rijndael1.DecryptString(Source); // дешифруем
  DCP_rijndael1.Burn;                            // стираем инфо о ключе
  DCP_rijndael1.Free;                            // уничтожаем объект
end;

function DigestToStr(Digest: array of byte): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to 19 do
    Result := Result + LowerCase(IntToHex(Digest[i], 2));
end;

//хэш-сумму файла:
function GetFileHash(FileName: string): string;
var
  Hash: TDCP_sha512;
  Digest: array[0..190] of byte; //sha1 вычисляет 160-битовую хэш-сумму (20 байт)
  Source: TFileStream;
begin
  Source:= TfileStream.Create(FileName,fmOpenRead);
  Hash:= TDCP_sha512.Create(nil);               // создаём объект
  Hash.Init;                                   // инициализируем
  Hash.UpdateStream(Source,Source.Size);       // вычисляем хэш-сумму
  Hash.Final(Digest);                          // сохраняем её в массив
  Source.Free;                                 // уничтожаем объект
  Result := DigestToStr(Digest);               // получаем хэш-сумму строкой
end;

Function HOD(a, b : int64) : int64;
var
  r : int64;
begin
  {если хотя бы одно из чисел равно 0, НОД также равен 0}
  if ((a=0)or(b=0)) then begin
    Result := abs(a+b);
    exit;
  end;
  {оба числа ненулевые}
  r := a-b*(a div b);
  while r <> 0 do begin
    a := b;
    b := r;
    r := a-b*(a div b);
  end;
  Result := b;
end;

//Файл без расширения
function ExtractOnlyFileName(const FileName: string): string;
begin
  result:=StringReplace(ExtractFileName(FileName),ExtractFileExt(FileName),'',[]);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  OpenDialog1.Filter:='*.*|*.*';
  OpenDialog1.InitialDir := ExtractFileDir(ParamStr(0));
  if OpenDialog1.Execute then
  if ExtractFileExt(OpenDialog1.FileName) = '.rsa' then begin
     Edit2.Text := ExtractFilePath(OpenDialog1.FileName)+ExtractOnlyFileName(OpenDialog1.FileName);
     Edit1.Text := OpenDialog1.FileName;
  if (Edit1.Text <> '') and (Edit2.Text <> '') then begin
     Button4.Enabled:=True;
     chk1.Enabled:=True;
     Button3.Enabled:=False;
     chk2.Enabled:=False;
  end;
  end else begin
    Edit1.Text := OpenDialog1.FileName;
    Edit2.Text := OpenDialog1.FileName+'.rsa';
  if (Edit1.Text <> '') and (Edit2.Text <> '') then begin
    Button3.Enabled:=True;
    chk2.Enabled:=True;    
    Button4.Enabled:=False;
    chk1.Enabled:=False;
  end;
  end;
    Panel1.Caption := 'Статус';
end;

procedure FillPQE(out P, Q, E, D: TInt);
var
  I: TInt;
begin
  P := StrToInt64(Form1.LabeledEdit1.Text);
  Q := StrToInt64(Form1.LabeledEdit2.Text);
  I := 2;
  repeat
    I := I + 1;
  until GetD((P - 1) * (Q - 1), I, D) = 1;
  E := I;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  P: TInt;
  Q: TInt;
  E: TInt;
  D: TInt;
  FileIn: TFileStream;
  FileOut: TFileStream;
begin
  btn1.Enabled:=False;
  chk1.Enabled:=False;
  chk2.Enabled:=False;
  Button3.Enabled:=False;
  Button4.Enabled:=False;
  Button1.Enabled:=False;
  Panel1.Caption := 'Идет процесс шифрования';
  Panel1.Refresh;
  Application.ProcessMessages;
  FillPQE(P, Q, E, D);
  FileIn := TFileStream.Create(Edit1.Text, fmOpenRead, fmShareExclusive);
  FileOut := TFileStream.Create(Edit2.Text, fmCreate, fmShareExclusive);
  Encrypt(FileIn, FileOut, P, Q, E);
  MessageBox(Handle,PChar('Файл успешно зашифрован!'+#10#13+'N = '+IntToStr(P * Q)+#10#13+'E = '+IntToStr(E)),PChar('Внимание'),64);
  Panel1.Caption:=' N = '+IntToStr(P)+' * '+IntToStr(Q)+' = '+LabeledEdit3.Text+' | E = '+IntToStr(e)+' | D = '+IntToStr(d);
  Panel1.Caption := 'Процесс шифрования завершен';
  Panel1.Refresh;
  Application.ProcessMessages;
  FileIn.Free;
  FileOut.Free;
  /////////////
  btn1.Enabled:=True;
  chk1.Enabled:=True;
  chk2.Enabled:=True;
  Button3.Enabled:=True;
  Button4.Enabled:=True;
  Button1.Enabled:=True;
end;

//Алгоритм создания открытого и секретного ключей
{
P и Q - случайные числа для создания открытого и секретного ключа
Выбираются два различных случайных простых числа p и q заданного размера (например, 1024 бита каждое).
Вычисляется их произведение n=p*q, которое называется модулем.
Вычисляется значение функции Эйлера от числа n:
}
//Пара {e,n} публикуется в качестве открытого ключа RSA (англ. RSA public key).
//Пара {d,n} играет роль закрытого ключа RSA (англ. RSA private key) и держится в секрете.

procedure TForm1.Button4Click(Sender: TObject);
var
  P: TInt;
  Q: TInt;
  E: TInt;
  D: TInt;
  FileIn: TFileStream;
  FileOut: TFileStream;
begin
  btn1.Enabled:=False;
  chk1.Enabled:=False;
  chk2.Enabled:=False;
  Button3.Enabled:=False;
  Button4.Enabled:=False;
  Button1.Enabled:=False;
  Panel1.Caption := 'Идет процесс дешифрования';
  Panel1.Refresh;
  Application.ProcessMessages;
  FillPQE(P, Q, E, D);
  FileIn := TFileStream.Create(Edit1.Text, fmOpenRead, fmShareExclusive);
  FileOut := TFileStream.Create(Edit2.Text, fmCreate, fmShareExclusive);
  Decrypt(FileIn, FileOut, P, Q, E);
  MessageBox(Handle,PChar('Файл успешно расшифрован!'+#10#13+'N = '+IntToStr(P * Q)+#10#13+'D = '+IntToStr(D)),PChar('Внимание'),64);
  Panel1.Caption:=' N = '+IntToStr(P)+' * '+IntToStr(Q)+' = '+LabeledEdit3.Text+' | E = '+IntToStr(e)+' | D = '+IntToStr(d);
  Panel1.Caption := 'Процесс дешифрования завершен';
  Panel1.Refresh;
  Application.ProcessMessages;
  FileIn.Free;
  FileOut.Free;
  btn1.Enabled:=True;
  chk1.Enabled:=True;
  chk2.Enabled:=True;
  Button3.Enabled:=True;
  Button4.Enabled:=True;
  Button1.Enabled:=True;
end;

Function PrimeNumber(Const X: Integer): Boolean;
Var
     I: Integer;
Begin
     If X <= 1 Then 
     Begin
          PrimeNumber := False;
          Exit;
     End;
     For I := 2 To Trunc(Sqrt(X)) Do
          If X Mod I = 0 Then
          Begin
               PrimeNumber := False;
               Exit;
          End;
     PrimeNumber := True;
End;

procedure TForm1.btn1Click(Sender: TObject);
label vx;
var
  P: TInt;
  Q: TInt;
  E: TInt;
  D: TInt;
  i: Integer;
  prk,pbk,hs: string;
begin
  vx:
  p:=0; q:=0;
  e:=0; d:=0;
  randomize;
  p:=Random(1001);
  q:=Random(1001);
  Panel1.Caption := 'Генерация простых чисел';
  Application.ProcessMessages;
While not PrimeNumber(p) do begin
  dec(p);
  LabeledEdit1.Text:=IntToStr(p);
end;
While not PrimeNumber(q) do begin
  dec(q);
  LabeledEdit2.Text:=IntToStr(q);
end;
  if p < 500 then goto vx;
  if q < 500 then goto vx;
try
  FillPQE(P, Q, E, D);
except
  Panel1.Caption:='Generator RSA public | private key';
end;
  if d < 0 then goto vx;
  LabeledEdit3.Text:=IntToStr(P * Q);
  LabeledEdit4.Text:=IntToStr(e);
  LabeledEdit5.Text:=IntToStr(d);
  Panel1.Caption:=' N = '+IntToStr(P)+' * '+IntToStr(Q)+' = '+LabeledEdit3.Text+' | E = '+IntToStr(e)+' | D = '+IntToStr(d);
  for i:=0 to Gauge1.MaxValue do Gauge1.Progress:=i;
  prk:=LabeledEdit5.Text+'|'+LabeledEdit2.Text+'|'+LabeledEdit1.Text+'|'+LabeledEdit4.Text+'|'+LabeledEdit3.Text;
  pbk:=LabeledEdit1.Text+'|'+LabeledEdit2.Text+'|'+LabeledEdit3.Text+'|'+LabeledEdit5.Text;
  prk:=EncryptString(prk,KeyRelease);
  pbk:=EncryptString(pbk,KeyRelease);
  prk:=encode64(prk);
  pbk:=encode64(pbk);  
 if FileExists(ExtractFilePath(ParamStr(0))+'private.pem') then
  keys.LoadFromFile(ExtractFilePath(ParamStr(0))+'private.pem');
  keys.Clear;
  keys.Add('-----BEGIN RSA PRIVATE KEY-----');
  keys.Add(prk); //Строка для записи в файл
  keys.Add('-----END RSA PRIVATE KEY-----');
  keys.SaveToFile(ExtractFilePath(ParamStr(0))+'private.pem'); //Сохранил в файл
 if FileExists(ExtractFilePath(ParamStr(0))+'private.pem') then
  hs:=GetFileHash(ExtractFilePath(ParamStr(0))+'private.pem');
 if hs <> '' then begin
    keys.Clear;
    hs:=encode64(hs);
    keys.LoadFromFile(ExtractFilePath(ParamStr(0))+'private.pem');
    keys.Insert(2, hs); //Если надо дописать на определенную позицию, в данном случае наша строка будет 3-й сверху
    keys.SaveToFile(ExtractFilePath(ParamStr(0))+'private.pem'); //Сохранил в файл
 end;
  /////////////////////////////////////////
 if FileExists(ExtractFilePath(ParamStr(0))+'public.pem') then
  keys.LoadFromFile(ExtractFilePath(ParamStr(0))+'public.pem');
  keys.Clear;  
  keys.Add('-----BEGIN PUBLIC KEY-----');
  keys.Add(pbk); //Строка для записи в файл
  //keys.Insert(2, s); //Если надо дописать на определенную позицию, в данном случае наша строка будет 3-й сверху
  keys.Add('-----END PUBLIC KEY-----');
  keys.SaveToFile(ExtractFilePath(ParamStr(0))+'public.pem'); //Сохранил в файл
  if (FileExists(ExtractFilePath(ParamStr(0))+'public.pem')) and (FileExists(ExtractFilePath(ParamStr(0))+'private.pem')) then
  MessageBox(Handle,PChar('RSA ключи успешно созданы!'),PChar('Внимание'),64);
end;

procedure TForm1.chk1Click(Sender: TObject);
begin
 keys.Clear;
 if chk1.Checked then begin
    btn1.Enabled:=False;
    chk2.Checked:=false;
    LabeledEdit1.Clear;
    LabeledEdit2.Clear;
    LabeledEdit3.Clear;
    LabeledEdit4.Clear;
    LabeledEdit5.Clear;
    OpenDialog1.FileName:='public.pem';
    OpenDialog1.Filter:='public.pem|*.pem';
 if OpenDialog1.Execute then
 if FileExists(ExtractFilePath(OpenDialog1.FileName)+'public.pem') then begin
  keys.LoadFromFile(ExtractFilePath(OpenDialog1.FileName)+'public.pem');
  if keys.Text <> '' then
  if keys.Count = 3 then begin
  keys.Text:=decode64(keys[1]);
  keys.Text:=DecryptString(keys.Text,KeyRelease);
  keys.Delimiter:='|';
  keys.DelimitedText := keys.Text;
  end;
  if keys.Text <> '' then begin
  Panel1.Caption:='CRC RSA public key - OK';
  LabeledEdit1.Text:=Trim(keys[0]);
  LabeledEdit2.Text:=Trim(keys[1]);
  LabeledEdit3.Text:=Trim(keys[2]);
  LabeledEdit5.Text:=Trim(keys[3]);
  btn1.Enabled:=True;
  Button4.Enabled:=True;
  Button3.Enabled:=False;
  end;
 end;
 end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  keys:= TStringList.Create;
  keyp:= TStringList.Create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  keyp.Free;
  keys.Free;
end;

procedure TForm1.chk2Click(Sender: TObject);
var
  hs,vl,ks: string;
  i: Integer;
begin
 keys.Clear;
 if chk2.Checked then begin
    btn1.Enabled:=False;
    chk1.Checked:=false;
    LabeledEdit1.Clear;
    LabeledEdit2.Clear;
    LabeledEdit3.Clear;
    LabeledEdit4.Clear;
    LabeledEdit5.Clear;
    //private.pem|*.pem|public.pem|*.pem|*.exe|*.exe
    OpenDialog1.Filter:='private.pem|*.pem';
 if OpenDialog1.Execute then
    OpenDialog1.FileName:='private.pem';
 if FileExists(ExtractFilePath(OpenDialog1.FileName)+'private.pem') then  begin
    keyp.LoadFromFile(ExtractFilePath(OpenDialog1.FileName)+'private.pem');
    keys.LoadFromFile(ExtractFilePath(OpenDialog1.FileName)+'private.pem');
  if keys.Text <> '' then begin
  if keys.Count = 4 then
     hs:=decode64(keys[2]);
  if keys.Count <= 4 then
     ks:=keys[1]
  else begin
     Panel1.Caption:='CRC RSA private key - ERROR';
     Exit;
  end;
     keys.Clear;
     keys.Add('-----BEGIN RSA PRIVATE KEY-----');
     keys.Add(ks); //Строка для записи в файл
     keys.Add('-----END RSA PRIVATE KEY-----');
     keys.SaveToFile(ExtractFilePath(OpenDialog1.FileName)+'private.pem');
     vl:=GetFileHash(ExtractFilePath(OpenDialog1.FileName)+'private.pem');
  if vl = hs then begin
     Panel1.Caption:='CRC RSA private key - OK';
     keyp.SaveToFile(ExtractFilePath(OpenDialog1.FileName)+'private.pem');
  end else begin
     keyp.SaveToFile(ExtractFilePath(OpenDialog1.FileName)+'private.pem');
     Panel1.Caption:='CRC RSA private key - ERROR';
     Exit;
  end;
     keys.LoadFromFile(ExtractFilePath(OpenDialog1.FileName)+'private.pem');
  end;
  if keys.Text <> '' then
  if keys.Count <= 4 then ks:=decode64(keys[1])
  else begin
     Panel1.Caption:='CRC RSA private key - ERROR';
     Exit;
  end;
  keys.Text:=DecryptString(ks,KeyRelease);
  keys.Delimiter:='|';
  keys.DelimitedText := keys.Text;
  LabeledEdit5.Text:=keys[0];
  LabeledEdit2.Text:=keys[1];
  LabeledEdit1.Text:=keys[2];
  LabeledEdit4.Text:=keys[3];
  LabeledEdit3.Text:=keys[4];
  btn1.Enabled:=True;
  Button4.Enabled:=False;
  Button3.Enabled:=True;
 end;
 end;
end;

end.
