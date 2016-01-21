-module(algolia_new_transport).

-export([make_request_builder/2]).

-define(readHosts, [
  "~s-dsn.algolia.net",
  "~s-1.algolianet.com",
  "~s-2.algolianet.com",
  "~s-3.algolianet.com"
]).

-define(writeHosts, [
  "~s.algolia.net",
  "~s-1.algolianet.com",
  "~s-2.algolianet.com",
  "~s-3.algolianet.com"
]).

make_request_builder(AppId, ApiKey) ->
  fun
    ({WhichHost, Method, Path}) ->
      build_request(AppId, ApiKey, WhichHost, Method, Path);
    ({WhichHost, Method, Path, Body}) ->
      build_request(AppId, ApiKey, WhichHost, Method, Path, Body)
    end.

build_request(AppId, ApiKey, WhichHost, Method, Path) ->
  Host = get_host(WhichHost, AppId),
  Url = lists:flatten(io_lib:format("https://~s~s", [Host, Path])),
  Headers = build_headers(AppId, ApiKey),
  [
    {method, Method},
    {url, Url},
    {headers, Headers}
  ].

build_request(AppId, ApiKey, WhichHost, Method, Path, Body) ->
  Request = build_request(AppId, ApiKey, WhichHost, Method, Path),
  EncodedBody = jiffy:encode(Body),
  lists:append(Request, [{body, EncodedBody}]).

get_host(read, AppId) ->
  [Host | _] = lists:map(
    fun(HostFormat) -> lists:flatten(io_lib:format(HostFormat, [AppId])) end,
    ?readHosts
  ),
  Host;
get_host(write, AppId) ->
  [Host | _ ] = lists:map(
    fun(HostFormat) -> lists:flatten(io_lib:format(HostFormat, [AppId])) end,
    ?writeHosts
  ),
  Host.

build_headers(AppId, ApiKey) ->
  [
    {"Content-Type", "application/json; charset=utf-8"},
    {"X-Algolia-Application-Id", AppId},
    {"X-Algolia-API-Key", ApiKey},
    {"Connection", "keep-alive"},
    {"User-Agent", "Algolia for Erlang"}
  ].
