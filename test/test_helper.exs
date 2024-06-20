ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Rate.Repo, :manual)

# MOCKS
Mox.defmock(ClientMock, for: Rate.Xchange.Behaviour)
