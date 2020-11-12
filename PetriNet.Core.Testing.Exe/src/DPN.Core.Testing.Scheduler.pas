{$I Defines.inc}
unit DPN.Core.Testing.Scheduler;

interface

uses
  System.Rtti,
  Spring.Collections,

  DUnitX.Loggers.Console,
  DUnitX.TestFramework,

  Event.Engine.Interfaces,
  Event.Engine,

  DPN.PetriNet,
  DPN.Modelo,
  DPN.Plaza,
  DPN.Transicion,
  DPN.ArcoIN,
  DPN.ArcoOut,
  DPN.TokenColoreado,
  DPN.Core.Testing.Funciones,
  DPN.Interfaces,
  DPN.Variable,
  DPN.Core.Scheduler;

type
{$IFDEF TESTS_HABILITADOS}
  [TestFixture]
{$ENDIF}
  TPetriNetCoreTesting_Scheduler = class
  public
    [Test]
    procedure Test_Scheduler_1_Timer;
    [Test]
    procedure Test_Scheduler_1_Timer_Cancelacion;
    [Test]
    [TestCase('Test-Count=1','1')]
    [TestCase('Test-Count=5','5')]
    [TestCase('Test-Count=10','10')]
    [TestCase('Test-Count=100','100')]
    [TestCase('Test-Count=1000','1000')]
    [TestCase('Test-Count=10000','10000')]
    procedure Test_Scheduler_N_Timers(const ACnt: integer);
    [Test]
    procedure Test_Scheduler_Transicion_No_Debe_Reintentar_Reevaluacion;
    [Test]
    procedure Test_Scheduler_Transicion_Debe_Reintentar_Reevaluacion;
    [Test]
    procedure Test_Scheduler_Transicion_No_Debe_Reintentar_Reevaluacion_Funciones_Mixtas_En_Transicion;
    [Test]
    procedure Test_Scheduler_Transicion_No_Debe_Reintentar_Reevaluacion_Funciones_Mixtas_En_Transicion_Tras_Cambio_Debe_Reactivarse_Evaluacion;

  end;

implementation

uses
  System.SysUtils,

  DPN.Core;

procedure TPetriNetCoreTesting_Scheduler.Test_Scheduler_1_Timer;
var
  LCallbackLlamado: Boolean;
  LTaskID: int64;
begin
  LCallbackLlamado := False;
  LTaskID := DPNCore.TaskScheduler.SetTimer(100, procedure (const ATaskID: int64)
                                                 begin
                                                   LCallbackLlamado := True;
                                                 end);
  Sleep(150);

  if LCallbackLlamado then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Scheduler.Test_Scheduler_1_Timer_Cancelacion;
var
  LCallbackLlamado: Boolean;
  LTaskID: int64;
begin
  LCallbackLlamado := False;
  LTaskID := DPNCore.TaskScheduler.SetTimer(300, procedure (const ATaskID: int64)
                                                 begin
                                                   LCallbackLlamado := True;
                                                 end);
  Sleep(150);

  DPNCore.TaskScheduler.RemoveTimer(LTaskID);

  Sleep(200);

  if LCallbackLlamado then
    Assert.Fail('debe estar cancelado')
  else Assert.Pass;
end;

procedure TPetriNetCoreTesting_Scheduler.Test_Scheduler_N_Timers(const ACnt: integer);
var
  LTaskID: int64;
  LTasks: IDictionary<int64, boolean>;
  I: integer;
begin
  LTasks := TCollections.CreateDictionary<int64, boolean>;
  for I := 1 to ACnt do
  begin
    LTaskID := DPNCore.TaskScheduler.SetTimer(100, procedure (const ATaskID: int64)
                                                   begin
                                                     LTasks[ATaskID] := True;
                                                   end);
    LTasks[LTaskID] := False;
  end;
  if ACnt < 10000 then
    Sleep(1000)
  else Sleep(10000);
  if LTasks.Values.Any(function (const AData: boolean): boolean
                       begin
                         Result := (AData = False)
                       end
                      ) then
    Assert.Fail
  else Assert.Pass
end;

procedure TPetriNetCoreTesting_Scheduler.Test_Scheduler_Transicion_Debe_Reintentar_Reevaluacion;
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

  LTransicion: ITransicion;
