unit DPN.PetriNet;

interface

uses
  System.Classes,

  DPN.Interfaces;

type
  TdpnPetriNetCoordinador = class(TThread)
  protected
    FGrafo: IModelo;
    FMultipleEnablednessOfTransitions: Boolean;

    function GetMultipleEnablednessOfTransitions: Boolean;
    procedure SetMultipleEnablednessOfTransitions(const Value: Boolean);

    function GetGrafo: IModelo;
    procedure SetGrafo(AGrafo: IModelo);

    procedure Execute; override;
  public
    constructor Create; override;

    procedure Start;
    procedure Stop;

    property MultipleEnablednessOfTransitions: Boolean read GetMultipleEnablednessOfTransitions write SetMultipleEnablednessOfTransitions;
    property Grafo: IModelo read GetGrafo write SetGrafo;
  end;

implementation

{ TdpnPetriNetCoordinador }

constructor TdpnPetriNetCoordinador.Create;
begin
  inherited Create(False);
  FMultipleEnablednessOfTransitions := True; //default
end;

procedure TdpnPetriNetCoordinador.Execute;
begin
  while not Terminated do
  begin

  end;
end;

function TdpnPetriNetCoordinador.GetGrafo: IModelo;
begin
  Result := FGrafo;
end;

function TdpnPetriNetCoordinador.GetMultipleEnablednessOfTransitions: Boolean;
begin
  Result := FMultipleEnablednessOfTransitions
end;

procedure TdpnPetriNetCoordinador.SetGrafo(AGrafo: IModelo);
begin
  FGrafo := AGrafo;
end;

procedure TdpnPetriNetCoordinador.SetMultipleEnablednessOfTransitions(const Value: Boolean);
begin
  FMultipleEnablednessOfTransitions := Value;
end;

procedure TdpnPetriNetCoordinador.Start;
begin
  FGrafo.Start;
end;

procedure TdpnPetriNetCoordinador.Stop;
begin
  FGrafo.Stop;
end;

end.
