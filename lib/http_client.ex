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

  * `params` - The params that come from the request.
  """
  # def process_request_params(params), do: Map.merge(params, %{key: get_api_key()})

  def process_url(endpoint) do
    @endpoint <> endpoint
  end

  defp get_api_key, do: get_app_env(:api_key)

  defp get_app_env(key), do: Application.get_env(:codex, key)
end
