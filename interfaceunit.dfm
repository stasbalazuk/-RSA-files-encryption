object Form1: TForm1
  Left = 796
  Top = 272
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'RSA v1.0.0.0  | StalkerSTS | '#1064#1080#1092#1088#1086#1074#1072#1085#1080#1077' '#1092#1072#1081#1083#1072
  ClientHeight = 371
  ClientWidth = 409
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 1
    Width = 409
    Height = 53
    Align = alBottom
    Caption = #1059#1082#1072#1079#1072#1090#1100' '#1092#1072#1081#1083' '#1076#1083#1103' '#1079#1072#1075#1088#1091#1079#1082#1080' '#1076#1072#1085#1085#1099#1093
    TabOrder = 0
    object Edit1: TEdit
      Left = 8
      Top = 20
      Width = 301
      Height = 21
      Enabled = False
      TabOrder = 0
    end
    object Button1: TButton
      Left = 316
      Top = 20
      Width = 85
      Height = 21
      Caption = #1054#1090#1082#1088#1099#1090#1100
      TabOrder = 1
      OnClick = Button1Click
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 54
    Width = 409
    Height = 53
    Align = alBottom
    Caption = #1059#1082#1072#1079#1072#1090#1100' '#1092#1072#1081#1083' '#1076#1083#1103' '#1089#1086#1093#1088#1072#1085#1077#1085#1080#1103' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1072
    TabOrder = 1
    object Edit2: TEdit
      Left = 8
      Top = 20
      Width = 393
      Height = 21
      TabOrder = 0
    end
  end
  object GroupBox4: TGroupBox
    Left = 0
    Top = 224
    Width = 409
    Height = 147
    Align = alBottom
    Caption = #1042#1099#1087#1086#1083#1085#1080#1090#1100' '#1076#1077#1081#1089#1090#1074#1080#1103
    TabOrder = 2
    object Gauge1: TGauge
      Left = 2
      Top = 125
      Width = 405
      Height = 20
      Align = alBottom
      ForeColor = clBlue
      Progress = 0
    end
    object Button3: TButton
      Left = 8
      Top = 20
      Width = 81
      Height = 53
      Caption = #1064#1080#1092#1088#1086#1074#1072#1090#1100
      Enabled = False
      TabOrder = 0
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 316
      Top = 20
      Width = 85
      Height = 53
      Caption = #1044#1077#1096#1080#1092#1088#1086#1074#1072#1090#1100
      Enabled = False
      TabOrder = 1
      OnClick = Button4Click
    end
    object Panel1: TPanel
      Left = 2
      Top = 104
      Width = 405
      Height = 21
      Align = alBottom
      Caption = #1057#1090#1072#1090#1091#1089
      TabOrder = 2
    end
    object btn1: TButton
      Left = 96
      Top = 20
      Width = 211
      Height = 21
      Caption = 'Generator P | Q | N | E | D'
      TabOrder = 3
      OnClick = btn1Click
    end
    object chk1: TCheckBox
      Left = 96
      Top = 48
      Width = 97
      Height = 17
      Caption = 'Load public key'
      Enabled = False
      TabOrder = 4
      OnClick = chk1Click
    end
    object chk2: TCheckBox
      Left = 200
      Top = 48
      Width = 105
      Height = 17
      Caption = 'Load private key'
      Enabled = False
      TabOrder = 5
      OnClick = chk2Click
    end
  end
  object grp1: TGroupBox
    Left = 0
    Top = 107
    Width = 409
    Height = 117
    Align = alBottom
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1096#1080#1092#1088#1086#1074#1072#1085#1080#1103
    TabOrder = 3
    object LabeledEdit1: TLabeledEdit
      Left = 8
      Top = 36
      Width = 193
      Height = 21
      EditLabel.Width = 37
      EditLabel.Height = 13
      EditLabel.Caption = 'P = 661'
      Enabled = False
      TabOrder = 0
    end
    object LabeledEdit2: TLabeledEdit
      Left = 8
      Top = 80
      Width = 193
      Height = 21
      EditLabel.Width = 38
      EditLabel.Height = 13
      EditLabel.Caption = 'Q = 809'
      Enabled = False
      TabOrder = 1
    end
    object LabeledEdit3: TLabeledEdit
      Left = 208
      Top = 36
      Width = 193
      Height = 21
      EditLabel.Width = 46
      EditLabel.Height = 13
      EditLabel.Caption = 'N = P x Q'
      Enabled = False
      ReadOnly = True
      TabOrder = 2
    end
    object LabeledEdit4: TLabeledEdit
      Left = 208
      Top = 80
      Width = 81
      Height = 21
      EditLabel.Width = 7
      EditLabel.Height = 13
      EditLabel.Caption = 'E'
      Enabled = False
      ReadOnly = True
      TabOrder = 3
    end
    object LabeledEdit5: TLabeledEdit
      Left = 296
      Top = 80
      Width = 105
      Height = 21
      EditLabel.Width = 8
      EditLabel.Height = 13
      EditLabel.Caption = 'D'
      Enabled = False
      ReadOnly = True
      TabOrder = 4
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 312
    Top = 48
  end
  object DCP_rijndael1: TDCP_rijndael
    Id = 9
    Algorithm = 'Rijndael'
    MaxKeySize = 256
    BlockSize = 128
    Left = 248
    Top = 48
  end
  object DCP_sha5121: TDCP_sha512
    Id = 30
    Algorithm = 'SHA512'
    HashSize = 512
    Left = 216
    Top = 48
  end
end
