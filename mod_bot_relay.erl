-module(mod_bot_relay).
-author("Riley Spahn").

%% Behavior for a module
-include("ejabberd.hrl").
-behavior(gen_mod).

-export([start/2, stop/1]).

start(_Host, _Opt) ->
    ?DEBUG("Loading first module.", []).

stop(_Host) ->
    ok.
