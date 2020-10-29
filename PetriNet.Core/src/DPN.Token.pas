unit DPN.Token;

interface

uses
  DPN.Interfaces;

type
  TdpnToken = class(TInterfacedObject, IToken)
  protected
    FID: int64;
    function GetID: int64;
  public
    constructor Create;
    destructor Destroy; override;

    function Clon: IToken;

    property ID: int64 read GetID;
  end;

implementation

uses
  DPN.Core;

{ TdpnToken }

function TdpnToken.Clon: IToken;
begin
  //DAVE
end;

constructor TdpnToken.Create;
begin
  inherited;
  FID := DPNCore.GetNuevoTokenID;
end;

destructor TdpnToken.Destroy;
begin

  inherited;
end;

function TdpnToken.GetID: int64;
begin
  Result := FID
end;

end.