begin
  LEnabled        := TdpnVariable.Create;
  LEnabled.NombreReducido := 'Enabled';
  LEnabled.Valor  := 0;

  LFuncion                                                        := TdpnCondicion_es_tabla_variables_trucada.Create;
  TdpnCondicion_es_tabla_variables_trucada(LFuncion).Variable     := LEnabled;
  TdpnCondicion_es_tabla_variables_trucada(LFuncion).ValorToCheck := 5;

  LModelo := TdpnModelo.Create;

  LPlazaI1           := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'I1';
  LPlazaI1.Capacidad := 1;

  LArcoI1             := TdpnArcoIn.Create;
  LArcoI1.Plaza       := LPlazaI1;
  LArcoI1.Peso        := 1;
  LArcoI1.PesoEvaluar := 1;

  LPlazaO1           := TdpnPlaza.Create;
  LPlazaO1.NombreReducido    := 'O1';
  LPlazaO1.Capacidad := 1;

  LArcoO1       := TdpnArcoOut.Create;
  LArcoO1.Plaza := LPlazaO1;
  LArcoO1.Peso  := 1;

  LTransicion := TdpnTransicion.Create;
  LTransicion.TiempoEvaluacion := 100;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);
  LTransicion.AddCondicion(LFuncion);

  LModelo.Elementos.Add(LTransicion);
  LModelo.Elementos.Add(LPlazaI1);
  LModelo.Elementos.Add(LArcoI1);
  LModelo.Elementos.Add(LPlazaO1);
  LModelo.Elementos.Add(LArcoO1);
  LModelo.Elementos.Add(LFuncion);
  LModelo.Elementos.Add(LEnabled);

  LPNet := TdpnPetriNetCoordinador.Create;
  try
    LPNet.Grafo := LModelo;
    LPNet.Start;

    for I := 1 to 1 do
    begin
      LToken := TdpnTokenColoreado.Create;
      LPlazaI1.AddToken(LToken);
    end;

    Sleep(500);

    //no debe transicionar
    if not(LPlazaI1.TokenCount = 1) and (LPlazaO1.TokenCount = 0) then
      Assert.Fail('no ha transicionado bien');

    //no debe estar reevaluando
    Writeln('I1: ' + LPlazaI1.TokenCount.ToString + ' - O1: ' + LPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + LTransicion.TransicionesRealizadas.ToString + '/' + LTransicion.TransicionesIntentadas.ToString);
    if not(LTransicion.TransicionesRealizadas = 0) and (LTransicion.TransicionesIntentadas > 1) then
      Assert.Fail('el numero de intentos de transicionar no es bueno');
    Assert.Pass;
  finally
    LModelo     := nil;

    LFuncion    := nil;
    LEnabled    := nil;
    LPlazaI1    := nil;
    LArcoI1     := nil;
    LPlazaO1    := nil;
    LArcoO1     := nil;
    LTransicion := nil;

    LPNet.Destroy;
  end;
end;

procedure TPetriNetCoreTesting_Scheduler.Test_Scheduler_Transicion_No_Debe_Reintentar_Reevaluacion;
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

  LTransicion: ITransicion;
begin
  LEnabled        := TdpnVariable.Create;
  LEnabled.NombreReducido := 'Enabled';
  LEnabled.Valor  := 0;

  LFuncion                                                := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(LFuncion).Variable     := LEnabled;
  TdpnCondicion_es_tabla_variables(LFuncion).ValorToCheck := 5;

  LModelo := TdpnModelo.Create;

  LPlazaI1           := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'I1';
  LPlazaI1.Capacidad := 1;

  LArcoI1             := TdpnArcoIn.Create;
  LArcoI1.Plaza       := LPlazaI1;
  LArcoI1.Peso        := 1;
  LArcoI1.PesoEvaluar := 1;

  LPlazaO1           := TdpnPlaza.Create;
  LPlazaO1.NombreReducido    := 'O1';
  LPlazaO1.Capacidad := 1;

  LArcoO1       := TdpnArcoOut.Create;
  LArcoO1.Plaza := LPlazaO1;
  LArcoO1.Peso  := 1;

  LTransicion := TdpnTransicion.Create;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);
  LTransicion.AddCondicion(LFuncion);

  LModelo.Elementos.Add(LTransicion);
  LModelo.Elementos.Add(LPlazaI1);
  LModelo.Elementos.Add(LArcoI1);
  LModelo.Elementos.Add(LPlazaO1);
  LModelo.Elementos.Add(LArcoO1);
  LModelo.Elementos.Add(LFuncion);
  LModelo.Elementos.Add(LEnabled);

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

    //no debe transicionar
    if not(LPlazaI1.TokenCount = 1) and (LPlazaO1.TokenCount = 0) then
      Assert.Fail('no ha transicionado bien');

    //no debe estar reevaluando
    Writeln('I1: ' + LPlazaI1.TokenCount.ToString + ' - O1: ' + LPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + LTransicion.TransicionesRealizadas.ToString + '/' + LTransicion.TransicionesIntentadas.ToString);
    if not(LTransicion.TransicionesRealizadas = 0) and (LTransicion.TransicionesIntentadas = 1) then
      Assert.Fail('el numero de intentos de transicionar no es bueno');
    Assert.Pass;
  finally
    LModelo     := nil;

    LFuncion    := nil;
    LEnabled    := nil;
    LPlazaI1    := nil;
    LArcoI1     := nil;
    LPlazaO1    := nil;
    LArcoO1     := nil;
    LTransicion := nil;

    LPNet.Destroy;
  end;
