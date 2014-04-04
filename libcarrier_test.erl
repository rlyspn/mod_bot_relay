-module(libcarrier_test).
-export([test_carrier/0]).

-import(libcarrier, [get_relay_packet/1]).
-import(base64, [encode_to_string/1]).

test_carrier() ->
	test_packet().

test_packet() ->
	RelayPacket = encode_to_string(<<"{\"to\":{\"user\":\"user1\", \"host\":\"localhost\"},\"from\":{\"user\":\"user2\", \"host\":\"localhost\"},\"time\":\"time1\",\"body\":\"bodybodybody\",\"id\":1}">>),
	DecodedPacket = get_relay_packet(RelayPacket),
	io:format("~p~n", [DecodedPacket]).
