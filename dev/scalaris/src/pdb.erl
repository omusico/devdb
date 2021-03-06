%% @copyright 2010 Konrad-Zuse-Zentrum fuer Informationstechnik Berlin
%%            and onScale solutions GmbH

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

%% @author Florian Schintke <schintke@onscale.de>
%% @doc DB for a process internal state (lika a gen_component).
%% This abstraction allows for easy switching between
%% erlang:put/get/erase and ets:insert/lookup,delete
%% @end
%% @version $Id: pdb.erl 906 2010-07-23 14:09:20Z schuett $
-module(pdb).
-author('schintke@onscale.de').
-vsn('$Id: pdb.erl 906 2010-07-23 14:09:20Z schuett $').

-define(TRACE(X,Y), io:format(X,Y)).
%-define(TRACE(X,Y), ok).

-type tableid() :: atom().

-export([new/2, get/2, set/2, delete/2]).

%% put/get variant
-spec new(TableName::atom(), [set | ordered_set | bag | duplicate_bag |
                              public | protected | private |
                              named_table | {keypos, integer()} |
                              {heir, pid(), term()} | {heir,none} |
                              {write_concurrency, boolean()}]) -> tableid().
new(TableName, _Params) ->
    TableName.

-spec get(Key::term(), TableName::atom()) -> tuple() | undefined.
get(Key, _TableName) ->
    erlang:get(Key).

-spec set(Value::tuple(), TableName::atom()) -> ok.
set(NewTuple, _TableName) ->
    erlang:put(element(1,NewTuple), NewTuple),
    ok.

-spec delete(Key::term(), TableName::atom()) -> ok.
delete(Key, _TableName) ->
    erlang:erase(Key),
    ok.

%% %% ets variant (only for debugging! has performance issues with msg_delay)
%% -type tableid() :: tid() | atom().
%% new(TableName, Params) ->
%%     Name = ets:new(TableName, Params).
%% 
%% get(Key, TableName) ->
%%     case ets:lookup(TableName, Key) of
%%         [] -> undefined;
%%         [Entry] -> Entry
%%     end.
%% 
%% set(NewTuple, TableName) ->
%%     ets:insert(TableName, NewTuple),
%%     ok.
%% 
%% delete(Key, TableName) ->
%%     ets:delete(TableName, Key),
%%     ok.
