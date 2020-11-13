unit DPN.Plaza;

interface

uses
  System.JSON,

  Spring,
  Spring.Collections,

  DPN.Interfaces,
  DPN.Bloqueable;

type
  TdpnPlaza = class (TdpnBloqueable, IPlaza)
  protected
    FTokens: IList<IToken>;
    FPreCondiciones: IList<ICondicion>;
    FPreAcciones: IList<IAccion>;
    FPostCondiciones: IList<ICondicion>;
    FPostAcciones: IList<IAccion>;

    FNombresPreCondiciones: IList<string>;
    FNombresPreAcciones: IList<string>;
    FNombresPostCondiciones: IList<string>;
    FNombresPostAcciones: IList<string>;

    FCapacidad: Integer;
    FEventoOnTokenCountChanged: IEvent<EventoNodoPN_ValorInteger>;

    function GetOnTokenCountChanged: IEvent<EventoNodoPN_ValorInteger>;

    function GetAceptaArcosIN: Boolean; virtual;
    function GetAceptaArcosOUT: Boolean; virtual;

    function GetTokens: IReadOnlyList<IToken>; virtual;
    function GetTokenCount: Integer; virtual;

    function GetCapacidad: Integer; virtual;
    procedure SetCapacidad(const Value: integer); virtual;
  public
    constructor Create; override;

    Procedure CargarDeJSON(NodoJson_IN: TJSONObject); override;
    Procedure FormatoJSON(NodoJson_IN: TJSONObject); overload; override;

    function GetPreCondiciones: IList<ICondicion>; virtual;
    function GetPreAcciones: IList<IAccion>; virtual;
    function GetPostCondiciones: IList<ICondicion>; virtual;
    function GetPostAcciones: IList<IAccion>; virtual;

    procedure Reset; override;
    procedure Start; override;
    procedure Setup; override;
    function CheckIsOK(out AListaErrores: IList<string>): boolean; override;

    function LogAsString: string; override;

    procedure AddToken(AToken: IToken); virtual;
    procedure AddTokens(ATokens: TListaTokens); overload; virtual;
    procedure AddTokens(ATokens: TArrayTokens); overload; virtual;

    procedure EliminarToken(AToken: IToken); virtual;
    procedure EliminarTokens(ATokens: TListaTokens); overload; virtual;
    procedure EliminarTokens(ATokens: TArrayTokens); overload; virtual;
    procedure EliminarTokens(const ACount: integer); overload; virtual;
    procedure EliminarTodosTokens; virtual;

    procedure AddPreCondicion(ACondicion: ICondicion); virtual;
    procedure AddPreCondiciones(ACondiciones: TCondiciones); overload; virtual;
    procedure AddPreCondiciones(ACondiciones: TArrayCondiciones); overload; virtual;
    procedure EliminarPreCondicion(ACondicion: ICondicion); virtual;
    procedure EliminarPreCondiciones(ACondiciones: TCondiciones); overload; virtual;
    procedure EliminarPreCondiciones(ACondiciones: TArrayCondiciones); overload; virtual;

    procedure AddPreAccion(AAccion: IAccion); virtual;
    procedure AddPreAcciones(AAcciones: TAcciones); overload; virtual;
    procedure AddPreAcciones(AAcciones: TArrayAcciones); overload; virtual;
    procedure EliminarPreAccion(AAccion: IAccion); virtual;
    procedure EliminarPreAcciones(AAcciones: TAcciones); overload; virtual;
    procedure EliminarPreAcciones(AAcciones: TArrayAcciones); overload; virtual;

    procedure AddPostCondicion(ACondicion: ICondicion); virtual;
    procedure AddPostCondiciones(ACondiciones: TCondiciones); overload; virtual;
    procedure AddPostCondiciones(ACondiciones: TArrayCondiciones); overload; virtual;
    procedure EliminarPostCondicion(ACondicion: ICondicion); virtual;
    procedure EliminarPostCondiciones(ACondiciones: TCondiciones); overload; virtual;
    procedure EliminarPostCondiciones(ACondiciones: TArrayCondiciones); overload; virtual;

    procedure AddPostAccion(AAccion: IAccion); virtual;
    procedure AddPostAcciones(AAcciones: TAcciones); overload; virtual;
    procedure AddPostAcciones(AAcciones: TArrayAcciones); overload; virtual;
    procedure EliminarPostAccion(AAccion: IAccion); virtual;
    procedure EliminarPostAcciones(AAcciones: TAcciones); overload; virtual;
    procedure EliminarPostAcciones(AAcciones: TArrayAcciones); overload; virtual;

    property AceptaArcosIN: boolean read GetAceptaArcosIN;
    property AceptaArcosOUT: boolean read GetAceptaArcosIN;
    property Tokens: IReadOnlyList<IToken> read GetTokens;
    property TokenCount: Integer read GetTokenCount;
    property Capacidad: Integer read GetCapacidad write SetCapacidad;
    property PreCondiciones: IList<ICondicion> read GetPreCondiciones;
    property PreAcciones: IList<IAccion> read GetPreAcciones;
    property PostCondiciones: IList<ICondicion> read GetPostCondiciones;
    property PostAcciones: IList<IAccion> read GetPostAcciones;

    property OnTokenCountChanged: IEvent<EventoNodoPN_ValorInteger> read GetOnTokenCountChanged;
  end;


