defmodule VictorWeb.Router do
  use VictorWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :notifications do
    plug(:accepts, ["html", "json"])
    plug(:put_secure_browser_headers)
  end

  pipeline :feature do
    plug(:accepts, ["html", "json"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:put_secure_browser_headers)
    plug(:authenticate)
  end

  pipeline :static_website do
    plug(VictorWeb.DetectWebsitePlug)
    plug(VictorWeb.StaticWebsitePlug)
    # plug to check if this website requires authentication goes here…
  end

  def authenticate(conn, _) do
    if authenticated?(conn) do
      conn
    else
      conn
      |> redirect(to: "/app/signin")
      |> halt()
    end
  end

  def authenticated?(_), do: false

  scope "/app", VictorWeb do
    pipe_through(:browser)

    get("/signin", AuthController, :signin)
    get("/signout", AuthController, :signout)
    get("/auth/callback", AuthController, :callback)
  end

  scope "/app", VictorWeb do
    pipe_through(:notifications)

    post("/deploy-notification", DeployController, :deploy)
  end

  scope "/app/editor", VictorWeb do
    pipe_through(:feature)

    get("/*anything", EditorController, :show)
    post("/", EditorController, :update)
  end

  scope "/", VictorWeb do
    pipe_through(:browser)
    pipe_through(:static_website)

    match(:*, "/*anything", PageController, :not_found)
  end
end
