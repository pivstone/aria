%% JWK Module
%%
-module(sign).

-include("Ecdsa.hrl").


-export([decode/1]).
-export([encode/1]).


decode(Sig) when is_binary(Sig) ->
  {ok,Decode} = 'Ecdsa':decode('Sig', Sig),
  R = Decode#'Sig'.r,
  S = Decode#'Sig'.s,
  R_B =binary:encode_unsigned(R),
  S_B =binary:encode_unsigned(S),
  <<R_B/binary,S_B/binary>>.

encode(Sig) when byte_size(Sig) == 64 ->
  <<R_S:32/binary, S_S:32/binary>> = Sig,
  R = binary:decode_unsigned(R_S),
  S = binary:decode_unsigned(S_S),
  {ok,Encode} = 'Ecdsa':encode('Sig',{Sig,R,S}),
  Encode;

encode(Sig) when byte_size(Sig) > 64 ->
  Sig.