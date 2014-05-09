-module(mod_bot_relay).
-behavior(gen_mod).

-author("Riley Spahn").


%% Behavior for a module
-include("ejabberd.hrl").

-export([
        start/2,
        stop/1
    ]).
-export([on_filter_packet/1]).


-define(BOTNAME, mod_bot_relay).
-define(PROCNAME, ejabberd_mod_bot).

start(Host, Opts) ->
    ejabberd_hooks:add(filter_packet, global, ?MODULE, on_filter_packet, 0),
    ?INFO_MSG("Starting mod_bot_relay filter.", []).

stop(Host) ->
    Proc = gen_mod:get_module_proc(Host, ?PROCNAME),
    gen_server:call(Proc, stop),
    supervisor:terminat_child(ejabberd_sup, Proc),
    superviser:delete_child(ejabberd_sup, Proc),
    ?INFO_MSG("Stoping mod_bot_relay", []).

get_really_from_name([]) ->
    nil;
get_really_from_name([{"reallyFrom", FromName} | ListTail]) ->
    FromName;
get_really_from_name([{_, FromName} | ListTail]) ->
    get_really_from_name(ListTail).

get_really_from_id([]) ->
    nil;
get_really_from_id([{"reallyFromID", FromID} | ListTail]) ->
    FromID;
get_really_from_id([{_, FromID} | ListTail]) ->
    get_really_from_id(ListTail).

parse_really_from(RFrom) ->
    [UserName , Host | Tail] = string:tokens(RFrom, "@"),
    {UserName, Host}.

rewrite_from_packet(From, nil) ->
    From;
rewrite_from_packet({Jid, Name1, Host1, Ar1, Name2, Host2, Ar2} = From, RFrom) ->

    {RFromName, RFromHost} = parse_really_from(RFrom),
    {Jid, RFromName, RFromHost, Ar1, RFromName, RFromHost, Ar2}.

on_filter_packet({From, To, {xmlelement, "message", Attrs, Els} = Packet} = Msg) ->

    FromName = get_really_from_name(Attrs),
    FromID = get_really_from_id(Attrs),
    NewFrom = rewrite_from_packet(From, FromName),
    {NewFrom, To, {xmlelement, "message", Attrs, Els}};

%% Handle all non-message packets.
on_filter_packet(Packet) ->
    Packet.

