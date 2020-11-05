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
  DPN.Plaza.Super,
  DPN.ArcoIn,
  DPN.ArcoReset,
  DPN.Condicion,
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
    procedure Test_PetriNet_ASignacionGrafo_TransicionSimple_1_origen_1_destino;
    [Test]
    procedure Test_PetriNet_ASignacionGrafo_TransicionSimple_1_origen_2_destinos;
    [Test]
    procedure Test_PetriNet_ASignacionGrafo_TransicionSimple_1_origen_2_destinos_Varios_Tokens;
    [Test]
    procedure Test_PetriNet_CondicionesNoOK_Varios_Eventos_1_Estado_Origen_1_Estado_Destino;
    [Test]
    procedure Test_PetriNet_CondicionesOK_Varios_Eventos_1_Estado_Origen_1_Estado_Destino;
    [Test]
    procedure Test_PetriNet_PrimerToken_CondicionesOK_SegundoToken_CondicionesNoOK_Varios_Eventos_1_Estado_Origen_1_Estado_Destino;
    [Test]
    procedure Test_PetriNet_SuperPlaza_Extrae_Token;
    [Test]
    procedure Test_PetriNet_ArcoReset;
    [Test]
    procedure Test_PetriNet_Nombres;
    [Test]
    procedure Test_Maps_vs_Diccionarios; //es un test de rendimiento, comparativa de tiempos, no de que funcionen bien
  end;

implementation

uses
  System.SysUtils,

  Event.Engine.Utils,
  DPN.Core.Testing.Funciones,
  DPN.TokenColoreado;

{ TPetriNetCoreTesting_PetriNet }

procedure TPetriNetCoreTesting_PetriNet.Test_Maps_vs_Diccionarios;
var
  LMapa: IMultimap<integer, integer>;
  LDiccionario: IDictionary<integer, integer>;
  I: integer;
  LI1, LF1, LI2, LF2: int64;
  LMI1, LMF1, LMI2, LMF2: int64;
  LCol: IReadOnlyCollection<integer>;
  LVal: integer;
begin
  LMapa := TCollections.CreateMultiMap<integer, integer>;
  LDiccionario := TCollections.CreateDictionary<integer, integer>;
  LI1 := Utils.ElapsedTicks;
  LMI1 := uTILS.ElapsedMiliseconds;
  for I := 1 to 10000000 do
  begin
    LMapa.Add(I, I);
  end;
  LF1 := Utils.ElapsedTicks;
  LMF1 := Utils.ElapsedMiliseconds;
  LI2 := Utils.ElapsedTicks;
  LMI2 := Utils.ElapsedMiliseconds;
  for I := 1 to 10000000 do
  begin
    LDiccionario[I] := I;
  end;
  LF2 := Utils.ElapsedTicks;
  LMF2 := uTILS.ElapsedMiliseconds;
  WriteLn('Map: ' + (LF1 - LI1).ToString + ' - ' + (LMF1 - LMI1).ToString);
  WriteLn('Dicc: ' + (LF2 - LI2).ToString + ' - ' + (LMF2 - LMI2).ToString);

  LI1 := Utils.ElapsedTicks;
  LMI1 := Utils.ElapsedMiliseconds;
  LMapa.TryGetValues(500000, LCol);
  LF1 := Utils.ElapsedTicks;
  LMF1 := Utils.ElapsedMiliseconds;
  for LVal in LCol do
    WriteLn('Col: ' + LVal.ToString);

  LI2 := Utils.ElapsedTicks;
  LMI2 := Utils.ElapsedMiliseconds;
  LDiccionario.TryGetValue(500000, LVal);
  LF2 := Utils.ElapsedTicks;
  LMF2 := Utils.ElapsedMiliseconds;
  WriteLn('Val: ' + LVal.ToString);

  WriteLn('Map*: ' + (LF1 - LI1).ToString + ' - ' + (LMF1 - LMI1).ToString);
  WriteLn('Dicc*: ' + (LF2 - LI2).ToString + ' - ' + (LMF2 - LMI2).ToString);

  LI1 := Utils.ElapsedTicks;
  LMI1 := Utils.ElapsedMiliseconds;
  LMapa.Add(500000, 1);
  for I := 1 to 100 do
  begin
    LMapa.Add(500000, I);
  end;
  LF1 := Utils.ElapsedTicks;
  LMF1 := Utils.ElapsedMiliseconds;
  WriteLn('Map**: ' + (LF1 - LI1).ToString + ' - ' + (LMF1 - LMI1).ToString);

  LI1 := Utils.ElapsedTicks;
  LMI1 := Utils.ElapsedMiliseconds;
  LMapa.TryGetValues(500000, LCol);
  LF1 := Utils.ElapsedTicks;
  LMF1 := Utils.ElapsedMiliseconds;
  WriteLn('Map***: ' + (LF1 - LI1).ToString + ' - ' + (LMF1 - LMI1).ToString);
  for LVal in LCol do
    WriteLn('Col: ' + LVal.ToString);

  Assert.Pass;
