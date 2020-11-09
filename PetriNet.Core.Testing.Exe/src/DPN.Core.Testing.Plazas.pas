{$I Defines.inc}
unit DPN.Core.Testing.Plazas;

interface

uses
  System.Rtti,
  Spring.Collections,

  DUnitX.TestFramework,

  DPN.Interfaces,
  DPN.Plaza,
  DPN.Modelo,
  DPN.Plaza.Start,
  DPN.Plaza.Finish,
  DPN.ArcoIn,
  DPN.ArcoReset,
  DPN.Condicion,
  DPN.ArcoOut,
  DPN.Transicion,
  DPN.PetriNet,
  DPN.Variable;

type
{$IFDEF TESTS_HABILITADOS}
  [TestFixture]
{$ENDIF}
  TPetriNetCoreTesting_Plazas = class
  private
    FID      : Integer;
    FArco    : IArcoIn;
    FPlaza   : IPlaza;
    FContextoCambiado: Boolean;
    FValor           : Boolean;
    FCnt : Integer;
  protected
    procedure DoOnHabilitacionChanged(const AID: Integer; const ANewEstado: boolean);
  public
    [Test]
    procedure Test_Transicionado_Arco_En_Plaza_Start;
    [Test]
    procedure Test_Transicionado_Arco_En_Plaza_Start_Varios;
    [Test]
    procedure Test_Cambio_En_PlazaStart_Notifica_A_Arco;
    [Test]
    procedure Test_Plaza_Finish;
  end;

implementation

uses
  System.SysUtils,

  DPN.TokenColoreado;

{ TPetriNetCoreTesting_Plazas }

procedure TPetriNetCoreTesting_Plazas.DoOnHabilitacionChanged(const AID: Integer; const ANewEstado: boolean);
begin
  FID := AID;
  FContextoCambiado := True;
  FValor := ANewEstado;
  inc(FCnt);
end;

procedure TPetriNetCoreTesting_Plazas.Test_Cambio_En_PlazaStart_Notifica_A_Arco;
var
  LMarcado: IMarcadoTokens;
  LTokens: IList<IToken>;
  LToken: IToken;
begin
  FID := 0;
  FContextoCambiado := False;
  FValor := False;
  FCnt := 0;

  FPlaza   := TdpnPlazaStart.Create;
  FPlaza.Nombre    := 'O1';
  FPlaza.Start;


  FArco                        := TdpnArcoIn.Create;
  FArco.OnHabilitacionChanged.Add(DoOnHabilitacionChanged);
  FArco.Plaza                  := FPlaza;
  FArco.Peso                   := 1;
  FArco.PesoEvaluar            := 1;
  FArco.Start;

  try
    if FPlaza.TokenCount <> 1 then
      Assert.Fail('Step1: TokenCount <> 1');

    LMarcado := FArco.ObtenerTokensEvaluacion;
    LMarcado.Marcado.TryGetValue(FPlaza, LTokens);
    LToken := LTokens[0];

    if not FContextoCambiado then
      Assert.Fail('Contexto');
    if FID <> FArco.ID then
      Assert.Fail('ID: ' + FID.ToString);

    FArco.DoOnTransicionando([LToken]);

    if FPlaza.TokenCount <> 0 then
      Assert.Fail('Step3: TokenCount <> 0');

    if FArco.IsHabilitado then
      Assert.Fail('Habilitado');

    Assert.Pass('Cnt: ' + FCnt.ToString);
  finally
    FArco.OnHabilitacionChanged.Remove(DoOnHabilitacionChanged);
    FArco.PLaza := nil;
    FArco       := nil;
    FPlaza      := nil;
  end;
end;

procedure TPetriNetCoreTesting_Plazas.Test_Plaza_Finish;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LToken : IToken;
  I      : Integer;

  LArcoI1 : IArcoIn;
  LPlazaI1: IPlaza;

  LArcoO1 : IArcoOut;
  LPlazaO1: IPlaza;

  LTransicion: ITransicion;
