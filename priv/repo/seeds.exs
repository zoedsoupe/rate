alias Rate.Accounts.User
alias Rate.Repo
alias Rate.Transactions.Transaction

user = Repo.insert!(%User{email: "john@example.com", external_id: Ecto.UUID.generate()})

Repo.insert!(%Transaction{
  from_amount: 100_00,
  from_currency: "BRL",
  to_currency: "EUR",
  conversion_rate: 6.4,
  external_id: Ecto.UUID.generate(),
  user_id: user.id
})

Repo.insert!(%Transaction{
  from_amount: 50_00,
  from_currency: "BRL",
  to_currency: "USD",
  conversion_rate: 5.2,
  external_id: Ecto.UUID.generate(),
  user_id: user.id
})
