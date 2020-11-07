{$I Defines.inc}
unit DPN.Core.Testing.PetriNetCoordinador;

interface

uses
  System.Classes,
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
  DPN.Plaza.Start,
  DPN.Plaza.Super,
  DPN.Plaza.Finish,
  DPN.ArcoIn,
  DPN.ArcoReset,
  DPN.Condicion,
  DPN.ArcoOut,
  DPN.Transicion;

type
  TThreadTestModificaPlaza = class(TThread)
    protected
      FPlaza: IPlaza;
      procedure Execute; override;
    public
      constructor Create(const APlaza: IPlaza);
  end;

{$IFDEF TESTS_HABILITADOS}
  [TestFixture]
{$ENDIF}
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
    (*[Test]*)
    procedure Test_Maps_vs_Diccionarios; //es un test de rendimiento, comparativa de tiempos, no de que funcionen bien
    (*[Test]
    [TestCase('Test=1','1')]
    [TestCase('Test=5','5')]
    [TestCase('Test=10','10')]
    [TestCase('Test=100','100')]*)
    procedure Test_Marcado_Cambiante(const ANoEstados: integer); //no es un test real
    [Test]
    [TestCase('Test=2,1','2,1')]
    [TestCase('Test=5,1','5,1')]
    [TestCase('Test=10,1','10,1')]
    [TestCase('Test=20,1','20,1')]
    [TestCase('Test=2,5','2,5')]
    [TestCase('Test=5,5','5,5')]
    [TestCase('Test=10,5','10,5')]
    [TestCase('Test=20,5','20,5')]
    procedure Test_Evolucion_Y_Timings_Sin_Eventos(const ANoEstadosIntermedios: Integer; const ANoCiclosEjecutar: Integer);
  end;

implementation

uses
  System.SysUtils,

  Event.Engine.Utils,
  DPN.Core.Testing.Funciones,
  DPN.TokenColoreado;

{ TPetriNetCoreTesting_PetriNet }

procedure TPetriNetCoreTesting_PetriNet.Test_Evolucion_Y_Timings_Sin_Eventos(const ANoEstadosIntermedios, ANoCiclosEjecutar: Integer);
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;

  LPlazaStart : IPlaza;
  LArcoStartI : IArcoIn;
  LArcoStartO : IArcoOut;
  LTransicionStart: ITransicion;
  LPlazaFin : IPlaza;
  LArcoFinI : IArcoIn;
  LArcoFinO : IArcoOut;
  LTransicionFin: ITransicion;

  I : Integer;

  LArcoI : IArcoIn;
  LPlaza: IPlaza;
  LArcoO : IArcoOut;
  LTransicion: ITransicion;

  LPlaza1 : IPlaza;
  LArcoOBack: IArcoOut;

  LFuncionF : ICondicion;
  LEnabled : IVariable;
  LFuncionNF: ICondicion;
  LAccion  : IAccion;
