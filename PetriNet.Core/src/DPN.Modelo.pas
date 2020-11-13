unit DPN.Modelo;

interface

uses
  System.Rtti,
  System.JSON,

  Spring,
  Spring.Collections,

  DPN.Interfaces,
  DPN.NodoPetriNet;

type
  // El modelo crea a todos sus hijos en cascada
  TdpnModelo = class(TdpnNodoPetriNet, IModelo)
  protected
    FTipoModelo: string;
    FElementos: IList<INodoPetriNet>;

    FArcosIn: IList<IArcoIn>;
    FArcosOut: IList<IArcoOut>;

    FPlazaIn: IPlaza;
    FPlazaOut: IPlaza;

    FNombrePlazaIn: string;
    FNombrePlazaOut: string;

    function GetElementos: IList<INodoPetriNet>; virtual;

    function GetPlazaIn: IPlaza; virtual;
    procedure SetPlazaIn(Value: IPlaza); virtual;
    function GetPlazaOut: IPlaza; virtual;
    procedure SetPlazaOut(Value: IPlaza); virtual;

    function GetTipoModelo: string; virtual;
    procedure SetTipoModelo(const Valor: string); virtual;
  public
    constructor Create; override;

    Procedure CargarDeJSON(NodoJson_IN: TJSONObject); override;
    Procedure FormatoJSON(NodoJson_IN: TJSONObject); overload; override;

    procedure Start; override;
    procedure Stop; override;
    procedure Reset; override;
    procedure Setup; override;
    function CheckIsOK(out AListaErrores: IList<string>): boolean; override;

    procedure AddElementoNodo(AElemento: INodoPetriNet); virtual;
    procedure AddElementosNodos(AElementos: TArray<INodoPetriNet>); overload; virtual;
    procedure AddElementosNodos(AElementos: IList<INodoPetriNet>); overload; virtual;
    procedure ClearElementos; virtual;
    procedure EliminarElementoNodo(AElemento: INodoPetriNet); virtual;
    procedure EliminarElementosNodos(AElementos: TArray<INodoPetriNet>); overload; virtual;
    procedure EliminarElementosNodos(AElementos: IList<INodoPetriNet>); overload; virtual;

    function GetPlazas: IReadOnlyList<IPlaza>; virtual;
    function GetTransiciones: IReadOnlyList<ITransicion>; virtual;
    function GetModelos: IReadOnlyList<IModelo>; virtual;
    function GetArcos: IReadOnlyList<IArco>; virtual;
    function GetTokens: IReadOnlyList<IToken>; virtual;
    function GetVariables: IReadOnlyList<IVariable>; virtual;
    function GetCondiciones: IReadOnlyList<ICondicion>; virtual;
    function GetAcciones: IReadOnlyList<IAccion>; virtual;

    procedure AddArcoEntrada(AArco: IArcoOut); virtual;
    procedure EliminarArcoEntrada(AArco: IArcoOut); virtual;
    procedure AddArcoSalida(AArco: IArcoIn); virtual;
    procedure EliminarArcoSalida(AArco: IArcoIn); virtual;

    property PlazaIn: IPlaza read GetPlazaIn write SetPlazaIn;
    property PlazaOut: IPlaza read GetPlazaOut write SetPlazaOut;
    property Elementos: IList<INodoPetriNet> read GetElementos;
    property TipoModelo: string read GetTipoModelo write SetTipoModelo;
  end;

implementation

uses
  System.SysUtils,

  Event.Engine.Utils,
  DPN.Core;

{ TdpnModelo }

procedure TdpnModelo.AddArcoEntrada(AArco: IArcoOut);
begin
  Guard.CheckTrue(Assigned(FPlazaIN), 'La plaza IN debe estar asignada');
  AArco.Plaza := FPlazaIN;
end;

procedure TdpnModelo.AddArcoSalida(AArco: IArcoIn);
begin
  Guard.CheckTrue(Assigned(FPlazaOut), 'La plaza OUT debe estar asignada');
  AArco.Plaza := FPlazaOut;
end;

procedure TdpnModelo.AddElementoNodo(AElemento: INodoPetriNet);
begin
  AElemento.Modelo := Self;
  Elementos.Add(AElemento);
end;

procedure TdpnModelo.AddElementosNodos(AElementos: TArray<INodoPetriNet>);
var
  LNodo: INodoPetriNet;
begin
  for LNodo in AElementos do
    AddElementoNodo(LNodo);
end;

procedure TdpnModelo.AddElementosNodos(AElementos: IList<INodoPetriNet>);
var
  LNodo: INodoPetriNet;
begin
  for LNodo in AElementos do
    AddElementoNodo(LNodo);
end;

procedure TdpnModelo.CargarDeJSON(NodoJson_IN: TJSONObject);
var
  LDatos: TJSONArray;
  LNodoJSon: TJSONObject;
  LNodo: INodoPetriNet;
  I: integer;
