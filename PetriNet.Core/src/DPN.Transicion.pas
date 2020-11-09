unit DPN.Transicion;

{$UNDEF TRAZAS_SECUNDARIAS_TdpnTransicion}

interface

uses
  System.SyncObjs,

  Spring,
  Spring.Collections,

  Event.Engine,
  Event.Engine.Interfaces,

  DPN.Interfaces,
  DPN.NodoPetriNet;

type

  TdpnTransicion = class (TdpnNodoPetriNet, ITransicion)
  protected
    FIsHabilitado: boolean;
    FTiempoEvaluacion: integer;
    FHayAlgunaCondicionDesactivadaQueNoDependeDeToken: Boolean;
{$IFDEF TRAZAS_SECUNDARIAS_TdpnTransicion}
    FTrazabilidad: IList<String>;
{$ENDIF}
    FID_TimerReEvaluacion: int64;
    FActivo_TimerReEvaluacion: boolean;

    FIsTransicionDependeDeEvento: Boolean;
    FCondicionDeEvento: ICondicion;

    FTransicionesIntentadas: int64;
    FTransicionesRealizadas: int64;

    FCondiciones: IList<ICondicion>;
    FAcciones: IList<IAccion>;
    FDependencias: IList<IBloqueable>;

    FPreCondicionesAgregadas: IList<ICondicion>;
    FPreAccionesAgregadas: IList<IAccion>;

    FLock: TSpinLock;
    FLockTimer: TSpinLock;

    FMarcadoEstados: IDictionary<integer, integer>;
    FEstadosHabilitacion: IDictionary<integer, boolean>;
    FEstadoCondicionesNoDependenDeToken: IDictionary<integer, boolean>;

    FCondicionesPreparadas: IReadOnlyList<ICondicion>;
    FAccionesPreparadas: IReadOnlyList<IAccion>;

    FArcosIn: IList<IArcoIn>;
    FArcosOut: IList<IArcoOut>;

    FArcosInPreparadas: IReadOnlyList<IArcoIn>;
    FArcosOutPreparadas: IReadOnlyList<IArcoOut>;

    FOnRequiereEvaluacion: IEvent<EventoNodoPN_Transicion>;
    FEventoOnMarcadoChanged: IEvent<EventoNodoPN_MarcadoPlazasTokenCount>;

    function GetOnRequiereEvaluacionChanged: IEvent<EventoNodoPN_Transicion>;
    function GetOnMarcadoChanged: IEvent<EventoNodoPN_MarcadoPlazasTokenCount>;

    function GetIsTransicionDependeDeEvento: Boolean; virtual;

    function GetIsHabilitado: Boolean; virtual;
    function GetIsHabilitadoParcialmente: Boolean; virtual;

    function GetTiempoEvaluacion: integer;
    procedure SetTiempoEvaluacion(const AValor: integer);

    function GetTransicionesIntentadas: int64;
    function GetTransicionesRealizadas: int64;

    function GetArcosIn: IReadOnlyList<IArcoIn>; virtual;
    function GetArcosOut: IReadOnlyList<IArcoOut>; virtual;

    function GetCondiciones: IReadOnlyList<ICondicion>; virtual;
    function GetAcciones: IReadOnlyList<IAccion>; virtual;

    procedure OnCondicionContextChanged(const AID: integer); virtual;
    procedure OnHabilitacionChanged(const AID: integer; const AValue: boolean); virtual;

    procedure DoOnTokenCountChanged(const AID: integer; const ACount: Integer); virtual;

    procedure PrepararPreCondicionesSiguientesEstados;

    procedure AgregarDependencia(ADependencia: IBloqueable); virtual;
    procedure AgregarDependencias(ADependencias: IList<IBloqueable>); virtual;
    procedure PreparacionDependencias; virtual;
    procedure CapturarDependencias; virtual;
    procedure LiberarDependencias; virtual;
    procedure AsociacionPlazasTokens; virtual;

    procedure IniciarTimerReEvaluacion; virtual;
    procedure DetenerTimerReEvaluacion; virtual;

    function ObtenerMarcadoTokens: IMarcadotokens;

    function EstrategiaDisparo(AEvento: IEvento = nil): Boolean; virtual;

    procedure EliminarEventosPendientesTransicionSiNecesario;
    function HayEventosPendientesEnTransicion: boolean;
    procedure QueHacerTrasDisparo(const AResultadoDisparo: Boolean);

    procedure CalcularPosibleCambioContexto(const AID: integer);
    procedure ActualizarEstadoTransicionPorCondicionQueNoDependeDeTokens(const AID: integer; const AValor: boolean);
    procedure ActualizarEstadoHabilitacionPorEstadoArco(const AID: integer; const AValor: boolean);
  public
    constructor Create; override;
    destructor Destroy; override;

    function EjecutarTransicion: Boolean; virtual;

    procedure AddCondicion(ACondicion: ICondicion); virtual;
    procedure EliminarCondicion(ACondicion: ICondicion); virtual;
    procedure AddAccion(AAccion: IAccion); virtual;
    procedure EliminarAccion(AAccion: IAccion); virtual;

    procedure AddArcoIn(AArco: IArcoIn); virtual;
    procedure EliminarArcoIn(AArco: IArcoIn); virtual;
    procedure AddArcoOut(AArco: IArcoOut); virtual;
    procedure EliminarArcoOut(AArco: IArcoOut); virtual;

    procedure Start; override;
    procedure Stop; override;
    procedure Reset; override;

    function LogAsString: string; override;

    property IsHabilitado: Boolean read GetIsHabilitado;
    property IsHabilitadoParcialmente: Boolean read GetIsHabilitadoParcialmente;
    property TiempoEvaluacion: integer read GetTiempoEvaluacion write SetTiempoEvaluacion;

    property ArcosIN: IReadOnlyList<IArcoIn> read GetArcosIn;
    property ArcosOut: IReadOnlyList<IArcoout> read GetArcosOut;

    property Condiciones: IReadOnlyList<ICondicion> read GetCondiciones;
    property Acciones: IReadOnlyList<IAccion> read GetAcciones;

    property TransicionesIntentadas: int64 read GetTransicionesIntentadas;
    property TransicionesRealizadas: int64 read GetTransicionesRealizadas;

    property OnMarcadoChanged: IEvent<EventoNodoPN_MarcadoPlazasTokenCount> read GetOnMarcadoChanged;
    property OnRequiereEvaluacionChanged: IEvent<EventoNodoPN_Transicion> read GetOnRequiereEvaluacionChanged;
    property IsTransicionDependeDeEvento: Boolean read GetIsTransicionDependeDeEvento;
  end;

