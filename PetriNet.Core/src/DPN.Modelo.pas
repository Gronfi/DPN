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
    FElementos: IList<INodoPetriNet>;

    function GetElementos: IList<INodoPetriNet>;

    function GetTipoModelo: string;
    procedure SetTipoModelo(const Valor: string);
  public
    constructor Create; override;

    procedure Start; override;
    procedure Stop; override;

    function GetPlazas: IReadOnlyList<IPlaza>; virtual;
    function GetTransiciones: IReadOnlyList<ITransicion>; virtual;

    property Elementos: IList<INodoPetriNet> read GetElementos;
    property TipoModelo: string read GetTipoModelo write SetTipoModelo;
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

function TdpnModelo.GetPlazas: IReadOnlyList<IPlaza>;
var
  LNodo: INodoPetriNet;
  LModelo: IModelo;
  LPlaza: IPlaza;
  LResult : IList<IPlaza>;
begin
  LResult := TCollections.CreateList<IPlaza>;
  for LNodo in FElementos do
  begin
    if Supports(LNodo, IPlaza, LPlaza) then
      LResult.Add(LPlaza)
    else begin
           if Supports(LNodo, IModelo, LModelo) then
             LResult.AddRange(LModelo.GetPlazas.ToArray);
         end;
  end;
  Result := LResult.AsReadOnly;
end;

function TdpnModelo.GetTipoModelo: string;
begin
  Result := FTipoModelo
end;

function TdpnModelo.GetTransiciones: IReadOnlyList<ITransicion>;
var
  LNodo: INodoPetriNet;
  LModelo: IModelo;
  LTransicion: ITransicion;
  LResult : IList<ITransicion>;
begin
  LResult := TCollections.CreateList<ITransicion>;
  for LNodo in FElementos do
  begin
    if Supports(LNodo, ITransicion, LTransicion) then
      LResult.Add(LTransicion)
    else begin
           if Supports(LNodo, IModelo, LModelo) then
             LResult.AddRange(LModelo.GetTransiciones.ToArray);
         end;
  end;
  Result := LResult.AsReadOnly;
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

procedure TdpnModelo.Start;
var
  LNodo: INodoPetriNet;
begin
  inherited;
  for LNodo in FElementos do
  begin
    LNodo.Start;
  end;
end;

procedure TdpnModelo.Stop;
var
  LNodo: INodoPetriNet;
begin
  inherited;
  for LNodo in FElementos do
  begin
    LNodo.Stop;
  end;
end;

end.
