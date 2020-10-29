unit DPN.Core.Testing.Transicion;

interface

uses
  System.Rtti,
  Spring.Collections,

  DUnitX.TestFramework,

  DPN.Interfaces,
  DPN.Variable,
  DPN.Plaza,
  DPN.ArcoIn,
  DPN.ArcoOut,
  DPN.Transicion;

type
  [TestFixture]
  TPetriNetCoreTesting_Transicion = class
  private
    FID              : Integer;
    FContextoCambiado: Boolean;
    FValor           : Boolean;
    FCnt             : Integer;
    procedure Test_Cambio_En_Estado_Notifica_A_Arco;
    procedure Test_Evaluar_ArcoHabilitado_Origen_1_Estado(const APesoArco,
      APesoExtraer, ANoTokensEstado: Integer; const AResult: Boolean);
    procedure Test_Transicionado_Arco;
  protected
    procedure DoOnHabilitacionChanged(const AID: Integer; const ANewEstado: boolean);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure Test_Habilitado_1_Estado_Origen;
    [Test]
    procedure Test_Habilitado_2_Estados_Origen;
    [Test]
    procedure Test_Deshabilitado_1_Estado_Origen;
    [Test]
    procedure Test_Deshabilitado_2_Estados_Origen;
    [Test]
    procedure Test_Habilitado_1_Estado_Origen_Arco_Es_Inhabilitador;
    [Test]
    procedure Test_Deshabilitado_1_Estado_Origen_Arco_Es_Inhabilitador;
    [Test]
    procedure Test_Habilitado_2_Estados_Origen_1_Arco_Es_Inhabilitador;
    [Test]
    procedure Test_Deshabilitado_2_Estados_Origen_1_Arco_Es_Inhabilitador;

    [Test]
    procedure Test_Habilitado_1_Estado_Origen_1_Estado_Destino;
    [Test]
    procedure Test_Deshabilitado_1_Estado_Origen_1_Estado_Destino_Por_Origen;
    [Test]
    procedure Test_Deshabilitado_1_Estado_Origen_1_Estado_Destino_Por_Destino;

    [Test]
    procedure Test_Transicion_CondicionesOK_1_Estado_Origen_1_Estado_Destino;
    [Test]
    procedure Test_Transicion_CondicionesNoOK_1_Estado_Origen_1_Estado_Destino;

    [Test]
    procedure Test_Transicion_CondicionesNoOK_EventoCambio_1_Estado_Origen_1_Estado_Destino;
//    [Test]
//    [TestCase('Test-TokenCount=2,1,1,FALSE','2,1,1,FALSE')]
//    [TestCase('Test-TokenCount=2,1,2,TRUE','2,1,2,TRUE')]
//    [TestCase('Test-TokenCount=2,1,2,TRUE','2,1,5,TRUE')]
//    [TestCase('Test-TokenCount=2,1,2,TRUE','4,2,2,FALSE')]
//    procedure Test_Evaluar_ArcoHabilitado_Origen_1_Estado(const APesoArco : Integer; const APesoExtraer : Integer; const ANoTokensEstado: Integer; const AResult : Boolean);
//    [Test]
//    procedure Test_Cambio_En_Estado_Notifica_A_Arco;
  end;

implementation

uses
  System.SysUtils,

  DPN.Core.Testing.Funciones,
  DPN.TokenColoreado;

{ TPetriNetCoreTesting_ArcoIn }

procedure TPetriNetCoreTesting_Transicion.DoOnHabilitacionChanged(const AID: Integer; const ANewEstado: boolean);
begin
  FID := AID;
  FContextoCambiado := True;
  FValor := ANewEstado;
  inc(FCnt);
end;

procedure TPetriNetCoreTesting_Transicion.Setup;
begin

end;

procedure TPetriNetCoreTesting_Transicion.TearDown;
begin

end;

procedure TPetriNetCoreTesting_Transicion.Test_Cambio_En_Estado_Notifica_A_Arco;
var
  I: Integer;
  LToken: IToken;
begin
  (*
  try
    if FPlaza.TokenCount <> 0 then
      Assert.Fail('Step1: TokenCount <> 0');
    if FArco.IsHabilitado then
      Assert.Fail('Step2: Habilitado');
    FID := 0;
    FContextoCambiado := False;
    for I := 1 to 1 do
    begin
      LToken := TdpnTokenColoreado.Create;
      FPlaza.AddToken(LToken);
    end;
    if not FContextoCambiado then
      Assert.Fail('Contexto');
    if FID <> FArco.ID then
      Assert.Fail('ID: ' + FID.ToString);
    if not FArco.IsHabilitado then
      Assert.Fail('No Habilitado');
    Assert.Pass('Cnt: ' + FCnt.ToString);
  finally
    FArco.OnHabilitacionChanged.Remove(DoOnHabilitacionChanged);
    FArco.PLaza := nil;
    FArco       := nil;
    FPlaza      := nil;
  end;
  *)