implementation

uses
  System.SysUtils,
  System.Math,

  DPN.MarcadoPlazasCantidadTokens,
  DPN.MarcadoTokens,
  DPN.Core;

{ TdpnTransicion }

procedure TdpnTransicion.ActualizarEstadoHabilitacionPorEstadoArco(const AID: integer; const AValor: boolean);
var
  LNewValue: Boolean;
begin
  FLock.Enter;
  try
    FEstadosHabilitacion[AID] := AValor;
    //evaluar que todos los arcos estén correctos
    LNewValue := FEstadosHabilitacion.Values.Any(
                                                   function (const AValue: boolean): boolean
                                                   begin
                                                     Result := (AValue = false)
                                                   end
                                                ) = False;
    if (LNewValue <> FIsHabilitado) then //si el estado de habilitacion de la transicion ha cambiado
    begin
      FIsHabilitado := LNewValue;
      if FIsHabilitado then //si la transicion pasa a habilitada
      begin
        if FIsTransicionDependeDeEvento then //si es una transición que espera de evento activamos la recepcion del evento
          FCondicionDeEvento.ListenerEventoHabilitado := True
        else begin //si es transicion sin evento, requerimos la evaluacion
               FOnRequiereEvaluacion.Invoke(ID, Self);
{$IFDEF TRAZAS_SECUNDARIAS_TdpnTransicion}
               FTrazabilidad.Add(FormatDateTime('hh:nn:ss.zzz ', Now) + '<TdpnTransicion.ActualizarEstadoHabilitacionPorEstadoArco> requiere evaluacion');
{$ENDIF}
             end;
      end
      else begin //la transicion ha pasado a deshabilitada
             if FIsTransicionDependeDeEvento then //si es transicion de evento, deshabilitamos evento, aunque llegue no sirve de nada
               FCondicionDeEvento.ListenerEventoHabilitado := False;
           end;
    end;
  finally
    FLock.Exit;
  end;
end;

