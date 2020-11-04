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
  //[TestFixture]
  TPetriNetCoreTesting_PetriNet = class
  public
    // [Test]
    procedure Test_PetriNet_Arranca_Para_OK;
    // [Test]
    procedure Test_PetriNet_ASignacionGrafo_Start;
    // [Test]
    procedure Test_PetriNet_ASignacionGrafo_TransicionSimple_1_origen_1_destino;
    // [Test]
    procedure Test_PetriNet_ASignacionGrafo_TransicionSimple_1_origen_2_destinos;
    // [Test]
    procedure Test_PetriNet_ASignacionGrafo_TransicionSimple_1_origen_2_destinos_Varios_Tokens;

    // [Test]
    procedure Test_PetriNet_CondicionesNoOK_Varios_Eventos_1_Estado_Origen_1_Estado_Destino;
    // [Test]
    procedure Test_PetriNet_CondicionesOK_Varios_Eventos_1_Estado_Origen_1_Estado_Destino;
    // [Test]
    procedure Test_PetriNet_PrimerToken_CondicionesOK_SegundoToken_CondicionesNoOK_Varios_Eventos_1_Estado_Origen_1_Estado_Destino;
    [Test]
    procedure Test_PetriNet_SuperPlaza_Extrae_Token;
    [Test]
    procedure Test_PetriNet_ArcoReset;
  end;

implementation

uses
  System.SysUtils,

  DPN.Core.Testing.Funciones,
  DPN.TokenColoreado;

{ TPetriNetCoreTesting_PetriNet }

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_ArcoReset;
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

  FPlazaO1           := TdpnPlaza.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 2;

  FArcoO1       := TdpnArcoReset.Create;
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
      FPlazaO1.AddToken(LToken);
    end;

    for I := 1 to 1 do
    begin
      LToken := TdpnTokenColoreado.Create;
      FPlazaI1.AddToken(LToken);
    end;

    Sleep(100);

    if not(FPlazaI1.TokenCount = 0) and (FPlazaO1.TokenCount = 0) then
      Assert.Fail('no ha transicionado bien');

    Writeln('I1: ' + FPlazaI1.TokenCount.ToString + ' - O1: ' + FPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + FTransicion.TransicionesRealizadas.ToString + '/' + FTransicion.TransicionesIntentadas.ToString);
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

  FPlazaO1           := TdpnPlaza.Create;
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

    if not(FPlazaI1.TokenCount = 0) and (FPlazaO1.TokenCount = 1) then
      Assert.Fail('no ha transicionado');

    Writeln('I1: ' + FPlazaI1.TokenCount.ToString + ' - O1: ' + FPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + FTransicion.TransicionesRealizadas.ToString + '/' + FTransicion.TransicionesIntentadas.ToString);
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

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_ASignacionGrafo_TransicionSimple_1_origen_2_destinos;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LToken : IToken;
  I      : Integer;

  FArcoI1 : IArcoIn;
  FPlazaI1: IPlaza;

  FArcoO1 : IArcoOut;
  FPlazaO1: IPlaza;

  FArcoO2 : IArcoOut;
  FPlazaO2: IPlaza;

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

  FPlazaO1           := TdpnPlaza.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 1;

  FArcoO1       := TdpnArcoOut.Create;
  FArcoO1.Plaza := FPlazaO1;
  FArcoO1.Peso  := 1;

  FPlazaO2           := TdpnPlaza.Create;
  FPlazaO2.Nombre    := 'O2';
  FPlazaO2.Capacidad := 1;

  FArcoO2       := TdpnArcoOut.Create;
  FArcoO2.Plaza := FPlazaO2;
  FArcoO2.Peso  := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);
  FTransicion.AddArcoOut(FArcoO2);

  LModelo.Elementos.Add(FTransicion);
  try
    LPNet := TdpnPetriNetCoordinador.Create;
    // LPNet.MultipleEnablednessOfTransitions := False;
    LPNet.Grafo := LModelo;
    LPNet.Start;

    for I := 1 to 1 do
    begin
      LToken := TdpnTokenColoreado.Create;
      FPlazaI1.AddToken(LToken);
    end;

    Sleep(500);

    if not((FPlazaI1.TokenCount = 0) and (FPlazaO1.TokenCount = 1) and (FPlazaO2.TokenCount = 1)) then
      Assert.Fail('no ha transicionado');

    Writeln('I1: ' + FPlazaI1.TokenCount.ToString + ' - O1: ' + FPlazaO1.TokenCount.ToString + ' - O2: ' + FPlazaO2.TokenCount.ToString);
    Writeln('Datos: ' + FTransicion.TransicionesRealizadas.ToString + '/' + FTransicion.TransicionesIntentadas.ToString);
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

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_ASignacionGrafo_TransicionSimple_1_origen_2_destinos_Varios_Tokens;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LToken : IToken;
  I      : Integer;

  FArcoI1 : IArcoIn;
  FPlazaI1: IPlaza;

  FArcoO1 : IArcoOut;
  FPlazaO1: IPlaza;

  FArcoO2 : IArcoOut;
  FPlazaO2: IPlaza;

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

  FPlazaO1           := TdpnPlaza.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 5;

  FArcoO1       := TdpnArcoOut.Create;
  FArcoO1.Plaza := FPlazaO1;
  FArcoO1.Peso  := 1;

  FPlazaO2           := TdpnPlaza.Create;
  FPlazaO2.Nombre    := 'O2';
  FPlazaO2.Capacidad := 5;

  FArcoO2       := TdpnArcoOut.Create;
  FArcoO2.Plaza := FPlazaO2;
  FArcoO2.Peso  := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);
  FTransicion.AddArcoOut(FArcoO2);

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

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_CondicionesNoOK_Varios_Eventos_1_Estado_Origen_1_Estado_Destino;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LToken : IToken;
  I      : Integer;

  FArcoI1 : IArcoIn;
  FPlazaI1: IPlaza;

  FArcoO1 : IArcoOut;
  FPlazaO1: IPlaza;

  FFuncion : ICondicion;
  FEnabled : IVariable;
  FFuncionE: ICondicion;

  LEvento: IEventEE;

  FTransicion: ITransicion;