end;

procedure TPetriNetCoreTesting_Transicion.Test_Deshabilitado_1_Estado_Origen_1_Estado_Destino_Por_Destino;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;

  FArcoO1    : IArcoOut;
  FPlazaO1   : IPlaza;

  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'I1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FPlazaO1   := TdpnPlaza.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 1;

  FArcoO1                        := TdpnArcoOut.Create;
  FArcoO1.Plaza                  := FPlazaO1;
  FArcoO1.Peso                   := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  for I := 1 to 1 do //saturamos plaza destino
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaO1.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Deshabilitado_1_Estado_Origen_1_Estado_Destino_Por_Origen;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;

  FArcoO1    : IArcoOut;
  FPlazaO1   : IPlaza;

  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'I1';
  FPlazaI1.Capacidad := 2;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 2;
  FArcoI1.PesoEvaluar            := 2;

  FPlazaO1   := TdpnPlaza.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 1;

  FArcoO1                        := TdpnArcoOut.Create;
  FArcoO1.Plaza                  := FPlazaO1;
  FArcoO1.Peso                   := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);

  for I := 1 to 1 do // solo 1
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Deshabilitado_1_Estado_Origen;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;
  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'O1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FArcoI1.OnHabilitacionChanged.Add(DoOnHabilitacionChanged);

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);

  LRes := FTransicion.IsHabilitado;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Deshabilitado_1_Estado_Origen_Arco_Es_Inhabilitador;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;
  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'O1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.IsInhibidor            := True;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FArcoI1.OnHabilitacionChanged.Add(DoOnHabilitacionChanged);

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Deshabilitado_2_Estados_Origen;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;

  FArcoI2    : IArcoIn;
  FPlazaI2   : IPlaza;

  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'O1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FPlazaI2   := TdpnPlaza.Create;
  FPlazaI2.Nombre    := 'O2';
  FPlazaI2.Capacidad := 1;

  FArcoI2                        := TdpnArcoIn.Create;
  FArcoI2.Plaza                  := FPlazaI2;
  FArcoI2.Peso                   := 1;
  FArcoI2.PesoEvaluar            := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoIn(FArcoI2);

  LRes := FTransicion.IsHabilitado;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Deshabilitado_2_Estados_Origen_1_Arco_Es_Inhabilitador;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;
  FArcoI2    : IArcoIn;
  FPlazaI2   : IPlaza;
  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'O1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;
  FArcoI1.IsInhibidor            := True;

  FPlazaI2   := TdpnPlaza.Create;
  FPlazaI2.Nombre    := 'O2';
  FPlazaI2.Capacidad := 1;

  FArcoI2                        := TdpnArcoIn.Create;
  FArcoI2.Plaza                  := FPlazaI2;
  FArcoI2.Peso                   := 1;
  FArcoI2.PesoEvaluar            := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoIn(FArcoI2);

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if LRes then // de los 2 arcos solo 1 habilitado
    Assert.Fail;

  for I := 1 to 2 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI2.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Evaluar_ArcoHabilitado_Origen_1_Estado(const APesoArco : Integer; const APesoExtraer : Integer; const ANoTokensEstado: Integer; const AResult : Boolean);
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;
begin
  (*
  FArco.Peso := APesoArco;
  FArco.PesoEvaluar := APesoExtraer;
  for I := 1 to ANoTokensEstado do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlaza.AddToken(LToken);
  end;
  LRes := FArco.Evaluar(FPlaza.TokenCount);
  if LRes = AResult then
    Assert.Pass
  else
    Assert.Fail;
  *)
end;