procedure TdpnTransicion.ActualizarEstadoTransicionPorCondicionQueNoDependeDeTokens(const AID: integer; const AValor: boolean);
begin
  FEstadoCondicionesNoDependenDeToken[AID] := AValor;
  FHayAlgunaCondicionDesactivadaQueNoDependeDeToken := FEstadoCondicionesNoDependenDeToken.Values.Any(
                                                                                                  function (const AValue: boolean): Boolean
                                                                                                  begin
                                                                                                    Result := (AValue = false)
                                                                                                  end
                                                                                               );
end;

procedure TdpnTransicion.AddAccion(AAccion: IAccion);
begin
  FAcciones.Add(AAccion);
end;

procedure TdpnTransicion.AddArcoIn(AArco: IArcoIn);
begin
  FArcosIn.Add(AArco);
  AArco.Transicion := Self;
  AArco.OnHabilitacionChanged.Add(OnHabilitacionChanged);
  ActualizarEstadoHabilitacionPorEstadoArco(AArco.ID, AArco.IsHabilitado);
end;

procedure TdpnTransicion.AddArcoOut(AArco: IArcoOut);
begin
  FArcosOut.Add(AArco);
  AArco.Transicion := Self;
  AArco.OnHabilitacionChanged.Add(OnHabilitacionChanged);
  ActualizarEstadoHabilitacionPorEstadoArco(AArco.ID, AArco.IsHabilitado);
end;

procedure TdpnTransicion.AddCondicion(ACondicion: ICondicion);
begin
  FCondiciones.Add(ACondicion);
  ACondicion.OnContextoCondicionChanged.Add(OnCondicionContextChanged);
end;

procedure TdpnTransicion.AgregarDependencia(ADependencia: IBloqueable);
begin
  if not FDependencias.Contains(ADependencia) then
    FDependencias.Add(ADependencia);
end;

procedure TdpnTransicion.AgregarDependencias(ADependencias: IList<IBloqueable>);
var
  LBloqueable: IBloqueable;
begin
  for LBloqueable in ADependencias do
    AgregarDependencia(LBloqueable);
end;

procedure TdpnTransicion.AsociacionPlazasTokens;
var
  LArco: IArco;
begin
  for LArco in FArcosIN do
  begin
    FMarcadoEstados[LArco.ID] := LArco.Plaza.TokenCount;
    LArco.Plaza.OnTokenCountChanged.Add(DoOnTokenCountChanged);
  end;
  for LArco in FArcosOUT do
  begin
    FMarcadoEstados[LArco.ID] := LArco.Plaza.TokenCount;
    LArco.Plaza.OnTokenCountChanged.Add(DoOnTokenCountChanged);
  end;
end;

procedure TdpnTransicion.CalcularPosibleCambioContexto(const AID: integer);
begin
  if FEstadoCondicionesNoDependenDeToken.ContainsKey(AID) then
  begin
    FEstadoCondicionesNoDependenDeToken[AID]    := True; //trampeamos para provocar su posible reevaluacion
    FHayAlgunaCondicionDesactivadaQueNoDependeDeToken := FEstadoCondicionesNoDependenDeToken.Values.Any(
                                                                                                  function (const AValue: boolean): Boolean
                                                                                                  begin
                                                                                                    Result := (AValue = false)
                                                                                                  end
                                                                                               );
  end;
end;

procedure TdpnTransicion.CapturarDependencias;
var
  LBloqueable: IBloqueable;
begin
  for LBloqueable in FDependencias do
    LBloqueable.AdquireLock;
end;

constructor TdpnTransicion.Create;
begin
  inherited;
  FTransicionesIntentadas := 0;
  FTransicionesRealizadas := 0;
  FIsTransicionDependeDeEvento := False;
  FHayAlgunaCondicionDesactivadaQueNoDependeDeToken := False;
  FPreCondicionesAgregadas := TCollections.CreateList<ICondicion>;
  FPreAccionesAgregadas := TCollections.CreateList<IAccion>;
  FCondiciones := TCollections.CreateList<ICondicion>;
  FAcciones := TCollections.CreateList<IAccion>;
  FArcosIn := TCollections.CreateList<IArcoIn>;
  FArcosOut := TCollections.CreateList<IArcoOut>;
  FEstadosHabilitacion := TCollections.CreateDictionary<integer, boolean>;
  FEstadoCondicionesNoDependenDeToken := TCollections.CreateDictionary<integer, boolean>;
  FDependencias := TCollections.CreateList<IBloqueable>;
  FMarcadoEstados := TCollections.CreateDictionary<integer, integer>;
  FOnRequiereEvaluacion := DPNCore.CrearEvento<EventoNodoPN_Transicion>;
  FEventoOnMarcadoChanged := DPNCore.CrearEvento<EventoNodoPN_MarcadoPlazasTokenCount>;
  FID_TimerReEvaluacion := 0;
  FActivo_TimerReEvaluacion := False;
{$IFDEF TRAZAS_SECUNDARIAS_TdpnTransicion}
  FTrazabilidad := TCollections.CreateList<String>;
{$ENDIF}
end;

