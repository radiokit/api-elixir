defmodule RadioKit.Data.Params do

  def encode_params({key, elements}) when is_list(elements) do
    Enum.map_join(elements, "&", &encode_param(&1, key))
  end

  def encode_params({key, value}) when not is_nil(value) do
    URI.encode("#{key}=#{value}")
  end

  def encode_params(keywords) when is_list(keywords) do
    Enum.map_join(keywords, "&", &encode_params/1)
  end

  def encode_params(_other), do: ""

  def encode_param(param, :s = key) do 
    URI.encode("#{key}[]=#{Enum.join(param, " ")}")
  end
  def encode_param({inner_key, params}, key) when is_list(params) do
    Enum.map_join(params, "&", fn({inner_inner_key, value}) ->
      URI.encode("#{key}[#{inner_key}][]=#{inner_inner_key} #{format_value(value)}")
    end)
  end

  def encode_param(param, key) do
    URI.encode("#{key}[]=#{param}")
  end

  def format_value(value) when is_list(value), do: Enum.join(value, " ")
  def format_value(value), do: value
end