begin
  inherited;
  DPNCore.CargarCampoDeNodo<string>(NodoJson_IN, 'TipoModelo', ClassName, FTipoModelo);
  DPNCore.CargarCampoDeNodo<string>(NodoJson_IN, 'PlazaIn', ClassName, FNombrePlazaIn);
  DPNCore.CargarCampoDeNodo<string>(NodoJson_IN, 'PlazaOut', ClassName, FNombrePlazaOut);
  if NodoJson_IN.TryGetValue<TJSONArray>('Elementos', LDatos) then
  begin
    for I := 0 to LDatos.Count - 1 do
    begin
      LNodoJSon := LDatos.Items[I] as TJSONObject;
      LNodo := DPNCore.CrearInstancia<INodoPetriNet>(LNodoJSon);
      LNodo.CargarDeJSON(LNodoJSon);
      AddElementoNodo(LNodo);
    end;
  end;
end;

function TdpnModelo.CheckIsOK(out AListaErrores: IList<string>): boolean;
begin
  Result := inherited;
  if TipoModelo.IsEmpty then
  begin
    Result := False;
    AListaErrores.Add('TipoModelo is Empty');
  end;
end;

procedure TdpnModelo.ClearElementos;
var
  LNodo: INodoPetriNet;
begin
  for LNodo in Elementos do
    EliminarElementoNodo(LNodo);
end;

constructor TdpnModelo.Create;
begin
  inherited;
  FElementos := TCollections.CreateList<INodoPetriNet>;

  FPlazaIn := nil;
  FPlazaOut := nil;
end;

procedure TdpnModelo.EliminarArcoEntrada(AArco: IArcoOut);
begin
  AArco.Plaza := nil;
end;

procedure TdpnModelo.EliminarArcoSalida(AArco: IArcoIn);
begin
  AArco.Plaza := nil;
end;

procedure TdpnModelo.EliminarElementoNodo(AElemento: INodoPetriNet);
begin
  AElemento.Modelo := nil;
  Elementos.Remove(AElemento);
end;

procedure TdpnModelo.EliminarElementosNodos(AElementos: TArray<INodoPetriNet>);
var
  LNodo: INodoPetriNet;
begin
  for LNodo in AElementos do
    EliminarElementoNodo(LNodo);
end;

procedure TdpnModelo.EliminarElementosNodos(AElementos: IList<INodoPetriNet>);
begin
  EliminarElementosNodos(AElementos.ToArray);
end;

procedure TdpnModelo.FormatoJSON(NodoJson_IN: TJSONObject);
var
  LDatos: TJSONArray;
  I: integer;
  LNombre: string;
begin
  inherited;
  NodoJson_IN.AddPair('TipoModelo', TJsonString.Create(TipoModelo));
  LNombre := '';
  if Assigned(PlazaIn) then
    LNombre := PlazaIn.Nombre;
  NodoJson_IN.AddPair('PlazaIn', TJsonString.Create(LNombre));
  LNombre := '';
  if Assigned(PlazaOut) then
    LNombre := PlazaOut.Nombre;
  NodoJson_IN.AddPair('PlazaOut', TJsonString.Create(LNombre));
  LDatos := TJSONArray.Create;
  for I := 0 to Elementos.Count - 1 do
  begin
    LDatos.AddElement(Elementos[I].FormatoJSon);
  end;
  NodoJson_IN.AddPair('Elementos', LDatos);
end;

function TdpnModelo.GetAcciones: IReadOnlyList<IAccion>;
var
  LNodo: INodoPetriNet;
  LModelo: IModelo;
  LAccion: IAccion;
  LResult : IList<IAccion>;
begin
  LResult := TCollections.CreateList<IAccion>;
  for LNodo in FElementos do
  begin
    if Supports(LNodo, IAccion, LAccion) then
      LResult.Add(LAccion)
    else begin
           if Supports(LNodo, IModelo, LModelo) then
             LResult.AddRange(LModelo.GetAcciones.ToArray);
         end;
  end;
  Result := LResult.AsReadOnly;
end;

function TdpnModelo.GetArcos: IReadOnlyList<IArco>;
var
  LNodo: INodoPetriNet;
  LModelo: IModelo;
  LArco: IArco;
  LResult : IList<IArco>;
begin
  LResult := TCollections.CreateList<IArco>;
  for LNodo in FElementos do
  begin
    if Supports(LNodo, IArco, LArco) then
      LResult.Add(LArco)
    else begin
           if Supports(LNodo, IModelo, LModelo) then
             LResult.AddRange(LModelo.GetArcos.ToArray);
         end;
  end;
  Result := LResult.AsReadOnly;
end;

function TdpnModelo.GetCondiciones: IReadOnlyList<ICondicion>;
var
  LNodo: INodoPetriNet;
  LModelo: IModelo;
  LCondicion: ICondicion;
  LResult : IList<ICondicion>;
