% @copyright 2010 Konrad-Zuse-Zentrum fuer Informationstechnik Berlin

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

%%% @author Nico Kruber <kruber@zib.de>
%%% @doc    Unit tests for src/db_toke.erl.
%%% @end
%% @version $Id: db_toke_SUITE.erl 906 2010-07-23 14:09:20Z schuett $
-module(db_toke_SUITE).

-author('kruber@zib.de').
-vsn('$Id: db_toke_SUITE.erl 906 2010-07-23 14:09:20Z schuett $').

-compile(export_all).

-define(TEST_DB, db_toke).

-include("db_SUITE.hrl").

-ifdef(have_toke).
all() -> tests_avail().
-else.
all() -> [].
-endif.

%% @doc Specify how often a read/write suite can be executed in order not to
%%      hit a timeout (depending on the speed of the DB implementation).
-spec max_rw_tests_per_suite() -> pos_integer().
max_rw_tests_per_suite() ->
    100.
