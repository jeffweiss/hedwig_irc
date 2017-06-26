defmodule Hedwig.Adapters.IRC do
  @moduledoc false

  use Hedwig.Adapter
  require Logger

  def init({robot, opts}) do
    Logger.debug "#{inspect opts}"
    {:ok, client} = ExIrc.start_client!
    ExIrc.Client.add_handler client, self()
    Kernel.send(self(), :connect)
    {:ok, {robot, opts, client}}
  end

  def handle_cast({:send, %{text: text, room: channel}}, state = {_robot, _opts, client}) do
    for line <- String.split(text, "\n") do
      ExIrc.Client.msg client, :privmsg, channel, line
    end
    {:noreply, state}
  end

  def handle_cast({:reply, %{text: text, user: user, room: channel}}, state = {_robot, _opts, client}) do
    ExIrc.Client.msg client, :privmsg, channel, user <> ": " <> text
    {:noreply, state}
  end

  def handle_cast({:emote, %{text: text, room: channel}}, state = {_robot, _opts, client}) do
    ExIrc.Client.me client, channel, text
    {:noreply, state}
  end

  def handle_info(:connect, state = {_robot, opts, client}) do
    host = Keyword.fetch!(opts, :server)
    port = Keyword.get(opts, :port, 6667)
    ssl? = Keyword.get(opts, :ssl?, false)
    if ssl? do
      ExIrc.Client.connect_ssl! client, host, port
    else
      ExIrc.Client.connect! client, host, port
    end
    {:noreply, state}
  end

  def handle_info({:connected, server, port}, state = {_robot, opts, client}) do
    Logger.info "Connected to #{server}:#{port}"
    pass = Keyword.fetch!(opts, :password)
    nick = Keyword.fetch!(opts, :name)
    user = Keyword.get(opts, :user, nick)
    name = Keyword.get(opts, :full_name, nick)
    ExIrc.Client.logon client, pass, nick, user, name
    {:noreply, state}
  end

  def handle_info(:logged_in, state = {_robot, opts, client}) do
    Logger.info "Logged in"
    rooms = Keyword.fetch!(opts, :rooms)
    for {channel, password} <- rooms do
      ExIrc.Client.join client, channel, password
    end
    {:noreply, state}
  end

  def handle_info({:received, msg, %{nick: user}, channel}, state = {robot, _opts, _client}) do
    incoming_message =
      %Hedwig.Message{
        ref: make_ref(),
        room: channel,
        text: msg,
        user: user,
        type: "groupchat"
      }
    Hedwig.Robot.handle_in(incoming_message, robot)

    {:noreply, state}
  end
  def handle_info({:received, msg, user, channel}, state = {robot, _opts, _client}) when is_binary(user) do
    incoming_message =
      %Hedwig.Message{
        ref: make_ref(),
        room: channel,
        text: msg,
        user: user,
        type: "groupchat"
      }
    Hedwig.Robot.handle_in(incoming_message, robot)

    {:noreply, state}
  end

  def handle_info({:quit, message, %{nick: user}}, state) do
    Logger.info "#{user} left with message: #{inspect message}"
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.debug "Unknown message: #{inspect msg}"
    {:noreply, state}
  end
end
