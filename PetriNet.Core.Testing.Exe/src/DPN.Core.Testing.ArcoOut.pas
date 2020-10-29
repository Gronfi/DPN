unit DPN.Core.Testing.ArcoOut;

interface

uses
  System.Rtti,
  Spring.Collections,

  DUnitX.TestFramework,

  DPN.Interfaces,
  DPN.Plaza,
  DPN.ArcoOut;

type
  //[TestFixture]
  TPetriNetCoreTesting_ArcoOut = class
  private
    FID      : Integer;
    FArco    : IArcoOut;
    FPlaza   : IPlaza;
    FContextoCambiado: Boolean;
    FValor           : Boolean;
    FCnt : Integer;
  protected
    procedure DoOnHabilitacionChanged(const AID: Integer; const ANewEstado: boolean);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure Test_Transicionado_Arco;
    [Test]
    [TestCase('Test-Capacidad=2,1,TRUE','2,1,TRUE')]
    [TestCase('Test-Capacidad=1,0,TRUE','1,0,TRUE')]
    [TestCase('Test-Capacidad=1,1,FALSE','1,1,FALSE')]
    [TestCase('Test-Capacidad=5,4,TRUE','5,4,TRUE')]
    [TestCase('Test-Capacidad=5,5,FALSE','5,5,FALSE')]
    procedure Test_Evaluar_CapacidadDestino(const ACapacidad : Integer; const ANoTokensEstado: Integer; const AResult : Boolean);
    [Test]
    procedure Test_Cambio_En_Estado_Notifica_A_Arco;
  end;

implementation

uses
  System.SysUtils,

  DPN.TokenColoreado;

{ TPetriNetCoreTesting_ArcoOut }

procedure TPetriNetCoreTesting_ArcoOut.DoOnHabilitacionChanged(const AID: Integer; const ANewEstado: boolean);
begin
  FID := AID;
  FContextoCambiado := True;
  FValor := ANewEstado;
  inc(FCnt);
end;

procedure TPetriNetCoreTesting_ArcoOut.Setup;
begin
  FPlaza   := TdpnPlaza.Create;
  FPlaza.Nombre    := 'D';
  FPlaza.Capacidad := 1;

  FArco                        := TdpnArcoOut.Create;
  FArco.Plaza                  := FPlaza;
  FArco.Peso                   := 1;

  FArco.OnHabilitacionChanged.Add(DoOnHabilitacionChanged);

  FCnt := 0;
end;

procedure TPetriNetCoreTesting_ArcoOut.TearDown;
begin
  FArco.OnHabilitacionChanged.Remove(DoOnHabilitacionChanged);
  FArco.PLaza := nil;
  FArco       := nil;
  FPlaza      := nil;
end;

procedure TPetriNetCoreTesting_ArcoOut.Test_Cambio_En_Estado_Notifica_A_Arco;
var
  I: Integer;
  LToken: IToken;
begin
  if FPlaza.TokenCount <> 0 then
    Assert.Fail('Step1: TokenCount <> 0');
  FPlaza.Capacidad := 5;
  FID := 0;
  FContextoCambiado := False;
  for I := 1 to 5 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlaza.AddToken(LToken);
  end;
  if not FContextoCambiado then
    Assert.Fail('Contexto');
  if FID <> FArco.ID then
    Assert.Fail('ID: ' + FID.ToString);
  Assert.Pass('Cnt: ' + FCnt.ToString);
end;

procedure TPetriNetCoreTesting_ArcoOut.Test_Evaluar_CapacidadDestino(const ACapacidad, ANoTokensEstado: Integer; const AResult: Boolean);
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;
begin
  if FPlaza.TokenCount <> 0 then
    Assert.Fail('Step1: TokenCount <> 0');
  FPlaza.Capacidad := ACapacidad;
  for I := 1 to ANoTokensEstado do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlaza.AddToken(LToken);
  end;
  LToken := TdpnTokenColoreado.Create;
  LRes := FArco.Evaluar(0);
  if LRes = AResult then
    Assert.Pass
  else
    Assert.Fail('Step2');
end;

procedure TPetriNetCoreTesting_ArcoOut.Test_Transicionado_Arco;
var
  LToken: IToken;
begin
  if FPlaza.TokenCount <> 0 then
    Assert.Fail('Step1: TokenCount <> 0');
  LToken := TdpnTokenColoreado.Create;
  FArco.DoOnTransicionando([LToken]);
  if FPlaza.TokenCount = 1 then
    Assert.Pass
  else
    Assert.Fail('Step2: TokenCount <> 1');
end;

initialization
  //TDUnitX.RegisterTestFixture(TPetriNetCoreTesting_ArcoOut);

end.