implementation

uses
  System.SysUtils,

  Event.Engine.Utils,
  DPN.Core;

{ TdpnPlaza }

procedure TdpnPlaza.AddPostAccion(AAccion: IAccion);
begin
  FPostAcciones.Add(AAccion);
end;

procedure TdpnPlaza.AddPostAcciones(AAcciones: TArrayAcciones);
begin
  FPostAcciones.AddRange(AAcciones)
end;

procedure TdpnPlaza.AddPostAcciones(AAcciones: TAcciones);
begin
  AddPostAcciones(AAcciones.ToArray)
end;

procedure TdpnPlaza.AddPostCondicion(ACondicion: ICondicion);
begin
  FPostCondiciones.Add(ACondicion)
end;

procedure TdpnPlaza.AddPostCondiciones(ACondiciones: TCondiciones);
begin
  AddPostCondiciones(ACondiciones.ToArray)
end;

procedure TdpnPlaza.AddPostCondiciones(ACondiciones: TArrayCondiciones);
begin
  FPostCondiciones.AddRange(ACondiciones)
end;

procedure TdpnPlaza.AddPreAccion(AAccion: IAccion);
begin
  FPreAcciones.Add(AAccion);
end;

procedure TdpnPlaza.AddPreAcciones(AAcciones: TArrayAcciones);
begin
  FPreAcciones.AddRange(AAcciones)
end;

procedure TdpnPlaza.AddPreAcciones(AAcciones: TAcciones);
begin
  FPreAcciones.AddRange(AAcciones.ToArray)
end;

procedure TdpnPlaza.AddPreCondicion(ACondicion: ICondicion);
begin
  FPreCondiciones.Add(ACondicion);
end;

procedure TdpnPlaza.AddPreCondiciones(ACondiciones: TArrayCondiciones);
begin
  FPreCondiciones.AddRange(ACondiciones)
end;

procedure TdpnPlaza.AddPreCondiciones(ACondiciones: TCondiciones);
begin
  AddPreCondiciones(ACondiciones.ToArray)
end;

procedure TdpnPlaza.AddToken(AToken: IToken);
begin
  FTokens.Add(AToken);
  AToken.Plaza := Self;
  FEventoOnTokenCountChanged.Invoke(ID, TokenCount);
end;

procedure TdpnPlaza.AddTokens(ATokens: TArrayTokens);
var
  I: Integer;
begin
  FTokens.AddRange(ATokens);
  for I := Low(ATokens) to High(ATokens) do
    ATokens[I].Plaza := Self;
  FEventoOnTokenCountChanged.Invoke(ID, TokenCount);
end;

procedure TdpnPlaza.AddTokens(ATokens: TListaTokens);
begin
  FTokens.AddRange(ATokens.ToArray);
  FEventoOnTokenCountChanged.Invoke(ID, TokenCount);
end;

procedure TdpnPlaza.CargarDeJSON(NodoJson_IN: TJSONObject);
var
  LDatos: TJSONArray;
  LNodoJSon: TJSONString;
  LCondicion: ICondicion;
  LAccion: IAccion;
  LNombre: string;
  I: integer;
