unit DPN.PetriNet;

interface

uses
  System.SyncObjs,
  System.Classes,
  System.Types,

  Spring,
  Spring.Collections,

  Helper.ThreadedQueue,
  DPN.Interfaces;

type
  TdpnPetriNetCoordinador = class(TThread)
  protected
    FGrafo: IModelo;
    FEstado: EEstadoPetriNet;
    FComm: TThreadedQueue<ITransicion>;
    FMultipleEnablednessOfTransitions: Boolean;
    FLock: TLightweightMREW;
    FEvento_OnEstadoChanged: IEvent<EventoEstadoPN>;

    FNodos: IDictionary<Integer, INodoPetriNet>;
    FMarcado: IDictionary<Integer, Integer>;
    FNombresEstados: IBidiDictionary<String, Integer>;
    FNombresTransiciones: IBidiDictionary<String, Integer>;

    function GetMultipleEnablednessOfTransitions: Boolean;
    procedure SetMultipleEnablednessOfTransitions(const Value: Boolean);

    function GetGrafo: IModelo;
    procedure SetGrafo(AGrafo: IModelo);

    function GetEstado: EEstadoPetriNet;
    function GetOnEstadoChanged: IEvent<EventoEstadoPN>;

    procedure DoOnTransicionRequiereEvaluacion(const AID: integer; ATransicion: ITransicion);
    procedure DoOnTokenCountChanged(const AID: integer; AMarcado: IMarcadoPlazasCantidadTokens);

    function GetSiguientePeticionDeTransicion(out AQueueSize: Integer; out ATransicion: ITransicion): TWaitResult; overload;
    function GetSiguientePeticionDeTransicion(out AQueueSize: Integer; out ATransicion: ITransicion; const ATimeOut: Cardinal): TWaitResult; overload;

    procedure AddTransicionAEvaluar(ATransicion: ITransicion);

    procedure LinkarTransicionesAlCoordinador;
    procedure DeslinkarTransicionesAlCoordinador;

    procedure AsociacionesPN;

    procedure EjecutarTransicionEnTask(ATransicion: ITransicion);
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;

    //function GetTransicionesHabilitadas: I

    procedure Start;
    procedure Stop;
    procedure Reset;

    function LogMarcado: string;

    property MultipleEnablednessOfTransitions: Boolean read GetMultipleEnablednessOfTransitions write SetMultipleEnablednessOfTransitions;
    property Grafo: IModelo read GetGrafo write SetGrafo;
    property Estado: EEstadoPetriNet read GetEstado;
    property OnEstadoChanged: IEvent<EventoEstadoPN> read GetOnEstadoChanged;
    property Nodos: IDictionary<Integer, INodoPetriNet> read FNodos;
    property NombresEstados: IBidiDictionary<String, Integer> read FNombresEstados;
    property NombresTransiciones: IBidiDictionary<String, Integer>read FNombresTransiciones;
  end;

implementation

uses
  System.SysUtils,
  System.Threading,

  DPN.Core;

{ TdpnPetriNetCoordinador }

procedure TdpnPetriNetCoordinador.AddTransicionAEvaluar(ATransicion: ITransicion);
var
  LSize: Integer;
  LRes : TWaitResult;
begin
  repeat
    LRes := FComm.PushItem(ATransicion, LSize);
    case LRes of
      wrTimeout:
        begin
          FComm.Grow(LSize);
          if Terminated then
            Exit;
        end;
    end;
  until LRes = TWaitResult.wrSignaled;
end;

procedure TdpnPetriNetCoordinador.AsociacionesPN;
begin
  FGrafo.GetTransiciones.ForEach(
                                 procedure (const ATransicion: ITransicion)
                                 begin
                                   FNodos[ATransicion.ID] := ATransicion;
                                   FNombresTransiciones[ATransicion.Nombre] := ATransicion.ID;
                                   ATransicion.OnMarcadoChanged.Add(DoOnTokenCountChanged);
                                 end);
  FGrafo.GetPlazas.ForEach(
                                 procedure (const APlaza: IPlaza)
                                 begin
                                   FNodos[APlaza.ID] := APlaza;
                                   FMarcado[APlaza.ID] := 0;
                                   FNombresEstados[APlaza.Nombre] := APlaza.ID;
                                   //APlaza.OnTokenCountChanged.Add(DoOnTokenCountChanged);
                                 end);
end;

constructor TdpnPetriNetCoordinador.Create;
begin
  inherited Create(False);
  FEstado                           := EEstadoPetriNet.GrafoNoAsignado;
  FMultipleEnablednessOfTransitions := True;
  FComm                             := TThreadedQueue<ITransicion>.Create(10, 100, Cardinal.MaxValue);

  FNodos := TCollections.CreateDictionary<Integer, INodoPetriNet>;
  FMarcado := TCollections.CreateDictionary<Integer, Integer>;
  FNombresEstados     := TCollections.CreateBidiDictionary<String, Integer>;
  FNombresTransiciones:= TCollections.CreateBidiDictionary<String, Integer>;

  FEvento_OnEstadoChanged := DPNCore.CrearEvento<EventoEstadoPN>;
end;

procedure TdpnPetriNetCoordinador.DeslinkarTransicionesAlCoordinador;
begin
  FGrafo.GetTransiciones.ForEach(
                                 procedure (const ATransicion: ITransicion)
                                 begin
                                   ATransicion.OnRequiereEvaluacionChanged.Remove(DoOnTransicionRequiereEvaluacion)
                                 end);
