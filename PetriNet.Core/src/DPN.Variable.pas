unit DPN.Variable;

interface

uses
  System.Rtti,

  Spring,

  DPN.Interfaces,
  DPN.Bloqueable;

type
  TdpnVariable = class(TdpnBloqueable, IVariable)
  protected
    FValor: TValue;
    FEventoOnValueChanged: IEvent<EventoNodoPN_ValorTValue>;

    function GetValor: TValue;
    procedure SetValor(const Value: TValue);

    function GetOnValueChanged: IEvent<EventoNodoPN_ValorTValue>;
  public
    constructor Create; override;

    property Valor: TValue read GetValor write SetValor;
    property OnValueChanged: IEvent<EventoNodoPN_ValorTValue> read GetOnValueChanged;
  end;


implementation

uses
  DPN.Core;

{ TdpnVariable }

constructor TdpnVariable.Create;
begin
  inherited;
  FEventoOnValueChanged := DPNCore.CrearEvento<EventoNodoPN_ValorTValue>;
end;

function TdpnVariable.GetOnValueChanged: IEvent<EventoNodoPN_ValorTValue>;
begin
  Result := FEventoOnValueChanged;
end;

function TdpnVariable.GetValor: TValue;
begin
  Result := FValor;
end;

procedure TdpnVariable.SetValor(const Value: TValue);
begin
  if FValor <> Value then
  begin
    FValor := Value;
    FEventoOnValueChanged.Invoke(ID, FValor);
  end;
end;

end.