begin
  inherited;
  DPNCore.CargarCampoDeNodo<Integer>(NodoJson_IN, 'Capacidad', ClassName, FCapacidad);
  if NodoJson_IN.TryGetValue<TJSONArray>('PreCondiciones', LDatos) then
  begin
    for I := 0 to LDatos.Count - 1 do
    begin
      LNodoJSon := LDatos.Items[I] as TJSONString;
      FNombresPreCondiciones.Add(LNodoJSon.Value);
    end;
  end;
  if NodoJson_IN.TryGetValue<TJSONArray>('PreAcciones', LDatos) then
  begin
    for I := 0 to LDatos.Count - 1 do
    begin
      LNodoJSon := LDatos.Items[I] as TJSONString;
      FNombresPreAcciones.Add(LNodoJSon.Value);
    end;
  end;

  if NodoJson_IN.TryGetValue<TJSONArray>('PostCondiciones', LDatos) then
  begin
    for I := 0 to LDatos.Count - 1 do
    begin
      LNodoJSon := LDatos.Items[I] as TJSONString;
      FNombresPostCondiciones.Add(LNodoJSon.Value);
    end;
  end;
  if NodoJson_IN.TryGetValue<TJSONArray>('PostAcciones', LDatos) then
  begin
    for I := 0 to LDatos.Count - 1 do
    begin
      LNodoJSon := LDatos.Items[I] as TJSONString;
      FNombresPostAcciones.Add(LNodoJSon.Value);
    end;
  end;
end;

function TdpnPlaza.CheckIsOK(out AListaErrores: IList<string>): boolean;
begin
  Result := inherited;
  if FCapacidad = 0 then
  begin
    Result := False;
    AListaErrores.Add('Capacidad = 0');
  end;
end;

constructor TdpnPlaza.Create;
begin
  inherited;
  FCapacidad      := 0;
  FTokens         := TCollections.CreateList<IToken>;
  FPreCondiciones := TCollections.CreateList<ICondicion>;
  FPreAcciones    := TCollections.CreateList<IAccion>;
  FPostCondiciones:= TCollections.CreateList<ICondicion>;
  FPostAcciones   := TCollections.CreateList<IAccion>;

  FNombresPreCondiciones := TCollections.CreateList<string>;
  FNombresPreAcciones := TCollections.CreateList<string>;
  FNombresPostCondiciones := TCollections.CreateList<string>;
  FNombresPostAcciones := TCollections.CreateList<string>;

  FEventoOnTokenCountChanged := DPNCore.CrearEvento<EventoNodoPN_ValorInteger>;
end;

procedure TdpnPlaza.EliminarPostAccion(AAccion: IAccion);
begin
  FPostAcciones.Remove(AAccion)
end;

procedure TdpnPlaza.EliminarPostAcciones(AAcciones: TAcciones);
begin
  EliminarPostAcciones(AAcciones.ToArray)
end;

procedure TdpnPlaza.EliminarPostAcciones(AAcciones: TArrayAcciones);
begin
  FPostAcciones.RemoveRange(AAcciones)
end;

procedure TdpnPlaza.EliminarPostCondicion(ACondicion: ICondicion);
begin
  FPostCondiciones.Remove(ACondicion);
end;

procedure TdpnPlaza.EliminarPostCondiciones(ACondiciones: TArrayCondiciones);
begin
  FPostCondiciones.RemoveRange(ACondiciones)
end;

procedure TdpnPlaza.EliminarPostCondiciones(ACondiciones: TCondiciones);
begin
  EliminarPostCondiciones(ACondiciones.ToArray)
end;

procedure TdpnPlaza.EliminarPreAccion(AAccion: IAccion);
begin
  FPreAcciones.Remove(AAccion)
end;

procedure TdpnPlaza.EliminarPreAcciones(AAcciones: TArrayAcciones);
begin
  FPreAcciones.RemoveRange(AAcciones)
end;

procedure TdpnPlaza.EliminarPreAcciones(AAcciones: TAcciones);
begin
  EliminarPreAcciones(AAcciones.ToArray)
end;

procedure TdpnPlaza.EliminarPreCondicion(ACondicion: ICondicion);
begin
  FPreCondiciones.Remove(ACondicion);
end;

procedure TdpnPlaza.EliminarPreCondiciones(ACondiciones: TCondiciones);
begin
  EliminarPreCondiciones(ACondiciones.ToArray)
end;

procedure TdpnPlaza.EliminarPreCondiciones(ACondiciones: TArrayCondiciones);
begin
  FPreCondiciones.RemoveRange(ACondiciones)
end;

procedure TdpnPlaza.EliminarTodosTokens;
begin
  FTokens.Clear;
  FEventoOnTokenCountChanged.Invoke(ID, TokenCount);
end;

procedure TdpnPlaza.EliminarToken(AToken: IToken);
begin
  FTokens.Remove(AToken);
  FEventoOnTokenCountChanged.Invoke(ID, TokenCount);
end;

procedure TdpnPlaza.EliminarTokens(ATokens: TListaTokens);
begin
  FTokens.RemoveRange(ATokens.ToArray);
  FEventoOnTokenCountChanged.Invoke(ID, TokenCount);
end;

procedure TdpnPlaza.EliminarTokens(ATokens: TArrayTokens);
begin
  FTokens.RemoveRange(ATokens);
  FEventoOnTokenCountChanged.Invoke(ID, TokenCount);
