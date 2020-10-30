unit DPN.Core;

interface

uses
  System.SyncObjs,

  Spring,
  Spring.Collections,

  DPN.Interfaces;

type
  DPNCore = class
    private
      class var FID: integer;
      class var FTokenID: int64;
      class var FLock: TSpinLock;
      class var FTokenLock: TSpinLock;
    protected
      class constructor CreateC;
    public
      class function GetNuevoID: Integer; static;
      class function GetNuevoTokenID: Int64; static;
      class function CrearEvento<T>: IEvent<T>; static;
      class function GenerarNTokensSistema(const ACount: Integer): IList<IToken>; static;
      class function GenerarTokensAdecuados(AMarcado: IMarcadoTokens; const ACount: Integer): IList<IToken>; static;
  end;

implementation

uses
  System.SysUtils,

  DPN.MarcadoTokens;

{ DPN }

class function DPNCore.CrearEvento<T>: IEvent<T>;
var
  LEvento: Event<T>;
begin
  Result := LEvento;
end;

class constructor DPNCore.CreateC;
begin
  FID := 0;
  FTokenID := 0;
end;

class function DPNCore.GenerarNTokensSistema(const ACount: Integer): IList<IToken>;
var
  I: integer;
  LToken: ITokenSistema;
begin
  Result := TCollections.CreateList<IToken>;
  for I := 1 to ACount do
  begin
    //LToken := ...  DAVE
    Result.Add(LToken);
  end;
end;

class function DPNCore.GenerarTokensAdecuados(AMarcado: IMarcadoTokens; const ACount: Integer): IList<IToken>;
var
  I: integer;
  LTokenPlus: IToken;
  LToken: IToken;
  LPlaza: IPlaza;
  LEnum : IEnumerable<IToken>;
  LGeneradosCount: Integer;
begin
  Result := TCollections.CreateList<IToken>;
  if (ACount = 0) then Exit;

  LGeneradosCount := 0;
  for LPlaza in AMarcado.Marcado.Keys do
  begin
    LEnum := AMarcado.Marcado[LPlaza].Where(
                                             function (const AToken: IToken): Boolean
                                             begin
                                               Result := Supports(AToken, ITokenColoreado);
                                             end
                                           );
    if LEnum.Count > 0 then
    begin
      for I := 0 to ACount - 1 do
      begin
        if (I < LEnum.Count) then
        begin
          LToken := LEnum.ElementAt(I).Clon;
          Result.Add(LToken);
          Inc(LGeneradosCount);
        end
        else break;
      end;
      break;
    end;
  end;
  if (LGeneradosCount < ACount) then
  begin
    if (Result.Count > 0) then
    begin
      LTokenPlus := Result.ElementAt(0);
      for I := (LGeneradosCount - 1) to ACount - 1 do
      begin
        LToken := LTokenPlus.Clon;
        Result.Add(LToken);
      end;
    end
    else begin
           for I := 0 to ACount - 1 do
           begin
             //LToken := //DAVE...no queda otra que generar de sistema???
             Result.Add(LToken);
           end;
         end;
  end;
end;

class function DPNCore.GetNuevoID: Integer;
begin
  FLock.Enter;
  try
    Inc(FID);
    Result := FID;
  finally
    FLock.Exit;
  end;
end;

class function DPNCore.GetNuevoTokenID: Int64;
begin
  FTokenLock.Enter;
  try
    Inc(FTokenID);
    Result := FTokenID;
  finally
    FTokenLock.Exit;
  end;
end;

end.
