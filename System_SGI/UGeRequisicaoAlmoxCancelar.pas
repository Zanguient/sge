unit UGeRequisicaoAlmoxCancelar;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UGrPadrao, StdCtrls, Mask, DBCtrls, ExtCtrls, Buttons, DB,
  IBCustomDataSet, IBUpdateSQL, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, Menus, cxButtons;

type
  TfrmGeRequisicaoAlmoxCancelar = class(TfrmGrPadrao)
    GrpBxControle: TGroupBox;
    lblCodigo: TLabel;
    lblCentroCusto: TLabel;
    lblDataApropriacao: TLabel;
    dbCodigo: TDBEdit;
    dbCentroCusto: TDBEdit;
    dbDataApropriacao: TDBEdit;
    Bevel1: TBevel;
    GrpBxImposto: TGroupBox;
    lblCancelUsuario: TLabel;
    lblCancelDataHora: TLabel;
    lblMotivo: TLabel;
    dbMotivo: TMemo;
    dbCancelUsuario: TEdit;
    dbCancelDataHora: TEdit;
    Bevel2: TBevel;
    lblInforme: TLabel;
    cdsApropriacao: TIBDataSet;
    updApropriacao: TIBUpdateSQL;
    dtsApropriacao: TDataSource;
    dbEntrada: TDBEdit;
    lblEntrada: TLabel;
    dbFornecedor: TDBEdit;
    btnCancelar: TcxButton;
    btFechar: TcxButton;
    procedure btFecharClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure RegistrarRotinaSistema; override;
  end;

var
  frmGeRequisicaoAlmoxCancelar: TfrmGeRequisicaoAlmoxCancelar;

  function CancelarAPROP(const AOwer : TComponent; Ano : Smallint; Numero : Integer) : Boolean;

implementation

uses
  UDMBusiness, UDMNFe, UFuncoes;

{$R *.dfm}

function CancelarAPROP(const AOwer : TComponent; Ano : Smallint; Numero : Integer) : Boolean;
var
  frm : TfrmGeRequisicaoAlmoxCancelar;
begin
  frm := TfrmGeRequisicaoAlmoxCancelar.Create(AOwer);
  try
    with frm do
    begin
      cdsApropriacao.Close;
      cdsApropriacao.ParamByName('ano').AsShort        := Ano;
      cdsApropriacao.ParamByName('controle').AsInteger := Numero;
      cdsApropriacao.Open;

      dbCancelUsuario.Text  := GetUserApp;
      dbCancelDataHora.Text := FormatDateTime('dd/mm/yyyy hh:mm:ss', GetDateTimeDB);

      Result := (ShowModal = mrOk);
    end;
  finally
    frm.Free;
  end;
end;

procedure TfrmGeRequisicaoAlmoxCancelar.btFecharClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmGeRequisicaoAlmoxCancelar.RegistrarRotinaSistema;
begin
  ;
end;

procedure TfrmGeRequisicaoAlmoxCancelar.btnCancelarClick(
  Sender: TObject);
var
  sMsg : String;
  Cont : Boolean;
begin
  if ( cdsApropriacao.IsEmpty ) then
    Exit;

  if ( Trim(dbMotivo.Lines.Text) = EmptyStr ) then
  begin
    ShowWarning('Favor informar o motivo de cancelamento da apropria��o');
    dbMotivo.SetFocus;
  end
  else
  if ( Length(Trim(dbMotivo.Lines.Text)) < 15 ) then
  begin
    ShowWarning('Motivo de cancelamento da apropria��o deve possuir 15 caracteres no m�nimo.');
    dbMotivo.SetFocus;
  end
  else
  begin
    sMsg := 'Confirma o cancelamento da apropria��o?';

    Cont := ShowConfirm(sMsg);

    if ( Cont ) then
      with cdsApropriacao do
      begin
        Edit;

        cdsApropriacaoSTATUS.AsInteger           := STATUS_APROPRIACAO_ESTOQUE_CAN;
        cdsApropriacaoCANCEL_DATAHORA.AsDateTime := StrToDateTime( Trim(dbCancelDataHora.Text) );
        cdsApropriacaoCANCEL_USUARIO.AsString    := AnsiUpperCase( Trim(dbCancelUsuario.Text) );
        cdsApropriacaoCANCEL_MOTIVO.AsString     := AnsiUpperCase( Trim(dbMotivo.Lines.Text) );

        Post;
        ApplyUpdates;
        CommitTransaction;

        ModalResult := mrOk;
      end;
  end;
end;

end.