begin
  FEnabled        := TdpnVariable.Create;
  FEnabled.Nombre := 'Enabled';
  FEnabled.Valor  := 0;

  FFuncionE                                     := TdpnCondicion_Evento_Prueba.Create;
  TdpnCondicion_Evento_Prueba(FFuncionE).Numero := 5;

  FFuncion                                                := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(FFuncion).Variable     := FEnabled;
  TdpnCondicion_es_tabla_variables(FFuncion).ValorToCheck := 5;

  LModelo := TdpnModelo.Create;

  FPlazaI1           := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'I1';
  FPlazaI1.Capacidad := 2;

  FArcoI1             := TdpnArcoIn.Create;
  FArcoI1.Plaza       := FPlazaI1;
  FArcoI1.Peso        := 1;
  FArcoI1.PesoEvaluar := 1;

  FPlazaO1           := TdpnPlaza.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 1;

  FArcoO1       := TdpnArcoOut.Create;
  FArcoO1.Plaza := FPlazaO1;
  FArcoO1.Peso  := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);
  FTransicion.AddCondicion(FFuncion);
  FTransicion.AddCondicion(FFuncionE);

  LModelo.Elementos.Add(FTransicion);

  LPNet := TdpnPetriNetCoordinador.Create;
  try
    LPNet.Grafo := LModelo;
    LPNet.Start;

    for I := 1 to 2 do
    begin
      LToken := TdpnTokenColoreado.Create;
      FPlazaI1.AddToken(LToken);
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

    Writeln('I1: ' + FPlazaI1.TokenCount.ToString + ' - O1: ' + FPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + FTransicion.TransicionesRealizadas.ToString + '/' + FTransicion.TransicionesIntentadas.ToString);

    if not((FPlazaI1.TokenCount = 2) and (FPlazaO1.TokenCount = 0)) then
      Assert.Fail('no ha transicionado bien');

    if FFuncionE.EventosCount <> 0 then
      Assert.Fail('no debiera tener ningun evento guardado');
    Assert.Pass;
  finally
    FEnabled    := nil;
    FFuncionE   := nil;
    FFuncion    := nil;
    LModelo     := nil;
    FPlazaI1    := nil;
    FArcoI1     := nil;
    FPlazaO1    := nil;
    FArcoO1     := nil;
    FTransicion := nil;
    LPNet.Destroy;
  end;
