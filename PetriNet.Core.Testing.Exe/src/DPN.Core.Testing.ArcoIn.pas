{$I Defines.inc}
unit DPN.Core.Testing.ArcoIn;
interface

uses
  System.Rtti,
  Spring.Collections,

  DUnitX.TestFramework,

  DPN.Interfaces,
  DPN.Plaza,
  DPN.ArcoIn;

type
{$IFDEF TESTS_HABILITADOS}
  [TestFixture]
{$ENDIF}
  TPetriNetCoreTesting_ArcoIn = class
  private
    FID      : Integer;
    FArco    : IArcoIn;
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
    [TestCase('Test-TokenCount=2,1,1,FALSE','2,1,1,FALSE')]
    [TestCase('Test-TokenCount=2,1,2,TRUE','2,1,2,TRUE')]
    [TestCase('Test-TokenCount=2,1,2,TRUE','2,1,5,TRUE')]
    [TestCase('Test-TokenCount=2,1,2,TRUE','4,2,2,FALSE')]
    procedure Test_Evaluar_ArcoHabilitado_Origen_1_Estado(const APesoArco : Integer; const APesoExtraer : Integer; const ANoTokensEstado: Integer; const AResult : Boolean);
    [Test]
    procedure Test_Cambio_En_Estado_Notifica_A_Arco;
  end;

implementation

uses
  System.SysUtils,

  DPN.TokenColoreado;

{ TPetriNetCoreTesting_ArcoIn }

procedure TPetriNetCoreTesting_ArcoIn.DoOnHabilitacionChanged(const AID: Integer; const ANewEstado: boolean);
begin
  FID := AID;
  FContextoCambiado := True;
  FValor := ANewEstado;
  inc(FCnt);
end;

procedure TPetriNetCoreTesting_ArcoIn.Setup;
begin
  FPlaza           := TdpnPlaza.Create;
  FPlaza.Nombre    := 'O1';
  FPlaza.Capacidad := 5;
  FPlaza.Start;

  FArco                        := TdpnArcoIn.Create;
  FArco.Nombre                 := 'ArcoIn';
  FArco.Plaza                  := FPlaza;
  FArco.Peso                   := 1;
  FArco.PesoEvaluar            := 1;
  FArco.Start;

  FArco.OnHabilitacionChanged.Add(DoOnHabilitacionChanged);

  FCnt := 0;
end;

procedure TPetriNetCoreTesting_ArcoIn.TearDown;
begin
  FArco.OnHabilitacionChanged.Remove(DoOnHabilitacionChanged);
  FArco.PLaza := nil;
  FArco       := nil;
  FPlaza      := nil;
end;

procedure TPetriNetCoreTesting_ArcoIn.Test_Cambio_En_Estado_Notifica_A_Arco;
var
  I: Integer;
  LToken: IToken;
begin
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
  Assert.Pass('Cnt: ' + FCnt.ToString);
end;

procedure TPetriNetCoreTesting_ArcoIn.Test_Evaluar_ArcoHabilitado_Origen_1_Estado(const APesoArco : Integer; const APesoExtraer : Integer; const ANoTokensEstado: Integer; const AResult : Boolean);
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;
begin
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
end;

procedure TPetriNetCoreTesting_ArcoIn.Test_Transicionado_Arco;
var
  LToken: IToken;
begin
  LToken := TdpnTokenColoreado.Create;
  FPlaza.AddToken(LToken);
  if FPlaza.TokenCount <> 1 then
    Assert.Fail('Step1: TokenCount <> 1');
  FArco.DoOnTransicionando([LToken]);
  if FPlaza.TokenCount = 0 then
    Assert.Pass
  else
    Assert.Fail('Step2: TokenCount <> 0');
end;

initialization
{$IFDEF TESTS_HABILITADOS}
  TDUnitX.RegisterTestFixture(TPetriNetCoreTesting_ArcoIn);
{$ENDIF}

end.
