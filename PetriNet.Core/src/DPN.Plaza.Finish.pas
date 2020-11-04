unit DPN.Plaza.Finish;

interface
uses
  Spring,
  Spring.Collections,

  DPN.Interfaces,
  DPN.Plaza;

type
  TdpnPlazaFinish = class (TdpnPlaza)
  protected
    function GetAceptaArcosIN: Boolean; override;

    procedure SetCapacidad(const Value: integer); override;
  public
    constructor Create; override;

    procedure AddToken(AToken: IToken); override;
    procedure AddTokens(ATokens: TListaTokens); overload; override;
    procedure AddTokens(ATokens: TArrayTokens); overload; override;
  end;

implementation

uses
  System.SysUtils,

  DPN.TokenSistema;

{ TdpnPlazaStart }

procedure TdpnPlazaFinish.AddToken(AToken: IToken);
begin
  ;
end;

procedure TdpnPlazaFinish.AddTokens(ATokens: TListaTokens);
begin
  ;
end;

procedure TdpnPlazaFinish.AddTokens(ATokens: TArrayTokens);
begin
  ;
end;constructor TdpnPlazaFinish.Create;
begin
  inherited;
  FCapacidad := Integer.MaxValue;
end;


function TdpnPlazaFinish.GetAceptaArcosIN: Boolean;
begin
  Result := False;
end;

procedure TdpnPlazaFinish.SetCapacidad(const Value: integer);
begin
  ;
end;

end.