begin
  LModelo := TdpnModelo.Create;

  LPlazaI1           := TdpnPlaza.Create;
  LPlazaI1.Nombre    := 'I1';
  LPlazaI1.Capacidad := 1;

  LArcoI1             := TdpnArcoIn.Create;
  LArcoI1.Plaza       := LPlazaI1;
  LArcoI1.Peso        := 1;
  LArcoI1.PesoEvaluar := 1;

  LPlazaO1           := TdpnPlazaFinish.Create;
  LPlazaO1.Nombre    := 'O1';
  LPlazaO1.Capacidad := 1;

  LArcoO1       := TdpnArcoOut.Create;
  LArcoO1.Plaza := LPlazaO1;
  LArcoO1.Peso  := 1;

  LTransicion := TdpnTransicion.Create;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);

  LModelo.Elementos.Add(LTransicion);
  LModelo.Elementos.Add(LPlazaI1);
  LModelo.Elementos.Add(LArcoI1);
  LModelo.Elementos.Add(LPlazaO1);
  LModelo.Elementos.Add(LArcoO1);

  LPNet := TdpnPetriNetCoordinador.Create;
  try
    LPNet.Grafo := LModelo;
    LPNet.Start;

    for I := 1 to 1 do
    begin
      LToken := TdpnTokenColoreado.Create;
      LPlazaI1.AddToken(LToken);
    end;

    Sleep(100);

    Writeln('I1: ' + LPlazaI1.TokenCount.ToString + ' - O1: ' + LPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + LTransicion.TransicionesRealizadas.ToString + '/' + LTransicion.TransicionesIntentadas.ToString);
    if not((LPlazaI1.TokenCount = 0) and (LPlazaO1.TokenCount = 0)) then
      Assert.Fail('no ha transicionado');

    Assert.Pass;
  finally
    LModelo     := nil;
    LPlazaI1    := nil;
    LArcoI1     := nil;
    LPlazaO1    := nil;
    LArcoO1     := nil;
    LTransicion := nil;

    LPNet.Destroy;
  end;
end;

procedure TPetriNetCoreTesting_Plazas.Test_Transicionado_Arco_En_Plaza_Start;
var
  LMarcado: IMarcadoTokens;
  LTokens: IList<IToken>;
  LToken: IToken;
begin
  FID := 0;
  FContextoCambiado := False;
  FValor := False;
  FCnt := 0;

  FPlaza   := TdpnPlazaStart.Create;
  FPlaza.Nombre    := 'O1';
  FPlaza.Start;

  FArco                        := TdpnArcoIn.Create;
  FArco.Plaza                  := FPlaza;
  FArco.Peso                   := 1;
  FArco.PesoEvaluar            := 1;
  FArco.Start;

  try
    if FPlaza.TokenCount <> 1 then
      Assert.Fail('Step1: TokenCount <> 1');

    LMarcado := FArco.ObtenerTokensEvaluacion;
    LMarcado.Marcado.TryGetValue(FPlaza, LTokens);
    LToken := LTokens[0];

    FArco.DoOnTransicionando([LToken]);

    if FPlaza.TokenCount = 0 then
      Assert.Pass
    else
      Assert.Fail('Step2: TokenCount <> 0');
  finally
      FArco.OnHabilitacionChanged.Remove(DoOnHabilitacionChanged);
      FArco.PLaza := nil;
      FArco       := nil;
      FPlaza      := nil;
  end;
end;

procedure TPetriNetCoreTesting_Plazas.Test_Transicionado_Arco_En_Plaza_Start_Varios;
var
  LMarcado: IMarcadoTokens;
  LTokens: IList<IToken>;
  LToken: IToken;
begin
  FID := 0;
  FContextoCambiado := False;
  FValor := False;
  FCnt := 0;

  FPlaza   := TdpnPlazaStart.Create;
  TdpnPlazaStart(FPlaza).GeneracionContinua := True;
  FPlaza.Nombre    := 'O1';
  FPlaza.Start;

  FArco                        := TdpnArcoIn.Create;
  FArco.Plaza                  := FPlaza;
  FArco.Peso                   := 1;
  FArco.PesoEvaluar            := 1;
  FArco.Start;

  try
    if FPlaza.TokenCount <> 1 then
      Assert.Fail('Step1: TokenCount <> 1');

    LMarcado := FArco.ObtenerTokensEvaluacion;
    LMarcado.Marcado.TryGetValue(FPlaza, LTokens);
    LToken := LTokens[0];

    FArco.DoOnTransicionando([LToken]);

    if FPlaza.TokenCount = 1 then //tenemos otro preparado
      Assert.Pass
    else
      Assert.Fail('Step2: TokenCount <> 0');
  finally
      FArco.OnHabilitacionChanged.Remove(DoOnHabilitacionChanged);
      FArco.PLaza := nil;
      FArco       := nil;
      FPlaza      := nil;
  end;
end;

initialization
{$IFDEF TESTS_HABILITADOS}
  TDUnitX.RegisterTestFixture(TPetriNetCoreTesting_Plazas);
{$ENDIF}
end.