destructor TdpnTransicion.Destroy;
begin
  DetenerTimerReEvaluacion;
  inherited;
end;

procedure TdpnTransicion.DetenerTimerReEvaluacion;
begin
  FLockTimer.Enter;
  try
    if FActivo_TimerReEvaluacion then
    begin
      FActivo_TimerReEvaluacion := False;
      DPNCore.TaskScheduler.RemoveTimer(FID_TimerReEvaluacion);
    end;
  finally
    FLockTimer.Exit;
  end;
end;

procedure TdpnTransicion.DoOnTokenCountChanged(const AID, ACount: Integer);
begin
  FMarcadoEstados[AID] := ACount;
end;

function TdpnTransicion.EjecutarTransicion: Boolean;
var
  LEvento: IEvento;
begin
  Result := False;
  CapturarDependencias; // todas las dependencias son capturadas
  // transicion efectiva
  Inc(FTransicionesIntentadas);
  try
    // 0) si hay un timer activo para esta transicion lo cancelamos
    DetenerTimerReEvaluacion;
    // 1) chequeo de integridad, debe estar habilitada la transicion (enabled)
    if not FEnabled then
    begin
      Exit;
    end;
    // 2) chequeo de integridad, debe estar habilitada la transicion (estados in y out cumplen sus restricciones)
    if not(FIsHabilitado) then
    begin
{$IFDEF TRAZAS_SECUNDARIAS_TdpnTransicion}
      FTrazabilidad.Add(FormatDateTime('hh:nn:ss.zzz ', Now) + '<TdpnTransicion.EjecutarTransicion> sale en FIsHabilitado');
{$ENDIF}
      Exit;
    end;
    // 3) si alguna condicion que no depende de token esta desactivada y no ha habido variacion en la misma no se pasa a evaluar
    if FHayAlgunaCondicionDesactivadaQueNoDependeDeToken then
    begin
{$IFDEF TRAZAS_SECUNDARIAS_TdpnTransicion}
      FTrazabilidad.Add(FormatDateTime('hh:nn:ss.zzz ', Now) + '<TdpnTransicion.EjecutarTransicion> sale en FHayAlgunaCondicionDesactivadaQueNoDependeDeToken');
{$ENDIF}
      Exit;
    end;
    // 4) estrategia disparo
    case FIsTransicionDependeDeEvento of
      False:
        begin
          Result := EstrategiaDisparo;
        end;
      True:
        begin
          if FCondicionDeEvento.EventosCount > 0 then
          begin
            LEvento := FCondicionDeEvento.GetPrimerEvento;
            try
              Result := EstrategiaDisparo(LEvento);
            finally
              FCondicionDeEvento.RemovePrimerEvento;
            end;
          end
          else begin
                 Exit;
               end;
        end;
    end;
    QueHacerTrasDisparo(Result);
  finally
    LiberarDependencias; // liberacion de dependencias
  end;
end;

procedure TdpnTransicion.EliminarAccion(AAccion: IAccion);
begin
  FAcciones.Remove(AAccion);
end;

procedure TdpnTransicion.EliminarArcoIn(AArco: IArcoIn);
begin
  AArco.OnHabilitacionChanged.Remove(OnHabilitacionChanged);
  if FArcosIn.Remove(AArco) then
    FEstadosHabilitacion.Remove(AArco.ID);
end;

procedure TdpnTransicion.EliminarArcoOut(AArco: IArcoOut);
begin
  AArco.OnHabilitacionChanged.Remove(OnHabilitacionChanged);
  FArcosOut.Remove(AArco);
end;

