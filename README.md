# Reacto

Reactive Programming for Ruby with some concurrency thrown into the mix!

## How to install?

If you use `bundler` just add this line to your `Gemfile`:

```ruby
gem 'reacto'
```

Alternatively you can install the gem with `gem install reacto` or clone this
repository and play with it!

## Why?

Because it is very cool to be reactive these days!
Seriously - to be reactive means that your code is able to react on changes
happening in various places right away. For example third party data sources or
other parts of the code. It helps writing multi-component apps which could
handle failures and still be available.

Of course there are other implementations of reactive programming for ruby:

* [RxRuby](https://github.com/ReactiveX/RxRuby) : Very powerful implementation
  of RX. Handles concurrency and as a whole has more features than `Reacto`.
  So why `Reacto`? `Reacto` has simpler interface it is native Ruby lib and
  is easier to use it. The goal of `Reacto` is to be competitor to `RxRuby`
  in the ruby world.
  Still the author of Reacto is big fan of `RX` especially `RxJava`. He even has
  a book on the topic using `RxJava` :
  [Learning Reactive Programming with Java 8](https://www.packtpub.com/application-development/learning-reactive-programming-java-8)
* [Frappuccino](https://github.com/steveklabnik/frappuccino) : Very cool lib,
  easy to use and simply beautiful. The only drawback - it is a bit limited :
  no concurrency and small set of operators.
  But if you don't need more complicated operators it is the best.
  The author of `Reacto` highly recommends it.

## Usage

### Simple Trackables

The main entry point to the lib is the `Reacto::Trackable` class.
It is something you can track for notifications. Usually A `Reacto::Trackable`
implemenation is pushing notifications to some notification tracker.
It depends on the source. We can have some remote streaming service as a source,
or an asynchronous HTTP request or some process pushing updates to another.

#### value

Of course the source can be very simple, for example a single value:

```ruby
  trackable = Reacto::Trackable.value(5)
```

This value won't be emitted as notification until there is no tracker (listener)
attached to the `trackable` - so this `trackable` instance is lazy - won't do
anything until necessary.

```ruby
  trackable.on(value: ->(v) { puts v })

  # => 5
```

This line attaches a notification tracker to the `trackable` - a lambda that
should be called when the `trackable` emits any value. This example is very
simple and the `trackable` emits only one value - `5` when a tracker is attached
to it so the lambda will be called and the value will be printed.

#### enumerable

Another example is `Trackable` with source an Enumerable instance:

```ruby
  trackable = Reacto::Trackable.enumerable([1, 3, 4])
```

Again we'll have to call `on` on it in order to push its values to the tracker
function.

#### never

It is possible that a Trackable which never emits anything is needed. Some
operations behave according to Trackable instances returned, so a way to have
such a Trackable is:

```ruby
  trackable = Reacto::Trackable.never
```


### Programming Trackable behavior

A `Reacto::Trackable` can have custom behavior, defining what and when should
be sent:

```ruby
  trackable = Reacto::Trackable.make do |tracker|
    tracker.on_value('You say yes')
    tracker.on_value('I say no')

    sleep 1
    tracker.on_value('You say stop and I say go go go, oh no')
    tracker.on_close
  end
```

When a tracker is attached this behavior will become active and the tracker
will receive the first two sentences as values, then, after one second the third
one and then a closing notification.

Every time a tracker is attached with call to `on`, this behavior will be
executed for the given tracker. If we want to have a shared behavior for all
the trackers we can create a `Reacto::SharedTrackable` instance:

```ruby

require 'socket'

trackable = Reacto::SharedTrackable.make do |subscriber|
  hostname = 'localhost'
  port = 3555

  return unless subscriber.subscribed?

  socket = nil
  begin
    socket = TCPSocket.open(hostname, port)

    while line = socket.gets
      break unless subscriber.subscribed?

      subscriber.on_value(line)
    end

    subscriber.on_close if subscriber.subscribed?
  rescue StandardError => error
    subscriber.on_error(error) if subscriber.subscribed?
  ensure
    socket.close unless socket.nil?
  end

end

trackable.on(value: -> (v) { puts v })
trackable.on do |v|
  puts v
end

# The above calls of `on` are identical. And the two will the same data.
# Nothing happens on calling `on` though, the `trackable` has to be activated:

trackable.activate!

```
