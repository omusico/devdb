{application, riakc,
 [{description, "Riak Client"},
  {vsn, "0.2.0"},
  {modules, [
             riakc_pb,
             riakc_pb_socket,
             riakc_obj,
             riakclient_pb
            ]},
  {applications, [
                  kernel,
                  stdlib
                 ]},
  {registered, []},
  {env, []}
 ]}.

