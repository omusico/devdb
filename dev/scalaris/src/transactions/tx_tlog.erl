% @copyright 2009, 2010 onScale solutions GmbH

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

% @author Florian Schintke <schintke@onscale.de>
% @doc operations on the end user transaction log
% @version $Id: tx_tlog.erl 906 2010-07-23 14:09:20Z schuett $
-module(tx_tlog).
-author('schintke@onscale.de').
-vsn('$Id: tx_tlog.erl 906 2010-07-23 14:09:20Z schuett $').

%-include("trecords.hrl").

%% Operations on TransLogs
-export([empty/0]).
-export([add_entry/2]).
-export([filter_by_key/2]).
-export([filter_by_status/2]).
-export([update_entry/4]).

%% Operations on entries of TransLogs
-export([new_entry/5]).
-export([get_entry_operation/1]).
-export([get_entry_key/1]).
-export([get_entry_status/1]).
-export([get_entry_value/1]).
-export([get_entry_version/1]).
-export([get_entry_as_tm_item/1]).

%% TranslogEntry: {Operation, Key, Status, Value, Version}
%% Sample: {read,"key3",ok,"value3",0}

% @doc create an empty list
empty() -> [].

add_entry(TransLog, Entry) ->
    [ Entry | TransLog ].

filter_by_key(TransLog, Key) ->
    [ X || X <- TransLog, Key =:= get_entry_key(X) ].

filter_by_status(TransLog, Status) ->
    [ X || X <- TransLog, Status =:= get_entry_status(X) ].

update_entry(TransLog, {read,LogKey,LogSuccess,_,LogVers} = Element,
             write, Value) ->
    UnchangedPart = lists:delete(Element, TransLog),
    add_entry(UnchangedPart,
              new_entry(write, LogKey, LogSuccess, Value, LogVers + 1));

update_entry(TransLog, {write,LogKey,LogSuccess,_,LogVers} = Element,
             write, Value) ->
    UnchangedPart = lists:delete(Element, TransLog),
    add_entry(UnchangedPart,
              new_entry(write, LogKey, LogSuccess, Value, LogVers));

update_entry(TransLog, Key, write, Value) ->
    [Element] = filter_by_key(TransLog, Key),
    update_entry(TransLog, Element, write, Value).


%% Operations on Elements of TransLogs
new_entry(Op, Key, Status, Val, Vers) ->
    {Op, Key, Status, Val, Vers}.
get_entry_operation(Element) ->
    erlang:element(1, Element).
get_entry_key(Element) ->
    erlang:element(2, Element).
get_entry_status(Element) ->
    erlang:element(3, Element).
get_entry_value(Element) ->
    erlang:element(4, Element).
get_entry_version(Element) ->
    erlang:element(5, Element).
get_entry_as_tm_item(Element) ->
    trecords:new_tm_item(get_entry_key(Element),
                         get_entry_value(Element),
                         get_entry_version(Element),
                         get_entry_operation(Element)).
