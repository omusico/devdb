%  @copyright 2007-2010 Konrad-Zuse-Zentrum fuer Informationstechnik Berlin

%   Licensed under the Apache License, Version 2.0 (the "License");
%   you may not use this file except in compliance with the License.
%   You may obtain a copy of the License at
%
%       http://www.apache.org/licenses/LICENSE-2.0
%
%   Unless required by applicable law or agreed to in writing, software
%   distributed under the License is distributed on an "AS IS" BASIS,
%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%   See the License for the specific language governing permissions and
%   limitations under the License.

%% @author Thorsten Schuett <schuett@zib.de>
%% @doc Stores the key for the dht_node process.
%%
%%  This process stores the identifier of the dht_node. If the dht_node is 
%%  restarted his identifier will survive in this process. We could use 
%%  this e.g. when doing load-blancing.
%% @end
%% @version $Id: idholder.erl 953 2010-08-03 13:52:39Z kruber@zib.de $
-module(idholder).
-author('schuett@zib.de').
-vsn('$Id: idholder.erl 953 2010-08-03 13:52:39Z kruber@zib.de $').

-behaviour(gen_component).

-include("scalaris.hrl").

-export([start_link/2, init/1, on/2, set_id/2, get_id/0, reinit/0,
         check_config/0]).

-type(message() ::
    {reinit} |
    {get_id, PID::pid()} |
    {set_id, NewId::?RT:key(), NewIdVersion::non_neg_integer()}).
-type(state() :: {Id::?RT:key(), IdVersion::non_neg_integer()}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Public API
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% @doc Sets the key of the dht_node including the counter that states how often
%%      a DHT node's ID changed (the version of the ID).
-spec set_id(NewId::?RT:key(), NewIdVersion::non_neg_integer()) -> ok.
set_id(NewId, NewIdVersion) ->
    comm:send_local(get_pid(), {set_id, NewId, NewIdVersion}).

%% @doc Reads the key of the dht_node; sends a 'idholder_get_id_response'
%%      message in response.
-spec get_id() -> ok.
get_id() ->
    comm:send_local(get_pid(), {get_id, self()}).

%% @doc Starts the idholder process, registers it with the process dictionary
%%      and returns its pid for use by a supervisor.
-spec start_link(instanceid(), list(tuple())) -> {ok, pid()}.
start_link(InstanceId, Options) ->
    gen_component:start_link(?MODULE, Options, [{register, InstanceId, idholder}]).

%% @doc Resets the key to a random key and a counter of 0.
%%      Warning: This effectively states that a newly created DHT node is
%%      unrelated to the old one and should only be used if the old DHT node is
%%      stopped.
-spec reinit() -> ok.
reinit() ->
    comm:send_local(get_pid(), {reinit}).

%% @doc Checks whether config parameters of the idholder process exist and are
%%      valid.
-spec check_config() -> boolean().
check_config() ->
    config:is_in(key_creator, [random, random_with_bit_mask]) and
        case config:read(key_creator) of
            random -> true;
            random_with_bit_mask ->
                config:is_tuple(key_creator_bitmask, 2,
                                fun({Mask1, Mask2}) ->
                                        erlang:is_integer(Mask1) andalso
                                            erlang:is_integer(Mask2) end,
                                "{int(), int()}")
        end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Server process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% userdevguide-begin gen_component:sample
%% @doc Initialises the idholder with a random key and a counter of 0.
-spec init([]) -> state().
init(Options) ->
    case lists:keyfind({idholder, id}, 1, Options) of
        {{idholder, id}, Id} -> {Id, 0};
        _ -> {get_initial_key(config:read(key_creator)), 0}
    end.

-spec on(message(), state()) -> state().
on({reinit}, _State) ->
    {get_initial_key(config:read(key_creator)), 0};
on({get_id, PID}, {Id, IdVersion} = State) ->
    comm:send_local(PID, {idholder_get_id_response, Id, IdVersion}),
    State;
on({set_id, NewId, NewIdVersion}, _State) ->
    {NewId, NewIdVersion}.
%% userdevguide-end gen_component:sample

%% @doc Gets the pid of the idholder process in the same group as the calling
%%      process.
-spec get_pid() -> pid() | failed.
get_pid() ->
    process_dictionary:get_group_member(idholder).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Key creation algorithms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-spec get_initial_key(random | random_with_bit_mask) -> ?RT:key().
get_initial_key(random) ->
    ?RT:get_random_node_id();
get_initial_key(random_with_bit_mask) ->
    {Mask1, Mask2} = config:read(key_creator_bitmask),
    (get_initial_key(random) band Mask2) bor Mask1.
