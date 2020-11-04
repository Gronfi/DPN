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
  [TestFixture]
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

  FArco                        := TdpnArcoIn.Create;
  FArco.OnHabilitacionChanged.Add(DoOnHabilitacionChanged);
  FArco.Plaza                  := FPlaza;
  FArco.Peso                   := 1;
  FArco.PesoEvaluar            := 1;

  try
    if FPlaza.TokenCount <> 1 then
      Assert.Fail('Step1: TokenCount <> 1');

    LMarcado := FArco.ObtenerTokensEvaluacion;
    LMarcado.Marcado.TryGetValue(FPlaza, LTokens);
    LToken := LTokens[0];

    if not FArco.IsHabilitado then
      Assert.Fail('Step2: not Habilitado');
    if not FContextoCambiado then
      Assert.Fail('Contexto');
    if FID <> FArco.ID then
      Assert.Fail('ID: ' + FID.ToString);
    if not FArco.IsHabilitado then
      Assert.Fail('No Habilitado');

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

  FArcoI1 : IArcoIn;
  FPlazaI1: IPlaza;

  FArcoO1 : IArcoOut;
  FPlazaO1: IPlaza;

  FTransicion: ITransicion;
begin
  LModelo := TdpnModelo.Create;

  FPlazaI1           := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'I1';
  FPlazaI1.Capacidad := 1;

  FArcoI1             := TdpnArcoIn.Create;
  FArcoI1.Plaza       := FPlazaI1;
  FArcoI1.Peso        := 1;
  FArcoI1.PesoEvaluar := 1;

  FPlazaO1           := TdpnPlazaFinish.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 1;

  FArcoO1       := TdpnArcoOut.Create;
  FArcoO1.Plaza := FPlazaO1;
  FArcoO1.Peso  := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);

  LModelo.Elementos.Add(FTransicion);

  LPNet := TdpnPetriNetCoordinador.Create;
  try
    LPNet.Grafo := LModelo;
    LPNet.Start;

    for I := 1 to 1 do
    begin
      LToken := TdpnTokenColoreado.Create;
      FPlazaI1.AddToken(LToken);
    end;

    Sleep(100);

    Writeln('I1: ' + FPlazaI1.TokenCount.ToString + ' - O1: ' + FPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + FTransicion.TransicionesRealizadas.ToString + '/' + FTransicion.TransicionesIntentadas.ToString);
    if not((FPlazaI1.TokenCount = 0) and (FPlazaO1.TokenCount = 0)) then
      Assert.Fail('no ha transicionado');

    Assert.Pass;
  finally
    LModelo     := nil;
    FPlazaI1    := nil;
    FArcoI1     := nil;
    FPlazaO1    := nil;
    FArcoO1     := nil;
    FTransicion := nil;

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

  FArco                        := TdpnArcoIn.Create;
  FArco.Plaza                  := FPlaza;
  FArco.Peso                   := 1;
  FArco.PesoEvaluar            := 1;

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

initialization
  TDUnitX.RegisterTestFixture(TPetriNetCoreTesting_Plazas);
end.