end;

procedure TdpnPlaza.EliminarTokens(const ACount: integer);
begin
  FTokens.DeleteRange(0, ACount);
  FEventoOnTokenCountChanged.Invoke(ID, TokenCount);
end;

procedure TdpnPlaza.FormatoJSON(NodoJson_IN: TJSONObject);
var
  LDatos: TJSONArray;
  LCondicion: ICondicion;
  LAccion: IAccion;
begin
  inherited;
  NodoJson_IN.AddPair('Capacidad', TJSONNumber.Create(Capacidad));
  LDatos := TJSONArray.Create;
  for LCondicion in FPreCondiciones do
  begin
    LDatos.AddElement(TJSonString.Create(LCondicion.Nombre));
  end;
  NodoJson_IN.AddPair('PreCondiciones', LDatos);
  LDatos := TJSONArray.Create;
  for LAccion in FPreAcciones do
  begin
    LDatos.AddElement(TJSonString.Create(LAccion.Nombre));
  end;
  NodoJson_IN.AddPair('PreAcciones', LDatos);
  LDatos := TJSONArray.Create;
  for LCondicion in FPostCondiciones do
  begin
    LDatos.AddElement(TJSonString.Create(LCondicion.Nombre));
  end;
  NodoJson_IN.AddPair('PostCondiciones', LDatos);
  LDatos := TJSONArray.Create;
  for LAccion in FPostAcciones do
  begin
    LDatos.AddElement(TJSonString.Create(LAccion.Nombre));
  end;
  NodoJson_IN.AddPair('PostAcciones', LDatos);
end;

function TdpnPlaza.GetAceptaArcosIN: Boolean;
begin
  Result := True;
end;

function TdpnPlaza.GetAceptaArcosOUT: Boolean;
begin
  Result := True;
end;

function TdpnPlaza.GetCapacidad: Integer;
begin
  Result := FCapacidad
end;

function TdpnPlaza.GetOnTokenCountChanged: IEvent<EventoNodoPN_ValorInteger>;
begin
  Result := FEventoOnTokenCountChanged
end;

function TdpnPlaza.GetPostAcciones: IList<IAccion>;
begin
  Result := FPostAcciones
end;

function TdpnPlaza.GetPostCondiciones: IList<ICondicion>;
begin
  Result := FPostCondiciones
end;

function TdpnPlaza.GetPreAcciones: IList<IAccion>;
begin
  Result := FPreAcciones
end;

function TdpnPlaza.GetPreCondiciones: IList<ICondicion>;
begin
  Result := FPreCondiciones
end;

function TdpnPlaza.GetTokenCount: Integer;
begin
  if not Enabled then
    Result := 0
  else Result := FTokens.Count
end;

function TdpnPlaza.GetTokens: IReadOnlyList<IToken>;
begin
  Result := FTokens.AsReadOnly
end;

function TdpnPlaza.LogAsString: string;
begin
  Result := inherited + '<' + ClassName + '>' + '[Capacidad]' + Capacidad.ToString + '[TokenCount]' + TokenCount.ToString;
end;

procedure TdpnPlaza.Reset;
begin
  FTokens.Clear;
  FEventoOnTokenCountChanged.Invoke(ID, TokenCount);
end;

procedure TdpnPlaza.SetCapacidad(const Value: integer);
begin
  Guard.CheckTrue(Value > 0, 'La capacidad debe ser > 0');
  FCapacidad := Value;
  FEventoOnTokenCountChanged.Invoke(ID, TokenCount);
end;

procedure TdpnPlaza.Setup;
var
  LNombre: string;
  LCondicion: ICondicion;
  LAccion: IAccion;
begin
  inherited;
  for LNombre in FNombresPreCondiciones do
  begin
    LCondicion := PetriNetController.GetCondicion(LNombre);
    AddPreCondicion(LCondicion);
  end;
  for LNombre in FNombresPreAcciones do
  begin
    LAccion := PetriNetController.GetAccion(LNombre);
    AddPreAccion(LAccion);
  end;

  for LNombre in FNombresPostCondiciones do
  begin
    LCondicion := PetriNetController.GetCondicion(LNombre);
    AddPostCondicion(LCondicion);
  end;
  for LNombre in FNombresPostAcciones do
  begin
    LAccion := PetriNetController.GetAccion(LNombre);
    AddPostAccion(LAccion);
  end;
end;

procedure TdpnPlaza.Start;
begin
  inherited;
  FEventoOnTokenCountChanged.Invoke(ID, TokenCount);
end;

end.
