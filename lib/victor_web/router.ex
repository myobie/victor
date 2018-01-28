defmodule VictorWeb.Router do
  use VictorWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(VictorWeb.DetectWebsitePlug)
  end

  pipeline :notifications do
    plug(:accepts, ["html", "json"])
    plug(:put_secure_browser_headers)
    plug(VictorWeb.DetectWebsitePlug)
  end

  pipeline :editor do
    plug(:accepts, ["html", "json"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:put_secure_browser_headers)
    plug(VictorWeb.DetectWebsitePlug)
    plug(VictorWeb.RequireAuthenticatedUserPlug, :editor)
  end

  pipeline :static_website do
    plug(VictorWeb.StaticWebsitePlug)
    plug(VictorWeb.RequireAuthenticatedUserPlug, :visitor)
  end

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
    pipe_through(:editor)

    get("/*anything", EditorController, :show)
    post("/", EditorController, :update)
  end

  scope "/", VictorWeb do
    pipe_through(:browser)
    pipe_through(:static_website)

    match(:*, "/*anything", PageController, :not_found)
  end
end
