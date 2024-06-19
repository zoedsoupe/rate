alias Rate.Accounts.User
alias Rate.Repo

Repo.insert!(%User{email: "john@example.com", external_id: Ecto.UUID.generate()})
