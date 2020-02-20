defmodule Codex do
  @moduledoc """
  Documentation for `Codex`.

  This package might not be the best fit for your needs. Consider using things like [ueberauth](https://github.com/ueberauth/ueberauth)
  before, which have support for OAuth in general and many community built packages to add support for
  more specific needs (like Goodreads OAuth).

  The only advantage of this package is perhaps that it's not built on top of Phoenix and Plugs. But,
  for most cases, you probably will be using those. So, I strongly suggest you do consider those options
  first.
  """

  alias Codex.{HttpClient, OAuth}

  @doc """
  call a given endpoint using auth, passing the access token and access token secret.

  ## Args:

  * `endpoint` - the endpoint to call. No leading "/". e.g. "api/auth_user".
  * `token` - the access token previously obtained from Goodreads.
  * `token_secret` - the access token secret previously obtained from Goodreads.
  * `params` - (optional) a map with query params to pass to the endpoint. e.g. `%{"user_id" => "12345"}`
  """
  def signed_request(endpoint, token, token_secret, params \\ %{}) do
    headers = [{:Authorization, OAuth.generate_oauth_header(endpoint, token, token_secret, params)}]

    HttpClient.signed_get(endpoint, headers, params: params)
  end
end
