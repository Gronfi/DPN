unit DPN.FuncionesBasicas.TablaVariables;

interface

uses
  System.Rtti,

  Spring.Collections,

  Event.Engine.Interfaces,

  DPN.Interfaces,
  DPN.Condicion,
  DPN.Accion,
  DPN.Variable;
type
  TdpnCondicion_es_tabla_variables = class(TdpnCondicion)
  private
  protected
    FVariable: IVariable;
    FValor: TValue;

    function GetDependencias: IList<IBloqueable>; override;

    function GetVariable: IVariable;
    procedure SetVariable(AVariable: IVariable);

    function GetValorToCheck: TValue;
    procedure SetValorToCheck(const AValue: TValue);

    procedure DoOnVarChanged(const AID: Integer; const AValue: TValue);

    function EvaluarInternal(ATokens: IMarcadoTokens; AEvento: IEvento): Boolean; override;
  public

    property Variable: IVariable read GetVariable write SetVariable;
    property ValorToCheck: TValue read GetValorToCheck write SetValorToCheck;
  end;

  TdpnAccion_tabla_variables = class(TdpnAccion)
  protected
    FVariable: IVariable;
    FValor: TValue;

    function GetDependencias: IList<IBloqueable>; override;

    function GetVariable: IVariable;
    procedure SetVariable(AVariable: IVariable);

    function GetValorToSet: TValue;
    procedure SetValorToSet(const AValue: TValue);

  public
    procedure Execute(ATokens: IMarcadoTokens; AEvento: IEvento = nil); override;

    property Variable: IVariable read GetVariable write SetVariable;
    property ValorToSet: TValue read GetValorToSet write SetValorToSet;
  end;

implementation

{ TdpnCondicion_es_tabla_variables }

procedure TdpnCondicion_es_tabla_variables.DoOnVarChanged(const AID: Integer; const AValue: TValue);
begin
  OnContextoCondicionChanged.Invoke(ID);
end;

function TdpnCondicion_es_tabla_variables.EvaluarInternal(ATokens: IMarcadoTokens; AEvento: IEvento): Boolean;
begin
  Result := (FVariable.Valor.AsInteger = FValor.AsInteger)
end;

function TdpnCondicion_es_tabla_variables.GetDependencias: IList<IBloqueable>;
begin
  Result := TCollections.CreateList<IBloqueable>;
  if Assigned(FVariable) then
    Result.Add(FVariable);
end;

function TdpnCondicion_es_tabla_variables.GetValorToCheck: TValue;
begin
  Result := FValor;
end;

function TdpnCondicion_es_tabla_variables.GetVariable: IVariable;
begin
  Result := FVariable;
end;

procedure TdpnCondicion_es_tabla_variables.SetValorToCheck(const AValue: TValue);
begin
  FValor := AValue;
end;

procedure TdpnCondicion_es_tabla_variables.SetVariable(AVariable: IVariable);
begin
  if Assigned(FVariable) then
  begin
    FVariable.OnValueChanged.Remove(DoOnVarChanged);
  end;
  if FVariable <> AVariable then
  begin
    FVariable := AVariable;
    FVariable.OnValueChanged.Add(DoOnVarChanged);
  end;
end;

{ TdpnAccion_tabla_variables }

procedure TdpnAccion_tabla_variables.Execute(ATokens: IMarcadoTokens; AEvento: IEvento);
begin
  FVariable.Valor:= FValor;
end;

function TdpnAccion_tabla_variables.GetDependencias: IList<IBloqueable>;
begin
  Result := TCollections.CreateList<IBloqueable>;
  if Assigned(FVariable) then
    Result.Add(FVariable);
end;

function TdpnAccion_tabla_variables.GetValorToSet: TValue;
begin
  Result := FValor;
end;

function TdpnAccion_tabla_variables.GetVariable: IVariable;
begin
  Result := FVariable;
end;

procedure TdpnAccion_tabla_variables.SetValorToSet(const AValue: TValue);
begin
  FValor := AValue;
end;

procedure TdpnAccion_tabla_variables.SetVariable(AVariable: IVariable);
begin
  if FVariable <> AVariable then
  begin
    FVariable := AVariable;
  end;
end;

end.
