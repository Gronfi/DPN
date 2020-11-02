unit DPN.Core.Testing.Funciones;

interface

uses
  System.Rtti,
  Spring.Collections,

  DUnitX.TestFramework,

  Event.Engine.Interfaces,
  Event.Engine,

  DPN.TokenSistema,
  DPN.Core,
  DPN.Interfaces,
  DPN.Condicion,
  DPN.Accion,
  DPN.Variable;

type
  TdpnCondicion_es_tabla_variables = class(TdpnCondicion)
  protected
    FVariable: IVariable;
    FValor: TValue;

    function GetDependencias: IList<IBloqueable>; override;

    function GetVariable: IVariable;
    procedure SetVariable(AVariable: IVariable);

    function GetValorToCheck: TValue;
    procedure SetValorToCheck(const AValue: TValue);

    procedure DoOnVarChanged(const AID: Integer; const AValue: TValue);

    function EvaluarInterno: Boolean;

  public
    function Evaluar(ATokens: IMarcadoTokens; AEvento: IEventEE): Boolean; overload; override;

    property Variable: IVariable read GetVariable write SetVariable;
    property ValorToCheck: TValue read GetValorToCheck write SetValorToCheck;
  end;

  TEventoPrueba = class(TEventEE)
  protected
    FNumero: integer;
    FTexto : string;
  public
    property Numero: integer read FNumero write FNumero;
    property Texto: string read FTexto write FTexto;
  end;

  TdpnCondicion_Evento_Prueba = class(TdpnCondicionBaseEsperaEvento)
  protected
    FNumero: integer;
  public
    function DoOnEventoRequiereFiltrado(AEvento: IEventEE): Boolean; override;
    function CrearListenerEvento: IEventEEListener; override;

    function Evaluar(ATokens: IMarcadoTokens; AEvento: IEventEE): Boolean; overload; override;
    property Numero: integer read FNumero write FNumero;
  end;

  //[TestFixture]
  TPetriNetCoreTesting_Funciones = class
  private
    FID      : Integer;
    FFuncion : ICondicion;
    FEnabled : IVariable;
    FValor   : Integer;
    FContextoCambiado: Boolean;
  protected
    procedure DoOnVarChanged(const AID: Integer; const AValue: TValue);
    procedure DoOnContextoChanged(const AID: Integer);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    [TestCase('Test-Check=1,1,TRUE','1,1,TRUE')]
    [TestCase('Test-Check=2,2,TRUE','2,2,TRUE')]
    [TestCase('Test-Check=5,3,FALSE','5,3,FALSE')]
    [TestCase('Test-Check=10,10,TRUE','10,10,TRUE')]
    procedure Test_Valor_Cambiado(const AValue : Integer; const ACheck: Integer; const AResult : Boolean);
    [Test]
    procedure Test_Evaluacion_Y_Cambio_Contexto_Posterior;
    [Test]
    procedure Test_1_Evento_OK;
    [Test]
    procedure Test_1_Evento_NoOK;
    [Test]
    procedure Test_1_Evento_NoAceptado;
    [Test]
    procedure Test_2_Eventos_1_OK_2_NoOK;
  end;

implementation

uses
  System.SysUtils,

  DPN.Plaza,
  DPN.MarcadoTokens;

{ TdpnCondicion_es_tabla_variables }

function TdpnCondicion_es_tabla_variables.Evaluar(ATokens: IMarcadoTokens; AEvento: IEventEE): Boolean;
begin
  Result := EvaluarInterno
end;

procedure TdpnCondicion_es_tabla_variables.DoOnVarChanged(const AID: Integer; const AValue: TValue);
begin
  OnContextoCondicionChanged.Invoke(ID);
end;

function TdpnCondicion_es_tabla_variables.EvaluarInterno: Boolean;
begin
  Result := (FVariable.Valor.AsInteger = FValor.AsInteger)
end;

function TdpnCondicion_es_tabla_variables.GetDependencias: IList<IBloqueable>;
begin
  Result := TCollections.CreateList<IBloqueable>;
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

{ TPetriNetCoreTesting_Funciones }

procedure TPetriNetCoreTesting_Funciones.DoOnContextoChanged(const AID: Integer);
begin
  FID := AID;
  FContextoCambiado := True;
end;

procedure TPetriNetCoreTesting_Funciones.DoOnVarChanged(const AID: Integer; const AValue: TValue);
begin
  FValor := AValue.AsInteger;
end;

