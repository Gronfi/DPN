unit DPN.Variable;

interface

uses
  System.Rtti,
  System.JSON,

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

    Procedure CargarDeJSON(NodoJson_IN: TJSONObject); override;
    Procedure FormatoJSON(NodoJson_IN: TJSONObject); overload; override;

    Procedure CargarEstadoDeJSON(NodoJson_IN: TJSONObject); override;
    Procedure FormatoEstadoJSON(NodoJson_IN: TJSONObject); overload; override;

    function LogAsString: string; override;

    property Valor: TValue read GetValor write SetValor;
    property OnValueChanged: IEvent<EventoNodoPN_ValorTValue> read GetOnValueChanged;
  end;


implementation

uses
  DPN.Core;

{ TdpnVariable }

procedure TdpnVariable.CargarDeJSON(NodoJson_IN: TJSONObject);
var
  LTmp: string;
begin
  inherited;
  DPNCore.CargarCampoDeNodo<string>(NodoJson_IN, 'Valor', ClassName, LTmp);
  FValor := TValue.From(LTmp);
end;

procedure TdpnVariable.CargarEstadoDeJSON(NodoJson_IN: TJSONObject);
var
  LTmp: string;
begin
  inherited;
  DPNCore.CargarCampoDeNodo<string>(NodoJson_IN, 'Valor', ClassName, LTmp);
  FValor := TValue.From(LTmp);
end;

constructor TdpnVariable.Create;
begin
  inherited;
  FEventoOnValueChanged := DPNCore.CrearEvento<EventoNodoPN_ValorTValue>;
end;

procedure TdpnVariable.FormatoEstadoJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  NodoJson_IN.AddPair('Valor', TJSONString.Create(FValor.ToString));
end;

procedure TdpnVariable.FormatoJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  NodoJson_IN.AddPair('Valor', TJSONString.Create(FValor.ToString));
end;

function TdpnVariable.GetOnValueChanged: IEvent<EventoNodoPN_ValorTValue>;
begin
  Result := FEventoOnValueChanged;
end;

function TdpnVariable.GetValor: TValue;
begin
  Result := FValor;
end;

function TdpnVariable.LogAsString: string;
begin
  Result := inherited + '<' + ClassName + '>' + '[Valor]' + Valor.ToString;
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
