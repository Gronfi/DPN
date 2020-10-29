unit DPN.Core.Testing.PetriNetCoordinador;

interface

uses
  System.Rtti,
  Spring.Collections,

  DUnitX.Loggers.Console,
  DUnitX.TestFramework,

  DPN.Interfaces,
  DPN.PetriNet,
  DPN.Modelo,
  DPN.Variable,
  DPN.Plaza,
  DPN.ArcoIn,
  DPN.ArcoOut,
  DPN.Transicion;

type
  [TestFixture]
  TPetriNetCoreTesting_PetriNet = class
  public
    [Test]
    procedure Test_PetriNet_Arranca_Para_OK;
    [Test]
    procedure Test_PetriNet_ASignacionGrafo_Start;
    [Test]
    procedure Test_PetriNet_ASignacionGrafo_TransicionSimple;
  end;

implementation

uses
  System.SysUtils,

  DPN.Core.Testing.Funciones,
  DPN.TokenColoreado;

{ TPetriNetCoreTesting_PetriNet }

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_Arranca_Para_OK;
var
  LPNet: TdpnPetriNetCoordinador;
  LEstado: EEstadoPetriNet;
begin
  LPNet := TdpnPetriNetCoordinador.Create;
  LEstado := LPNet.Estado;

  if not (LEstado = EEstadoPetriNet.GrafoNoASignado) then
    Assert.Fail('Tras inicio');

  LPNet.Destroy;
  Assert.Pass
end;

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_ASignacionGrafo_Start;
var
  LPNet: TdpnPetriNetCoordinador;
  LModelo: IModelo;
begin
  LModelo := TdpnModelo.Create;

  LPNet := TdpnPetriNetCoordinador.Create;

  if not (LPNet.Estado = EEstadoPetriNet.GrafoNoASignado) then
    Assert.Fail('Tras inicio');

  LPNet.Grafo := LModelo;

  if not (LPNet.Estado = EEstadoPetriNet.Detenida) then
    Assert.Fail('Tras asignar');

  LPNet.Start;

  if not (LPNet.Estado = EEstadoPetriNet.Iniciada) then
    Assert.Fail('Tras start');

  LPNet.Destroy;
  Assert.Pass
end;

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_ASignacionGrafo_TransicionSimple;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LToken : IToken;
  I      : Integer;
  LRes   : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;

  FArcoO1    : IArcoOut;
  FPlazaO1   : IPlaza;

  FTransicion: ITransicion;
begin
  LModelo := TdpnModelo.Create;

  FPlazaI1           := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'I1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FPlazaO1           := TdpnPlaza.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 1;

  FArcoO1                        := TdpnArcoOut.Create;
  FArcoO1.Plaza                  := FPlazaO1;
  FArcoO1.Peso                   := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);

  LModelo.Elementos.Add(FTransicion);

  LPNet       := TdpnPetriNetCoordinador.Create;
  LPNet.Grafo := LModelo;
  LPNet.Start;

  Sleep(100);

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  Sleep(1000);

  if not(FPlazaI1.TokenCount = 0) and (FPlazaO1.TokenCount = 1) then
    Assert.Fail('no ha transicionado');

  Writeln('I1: ' + FPlazaI1.TokenCount.ToString + ' - O1: ' + FPlazaO1.TokenCount.ToString);
  Writeln('Datos: ' + FTransicion.TransicionesRealizadas.ToString + '/' + FTransicion.TransicionesIntentadas.ToString);

  LPNet.Destroy;
  Assert.Pass
end;

initialization
  TDUnitX.RegisterTestFixture(TPetriNetCoreTesting_PetriNet);

end.
