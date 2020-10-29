unit DPN.Modelo;

interface

uses
  System.Rtti,

  Spring,
  Spring.Collections,

  DPN.Interfaces,
  DPN.NodoPetriNet;

type
  TdpnModelo = class(TdpnNodoPetriNet, IModelo)
  protected
    FTipoModelo: string;
    FNombre: string;
    FElementos: IList<INodoPetriNet>;

    function GetElementos: IList<INodoPetriNet>;

    function GetTipoModelo: string;
    procedure SetTipoModelo(const Valor: string);
    function GetNombre: string;
    procedure SetNombre(const Valor: string);
  public
    constructor Create; override;

    property Elementos: IList<INodoPetriNet> read GetElementos;
    property TipoModelo: string read GetTipoModelo write SetTipoModelo;
    property Nombre: string read GetNombre write SetNombre;
  end;

implementation

uses
  System.SysUtils;

{ TdpnModelo }

constructor TdpnModelo.Create;
begin
  inherited;
  FElementos := TCollections.CreateList<INodoPetriNet>;
end;

function TdpnModelo.GetElementos: IList<INodoPetriNet>;
begin
  Result := FElementos
end;

function TdpnModelo.GetNombre: string;
begin
  Result := FNombre
end;

function TdpnModelo.GetTipoModelo: string;
begin
  Result := FTipoModelo
end;

procedure TdpnModelo.SetNombre(const Valor: string);
begin
  Guard.CheckFalse(Valor.IsEmpty, 'El Nombre no puede ser nulo');
  if FNombre <> Valor then
  begin
    FNombre := Valor;
    //DAVE evento
  end;
end;

procedure TdpnModelo.SetTipoModelo(const Valor: string);
begin
  Guard.CheckFalse(Valor.IsEmpty, 'El TipoModelo no puede ser nulo');
  if FTipoModelo <> Valor then
  begin
    FTipoModelo := Valor;
    //DAVE evento
  end;
end;

end.