end;

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_ArcoReset;
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

  LPlazaO1           := TdpnPlaza.Create;
  LPlazaO1.Nombre    := 'O1';
  LPlazaO1.Capacidad := 2;

  LArcoO1       := TdpnArcoReset.Create;
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
      LPlazaO1.AddToken(LToken);
    end;

    for I := 1 to 1 do
    begin
      LToken := TdpnTokenColoreado.Create;
      LPlazaI1.AddToken(LToken);
    end;

    Sleep(100);

    if not(LPlazaI1.TokenCount = 0) and (LPlazaO1.TokenCount = 0) then
      Assert.Fail('no ha transicionado bien');

    Writeln('I1: ' + LPlazaI1.TokenCount.ToString + ' - O1: ' + LPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + LTransicion.TransicionesRealizadas.ToString + '/' + LTransicion.TransicionesIntentadas.ToString);
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

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_Arranca_Para_OK;
var
  LPNet  : TdpnPetriNetCoordinador;
  LEstado: EEstadoPetriNet;
begin
  LPNet := TdpnPetriNetCoordinador.Create;
  try
    LEstado := LPNet.Estado;

    if not(LEstado = EEstadoPetriNet.GrafoNoASignado) then
      Assert.Fail('Tras inicio');
  finally
    LPNet.Destroy;
  end;
  Assert.Pass
end;

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_ASignacionGrafo_Start;
var
  LPNet  : TdpnPetriNetCoordinador;
  LModelo: IModelo;
begin
  LModelo := TdpnModelo.Create;

  LPNet := TdpnPetriNetCoordinador.Create;
  try
    if not(LPNet.Estado = EEstadoPetriNet.GrafoNoASignado) then
      Assert.Fail('Tras inicio');

    LPNet.Grafo := LModelo;

    if not(LPNet.Estado = EEstadoPetriNet.Detenida) then
      Assert.Fail('Tras asignar');

    LPNet.Start;

    if not(LPNet.Estado = EEstadoPetriNet.Iniciada) then
      Assert.Fail('Tras start');
    Assert.Pass
  finally
    LModelo := nil;
    LPNet.Destroy;
  end;
