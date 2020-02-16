defmodule Codex.HttpClient do
  @moduledoc """
  Module that deals with the requests to the API.

  Uses HTTPoison.Base
  """

  use HTTPoison.Base
  alias Codex.Config

  @endpoint Config.api_url

  @doc """
  From HTTPoison.Base. Processes the given params.
  Adds the required api_key to the params.

  Args:

  * `params` - The params passed to the request.
  """
  def process_request_params(%{"signed" => true} = params) do
    Map.delete(params, "signed")
  end
  def process_request_params(params), do: Map.merge(params, %{key: get_api_key()})

  def process_url(endpoint) do
    @endpoint <> endpoint
  end

  @doc """
  Make a get request keeping the passed headers and opts without adding the API key to the params.
  Convenient for OAuth requests.

  ## Args:

  * `endpoint` - the endpoint to call.
  * `headers` - the headers, just like you would normally pass to a get request.
  * `opts` - (optional) the opts like you would pass to a request. Defaults to `[]`
  """
  def signed_get(endpoint, headers, opts \\ []) do
    get(
      endpoint,
      headers,
      Keyword.update(
        opts,
        :params,
        signed_request_param(),
        &(Map.merge(&1, signed_request_param()))
      )
    )
  end

  defp get_api_key, do: get_app_env(:api_key)

  defp get_app_env(key), do: Application.get_env(:codex, key)

  defp signed_request_param(), do: %{"signed" => true}
end
