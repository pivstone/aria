defmodule Accelerator do
  @moduledoc false
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children =
    if Mix.env != :test do
      [
        worker(Accelerator.Producer, []),
        worker(Accelerator.Comparator, []),
        worker(Accelerator.Downloader, [], id: 1),
      ]
    else
      []
    end
    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Accelerator]
    Supervisor.start_link(children, opts)
  end

end
