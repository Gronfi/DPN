unit DPN.Token;

interface

uses
  DPN.Interfaces;

type
  TdpnToken = class(TInterfacedObject, IToken)
  protected
    FID: int64;
    FPlaza: IPlaza;

    FCantidadCambiosPlaza: int64;
    FMomentoCreacion: int64;
    FMomentoCambioPlaza: int64;

    function GetID: int64;

    function GetCantidadCambiosPlaza: int64;

    function GetMomentoCreacion: int64;

    function GetMomentoCambioPlaza: int64;

    function GetPlaza: IPlaza;
    procedure SetPlaza(APlaza: IPlaza);
  public
    constructor Create;
    destructor Destroy; override;

    function Clon: IToken;

    property ID: int64 read GetID;
    property Plaza: IPlaza read GetPlaza write SetPlaza;
    property CantidadCambiosPlaza: int64 read GetCantidadCambiosPlaza;
    property MomentoCreacion: int64 read GetMomentoCreacion;
    property MomentoCambioPlaza: int64 read GetMomentoCambioPlaza;
  end;

implementation

uses
  Event.Engine.Utils,
  DPN.Core;

{ TdpnToken }

function TdpnToken.Clon: IToken;
begin
  //DAVE
end;

constructor TdpnToken.Create;
begin
  inherited;
  FID                    := DPNCore.GetNuevoTokenID;
  FMomentoCreacion       := Utils.ElapsedMiliseconds;
  FMomentoCambioPlaza    := Utils.ElapsedMiliseconds;
  FCantidadCambiosPlaza  := 0;
end;

destructor TdpnToken.Destroy;
begin
  inherited;
end;

function TdpnToken.GetCantidadCambiosPlaza: int64;
begin
  Result := FCantidadCambiosPlaza
end;

function TdpnToken.GetID: int64;
begin
  Result := FID
end;

function TdpnToken.GetMomentoCambioPlaza: int64;
begin
  Result := FMomentoCambioPlaza;
end;

function TdpnToken.GetMomentoCreacion: int64;
begin
  Result := FMomentoCreacion
end;

function TdpnToken.GetPlaza: IPlaza;
begin
  Result := FPlaza;
end;

procedure TdpnToken.SetPlaza(APlaza: IPlaza);
begin
  FPlaza := APlaza;
  if Assigned(FPlaza) then
  begin
    FMomentoCambioPlaza := Utils.ElapsedMiliseconds;
    Inc(FCantidadCambiosPlaza);
  end;
end;

end.