end;

procedure TPetriNetCoreTesting_Scheduler.Test_Scheduler_Transicion_No_Debe_Reintentar_Reevaluacion_Funciones_Mixtas_En_Transicion;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LToken : IToken;
  I      : Integer;

  LArcoI1 : IArcoIn;
  LPlazaI1: IPlaza;

  LArcoO1 : IArcoOut;
  LPlazaO1: IPlaza;

  LFuncion1 : ICondicion;
  LFuncion2 : ICondicion;
  LEnabled : IVariable;

  LTransicion: ITransicion;
begin
  LEnabled        := TdpnVariable.Create;
  LEnabled.NombreReducido := 'Enabled';
  LEnabled.Valor  := 0;

  LFuncion1                                                        := TdpnCondicion_es_tabla_variables_trucada.Create;
  TdpnCondicion_es_tabla_variables_trucada(LFuncion1).Variable     := LEnabled;
  TdpnCondicion_es_tabla_variables_trucada(LFuncion1).ValorToCheck := 5;

  LFuncion2                                                := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(LFuncion2).Variable     := LEnabled;
  TdpnCondicion_es_tabla_variables(LFuncion2).ValorToCheck := 5;

  LModelo := TdpnModelo.Create;

  LPlazaI1           := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'I1';
  LPlazaI1.Capacidad := 1;

  LArcoI1             := TdpnArcoIn.Create;
  LArcoI1.Plaza       := LPlazaI1;
  LArcoI1.Peso        := 1;
  LArcoI1.PesoEvaluar := 1;

  LPlazaO1           := TdpnPlaza.Create;
  LPlazaO1.NombreReducido    := 'O1';
  LPlazaO1.Capacidad := 1;

  LArcoO1       := TdpnArcoOut.Create;
  LArcoO1.Plaza := LPlazaO1;
  LArcoO1.Peso  := 1;

  LTransicion := TdpnTransicion.Create;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);
  LTransicion.AddCondicion(LFuncion2);
  LTransicion.AddCondicion(LFuncion1);

  LModelo.Elementos.Add(LTransicion);
  LModelo.Elementos.Add(LPlazaI1);
  LModelo.Elementos.Add(LArcoI1);
  LModelo.Elementos.Add(LPlazaO1);
  LModelo.Elementos.Add(LArcoO1);
  LModelo.Elementos.Add(LFuncion1);
  LModelo.Elementos.Add(LFuncion2);
  LModelo.Elementos.Add(LEnabled);

  LPNet := TdpnPetriNetCoordinador.Create;
  try
    LPNet.Grafo := LModelo;
    LPNet.Start;

    for I := 1 to 1 do
    begin
      LToken := TdpnTokenColoreado.Create;
      LPlazaI1.AddToken(LToken);
    end;

    Sleep(500);

    //no debe transicionar
    if not(LPlazaI1.TokenCount = 1) and (LPlazaO1.TokenCount = 0) then
      Assert.Fail('no ha transicionado bien');

    //no debe estar reevaluando
    Writeln('I1: ' + LPlazaI1.TokenCount.ToString + ' - O1: ' + LPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + LTransicion.TransicionesRealizadas.ToString + '/' + LTransicion.TransicionesIntentadas.ToString);
    if not(LTransicion.TransicionesRealizadas = 0) and (LTransicion.TransicionesIntentadas = 1) then
      Assert.Fail('el numero de intentos de transicionar no es bueno');
    Assert.Pass;
  finally
    LModelo     := nil;

    LFuncion1    := nil;
    LFuncion2    := nil;
    LEnabled    := nil;
    LPlazaI1    := nil;
    LArcoI1     := nil;
    LPlazaO1    := nil;
    LArcoO1     := nil;
    LTransicion := nil;

    LPNet.Destroy;
  end;
end;

