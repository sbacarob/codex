defmodule Codex.OAuth do
  @base_url "https://www.goodreads.com/oauth"

  def get_request_token_and_secret(key, secret) do
    headers = [{:Authorization, generate_oauth_header(key, secret)}]

    case Codex.HttpClient.get("oauth/request_token", headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        extract_token_and_secret(body)
      {:error, _} = err ->
        err
    end
  end

  def get_request_authorization_url(token) do
    @base_url <> "/authorize"
  end

  defp generate_oauth_header(key, secret) do
    key
    |> generate_oauth_data()
    |> generate_signature(secret)
    |> encode_header()
  end

  defp generate_oauth_data(key) do
    %{
      "oauth_consumer_key" => key,
      "oauth_nonce" => get_random_string(),
      "oauth_signature_method" => "HMAC-SHA1",
      "oauth_timestamp" => get_timestamp()
    }
  end

  defp generate_signature(params, secret) do
    encoded_params =
      params
      |> concatenate_params("&")
      |> URI.encode_www_form()

    base_string = "GET&#{URI.encode_www_form(request_token_url())}&#{encoded_params}"

    {params, sign(base_string, secret <> "&")}
  end

  defp encode_header({params, signature}) do
    oauth_data = concatenate_params(params, ",")

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

  defp request_token_url(), do: @base_url <> "/request_token"

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
end
