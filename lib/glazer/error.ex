defmodule Glazer.ParseError do
  defexception [:message]

  @impl true
  def exception(opts) when is_list(opts) do
    msg = Keyword.get(opts, :message, "parse error")
    %__MODULE__{message: msg}
  end
end
