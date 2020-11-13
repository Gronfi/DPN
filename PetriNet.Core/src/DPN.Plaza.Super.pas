unit DPN.Plaza.Super;

interface

uses
  System.JSON,

  Spring,
  Spring.Collections,

  DPN.Interfaces,
  DPN.Plaza;

type
  TdpnPlazaSuper = class (TdpnPlaza)
  protected
    FCapacidadAcumulada: Integer;
    FListaPlazas: IList<IPlaza>;
    FNombresListaPlazas: IList<string>;

    function GetAceptaArcosOUT: Boolean; override;

    function GetTokens: IReadOnlyList<IToken>; override;
    function GetTokenCount: Integer; override;

    procedure DoOnTokenCountChanged(const AID: integer; const ACount: Integer); virtual;

    function GetCapacidad: Integer; override;

  public
    constructor Create; override;

    Procedure CargarDeJSON(NodoJson_IN: TJSONObject); override;
    Procedure FormatoJSON(NodoJson_IN: TJSONObject); overload; override;

    procedure Start; override;
    procedure Setup; override;
    function CheckIsOK(out AListaErrores: IList<string>): boolean; override;

    procedure AddPlaza(APlaza: IPlaza); virtual;
    procedure RemovePlaza(APlaza: IPlaza); virtual;

    procedure AddToken(AToken: IToken); override;
    procedure AddTokens(ATokens: TListaTokens); overload; override;
    procedure AddTokens(ATokens: TArrayTokens); overload; override;

    procedure EliminarToken(AToken: IToken); override;
    procedure EliminarTokens(ATokens: TListaTokens); overload; override;
    procedure EliminarTokens(ATokens: TArrayTokens); overload; override;
    procedure EliminarTokens(const ACount: integer); overload; override;
    procedure EliminarTodosTokens; override;

    procedure AddPreCondicion(ACondicion: ICondicion); override;
    procedure AddPreCondiciones(ACondiciones: TCondiciones); overload; override;
    procedure AddPreCondiciones(ACondiciones: TArrayCondiciones); overload; override;
    procedure EliminarPreCondicion(ACondicion: ICondicion); override;
    procedure EliminarPreCondiciones(ACondiciones: TCondiciones); overload; override;
    procedure EliminarPreCondiciones(ACondiciones: TArrayCondiciones); overload; override;

    property ListaPlazasContenidas: IList<IPlaza> read FListaPlazas;
  end;

implementation

uses
  DPN.Core,
  DPN.TokenSistema;

{ TdpnPlazaSuper }

procedure TdpnPlazaSuper.AddPlaza(APlaza: IPlaza);
begin
  if not FListaPlazas.Contains(APlaza) then
  begin
    FListaPlazas.Add(APlaza);
    APlaza.OnTokenCountChanged.Add(DoOnTokenCountChanged);
  end;
end;

procedure TdpnPlazaSuper.AddPreCondicion(ACondicion: ICondicion);
begin
  ;
end;

procedure TdpnPlazaSuper.AddPreCondiciones(ACondiciones: TArrayCondiciones);
begin
  ;
end;

procedure TdpnPlazaSuper.AddPreCondiciones(ACondiciones: TCondiciones);
begin
  ;
end;

procedure TdpnPlazaSuper.AddToken(AToken: IToken);
begin
  ;
end;

procedure TdpnPlazaSuper.AddTokens(ATokens: TListaTokens);
begin
  ;
end;

procedure TdpnPlazaSuper.AddTokens(ATokens: TArrayTokens);
begin
  ;
end;

procedure TdpnPlazaSuper.CargarDeJSON(NodoJson_IN: TJSONObject);
var
  LDatos: TJSONArray;
  LNodoJSon: TJSONString;
  I: integer;
begin
  inherited;
  if NodoJson_IN.TryGetValue<TJSONArray>('Plazas', LDatos) then
  begin
    for I := 0 to LDatos.Count - 1 do
    begin
      LNodoJSon := LDatos.Items[I] as TJSONString;
      FNombresListaPlazas.Add(LNodoJSon.Value);
    end;
  end;
end;

function TdpnPlazaSuper.CheckIsOK(out AListaErrores: IList<string>): boolean;
begin
  Result := inherited;
  if FListaPlazas.Count = 0 then
  begin
    Result := False;
    AListaErrores.Add('No se han configurado plazas');
  end;
end;

constructor TdpnPlazaSuper.Create;
begin
  inherited;
  FListaPlazas := TCollections.CreateList<IPlaza>;
  FNombresListaPlazas := TCollections.CreateList<string>;
end;

procedure TdpnPlazaSuper.DoOnTokenCountChanged(const AID, ACount: Integer);
begin
  FEventoOnTokenCountChanged.Invoke(ID, TokenCount);