end;

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_ASignacionGrafo_TransicionSimple_1_origen_1_destino;
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

  LPlazaO1           := TdpnPlaza.Create;
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

    if not(LPlazaI1.TokenCount = 0) and (LPlazaO1.TokenCount = 1) then
      Assert.Fail('no ha transicionado');

    Writeln('I1: ' + LPlazaI1.TokenCount.ToString + ' - O1: ' + LPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + LTransicion.TransicionesRealizadas.ToString + '/' + LTransicion.TransicionesIntentadas.ToString);
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

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_ASignacionGrafo_TransicionSimple_1_origen_2_destinos;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LToken : IToken;
  I      : Integer;

  LArcoI1 : IArcoIn;
  LPlazaI1: IPlaza;

  LArcoO1 : IArcoOut;
  LPlazaO1: IPlaza;

  LArcoO2 : IArcoOut;
  LPlazaO2: IPlaza;

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

  LPlazaO1           := TdpnPlaza.Create;
  LPlazaO1.Nombre    := 'O1';
  LPlazaO1.Capacidad := 1;

  LArcoO1       := TdpnArcoOut.Create;
  LArcoO1.Plaza := LPlazaO1;
  LArcoO1.Peso  := 1;

  LPlazaO2           := TdpnPlaza.Create;
  LPlazaO2.Nombre    := 'O2';
  LPlazaO2.Capacidad := 1;

  LArcoO2       := TdpnArcoOut.Create;
  LArcoO2.Plaza := LPlazaO2;
  LArcoO2.Peso  := 1;

  LTransicion := TdpnTransicion.Create;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);
  LTransicion.AddArcoOut(LArcoO2);

  LModelo.Elementos.Add(LTransicion);
  LPNet := TdpnPetriNetCoordinador.Create;
  try
    // LPNet.MultipleEnablednessOfTransitions := False;
    LPNet.Grafo := LModelo;
    LPNet.Start;

    for I := 1 to 1 do
    begin
      LToken := TdpnTokenColoreado.Create;
      LPlazaI1.AddToken(LToken);
    end;

    Sleep(500);

    if not((LPlazaI1.TokenCount = 0) and (LPlazaO1.TokenCount = 1) and (LPlazaO2.TokenCount = 1)) then
      Assert.Fail('no ha transicionado');

    Writeln('I1: ' + LPlazaI1.TokenCount.ToString + ' - O1: ' + LPlazaO1.TokenCount.ToString + ' - O2: ' + LPlazaO2.TokenCount.ToString);
    Writeln('Datos: ' + LTransicion.TransicionesRealizadas.ToString + '/' + LTransicion.TransicionesIntentadas.ToString);
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

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_ASignacionGrafo_TransicionSimple_1_origen_2_destinos_Varios_Tokens;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LToken : IToken;
  I      : Integer;

  LArcoI1 : IArcoIn;
  LPlazaI1: IPlaza;

  LArcoO1 : IArcoOut;
  LPlazaO1: IPlaza;

  LArcoO2 : IArcoOut;
  LPlazaO2: IPlaza;

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

  LPlazaO1           := TdpnPlaza.Create;
  LPlazaO1.Nombre    := 'O1';
  LPlazaO1.Capacidad := 5;

  LArcoO1       := TdpnArcoOut.Create;
  LArcoO1.Plaza := LPlazaO1;
  LArcoO1.Peso  := 1;

  LPlazaO2           := TdpnPlaza.Create;
  LPlazaO2.Nombre    := 'O2';
  LPlazaO2.Capacidad := 5;

  LArcoO2       := TdpnArcoOut.Create;
  LArcoO2.Plaza := LPlazaO2;
  LArcoO2.Peso  := 1;

  LTransicion := TdpnTransicion.Create;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);
  LTransicion.AddArcoOut(LArcoO2);

  LModelo.Elementos.Add(LTransicion);
  LModelo.Elementos.Add(LPlazaI1);
  LModelo.Elementos.Add(LArcoI1);
  LModelo.Elementos.Add(LPlazaO1);
  LModelo.Elementos.Add(LPlazaO2);
  LModelo.Elementos.Add(LArcoO1);
  LModelo.Elementos.Add(LArcoO2);

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

    Writeln('Step1 -- > I1: ' + LPlazaI1.TokenCount.ToString + ' - O1: ' + LPlazaO1.TokenCount.ToString + ' - O2: ' + LPlazaO2.TokenCount.ToString);
    Writeln('Step1 -- > Datos: ' + LTransicion.TransicionesRealizadas.ToString + '/' + LTransicion.TransicionesIntentadas.ToString);

    if not((LPlazaI1.TokenCount = 0) and (LPlazaO1.TokenCount = 1) and (LPlazaO2.TokenCount = 1)) then
      Assert.Fail('no ha transicionado (1)');

    for I := 1 to 3 do
    begin
      LToken := TdpnTokenColoreado.Create;
      LPlazaI1.AddToken(LToken);
    end;

    Sleep(100);

    Writeln('Step2 -- > I1: ' + LPlazaI1.TokenCount.ToString + ' - O1: ' + LPlazaO1.TokenCount.ToString + ' - O2: ' + LPlazaO2.TokenCount.ToString);
    Writeln('Step2 -- > Datos: ' + LTransicion.TransicionesRealizadas.ToString + '/' + LTransicion.TransicionesIntentadas.ToString);

    if not((LPlazaI1.TokenCount = 0) and (LPlazaO1.TokenCount = 4) and (LPlazaO2.TokenCount = 4)) then
      Assert.Fail('no ha transicionado (2)');
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

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_CondicionesNoOK_Varios_Eventos_1_Estado_Origen_1_Estado_Destino;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LToken : IToken;
  I      : Integer;

  LArcoI1 : IArcoIn;
  LPlazaI1: IPlaza;

  LArcoO1 : IArcoOut;
  LPlazaO1: IPlaza;

  LFuncion : ICondicion;
  LEnabled : IVariable;
  LFuncionE: ICondicion;

  LEvento: IEventEE;

  LTransicion: ITransicion;