end;

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_CondicionesOK_Varios_Eventos_1_Estado_Origen_1_Estado_Destino;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LToken : IToken;
  I      : Integer;

  FArcoI1 : IArcoIn;
  FPlazaI1: IPlaza;

  FArcoO1 : IArcoOut;
  FPlazaO1: IPlaza;

  FFuncion : ICondicion;
  FEnabled : IVariable;
  FFuncionE: ICondicion;

  LEvento: IEventEE;

  FTransicion: ITransicion;
begin
  FEnabled        := TdpnVariable.Create;
  FEnabled.Nombre := 'Enabled';
  FEnabled.Valor  := 0;

  FFuncionE                                     := TdpnCondicion_Evento_Prueba.Create;
  TdpnCondicion_Evento_Prueba(FFuncionE).Numero := 5;

  FFuncion                                                := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(FFuncion).Variable     := FEnabled;
  TdpnCondicion_es_tabla_variables(FFuncion).ValorToCheck := 5;

  LModelo := TdpnModelo.Create;

  FPlazaI1           := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'I1';
  FPlazaI1.Capacidad := 2;

  FArcoI1             := TdpnArcoIn.Create;
  FArcoI1.Plaza       := FPlazaI1;
  FArcoI1.Peso        := 1;
  FArcoI1.PesoEvaluar := 1;

  FPlazaO1           := TdpnPlaza.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 2;

  FArcoO1       := TdpnArcoOut.Create;
  FArcoO1.Plaza := FPlazaO1;
  FArcoO1.Peso  := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);
  FTransicion.AddCondicion(FFuncion);
  FTransicion.AddCondicion(FFuncionE);

  LModelo.Elementos.Add(FTransicion);

  LPNet := TdpnPetriNetCoordinador.Create;
  try
    LPNet.Grafo := LModelo;
    LPNet.Start;

    for I := 1 to 2 do
    begin
      LToken := TdpnTokenColoreado.Create;
      FPlazaI1.AddToken(LToken);
    end;

    FEnabled.Valor := 5;

    LEvento                       := TEventoPrueba.Create;
    TEventoPrueba(LEvento).Numero := 5;
    TEventoPrueba(LEvento).Texto  := 'Hola';
    LEvento.Post;

    LEvento                       := TEventoPrueba.Create;
    TEventoPrueba(LEvento).Numero := 5;
    TEventoPrueba(LEvento).Texto  := 'Hola';
    LEvento.Post;

    Sleep(10);

    Writeln('I1: ' + FPlazaI1.TokenCount.ToString + ' - O1: ' + FPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + FTransicion.TransicionesRealizadas.ToString + '/' + FTransicion.TransicionesIntentadas.ToString);

    if not((FPlazaI1.TokenCount = 0) and (FPlazaO1.TokenCount = 2)) then
      Assert.Fail('no ha transicionado bien');

    if FFuncionE.EventosCount <> 0 then
      Assert.Fail('no debiera tener ningun evento guardado');
    Assert.Pass;
  finally
    FEnabled    := nil;
    FFuncionE   := nil;
    FFuncion    := nil;
    LModelo     := nil;
    FPlazaI1    := nil;
    FArcoI1     := nil;
    FPlazaO1    := nil;
    FArcoO1     := nil;
    FTransicion := nil;
    LPNet.Destroy;
  end;
end;

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_PrimerToken_CondicionesOK_SegundoToken_CondicionesNoOK_Varios_Eventos_1_Estado_Origen_1_Estado_Destino;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LToken : IToken;
  I      : Integer;

  FArcoI1 : IArcoIn;
  FPlazaI1: IPlaza;

  FArcoO1 : IArcoOut;
  FPlazaO1: IPlaza;

  FFuncion : ICondicion;
  FEnabled : IVariable;
  FFuncionE: ICondicion;
  FAccion  : IAccion;

  LEvento: IEventEE;

  FTransicion: ITransicion;
