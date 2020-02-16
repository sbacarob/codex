defmodule Codex.OAuth do
  @moduledoc """
  Handles OAuth related functionality for interaction with Goodreads API ONLY.

  You should not use this OAuth client to interact with other APIs, for it doesn't do endpoint
  discovery or anything like that. It's specifically written for Goodreads' API.
  """

  alias Codex.{Config, HttpClient}

  @doc """
  Get a Goodreads token and token secret.
  If signing goes well, returns `{:ok, tuple}` where tuple is a 2-element tuple containing the token and token secret.
  Otherwise, returns `{:error, reason}`.

  Your `API_KEY` and `API_SECRET` should be stored in your config, like:

  ```elixir
  config :codex,
    api_key: "YOUR_API_KEY",
    api_secret: "YOUR_API_SECRET"
  ```

  ## Examples

      iex> Codex.OAuth.get_request_token_and_secret()
      {:ok, %{"oauth_token" => "TOKEN", "oauth_token_secret" => "TOKEN_SECRET"}}

  > Notice that this just obtains a token and token secret from the Goodread's OAuth service. It doesn't
  store your token in any way or do anything else with it. You should do all your token storage and
  management logic yourself.
  """
  @spec get_request_token_and_secret() :: {:ok, map()} | {:error, String.t()}
  def get_request_token_and_secret() do
    endpoint = "oauth/request_token"
    headers = [{:Authorization, generate_oauth_header(endpoint)}]

    case HttpClient.signed_get(endpoint, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, extract_token_and_secret(body)}
      {:error, _} = err ->
        err
    end
  end

  @doc """
  Get the authorization url, provided an OAuth token and optionally a callback URL

  ## Args:

  * `token` - The OAuth token obtained from Goodreads. This can be obtained by using `Codex.OAuth.get_request_token_and_secret/2`
  * `callback_url` - Optional. A URL for your application for an endpoint to which the user should be redirected
  after giving your app permission.

  ## Examples:

      iex> Codex.OAuth.get_request_authorization_url("API_TOKEN")
      "https://www.goodreads.com/oauth/authorize?oauth_token=API_TOKEN"

      iex> Codex.OAuth.get_request_authorization_url("API_TOKEN", "https://myapp.com/goodreads_oauth_callback")
      "https://www.goodreads.com/oauth/authorize?oauth_token=API_TOKEN&oauth_callback=https://myapp.com/goodreads_oauth_callback"
  """
  def get_request_authorization_url(token, callback_url \\ nil)
  def get_request_authorization_url(token, nil), do: "#{Config.api_url()}oauth/authorize?oauth_token=#{token}"
  def get_request_authorization_url(token, callback_url) do
    "#{Config.api_url()}oauth/authorize?oauth_token=#{token}&oauth_callback=#{callback_url}"
  end

  @doc """
  Generate an Authorization header with a valid OAuth signature, taking the consumer key and secret
  from the config. You may optionally pass, a token, token secret and query params.

  ## Args:

  * `token` - (optional) a request token previously obtained from the OAuth service.
  * `token_secret` - (optional) a request token secret previously obtained from the OAuth service.
  * `params` - (optional) the query params from the request, as these need to be included in the signature.

  ## Examples:

      iex> Codex.OAuth.generate_oauth_header("oauth/request_token")
      "OAuth oauth_consumer_key=***,oauth_nonce=oHaBYEbXwtv7lWIoDkXMQT-I5iJThNliAls4vGDm,oauth_signature_method=HMAC-SHA1,oauth_timestamp=1581858006,oauth_token=***,oauth_version=1.0,oauth_signature=***"
  """
  def generate_oauth_header(endpoint, token \\ nil, token_secret \\ nil, params \\ %{}) do
    {key, secret} = get_goodreads_key_and_secret_from_config()

    key
    |> generate_oauth_data(token, params)
    |> generate_signature(endpoint, secret, token_secret)
    |> encode_header()
  end

  defp generate_oauth_data(key, token, params) do
    %{
      "oauth_consumer_key" => key,
      "oauth_nonce" => get_random_string(),
      "oauth_signature_method" => "HMAC-SHA1",
      "oauth_timestamp" => get_timestamp(),
      "oauth_token" => token,
      "oauth_version" => "1.0"
    }
    |> Map.merge(params)
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  defp generate_signature(params, endpoint, secret, token_secret) do

    encoded_params =
      params
      |> concatenate_params("&")
      |> URI.encode_www_form()

    base_string = "GET&#{URI.encode_www_form(full_url(endpoint))}&#{encoded_params}"

    {params, sign(base_string, "#{secret}&#{token_secret}")}
  end

  defp encode_header({params, signature}) do
    oauth_data =
      params
      |> Map.take(oauth_params_list())
      |> concatenate_params(",")

    "OAuth #{oauth_data},oauth_signature=#{signature}"
  end

  defp get_random_string() do
    40
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64
    |> binary_part(0, 40)
  end

  defp get_timestamp(), do: DateTime.utc_now() |> DateTime.to_unix()

  defp concatenate_params(params, joiner) do
    params
    |> Enum.sort_by(fn {k, _v} -> k end)
    |> Enum.reduce("", fn
      {k, v}, "" ->
        "#{k}=#{v}"
      {k, v}, acc ->
        "#{acc}#{joiner}#{k}=#{v}"
    end)
  end

  defp full_url(endpoint), do: Config.api_url() <> endpoint

  defp sign(text, key) do
    :sha
    |> :crypto.hmac(key, text)
    |> Base.encode64()
  end

  defp extract_token_and_secret(body) do
    for pair <- String.split(body, "&"),
        [key, value] = String.split(pair, "="),
        into: %{},
        do: {key, value}
  end

  defp get_goodreads_key_and_secret_from_config() do
    {Application.get_env(:codex, :api_key), Application.get_env(:codex, :api_secret)}
  end

  defp oauth_params_list do
    [
      "oauth_consumer_key",
      "oauth_nonce",
      "oauth_signature_method",
      "oauth_timestamp",
      "oauth_token",
      "oauth_version"
    ]
  end
end
