# Hedwig IRC Adapter
> An IRC adapter for [Hedwig](https://github.com/hedwig-im/hedwig), based
> on [ExIrc](https://github.com/bitwalker/exirc)

## Getting started

Let's generate a new Elixir application with a supervision tree:

```
λ mix new alfred --sup
* creating README.md
* creating .gitignore
* creating mix.exs
* creating config
* creating config/config.exs
* creating lib
* creating lib/alfred.ex
* creating test
* creating test/test_helper.exs
* creating test/alfred_test.exs

Your Mix project was created successfully.
You can use "mix" to compile it, test it, and more:

    cd alfred
    mix test

Run "mix help" for more commands.
```

Change into our new application directory:

```
λ cd alfred
```

Add `hedwig_irc` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
   {:hedwig_irc, "~> 0.1.0"}
  ]
end
```

Ensure `hedwig_irc` is started before your application:

```elixir
def application do
  [applications: [:hedwig_irc]]
end
```

### Generate our robot

```
λ mix deps.get
λ mix hedwig.gen.robot

Welcome to the Hedwig Robot Generator!

Let's get started.

What would you like to name your bot?: alfred

Available adapters

1. Hedwig.Adapters.IRC
2. Hedwig.Adapters.Console
3. Hedwig.Adapters.Test

Please select an adapter: 1

* creating lib/alfred
* creating lib/alfred/robot.ex
* updating config/config.exs

Don't forget to add your new robot to your supervision tree
(typically in lib/alfred.ex):

    worker(Alfred.Robot, [])
```

### Supervise our robot

We'll want Alfred to be supervised and started when we start our application.
Let's add it to our supervision tree. Open up `lib/alfred.ex` and add the
following to the `children` list:

```elixir
worker(Alfred.Robot, [])
```

### Configuration

The next thing we need to do is configure our bot for our IRC server. Open
up `config/config.exs` and let's take a look at what was generated for us:

```elixir
use Mix.Config

config :alfred, Alfred.Robot,
  adapter: Hedwig.Adapters.IRC,
  name: "alfred",
  aka: "/",
  responders: [
    {Hedwig.Responders.Help, []},
    {Hedwig.Responders.GreatSuccess, []},
    {Hedwig.Responders.ShipIt, []},
  ]
```

So we have the `adapter`, `name`, `aka`, and `responders` set. The `adapter` is
the module responsible for handling all of the IRC details like connecting
and sending and receiving messages over the network. The `name` is the name
that our bot will respond to, and _must not be used by any other account registered
or active on IRC_. The `aka` (also known as) field is optional, but it
allows us to address our bot with an alias. By default, this alias is set to
`/`; _we'll need to change that (since `/` is used by the IRC client), so
we'll use `!` instead_.

Finally we have `responders`. Responders are modules that provide functions that
match on the messages that get sent to our bot. We'll discuss this further in
a bit.

We'll need to provide a few more things in order for us to connect to our
IRC server. We'll need to provide our bot's `password`, the IRC `server` as well as
a list of rooms/channels we want our bot to join once connected.

Let's see what this could look like:

```elixir
use Mix.Config

config :alfred, Alfred.Robot,
  adapter: Hedwig.Adapters.IRC,
  name: "alfred",
  user: "alfred", # optional, defaults to `:name`
  full_name: "Alfred Bot", # optional, defaults to `:name`
  # we needed to change this, remember?
  aka: "!",
  # fill in the appropriate password for your bot
  password: "password",
  server: "chat.freenode.net",
  port: 6697, # optional, defaults to `6667`
  ssl?: true, # optional, defaults to `false`
  rooms: [
    # fill in the appropriate channels for your IRC server
    {"#elixir-lang", ""}
    {"#private-channel", "password-for-private-channel"}
  ],
  responders: [
    {Hedwig.Responders.Help, []},
    {Hedwig.Responders.GreatSuccess, []},
    {Hedwig.Responders.ShipIt, []}
  ]
```

Great! We're ready to start our bot. From the root of our application, let's run
the following:

```
λ mix run --no-halt
```

This will start our application along with our bot. Our bot should connect to
the server and join the configured room(s). From there, we can connect with our
favourite IRC client and begin sending messages to our bot.

Since we have the `Help` responder installed, we can say `alfred help` (or the
shorter version using our `aka`, `!help`) and we should see a list of usage for
all of the installed responders.

## What's next?

Well, that's it for now. Make sure to read the [Hedwig Documentation](http://hexdocs.pm/hedwig) for more
details on writing responders and other exciting things!

## LICENSE

Copyright (c) 2016 Jeff Weiss

Hedwig IRC source code is licensed under the [MIT License](https://github.com/jeffweiss/hedwig_irc/blob/master/LICENSE.md).
