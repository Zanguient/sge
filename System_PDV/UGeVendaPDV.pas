unit UGeVendaPDV;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UGrPadrao, ExtCtrls, dxGDIPlusClasses, StdCtrls, DBCtrls, Grids,
  DBGrids, DB, ActnList, IBCustomDataSet, IBUpdateSQL;

type
  TfrmGeVendaPDV = class(TfrmGrPadrao)
    PnlInformeGeral: TPanel;
    imgEmpresa: TImage;
    PnlVendaCabecalho: TPanel;
    lblNomeVendedor: TLabel;
    imgNomeVendedor: TImage;
    imgNomeCliente: TImage;
    lblNomeCliente: TLabel;
    imgNomeFormaPagto: TImage;
    lblNomeFormaPagto: TLabel;
    PnlVendaProduto: TPanel;
    lblData: TLabel;
    lblHora: TLabel;
    tmrContador: TTimer;
    lblProdutoCodigo: TLabel;
    edProdutoCodigo: TEdit;
    dbNomeProduto: TDBText;
    dbValorProduto: TDBText;
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    dbgDados: TDBGrid;
    Label6: TLabel;
    dbValorTotal: TDBText;
    Bevel1: TBevel;
    Label7: TLabel;
    dbValorDesconto: TDBText;
    Bevel2: TBevel;
    Label8: TLabel;
    dbValorAPagar: TDBText;
    dbQuantidade: TDBText;
    dbUnidade: TDBText;
    dbTotalProduto: TDBText;
    Label9: TLabel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    Bevel6: TBevel;
    Bevel7: TBevel;
    dtsVenda: TDataSource;
    edNomeVendedor: TLabel;
    edNomeCliente: TLabel;
    edNomeFormaPagto: TLabel;
    actVenda: TActionList;
    actCarregarVendedor: TAction;
    actCarregarCliente: TAction;
    actCarregarFormaPagto: TAction;
    actSair: TAction;
    dtsItem: TDataSource;
    dtsFormaPagto: TDataSource;
    Label2: TLabel;
    actIniciarVenda: TAction;
    actCancelar: TAction;
    actCarregarProduto: TAction;
    dtsCFOP: TDataSource;
    dtsProduto: TDataSource;
    actDescontoCupom: TAction;
    actCarregarOrcamento: TAction;
    Label10: TLabel;
    pnlCaixaLivre: TPanel;
    actGravarOrcamento: TAction;
    procedure tmrContadorTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edProdutoCodigoKeyPress(Sender: TObject; var Key: Char);
    procedure actSairExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ControlEditEnter(Sender: TObject);
    procedure actCarregarClienteExecute(Sender: TObject);
    procedure actIniciarVendaExecute(Sender: TObject);
    procedure dtsVendaDataChange(Sender: TObject; Field: TField);
    procedure actCancelarExecute(Sender: TObject);
    procedure actCarregarVendedorExecute(Sender: TObject);
    procedure actCarregarProdutoExecute(Sender: TObject);
    procedure dbgDadosDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure actDescontoCupomExecute(Sender: TObject);
    procedure actCarregarOrcamentoExecute(Sender: TObject);
    procedure dtsVendaStateChange(Sender: TObject);
    procedure actGravarOrcamentoExecute(Sender: TObject);
  private
    { Private declarations }
    sNomeTabela    ,
    sCampoCodigo   ,
    sGeneratorName : String;
    procedure IniciarCupomCabecalho;
    procedure IniciarCupomProduto;
    procedure CarregarVenda(const Empresa : String; const Ano, Controle : Integer);
    procedure CarregarItens(const Empresa : String; const Ano, Controle : Integer);
    procedure CarregarFormaPagto(const Empresa : String; const Ano, Controle : Integer);
    procedure CarregarDadosCFOP( iCodigo : Integer );

    procedure ZerarFormaPagto;
    procedure InserirProduto;

    function DataSetVenda : TDataSet;
    function DataSetItens : TDataSet;
    function DataSetFormaPagto : TDataSet;
    function EstaEditando : Boolean;
    function VendaEstaAberta : Boolean;
    function VendaEstaFinalizada : Boolean;
  public
    { Public declarations }
    procedure RegistrarRotinaSistema; override;
  end;

var
  frmGeVendaPDV: TfrmGeVendaPDV;

implementation

uses
  UConstantesDGE, UFuncoes, DateUtils, UDMBusiness, UDMCupom,
  UGeCliente, UGeVendedor, UGeProduto, UGeVendaPDVDesconto, UGeVendaPDVOrcamento;

{$R *.dfm}

const
  COD_MLT = '*';

{ TfrmGeVendaPDV }

procedure TfrmGeVendaPDV.RegistrarRotinaSistema;
begin
  ;
end;