begin
  LEnabled        := TdpnVariable.Create;
  LEnabled.Nombre := 'Enabled';
  LEnabled.Valor  := 0;

  LFuncionE                                     := TdpnCondicion_Evento_Prueba.Create;
  TdpnCondicion_Evento_Prueba(LFuncionE).Numero := 5;

  LFuncion                                                := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(LFuncion).Variable     := LEnabled;
  TdpnCondicion_es_tabla_variables(LFuncion).ValorToCheck := 5;

  LModelo := TdpnModelo.Create;

  LPlazaI1           := TdpnPlaza.Create;
  LPlazaI1.Nombre    := 'I1';
  LPlazaI1.Capacidad := 2;

  LArcoI1             := TdpnArcoIn.Create;
  LArcoI1.Plaza       := LPlazaI1;
  LArcoI1.Peso        := 1;
  LArcoI1.PesoEvaluar := 1;

  LPlazaO1           := TdpnPlaza.Create;
  LPlazaO1.Nombre    := 'O1';
  LPlazaO1.Capacidad := 1;

  LArcoO1       := TdpnArcoOut.Create;
  LArcoO1.Plaza := LPlazaO1;
  LArcoO1.Peso  := 1;

  LTransicion := TdpnTransicion.Create;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);
  LTransicion.AddCondicion(LFuncion);
  LTransicion.AddCondicion(LFuncionE);

  LModelo.Elementos.Add(LTransicion);
  LModelo.Elementos.Add(LPlazaI1);
  LModelo.Elementos.Add(LArcoI1);
  LModelo.Elementos.Add(LPlazaO1);
  LModelo.Elementos.Add(LEnabled);
  LModelo.Elementos.Add(LArcoO1);
  LModelo.Elementos.Add(LFuncionE);
  LModelo.Elementos.Add(LFuncion);

  LPNet := TdpnPetriNetCoordinador.Create;
  try
    LPNet.Grafo := LModelo;
    LPNet.Start;

    for I := 1 to 2 do
    begin
      LToken := TdpnTokenColoreado.Create;
      LPlazaI1.AddToken(LToken);
    end;

    LEvento                       := TEventoPrueba.Create;
    TEventoPrueba(LEvento).Numero := 5;
    TEventoPrueba(LEvento).Texto  := 'Hola';
    LEvento.Post;

    LEvento                       := TEventoPrueba.Create;
    TEventoPrueba(LEvento).Numero := 5;
    TEventoPrueba(LEvento).Texto  := 'Hola';
    LEvento.Post;

    Sleep(10);

    Writeln('I1: ' + LPlazaI1.TokenCount.ToString + ' - O1: ' + LPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + LTransicion.TransicionesRealizadas.ToString + '/' + LTransicion.TransicionesIntentadas.ToString);

    if not((LPlazaI1.TokenCount = 2) and (LPlazaO1.TokenCount = 0)) then
      Assert.Fail('no ha transicionado bien');

    if LFuncionE.EventosCount <> 0 then
      Assert.Fail('no debiera tener ningun evento guardado');
    Assert.Pass;
  finally
    LEnabled    := nil;
    LFuncionE   := nil;
    LFuncion    := nil;
    LModelo     := nil;
    LPlazaI1    := nil;
    LArcoI1     := nil;
    LPlazaO1    := nil;
    LArcoO1     := nil;
    LTransicion := nil;
    LPNet.Destroy;
  end;