procedure TdpnTransicion.EliminarCondicion(ACondicion: ICondicion);
begin
  ACondicion.OnContextoCondicionChanged.Remove(OnCondicionContextChanged);
  FCondiciones.Remove(ACondicion)
end;

procedure TdpnTransicion.EliminarEventosPendientesTransicionSiNecesario;
begin
  if FIsTransicionDependeDeEvento then
    FCondicionDeEvento.ClearEventos;
end;

function TdpnTransicion.EstrategiaDisparo(AEvento: IEvento = nil): boolean;
var
  LTokens: IMarcadoTokens;
  LTokensOut: IList<IToken>;
  LCondicion: ICondicion;
  LAccion: IAccion;
  LResult: Boolean;
  LArcoIn: IArcoIn;
  LArcoOut: IArcoOut;
  LMarcadoNotificacion: IMarcadoPlazasCantidadTokens;
begin
  Result := False;
  // Pasos:
  // 1) obtenemos los jetones implicados por estado
  LTokens := ObtenerMarcadoTokens;
  // 2) recorremos las condiciones y les pasamos la lista de jetones
  //    las condiciones pueden ir reduciendo esa lista a su antojo, es decir pueden ir dejando en la lista solo aquellos token que cumplan sus restricciones
  for LCondicion in FCondiciones do
  begin
    try
      LResult := LCondicion.Evaluar(LTokens, AEvento);
      if LCondicion.IsEvaluacionNoDependeDeTokensOEvento then
      begin
        ActualizarEstadoTransicionPorCondicionQueNoDependeDeTokens(LCondicion.ID, LResult);
      end;
      if not LResult then
      begin
        Exit;
      end;
    except
      on E:Exception do
      begin
        //DAVE
        Exit;
      end;
    end;
  end;
  Result := True;
  // 3) ejecucion de acciones
  for LAccion in FAcciones do
  begin
    try
      LAccion.Execute(LTokens, AEvento);
    except
      on E:Exception do
      begin
        //DAVE
      end;
    end;
  end;
  // 4) movimiento de tokens
  // 4.1) ejecucion de arcos in
  for LArcoIn in FArcosIn do
  begin
    LArcoIn.DoOnTransicionando(LTokens.Marcado[LArcoIn.Plaza]);
  end;
  // 4.2) ejecucion de arcos out
  for LArcoOut in FArcosOut do
  begin
    case LArcoOut.GenerarTokensDeSistema of
      True:
        begin
          LTokensOut := DPNCore.GenerarNTokensSistema(LArcoOut.Peso);
        end;
      False:
        begin
          LTokensOut := DPNCore.GenerarTokensAdecuados(LTokens, LArcoOut.Peso);
        end;
    end;
    LArcoOut.DoOnTransicionando(LTokensOut);
  end;
  //notificacion de transaccion, cambio de tokens
  LMarcadoNotificacion := TdpnMarcadoPlazasCantidadTokens.Create;
  LMarcadoNotificacion.AddTokensPlazas(FMarcadoEstados);
  FEventoOnMarcadoChanged.Invoke(ID, LMarcadoNotificacion);
end;

function TdpnTransicion.GetAcciones: IReadOnlyList<IAccion>;
begin
  Result := FAccionesPreparadas
end;

function TdpnTransicion.GetArcosIn: IReadOnlyList<IArcoIn>;
begin
  Result := FArcosInPreparadas;
end;

function TdpnTransicion.GetArcosOut: IReadOnlyList<IArcoOut>;
begin
  Result := FArcosOutPreparadas;
end;

function TdpnTransicion.GetCondiciones: IReadOnlyList<ICondicion>;
begin
  Result := FCondicionesPreparadas
end;

function TdpnTransicion.GetIsHabilitado: Boolean;
begin
  Result := FIsHabilitado
end;

function TdpnTransicion.GetIsHabilitadoParcialmente: Boolean;
begin
  if FIsHabilitado then Exit(False);
  Result := FEstadosHabilitacion.Values.Any(
                                              function (const AValor: boolean): Boolean
                                              begin
                                                Result := (AValor = True)
                                              end
                                           );
end;

function TdpnTransicion.GetIsTransicionDependeDeEvento: Boolean;
begin
  Result := FIsTransicionDependeDeEvento
end;

function TdpnTransicion.GetOnMarcadoChanged: IEvent<EventoNodoPN_MarcadoPlazasTokenCount>;
begin
  Result := FEventoOnMarcadoChanged