begin
  LResult := TCollections.CreateList<ICondicion>;
  for LNodo in FElementos do
  begin
    if Supports(LNodo, ICondicion, LCondicion) then
      LResult.Add(LCondicion)
    else begin
           if Supports(LNodo, IModelo, LModelo) then
             LResult.AddRange(LModelo.GetCondiciones.ToArray);
         end;
  end;
  Result := LResult.AsReadOnly;
end;

function TdpnModelo.GetElementos: IList<INodoPetriNet>;
begin
  Result := FElementos
end;

function TdpnModelo.GetModelos: IReadOnlyList<IModelo>;
var
  LNodo: INodoPetriNet;
  LModelo: IModelo;
  LResult : IList<IModelo>;
begin
  LResult := TCollections.CreateList<IModelo>;
  for LNodo in FElementos do
  begin
    if Supports(LNodo, IModelo, LModelo) then
    begin
      LResult.Add(LModelo);
      LResult.AddRange(LModelo.GetModelos);
    end
  end;
  Result := LResult.AsReadOnly;
end;

function TdpnModelo.GetPlazaIn: IPlaza;
begin
  Result := FPlazaIn;
end;

function TdpnModelo.GetPlazaOut: IPlaza;
begin
  Result := FPlazaOut;
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

function TdpnModelo.GetTokens: IReadOnlyList<IToken>;
var
  LNodo: INodoPetriNet;
  LModelo: IModelo;
  LPlaza: IPlaza;
  LResult : IList<IToken>;
begin
  LResult := TCollections.CreateList<IToken>;
  for LNodo in FElementos do
  begin
    if Supports(LNodo, IPlaza, LPlaza) then
      LResult.AddRange(LPlaza.Tokens.ToArray)
    else begin
           if Supports(LNodo, IModelo, LModelo) then
             LResult.AddRange(LModelo.GetTokens.ToArray);
         end;
  end;
  Result := LResult.AsReadOnly;
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

function TdpnModelo.GetVariables: IReadOnlyList<IVariable>;
var
  LNodo: INodoPetriNet;
  LModelo: IModelo;
  LVariable: IVariable;
  LResult : IList<IVariable>;
begin
  LResult := TCollections.CreateList<IVariable>;
  for LNodo in FElementos do
  begin
    if Supports(LNodo, IVariable, LVariable) then
      LResult.Add(LVariable)
    else begin
           if Supports(LNodo, IModelo, LModelo) then
             LResult.AddRange(LModelo.GetVariables.ToArray);
         end;
  end;
  Result := LResult.AsReadOnly;
end;

procedure TdpnModelo.Reset;
var
  LNodo: INodoPetriNet;
begin
  inherited;
  for LNodo in FElementos do
  begin
    LNodo.Reset;
  end;
end;

procedure TdpnModelo.SetPlazaIn(Value: IPlaza);
var
  LRes: boolean;
begin
  FPlazaIN := Value;
  if Assigned(FPlazaIN) then
  begin
    LRes := GetPlazas.Any(function (const APlaza: IPlaza): boolean
                          begin
                            Result := (APlaza.ID = Value.ID);
                          end
                         );
    Guard.CheckTrue(LRes, 'La plaza IN debe existir en el modelo')
  end;
end;

procedure TdpnModelo.SetPlazaOut(Value: IPlaza);
var
  LRes: boolean;
begin
  FPlazaOut := Value;
  if Assigned(FPlazaOut) then
  begin
    LRes := GetPlazas.Any(function (const APlaza: IPlaza): boolean
                          begin
                            Result := (APlaza.ID = Value.ID);
                          end
                         );
    Guard.CheckTrue(LRes, 'La plaza OUT debe existir en el modelo')
  end;
end;

procedure TdpnModelo.SetTipoModelo(const Valor: string);
begin
  Guard.CheckFalse(Valor.IsEmpty, 'El TipoModelo no puede ser nulo');
  if FTipoModelo <> Valor then
  begin
    FTipoModelo := Valor;
  end;
end;

procedure TdpnModelo.Setup;
var
  LPlazaIn, LPlazaOut: IPlaza;
begin
  inherited;
  if not FNombrePlazaIn.IsEmpty then
  begin
    LPlazaIn := PetriNetController.GetPlaza(FNombrePlazaIn);
    if Assigned(LPlazaIn) then
      PlazaIn := LPlazaIn;
  end;
  if not FNombrePlazaOut.IsEmpty then
  begin
    LPlazaOut := PetriNetController.GetPlaza(FNombrePlazaOut);
    if Assigned(LPlazaOut) then
      PlazaOut := LPlazaOut;
  end;
end;

procedure TdpnModelo.Start;
var
  LNodo: INodoPetriNet;
begin
  inherited;
  for LNodo in FElementos do
  begin
    Utils.IdeDebugMsg(LNodo.Nombre);
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