procedure TPetriNetCoreTesting_Funciones.Setup;
begin
  FEnabled := TdpnVariable.Create;
  FEnabled.Nombre := 'Enabled';
  FEnabled.Valor  := 0;
  FEnabled.OnValueChanged.Add(DoOnVarChanged);

  FFuncion := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(FFuncion).Variable := FEnabled;
  FFuncion.OnContextoCondicionChanged.Add(DoOnContextoChanged);

  FID              := 0;
  FContextoCambiado:= False;
end;

procedure TPetriNetCoreTesting_Funciones.TearDown;
begin
  FFuncion.OnContextoCondicionChanged.Remove(DoOnContextoChanged);

  FEnabled.OnValueChanged.Remove(DoOnVarChanged);
  FEnabled := nil;
end;

procedure TPetriNetCoreTesting_Funciones.Test_1_Evento_NoAceptado;
var
  LFuncion : ICondicion;
  LEvento  : IEventEE;
begin
  LFuncion := TdpnCondicion_Evento_Prueba.Create;
  try
    TdpnCondicion_Evento_Prueba(LFuncion).Numero := 5;
    LFuncion.OnContextoCondicionChanged.Add(DoOnContextoChanged);
    LEvento := TEventoPrueba.Create;
    TEventoPrueba(LEvento).Numero := 7;
    TEventoPrueba(LEvento).Texto  := 'Hola';
    LEvento.Post;
    Sleep(50);
    if not FContextoCambiado then
      Assert.Pass
    else Assert.Fail;
  finally
    LFuncion := nil;
  end;
end;

procedure TPetriNetCoreTesting_Funciones.Test_1_Evento_NoOK;
var
  LFuncion : ICondicion;
  LEvento  : IEventEE;
  LRes     : boolean;
  LPlaza   : IPlaza;
  LMarcado : IMarcadoTokens;
  LToken   : IToken;
  LEventoR : IEventEE;
begin
  LFuncion := TdpnCondicion_Evento_Prueba.Create;
  try
    TdpnCondicion_Evento_Prueba(LFuncion).Numero := 5;
    LFuncion.OnContextoCondicionChanged.Add(DoOnContextoChanged);
    LEvento := TEventoPrueba.Create;
    TEventoPrueba(LEvento).Numero := 5;
    TEventoPrueba(LEvento).Texto  := 'Pepe';
    LEvento.Post;
    Sleep(50);
    if FID <> LFuncion.ID then
      Assert.Fail('ID: ' + FID.ToString);
    if not FContextoCambiado then
      Assert.Fail('Contexto');
    LEventoR := LFuncion.GetPrimerEvento;
    LMarcado := TdpnMarcadoTokens.Create;
    LPlaza := TdpnPlaza.Create;
    LToken := TdpnTokenSistema.Create;
    LMarcado.AddTokenPlaza(LPlaza, LToken);
    LRes := LFuncion.Evaluar(LMarcado, LEventoR);
    if not LRes then
      Assert.Pass
    else Assert.Fail;
  finally
    LFuncion := nil;
  end;
end;

procedure TPetriNetCoreTesting_Funciones.Test_1_Evento_OK;
var
  LFuncion : ICondicion;
  LEvento  : IEventEE;
  LRes     : boolean;
  LPlaza   : IPlaza;
  LMarcado : IMarcadoTokens;
  LToken   : IToken;
  LEventoR : IEventEE;
begin
  LFuncion := TdpnCondicion_Evento_Prueba.Create;
  try
    TdpnCondicion_Evento_Prueba(LFuncion).Numero := 5;
    LFuncion.OnContextoCondicionChanged.Add(DoOnContextoChanged);
    LEvento := TEventoPrueba.Create;
    TEventoPrueba(LEvento).Numero := 5;
    TEventoPrueba(LEvento).Texto  := 'Hola';
    LEvento.Post;
    Sleep(50);
    if FID <> LFuncion.ID then
      Assert.Fail('ID: ' + FID.ToString);
    if not FContextoCambiado then
      Assert.Fail('Contexto');
    LEventoR := LFuncion.GetPrimerEvento;
    LMarcado := TdpnMarcadoTokens.Create;
    LPlaza := TdpnPlaza.Create;
    LToken := TdpnTokenSistema.Create;
    LMarcado.AddTokenPlaza(LPlaza, LToken);
    LRes := LFuncion.Evaluar(LMarcado, LEventoR);
    if LRes then
      Assert.Pass
    else Assert.Fail;
  finally
    LFuncion := nil;
  end;
end;

procedure TPetriNetCoreTesting_Funciones.Test_2_Eventos_1_OK_2_NoOK;
var
  LFuncion : ICondicion;
  LEvento  : IEventEE;
  LRes     : boolean;
  LPlaza   : IPlaza;
  LMarcado : IMarcadoTokens;
  LToken   : IToken;
  LEventoR : IEventEE;
