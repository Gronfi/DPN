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

  TdpnCondicion_DosVariables = class abstract(TdpnCondicion)
  protected
    FVariable1: IVariable;
    FNombreVariable1: string;
    FVariable2: IVariable;
    FNombreVariable2: string;

    function GetDependencias: IList<IBloqueable>; override;

    function GetVariable1: IVariable;
    procedure SetVariable1(AVariable: IVariable);
    function GetVariable2: IVariable;
    procedure SetVariable2(AVariable: IVariable);

    procedure DoOnVarChanged(const AID: Integer; const AValue: TValue);
  public
    constructor Create; override;

    Procedure CargarDeJSON(NodoJson_IN: TJSONObject); override;
    Procedure FormatoJSON(NodoJson_IN: TJSONObject); overload; override;

    procedure Setup; override;
    function CheckIsOK(out AListaErrores: IList<string>): boolean; override;

    property Variable1: IVariable read GetVariable1 write SetVariable1;
    property Variable2: IVariable read GetVariable2 write SetVariable2;
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

{ TdpnCondicion_DosVariables }

procedure TdpnCondicion_DosVariables.CargarDeJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  DPNCore.CargarCampoDeNodo<string>(NodoJson_IN, 'NombreVariable1', ClassName, FNombreVariable1);
  DPNCore.CargarCampoDeNodo<string>(NodoJson_IN, 'NombreVariable2', ClassName, FNombreVariable2);
end;

function TdpnCondicion_DosVariables.CheckIsOK(out AListaErrores: IList<string>): boolean;
begin
  Result := inherited;
  if FNombreVariable1.IsEmpty then
  begin
    Result := False;
    AListaErrores.Add('NombreVariable1 is Empty');
  end;
  if FNombreVariable2.IsEmpty then
  begin
    Result := False;
    AListaErrores.Add('NombreVariable2 is Empty');
  end;
end;

constructor TdpnCondicion_DosVariables.Create;
begin
  inherited;
  FNombreVariable1 := '';
  FNombreVariable2 := '';
end;

procedure TdpnCondicion_DosVariables.DoOnVarChanged(const AID: Integer; const AValue: TValue);
begin
  OnContextoCondicionChanged.Invoke(ID);
end;

procedure TdpnCondicion_DosVariables.FormatoJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  NodoJson_IN.AddPair('NombreVariable1', TJSONString.Create(Variable1.Nombre));
  NodoJson_IN.AddPair('NombreVariable2', TJSONString.Create(Variable2.Nombre));
end;

function TdpnCondicion_DosVariables.GetDependencias: IList<IBloqueable>;
begin
  Result := TCollections.CreateList<IBloqueable>;
  if Assigned(FVariable1) then
    Result.Add(FVariable1);
  if Assigned(FVariable2) then
    Result.Add(FVariable2);
end;

function TdpnCondicion_DosVariables.GetVariable1: IVariable;
begin
  Result := FVariable1;
end;

function TdpnCondicion_DosVariables.GetVariable2: IVariable;
begin
  Result := FVariable2;
end;

procedure TdpnCondicion_DosVariables.Setup;
var
  LVariable: IVariable;
begin
  inherited;
  if not FNombreVariable1.IsEmpty then
  begin
    LVariable := PetriNetController.GetVariable(FNombreVariable1);
    if Assigned(LVariable) then
      FVariable1 := LVariable;
  end;
  if not FNombreVariable2.IsEmpty then
  begin
    LVariable := PetriNetController.GetVariable(FNombreVariable2);
    if Assigned(LVariable) then
      FVariable2 := LVariable;
  end;
end;

procedure TdpnCondicion_DosVariables.SetVariable1(AVariable: IVariable);
begin
  if Assigned(FVariable1) then
  begin
    FVariable1.OnValueChanged.Remove(DoOnVarChanged);
  end;
  if FVariable1 <> AVariable then
  begin
    FVariable1 := AVariable;
    if Assigned(FVariable1) then
      FVariable1.OnValueChanged.Add(DoOnVarChanged);
  end;
end;

procedure TdpnCondicion_DosVariables.SetVariable2(AVariable: IVariable);
begin
  if Assigned(FVariable2) then
  begin
    FVariable2.OnValueChanged.Remove(DoOnVarChanged);
  end;
  if FVariable2 <> AVariable then
  begin
    FVariable2 := AVariable;
    if Assigned(FVariable2) then
      FVariable2.OnValueChanged.Add(DoOnVarChanged);
  end;
end;

end.
