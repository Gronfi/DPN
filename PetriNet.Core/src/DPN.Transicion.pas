unit DPN.Transicion;

interface

uses
  System.SyncObjs,

  Spring,
  Spring.Collections,

  Event.Engine.Interfaces,

  DPN.Interfaces,
  DPN.NodoPetriNet;

type
  TdpnTransicion = class (TdpnNodoPetriNet, ITransicion)
  protected
    FIsActivado: boolean;
    FIsHabilitado: boolean;
    FHayAlgunaCondicionDesactivadaQueNoDependeDeToken: Boolean;

    FIsTransicionDependeDeEvento: Boolean;
    FCondicionDeEvento: ICondicion;

    FTransicionesIntentadas: int64;
    FTransicionesRealizadas: int64;

    FPrioridad: integer; //por el momento no se tiene en cuenta

    FCondiciones: IList<ICondicion>;
    FAcciones: IList<IAccion>;
    FDependencias: IList<IBloqueable>;

    FPreCondicionesAgregadas: IList<ICondicion>;

    FLock: TSpinLock;
    FEstadosHabilitacion: IDictionary<integer, boolean>;
    FEstadoCondicionesNoDependenDeToken: IDictionary<integer, boolean>;

    FCondicionesPreparadas: IReadOnlyList<ICondicion>;
    FAccionesPreparadas: IReadOnlyList<IAccion>;

    FArcosIn: IList<IArcoIn>;
    FArcosOut: IList<IArcoOut>;

    FArcosInPreparadas: IReadOnlyList<IArcoIn>;
    FArcosOutPreparadas: IReadOnlyList<IArcoOut>;

    FOnRequiereEvaluacion: IEvent<EventoNodoPN_Transicion>;

    function GetPrioridad: Integer; virtual;
    procedure SetPrioridad(const Value: integer); virtual;

    function GetOnRequiereEvaluacionChanged: IEvent<EventoNodoPN_Transicion>; virtual;
    function GetIsTransicionDependeDeEvento: Boolean; virtual;

    function GetIsHabilitado: Boolean; virtual;

    function GetTransicionesIntentadas: int64;
    function GetTransicionesRealizadas: int64;

    function GetArcosIn: IReadOnlyList<IArcoIn>; virtual;
    function GetArcosOut: IReadOnlyList<IArcoOut>; virtual;

    function GetCondiciones: IReadOnlyList<ICondicion>; virtual;
    function GetAcciones: IReadOnlyList<IAccion>; virtual;

    function GetIsActivado: Boolean; virtual;

    procedure OnCondicionContextChanged(const AID: integer); virtual;
    procedure OnHabilitacionChanged(const AID: integer; const AValue: boolean); virtual;

    procedure PrepararPreCondicionesSiguientesEstados;

    procedure AgregarDependencia(ADependencia: IBloqueable);
    procedure AgregarDependencias(ADependencias: IList<IBloqueable>);
    procedure PreparacionDependencias;
    procedure CapturarDependencias;
    procedure LiberarDependencias;

    function ObtenerMarcadoTokens: IMarcadotokens;

    function EstrategiaDisparo(AEvento: IEventEE = nil): Boolean; virtual;

    procedure EliminarEventosPendientesTransicionSiNecesario;
    function HayEventosPendientesEnTransicion: boolean;
    procedure QueHacerTrasDisparo(const AResultadoDisparo: Boolean);

    procedure CalcularPosibleCambioContexto(const AID: integer);
    procedure ActualizarEstadoTransicionPorCondicionQueNoDependeDeTokens(const AID: integer; const AValor: boolean);
    procedure ActualizarEstadoHabilitacionPorEstadoArco(const AID: integer; const AValor: boolean);
  public
    constructor Create; override;

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

    function DebugLog: string;

    property Prioridad: integer read GetPrioridad write SetPrioridad; //por el momento no se tiene en cuenta
    property IsHabilitado: Boolean read GetIsHabilitado;
    property IsActivado: Boolean read GetIsActivado;

    property ArcosIN: IReadOnlyList<IArcoIn> read GetArcosIn;
    property ArcosOut: IReadOnlyList<IArcoout> read GetArcosOut;

    property Condiciones: IReadOnlyList<ICondicion> read GetCondiciones;
    property Acciones: IReadOnlyList<IAccion> read GetAcciones;

    property TransicionesIntentadas: int64 read GetTransicionesIntentadas;
    property TransicionesRealizadas: int64 read GetTransicionesRealizadas;

    property OnRequiereEvaluacionChanged: IEvent<EventoNodoPN_Transicion> read GetOnRequiereEvaluacionChanged;
    property IsTransicionDependeDeEvento: Boolean read GetIsTransicionDependeDeEvento;
  end;

implementation

uses
  System.SysUtils,
  System.Math,

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
               FIsActivado := True;
               FOnRequiereEvaluacion.Invoke(ID, Self);
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
                                                                                               ) = False;
end;

procedure TdpnTransicion.AddAccion(AAccion: IAccion);
begin
  FAcciones.Add(AAccion);
end;

