unit DPN.Core.Testing.PetriNetCoordinador;

interface

uses
  System.Rtti,
  Spring.Collections,

  DUnitX.Loggers.Console,
  DUnitX.TestFramework,

  Event.Engine.Interfaces,
  Event.Engine,

  DPN.Interfaces,
  DPN.PetriNet,
  DPN.Modelo,
  DPN.Variable,
  DPN.Plaza,
  DPN.ArcoIn,
  DPN.Condicion,
  DPN.ArcoOut,
  DPN.Transicion;

type
  TMsg_SGA_42 = class(TEvent)

  end;

  TdpnCondicion_es_mensaje_sga_07 = class(TdpnCondicionBaseEsperaEvento)
  protected
    FEvento: IEventEE;
    FListenerEvento: IEventEEListener;

    function GetDependencias: IList<IBloqueable>; override;

    function CrearListenerEvento: IEventEEListener; override;

    function Filtrado (AEvento: IEventEE): Boolean;
    procedure Ejecutar (AEvento: IEventEE);

  public
    function Evaluar(ATokens: IMarcadoTokens; AEvento: IEventEE): Boolean; overload; override;
  end;

  [TestFixture]
  TPetriNetCoreTesting_PetriNet = class
  public
    [Test]
    procedure Test_PetriNet_Arranca_Para_OK;
    [Test]
    procedure Test_PetriNet_ASignacionGrafo_Start;
    [Test]
    procedure Test_PetriNet_ASignacionGrafo_TransicionSimple_1_origen_1_destino;
    [Test]
    procedure Test_PetriNet_ASignacionGrafo_TransicionSimple_1_origen_2_destinos;
    [Test]
    procedure Test_PetriNet_ASignacionGrafo_TransicionSimple_1_origen_2_destinos_Varios_Tokens;
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

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_ASignacionGrafo_TransicionSimple_1_origen_1_destino;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LToken : IToken;
  I      : Integer;

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


  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  Sleep(100);

  if not(FPlazaI1.TokenCount = 0) and (FPlazaO1.TokenCount = 1) then
    Assert.Fail('no ha transicionado');

  Writeln('I1: ' + FPlazaI1.TokenCount.ToString + ' - O1: ' + FPlazaO1.TokenCount.ToString);
  Writeln('Datos: ' + FTransicion.TransicionesRealizadas.ToString + '/' + FTransicion.TransicionesIntentadas.ToString);

  LPNet.Destroy;
  Assert.Pass;
end;

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_ASignacionGrafo_TransicionSimple_1_origen_2_destinos;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LToken : IToken;
  I      : Integer;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;

  FArcoO1    : IArcoOut;
  FPlazaO1   : IPlaza;

  FArcoO2    : IArcoOut;
  FPlazaO2   : IPlaza;

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

  FPlazaO2           := TdpnPlaza.Create;
  FPlazaO2.Nombre    := 'O2';
  FPlazaO2.Capacidad := 1;

  FArcoO2                        := TdpnArcoOut.Create;
  FArcoO2.Plaza                  := FPlazaO2;
  FArcoO2.Peso                   := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);
  FTransicion.AddArcoOut(FArcoO2);

  LModelo.Elementos.Add(FTransicion);

  LPNet       := TdpnPetriNetCoordinador.Create;
  //LPNet.MultipleEnablednessOfTransitions := False;
  LPNet.Grafo := LModelo;
  LPNet.Start;


  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  Sleep(100);

  if not((FPlazaI1.TokenCount = 0) and (FPlazaO1.TokenCount = 1) and (FPlazaO2.TokenCount = 1)) then
    Assert.Fail('no ha transicionado');

  Writeln('I1: ' + FPlazaI1.TokenCount.ToString + ' - O1: ' + FPlazaO1.TokenCount.ToString + ' - O2: ' + FPlazaO2.TokenCount.ToString);
  Writeln('Datos: ' + FTransicion.TransicionesRealizadas.ToString + '/' + FTransicion.TransicionesIntentadas.ToString);

  LPNet.Destroy;
  Assert.Pass;
