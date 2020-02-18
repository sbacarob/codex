![Elixir CI](https://github.com/sbacarob/codex/workflows/Elixir%20CI/badge.svg) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# Codex

Elixir Wrapper for Goodreads API.

## Installation

Add the package to your dependencies:

```elixir
def deps do
  [
    {:codex, github: "https://github.com/sbacarob/codex.git"}
  ]
end
```

Then in your `config.exs` include your API key and secret:

```elixir
config :codex,
  api_key: "YOUR_API_KEY",
  api_secret: "YOUR_API_SECRET"
```

## Basic Usage

If you don't intend to use the OAuth protected endpoints, you can just call any of them
directly using Codex.HttpClient.

For instance, to get info about an author, you would call the `author/show/:id` endpoint. Like:

``` elixir
iex> Codex.HttpClient.get("author/show/18541", [], params: %{"format" => "xml"})
```

> Here, `18541` would be the author id. As you can see, you don't need to pass the full
Goodreads path or the api key in the parameters. This is added from your configuration.

## Authorization process

If you do intend to use the OAuth protected endpoints, there are a series of steps you would need to follow to be able to do so:

1. Get an initial request token:
```elixir
iex> Codex.OAuth.get_request_token_and_secret()
{:ok, %{"oauth_token" => "REQUEST_TOKEN", "oauth_token_secret" => "REQUEST_TOKEN_SECRET"}}
```

2. Once you have that, you can generate an authorization URL passing in the token:
```elixir
iex> Codex.OAuth.get_request_authorization_url("REQUEST_TOKEN")
"https://www.goodreads.com/oauth/authorize?oauth_token=REQUEST_TOKEN"
```
> You can optionally pass a callback URL as the second argument, so that after granting or denying access, your users would be redirected there.

3. Then, you can exchange the request token and secret for an access token and secret:
```elixir
iex> Codex.OAuth.get_access_token_and_secret("REQUEST_TOKEN", "REQUEST_TOKEN_SECRET")
{:ok, %{"oauth_token" => "ACCESS_TOKEN", "oauth_token_secret" => "REQUEST_TOKEN_SECRET"}}
```

4. Finally, you can make requests to the OAuth protected endpoints using the access token and secret. For instance, to get the user who has allowed the application access, you would call the `api/auth_user` endpoint:
```elixir
iex> Codex.signed_request("api/auth_user", "ACCESS_TOKEN", "ACCESS_TOKEN_SECRET")
{:ok,
 "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<GoodreadsResponse>\n  <Request>\n    <authentication>true</authentication>\n      <key><![CDATA[YOUR_API_KEY]]></key>\n    <method><![CDATA[api_auth_user]]></method>\n  </Request>\n  <user id=\"91535552\">\n  <name>Santiago Bacaro</name>\n  <link><![CDATA[https://www.goodreads.com/user/show/91535552-santiago-bacaro?utm_medium=api]]></link>\n</user>\n\n</GoodreadsResponse>"}
```
> You don't need to pass the whole URL or the API key here either. The result will contain the raw response produced by Goodreads. Parsers haven't been added yet.