begin
  FEnabled        := TdpnVariable.Create;
  FEnabled.Nombre := 'Enabled';
  FEnabled.Valor  := 0;

  FAccion                                        := TdpnAccion_tabla_variables.Create;
  TdpnAccion_tabla_variables(FAccion).Variable   := FEnabled;
  TdpnAccion_tabla_variables(FAccion).ValorToSet := 3;

  FFuncionE                                     := TdpnCondicion_Evento_Prueba.Create;
  TdpnCondicion_Evento_Prueba(FFuncionE).Numero := 5;

  FFuncion                                                := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(FFuncion).Variable     := FEnabled;
  TdpnCondicion_es_tabla_variables(FFuncion).ValorToCheck := 5;

  LModelo := TdpnModelo.Create;

  FPlazaI1           := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'I1';
  FPlazaI1.Capacidad := 2;

  FArcoI1             := TdpnArcoIn.Create;
  FArcoI1.Plaza       := FPlazaI1;
  FArcoI1.Peso        := 1;
  FArcoI1.PesoEvaluar := 1;

  FPlazaO1           := TdpnPlaza.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 2;

  FArcoO1       := TdpnArcoOut.Create;
  FArcoO1.Plaza := FPlazaO1;
  FArcoO1.Peso  := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);
  FTransicion.AddCondicion(FFuncion);
  FTransicion.AddCondicion(FFuncionE);
  FTransicion.AddAccion(FAccion);

  LModelo.Elementos.Add(FTransicion);

  LPNet := TdpnPetriNetCoordinador.Create;
  try
    LPNet.Grafo := LModelo;
    LPNet.Start;

    for I := 1 to 2 do
    begin
      LToken := TdpnTokenColoreado.Create;
      FPlazaI1.AddToken(LToken);
    end;

    FEnabled.Valor := 5;

    LEvento                       := TEventoPrueba.Create;
    TEventoPrueba(LEvento).Numero := 5;
    TEventoPrueba(LEvento).Texto  := 'Hola';
    LEvento.Post;

    LEvento                       := TEventoPrueba.Create;
    TEventoPrueba(LEvento).Numero := 5;
    TEventoPrueba(LEvento).Texto  := 'Hola';
    LEvento.Post;

    Sleep(10);

    Writeln('I1: ' + FPlazaI1.TokenCount.ToString + ' - O1: ' + FPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + FTransicion.TransicionesRealizadas.ToString + '/' + FTransicion.TransicionesIntentadas.ToString);

    if not((FPlazaI1.TokenCount = 1) and (FPlazaO1.TokenCount = 1)) then
      Assert.Fail('no ha transicionado bien');

    if FFuncionE.EventosCount <> 0 then
      Assert.Fail('no debiera tener ningun evento guardado');
    Assert.Pass;
  finally
    FEnabled    := nil;
    FFuncionE   := nil;
    FAccion     := nil;
    FFuncion    := nil;
    LModelo     := nil;
    FPlazaI1    := nil;
    FArcoI1     := nil;
    FPlazaO1    := nil;
    FArcoO1     := nil;
    FTransicion := nil;
    LPNet.Destroy;
  end;
end;

procedure TPetriNetCoreTesting_PetriNet.Test_PetriNet_SuperPlaza_Extrae_Token;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LToken : IToken;
  I      : Integer;

  FArcoI1 : IArcoIn;
  FPlazaI1: IPlaza;

  FArcoO1 : IArcoOut;
  FPlazaO1: IPlaza;

  FFuncion : ICondicion;
  FEnabled : IVariable;
  FFuncionE: ICondicion;
  FAccion  : IAccion;

  LEvento: IEventEE;

  FTransicion: ITransicion;

  FArcoI2      : IArcoIn;
  FSuperPlazaI2: IPlaza;

  FArcoO2 : IArcoOut;
  FPlazaO2: IPlaza;

  FFuncion2   : ICondicion;
  FTransicion2: ITransicion;
