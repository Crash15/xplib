{$IFDEF Logndlg}
    {$DEFINE DEBUG_UNIT}
{$ENDIF}
{$I DlgLib.inc}

unit Logndlg;

interface

uses
    WinTypes, WinProcs, Classes, Graphics, Forms, Controls, StdCtrls, Buttons, SysUtils;

{$IF CompilerVersion >= 21.00}
type
    TPropText = TCaption;
{$ELSE}
type
    TPropText = string[40];
{$IFEND}

type

    TLoginDlgs = class(TForm)
        Label1 :    TLabel;
        PasswordEdit : TEdit;
        OKBtn :     TBitBtn;
        CancelBtn : TBitBtn;
        UserNameEdit : TEdit;
        Label2 :    TLabel;
        procedure FormShow(Sender : TObject);
    private
        { Private declarations }
    public
        { Public declarations }
    end;

    TLoginDlg = class;
    TOnCheckLoginEvent = procedure(Sender : TLoginDlg; var UserName, Password : string; var Accepted : boolean) of object;

    TLoginDlg = class(TComponent)
    private
        FTitle :   TPropText;
        FInitUserName : TPropText;
        FUserName : TPropText;
        FPass :    TPropText;
        Dlg :      TLoginDlgs;
        FUserNameCharCase : TEditCharCase;
        FPasswordCharCase : TEditCharCase;
        FOnCheckLogin : TOnCheckLoginEvent;
        FMaxRetries : integer;
        FRetries : integer;
        FInitPwd : TPropText;
        FCancelled : boolean;
        procedure SetUserName(const Value : TPropText);
        procedure SetInitUserName(const Value : TPropText);
        procedure SetInitPwd(const Value : TPropText);
        function GetActive : boolean;
    public
        constructor Create(AOwner : TComponent); override;
        procedure Cancel;
        function Execute : boolean;
        property UserName : TPropText Read FUserName Write SetUserName;
        {{
        Nome do usu�rio em processo de login e validado
        }
        property PassWord : TPropText Read FPass Write FPass;
        property Retries : integer Read FRetries;
    published
        property Cancelled : boolean Read FCancelled;
        {{
        Indica que a falha de login foi gerada pelo cancelamento do usu�rio
        }
        property Active : boolean Read GetActive;
        {{
        Flag indicando que o dialogo est� ativo
        }
        property MaxRetries : integer Read FMaxRetries Write FMaxRetries;
        {{
        Quantidade maxima de tentativas permitidas, o valor padr�o � 3. Quando Retries >= MaxRetries o resultado do login e dado como falso
        }
        property UserNameCharCase : TEditCharCase Read FUserNameCharCase Write FUserNameCharCase;
        {{
        Qual CharCase ser� usado para edi��o do nome do usu�rio.
        }
        property OnCheckLogin : TOnCheckLoginEvent Read FOnCheckLogin Write FOnCheckLogin;
        {{
        Evento de valida��o do login.
        procedure(Sender : TLoginDlg; var UserName, Password : string; var Accepted : boolean);
        Ajuste Accepted para true para validar positivamente o login.
        }
        property PasswordCharCase : TEditCharCase Read FPasswordCharCase Write FPasswordCharCase;
        {{
        Charcase da senha.
        }
        property Title : TPropText Read FTitle Write FTitle;
        {{
        Titulo a ser exibido no dialogo de captura da senha e nome do usu�rio.
        }
        property InitPwd : TPropText Read FInitPwd Write SetInitPwd;
        {{
        Valor da senha inicialmente preenchida no dialogo.
        }
        property InitUserName : TPropText Read FInitUserName Write SetInitUserName;
        {{
        Nome do usuario inicialmente preenchido.
        }
    end;

implementation

{$R *.DFM}


procedure TLoginDlg.Cancel;
{{
Cancela a execu��o do dialogo de captura do par senha/usuario e ajusta Cancelled para true

Revision: 19/7/2005
}
begin
    Self.FCancelled := True;
    if (Assigned(Self.Dlg)) then begin
        Self.Dlg.Close;
    end;
end;

constructor TLoginDlg.Create(AOwner : TComponent);
{{
Construtor padr�o de um componente e inicializa��o de atributos padr�o.

Revision: 19/7/2005
}
begin
    inherited Create(AOwner);
    Self.FMaxRetries   := 3;
    Self.FInitUserName := EmptyStr;
end;


function TLoginDlg.Execute : boolean;
{{
 Executa o dialogo de captura do par usu�rio/senha de acordo com os parametros ajustados

 Revision: 19/7/2005

 Ajustados os valores de Self.Password e Self.Username para o conteudo final do dialogo de modo a compatibilizar com os programas
 antigos que n�o usavam o evento OnValidate deste componente.

 Revision: 18/11/2005 - Roger
}
var
    UName, Pwd : string;
begin
    Self.FCancelled := False;
    Dlg := TLoginDlgs.Create(Self.Owner);
    try
        Dlg.Caption := FTitle;
        Dlg.UserNameEdit.CharCase := Self.FUserNameCharCase;
        Dlg.PasswordEdit.CharCase := Self.FPasswordCharCase;
        if FInitUserName <> EmptyStr then begin
            Dlg.UserNameEdit.Text := FInitUserName;  //Caso o Charcase <> nornal converso sera realizada
            if Dlg.UserNameEdit.Text = EmptyStr then begin
                Dlg.ActiveControl := Dlg.UserNameEdit;
            end else begin
                Dlg.ActiveControl := Dlg.PassWordEdit;
            end;
        end;
        Application.Restore;
        Application.BringToFront;
        FRetries := 0;
        while (Self.Active) do begin
            if (Dlg.ShowModal = mrOk) then begin
                UName := Dlg.UserNameEdit.Text;
                Pwd   := Dlg.PasswordEdit.Text;
                if (Assigned(Self.FOnCheckLogin)) then begin
                    Self.FOnCheckLogin(Self, UName, Pwd, Result);
                    if (Result) then begin  //Tudo OK -> Sair da execucao
                        Dlg.UserNameEdit.Text := UName;
                        Dlg.PasswordEdit.Text := Pwd;
                        //Repassa valores dos controles aos atributos da instancia que podem ter sido modificados no evento de valida��o
                        Self.UserName := UName;
                        Self.PassWord := Pwd;
                        Break;
                    end else begin  //Tentar novamente se permitido
                        Inc(Self.FRetries);
                        if (Self.Retries >= Self.FMaxRetries) then begin    //Tentativas permitidas falharam
                            Break;
                        end;
                    end;
                end else begin  //N�o existe validacao -> sempre sera aceito como OK
                    Self.UserName := UName;
                    Self.PassWord := Pwd;
                    Result := True;
                    Break;
                end;
                //Repassa valores dos controles aos atributos da instancia que podem ter sido modificados no evento de valida��o
                Self.UserName := UName;
                Self.PassWord := Pwd;
            end else begin
                Self.FCancelled := True;
                Break;
            end;
        end;
    finally
        FreeAndNil(Dlg);
    end;
end;

procedure TLoginDlgs.FormShow(Sender : TObject);
{{
Evento disparado no momento da exibi��o do dialogo de captura do par senha/usu�rio

Revision: 19/7/2005
}
begin
    Application.BringToFront;
    Application.ProcessMessages;
    SetForeGroundWindow(Self.Handle);
end;

function TLoginDlg.GetActive : boolean;
{{
Flag que indica se o dialogo est� em execu��o
}
begin
    Result := Assigned(Self.Dlg);
end;

procedure TLoginDlg.SetInitPwd(const Value : TPropText);
{{
Ajusta o valor incial da senha do dialogo.

Revision: 19/7/2005
}
begin
    FInitPwd := Value;
    if (Self.Active) then begin
        Self.Dlg.PasswordEdit.Text := Value;
    end;
end;

procedure TLoginDlg.SetInitUserName(const Value : TPropText);
{{
Ajusta o valor do nome do usu�rio em processo de login

Revision: 19/7/2005
}
begin
    Self.FInitUserName := Value;
    if (Assigned(Self.Dlg)) then begin
        Self.Dlg.UserNameEdit.Text := Value;
    end;
end;

procedure TLoginDlg.SetUserName(const Value : TPropText);
{{
Ajusta o nome do usu�rio em processo de login, bem como o valor inicial exibido no dialgo.

Revision: 19/7/2005
}
begin
    Self.FUserName    := Value;
    Self.InitUserName := Value; //Mais coerente para uma chamada posterior a Execute deste componente
end;

end.
