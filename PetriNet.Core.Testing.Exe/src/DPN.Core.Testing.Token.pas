{$I Defines.inc}
unit DPN.Core.Testing.Token;

interface

uses
  System.Rtti,
  Spring.Collections,

  DUnitX.TestFramework,

  DPN.Interfaces,
  DPN.Plaza,
  DPN.TokenSistema,
  DPN.Variable;

type
{$IFDEF TESTS_HABILITADOS}
  [TestFixture]
{$ENDIF}
  TPetriNetCoreTesting_Tokens = class
  private
  protected
  public
    [Test]
    procedure Test_TablaVariables;
  end;

implementation

uses
  System.SysUtils;

{ TPetriNetCoreTesting_Modelos }

procedure TPetriNetCoreTesting_Tokens.Test_TablaVariables;
var
  LToken : IToken;
  LPlazaI1: IPlaza;
begin
  LPlazaI1           := TdpnPlaza.Create;
  LPlazaI1.Nombre    := 'I1';
  LPlazaI1.Capacidad := 1;

  LToken := TdpnTokenSistema.Create;
  LPlazaI1.AddToken(LToken);

  LToken.Variable['Orden'] := '0000420000';
  LToken.Variable['Cnt'] := 5;

  Writeln(LToken.LogAsString);
  if not((LToken.Variable['Orden'].AsString = '0000420000') and (LToken.Variable['Cnt'].AsInteger = 5)) then
    Assert.Fail;
  Assert.Pass;
end;

initialization
{$IFDEF TESTS_HABILITADOS}
  TDUnitX.RegisterTestFixture(TPetriNetCoreTesting_Tokens);
{$ENDIF}
end.