begin
  LModelo        := TdpnModelo.Create;
  LModelo.Nombre := 'Prueba.Bucle';

  //funciones y acciones
  LEnabled        := TdpnVariable.Create;
  LEnabled.Nombre := 'Enabled';
  LEnabled.Valor  := 0;

  LModelo.Elementos.Add(LEnabled);

  LAccion                                                         := TdpnAccion_incrementar_tabla_variables.Create;
  LAccion.Nombre                                                  := 'Accion_' + LAccion.ID.ToString;
  TdpnAccion_incrementar_tabla_variables(LAccion).Variable        := LEnabled;
  TdpnAccion_incrementar_tabla_variables(LAccion).ValorIncremento := 1;

  LFuncionF                                                := TdpnCondicion_es_tabla_variables.Create;
  LFuncionF.Nombre                                         := 'Funcion_' + LFuncionF.ID.ToString;
  TdpnCondicion_es_tabla_variables(LFuncionF).Variable     := LEnabled;
  TdpnCondicion_es_tabla_variables(LFuncionF).ValorToCheck := ANoCiclosEjecutar;

  LFuncionNF                                                := TdpnCondicion_es_tabla_variables.Create;
  LFuncionNF.Nombre                                         := 'Funcion_' + LFuncionNF.ID.ToString;
  LFuncionNF.IsCondicionNegada                              := True;
  TdpnCondicion_es_tabla_variables(LFuncionNF).Variable     := LEnabled;
  TdpnCondicion_es_tabla_variables(LFuncionNF).ValorToCheck := ANoCiclosEjecutar;

  LModelo.Elementos.Add(LAccion);
  LModelo.Elementos.Add(LFuncionF);
  LModelo.Elementos.Add(LFuncionNF);

  //START
  LPlazaStart           := TdpnPlazaStart.Create;
  LPlazaStart.Nombre    := 'PlazaStart';

  LArcoStartI             := TdpnArcoIn.Create;
  LArcoStartI.Nombre      := 'ArcoStartI';
  LArcoStartI.Plaza       := LPlazaStart;
  LArcoStartI.Peso        := 1;
  LArcoStartI.PesoEvaluar := 1;

  LArcoStartO           := TdpnArcoOut.Create;
  LArcoStartO.Nombre    := 'ArcoStartO';
  LArcoStartO.Peso      := 1;

  LTransicionStart           := TdpnTransicion.Create;
  LTransicionStart.Nombre    := 'TransicionStart';
  LTransicionStart.AddArcoIn(LArcoStartI);
  LTransicionStart.AddArcoOut(LArcoStartO);

  LModelo.Elementos.Add(LTransicionStart);
  LModelo.Elementos.Add(LPlazaStart);
  LModelo.Elementos.Add(LArcoStartI);
  LModelo.Elementos.Add(LArcoStartO);

  //FIN
  LPlazaFin           := TdpnPlaza.Create;
  LPlazaFin.Capacidad := 1;
  LPlazaFin.Nombre    := 'PlazaFin';

  LArcoFinI             := TdpnArcoIn.Create;
  LArcoFinI.Nombre      := 'ArcoFinI';
  //LArcoFinI.Plaza       := LPlazaFin;
  LArcoFinI.Peso        := 1;
  LArcoFinI.PesoEvaluar := 1;

  LArcoFinO           := TdpnArcoOut.Create;
  LArcoFinO.Nombre    := 'ArcoFinO';
  LArcoFinO.Plaza     := LPlazaFin;
  LArcoFinO.Peso      := 1;

  LTransicionFin           := TdpnTransicion.Create;
  LTransicionFin.Nombre    := 'TransicionFin';
  LTransicionFin.AddArcoIn(LArcoFinI);
  LTransicionFin.AddArcoOut(LArcoFinO);
  LTransicionFin.AddCondicion(LFuncionF);

  LModelo.Elementos.Add(LTransicionFin);
  LModelo.Elementos.Add(LPlazaFin);
  LModelo.Elementos.Add(LArcoFinI);
  LModelo.Elementos.Add(LArcoFinO);

  //INTERMEDIO
  for I := 1 to ANoEstadosIntermedios do
  begin
    LPlaza           := TdpnPlaza.Create;
    LPlaza.Capacidad := 1;
    LPlaza.Nombre    := 'Plaza' + I.ToString;

    LArcoI             := TdpnArcoIn.Create;
    LArcoI.Nombre      := 'ArcoI' + I.ToString;
    LArcoI.Plaza       := LPlaza;
    LArcoI.Peso        := 1;
    LArcoI.PesoEvaluar := 1;

    LArcoO           := TdpnArcoOut.Create;
    LArcoO.Nombre    := 'ArcoO' + I.ToString;
    LArcoO.Peso      := 1;

    LTransicion := TdpnTransicion.Create;
    LTransicion.Nombre := 'Transicion' + I.ToString;
    LTransicion.AddArcoIn(LArcoI);
    LTransicion.AddArcoOut(LArcoO);

    LModelo.Elementos.Add(LTransicion);
    LModelo.Elementos.Add(LPlaza);
    LModelo.Elementos.Add(LArcoI);
    LModelo.Elementos.Add(LArcoO);

    case I of
      1:
        begin
          LArcoStartO.Plaza := LPlaza;
          LArcoOBack := LArcoO;
          LPlaza1 := LPlaza;
          if I = ANoEstadosIntermedios then
           begin
             LArcoFinI.Plaza  := LPlaza;
             LArcoOBack.Plaza := LPlaza;
             LArcoO.Plaza     := LPlaza1; //linkar a primer estado del bucle formado
             //agregamos funcion
             LTransicion.AddCondicion(LFuncionNF);
           end;
        end;
      else begin
             if I = ANoEstadosIntermedios then
             begin
               LArcoFinI.Plaza  := LPlaza;
               LArcoOBack.Plaza := LPlaza;
               LArcoO.Plaza     := LPlaza1; //linkar a primer estado del bucle formado
               //agregamos funcion
               LTransicion.AddCondicion(LFuncionNF);
               LTransicion.AddAccion(LAccion);
             end
             else begin
                    LArcoOBack.Plaza := LPlaza;
                    LArcoOBack := LArcoO;
                  end;
           end;
    end;
  end;

  LPNet := TdpnPetriNetCoordinador.Create;
  try
    LPNet.Grafo := LModelo;
    LPNet.Start;

    Sleep(1000);

    WriteLn('--ARCOS--');
    LModelo.GetArcos.ForEach(procedure (const AArco: IArco)
                              begin
                                WriteLn(AArco.LogAsString);
                              end
                             );
    WriteLn('--PLAZAS--');
    LModelo.GetPlazas.ForEach(procedure (const APlaza: IPlaza)
                              begin
                                WriteLn(APlaza.LogAsString);
                              end
                             );
    WriteLn('--TRANSICIONES--');
    LModelo.GetTransiciones.ForEach(procedure (const ATransicion: ITransicion)
                              begin
                                WriteLn(ATransicion.LogAsString);
                              end
                             );
    WriteLn('--VARIABLES--');
    LModelo.GetVariables.ForEach(procedure (const AVariable: IVariable)
                              begin
                                WriteLn(AVariable.LogAsString);
                              end
                             );

    if not(LPlazaFin.TokenCount = 1) then
      Assert.Fail('no ha transicionado bien');
    Assert.Pass;
  finally
    LModelo := nil;
    LPNet.Destroy;
  end;