procedure TfrmGeVendaPDV.IniciarCupomCabecalho;
begin
  Self.Caption := 'Vendas PDV';
  
  edNomeVendedor.Tag     := GetVendedorIDDefault;
  edNomeVendedor.Caption := GetVendedorNomeDefault;

  edNomeCliente.Tag     := CONSUMIDOR_FINAL_CODIGO;
  edNomeCliente.Caption := CONSUMIDOR_FINAL_NOME;
  edNomeCliente.Hint    := CONSUMIDOR_FINAL_CNPJ;

  edNomeFormaPagto.Tag     := GetFormaPagtoIDDefault;
  edNomeFormaPagto.Caption := GetFormaPagtoNomeDefault;

  CarregarVenda(GetEmpresaIDDefault, 0, 0);
end;

procedure TfrmGeVendaPDV.tmrContadorTimer(Sender: TObject);
begin
  lblData.Caption := FormatDateTime('dd/mm/yyyy', Date);
  lblHora.Caption := FormatDateTime('hh:mm:ss', Time);

  Case pnlCaixaLivre.Font.Color of
    clBlack : pnlCaixaLivre.Font.Color := clBlue;
    clBlue  : pnlCaixaLivre.Font.Color := clRed;
    clRed   : pnlCaixaLivre.Font.Color := clBlack;
  end;
end;

procedure TfrmGeVendaPDV.IniciarCupomProduto;
begin
  edProdutoCodigo.Text := '1' + COD_MLT;

  if edProdutoCodigo.Visible and edProdutoCodigo.Enabled then
  begin
    edProdutoCodigo.SetFocus;
    edProdutoCodigo.SelStart := Length(edProdutoCodigo.Text);
  end;
end;

procedure TfrmGeVendaPDV.FormShow(Sender: TObject);
begin
  if ( (sGeneratorName <> EmptyStr) and (sNomeTabela <> EmptyStr) and (sCampoCodigo <> EmptyStr) ) then
    UpdateSequence(sGeneratorName, sNomeTabela, sCampoCodigo, 'where Ano = ' + FormatFloat('0000', YearOf(Date)) );

  inherited;

  IniciarCupomCabecalho;
  IniciarCupomProduto;
end;

