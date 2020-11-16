unit DPN.FuncionesBasicas.TablaVariables;

interface

uses
  System.JSON,
  System.Rtti,

  Event.Engine.Interfaces,

  DPN.FuncionesBasicas.TablaVariables.Base,
  DPN.Interfaces,
  DPN.Condicion,
  DPN.Accion,
  DPN.Variable;
type
  TdpnCondicion_es_tabla_variables = class(TdpnCondicion_variable)
  protected
    FValor: TValue;

    function GetValorToCheck: TValue;
    procedure SetValorToCheck(const AValue: TValue);

    function EvaluarInternal(ATokens: IMarcadoTokens; AEvento: IEvento): Boolean; override;
  public
    Procedure CargarDeJSON(NodoJson_IN: TJSONObject); override;
    Procedure FormatoJSON(NodoJson_IN: TJSONObject); overload; override;

    property ValorToCheck: TValue read GetValorToCheck write SetValorToCheck;
  end;

  TdpnAccion_tabla_variables = class(TdpnAccion_Variable)
  protected
    FValor: TValue;

    function GetValorToSet: TValue;
    procedure SetValorToSet(const AValue: TValue);

  public
    Procedure CargarDeJSON(NodoJson_IN: TJSONObject); override;
    Procedure FormatoJSON(NodoJson_IN: TJSONObject); overload; override;

    procedure Execute(ATokens: IMarcadoTokens; AEvento: IEvento = nil); override;

    property ValorToSet: TValue read GetValorToSet write SetValorToSet;
  end;

implementation

uses
  System.SysUtils,

  DPN.Core;

{ TdpnCondicion_es_tabla_variables }

procedure TdpnCondicion_es_tabla_variables.CargarDeJSON(NodoJson_IN: TJSONObject);
var
  LValor: string;
begin
  inherited;
  DPNCore.CargarCampoDeNodo<string>(NodoJson_IN, 'ValorToCheck', ClassName, LValor);
  ValorToCheck := LValor;
end;

function TdpnCondicion_es_tabla_variables.EvaluarInternal(ATokens: IMarcadoTokens; AEvento: IEvento): Boolean;
begin
  Result := (FVariable.Valor.ToString = FValor.ToString)
end;

procedure TdpnCondicion_es_tabla_variables.FormatoJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  NodoJson_IN.AddPair('ValorToCheck', TJSONString.Create(ValorToCheck.ToString));
end;

function TdpnCondicion_es_tabla_variables.GetValorToCheck: TValue;
begin
  Result := FValor;
end;

procedure TdpnCondicion_es_tabla_variables.SetValorToCheck(const AValue: TValue);
begin
  FValor := AValue;
end;

{ TdpnAccion_tabla_variables }

procedure TdpnAccion_tabla_variables.CargarDeJSON(NodoJson_IN: TJSONObject);
var
  LValor: string;
begin
  inherited;
  DPNCore.CargarCampoDeNodo<string>(NodoJson_IN, 'ValorToSet', ClassName, LValor);
  ValorToSet := LValor;
end;

procedure TdpnAccion_tabla_variables.Execute(ATokens: IMarcadoTokens; AEvento: IEvento);
begin
  FVariable.Valor:= FValor;
end;

procedure TdpnAccion_tabla_variables.FormatoJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  NodoJson_IN.AddPair('ValorToSet', TJSONString.Create(ValorToSet.ToString));
end;

function TdpnAccion_tabla_variables.GetValorToSet: TValue;
begin
  Result := FValor;
end;

procedure TdpnAccion_tabla_variables.SetValorToSet(const AValue: TValue);
begin
  FValor := AValue;
end;

end.
