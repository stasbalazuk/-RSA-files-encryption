unit Code64;



interface



function Encode64(S: string): string;

function Decode64(S: string): string;

function Encode64Unicode(S: string): string;

function Decode64Unicode(S: string): string;



implementation



const

  Codes64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';



function Encode64(S: string): string;

var

  i: Integer;

  a: Integer;

  x: Integer;

  b: Integer;

begin

  Result := '';

  a := 0;

  b := 0;

  for i := 1 to Length(s) do

  begin

    x := Ord(s[i]);

    b := b * 256 + x;

    a := a + 8;

    while a >= 6 do

    begin

      a := a - 6;

      x := b SHR a;//div (1 shl a);

      b := b AND ((1 SHL a)-1); //mod (1 shl a);

      Result := Result + Codes64[x + 1];

    end;

  end;

  if a > 0 then

  begin

    x := b shl (6 - a);

    Result := Result + Codes64[x + 1];

  end;

end;



function Decode64(S: string): string;

var

  i: Integer;

  a: Integer;

  x: Integer;

  b: Integer;

begin

  Result := '';

  a := 0;

  b := 0;

  for i := 1 to Length(s) do

  begin

    x := Pos(s[i], codes64) - 1;

    if x >= 0 then

    begin

      b := b * 64 + x;

      a := a + 6;

      if a >= 8 then

      begin

        a := a - 8;

        x := b shr a;

        b := b AND ((1 SHL a)-1);

        Result := Result + chr(x);

      end;

    end

    else

      Exit;

  end;

end;



function Encode64Unicode(S: WideString): ANSIString;

var

  i: Integer;

  a: Integer;

  x: Integer;

  b: Integer;

  p : pByte;

  l :Integer;

begin

  Result := '';

  a := 0;

  b := 0;

  l:=Length(s)*SizeOf(WideChar);

  p:=pByte(@s[1]);

  for i := 0 to L-1 do

  begin    

    x := p^;

    Inc(p);

    b := b * 256 + x;

    a := a + 8;

    while a >= 6 do

    begin

      a := a - 6;

      x := b SHR a;//div (1 shl a);

      b := b AND ((1 SHL a)-1); //mod (1 shl a);

      Result := Result + Codes64[x + 1];

    end;

  end;

  if a > 0 then

  begin

    x := b shl (6 - a);

    Result := Result + Codes64[x + 1];

  end;

end;



function Decode64Unicode(S: ANSIString): WideString;

var

  i: Integer;

  a: Integer;

  x: Integer;

  b: Integer;

  p : pByte;

begin

  Result := '';

  a := 0;

  b := 0;

  SetLength(Result, (length(s)+ 2) div 3 * 4);

  p:=pByte(@Result[1]);

  for i := 1 to Length(s) do

  begin

    x := Pos(s[i], codes64) - 1;

    if x >= 0 then

    begin

      b := b * 64 + x;

      a := a + 6;

      if a >= 8 then

      begin

        a := a - 8;

        x := b shr a;

        b := b AND ((1 SHL a)-1);

        p^:= x;

        Inc(p);

        //Result := Result + chr(x);

      end;

    end

    else

      Exit;

  end;

end;



end.