procedure TfrmGeVendaPDV.edProdutoCodigoKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not EstaEditando then
    Abort
  else  
  if not (Key in [',', '0'..'9', '*', #8, #13]) then
  begin
    Key := #0;
    Abort;
  end;
end;

procedure TfrmGeVendaPDV.actSairExecute(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmGeVendaPDV.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ( Key = VK_F2 ) then
    actCarregarVendedor.Execute
  else
  if ( Key = VK_F3 ) then
    actCarregarCliente.Execute
  else
  if ( Key = VK_F4 ) then
    actCarregarFormaPagto.Execute
  else
  if ( Key = VK_F6 ) then
    actCarregarProduto.Execute
  else
  if ( Key = VK_F7 ) then
    actIniciarVenda.Execute
  else
  if ( Key = VK_F8 ) then
    actCarregarOrcamento.Execute
  else
  if ( Key = VK_F9 ) then
    actDescontoCupom.Execute
  else
  if ( Key = VK_F11 ) then
    actCancelar.Execute
  else
  if ( Key = VK_F12 ) then
    actGravarOrcamento.Execute
  else
  if ( (Key = VK_RETURN) and edProdutoCodigo.Focused ) then
    InserirProduto
  else
  if ( Key = 83 ) then // Tela S
    actSair.Execute
  else
    inherited;
end;

procedure TfrmGeVendaPDV.FormCreate(Sender: TObject);
begin
  if not Assigned(DMCupom) then
    DMCupom := TDMCupom.Create(Application);

  sNomeTabela    := 'TBVENDAS';
  sCampoCodigo   := 'Codcontrol';
  sGeneratorName := 'GEN_VENDAS_CONTROLE_' + FormatFloat('0000', YearOf(GetDateDB));

  inherited;
end;

function TfrmGeVendaPDV.DataSetVenda: TDataSet;
begin
  Result := dtsVenda.DataSet;
end;

procedure TfrmGeVendaPDV.CarregarVenda(const Empresa: String; const Ano,
  Controle: Integer);
begin
  with TIBDataSet(DataSetVenda) do
  begin
    Close;
    ParamByName('empresa').AsString   := Empresa;
    ParamByName('ano').AsInteger      := Ano;
    ParamByName('controle').AsInteger := Controle;
    Open;
  end;

  CarregarItens(Empresa, Ano, Controle);
  CarregarFormaPagto(Empresa, Ano, Controle);

  if ( DataSetVenda.FieldByName('ano').AsInteger > 0 ) then
  begin
    edNomeVendedor.Tag     := DataSetVenda.FieldByName('VENDEDOR_COD').AsInteger;
    edNomeVendedor.Caption := GetVendedorNome( edNomeVendedor.Tag );

    edNomeCliente.Tag     := DataSetVenda.FieldByName('CODCLIENTE').AsInteger;
    edNomeCliente.Caption := GetClienteNome( edNomeCliente.Tag );
    edNomeCliente.Hint    := DataSetVenda.FieldByName('CODCLI').AsString;

    edNomeFormaPagto.Tag     := DataSetFormaPagto.FieldByName('FORMAPAGTO_COD').AsInteger;
    edNomeFormaPagto.Caption := GetFormaPagtoNome( edNomeFormaPagto.Tag );
  end;

  if ( DataSetVenda.FieldByName('CODCONTROL').AsInteger > 0 ) then
    Self.Caption := 'Vendas PDV | No. ' + DataSetVenda.FieldByName('ANO').AsString + '/' + FormatFloat('###00000', DataSetVenda.FieldByName('CODCONTROL').AsInteger)
  else
    Self.Caption := 'Vendas PDV';
end;

procedure TfrmGeVendaPDV.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := not EstaEditando;

  if not CanClose then
    ShowWarning('Venda em aberto!!!');
end;

procedure TfrmGeVendaPDV.ControlEditEnter(Sender: TObject);
begin
  inherited;
  if ( Sender = edProdutoCodigo ) then
    edProdutoCodigo.SelStart := Length(edProdutoCodigo.Text);
end;

procedure TfrmGeVendaPDV.actCarregarClienteExecute(Sender: TObject);
var
  iCodigo : Integer;
  sCNPJ ,
  sNome : String;
  bBloqueado : Boolean;
  sBloqueado : String;
begin
  if ( SelecionarCliente(Self, iCodigo, sCNPJ, sNome, bBloqueado, sBloqueado) ) then
  begin
    if bBloqueado then
      ShowWarning('Cliente selecionado se encontra bloqueado!' + #13#13 + 'Motivo:' + #13 + sBloqueado);

    edNomeCliente.Tag     := iCodigo;
    edNomeCliente.Caption := sNome;
    edNomeCliente.Hint    := sCNPJ;
    edNomeCliente.Enabled := not bBloqueado;

    if VendaEstaAberta and (not EstaEditando) then
      DataSetVenda.Edit;

    if EstaEditando then
      with DataSetVenda do
      begin
        if bBloqueado then
        begin
          FieldByName('BLOQUEADO').AsInteger       := 1;
          FieldByName('BLOQUEADO_MOTIVO').AsString := sBloqueado;
        end
        else
        begin
          FieldByName('BLOQUEADO').AsInteger       := 0;
          FieldByName('BLOQUEADO_MOTIVO').AsString := EmptyStr;
        end;

        FieldByName('CODCLIENTE').AsInteger := iCodigo;
        FieldByName('CODCLI').AsString      := sCNPJ;
        FieldByName('NOME').AsString        := sNome;
      end;

  end;
end;

function TfrmGeVendaPDV.EstaEditando: Boolean;
begin
  Result := (DataSetVenda.State in [dsEdit, dsInsert]);
end;

procedure TfrmGeVendaPDV.actIniciarVendaExecute(Sender: TObject);
var
  iAno ,
  iNum : Integer;
begin
  if ( EstaEditando ) then
    ShowWarning('J� existe uma venda iniciada!' + #13 + 'Favor finaliz�-la.')
  else
    with DataSetVenda do
    begin
      iAno := YearOf(GetDateDB);
      iNum := GetGeneratorID(sGeneratorName);

      Append;

      FieldByName('CODEMP').Value         := GetEmpresaIDDefault;
      FieldByName('ANO').AsInteger        := iAno;
      FieldByName('CODCONTROL').AsInteger := iNum;

      FieldByName('DTVENDA').Value        := GetDateTimeDB;
      FieldByName('CFOP').Value           := GetCfopIDDefault;
      FieldByName('VENDA_PRAZO').Value    := 0;
      FieldByName('STATUS').Value         := STATUS_VND_AND;
      FieldByName('TOTALVENDA_BRUTA').Value  := 0;
      FieldByName('DESCONTO').Value          := 0;
      FieldByName('DESCONTO_CUPOM').Value    := 0;
      FieldByName('TOTALVENDA').Value        := 0;
      FieldByName('GERAR_ESTOQUE_CLIENTE').Value := 0;
      FieldByName('NFE_ENVIADA').Value           := 0;
      FieldByName('NFE_MODALIDADE_FRETE').Value  := MODALIDADE_FRETE_SEMFRETE;
      FieldByName('USUARIO').Value               := GetUserApp;

      FieldByName('VENDEDOR_COD').Value   := edNomeVendedor.Tag;
      FieldByName('FORMAPAG').Value       := edNomeFormaPagto.Caption;

      FieldByName('CODCLIENTE').Value := edNomeCliente.Tag;
      FieldByName('CODCLI').Value     := edNomeCliente.Hint;
      FieldByName('NOME').Value       := edNomeCliente.Caption;

      if (AnsiUpperCase(Trim(FieldByName('NOME').AsString)) <> CONSUMIDOR_FINAL_NOME) then
      begin
        FieldByName('CODCLIENTE').Clear;
        FieldByName('CODCLI').Clear;
        FieldByName('NOME').Clear;
      end;

      FieldByName('FORMAPAGTO_COD').Clear;
      FieldByName('CONDICAOPAGTO_COD').Clear;
      FieldByName('SERIE').Clear;
      FieldByName('NFE').Clear;
      FieldByName('LOTE_NFE_ANO').Clear;
      FieldByName('LOTE_NFE_NUMERO').Clear;
      FieldByName('NFE_TRANSPORTADORA').Clear;

      CarregarDadosCFOP( FieldByName('CFOP').AsInteger );

      CarregarItens(
        FieldByName('CODEMP').AsString,
        FieldByName('ANO').AsInteger,
        FieldByName('CODCONTROL').AsInteger );
      CarregarFormaPagto(
        FieldByName('CODEMP').AsString,
        FieldByName('ANO').AsInteger,
        FieldByName('CODCONTROL').AsInteger );

      ZerarFormaPagto;
      IniciarCupomProduto;
    end;
end;

procedure TfrmGeVendaPDV.ZerarFormaPagto;
begin
  with DataSetFormaPagto do
  begin
    First;

    while not Eof do
      Delete;

    // Adicionar forma de pagamento inicial

    Append;

    FieldByName('ANO_VENDA').Value         := DataSetVenda.FieldByName('ANO').Value;
    FieldByName('CONTROLE_VENDA').Value    := DataSetVenda.FieldByName('CODCONTROL').Value;
    FieldByName('FORMAPAGTO_COD').Value    := edNomeFormaPagto.Tag;
    FieldByName('CONDICAOPAGTO_COD').Value := GetCondicaoPagtoIDDefault;
    FieldByName('VALOR_FPAGTO').Value      := dbValorAPagar.Field.AsCurrency;
    FieldByName('VENDA_PRAZO').Value       := 0;

    if not EstaEditando then
      DataSetVenda.Edit;

    DataSetVenda.FieldByName('VENDA_PRAZO').AsInteger := 0;
  end;
end;

function TfrmGeVendaPDV.DataSetFormaPagto: TDataSet;
begin
  Result := dtsFormaPagto.DataSet;
end;

function TfrmGeVendaPDV.DataSetItens: TDataSet;
begin
  Result := dtsItem.DataSet;
end;

procedure TfrmGeVendaPDV.dtsVendaDataChange(Sender: TObject;
  Field: TField);
begin
  if ( Field = DataSetVenda.FieldByName('CODCONTROL') ) then
    Self.Caption := 'Vendas PDV | No. ' + DataSetVenda.FieldByName('ANO').AsString + '/' + FormatFloat('###00000', DataSetVenda.FieldByName('CODCONTROL').AsInteger);
end;

procedure TfrmGeVendaPDV.CarregarItens(const Empresa: String; const Ano,
  Controle: Integer);
begin
  with TIBDataSet(DataSetItens) do
  begin
    Close;
    ParamByName('empresa').AsString   := Empresa;
    ParamByName('ano').AsInteger      := Ano;
    ParamByName('controle').AsInteger := Controle;
    Open;
  end;
end;

procedure TfrmGeVendaPDV.CarregarFormaPagto(const Empresa: String;
  const Ano, Controle: Integer);
begin
  with TIBDataSet(DataSetFormaPagto) do
  begin
    Close;
    ParamByName('ano').AsInteger      := Ano;
    ParamByName('controle').AsInteger := Controle;
    Open;
  end;
end;

procedure TfrmGeVendaPDV.actCancelarExecute(Sender: TObject);
begin
  if EstaEditando then
    DataSetVenda.Cancel;

  with DataSetVenda do
    if ( RecordCount = 0 ) then
    begin
      CarregarVenda(GetEmpresaIDDefault, 0, 0);
      IniciarCupomCabecalho;
      IniciarCupomProduto;
    end
    else
    begin
      if VendaEstaAberta then
        if ShowConfirmation('Confirma o cancelamento do or�amento?') then
        begin
          TIBDataSet(DataSetVenda).Delete;
          TIBDataSet(DataSetVenda).ApplyUpdates;
        end;

      CarregarVenda(GetEmpresaIDDefault, 0, 0);
      IniciarCupomCabecalho;
      IniciarCupomProduto;
    end;
end;

procedure TfrmGeVendaPDV.actCarregarVendedorExecute(Sender: TObject);
var
  iCodigo : Integer;
  sNome   : String;
begin
  if SelecionarVendedorPDV(Self, iCodigo, sNome) then
  begin
    edNomeVendedor.Tag     := iCodigo;
    edNomeVendedor.Caption := sNome;

    if VendaEstaAberta and (not EstaEditando) then
      DataSetVenda.Edit;

    if EstaEditando then
      DataSetVenda.FieldByName('VENDEDOR_COD').AsInteger := iCodigo;
  end;

end;

procedure TfrmGeVendaPDV.actCarregarProdutoExecute(Sender: TObject);
var
  iCodigo    : Integer;
  sCodigoAlfa,
  sCodigoEAN ,
  sNome      ,
  sUnidade   : String;
  cQuantidade ,
  cValorVenda : Currency;
begin
  if not EstaEditando then
    ShowWarning('Favor iniciar o processo de venda!')
  else
    if SelecionarProduto(Self, iCodigo, sCodigoAlfa, sCodigoEAN, sNome, sUnidade, cValorVenda) then
    begin
      if ( Pos(COD_MLT, edProdutoCodigo.Text) = 0 ) then
        cQuantidade := 1
      else
        cQuantidade := StrToCurrDef(Copy(edProdutoCodigo.Text, 1, Pos(COD_MLT, edProdutoCodigo.Text) - 1), 1);

      edProdutoCodigo.Text := Trim(Copy(edProdutoCodigo.Text, 1, Pos(COD_MLT, edProdutoCodigo.Text))) + Trim(IfThen(sCodigoEAN = EmptyStr, sCodigoAlfa, sCodigoEAN));
      edProdutoCodigo.SetFocus;
      edProdutoCodigo.SelStart := Length(edProdutoCodigo.Text);
      dbNomeProduto.Caption    := sNome;
      dbUnidade.Caption        := sUnidade;
      dbQuantidade.Caption     := FormatFloat(',0.###', cQuantidade);
      dbValorProduto.Caption   := FormatFloat(',0.00', cValorVenda);
      dbTotalProduto.Caption   := FormatFloat(',0.00', cValorVenda * cQuantidade);
    end;
end;

procedure TfrmGeVendaPDV.CarregarDadosCFOP(iCodigo: Integer);
begin
  with TIBDataSet(dtsCFOP.DataSet) do
  begin
    Close;
    ParamByName('Cfop_cod').AsInteger := iCodigo;
    Open;
  end;
end;

procedure TfrmGeVendaPDV.InserirProduto;

  procedure GerarSequencial(var Seq : Integer);
  begin
    if (DataSetItens.State in [dsEdit, dsInsert]) then
      DataSetItens.Cancel;

    Seq := DataSetItens.RecordCount + 1;
    if ( DataSetItens.Locate('SEQ', Seq, []) ) then
      Seq := Seq + 1;
  end;


  procedure GetToTais(var Total_Bruto, Total_Desconto, Total_Liquido: Currency);
  var
    Item : Integer;
  begin
    Item := DataSetItens.FieldByName('SEQ').AsInteger;
    Total_Bruto    := 0.0;
    Total_desconto := 0.0;
    Total_Liquido  := 0.0;

    DataSetItens.First;

    while not DataSetItens.Eof do
    begin
      Total_Bruto    := Total_Bruto    + DataSetItens.FieldByName('TOTAL_BRUTO').AsCurrency;
      Total_desconto := Total_desconto + DataSetItens.FieldByName('TOTAL_DESCONTO').AsCurrency;

      DataSetItens.Next;
    end;

    Total_Liquido  := Total_Bruto - Total_desconto;

    DataSetItens.Locate('SEQ', Item, []);
  end;

var
  cDescontos    ,
  cTotalBruto   ,
  cTotalDesconto,
  cTotalLiquido : Currency;

  Sequencial,
  iCodigo   : Integer;
  sCodigo   : String;
  cQuantidade,
  cPrecoVND  : Currency;
begin
  if (not EstaEditando) and (DataSetVenda.FieldByName('STATUS').AsInteger = STATUS_VND_AND) then
    DataSetVenda.Edit;

  if EstaEditando then
    with DataSetItens do
    begin

      // Iniciar Csmpos com valores padr�es

      GerarSequencial(Sequencial);
      Append;

      FieldByName('SEQ').Value := Sequencial;

      FieldByName('ANO').Value        := DataSetVenda.FieldByName('ANO').Value;
      FieldByName('CODCONTROL').Value := DataSetVenda.FieldByName('CODCONTROL').Value;
      FieldByName('DTVENDA').Value    := DataSetVenda.FieldByName('DTVENDA').Value;
      FieldByName('CODEMP').Value     := DataSetVenda.FieldByName('CODEMP').Value;
      FieldByName('CODCLI').Value     := DataSetVenda.FieldByName('CODCLI').Value;
      FieldByName('CODCLIENTE').Value := DataSetVenda.FieldByName('CODCLIENTE').Value;

      if ( DataSetVenda.FieldByName('CFOP').IsNull ) then
      begin
        FieldByName('CFOP_COD').Value        := GetCfopIDDefault;
        FieldByName('CFOP_DESCRICAO').Value  := GetCfopNomeDefault;
      end
      else
      begin
        FieldByName('CFOP_COD').Assign( DataSetVenda.FieldByName('CFOP') );
        FieldByName('CFOP_DESCRICAO').Assign( dtsCFOP.DataSet.FieldByName('CFOP_DESCRICAO') );
      end;

      FieldByName('CST').Value             := '000';
      FieldByName('PUNIT_PROMOCAO').Value  := 0.0;
      FieldByName('ALIQUOTA').Value        := 0;
      FieldByName('ALIQUOTA_PIS').Value    := 0.0;
      FieldByName('ALIQUOTA_COFINS').Value := 0.0;
      FieldByName('QTDE').Value            := 1;
      FieldByName('QTDEFINAL').Value       := 0;
      FieldByName('DESCONTO').Value        := 0;
      FieldByName('DESCONTO_VALOR').Value  := 0;
      FieldByName('PERCENTUAL_REDUCAO_BC').Value := 0.0;

      // Carregar dados do Produto

      try
        if Length(Trim(Copy(edProdutoCodigo.Text, Pos(COD_MLT, edProdutoCodigo.Text) + 1, Length(edProdutoCodigo.Text)))) <= 7 then
        begin
          iCodigo := StrToInt( Copy(edProdutoCodigo.Text, Pos(COD_MLT, edProdutoCodigo.Text) + 1, Length(edProdutoCodigo.Text)) );
          sCodigo := 'XXXXXXXXXXXXX'
        end
        else
        begin
          iCodigo := 0;
          sCodigo := Copy(edProdutoCodigo.Text, Pos(COD_MLT, edProdutoCodigo.Text) + 1, Length(edProdutoCodigo.Text));
        end;
      except
        if (DataSetItens.State in [dsEdit, dsInsert]) then
          DataSetItens.Cancel;
          
        ShowWarning('Favor informar c�digo do produto!');
        Abort;
      end;

      TIBDataSet(dtsProduto.DataSet).Close;
      TIBDataSet(dtsProduto.DataSet).ParamByName('Codigo').AsInteger     := iCodigo;
      TIBDataSet(dtsProduto.DataSet).ParamByName('CodigoBarra').AsString := sCodigo;
      TIBDataSet(dtsProduto.DataSet).Open;

      if TIBDataSet(dtsProduto.DataSet).IsEmpty then
      begin
        Cancel;
        ShowWarning('C�digo do produto n�o cadastrado!');
        Exit;
      end;

      if ( Pos(COD_MLT, edProdutoCodigo.Text) = 0 ) then
        cQuantidade := 1
      else
        cQuantidade := StrToCurrDef( StringReplace(Copy(edProdutoCodigo.Text, 1, Pos(COD_MLT, edProdutoCodigo.Text) - 1), ',', '.', [rfReplaceAll]), 1 );

      // Inserir dados do Produto encontrado

      FieldByName('CODPROD').AsString     := dtsProduto.DataSet.FieldByName('Cod').AsString;
      FieldByName('DESCRI').AsString      := dtsProduto.DataSet.FieldByName('Descri').AsString;
      FieldByName('UNP_SIGLA').AsString   := dtsProduto.DataSet.FieldByName('Unp_sigla').AsString;
      FieldByName('QTDE').Value           := cQuantidade;

      if ( dtsProduto.DataSet.FieldByName('Codunidade').AsInteger > 0 ) then
        FieldByName('UNID_COD').AsInteger   := dtsProduto.DataSet.FieldByName('Codunidade').AsInteger;

      if ( dtsProduto.DataSet.FieldByName('Codcfop').AsInteger > 0 ) then
        FieldByName('CFOP_COD').AsInteger := dtsProduto.DataSet.FieldByName('Codcfop').AsInteger;

      FieldByName('ALIQUOTA').AsCurrency              := dtsProduto.DataSet.FieldByName('Aliquota').AsCurrency;
      FieldByName('ALIQUOTA_CSOSN').AsCurrency        := dtsProduto.DataSet.FieldByName('Aliquota_csosn').AsCurrency;
      FieldByName('ALIQUOTA_PIS').AsCurrency          := dtsProduto.DataSet.FieldByName('Aliquota_pis').AsCurrency;
      FieldByName('ALIQUOTA_COFINS').AsCurrency       := dtsProduto.DataSet.FieldByName('Aliquota_cofins').AsCurrency;
      FieldByName('PERCENTUAL_REDUCAO_BC').AsCurrency := dtsProduto.DataSet.FieldByName('Percentual_reducao_BC').AsCurrency;

      if ( Trim(dtsProduto.DataSet.FieldByName('Cst').AsString) <> EmptyStr ) then
        FieldByName('CST').AsString       := dtsProduto.DataSet.FieldByName('Cst').AsString;

      if ( Trim(dtsProduto.DataSet.FieldByName('Csosn').AsString) <> EmptyStr ) then
        FieldByName('CSOSN').AsString     := dtsProduto.DataSet.FieldByName('Csosn').AsString;

      FieldByName('PUNIT').AsCurrency          := dtsProduto.DataSet.FieldByName('Preco').AsCurrency;
      FieldByName('PUNIT_PROMOCAO').AsCurrency := dtsProduto.DataSet.FieldByName('Preco_Promocao').AsCurrency;
      FieldByName('VALOR_IPI').AsCurrency      := dtsProduto.DataSet.FieldByName('Valor_ipi').AsCurrency;

      FieldByName('ESTOQUE').AsCurrency          := dtsProduto.DataSet.FieldByName('Qtde').AsCurrency;
      FieldByName('RESERVA').AsCurrency          := dtsProduto.DataSet.FieldByName('Reserva').AsCurrency;
      FieldByName('MOVIMENTA_ESTOQUE').AsInteger := dtsProduto.DataSet.FieldByName('Movimenta_Estoque').AsInteger;

      if ( FieldByName('PUNIT_PROMOCAO').AsCurrency > 0 ) then
      begin
        FieldByName('DESCONTO_VALOR').AsCurrency := FieldByName('PUNIT').AsCurrency - FieldByName('PUNIT_PROMOCAO').AsCurrency;
        FieldByName('DESCONTO').AsCurrency       := FieldByName('DESCONTO_VALOR').AsCurrency / FieldByName('PUNIT').AsCurrency * 100;
      end;

      if ( Trim(dtsCFOP.DataSet.FieldByName('Cfop_cst_padrao_saida').AsString) <> EmptyStr ) then
        FieldByName('CST').AsString := Trim(dtsCFOP.DataSet.FieldByName('Cfop_cst_padrao_saida').AsString);

      cPrecoVND := FieldByName('PUNIT').AsCurrency;

      FieldByName('DESCONTO_VALOR').AsCurrency := cPrecoVND * FieldByName('DESCONTO').AsCurrency / 100;
      FieldByName('PFINAL').AsCurrency         := cPrecoVND - FieldByName('DESCONTO_VALOR').AsCurrency;
      FieldByName('TOTAL_BRUTO').AsCurrency    := FieldByName('QTDE').AsCurrency * cPrecoVND;
      FieldByName('TOTAL_DESCONTO').AsCurrency := FieldByName('QTDE').AsCurrency * FieldByName('DESCONTO_VALOR').AsCurrency;
      FieldByName('TOTAL_LIQUIDO').AsCurrency  := FieldByName('TOTAL_BRUTO').AsCurrency - FieldByName('TOTAL_DESCONTO').AsCurrency;

      Post;

      IniciarCupomProduto;

      GetToTais(cTotalBruto, cTotalDesconto, cTotalLiquido);

      DataSetVenda.FieldByName('TOTALVENDA_BRUTA').AsCurrency := cTotalBruto;
      DataSetVenda.FieldByName('DESCONTO').AsCurrency         := cTotalDesconto;
      DataSetVenda.FieldByName('TOTALVENDA').AsCurrency       := cTotalLiquido - DataSetVenda.FieldByName('DESCONTO_CUPOM').AsCurrency;

      if ( DataSetFormaPagto.RecordCount <= 1 ) then
      begin
        if ( not (DataSetFormaPagto.State in [dsEdit, dsInsert]) ) then
          DataSetFormaPagto.Edit;

        DataSetFormaPagto.FieldByName('VALOR_FPAGTO').Value := cTotalLiquido;
      end;
    end;
end;

procedure TfrmGeVendaPDV.dbgDadosDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
  TDbGrid(Sender).Canvas.font.Color := clBlack;

  if odd(TDbGrid(Sender).DataSource.DataSet.RecNo) then
    TDBGrid(Sender).Canvas.Brush.Color:= clMenuBar
  else
    TDBGrid(Sender).Canvas.Brush.Color:= clCream;

  if gdSelected in State then
    with (Sender as TDBGrid).Canvas do
    begin
      Brush.Color :=  clMoneyGreen;
      FillRect(Rect);
      Font.Style  := [fsbold]
    end;

  TDbGrid(Sender).DefaultDrawDataCell(Rect, TDbGrid(Sender).columns[datacol].field, State);
end;

procedure TfrmGeVendaPDV.actDescontoCupomExecute(Sender: TObject);
var
  AForm : TfrmGeVendaPDVDesconto;
begin
  if not VendaEstaAberta then
    Exit;

  if not EstaEditando then
    DataSetVenda.Edit;

  if ( DataSetVenda.FieldByName('TOTALVENDA_BRUTA').AsCurrency = 0 ) then
  begin
    ShowWarning('Venda ainda n�o possui �tens para poder se aplicar descontos!');
    Exit;
  end;

  AForm := TfrmGeVendaPDVDesconto.Create(Self);
  try
    AForm.DescontoCupomOLD := DataSetVenda.FieldByName('DESCONTO_CUPOM').AsCurrency;

    if (AForm.ShowModal = mrOk) then
      DataSetVenda.FieldByName('DESCONTO_CUPOM').AsCurrency := AForm.DescontoAcrestimo
    else
      DataSetVenda.FieldByName('DESCONTO_CUPOM').AsCurrency := AForm.DescontoCupomOLD;

    DataSetVenda.FieldByName('TOTALVENDA').AsCurrency := DataSetVenda.FieldByName('TOTALVENDA_BRUTA').AsCurrency +
      DataSetVenda.FieldByName('DESCONTO').AsCurrency -
      DataSetVenda.FieldByName('DESCONTO_CUPOM').AsCurrency;
  finally
    AForm.Free;
  end;
end;

function TfrmGeVendaPDV.VendaEstaAberta: Boolean;
begin
  Result := (DataSetVenda.FieldByName('STATUS').AsInteger in [STATUS_VND_AND, STATUS_VND_ABR]);
end;

procedure TfrmGeVendaPDV.actCarregarOrcamentoExecute(Sender: TObject);
var
  AForm : TfrmGeVendaPDVOrcamento;
begin
  if EstaEditando then
  begin
    ShowWarning('Existe uma venda iniciada!' + #13 + 'Favor finaliz�-la.');
    Exit;
  end;

  AForm := TfrmGeVendaPDVOrcamento.Create(Self);
  try
    AForm.OrcamentoCod := DMCupom.GetUltimaVenda(GetEmpresaIDDefault
      , gUsuarioLogado.Login
      , AForm.OrcamentoAno
      , STATUS_VND_ABR);

    if AForm.OrcamentoCod = 0 then
      AForm.e2NumeroOrcamento.Text := EmptyStr;

    if ( AForm.ShowModal = mrOk ) then
      CarregarVenda(GetEmpresaIDDefault, AForm.OrcamentoAno, AForm.OrcamentoCod);
  finally
    AForm.Free;
  end;
end;

procedure TfrmGeVendaPDV.dtsVendaStateChange(Sender: TObject);
begin
  pnlCaixaLivre.Visible := dtsVenda.DataSet.IsEmpty and (not VendaEstaAberta);
end;

function TfrmGeVendaPDV.VendaEstaFinalizada: Boolean;
begin
  Result := (DataSetVenda.FieldByName('STATUS').AsInteger in [STATUS_VND_FIN, STATUS_VND_NFE]);
end;

procedure TfrmGeVendaPDV.actGravarOrcamentoExecute(Sender: TObject);
begin
  if VendaEstaAberta and (not EstaEditando) then
    DataSetVenda.Edit;
    
  if not EstaEditando then
    Exit;

  if ( DataSetItens.RecordCount = 0 ) then
  begin
    ShowWarning('Or�amento sem �tens n�o pode ser gravado!!!');
    Exit;
  end;

  if VendaEstaAberta then
    if ShowConfirmation('Gravar', 'Deseja gravar o or�amento para carreg�-lo futuramente?') then
    begin
      with DataSetVenda do
      begin
        if ( FieldByName('STATUS').AsInteger = STATUS_VND_AND ) then
          FieldByName('STATUS').Value := STATUS_VND_ABR;

        FieldByName('CODCLIENTE').Value := edNomeCliente.Tag;
        FieldByName('CODCLI').Value     := edNomeCliente.Hint;
        FieldByName('NOME').Value       := edNomeCliente.Caption;
      end;

      TIBDataSet(DataSetVenda).Post;
      TIBDataSet(DataSetVenda).ApplyUpdates;

      TIBDataSet(DataSetItens).ApplyUpdates;
      TIBDataSet(DataSetFormaPagto).ApplyUpdates;

      ShowInformation('Or�amento gravado com sucesso. Favor anotar n�mero:' + #13#13 +
        'No. ' + DataSetVenda.FieldByName('ANO').AsString + '/' + FormatFloat('###00000', DataSetVenda.FieldByName('CODCONTROL').AsInteger));

      CarregarVenda(GetEmpresaIDDefault, 0, 0);
      IniciarCupomCabecalho;
      IniciarCupomProduto;
    end;
end;

initialization
  FormFunction.RegisterForm('frmGeVendaPDV', TfrmGeVendaPDV);

end.