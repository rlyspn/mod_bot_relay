-module(mod_bot_relay).
-author("Riley Spahn").

%% Behavior for a module
-include("ejabberd.hrl").
-behavior(gen_mod).
-behavior(gen_server).

-export([start_link/2]).
-export([
        start/2,
        stop/1,
        init/1,
        handle_call/3,
        handle_cast/2,
        handle_info/2,
        terminate/2,
        code_change/3
    ]).

-define(BOTNAME, mod_bot_relay).
-define(PROCNAME, ejabberd_mod_bot_relay).

%% Start the server.
start_link(_Host, _Opts) ->
    Proc = gen_mod:get_module_proc(_Host, ?PROCNAME),
    gen_server:start_link({local, Proc}, ?MODULE,
        [_Host, _Opts], []),
    ?INFO_MSG("Starting link: mod_bot_relay", []).

start(_Host, _Opts) ->
    Proc = gen_mod:get_module_proc(_Host, ?PROCNAME),
    ChildSpec = {Proc, {?MODULE, start_link, [_Host, _Opts]}, temporary,
        1000, worker, [?MODULE]},
    supervisor:start_child(ejabberd_sup, ChildSpec),

    ?INFO_MSG("Starting mod_bot_relay", []),
    ok.

stop(_Host) ->
    Proc = gen_mod:get_module_proc(_Host, ?PROCNAME),
    gen_server:call(Proc, stop),
    supervisor:terminat_child(ejabberd_sup, Proc),
    superviser:delete_child(ejabberd_sup, Proc),
    ?INFO_MSG("Stoping mod_bot_relay", []),
    ok.

init([Host, Opts]) ->
    _Host = gen_mod:get_opt_host(Host, Opts, "@HOST@"),
    ejabberd_router:register_route(_Host, {apply, ?MODULE, route}),
    ?DEBUG("Initializing mod_relay_bot.", []),
    {ok, Host}.

% Boilerplate
handle_call(stop, _From, _Host) ->
    {stop, normal, ok, _Host}.

handle_cast(_Msg, _Host) ->
    {noreplay, _Host}.

handle_info(_Msg, _Host) ->
    {noreplay, _Host}.

terminate(_Reason, _Host) ->
    ejabberd_route:unregister_route(_Host),
    ok.

code_change(_OldVersion, Host, _Extra) ->
    {ok, Host}.

% Routing Below
%% Presence Routing
route(From, To, {xmlelement, "presence", _, _} = Packet) ->
    case xml:get_tag_attr_s("type", Packet) of
        _ ->
            ?INFO_MSG("Presence Packet: ~p", [Packet])
    end,
    ok;
route(From, To, {xmlelement, "message", _, _} = Packet) ->
    case xml:get_subtag_cdata(Packet, "body") of
        "" -> ok;
        Body ->
            case xml:get_tag_attr_s("type", Packet) of
                "chat"  -> ?INFO_MSG("Received message To: ~p, From: ~p, Body: ~p.\n", [To, From, Body]);
                "error" -> ?ERROR_MSG("Received an error message.\n", []);
                _       -> ?INFO_MSG("Received message To: ~p, From: ~p, Body: ~p.\n", [To, From, Body])
        end
    end,
    ok.
