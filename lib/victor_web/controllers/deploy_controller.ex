defmodule VictorWeb.DeployController do
  use VictorWeb, :controller

  def deploy(conn, _params) do
    Task.async(Victor.Hugo, :deploy, [])
    text conn, "thanks"
  end
end