procedure TdpnTransicion.AddArcoIn(AArco: IArcoIn);
begin
  FArcosIn.Add(AArco);
  AArco.OnHabilitacionChanged.Add(OnHabilitacionChanged);
  ActualizarEstadoHabilitacionPorEstadoArco(AArco.ID, AArco.IsHabilitado);
end;

procedure TdpnTransicion.AddArcoOut(AArco: IArcoOut);
begin
  FArcosOut.Add(AArco);
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
                                                                                               ) = False;
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
  FPrioridad := 1;
  FIsActivado := false;
  FTransicionesIntentadas := 0;
  FTransicionesRealizadas := 0;
  FIsTransicionDependeDeEvento := False;
  FHayAlgunaCondicionDesactivadaQueNoDependeDeToken := False;
  FPreCondicionesAgregadas := TCollections.CreateList<ICondicion>;
  FCondiciones := TCollections.CreateList<ICondicion>;
  FAcciones := TCollections.CreateList<IAccion>;
  FArcosIn := TCollections.CreateList<IArcoIn>;
  FArcosOut := TCollections.CreateList<IArcoOut>;
  FEstadosHabilitacion := TCollections.CreateDictionary<integer, boolean>;
  FEstadoCondicionesNoDependenDeToken := TCollections.CreateDictionary<integer, boolean>;
  FDependencias := TCollections.CreateList<IBloqueable>;
  FOnRequiereEvaluacion := DPNCore.CrearEvento<EventoNodoPN_Transicion>;
end;

function TdpnTransicion.DebugLog: string;
begin
  Result := '';
end;

function TdpnTransicion.EjecutarTransicion: Boolean;
var
  LEvento: IEventEE;
begin
  Result := False;
  Inc(FTransicionesIntentadas);
  CapturarDependencias; // todas las dependencias son capturadas
  // transicion efectiva
  try
    // 1) chequeo de integridad, debe estar habilitada la transicion (enabled)
    if not FEnabled then
      Exit;
    // 2) chequeo de integridad, debe estar habilitada la transicion (estados in y out cumplen sus restricciones)
    if not(FIsHabilitado) then
      Exit;
    // 3) si alguna condicion que no depende de token esta desactivada y no ha habido variacion en la misma no se pasa a evaluar
    if FHayAlgunaCondicionDesactivadaQueNoDependeDeToken then
    begin
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
                 //DAVE: log
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

function TdpnTransicion.EstrategiaDisparo(AEvento: IEventEE = nil): boolean;
var
  LTokens: IMarcadoTokens;
  LTokensOut: IList<IToken>;
  LCondicion: ICondicion;
  LAccion: IAccion;
  LResult: Boolean;
  LArcoIn: IArcoIn;
  LArcoOut: IArcoOut;
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
        Exit;
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

function TdpnTransicion.GetIsActivado: Boolean;
begin
  Result := FIsActivado
end;

function TdpnTransicion.GetIsHabilitado: Boolean;
begin
  Result := FIsHabilitado
end;

function TdpnTransicion.GetIsTransicionDependeDeEvento: Boolean;
begin
  Result := FIsTransicionDependeDeEvento
end;

function TdpnTransicion.GetOnRequiereEvaluacionChanged: IEvent<EventoNodoPN_Transicion>;
begin
  Result := FOnRequiereEvaluacion
end;

function TdpnTransicion.GetPrioridad: Integer;
begin
  Result := FPrioridad
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

procedure TdpnTransicion.LiberarDependencias;
var
  LBloqueable: IBloqueable;
begin
  for LBloqueable in FDependencias do
    LBloqueable.ReleaseLock;
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
    FIsActivado := True;
    FOnRequiereEvaluacion.Invoke(ID, Self);
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
  LArcoOut: IArcoOut;
begin
  for LCondicion in FPreCondicionesAgregadas do
  begin
    EliminarCondicion(LCondicion);
  end;
  FPreCondicionesAgregadas.Clear;
  for LArcoOut in FArcosOut do
  begin
    FPreCondicionesAgregadas.AddRange(LArcoOut.PreCondicionesPlaza.ToArray);
  end;
  FCondiciones.AddRange(FPreCondicionesAgregadas.ToArray);
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
                 FIsActivado := True;
                 FOnRequiereEvaluacion.Invoke(ID, Self);
               end;
             end;
           False:
             begin
               //se reintenta el disparo
               FIsActivado := True;
               FOnRequiereEvaluacion.Invoke(ID, Self);
             end;
         end;
      end
      else begin //a dormir infinito hasta que haya un cambio de contexto
             //si hay eventos pendientes se eliminan
             EliminarEventosPendientesTransicionSiNecesario;
           end;
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
                     FIsActivado := True;
                     FOnRequiereEvaluacion.Invoke(ID, Self);
                   end
                   else begin
                          //DAVE
                        end;
                 end;
               False:
                 begin
                   //esperamos el tiempo de la transición dormidos

                 end;
             end;
           end
           else begin

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

procedure TdpnTransicion.SetPrioridad(const Value: integer);
begin
  Guard.CheckTrue(Value > 0, 'La prioridad debe ser >= 0');
  FPrioridad := Value;
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