procedure TPetriNetCoreTesting_Transicion.Test_Habilitado_1_Estado_Origen;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;
  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'O1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FArcoI1.OnHabilitacionChanged.Add(DoOnHabilitacionChanged);

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Habilitado_1_Estado_Origen_1_Estado_Destino;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;

  FArcoO1    : IArcoOut;
  FPlazaO1   : IPlaza;

  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'I1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FPlazaO1   := TdpnPlaza.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 1;

  FArcoO1                        := TdpnArcoOut.Create;
  FArcoO1.Plaza                  := FPlazaO1;
  FArcoO1.Peso                   := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Habilitado_1_Estado_Origen_Arco_Es_Inhabilitador;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;
  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'O1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.IsInhibidor            := True;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FArcoI1.OnHabilitacionChanged.Add(DoOnHabilitacionChanged);

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);

  LRes := FTransicion.IsHabilitado;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Habilitado_2_Estados_Origen;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;
  FArcoI2    : IArcoIn;
  FPlazaI2   : IPlaza;
  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'O1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FPlazaI2   := TdpnPlaza.Create;
  FPlazaI2.Nombre    := 'O2';
  FPlazaI2.Capacidad := 1;

  FArcoI2                        := TdpnArcoIn.Create;
  FArcoI2.Plaza                  := FPlazaI2;
  FArcoI2.Peso                   := 1;
  FArcoI2.PesoEvaluar            := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoIn(FArcoI2);

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if LRes then // de los 2 arcos solo 1 habilitado
    Assert.Fail;

  for I := 1 to 2 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI2.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Habilitado_2_Estados_Origen_1_Arco_Es_Inhabilitador;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;
  FArcoI2    : IArcoIn;
  FPlazaI2   : IPlaza;
  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'O1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;
  FArcoI1.IsInhibidor            := True;

  FPlazaI2   := TdpnPlaza.Create;
  FPlazaI2.Nombre    := 'O2';
  FPlazaI2.Capacidad := 1;

  FArcoI2                        := TdpnArcoIn.Create;
  FArcoI2.Plaza                  := FPlazaI2;
  FArcoI2.Peso                   := 1;
  FArcoI2.PesoEvaluar            := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoIn(FArcoI2);

  (*
  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;
  *)

  LRes := FTransicion.IsHabilitado;

  if LRes then // de los 2 arcos solo 1 habilitado
    Assert.Fail;

  for I := 1 to 2 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI2.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Transicionado_Arco;
begin

end;

procedure TPetriNetCoreTesting_Transicion.Test_Transicion_CondicionesNoOK_1_Estado_Origen_1_Estado_Destino;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;

  FArcoO1    : IArcoOut;
  FPlazaO1   : IPlaza;

  FTransicion: ITransicion;

  FFuncion : ICondicion;
  FEnabled : IVariable;
begin
  FEnabled := TdpnVariable.Create;
  FEnabled.Nombre := 'Enabled';
  FEnabled.Valor  := 0;

  FFuncion := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(FFuncion).Variable     := FEnabled;
  TdpnCondicion_es_tabla_variables(FFuncion).ValorToCheck := 5;

  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'I1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FPlazaO1   := TdpnPlaza.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 1;

  FArcoO1                        := TdpnArcoOut.Create;
  FArcoO1.Plaza                  := FPlazaO1;
  FArcoO1.Peso                   := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.Start;

  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);
  FTransicion.AddCondicion(FFuncion);

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;
  if not LRes then
    Assert.Fail('No habilitado!');

  LRes := FTransicion.EjecutarTransicion;
  if LRes then
    Assert.Fail('No debiera!');

  FEnabled.Valor  := 7;

  LRes := FTransicion.EjecutarTransicion;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Transicion_CondicionesOK_1_Estado_Origen_1_Estado_Destino;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;

  FArcoO1    : IArcoOut;
  FPlazaO1   : IPlaza;

  FTransicion: ITransicion;

  FFuncion : ICondicion;
  FEnabled : IVariable;
begin
  FEnabled := TdpnVariable.Create;
  FEnabled.Nombre := 'Enabled';
  FEnabled.Valor  := 0;

  FFuncion := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(FFuncion).Variable     := FEnabled;
  TdpnCondicion_es_tabla_variables(FFuncion).ValorToCheck := 5;

  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'I1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FPlazaO1   := TdpnPlaza.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 1;

  FArcoO1                        := TdpnArcoOut.Create;
  FArcoO1.Plaza                  := FPlazaO1;
  FArcoO1.Peso                   := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.Start;

  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);
  FTransicion.AddCondicion(FFuncion);

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;
  if not LRes then
    Assert.Fail('No habilitado!');

  LRes := FTransicion.EjecutarTransicion;
  if LRes then
    Assert.Fail('No debiera!');

  FEnabled.Valor  := 5;

  LRes := FTransicion.EjecutarTransicion;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

initialization
  TDUnitX.RegisterTestFixture(TPetriNetCoreTesting_Transicion);

end.
