%Victor.Website{
  host: "localhost",
  scheme: :http,
  repo: %Victor.GitRepo{
    path: "/hugo-dev/hugo-docs/"
  },
  remote: %Victor.GitRemote{
    adapter: :github,
    url: "https://github.com/gohugoio/hugoDocs.git"
  }
}
|> Victor.Repo.insert!()
