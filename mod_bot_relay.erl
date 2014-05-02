-module(mod_bot_relay).
-behavior(gen_mod).

-author("Riley Spahn").


%% Behavior for a module
-include("ejabberd.hrl").

%-export([start_link/2]).
-export([
        start/2,
        stop/1
        %init/1,
        %handle_call/3,
        %handle_cast/2,
        %handle_info/2,
        %terminate/2,
        %code_change/3
    ]).
-export([on_filter_packet/1]).

%-export([route/3]).

-define(BOTNAME, mod_bot_relay).
-define(PROCNAME, ejabberd_mod_bot).

%% Start the server.
%start_link(Host, Opts) ->
    %Proc = gen_mod:get_module_proc(Host, ?PROCNAME),
    %gen_server:start_link({local, Proc}, ?MODULE, [Host, Opts], []),
%    ?INFO_MSG("Starting link: mod_bot_relay", []).

start(Host, Opts) ->
    %% Proc = gen_mod:get_module_proc(Host, ?PROCNAME),
    %%ChildSpec = {Proc,
    %%    {?MODULE, start_link, [Host, Opts]},
    %%   temporary, 1000, worker, [?MODULE]},
    %%supervisor:start_child(ejabberd_sup, ChildSpec),
    ejabberd_hooks:add(filter_packet, global, ?MODULE, on_filter_packet, 0),
    ?INFO_MSG("Starting mod_bot_relay filter.", []).

stop(Host) ->
    Proc = gen_mod:get_module_proc(Host, ?PROCNAME),
    gen_server:call(Proc, stop),
    supervisor:terminat_child(ejabberd_sup, Proc),
    superviser:delete_child(ejabberd_sup, Proc),
    ?INFO_MSG("Stoping mod_bot_relay", []).

get_really_from_name([_, _, _, _, {_, FromName}, _]) ->
        ?INFO_MSG("FromName: ~p", [FromName]),
        FromName;
get_really_from_name(Attrs) ->
    nil.

get_really_from_id([_, _, _, _, _, {_, FromID}]) ->
    ?INFO_MSG("FromID: ~p", [FromID]),
    FromID;
get_really_from_id(Attr) ->
    nil.

parse_really_from(RFrom) ->
    [UserName , Host | Tail] = string:tokens(RFrom, "@"),
    {UserName, Host}.

rewrite_from_packet(From, nil) ->
    From;
rewrite_from_packet({Jid, Name1, Host1, Ar1, Name2, Host2, Ar2} = From, RFrom) ->

    {RFromName, RFromHost} = parse_really_from(RFrom),
    ?INFO_MSG("ReallyFromName: ~p, ReallyFromHost: ~p.", [RFromName, RFromHost]),
    {Jid, RFromName, RFromHost, Ar1, RFromName, RFromHost, Ar2}.

%on_filter_packet({From, To, XML} = Packet) ->
on_filter_packet({From, To, {xmlelement, "message", Attrs, Els} = Packet} = Msg) ->

    ?INFO_MSG("Maybe really to: ~p", [length(Attrs)]),
    ?INFO_MSG("===Received Message Packet~n~p->~n~p~nAttrs:~p~nEls:~p", [From, To, Attrs, Els]),
    FromName = get_really_from_name(Attrs),
    FromID = get_really_from_id(Attrs),
    NewFrom = rewrite_from_packet(From, FromName),
    {NewFrom, To, {xmlelement, "message", Attrs, Els}};

%% Handle all non-message packets.
on_filter_packet(Packet) ->
    ?INFO_MSG("Received NonMessage packet.", []),
    Packet.