end;

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

procedure TPetriNetCoreTesting_PetriNet.Test_Marcado_Cambiante(const ANoEstados: integer);
var
  LThreadsWrite: TArray<TThread>;
  I: integer;
  LModelo: IModelo;
  LPNet: TdpnPetriNetCoordinador;
  LPlaza: IPlaza;
begin
  Randomize;
  LModelo := TdpnModelo.Create;

  SetLength(LThreadsWrite, ANoEstados);
  for I := 0 to ANoEstados - 1 do
  begin
    LPlaza           := TdpnPlaza.Create;
    LPlaza.Nombre    := 'I' + I.ToString;
    LPlaza.Capacidad := 1;
    LModelo.Elementos.Add(LPlaza);
    LThreadsWrite[I] := TThreadTestModificaPlaza.Create(LPlaza);
    LThreadsWrite[I].FreeOnTerminate := True;
  end;
  for I := 0 to ANoEstados - 1 do
  begin
    LThreadsWrite[I].Start;
  end;
  Sleep(5000);
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
  LModelo.Elementos.Add(LPlazaI1);
  LModelo.Elementos.Add(LArcoI1);
  LModelo.Elementos.Add(LPlazaO1);
  LModelo.Elementos.Add(LArcoO1);
  LModelo.Elementos.Add(LPlazaO2);
  LModelo.Elementos.Add(LArcoO2);


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

    Sleep(200);

    Writeln('Step1 -- > I1: ' + LPlazaI1.TokenCount.ToString + ' - O1: ' + LPlazaO1.TokenCount.ToString + ' - O2: ' + LPlazaO2.TokenCount.ToString);
    Writeln('Step1 -- > Datos: ' + LTransicion.TransicionesRealizadas.ToString + '/' + LTransicion.TransicionesIntentadas.ToString);

    if not((LPlazaI1.TokenCount = 0) and (LPlazaO1.TokenCount = 1) and (LPlazaO2.TokenCount = 1)) then
      Assert.Fail('no ha transicionado (1)');

    for I := 1 to 3 do
    begin
      LToken := TdpnTokenColoreado.Create;
      LPlazaI1.AddToken(LToken);
    end;

    Sleep(500);

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

    Sleep(500);

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
    WriteLn('PN: ' + LPNet.LogMarcado);
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

{ TThreadTestModificaPlaza }

constructor TThreadTestModificaPlaza.Create(const APlaza: IPlaza);
begin
  inherited Create(True);
  FPlaza := APlaza;
end;

procedure TThreadTestModificaPlaza.Execute;
var
  I, J : integer;
  LToken: IToken;
begin
  for i := 1 to 100 do
  begin
    for J := 1 to Random(10) do
    begin
      LToken := TdpnTokenColoreado.Create;
      FPlaza.AddToken(LToken);
    end;
    FPlaza.EliminarTodosTokens;
  end;
end;

initialization
{$IFDEF TESTS_HABILITADOS}
TDUnitX.RegisterTestFixture(TPetriNetCoreTesting_PetriNet);
{$ENDIF}
end.
