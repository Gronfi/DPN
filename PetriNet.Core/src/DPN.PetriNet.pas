unit DPN.PetriNet;

interface

uses
  System.JSON,
  System.SyncObjs,
  System.Classes,
  System.Types,

  Spring,
  Spring.Collections,

  Helper.ThreadedQueue,
  DPN.Interfaces;

type
  TdpnPetriNetCoordinador = class(TdpnPetriNetCoordinadorBase)
  protected
    FComm: TThreadedQueue<ITransicion>;
    FLockMarcado: TLightweightMREW;

    procedure DoOnTransicionRequiereEvaluacion(const AID: integer; ATransicion: ITransicion);
    procedure DoOnMarcadoPlazasCantidadTokensChanged(const AID: integer; AMarcado: IMarcadoPlazasCantidadTokens);
    procedure DoOnTokensPlazaChanged(const AID: integer; const ACantidadTokens: integer);

    function GetSiguientePeticionDeTransicion(out AQueueSize: Integer; out ATransicion: ITransicion): TWaitResult; overload;
    function GetSiguientePeticionDeTransicion(out AQueueSize: Integer; out ATransicion: ITransicion; const ATimeOut: Cardinal): TWaitResult; overload;

    procedure AddTransicionAEvaluar(ATransicion: ITransicion);

    procedure EjecutarTransicionEnTask(ATransicion: ITransicion);
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AsociacionesPN; override;
  end;

implementation

uses
  System.SysUtils,
  System.Threading,

  Event.Engine.Utils,
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
                                   ATransicion.OnMarcadoChanged.Add(DoOnMarcadoPlazasCantidadTokensChanged);
                                   ATransicion.OnRequiereEvaluacionChanged.Add(DoOnTransicionRequiereEvaluacion);
                                 end);

  FGrafo.GetPlazas.ForEach(
                                 procedure (const APlaza: IPlaza)
                                 begin
                                   FNodos[APlaza.ID] := APlaza;
                                   FMarcado[APlaza.ID] := 0;
                                   FNombresPlazas[APlaza.Nombre] := APlaza.ID;
                                   APlaza.OnTokenCountChanged.Add(DoOnTokensPlazaChanged);
                                 end);

  FGrafo.GetArcos.ForEach(
                                 procedure (const AArco: IArco)
                                 begin
                                   FNodos[AArco.ID] := AArco;
                                   FNombresArcos[AArco.Nombre] := AArco.ID;
                                 end);

  FGrafo.GetModelos.ForEach(
                                 procedure (const AModelo: IModelo)
                                 begin
                                   FNodos[AModelo.ID] := AModelo;
                                   FNombresModelos[AModelo.Nombre] := AModelo.ID;
                                 end);
  FGrafo.GetCondiciones.ForEach(
                                 procedure (const ACondicion: ICondicion)
                                 begin
                                   FNodos[ACondicion.ID] := ACondicion;
                                   FNombresCondiciones[ACondicion.Nombre] := ACondicion.ID;
                                 end);
  FGrafo.GetAcciones.ForEach(
                                 procedure (const AAccion: IAccion)
                                 begin
                                   FNodos[AAccion.ID] := AAccion;
                                   FNombresAcciones[AAccion.Nombre] := AAccion.ID;
                                 end);
  FGrafo.GetVariables.ForEach(
                                 procedure (const AVariable: IVariable)
                                 begin
                                   FNodos[AVariable.ID] := AVariable;
                                   FNombresVariables[AVariable.Nombre] := AVariable.ID;
                                 end);
  FGrafo.GetDecoraciones.ForEach(
                                 procedure (const ADecoracion: IDecoracion)
                                 begin
                                   FNodos[ADecoracion.ID] := ADecoracion;
                                   FNombresDecoraciones[ADecoracion.Nombre] := ADecoracion.ID;
                                 end);
end;

constructor TdpnPetriNetCoordinador.Create;
begin
  inherited;
  FComm := TThreadedQueue<ITransicion>.Create(10, 100, Cardinal.MaxValue);
end;

destructor TdpnPetriNetCoordinador.Destroy;
begin
  FComm.DoShutDown;
  inherited;
end;

procedure TdpnPetriNetCoordinador.DoOnMarcadoPlazasCantidadTokensChanged(const AID: Integer; AMarcado: IMarcadoPlazasCantidadTokens);
var
  LPlaza: integer;
begin
  FLockMarcado.BeginWrite;
  try
    for LPlaza in AMarcado.Marcado.Keys do
      FMarcado[LPlaza] := AMarcado.Marcado[LPlaza];
  finally
    FLockMarcado.EndWrite;
  end;
end;

procedure TdpnPetriNetCoordinador.DoOnTokensPlazaChanged(const AID, ACantidadTokens: integer);
begin
  //
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

function TdpnPetriNetCoordinador.GetSiguientePeticionDeTransicion(out AQueueSize: Integer; out ATransicion: ITransicion; const ATimeOut: Cardinal): TWaitResult;
begin
  Result := FComm.PopItem(AQueueSize, ATransicion, ATimeout);
end;

function TdpnPetriNetCoordinador.GetSiguientePeticionDeTransicion(out AQueueSize: Integer; out ATransicion: ITransicion): TWaitResult;
begin
  Result := FComm.PopItem(AQueueSize, ATransicion);
end;

end.
