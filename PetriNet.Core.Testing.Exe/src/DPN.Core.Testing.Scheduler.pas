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
  [TestFixture]
  TPetriNetCoreTesting_Scheduler = class
  public
    [Test]
    procedure Test_Scheduler_1_Timer;
//    [Test]
//    [TestCase('Test-Count=1','1')]
//    [TestCase('Test-Count=5','5')]
//    [TestCase('Test-Count=10','10')]
//    [TestCase('Test-Count=100','100')]
//    [TestCase('Test-Count=1000','1000')]
//    [TestCase('Test-Count=10000','10000')]
    procedure Test_Scheduler_N_Timers(const ACnt: integer);
    [Test]
    procedure Test_Scheduler_Transicion_No_Debe_Reintentar_Reevaluacion;
    [Test]
    procedure Test_Scheduler_Transicion_Debe_Reintentar_Reevaluacion;
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
  else Sleep(5000);
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

  FArcoI1 : IArcoIn;
  FPlazaI1: IPlaza;

  FArcoO1 : IArcoOut;
  FPlazaO1: IPlaza;

  FFuncion : ICondicion;
  FEnabled : IVariable;

  FTransicion: ITransicion;
begin
  FEnabled        := TdpnVariable.Create;
  FEnabled.Nombre := 'Enabled';
  FEnabled.Valor  := 0;

  FFuncion                                                        := TdpnCondicion_es_tabla_variables_trucada.Create;
  TdpnCondicion_es_tabla_variables_trucada(FFuncion).Variable     := FEnabled;
  TdpnCondicion_es_tabla_variables_trucada(FFuncion).ValorToCheck := 5;

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
  FTransicion.TiempoEvaluacion := 100;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);
  FTransicion.AddCondicion(FFuncion);

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

    Sleep(500);

    //no debe transicionar
    if not(FPlazaI1.TokenCount = 1) and (FPlazaO1.TokenCount = 0) then
      Assert.Fail('no ha transicionado bien');

    //no debe estar reevaluando
    Writeln('I1: ' + FPlazaI1.TokenCount.ToString + ' - O1: ' + FPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + FTransicion.TransicionesRealizadas.ToString + '/' + FTransicion.TransicionesIntentadas.ToString);
    if not(FTransicion.TransicionesRealizadas = 0) and (FTransicion.TransicionesIntentadas > 1) then
      Assert.Fail('el numero de intentos de transicionar no es bueno');
    Assert.Pass;
  finally
    LModelo     := nil;

    FFuncion    := nil;
    FEnabled    := nil;
    FPlazaI1    := nil;
    FArcoI1     := nil;
    FPlazaO1    := nil;
    FArcoO1     := nil;
    FTransicion := nil;

    LPNet.Destroy;
  end;
end;

procedure TPetriNetCoreTesting_Scheduler.Test_Scheduler_Transicion_No_Debe_Reintentar_Reevaluacion;
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

  FTransicion: ITransicion;
begin
  FEnabled        := TdpnVariable.Create;
  FEnabled.Nombre := 'Enabled';
  FEnabled.Valor  := 0;

  FFuncion                                                := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(FFuncion).Variable     := FEnabled;
  TdpnCondicion_es_tabla_variables(FFuncion).ValorToCheck := 5;

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
  FTransicion.AddCondicion(FFuncion);

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

    //no debe transicionar
    if not(FPlazaI1.TokenCount = 1) and (FPlazaO1.TokenCount = 0) then
      Assert.Fail('no ha transicionado bien');

    //no debe estar reevaluando
    Writeln('I1: ' + FPlazaI1.TokenCount.ToString + ' - O1: ' + FPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + FTransicion.TransicionesRealizadas.ToString + '/' + FTransicion.TransicionesIntentadas.ToString);
    if not(FTransicion.TransicionesRealizadas = 0) and (FTransicion.TransicionesIntentadas = 1) then
      Assert.Fail('el numero de intentos de transicionar no es bueno');
    Assert.Pass;
  finally
    LModelo     := nil;

    FFuncion    := nil;
    FEnabled    := nil;
    FPlazaI1    := nil;
    FArcoI1     := nil;
    FPlazaO1    := nil;
    FArcoO1     := nil;
    FTransicion := nil;

    LPNet.Destroy;
  end;
end;

initialization

TDUnitX.RegisterTestFixture(TPetriNetCoreTesting_Scheduler);

end.
