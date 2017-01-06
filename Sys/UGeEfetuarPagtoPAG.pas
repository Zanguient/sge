unit UGeEfetuarPagtoPAG;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UGrPadrao, StdCtrls, Mask, DBCtrls, ExtCtrls, DB, IBCustomDataSet, IBUpdateSQL,
  IBTable, Buttons, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, Menus, cxButtons,
  JvExMask, JvToolEdit, JvDBControls, IBX.IBQuery,

  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,

  dxSkinsCore, dxSkinMcSkin,
  dxSkinOffice2007Green, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Pink, dxSkinOffice2007Silver,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint;

type
  TfrmGeEfetuarPagtoPAG = class(TfrmGrPadrao)
    GrpBxPagamento: TGroupBox;
    Bevel1: TBevel;
    GrpBxLancamento: TGroupBox;
    lblAnoLanc: TLabel;
    Label3: TLabel;
    lblFornecedor: TLabel;
    edAnoLanc: TEdit;
    edNumLanc: TEdit;
    edFornecedor: TEdit;
    Bevel2: TBevel;
    cdsPagamentos: TIBDataSet;
    cdsPagamentosANOLANC: TSmallintField;
    cdsPagamentosNUMLANC: TIntegerField;
    cdsPagamentosSEQ: TSmallintField;
    cdsPagamentosHISTORICO: TMemoField;
    cdsPagamentosDATA_PAGTO: TDateField;
    cdsPagamentosFORMA_PAGTO: TSmallintField;
    cdsPagamentosFORMA_PAGTO_DESC: TIBStringField;
    cdsPagamentosVALOR_BAIXA: TIBBCDField;
    cdsPagamentosNUMERO_CHEQUE: TIBStringField;
    cdsPagamentosBANCO: TSmallintField;
    cdsPagamentosBCO_NOME: TIBStringField;
    cdsPagamentosDOCUMENTO_BAIXA: TIBStringField;
    updPagamentos: TIBUpdateSQL;
    dtsPagamentos: TDataSource;
    dtsBanco: TDataSource;
    dtsFormaPagto: TDataSource;
    lblDataPagto: TLabel;
    dbValorPago: TDBEdit;
    lblValorPago: TLabel;
    lblFormaPagto: TLabel;
    dbFormaPagto: TDBLookupComboBox;
    lblDocBaixa: TLabel;
    dbDocBaixa: TDBEdit;
    lblBanco: TLabel;
    dbBanco: TDBLookupComboBox;
    lblHistorico: TLabel;
    dbHistorico: TDBMemo;
    cdsPagamentosUSUARIO: TIBStringField;
    lblInforme: TLabel;
    tmrAlerta: TTimer;
    btnConfirmar: TcxButton;
    btnCancelar: TcxButton;
    dbDataPagto: TJvDBDateEdit;
    cdsPagamentosEMPRESA: TIBStringField;
    cdsPagamentosBANCO_FEBRABAN: TIBStringField;
    dtsBancoFebraban: TDataSource;
    lblNumeroCheque: TLabel;
    dbNumeroCheque: TJvDBComboEdit;
    cdsPagamentosCONTROLE_CHEQUE: TIntegerField;
    fdQryBanco: TFDQuery;
    fdQryFormaPagto: TFDQuery;
    fdQryBancoFebraban: TFDQuery;
    procedure dtsPagamentosStateChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnConfirmarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure cdsPagamentosNewRecord(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure tmrAlertaTimer(Sender: TObject);
    procedure dbNumeroChequeButtonClick(Sender: TObject);
    procedure dtsPagamentosDataChange(Sender: TObject; Field: TField);
  private
    { Private declarations }
    CxContaCorrente : Integer;
  public
    { Public declarations }
    procedure RegistrarRotinaSistema; override;
  end;

(*
  Tabelas:
  - TBCONTPAG
  - TBEMPRESA
  - TBFORNECEDOR
  - TBCONTPAG_BAIXA
  - TBBANCO_BOLETO
  - TBBANCO
  - TBFORMPAGTO

  Views:
  - VW_CONDICAOPAGTO

  Procedures:

*)

var
  frmGeEfetuarPagtoPAG: TfrmGeEfetuarPagtoPAG;

  function PagamentoConfirmado(const AOwner : TComponent; const Empresa : String;
    const Ano, Lancamento, FormaPagto : Integer; const Fornecedor : String;
    var ContaCorrente : Integer; var DataPagto : TDateTime; var APagar : Currency) : Boolean;

implementation

uses
  UDMBusiness, UGeControleCheque;

{$R *.dfm}

function PagamentoConfirmado(const AOwner : TComponent; const Empresa : String;
  const Ano, Lancamento, FormaPagto : Integer; const Fornecedor : String;
  var ContaCorrente : Integer; var DataPagto : TDateTime; var APagar : Currency) : Boolean;
var
  frm : TfrmGeEfetuarPagtoPAG;
begin
  frm := TfrmGeEfetuarPagtoPAG.Create(AOwner);
  try

    with frm do
    begin
      edAnoLanc.Text    := FormatFloat('0000', Ano);
      edNumLanc.Text    := FormatFloat('###0000000', Lancamento);
      edFornecedor.Text := Fornecedor;

      cdsPagamentos.Close;

      with cdsPagamentos, SelectSQL do
      begin
        Add('where p.Anolanc = ' + IntToStr(Ano));
        Add('  and p.Numlanc = ' + IntToStr(Lancamento));
      end;

      cdsPagamentos.Open;
      cdsPagamentos.Append;
      cdsPagamentosEMPRESA.AsString       := Empresa;
      cdsPagamentosFORMA_PAGTO.AsInteger  := FormaPagto;
      cdsPagamentosVALOR_BAIXA.AsCurrency := APagar;
      cdsPagamentosCONTROLE_CHEQUE.Clear;

      Result := (ShowModal = mrOk);

      if ( Result ) then
      begin
        DataPagto     := cdsPagamentosDATA_PAGTO.AsDateTime;
        ContaCorrente := cxContaCorrente;

        SetMovimentoCaixa(
          gUsuarioLogado.Login,
          cdsPagamentosDATA_PAGTO.AsDateTime + Time,
          cdsPagamentosFORMA_PAGTO.AsInteger,
          cdsPagamentosANOLANC.AsInteger,
          cdsPagamentosNUMLANC.AsInteger,
          cdsPagamentosSEQ.AsInteger,
          cdsPagamentosVALOR_BAIXA.AsCurrency,
          tmcxDebito);
      end;
    end;

  finally
    frm.Free;
  end;
end;

procedure TfrmGeEfetuarPagtoPAG.dbNumeroChequeButtonClick(Sender: TObject);
var
  aCheque : TChequeBaixa;
begin
  if not (cdsPagamentos.State in [dsEdit, dsInsert]) then
    cdsPagamentos.Edit;

  if SelecionarChequeBaixa(Self, aCheque) then
  begin
    cdsPagamentosCONTROLE_CHEQUE.AsInteger := aCheque.Codigo;
    cdsPagamentosNUMERO_CHEQUE.AsString    := aCheque.Numero;
    cdsPagamentosBANCO_FEBRABAN.AsString   := aCheque.Banco;
    cdsPagamentosVALOR_BAIXA.AsCurrency    := aCheque.Valor;
    cdsPagamentosDATA_PAGTO.AsDateTime     := aCheque.Data;
  end;
end;

procedure TfrmGeEfetuarPagtoPAG.dtsPagamentosDataChange(Sender: TObject;
  Field: TField);
begin
  if (Field = cdsPagamentosFORMA_PAGTO) then
    dbNumeroCheque.Enabled := (Pos('CHEQUE', AnsiUpperCase(dbFormaPagto.Text)) > 0);
end;

procedure TfrmGeEfetuarPagtoPAG.dtsPagamentosStateChange(Sender: TObject);
begin
  inherited;
  dtsPagamentos.AutoEdit := ( cdsPagamentos.State in [dsEdit, dsInsert] );
end;

procedure TfrmGeEfetuarPagtoPAG.FormCreate(Sender: TObject);
begin
  inherited;
  CarregarListaDB(fdQryBanco);
  CarregarListaDB(fdQryFormaPagto);
  CarregarListaDB(fdQryBancoFebraban);

  CxContaCorrente := 0;
end;

procedure TfrmGeEfetuarPagtoPAG.btnConfirmarClick(Sender: TObject);
var
  CxAno    ,
  CxNumero ,
  iBancoBoleto : Integer;
begin
  inherited;
  CxAno    := 0;
  CxNumero := 0;

  if ( cdsPagamentos.State in [dsEdit, dsInsert] ) then
  begin
    if ( cdsPagamentosVALOR_BAIXA.AsCurrency <= 0 ) then
    begin
      ShowWarning('Favor informar o valor pago!');
      dbValorPago.SetFocus;
    end
    else
    if ( cdsPagamentosDATA_PAGTO.AsDateTime > GetDateTimeDB ) then
    begin
      ShowWarning('N�o � permitido do registro de pagamentos futuros!');
      dbDataPagto.SetFocus;
    end
    else
    if ( (Pos('CHEQUE', AnsiUpperCase(dbFormaPagto.Text)) > 0) and (Trim(cdsPagamentosNUMERO_CHEQUE.AsString) = EmptyStr) ) then
    begin
      ShowWarning('Favor informar o N�mero do Cheque!');
      if dbNumeroCheque.Visible and dbNumeroCheque.Enabled then
        dbNumeroCheque.SetFocus;
    end
    else
//    if ( (Trim(cdsPagamentosNUMERO_CHEQUE.AsString) <> EmptyStr) and (cdsPagamentosBANCO.AsInteger = 0) ) then
    if ( (Trim(cdsPagamentosNUMERO_CHEQUE.AsString) <> EmptyStr) and (Trim(cdsPagamentosBANCO_FEBRABAN.AsString) = EmptyStr) ) then
    begin
      ShowWarning('Favor informar o Banco!');
      dbBanco.SetFocus;
    end
    else
    if ( Trim(cdsPagamentosHISTORICO.AsString) = EmptyStr ) then
    begin
      ShowWarning('Favor informar hist�rico (referente �) do pagamento!');
      dbHistorico.SetFocus;
    end
    else
    begin
      if ( not CaixaAberto(cdsPagamentosEMPRESA.AsString, gUsuarioLogado.Login, cdsPagamentosDATA_PAGTO.AsDateTime, cdsPagamentosFORMA_PAGTO.AsInteger, CxAno, CxNumero, CxContaCorrente) ) then
      begin
        ShowWarning('N�o existe caixa aberto para o usu�rio na forma de pagamento deste movimento.');
        Exit;
      end;

      if ( ShowConfirm('Confirma a efetua��o do pagamento?') ) then
      begin
        cdsPagamentosHISTORICO.AsString := AnsiUpperCase(Trim(cdsPagamentosHISTORICO.AsString));

        if (Copy(cdsPagamentosHISTORICO.AsString, Length(cdsPagamentosHISTORICO.AsString), 1) = '.') then
          cdsPagamentosHISTORICO.AsString := Copy(cdsPagamentosHISTORICO.AsString, 1, Length(cdsPagamentosHISTORICO.AsString) - 1);

        iBancoBoleto := GetBancoBoletoCodigo(cdsPagamentosEMPRESA.AsString, Trim(cdsPagamentosBANCO_FEBRABAN.AsString));
        if iBancoBoleto > 0 then
          cdsPagamentosBANCO.AsInteger := iBancoBoleto
        else
          cdsPagamentosBANCO.Clear;

        cdsPagamentos.Post;
        cdsPagamentos.ApplyUpdates;
        CommitTransaction;

        ModalResult := mrOk;
      end;
    end;
  end;
end;

procedure TfrmGeEfetuarPagtoPAG.btnCancelarClick(Sender: TObject);
begin
  inherited;
  Self.Close;
end;

procedure TfrmGeEfetuarPagtoPAG.cdsPagamentosNewRecord(DataSet: TDataSet);
begin
  inherited;
  cdsPagamentosANOLANC.Value    := StrToInt(edAnoLanc.Text);
  cdsPagamentosNUMLANC.Value    := StrToInt(edNumLanc.Text);
  cdsPagamentosSEQ.Value        := GetNextID('TBCONTPAG_BAIXA', 'SEQ', 'where anolanc = ' + edAnoLanc.Text + ' and numlanc = ' + edNumLanc.Text);
  cdsPagamentosDATA_PAGTO.Value := Date;
  cdsPagamentosUSUARIO.Value    := GetUserApp;
  cdsPagamentosFORMA_PAGTO.Value      := GetFormaPagtoIDDefault;
  cdsPagamentosFORMA_PAGTO_DESC.Value := GetFormaPagtoNomeDefault;
end;

procedure TfrmGeEfetuarPagtoPAG.FormShow(Sender: TObject);
begin
  inherited;
  if ( dtsPagamentos.AutoEdit ) then
    dbDataPagto.SetFocus;
end;

procedure TfrmGeEfetuarPagtoPAG.RegistrarRotinaSistema;
begin
  ;
end;

procedure TfrmGeEfetuarPagtoPAG.tmrAlertaTimer(Sender: TObject);
begin
  if (lblInforme.Font.Color = clRed) then
    lblInforme.Font.Color := clBlue
  else
  if (lblInforme.Font.Color = clBlue) then
    lblInforme.Font.Color := clRed;
end;

end.
