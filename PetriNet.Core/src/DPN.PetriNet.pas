unit DPN.PetriNet;

interface

uses
  System.Classes,
  System.Types,

  DPN.Helpers,
  DPN.Interfaces;

type
  TdpnPetriNetCoordinador = class(TThread)
  protected
    FGrafo: IModelo;
    FEstado: EEstadoPetriNet;
    FComm: TThreadedQueue<ITransicion>;
    FMultipleEnablednessOfTransitions: Boolean;

    function GetMultipleEnablednessOfTransitions: Boolean;
    procedure SetMultipleEnablednessOfTransitions(const Value: Boolean);

    function GetGrafo: IModelo;
    procedure SetGrafo(AGrafo: IModelo);

    function GetEstado: EEstadoPetriNet;

    procedure DoOnTransicionRequiereEvaluacion(const AID: integer; ATransicion: ITransicion);

    function GetSiguientePeticionDeTransicion(out AQueueSize: Integer; out ATransicion: ITransicion): TWaitResult; overload;
    function GetSiguientePeticionDeTransicion(out AQueueSize: Integer; out ATransicion: ITransicion; const ATimeOut: Cardinal): TWaitResult; overload;

    procedure AddTransicionAEvaluar(ATransicion: ITransicion);

    procedure LinkarTransicionesAlCoordinador;
    procedure DeslinkarTransicionesAlCoordinador;

    procedure EjecutarTransicionEnTask(ATransicion: ITransicion);
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Start;
    procedure Stop;

    property MultipleEnablednessOfTransitions: Boolean read GetMultipleEnablednessOfTransitions write SetMultipleEnablednessOfTransitions;
    property Grafo: IModelo read GetGrafo write SetGrafo;
    property Estado: EEstadoPetriNet read GetEstado;
  end;

implementation

uses
  System.SysUtils,
  System.Threading;

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

constructor TdpnPetriNetCoordinador.Create;
begin
  inherited Create(False);
  FEstado                           := EEstadoPetriNet.GrafoNoAsignado;
  FMultipleEnablednessOfTransitions := True;
  FComm                             := TThreadedQueue<ITransicion>.Create(10, 100, Cardinal.MaxValue);
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
  if Assigned(FGrafo) then
  begin
    LinkarTransicionesAlCoordinador;
    FGrafo.Start;
    FEstado := EEstadoPetriNet.Iniciada;
  end;
end;

procedure TdpnPetriNetCoordinador.Stop;
begin
  if Assigned(FGrafo) then
  begin
    FEstado := EEstadoPetriNet.Detenida;
    DeslinkarTransicionesAlCoordinador;
    FGrafo.Stop;
  end;
end;

end.
