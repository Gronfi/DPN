{$I Defines.inc}
unit DPN.Core.Testing.Variables;

interface

uses
  System.Rtti,
  System.SysUtils,

  DUnitX.TestFramework,

  DPN.Interfaces,
  DPN.Variable;

type
{$IFDEF TESTS_HABILITADOS}
  [TestFixture]
{$ENDIF}
  TPetriNetCoreTesting_Variables = class
  private
    FEnabled : IVariable;
    FValor   : Integer;
  protected
    procedure DoOnVarChanged(const AID: Integer; const AValue: TValue);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure Test_Serializable;
    [Test]
    [TestCase('Test-Cambiar-Valor=1','1')]
    [TestCase('Test-Cambiar-Valor=2','2')]
    [TestCase('Test-Cambiar-Valor=5','5')]
    [TestCase('Test-Cambiar-Valor=10','10')]
    procedure Test_Valor_Cambiado(const AValue : Integer);
  end;

implementation

uses
  System.JSON;

procedure TPetriNetCoreTesting_Variables.DoOnVarChanged(const AID: Integer; const AValue: TValue);
begin
  FValor := AValue.AsInteger;
end;

procedure TPetriNetCoreTesting_Variables.Setup;
begin
  FEnabled := TdpnVariable.Create;
  FEnabled.NombreReducido := 'Enabled';
  FEnabled.Valor  := 0;
  FEnabled.OnValueChanged.Add(DoOnVarChanged);
end;

procedure TPetriNetCoreTesting_Variables.TearDown;
begin
  FEnabled.OnValueChanged.Remove(DoOnVarChanged);
  FEnabled := nil;
end;

procedure TPetriNetCoreTesting_Variables.Test_Serializable;
var
  LTmp: string;
  LJSon: TJSOnObject;
  LValorInicio : integer;
begin
  LValorInicio := FEnabled.Valor.AsInteger;
  WriteLn('I: ' + FEnabled.Valor.ToString);
  LJSon := FEnabled.FormatoJSON;
  LTmp := LJSON.ToString;
  WriteLn('Json: ' + LTmp);
  FEnabled.Valor  := 5;
  WriteLn('1: ' + FEnabled.Valor.ToString);
  FEnabled.CargarDeJSON(LJSon);
  WriteLn('F: ' + FEnabled.Valor.ToString);
  if FEnabled.Valor.AsInteger = LValorInicio then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Variables.Test_Valor_Cambiado(const AValue : Integer);
begin
  FEnabled.Valor := AValue;
  if (FValor = AValue) then
    Assert.Pass
  else Assert.Fail('Valor erroneo: ' + FValor.ToString);
end;

initialization
{$IFDEF TESTS_HABILITADOS}
  TDUnitX.RegisterTestFixture(TPetriNetCoreTesting_Variables);
{$ENDIF}
end.
