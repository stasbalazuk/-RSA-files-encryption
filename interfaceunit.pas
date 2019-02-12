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

//��� ������������ ������
function EncryptString(Source, Password: string): string;
var
  DCP_rijndael1: TDCP_rijndael;
begin
  DCP_rijndael1 := TDCP_rijndael.Create(nil);   // ������ ������
  DCP_rijndael1.InitStr(Password, TDCP_sha512);    // ��������������
  Result := DCP_rijndael1.EncryptString(Source); // �������
  DCP_rijndael1.Burn;                            // ������� ���� � �����
  DCP_rijndael1.Free;                            // ���������� ������
end;

//��� ������������� ������
function DecryptString(Source, Password: string): string;
var
  DCP_rijndael1: TDCP_rijndael;
begin
  DCP_rijndael1 := TDCP_rijndael.Create(nil);   // ������ ������
  DCP_rijndael1.InitStr(Password, TDCP_sha512);    // ��������������
  Result := DCP_rijndael1.DecryptString(Source); // ���������
  DCP_rijndael1.Burn;                            // ������� ���� � �����
  DCP_rijndael1.Free;                            // ���������� ������
end;

function DigestToStr(Digest: array of byte): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to 19 do
    Result := Result + LowerCase(IntToHex(Digest[i], 2));
end;

//���-����� �����:
function GetFileHash(FileName: string): string;
var
  Hash: TDCP_sha512;
  Digest: array[0..190] of byte; //sha1 ��������� 160-������� ���-����� (20 ����)
  Source: TFileStream;
begin
  Source:= TfileStream.Create(FileName,fmOpenRead);
  Hash:= TDCP_sha512.Create(nil);               // ������ ������
  Hash.Init;                                   // ��������������
  Hash.UpdateStream(Source,Source.Size);       // ��������� ���-�����
  Hash.Final(Digest);                          // ��������� � � ������
  Source.Free;                                 // ���������� ������
  Result := DigestToStr(Digest);               // �������� ���-����� �������
end;

Function HOD(a, b : int64) : int64;
var
  r : int64;
begin
  {���� ���� �� ���� �� ����� ����� 0, ��� ����� ����� 0}
  if ((a=0)or(b=0)) then begin
    Result := abs(a+b);
    exit;
  end;
  {��� ����� ���������}
  r := a-b*(a div b);
  while r <> 0 do begin
    a := b;
    b := r;
    r := a-b*(a div b);
  end;
  Result := b;
end;

//���� ��� ����������
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
    Panel1.Caption := '������';
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
  Panel1.Caption := '���� ������� ����������';
  Panel1.Refresh;
  Application.ProcessMessages;
  FillPQE(P, Q, E, D);
  FileIn := TFileStream.Create(Edit1.Text, fmOpenRead, fmShareExclusive);
  FileOut := TFileStream.Create(Edit2.Text, fmCreate, fmShareExclusive);
  Encrypt(FileIn, FileOut, P, Q, E);
  MessageBox(Handle,PChar('���� ������� ����������!'+#10#13+'N = '+IntToStr(P * Q)+#10#13+'E = '+IntToStr(E)),PChar('��������'),64);
  Panel1.Caption:=' N = '+IntToStr(P)+' * '+IntToStr(Q)+' = '+LabeledEdit3.Text+' | E = '+IntToStr(e)+' | D = '+IntToStr(d);
  Panel1.Caption := '������� ���������� ��������';
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

//�������� �������� ��������� � ���������� ������
{
P � Q - ��������� ����� ��� �������� ��������� � ���������� �����
���������� ��� ��������� ��������� ������� ����� p � q ��������� ������� (��������, 1024 ���� ������).
����������� �� ������������ n=p*q, ������� ���������� �������.
����������� �������� ������� ������ �� ����� n:
}
//���� {e,n} ����������� � �������� ��������� ����� RSA (����. RSA public key).
//���� {d,n} ������ ���� ��������� ����� RSA (����. RSA private key) � �������� � �������.

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
  Panel1.Caption := '���� ������� ������������';
  Panel1.Refresh;
  Application.ProcessMessages;
  FillPQE(P, Q, E, D);
  FileIn := TFileStream.Create(Edit1.Text, fmOpenRead, fmShareExclusive);
  FileOut := TFileStream.Create(Edit2.Text, fmCreate, fmShareExclusive);
  Decrypt(FileIn, FileOut, P, Q, E);
  MessageBox(Handle,PChar('���� ������� �����������!'+#10#13+'N = '+IntToStr(P * Q)+#10#13+'D = '+IntToStr(D)),PChar('��������'),64);
  Panel1.Caption:=' N = '+IntToStr(P)+' * '+IntToStr(Q)+' = '+LabeledEdit3.Text+' | E = '+IntToStr(e)+' | D = '+IntToStr(d);
  Panel1.Caption := '������� ������������ ��������';
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
  Panel1.Caption := '��������� ������� �����';
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
  keys.Add(prk); //������ ��� ������ � ����
  keys.Add('-----END RSA PRIVATE KEY-----');
  keys.SaveToFile(ExtractFilePath(ParamStr(0))+'private.pem'); //�������� � ����
 if FileExists(ExtractFilePath(ParamStr(0))+'private.pem') then
  hs:=GetFileHash(ExtractFilePath(ParamStr(0))+'private.pem');
 if hs <> '' then begin
    keys.Clear;
    hs:=encode64(hs);
    keys.LoadFromFile(ExtractFilePath(ParamStr(0))+'private.pem');
    keys.Insert(2, hs); //���� ���� �������� �� ������������ �������, � ������ ������ ���� ������ ����� 3-� ������
    keys.SaveToFile(ExtractFilePath(ParamStr(0))+'private.pem'); //�������� � ����
 end;
  /////////////////////////////////////////
 if FileExists(ExtractFilePath(ParamStr(0))+'public.pem') then
  keys.LoadFromFile(ExtractFilePath(ParamStr(0))+'public.pem');
  keys.Clear;  
  keys.Add('-----BEGIN PUBLIC KEY-----');
  keys.Add(pbk); //������ ��� ������ � ����
  //keys.Insert(2, s); //���� ���� �������� �� ������������ �������, � ������ ������ ���� ������ ����� 3-� ������
  keys.Add('-----END PUBLIC KEY-----');
  keys.SaveToFile(ExtractFilePath(ParamStr(0))+'public.pem'); //�������� � ����
  if (FileExists(ExtractFilePath(ParamStr(0))+'public.pem')) and (FileExists(ExtractFilePath(ParamStr(0))+'private.pem')) then
  MessageBox(Handle,PChar('RSA ����� ������� �������!'),PChar('��������'),64);
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
     keys.Add(ks); //������ ��� ������ � ����
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
