unit DPN.PetriNet.Coordinador;

interface

uses
  DPN.Interfaces;

type
  TdpnPetriNetCoordinador = class
  protected
    FGrafo: IModelo;

    function GetGrafo: IModelo;
    procedure SetGrafo(AGrafo: IModelo);
  public
    procedure Start;
    procedure Stop;

    property Grafo: IModelo read GetGrafo write SetGrafo;
  end;

implementation

{ TdpnPetriNetCoordinador }

function TdpnPetriNetCoordinador.GetGrafo: IModelo;
begin
  Result := FGrafo;
end;

procedure TdpnPetriNetCoordinador.SetGrafo(AGrafo: IModelo);
begin
  FGrafo := AGrafo;
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
