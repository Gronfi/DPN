unit DPN.FuncionesBasicas.TablaVariables.Base;

interface

uses
  System.JSON,
  System.Rtti,

  Spring.Collections,

  Event.Engine.Interfaces,

  DPN.Interfaces,
  DPN.Condicion,
  DPN.Accion,
  DPN.Variable;

type
  TdpnCondicion_Variable = class abstract(TdpnCondicion)
  protected
    FVariable: IVariable;
    FNombreVariable: string;

    function GetDependencias: IList<IBloqueable>; override;

    function GetVariable: IVariable;
    procedure SetVariable(AVariable: IVariable);

    procedure DoOnVarChanged(const AID: Integer; const AValue: TValue);
  public
    constructor Create; override;

    Procedure CargarDeJSON(NodoJson_IN: TJSONObject); override;
    Procedure FormatoJSON(NodoJson_IN: TJSONObject); overload; override;

    procedure Setup; override;
    function CheckIsOK(out AListaErrores: IList<string>): boolean; override;

    property Variable: IVariable read GetVariable write SetVariable;
  end;

  TdpnAccion_Variable = class abstract(TdpnAccion)
  protected
    FVariable: IVariable;
    FNombreVariable: string;

    function GetDependencias: IList<IBloqueable>; override;

    function GetVariable: IVariable;
    procedure SetVariable(AVariable: IVariable);

  public
    constructor Create; override;

    Procedure CargarDeJSON(NodoJson_IN: TJSONObject); override;
    Procedure FormatoJSON(NodoJson_IN: TJSONObject); overload; override;

    procedure Setup; override;
    function CheckIsOK(out AListaErrores: IList<string>): boolean; override;

    property Variable: IVariable read GetVariable write SetVariable;
  end;

implementation

uses
  System.SysUtils,

  DPN.Core;

{ TdpnCondicion_variable }

procedure TdpnCondicion_variable.CargarDeJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  DPNCore.CargarCampoDeNodo<string>(NodoJson_IN, 'NombreVariable', ClassName, FNombreVariable);
end;

function TdpnCondicion_variable.CheckIsOK(out AListaErrores: IList<string>): boolean;
begin
  Result := inherited;
  if FNombreVariable.IsEmpty then
  begin
    Result := False;
    AListaErrores.Add('NombreVariable is Empty');
  end;
end;

constructor TdpnCondicion_variable.Create;
begin
  inherited;
  FNombreVariable := '';
end;

procedure TdpnCondicion_variable.DoOnVarChanged(const AID: Integer; const AValue: TValue);
begin
  OnContextoCondicionChanged.Invoke(ID);
end;

procedure TdpnCondicion_variable.FormatoJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  NodoJson_IN.AddPair('NombreVariable', TJSONString.Create(Variable.Nombre));
end;

function TdpnCondicion_variable.GetDependencias: IList<IBloqueable>;
begin
  Result := TCollections.CreateList<IBloqueable>;
  if Assigned(FVariable) then
    Result.Add(FVariable);
end;

function TdpnCondicion_variable.GetVariable: IVariable;
begin
  Result := FVariable;
end;

procedure TdpnCondicion_variable.Setup;
var
  LVariable: IVariable;
begin
  inherited;
  if not FNombreVariable.IsEmpty then
  begin
    LVariable := PetriNetController.GetVariable(FNombreVariable);
    if Assigned(LVariable) then
      FVariable := LVariable;
  end;
end;

procedure TdpnCondicion_variable.SetVariable(AVariable: IVariable);
begin
  if Assigned(FVariable) then
  begin
    FVariable.OnValueChanged.Remove(DoOnVarChanged);
  end;
  if FVariable <> AVariable then
  begin
    FVariable := AVariable;
    if Assigned(FVariable) then
      FVariable.OnValueChanged.Add(DoOnVarChanged);
  end;
end;

{ TdpnAccion_Variable }

procedure TdpnAccion_Variable.CargarDeJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  DPNCore.CargarCampoDeNodo<string>(NodoJson_IN, 'NombreVariable', ClassName, FNombreVariable);
end;

function TdpnAccion_Variable.CheckIsOK(out AListaErrores: IList<string>): boolean;
begin
  Result := inherited;
  if FNombreVariable.IsEmpty then
  begin
    Result := False;
    AListaErrores.Add('NombreVariable is Empty');
  end;
end;

constructor TdpnAccion_Variable.Create;
begin
  inherited;
  FNombreVariable := '';
end;

procedure TdpnAccion_Variable.FormatoJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  NodoJson_IN.AddPair('NombreVariable', TJSONString.Create(Variable.Nombre));
end;

function TdpnAccion_Variable.GetDependencias: IList<IBloqueable>;
begin
  Result := TCollections.CreateList<IBloqueable>;
  if Assigned(FVariable) then
    Result.Add(FVariable);
end;

function TdpnAccion_Variable.GetVariable: IVariable;
begin
  Result := FVariable;
end;

procedure TdpnAccion_Variable.Setup;
var
  LVariable: IVariable;
begin
  inherited;
  if not FNombreVariable.IsEmpty then
  begin
    LVariable := PetriNetController.GetVariable(FNombreVariable);
    if Assigned(LVariable) then
      FVariable := LVariable;
  end;
end;

procedure TdpnAccion_Variable.SetVariable(AVariable: IVariable);
begin
  if FVariable <> AVariable then
  begin
    FVariable := AVariable;
  end;
end;

end.