end;

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_CondicionesOK_Varios_Eventos_1_Estado_Origen_1_Estado_Destino;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LToken : IToken;
  I      : Integer;

  LArcoI1 : IArcoIn;
  LPlazaI1: IPlaza;

  LArcoO1 : IArcoOut;
  LPlazaO1: IPlaza;

  LFuncion : ICondicion;
  LEnabled : IVariable;
  LFuncionE: ICondicion;

  LEvento: IEventEE;

  LTransicion: ITransicion;
begin
  LEnabled        := TdpnVariable.Create;
  LEnabled.Nombre := 'Enabled';
  LEnabled.Valor  := 0;

  LFuncionE                                     := TdpnCondicion_Evento_Prueba.Create;
  TdpnCondicion_Evento_Prueba(LFuncionE).Numero := 5;

  LFuncion                                                := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(LFuncion).Variable     := LEnabled;
  TdpnCondicion_es_tabla_variables(LFuncion).ValorToCheck := 5;

  LModelo := TdpnModelo.Create;

  LPlazaI1           := TdpnPlaza.Create;
  LPlazaI1.Nombre    := 'I1';
  LPlazaI1.Capacidad := 2;

  LArcoI1             := TdpnArcoIn.Create;
  LArcoI1.Plaza       := LPlazaI1;
  LArcoI1.Peso        := 1;
  LArcoI1.PesoEvaluar := 1;

  LPlazaO1           := TdpnPlaza.Create;
  LPlazaO1.Nombre    := 'O1';
  LPlazaO1.Capacidad := 2;

  LArcoO1       := TdpnArcoOut.Create;
  LArcoO1.Plaza := LPlazaO1;
  LArcoO1.Peso  := 1;

  LTransicion := TdpnTransicion.Create;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);
  LTransicion.AddCondicion(LFuncion);
  LTransicion.AddCondicion(LFuncionE);

  LModelo.Elementos.Add(LTransicion);
  LModelo.Elementos.Add(LPlazaI1);
  LModelo.Elementos.Add(LArcoI1);
  LModelo.Elementos.Add(LPlazaO1);
  LModelo.Elementos.Add(LEnabled);
  LModelo.Elementos.Add(LArcoO1);
  LModelo.Elementos.Add(LFuncionE);
  LModelo.Elementos.Add(LFuncion);

  LPNet := TdpnPetriNetCoordinador.Create;
  try
    LPNet.Grafo := LModelo;
    LPNet.Start;

    for I := 1 to 2 do
    begin
      LToken := TdpnTokenColoreado.Create;
      LPlazaI1.AddToken(LToken);
    end;

    LEnabled.Valor := 5;

    LEvento                       := TEventoPrueba.Create;
    TEventoPrueba(LEvento).Numero := 5;
    TEventoPrueba(LEvento).Texto  := 'Hola';
    LEvento.Post;

    LEvento                       := TEventoPrueba.Create;
    TEventoPrueba(LEvento).Numero := 5;
    TEventoPrueba(LEvento).Texto  := 'Hola';
    LEvento.Post;

    Sleep(10);

    Writeln('I1: ' + LPlazaI1.TokenCount.ToString + ' - O1: ' + LPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + LTransicion.TransicionesRealizadas.ToString + '/' + LTransicion.TransicionesIntentadas.ToString);

    if not((LPlazaI1.TokenCount = 0) and (LPlazaO1.TokenCount = 2)) then
      Assert.Fail('no ha transicionado bien');

    if LFuncionE.EventosCount <> 0 then
      Assert.Fail('no debiera tener ningun evento guardado');
    Assert.Pass;
  finally
    LEnabled    := nil;
    LFuncionE   := nil;
    LFuncion    := nil;
    LModelo     := nil;
    LPlazaI1    := nil;
    LArcoI1     := nil;
    LPlazaO1    := nil;
    LArcoO1     := nil;
    LTransicion := nil;
    LPNet.Destroy;
  end;