end;

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_ASignacionGrafo_TransicionSimple_1_origen_2_destinos_Varios_Tokens;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LToken : IToken;
  I      : Integer;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;

  FArcoO1    : IArcoOut;
  FPlazaO1   : IPlaza;

  FArcoO2    : IArcoOut;
  FPlazaO2   : IPlaza;

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
  FPlazaO1.Capacidad := 5;

  FArcoO1                        := TdpnArcoOut.Create;
  FArcoO1.Plaza                  := FPlazaO1;
  FArcoO1.Peso                   := 1;

  FPlazaO2           := TdpnPlaza.Create;
  FPlazaO2.Nombre    := 'O2';
  FPlazaO2.Capacidad := 5;

  FArcoO2                        := TdpnArcoOut.Create;
  FArcoO2.Plaza                  := FPlazaO2;
  FArcoO2.Peso                   := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);
  FTransicion.AddArcoOut(FArcoO2);

  LModelo.Elementos.Add(FTransicion);

  LPNet       := TdpnPetriNetCoordinador.Create;
  //LPNet.MultipleEnablednessOfTransitions := False;
  LPNet.Grafo := LModelo;
  LPNet.Start;


  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  Sleep(100);

  Writeln('Step1 -- > I1: ' + FPlazaI1.TokenCount.ToString + ' - O1: ' + FPlazaO1.TokenCount.ToString + ' - O2: ' + FPlazaO2.TokenCount.ToString);
  Writeln('Step1 -- > Datos: ' + FTransicion.TransicionesRealizadas.ToString + '/' + FTransicion.TransicionesIntentadas.ToString);

  if not((FPlazaI1.TokenCount = 0) and (FPlazaO1.TokenCount = 1) and (FPlazaO2.TokenCount = 1)) then
    Assert.Fail('no ha transicionado (1)');

  for I := 1 to 3 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  Sleep(100);

  Writeln('Step2 -- > I1: ' + FPlazaI1.TokenCount.ToString + ' - O1: ' + FPlazaO1.TokenCount.ToString + ' - O2: ' + FPlazaO2.TokenCount.ToString);
  Writeln('Step2 -- > Datos: ' + FTransicion.TransicionesRealizadas.ToString + '/' + FTransicion.TransicionesIntentadas.ToString);

  if not((FPlazaI1.TokenCount = 0) and (FPlazaO1.TokenCount = 4) and (FPlazaO2.TokenCount = 4)) then
    Assert.Fail('no ha transicionado (2)');

  LPNet.Destroy;
  Assert.Pass;
end;

{ TdpnCondicion_es_mensaje_sga_07 }

function TdpnCondicion_es_mensaje_sga_07.CrearListenerEvento: IEventEEListener;
begin
  Result := TEventListener<TMsg_SGA_42>.Create(Ejecutar, Filtrado);
end;

procedure TdpnCondicion_es_mensaje_sga_07.Ejecutar(AEvento: IEventEE);
begin
  WriteLn('Ejecutar --> ' + QualifiedClassName);
  FEvento := AEvento;
  FEventoOnContextoCondicionChanged.Invoke(ID);
end;

function TdpnCondicion_es_mensaje_sga_07.Evaluar(ATokens: IMarcadoTokens; AEvento: IEventEE): Boolean;
begin
  Result := Assigned(FEvento)
end;

function TdpnCondicion_es_mensaje_sga_07.Filtrado(AEvento: IEventEE): Boolean;
begin
  Result := True;
end;

function TdpnCondicion_es_mensaje_sga_07.GetDependencias: IList<IBloqueable>;
begin
  Result := inherited;
end;

initialization
  TDUnitX.RegisterTestFixture(TPetriNetCoreTesting_PetriNet);

end.
