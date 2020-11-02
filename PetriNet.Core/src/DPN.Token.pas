unit DPN.Token;

interface

uses
  DPN.Interfaces;

type
  TdpnToken = class(TInterfacedObject, IToken)
  protected
    FID: int64;
    FPlaza: IPlaza;

    function GetID: int64;

    function GetPlaza: IPlaza;
    procedure SetPlaza(APlaza: IPlaza);
  public
    constructor Create;
    destructor Destroy; override;

    function Clon: IToken;

    property ID: int64 read GetID;
    property Plaza: IPlaza read GetPlaza write SetPlaza;
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

function TdpnToken.GetPlaza: IPlaza;
begin
  Result := FPlaza;
end;

procedure TdpnToken.SetPlaza(APlaza: IPlaza);
begin
  FPlaza := APlaza;
end;

end.