begin
  LFuncion := TdpnCondicion_Evento_Prueba.Create;
  try
    TdpnCondicion_Evento_Prueba(LFuncion).Numero := 5;
    LFuncion.OnContextoCondicionChanged.Add(DoOnContextoChanged);
    LEvento := TEventoPrueba.Create;
    TEventoPrueba(LEvento).Numero := 5;
    TEventoPrueba(LEvento).Texto  := 'Hola';
    LEvento.Post;
    LEvento := TEventoPrueba.Create;
    TEventoPrueba(LEvento).Numero := 5;
    TEventoPrueba(LEvento).Texto  := 'Koko';
    LEvento.Post;
    Sleep(50);
    if FID <> LFuncion.ID then
      Assert.Fail('ID: ' + FID.ToString);
    if not FContextoCambiado then
      Assert.Fail('Contexto');
    if LFuncion.EventosCount <> 2 then
      Assert.Fail('No eventos');
    LEventoR := LFuncion.GetPrimerEvento;
    LMarcado := TdpnMarcadoTokens.Create;
    LPlaza := TdpnPlaza.Create;
    LToken := TdpnTokenSistema.Create;
    LMarcado.AddTokenPlaza(LPlaza, LToken);
    LRes := LFuncion.Evaluar(LMarcado, LEventoR);
    if not LRes then
      Assert.Fail;
    LFuncion.RemovePrimerEvento;
    LEventoR := LFuncion.GetPrimerEvento;
    LMarcado.AddTokenPlaza(LPlaza, LToken);
    LRes := LFuncion.Evaluar(LMarcado, LEventoR);
    if not LRes then
      Assert.Pass
    else Assert.Fail;
  finally
    LFuncion := nil;
  end;
end;

procedure TPetriNetCoreTesting_Funciones.Test_Evaluacion_Y_Cambio_Contexto_Posterior;
var
  LRes : Boolean;
  LPlaza: IPlaza;
  LMarcado: IMarcadoTokens;
  LToken: IToken;
begin
  FEnabled.Valor := 1;
  TdpnCondicion_es_tabla_variables(FFuncion).ValorToCheck := 1;
  LMarcado := TdpnMarcadoTokens.Create;
  LPlaza := TdpnPlaza.Create;
  LMarcado.AddTokenPlaza(LPlaza, LToken);
  LRes := FFuncion.Evaluar(LMarcado);
  if (LRes = False) then
    Assert.Fail('Funcion ha evaluado mal');
  FContextoCambiado := False;
  FID               := 0;
  FEnabled.Valor    := 2;
  if FID <> FFuncion.ID then
    Assert.Fail('ID: ' + FID.ToString);
  if not FContextoCambiado then
    Assert.Fail('Contexto');
  Assert.Pass;
end;

procedure TPetriNetCoreTesting_Funciones.Test_Valor_Cambiado(const AValue: Integer; const ACheck: Integer; const AResult : Boolean);
var
  LRes : Boolean;
  LPlaza: IPlaza;
  LMarcado: IMarcadoTokens;
  LToken: IToken;
begin
  FEnabled.Valor := AValue;
  TdpnCondicion_es_tabla_variables(FFuncion).ValorToCheck := ACheck;
  LMarcado := TdpnMarcadoTokens.Create;
  LPlaza := TdpnPlaza.Create;
  LMarcado.AddTokenPlaza(LPlaza, LToken);
  LRes := FFuncion.Evaluar(LMarcado);
  if (AResult = LRes) then
    Assert.Pass
  else Assert.Fail;
end;

{ TdpnCondicion_Evento_Prueba }

function TdpnCondicion_Evento_Prueba.CrearListenerEvento: IEventEEListener;
begin
  Result := TEventListener<TEventoPrueba>.Create(DoOnEventoRecibido, DoOnEventoRequiereFiltrado, DPNCore.CHANNEL_MULTI_THREADED);
end;

function TdpnCondicion_Evento_Prueba.DoOnEventoRequiereFiltrado(AEvento: IEventEE): Boolean;
begin
  Result := TEventoPrueba(AEvento).Numero = FNumero
end;

function TdpnCondicion_Evento_Prueba.Evaluar(ATokens: IMarcadoTokens; AEvento: IEventEE): Boolean;
begin
  Result := TEventoPrueba(AEvento).Texto = 'Hola';
end;

initialization
  //TDUnitX.RegisterTestFixture(TPetriNetCoreTesting_Funciones);

end.