end;

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_Nombres;
const
  NOMBRE_MODELO = 'Modelo.1';
  NOMBRE_PLAZA = 'Plaza.I1';
var
  LModelo: IModelo;
  LPlazaI1: IPlaza;
begin
  LModelo := TdpnModelo.Create;
  LModelo.Nombre := NOMBRE_MODELO;

  LPlazaI1           := TdpnPlaza.Create;
  LPlazaI1.Nombre    := NOMBRE_PLAZA;
  LPlazaI1.Modelo    := LModelo;

  try
    Writeln('Plaza(1): ' + LPlazaI1.Nombre);
    if not(LPlazaI1.Nombre = NOMBRE_MODELO + SEPARADOR_NOMBRES + NOMBRE_PLAZA) then
      Assert.Fail('mal el nombre (1)');

    LPlazaI1.Modelo := nil;

    Writeln('Plaza(2): ' + LPlazaI1.Nombre);
    if not(LPlazaI1.Nombre = NOMBRE_PLAZA) then
      Assert.Fail('mal el nombre (2)');

    Assert.Pass;
  finally
    LModelo     := nil;
    LPlazaI1    := nil;
  end;
end;

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_PrimerToken_CondicionesOK_SegundoToken_CondicionesNoOK_Varios_Eventos_1_Estado_Origen_1_Estado_Destino;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LToken : IToken;
  I      : Integer;

  LArcoI1 : IArcoIn;
  LPlazaI1: IPlaza;

  LArcoO1 : IArcoOut;
  LPlazaO1: IPlaza;

  LFuncion : ICondicion;
  LEnabled : IVariable;
  LFuncionE: ICondicion;
  LAccion  : IAccion;

  LEvento: IEventEE;

  LTransicion: ITransicion;
begin
  LEnabled        := TdpnVariable.Create;
  LEnabled.Nombre := 'Enabled';
  LEnabled.Valor  := 0;

  LAccion                                        := TdpnAccion_tabla_variables.Create;
  TdpnAccion_tabla_variables(LAccion).Variable   := LEnabled;
  TdpnAccion_tabla_variables(LAccion).ValorToSet := 3;

  LFuncionE                                     := TdpnCondicion_Evento_Prueba.Create;
  TdpnCondicion_Evento_Prueba(LFuncionE).Numero := 5;

  LFuncion                                                := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(LFuncion).Variable     := LEnabled;
  TdpnCondicion_es_tabla_variables(LFuncion).ValorToCheck := 5;

  LModelo := TdpnModelo.Create;

  LPlazaI1           := TdpnPlaza.Create;
  LPlazaI1.Nombre    := 'I1';
  LPlazaI1.Capacidad := 2;

  LArcoI1             := TdpnArcoIn.Create;
  LArcoI1.Plaza       := LPlazaI1;
  LArcoI1.Peso        := 1;
  LArcoI1.PesoEvaluar := 1;

  LPlazaO1           := TdpnPlaza.Create;
  LPlazaO1.Nombre    := 'O1';
  LPlazaO1.Capacidad := 2;

  LArcoO1       := TdpnArcoOut.Create;
  LArcoO1.Plaza := LPlazaO1;
  LArcoO1.Peso  := 1;

  LTransicion := TdpnTransicion.Create;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);
  LTransicion.AddCondicion(LFuncion);
  LTransicion.AddCondicion(LFuncionE);
  LTransicion.AddAccion(LAccion);

  LModelo.Elementos.Add(LTransicion);
  LModelo.Elementos.Add(LPlazaI1);
  LModelo.Elementos.Add(LArcoI1);
  LModelo.Elementos.Add(LPlazaO1);
  LModelo.Elementos.Add(LEnabled);
  LModelo.Elementos.Add(LArcoO1);
  LModelo.Elementos.Add(LFuncionE);
  LModelo.Elementos.Add(LFuncion);
  LModelo.Elementos.Add(LAccion);

  LPNet := TdpnPetriNetCoordinador.Create;
  try
    LPNet.Grafo := LModelo;
    LPNet.Start;

    for I := 1 to 2 do
    begin
      LToken := TdpnTokenColoreado.Create;
      LPlazaI1.AddToken(LToken);
    end;

    LEnabled.Valor := 5;

    LEvento                       := TEventoPrueba.Create;
    TEventoPrueba(LEvento).Numero := 5;
    TEventoPrueba(LEvento).Texto  := 'Hola';
    LEvento.Post;

    LEvento                       := TEventoPrueba.Create;
    TEventoPrueba(LEvento).Numero := 5;
    TEventoPrueba(LEvento).Texto  := 'Hola';
    LEvento.Post;

    Sleep(10);

    Writeln('I1: ' + LPlazaI1.TokenCount.ToString + ' - O1: ' + LPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + LTransicion.TransicionesRealizadas.ToString + '/' + LTransicion.TransicionesIntentadas.ToString);

    if not((LPlazaI1.TokenCount = 1) and (LPlazaO1.TokenCount = 1)) then
      Assert.Fail('no ha transicionado bien');

    if LFuncionE.EventosCount <> 0 then
      Assert.Fail('no debiera tener ningun evento guardado');
    Assert.Pass;
  finally
    LEnabled    := nil;
    LFuncionE   := nil;
    LAccion     := nil;
    LFuncion    := nil;
    LModelo     := nil;
    LPlazaI1    := nil;
    LArcoI1     := nil;
    LPlazaO1    := nil;
    LArcoO1     := nil;
    LTransicion := nil;
    LPNet.Destroy;
  end;
