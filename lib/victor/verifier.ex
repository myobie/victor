defmodule Victor.Verifier do
  def valid?(%{"email" => email}), do: String.ends_with?(email, "@microsoft.com")

  def valid?(_), do: false
end