procedure TPetriNetCoreTesting_Scheduler.Test_Scheduler_Transicion_No_Debe_Reintentar_Reevaluacion_Funciones_Mixtas_En_Transicion_Tras_Cambio_Debe_Reactivarse_Evaluacion;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LToken : IToken;
  I      : Integer;

  LArcoI1 : IArcoIn;
  LPlazaI1: IPlaza;

  LArcoO1 : IArcoOut;
  LPlazaO1: IPlaza;

  LFuncion1 : ICondicion;
  LFuncion2 : ICondicion;
  LEnabled : IVariable;

  LTransicion: ITransicion;
begin
  LEnabled        := TdpnVariable.Create;
  LEnabled.NombreReducido := 'Enabled';
  LEnabled.Valor  := 0;

  LFuncion1                                                        := TdpnCondicion_es_tabla_variables_trucada.Create;
  TdpnCondicion_es_tabla_variables_trucada(LFuncion1).Variable     := LEnabled;
  TdpnCondicion_es_tabla_variables_trucada(LFuncion1).ValorToCheck := 5;

  LFuncion2                                                := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(LFuncion2).Variable     := LEnabled;
  TdpnCondicion_es_tabla_variables(LFuncion2).ValorToCheck := 5;

  LModelo := TdpnModelo.Create;

  LPlazaI1           := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'I1';
  LPlazaI1.Capacidad := 1;

  LArcoI1             := TdpnArcoIn.Create;
  LArcoI1.Plaza       := LPlazaI1;
  LArcoI1.Peso        := 1;
  LArcoI1.PesoEvaluar := 1;

  LPlazaO1           := TdpnPlaza.Create;
  LPlazaO1.NombreReducido    := 'O1';
  LPlazaO1.Capacidad := 1;

  LArcoO1       := TdpnArcoOut.Create;
  LArcoO1.Plaza := LPlazaO1;
  LArcoO1.Peso  := 1;

  LTransicion := TdpnTransicion.Create;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);
  LTransicion.AddCondicion(LFuncion2);
  LTransicion.AddCondicion(LFuncion1);

  LModelo.Elementos.Add(LTransicion);
  LModelo.Elementos.Add(LPlazaI1);
  LModelo.Elementos.Add(LArcoI1);
  LModelo.Elementos.Add(LPlazaO1);
  LModelo.Elementos.Add(LArcoO1);
  LModelo.Elementos.Add(LFuncion1);
  LModelo.Elementos.Add(LFuncion2);
  LModelo.Elementos.Add(LEnabled);

  LPNet := TdpnPetriNetCoordinador.Create;
  try
    LPNet.Grafo := LModelo;
    LPNet.Start;

    for I := 1 to 1 do
    begin
      LToken := TdpnTokenColoreado.Create;
      LPlazaI1.AddToken(LToken);
    end;

    Sleep(500);

    //no debe transicionar
    if not(LPlazaI1.TokenCount = 1) and (LPlazaO1.TokenCount = 0) then
      Assert.Fail('no ha transicionado bien');

    //no debe estar reevaluando
    Writeln('I1: ' + LPlazaI1.TokenCount.ToString + ' - O1: ' + LPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + LTransicion.TransicionesRealizadas.ToString + '/' + LTransicion.TransicionesIntentadas.ToString);
    if not(LTransicion.TransicionesRealizadas = 0) and (LTransicion.TransicionesIntentadas = 1) then
      Assert.Fail('el numero de intentos de transicionar no es bueno');

    LEnabled.Valor  := 5;

    Sleep(100);

    //debe transicionar
    if not(LPlazaI1.TokenCount = 0) and (LPlazaO1.TokenCount = 1) then
      Assert.Fail('no ha transicionado');
    Writeln('I1: ' + LPlazaI1.TokenCount.ToString + ' - O1: ' + LPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + LTransicion.TransicionesRealizadas.ToString + '/' + LTransicion.TransicionesIntentadas.ToString);
    if not(LTransicion.TransicionesRealizadas = 1) and (LTransicion.TransicionesIntentadas = 2) then
      Assert.Fail('el numero de intentos de transicionar no es bueno (*)');

    Assert.Pass;
  finally
    LModelo     := nil;

    LFuncion1    := nil;
    LFuncion2    := nil;
    LEnabled    := nil;
    LPlazaI1    := nil;
    LArcoI1     := nil;
    LPlazaO1    := nil;
    LArcoO1     := nil;
    LTransicion := nil;

    LPNet.Destroy;
  end;
end;

initialization
{$IFDEF TESTS_HABILITADOS}
TDUnitX.RegisterTestFixture(TPetriNetCoreTesting_Scheduler);
{$ENDIF}
end.
