unit DPN.ArcoReset;

interface

uses
  DPN.Interfaces,
  DPN.ArcoOut;

type
  TdpnArcoReset = class(TdpnArcoOut, IArcoReset)
  public
    procedure DoOnTransicionando(ATokensAfectados: TListaTokens); overload; override;
    procedure DoOnTransicionando(ATokensAfectados: TArrayTokens); overload; override;
  end;

implementation

{ TdpnArcoReset }

procedure TdpnArcoReset.DoOnTransicionando(ATokensAfectados: TArrayTokens);
begin
  Plaza.EliminarTodosTokens;
end;

{ TdpnArcoReset }

procedure TdpnArcoReset.DoOnTransicionando(ATokensAfectados: TListaTokens);
begin
  Plaza.EliminarTodosTokens;
end;

end.
