unit DPN.Core;

interface

uses
  System.SyncObjs,
  System.JSON,

  Spring,
  Spring.Collections,

  DPN.Core.Scheduler,
  DPN.Interfaces;

type
  DPNCore = class
    const
      CHANNEL_SINGLE_THREADED = 'DPN.SingleThreaded';
      CHANNEL_MULTI_THREADED  = 'DPN.MultiThreaded';
      MAX_MULTITHREADING_POOL = 10;
    private
      class var FID: integer;
      class var FTokenID: int64;
      class var FPnID: integer;
      class var FLock: TSpinLock;
      class var FTokenLock: TSpinLock;
      class var FScheduler: TEventsScheduler;
    protected
      class constructor CreateC;
      class destructor DestroyC;
    public
      class function GetNuevoID: Integer; static;
      class function GetNuevoPnID: Integer; static;
      class function GetNuevoTokenID: Int64; static;
      class function CrearEvento<T>: IEvent<T>; static;
      class function GenerarNTokensSistema(const ACount: Integer): IList<IToken>; static;
      class function GenerarTokensAdecuados(AMarcado: IMarcadoTokens; const ACount: Integer): IList<IToken>; static;

      class function CrearInstancia(const typeInfo: PTypeInfo): TValue; overload; static;
      class function CrearInstancia(const NodoJSON: TJSonObject): TValue; overload; static;
      class function CrearInstancia(const ADescriptorCualificado: string): TValue; overload; static;

      class function CrearNodoJSONObjeto(Objeto: TObject): TJSONObject; static;
      class procedure CargarCampoDeNodo<T>(var AObjetoJSON: TJSONObject; const ACampo, AErrorMsg: string; var ADato: T); overload; static;
      class procedure CargarCampoDeNodo<T>(var AObjetoJSON: TJSONObject; const ACampo, AErrorMsg: string; var ADato: T; const ADefault: T); overload; static;

      class property TaskScheduler: TEventsScheduler read FScheduler;
  end;

implementation

uses
  System.RTTI,
  System.SysUtils,

  DPN.TokenColoreado,
  DPN.TokenSistema,
  Event.Engine,
  DPN.MarcadoTokens;

{ DPN }

class procedure DPNCore.CargarCampoDeNodo<T>(var AObjetoJSON: TJSONObject; const ACampo, AErrorMsg: string; var ADato: T; const ADefault: T);
var
  DatoTmp: T;
begin
  if not AObjetoJSON.TryGetValue<T>(ACampo, DatoTmp) then
  begin
    DatoTmp := ADefault;
  end;
  ADato := DatoTmp;
end;

class procedure DPNCore.CargarCampoDeNodo<T>(var AObjetoJSON: TJSONObject; const ACampo, AErrorMsg: string; var ADato: T);
var
  DatoTmp: T;
begin
  if not AObjetoJSON.TryGetValue<T>(ACampo, DatoTmp) then
    raise Exception.Create(AErrorMsg + ' - No se encuentra el campo: ' + ACampo);
  ADato := DatoTmp;
end;

class function DPNCore.CrearEvento<T>: IEvent<T>;
var
  LEvento: Event<T>;
begin
  Result := LEvento;
end;

class function DPNCore.CrearInstancia(const ADescriptorCualificado: string): TValue;
begin
  Result := TActivator.CreateInstance(ADescriptorCualificado);
end;

class function DPNCore.CrearInstancia(const typeInfo: PTypeInfo): TValue;
begin
  Result := CrearInstancia(typeInfo.TypeData.ClassType.QualifiedClassName);
end;

class function DPNCore.CrearInstancia(const NodoJSON: TJSonObject): TValue;
var
  LNombreCualificado: string;
begin
  // Se obtiene la informacion de la clase desde el nodo
  LNombreCualificado := NodoJSON.GetValue('Clase').Value;
  // Creamos la instacia.
  Result := CrearInstancia(LNombreCualificado);
end;

class function DPNCore.CrearNodoJSONObjeto(Objeto: TObject): TJSONObject;
var
  LNodo: TJSONObject;
  LType: TRttiType;
  LCtx : TRttiContext;
begin
  LNodo := TJSONObject.Create;
  LNodo.AddPair('Clase', TJSONString.Create(Objeto.QualifiedClassName));
  LCtx := TRttiContext.Create;
  LType := LCtx.GetType(Objeto.ClassInfo);
  LNodo.AddPair('Package', TJSONString.Create(ExtractFileName(LType.Package.Name)));
  Result := LNodo;
end;

class constructor DPNCore.CreateC;
begin
  FID := 0;
  FTokenID := 0;
  FPnID := 0;
  EventoBus.RegisterChannel(CHANNEL_SINGLE_THREADED, 1);
  EventoBus.RegisterChannel(CHANNEL_MULTI_THREADED, MAX_MULTITHREADING_POOL);
  FScheduler := TEventsScheduler.Create;
end;

class destructor DPNCore.DestroyC;
begin
  FScheduler.Destroy;
end;

class function DPNCore.GenerarNTokensSistema(const ACount: Integer): IList<IToken>;
var
  I: integer;
  LToken: ITokenSistema;
begin
  Result := TCollections.CreateList<IToken>;
  for I := 1 to ACount do
  begin
    LToken := TdpnTokenSistema.Create;
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
             LToken := TdpnTokenColoreado.Create;
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

class function DPNCore.GetNuevoPnID: Integer;
begin
  FLock.Enter;
  try
    Inc(FPnID);
    Result := FPnID;
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