end;

function TdpnTransicion.GetOnRequiereEvaluacionChanged: IEvent<EventoNodoPN_Transicion>;
begin
  Result := FOnRequiereEvaluacion
end;

function TdpnTransicion.GetTiempoEvaluacion: integer;
begin
  Result := FTiempoEvaluacion
end;

function TdpnTransicion.GetTransicionesIntentadas: int64;
begin
  Result := FTransicionesIntentadas
end;

function TdpnTransicion.GetTransicionesRealizadas: int64;
begin
  Result := FTransicionesRealizadas
end;

function TdpnTransicion.HayEventosPendientesEnTransicion: boolean;
begin
  Result := (FCondicionDeEvento.EventosCount <> 0)
end;

procedure TdpnTransicion.IniciarTimerReEvaluacion;
begin
  FLockTimer.Enter;
  try
    if not FActivo_TimerReEvaluacion then
    begin
      if TiempoEvaluacion > 0 then //solo si hay un tiempo configurado
      begin
        FID_TimerReEvaluacion := DPNCore.TaskScheduler.SetTimer(TiempoEvaluacion, procedure (const ATaskID: int64)
                                                                                  begin
                                                                                    FLockTimer.Enter;
                                                                                    try
                                                                                      FActivo_TimerReEvaluacion := False;
                                                                                      FID_TimerReEvaluacion := 0;
                                                                                    finally
                                                                                      FLockTimer.Exit;
                                                                                    end;
                                                                                    FOnRequiereEvaluacion.Invoke(ID, Self); //requerimos reevaluacion
{$IFDEF TRAZAS_SECUNDARIAS_TdpnTransicion}
                                                                                    FTrazabilidad.Add(FormatDateTime('hh:nn:ss.zzz ', Now) + '<TdpnTransicion.IniciarTimerReEvaluacion> requiere evaluacion');
{$ENDIF}
                                                                                  end);
        FActivo_TimerReEvaluacion := True;
      end;
    end;
  finally
    FLockTimer.Exit;
  end;
end;

procedure TdpnTransicion.LiberarDependencias;
var
  LBloqueable: IBloqueable;
begin
  for LBloqueable in FDependencias do
    LBloqueable.ReleaseLock;
end;

function TdpnTransicion.LogAsString: string;
{$IFDEF TRAZAS_SECUNDARIAS_TdpnTransicion}
var
  LTexto: string;
{$ENDIF}
var
  I: integer;
begin
  Result := inherited + '<' + ClassName + '>' + '[IsHabilitado]' + IsHabilitado.ToString + '[IsHabilitadoParcialmente]' + IsHabilitadoParcialmente.ToString +
            '[TiempoEvaluacion]' + TiempoEvaluacion.ToString + '[TransicionesIntentadas]' + TransicionesIntentadas.ToString + '[TransicionesRealizadas]' + TransicionesRealizadas.ToString + '[IsTransicionDependeDeEvento]' + IsTransicionDependeDeEvento.ToString;
{$IFDEF TRAZAS_SECUNDARIAS_TdpnTransicion}
  for LTexto in FTrazabilidad do
  begin
    Result := Result + #13#10 + LTexto;
  end;
{$ENDIF}
  Result := Result + #13#10 + '---' + 'Estados habilitacion:';
  for I in FEstadosHabilitacion.Keys do
  begin
    Result := Result + #13#10 + '   |-> ' + I.ToString + ' : ' + FEstadosHabilitacion[I].ToString;
  end;
end;

function TdpnTransicion.ObtenerMarcadoTokens: IMarcadoTokens;
var
  LArco: IArcoIn;
  LMarcadoPlaza: IMarcadotokens;
begin
  Result := TdpnMarcadoTokens.Create;
  for LArco in FArcosIn do
  begin
    LMarcadoPlaza := LArco.ObtenerTokensEvaluacion;
    Result.AddTokensMarcado(LMarcadoPlaza);
  end;
end;

procedure TdpnTransicion.OnCondicionContextChanged(const AID: integer);
begin
  CalcularPosibleCambioContexto(AID);
  if FIsHabilitado and (not FHayAlgunaCondicionDesactivadaQueNoDependeDeToken) then
  begin
    FOnRequiereEvaluacion.Invoke(ID, Self);
{$IFDEF TRAZAS_SECUNDARIAS_TdpnTransicion}
    FTrazabilidad.Add(FormatDateTime('hh:nn:ss.zzz ', Now) + '<TdpnTransicion.OnCondicionContextChanged> requiere evaluacion');
{$ENDIF}
  end;
