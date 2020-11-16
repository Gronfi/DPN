unit DPN.FuncionesBasicas.TablaVariables;

interface

uses
  System.JSON,
  System.Rtti,

  Event.Engine.Interfaces,

  DPN.FuncionesBasicas.Tipos,
  DPN.FuncionesBasicas.TablaVariables.Base,
  DPN.Interfaces,
  DPN.Condicion,
  DPN.Accion,
  DPN.Variable;
type
  TdpnCondicion_es_valor_variable = class(TdpnCondicion_variable)
  protected
    FValor: TValue;
    FOperacion: ETipoOperacionComparacion;

    function GetValorToCheck: TValue;
    procedure SetValorToCheck(const AValue: TValue);

    function MatchesStringPatron(const Input, Patron: string): Boolean;

    function GetOperacion: ETipoOperacionComparacion;
    procedure SetOperacion(const AValor: ETipoOperacionComparacion);

    function EvaluarInternal(ATokens: IMarcadoTokens; AEvento: IEvento): Boolean; override;
  public
    Procedure CargarDeJSON(NodoJson_IN: TJSONObject); override;
    Procedure FormatoJSON(NodoJson_IN: TJSONObject); overload; override;

    property ValorToCheck: TValue read GetValorToCheck write SetValorToCheck;
    property Operacion: ETipoOperacionComparacion read GetOperacion write SetOperacion;
  end;

  TdpnCondicion_son_valores_iguales_en_variables = class(TdpnCondicion_DosVariables)
  protected
    function EvaluarInternal(ATokens: IMarcadoTokens; AEvento: IEvento): Boolean; override;
  public
  end;

  TdpnAccion_set_valor_variable = class(TdpnAccion_Variable)
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
  System.RegularExpressions,
  System.SysUtils,

  Spring,

  DPN.Core;

{ TdpnCondicion_es_tabla_variables }

procedure TdpnCondicion_es_valor_variable.CargarDeJSON(NodoJson_IN: TJSONObject);
var
  LValor: string;
  LOperacion: string;
begin
  inherited;
  DPNCore.CargarCampoDeNodo<string>(NodoJson_IN, 'ValorToCheck', ClassName, LValor);
  DPNCore.CargarCampoDeNodo<string>(NodoJson_IN, 'Operacion', ClassName, LOperacion);
  ValorToCheck := LValor;
  FOperacion := TEnum.Parse<ETipoOperacionComparacion>(LOperacion);
end;

function TdpnCondicion_es_valor_variable.EvaluarInternal(ATokens: IMarcadoTokens; AEvento: IEvento): Boolean;
begin
  case FOperacion of
    EsIgual: Result := (FVariable.Valor.ToString = FValor.ToString);
    EsDistinto: Result := (FVariable.Valor.ToString <> FValor.ToString);
    EsMayor:
      begin
        Guard.CheckTrue(FVariable.Valor.Kind in [tkInteger, tkInt64, tkFloat]);
        case FVariable.Valor.Kind of
          tkInteger: Result := (FVariable.Valor.AsInteger > FValor.AsInteger);
          tkFloat: Result := (FVariable.Valor.AsExtended > FValor.AsExtended);
          tkInt64: Result := (FVariable.Valor.AsInt64 > FValor.AsInt64);
        end;
      end;
    EsMenor:
      begin
        Guard.CheckTrue(FVariable.Valor.Kind in [tkInteger, tkInt64, tkFloat]);
        case FVariable.Valor.Kind of
          tkInteger: Result := (FVariable.Valor.AsInteger < FValor.AsInteger);
          tkFloat: Result := (FVariable.Valor.AsExtended < FValor.AsExtended);
          tkInt64: Result := (FVariable.Valor.AsInt64 < FValor.AsInt64);
        end;
      end;
    EsMayorIgual:
      begin
        Guard.CheckTrue(FVariable.Valor.Kind in [tkInteger, tkInt64, tkFloat]);
        case FVariable.Valor.Kind of
          tkInteger: Result := (FVariable.Valor.AsInteger >= FValor.AsInteger);
          tkFloat: Result := (FVariable.Valor.AsExtended >= FValor.AsExtended);
          tkInt64: Result := (FVariable.Valor.AsInt64 >= FValor.AsInt64);
        end;
      end;
    EsMenorIgual:
      begin
        Guard.CheckTrue(FVariable.Valor.Kind in [tkInteger, tkInt64, tkFloat]);
        case FVariable.Valor.Kind of
          tkInteger: Result := (FVariable.Valor.AsInteger <= FValor.AsInteger);
          tkFloat: Result := (FVariable.Valor.AsExtended <= FValor.AsExtended);
          tkInt64: Result := (FVariable.Valor.AsInt64 <= FValor.AsInt64);
        end;
      end;
    CumplePatron:
      begin
        Result := MatchesStringPatron(FVariable.Valor.ToString, FValor.ToString);
      end;
    NoCumplePatron:
      begin
        Result := not MatchesStringPatron(FVariable.Valor.ToString, FValor.ToString);
      end;
  end;
end;

procedure TdpnCondicion_es_valor_variable.FormatoJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  NodoJson_IN.AddPair('ValorToCheck', TJSONString.Create(ValorToCheck.ToString));
  NodoJson_IN.AddPair('Operacion', TJSONString.Create(TEnum.GetName<ETipoOperacionComparacion>(Operacion)));
end;

function TdpnCondicion_es_valor_variable.GetOperacion: ETipoOperacionComparacion;
begin
  Result := FOperacion
end;

function TdpnCondicion_es_valor_variable.GetValorToCheck: TValue;
begin
  Result := FValor;
end;

function TdpnCondicion_es_valor_variable.MatchesStringPatron(const Input, Patron: string): Boolean;
begin
  Result := System.RegularExpressions.TRegEx.IsMatch(Input, Patron);
end;

procedure TdpnCondicion_es_valor_variable.SetOperacion(const AValor: ETipoOperacionComparacion);
begin
  FOperacion := AValor;
end;

procedure TdpnCondicion_es_valor_variable.SetValorToCheck(const AValue: TValue);
begin
  FValor := AValue;
end;

{ TdpnAccion_tabla_variables }

procedure TdpnAccion_set_valor_variable.CargarDeJSON(NodoJson_IN: TJSONObject);
var
  LValor: string;
begin
  inherited;
  DPNCore.CargarCampoDeNodo<string>(NodoJson_IN, 'ValorToSet', ClassName, LValor);
  ValorToSet := LValor;
end;

procedure TdpnAccion_set_valor_variable.Execute(ATokens: IMarcadoTokens; AEvento: IEvento);
begin
  FVariable.Valor:= FValor;
end;

procedure TdpnAccion_set_valor_variable.FormatoJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  NodoJson_IN.AddPair('ValorToSet', TJSONString.Create(ValorToSet.ToString));
end;

function TdpnAccion_set_valor_variable.GetValorToSet: TValue;
begin
  Result := FValor;
end;

procedure TdpnAccion_set_valor_variable.SetValorToSet(const AValue: TValue);
begin
  FValor := AValue;
end;

{ TdpnCondicion_son_valores_iguales_en_variables }

function TdpnCondicion_son_valores_iguales_en_variables.EvaluarInternal(ATokens: IMarcadoTokens; AEvento: IEvento): Boolean;
begin
  Result := (FVariable1.Valor.ToString = FVariable2.Valor.ToString)
end;

end.
