# Poke

_In the spirit of Basic's poke/peek, a rack-based web server._

## Install

Clone this here repo, cd into there, and

```
bundle install
```

and then

```
bundle exec rake env:hydrate:development
```

and FINALLY

```
rake
```

Your perserverance will be rewarded.

## Usage

Poke:

```
curl --data "Hello World" http://localhost:9995/this/thing/here
```

And peek:

```
curl http://localhost:9995/this/thing/here
#=> "Hello World"
```

Whatsoever `Content-Type` header you use when poking, the same also shall be returned to you
when peeking the same location.

## Configure

Take a look at `config/thin.yml` and `config/server.ru`.  Go wild.

## One More Thing

Poke also uses a middleware called `Poke::About` which exists for the purpose of
providing a dab of human-browserable info about **Poke** in general, and perhaps
your Poke server in particular.  As such the paths `/` and `/about` are special.

A GET to those paths will return the informational message/page, etc.  A POST
to those paths will get you a 405 right in the teeth.  No exceptions.
