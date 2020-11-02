unit DPN.Plaza.Super;

interface

uses
  Spring,
  Spring.Collections,

  DPN.Interfaces,
  DPN.Plaza;

type
  TdpnPlazaSuper = class (TdpnPlaza)
  protected
    FCapacidadAcumulada: Integer;
    FListaPlazas: IList<IPlaza>;

    function GetAceptaArcosIN: Boolean; override;

    function GetTokens: IReadOnlyList<IToken>; override;
    function GetTokenCount: Integer; override;

    function GetCapacidad: Integer; override;

  public
    constructor Create; override;

    procedure Start; override;

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
  end;

implementation

uses
  DPN.TokenSistema;

{ TdpnPlazaSuper }

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

constructor TdpnPlazaSuper.Create;
begin
  inherited;
  FListaPlazas := TCollections.CreateList<IPlaza>;
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

function TdpnPlazaSuper.GetAceptaArcosIN: Boolean;
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