end;

procedure TdpnTransicion.OnHabilitacionChanged(const AID: integer; const AValue: boolean);
begin
  ActualizarEstadoHabilitacionPorEstadoArco(AID, AValue);
end;

procedure TdpnTransicion.PreparacionDependencias;
var
  LArcoIn: IArcoIn;
  LArcoOut: IArcoOut;
  LCondicion: ICondicion;
  LAccion: IAccion;
begin
  //plazas asociadas
  for LArcoIn in FArcosIn do
  begin
    AgregarDependencia(LArcoIn.Plaza);
  end;
  for LArcoOut in FArcosOut do
  begin
    AgregarDependencia(LArcoOut.Plaza);
  end;
  //dependecias de condiciones/acciones
  for LCondicion in FCondiciones do
  begin
    AgregarDependencias(LCondicion.Dependencias);
  end;
  for LAccion in FAcciones do
  begin
    AgregarDependencias(LAccion.Dependencias);
  end;
  //sort
  FDependencias.Sort(function (const Izq, Der: IBloqueable): integer
                     begin
                       Result := CompareValue(Izq.ID, Der.ID);
                     end);
end;

procedure TdpnTransicion.PrepararPreCondicionesSiguientesEstados;
var
  LCondicion: ICondicion;
  LAccion: IAccion;
  LArcoOut: IArcoOut;
begin
  for LCondicion in FPreCondicionesAgregadas do
  begin
    EliminarCondicion(LCondicion);
  end;
  FPreCondicionesAgregadas.Clear;
  for LAccion in FPreAccionesAgregadas do
  begin
    EliminarAccion(LAccion);
  end;
  FPreCondicionesAgregadas.Clear;
  FPreAccionesAgregadas.Clear;
  for LArcoOut in FArcosOut do
  begin
    FPreCondicionesAgregadas.AddRange(LArcoOut.PreCondicionesPlaza.ToArray);
    FPreAccionesAgregadas.AddRange(LArcoOut.PreAccionesPlaza.ToArray);
  end;
  FCondiciones.AddRange(FPreCondicionesAgregadas.ToArray);
  FAcciones.AddRange(FPreAccionesAgregadas.ToArray);
end;