end;

destructor TdpnPetriNetCoordinador.Destroy;
begin
  FEstado := EEstadoPetriNet.Detenida;
  Terminate;
  FComm.DoShutDown;
  WaitFor;
end;

procedure TdpnPetriNetCoordinador.DoOnTokenCountChanged(const AID: Integer; AMarcado: IMarcadoPlazasCantidadTokens);
var
  LPlaza: integer;
begin
  FLock.BeginWrite;
  try
    for LPlaza in AMarcado.Marcado.Keys do
      FMarcado[LPlaza] := AMarcado.Marcado[LPlaza];
  finally
    FLock.EndWrite;
  end;
end;

procedure TdpnPetriNetCoordinador.DoOnTransicionRequiereEvaluacion(const AID: integer; ATransicion: ITransicion);
begin
  AddTransicionAEvaluar(ATransicion);
end;

procedure TdpnPetriNetCoordinador.EjecutarTransicionEnTask(ATransicion: ITransicion);
var
  LTask: ITask;
begin
  LTask := TTask.Create(
                        procedure
                        begin
                          ATransicion.EjecutarTransicion;
                        end);
  LTask.Start;
end;

procedure TdpnPetriNetCoordinador.Execute;
var
  LSize      : Integer;
  LTransicion: ITransicion;
  LRes       : TWaitResult;
begin
  while not Terminated do
  begin
    repeat
      LRes := GetSiguientePeticionDeTransicion(LSize, LTransicion);
      case LRes of
        wrSignaled:
          begin
            if not Terminated then
            begin
              case FMultipleEnablednessOfTransitions of
                False:
                  begin
                    LTransicion.EjecutarTransicion;
                  end;
                True:
                  begin
                    EjecutarTransicionEnTask(LTransicion);
                  end;
              end;
            end
            else Exit;
          end;
        wrAbandoned:
          begin
            Exit;
          end;
      end;
    until (LSize = 0) or (LRes = TWaitResult.wrTimeout);
  end;
end;

function TdpnPetriNetCoordinador.GetEstado: EEstadoPetriNet;
begin
  Result := FEstado;
end;

function TdpnPetriNetCoordinador.GetGrafo: IModelo;
begin
  Result := FGrafo;
end;

function TdpnPetriNetCoordinador.GetMultipleEnablednessOfTransitions: Boolean;
begin
  Result := FMultipleEnablednessOfTransitions
end;

function TdpnPetriNetCoordinador.GetOnEstadoChanged: IEvent<EventoEstadoPN>;
begin
  Result := FEvento_OnEstadoChanged
end;

function TdpnPetriNetCoordinador.GetSiguientePeticionDeTransicion(out AQueueSize: Integer; out ATransicion: ITransicion; const ATimeOut: Cardinal): TWaitResult;
begin
  Result := FComm.PopItem(AQueueSize, ATransicion, ATimeout);
end;

procedure TdpnPetriNetCoordinador.LinkarTransicionesAlCoordinador;
begin
  FGrafo.GetTransiciones.ForEach(
                                 procedure (const ATransicion: ITransicion)
                                 begin
                                   ATransicion.OnRequiereEvaluacionChanged.Add(DoOnTransicionRequiereEvaluacion)
                                 end);
end;

function TdpnPetriNetCoordinador.LogMarcado: string;
var
  LPlaza: integer;
begin
  for LPlaza in FMarcado.Keys do
  begin
    Result := Result + LPlaza.ToString + ' : ' + FMarcado[LPlaza].ToString + #13#10;
  end;
end;

procedure TdpnPetriNetCoordinador.Reset;
begin
  if Assigned(FGrafo) then
  begin
    FGrafo.Reset;
  end;
end;

function TdpnPetriNetCoordinador.GetSiguientePeticionDeTransicion(out AQueueSize: Integer; out ATransicion: ITransicion): TWaitResult;
begin
  Result := FComm.PopItem(AQueueSize, ATransicion);
end;

procedure TdpnPetriNetCoordinador.SetGrafo(AGrafo: IModelo);
begin
  FGrafo := AGrafo;
  if Assigned(FGrafo) then
  begin
    FEstado := EEstadoPetriNet.Detenida;
  end
  else FEstado := EEstadoPetriNet.GrafoNoAsignado;
end;

procedure TdpnPetriNetCoordinador.SetMultipleEnablednessOfTransitions(const Value: Boolean);
begin
  FMultipleEnablednessOfTransitions := Value;
end;

procedure TdpnPetriNetCoordinador.Start;
begin
  FMarcado.Clear;
  FNodos.Clear;
  FNombresEstados.Clear;
  FNombresTransiciones.Clear;
  if Assigned(FGrafo) then
  begin
    LinkarTransicionesAlCoordinador;
    AsociacionesPN;
    FGrafo.Start;
    FEstado := EEstadoPetriNet.Iniciada;
    FEvento_OnEstadoChanged.Invoke(FEstado);
  end;
end;

procedure TdpnPetriNetCoordinador.Stop;
begin
  if Assigned(FGrafo) then
  begin
    FEstado := EEstadoPetriNet.Detenida;
    DeslinkarTransicionesAlCoordinador;
    FGrafo.Stop;
    FEvento_OnEstadoChanged.Invoke(FEstado);
  end;
end;

end.
