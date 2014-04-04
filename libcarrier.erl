-module(libcarrier).
-export (
    [get_relay_packet/1]
).

-import(mochijson2, [decode/1, decoder/2]).
-include("ejabberd.hrl").


%% Expects a Base64 encoded json string looking something like:
%% {
%%  to:   {user: "..", host: ".."},
%%  from: {user: "..", "host: ".."},
%%  id: 0,
%%  body: "..",
%%  time: ".."
%% }
get_relay_packet(MsgBody) ->
    DecodedMsg = mochijson2:decode(MsgBody),
    %io:format(DecodedMsg),
    %io:format("~p\n", DecodedMsg),
    DecodedMsg.