procedure TdpnTransicion.QueHacerTrasDisparo(const AResultadoDisparo: Boolean);
begin
  if AResultadoDisparo then //ha habido un disparo
  begin
    Inc(FTransicionesRealizadas);
    if FIsHabilitado then //la transicion sigue habilitada
    begin
      if (not FHayAlgunaCondicionDesactivadaQueNoDependeDeToken) then //no hay ninguna condicion general que falla
      begin
        //segun es una transicion que espera de evento o no
        case IsTransicionDependeDeEvento of
           True:
             begin
               //si la condicion tiene aún un evento
               if HayEventosPendientesEnTransicion then
               begin
                 //se reintenta el disparo
                 FOnRequiereEvaluacion.Invoke(ID, Self);
{$IFDEF TRAZAS_SECUNDARIAS_TdpnTransicion}
                 FTrazabilidad.Add(FormatDateTime('hh:nn:ss.zzz ', Now) + '<TdpnTransicion.QueHacerTrasDisparo> requiere evaluacion 1');
{$ENDIF}
               end
               else begin
                      //a la espera de evento
                    end;
             end;
           False:
             begin
               //se reintenta el disparo
               FOnRequiereEvaluacion.Invoke(ID, Self);
{$IFDEF TRAZAS_SECUNDARIAS_TdpnTransicion}
               FTrazabilidad.Add(FormatDateTime('hh:nn:ss.zzz ', Now) + '<TdpnTransicion.QueHacerTrasDisparo> requiere evaluacion 2');
{$ENDIF}
             end;
         end;
      end
      else begin //a dormir infinito hasta que haya un cambio de contexto
             case IsTransicionDependeDeEvento of
               True:
                 begin
                   //si hay eventos pendientes se eliminan
                   EliminarEventosPendientesTransicionSiNecesario;
                   //a la espera de evento
                 end;
               False:
                 begin
                   //a la espera de cambio en condiciones/contexto
                 end;
             end;
           end
    end
    else begin //a esperar hasta que haya un cambio en una plaza
           //si hay eventos pendientes se eliminan
           EliminarEventosPendientesTransicionSiNecesario;
         end;
  end
  else begin //no ha habido disparo
         if FIsHabilitado then //la transicion sigue habilitada, luego problema de condiciones
         begin
           if not FHayAlgunaCondicionDesactivadaQueNoDependeDeToken then //no hay ninguna condicion general que falla
           begin
             //segun es una transicion que espera de evento o no
             case IsTransicionDependeDeEvento of
               True:
                 begin
                   //si la condicion tiene aún un evento
                   //se reintenta el disparo
                   if HayEventosPendientesEnTransicion then
                   begin
                     //se reintenta el disparo
                     FOnRequiereEvaluacion.Invoke(ID, Self);
{$IFDEF TRAZAS_SECUNDARIAS_TdpnTransicion}
                     FTrazabilidad.Add(FormatDateTime('hh:nn:ss.zzz ', Now) + '<TdpnTransicion.QueHacerTrasDisparo> requiere evaluacion 3');
{$ENDIF}
                   end
                   else begin
                          //a la espera de que llegue un evento
                        end;
                 end;
               False:
                 begin
                   //esperamos el tiempo de la transición dormidos
                   //hay condiciones que fallan por lo que debemos dormirnos y reevaluar al despertar
                   IniciarTimerReEvaluacion;
                 end;
             end;
           end
           else begin
                  //a la espera de cambio en condicion/contexto
                  EliminarEventosPendientesTransicionSiNecesario;
                end;
         end
         else begin //a esperar hasta que haya un cambio en una plaza
                //si hay eventos pendientes se eliminan
                EliminarEventosPendientesTransicionSiNecesario;
              end;
       end;
end;

procedure TdpnTransicion.Reset;
begin
  FHayAlgunaCondicionDesactivadaQueNoDependeDeToken := false;
  FEstadoCondicionesNoDependenDeToken.Clear;
end;

procedure TdpnTransicion.SetTiempoEvaluacion(const AValor: integer);
begin
  Guard.CheckTrue(AValor >= 0, 'No puede ser negativo el tiempo de evaluacion');
  if FTiempoEvaluacion <> AValor then
  begin
    FTiempoEvaluacion := AValor;
  end;
end;

procedure TdpnTransicion.Start;
var
  LCount: Integer;
begin
  //precondiciones
  PrepararPreCondicionesSiguientesEstados;
  //calculados
  FCondicionesPreparadas := FCondiciones.AsReadOnly;
  FAccionesPreparadas    := FAcciones.AsReadOnly;

  FArcosInPreparadas  := FArcosIn.AsReadOnly;
  FArcosOutPreparadas := FArcosOut.AsReadOnly;

  //Dependencias
  PreparacionDependencias;

  //Asociacion plazas-tokens
  AsociacionPlazasTokens;
  //Evento?
  FIsTransicionDependeDeEvento := FCondiciones.Any(
                                                     function (const ACondicion: ICondicion): Boolean
                                                     begin
                                                       Result := ACondicion.IsCondicionQueEsperaEvento
                                                     end
                                                  );
  if FIsTransicionDependeDeEvento then
  begin
    FCondicionDeEvento := FCondiciones.Where(
                                               function (const ACondicion: ICondicion): Boolean
                                               begin
                                                 Result := ACondicion.IsCondicionQueEsperaEvento
                                               end
                                            ).First;
  end
  else FCondicionDeEvento := nil;
  LCount := FCondiciones.where(
                                 function (const ACondicion: ICondicion): Boolean
                                 begin
                                   Result := ACondicion.IsCondicionQueEsperaEvento
                                 end
                              ).Count;
  if LCount > 1 then
    raise ETransicionConMasDeUnaCondicionQueEsperaEvento.Create('Hay ' + LCount.ToString + ' condiciones que esperan de evento en la transición ' + Nombre);
  inherited;
end;

procedure TdpnTransicion.Stop;
begin
  inherited;
  FCondicionesPreparadas := nil;
  FAccionesPreparadas    := nil;

  FArcosInPreparadas  := nil;
  FArcosOutPreparadas := nil;
end;

end.