begin
  FEnabled        := TdpnVariable.Create;
  FEnabled.Nombre := 'Enabled';
  FEnabled.Valor  := 0;

  FFuncionE                                     := TdpnCondicion_Evento_Prueba.Create;
  TdpnCondicion_Evento_Prueba(FFuncionE).Numero := 5;

  FFuncion                                                := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(FFuncion).Variable     := FEnabled;
  TdpnCondicion_es_tabla_variables(FFuncion).ValorToCheck := 5;

  FFuncion2                                                := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(FFuncion2).Variable     := FEnabled;
  TdpnCondicion_es_tabla_variables(FFuncion2).ValorToCheck := 3;

  LModelo := TdpnModelo.Create;

  FPlazaI1           := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'I1';
  FPlazaI1.Capacidad := 2;

  FArcoI1             := TdpnArcoIn.Create;
  FArcoI1.Plaza       := FPlazaI1;
  FArcoI1.Peso        := 1;
  FArcoI1.PesoEvaluar := 1;

  FPlazaO1           := TdpnPlaza.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 2;

  FArcoO1       := TdpnArcoOut.Create;
  FArcoO1.Plaza := FPlazaO1;
  FArcoO1.Peso  := 1;

  FTransicion := TdpnTransicion.Create;
  Writeln('Transicion: ' + FTransicion.ID.ToString);
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);
  FTransicion.AddCondicion(FFuncion);
  FTransicion.AddCondicion(FFuncionE);

  LModelo.Elementos.Add(FTransicion);

  FSuperPlazaI2 := TdpnPlazaSuper.Create;
  TdpnPlazaSuper(FSuperPlazaI2).AddPlaza(FPlazaI1);
  FPlazaI1.Nombre    := 'I2';
  FPlazaI1.Capacidad := 2;

  FArcoI2             := TdpnArcoIn.Create;
  FArcoI2.Plaza       := FSuperPlazaI2;
  FArcoI2.Peso        := 1;
  FArcoI2.PesoEvaluar := 1;

  FPlazaO2           := TdpnPlaza.Create;
  FPlazaO2.Nombre    := 'O2';
  FPlazaO2.Capacidad := 2;

  FArcoO2       := TdpnArcoOut.Create;
  FArcoO2.Plaza := FPlazaO2;
  FArcoO2.Peso  := 1;

  FTransicion2 := TdpnTransicion.Create;
  Writeln('Transicion2: ' + FTransicion2.ID.ToString);
  FTransicion2.AddArcoIn(FArcoI2);
  FTransicion2.AddArcoOut(FArcoO2);
  FTransicion2.AddCondicion(FFuncion2);

  LModelo.Elementos.Add(FTransicion2);

  LPNet := TdpnPetriNetCoordinador.Create;
  try
    LPNet.Grafo := LModelo;
    LPNet.Start;

    for I := 1 to 1 do
    begin
      LToken := TdpnTokenColoreado.Create;
      FPlazaI1.AddToken(LToken);
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

    if not((FPlazaI1.TokenCount = 1) and (FPlazaO1.TokenCount = 0) and (FPlazaO2.TokenCount = 0)) then
      Assert.Fail('no va bien');

    FEnabled.Valor := 3;

    Sleep(500);

    if not((FPlazaI1.TokenCount = 0) and (FPlazaO1.TokenCount = 0) and (FPlazaO2.TokenCount = 1)) then
      Assert.Fail('no va bien *');

    Writeln('I1: ' + FPlazaI1.TokenCount.ToString + ' - O1: ' + FPlazaO1.TokenCount.ToString + ' - O2: ' + FPlazaO2.TokenCount.ToString);
    Writeln('Datos1: ' + FTransicion.TransicionesRealizadas.ToString + '/' + FTransicion.TransicionesIntentadas.ToString);
    Writeln('Datos2: ' + FTransicion2.TransicionesRealizadas.ToString + '/' + FTransicion2.TransicionesIntentadas.ToString);

    if FFuncionE.EventosCount <> 0 then
      Assert.Fail('no debiera tener ningun evento guardado');
    Assert.Pass;
  finally
    FEnabled    := nil;
    FFuncionE   := nil;
    FAccion     := nil;
    FFuncion    := nil;
    LModelo     := nil;
    FPlazaI1    := nil;
    FArcoI1     := nil;
    FPlazaO1    := nil;
    FArcoO1     := nil;
    FTransicion := nil;
    LPNet.Destroy;
  end;
end;

initialization

//TDUnitX.RegisterTestFixture(TPetriNetCoreTesting_PetriNet);

end.
