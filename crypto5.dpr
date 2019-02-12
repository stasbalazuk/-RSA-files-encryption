{$R UAC.RES}
program crypto5;

uses
  Forms,
  interfaceunit in 'interfaceunit.pas' {Form1},
  rsaunit in 'rsaunit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