end;

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_SuperPlaza_Extrae_Token;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LToken : IToken;
  I      : Integer;

  LArcoI1 : IArcoIn;
  LPlazaI1: IPlaza;

  LArcoO1 : IArcoOut;
  LPlazaO1: IPlaza;

  LFuncion : ICondicion;
  LEnabled : IVariable;
  LFuncionE: ICondicion;
  LAccion  : IAccion;

  LEvento: IEventEE;

  LTransicion: ITransicion;

  LArcoI2      : IArcoIn;
  LSuperPlazaI2: IPlaza;

  LArcoO2 : IArcoOut;
  LPlazaO2: IPlaza;

  LFuncion2   : ICondicion;
  LTransicion2: ITransicion;
begin
  LEnabled        := TdpnVariable.Create;
  LEnabled.Nombre := 'Enabled';
  LEnabled.Valor  := 0;

  LFuncionE                                     := TdpnCondicion_Evento_Prueba.Create;
  TdpnCondicion_Evento_Prueba(LFuncionE).Numero := 5;

  LFuncion                                                := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(LFuncion).Variable     := LEnabled;
  TdpnCondicion_es_tabla_variables(LFuncion).ValorToCheck := 5;

  LFuncion2                                                := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(LFuncion2).Variable     := LEnabled;
  TdpnCondicion_es_tabla_variables(LFuncion2).ValorToCheck := 3;

  LModelo := TdpnModelo.Create;

  LPlazaI1           := TdpnPlaza.Create;
  LPlazaI1.Nombre    := 'I1';
  LPlazaI1.Capacidad := 2;

  LArcoI1             := TdpnArcoIn.Create;
  LArcoI1.Plaza       := LPlazaI1;
  LArcoI1.Peso        := 1;
  LArcoI1.PesoEvaluar := 1;

  LPlazaO1           := TdpnPlaza.Create;
  LPlazaO1.Nombre    := 'O1';
  LPlazaO1.Capacidad := 2;

  LArcoO1       := TdpnArcoOut.Create;
  LArcoO1.Plaza := LPlazaO1;
  LArcoO1.Peso  := 1;

  LTransicion := TdpnTransicion.Create;
  Writeln('Transicion: ' + LTransicion.ID.ToString);
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);
  LTransicion.AddCondicion(LFuncion);
  LTransicion.AddCondicion(LFuncionE);

  LModelo.Elementos.Add(LTransicion);
  LModelo.Elementos.Add(LPlazaI1);
  LModelo.Elementos.Add(LArcoI1);
  LModelo.Elementos.Add(LPlazaO1);
  LModelo.Elementos.Add(LEnabled);
  LModelo.Elementos.Add(LArcoO1);
  LModelo.Elementos.Add(LFuncionE);
  LModelo.Elementos.Add(LFuncion);
  LModelo.Elementos.Add(LFuncion2);

  LSuperPlazaI2 := TdpnPlazaSuper.Create;
  TdpnPlazaSuper(LSuperPlazaI2).AddPlaza(LPlazaI1);
  LPlazaI1.Nombre    := 'I2';
  LPlazaI1.Capacidad := 2;

  LArcoI2             := TdpnArcoIn.Create;
  LArcoI2.Plaza       := LSuperPlazaI2;
  LArcoI2.Peso        := 1;
  LArcoI2.PesoEvaluar := 1;

  LPlazaO2           := TdpnPlaza.Create;
  LPlazaO2.Nombre    := 'O2';
  LPlazaO2.Capacidad := 2;

  LArcoO2       := TdpnArcoOut.Create;
  LArcoO2.Plaza := LPlazaO2;
  LArcoO2.Peso  := 1;

  LTransicion2 := TdpnTransicion.Create;
  Writeln('Transicion2: ' + LTransicion2.ID.ToString);
  LTransicion2.AddArcoIn(LArcoI2);
  LTransicion2.AddArcoOut(LArcoO2);
  LTransicion2.AddCondicion(LFuncion2);

  LModelo.Elementos.Add(LTransicion2);
  LModelo.Elementos.Add(LSuperPlazaI2);
  LModelo.Elementos.Add(LArcoI2);
  LModelo.Elementos.Add(LPlazaO2);
  LModelo.Elementos.Add(LArcoO2);

  LPNet := TdpnPetriNetCoordinador.Create;
  try
    LPNet.Grafo := LModelo;
    LPNet.Start;

    for I := 1 to 1 do
    begin
      LToken := TdpnTokenColoreado.Create;
      LPlazaI1.AddToken(LToken);
    end;

    LEvento                       := TEventoPrueba.Create;
    TEventoPrueba(LEvento).Numero := 5;
    TEventoPrueba(LEvento).Texto  := 'Hola';
    LEvento.Post;

    LEvento                       := TEventoPrueba.Create;
    TEventoPrueba(LEvento).Numero := 5;
    TEventoPrueba(LEvento).Texto  := 'Hola';
    LEvento.Post;

    Sleep(500);

    if not((LPlazaI1.TokenCount = 1) and (LPlazaO1.TokenCount = 0) and (LPlazaO2.TokenCount = 0)) then
      Assert.Fail('no va bien');

    LEnabled.Valor := 3;

    Sleep(500);

    if not((LPlazaI1.TokenCount = 0) and (LPlazaO1.TokenCount = 0) and (LPlazaO2.TokenCount = 1)) then
      Assert.Fail('no va bien *');

    Writeln('I1: ' + LPlazaI1.TokenCount.ToString + ' - O1: ' + LPlazaO1.TokenCount.ToString + ' - O2: ' + LPlazaO2.TokenCount.ToString);
    Writeln('Datos1: ' + LTransicion.TransicionesRealizadas.ToString + '/' + LTransicion.TransicionesIntentadas.ToString);
    Writeln('Datos2: ' + LTransicion2.TransicionesRealizadas.ToString + '/' + LTransicion2.TransicionesIntentadas.ToString);

    if LFuncionE.EventosCount <> 0 then
      Assert.Fail('no debiera tener ningun evento guardado');
    Assert.Pass;
  finally
    LEnabled    := nil;
    LFuncionE   := nil;
    LAccion     := nil;
    LFuncion    := nil;
    LModelo     := nil;
    LPlazaI1    := nil;
    LArcoI1     := nil;
    LPlazaO1    := nil;
    LArcoO1     := nil;
    LTransicion := nil;
    LPNet.Destroy;
  end;
end;

initialization

TDUnitX.RegisterTestFixture(TPetriNetCoreTesting_PetriNet);

end.
