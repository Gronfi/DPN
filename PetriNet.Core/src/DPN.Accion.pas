unit DPN.Accion;

interface

uses
  Spring,
  Spring.Collections,

  DPN.Interfaces,
  DPN.NodoPetriNet;

type
  TdpnAccion = class abstract(TdpnNodoPetriNet, IAccion)
  protected
    FTransicion: ITransicion;

    function GetDependencias: IList<IBloqueable>; virtual; abstract;

    function GetTransicion: ITransicion; virtual;
    procedure SetTransicion(const Value: ITransicion); virtual;
  public
    constructor Create; override;

    procedure Execute(ATokens: IMarcadoTokens); overload; virtual;

    property Dependencias: IList<IBloqueable> read GetDependencias;
    property Transicion: ITransicion read GetTransicion write SetTransicion;
  end;

implementation

uses
  DPN.Core;

{ TdpnAccion }

constructor TdpnAccion.Create;
begin
  inherited;
end;

procedure TdpnAccion.Execute(ATokens: IMarcadoTokens);
begin
  ;
end;

function TdpnAccion.GetTransicion: ITransicion;
begin
  Result := FTransicion
end;

procedure TdpnAccion.SetTransicion(const Value: ITransicion);
begin
  FTransicion := Value;
end;

end.
