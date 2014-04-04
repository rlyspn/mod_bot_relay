-module(libcarrier_test).
-export([test_carrier/0]).

-import(libcarrier, [get_relay_packet/1]).

test_carrier() ->
	DecodedMsg = get_relay_packet(<<"[1,2,3]">>),
	io:format("~p~n", [DecodedMsg]).