end;

procedure TdpnPlazaSuper.EliminarPreCondicion(ACondicion: ICondicion);
begin
  ;
end;

procedure TdpnPlazaSuper.EliminarPreCondiciones(ACondiciones: TCondiciones);
begin
  ;
end;

procedure TdpnPlazaSuper.EliminarPreCondiciones(ACondiciones: TArrayCondiciones);
begin
  ;
end;procedure TdpnPlazaSuper.EliminarTodosTokens;
begin
  inherited;

end;

procedure TdpnPlazaSuper.EliminarToken(AToken: IToken);
begin
  FListaPlazas.ForEach(
                         procedure (const APlaza: IPlaza)
                         begin
                           APlaza.EliminarToken(AToken);
                         end
                       );
  FEventoOnTokenCountChanged.Invoke(ID, TokenCount);
end;

procedure TdpnPlazaSuper.EliminarTokens(ATokens: TListaTokens);
begin
  FListaPlazas.ForEach(
                         procedure (const APlaza: IPlaza)
                         begin
                           APlaza.EliminarTokens(ATokens);
                         end
                       );
  FEventoOnTokenCountChanged.Invoke(ID, TokenCount);
end;

procedure TdpnPlazaSuper.EliminarTokens(ATokens: TArrayTokens);
begin
  FListaPlazas.ForEach(
                         procedure (const APlaza: IPlaza)
                         begin
                           APlaza.EliminarTokens(ATokens);
                         end
                       );
  FEventoOnTokenCountChanged.Invoke(ID, TokenCount);
end;

procedure TdpnPlazaSuper.EliminarTokens(const ACount: integer);
var
  LEliminar: integer;
begin
  LEliminar := ACount;
  FListaPlazas.ForEach(
                         procedure (const APlaza: IPlaza)
                         begin
                           if LEliminar > 0 then
                           begin
                             if APlaza.TokenCount > 0 then
                             begin
                               if LEliminar >= APlaza.TokenCount then
                               begin
                                 LEliminar := LEliminar - APlaza.TokenCount;
                                 APlaza.EliminarTodosTokens;
                               end
                               else begin
                                      if LEliminar > 0 then
                                      begin
                                        APlaza.EliminarTokens(LEliminar);
                                        LEliminar := 0;
                                      end;
                                    end;
                             end;
                           end;
                         end
                       );
  FEventoOnTokenCountChanged.Invoke(ID, TokenCount);
end;

procedure TdpnPlazaSuper.FormatoJSON(NodoJson_IN: TJSONObject);
var
  LDatos: TJSONArray;
  LNombre: string;
begin
  inherited;
  LDatos := TJSONArray.Create;
  for LNombre in FNombresListaPlazas do
  begin
    LDatos.AddElement(TJSonString.Create(LNombre));
  end;
  NodoJson_IN.AddPair('Plazas', LDatos);
end;

function TdpnPlazaSuper.GetAceptaArcosOUT: Boolean;
begin
  Result := False;
end;

function TdpnPlazaSuper.GetCapacidad: Integer;
begin
  Result := FCapacidadAcumulada;
end;

function TdpnPlazaSuper.GetTokenCount: Integer;
var
  LCnt : integer;
begin
  LCnt := 0;
  FListaPlazas.ForEach(
                         procedure (const APlaza: IPlaza)
                         begin
                           Inc(LCnt, APlaza.TokenCount);
                         end
                       );
  Result := LCnt;
end;

function TdpnPlazaSuper.GetTokens: IReadOnlyList<IToken>;
begin
  FTokens.Clear;
  FListaPlazas.ForEach(
                         procedure (const APlaza: IPlaza)
                         begin
                           FTokens.AddRange(APlaza.Tokens.ToArray);
                         end
                       );
  Result := FTokens.AsReadOnly
end;

procedure TdpnPlazaSuper.RemovePlaza(APlaza: IPlaza);
begin
  if FListaPlazas.Contains(APlaza) then
    FListaPlazas.Remove(APlaza);
end;

procedure TdpnPlazaSuper.Setup;
var
  LPlaza: IPlaza;
  LNombre: string;
begin
  inherited;
  for LNombre in FNombresListaPlazas do
  begin
    LPlaza := PetriNetController.GetPlaza(LNombre);
    AddPlaza(LPlaza);
  end;
end;

procedure TdpnPlazaSuper.Start;
begin
  FCapacidadAcumulada := 0;
  FListaPlazas.ForEach(
                         procedure (const APlaza: IPlaza)
                         begin
                           Inc(FCapacidadAcumulada, APlaza.Capacidad);
                         end
                       );
  inherited;

end;

end.
