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


#### error

If we want to emit only an error notification we can do it with `Trackable.error`,
it works the same way as `Trackable.value`, but the notification is of type
`error`:

```ruby
  trackable = Reacto::Trackable.error(StandardError.new('Some error!'))

  trackable.on(error: ->(e) { raise e })
```

#### close

There is a way to create a `Reacto::Trackable` emitting only close notification
too:

```ruby
  trackable = Reacto::Trackable.error(StandardError.new('Some error!'))

  trackable.on(close: ->() { p 'closed' })
```

#### enumerable

Another example is `Trackable` with source an Enumerable instance:

```ruby
  trackable = Reacto::Trackable.enumerable([1, 3, 4])
```

Again we'll have to call `on` on it in order to push its values to the tracker
function.

#### interval

A neat way to create `Trackable` emitting the values of some Enumerable on
every second, for example is `Reacto::Trackable.interval`:

```ruby
  trackable = described_class.interval(0.3)
```

This one emits the natural number (1..N) on every _0.3_ seconds.
The second argument can be an `Enumerator` - limited or unlimited, for example:

```ruby
  trackable = described_class.interval(2, ('a'..'z').each)
```

Emits the letters _a to z_ on every two seconds. We can create a custom
enumerator and use it.

#### never

It is possible that a Trackable which never emits anything is needed. Some
operations behave according to Trackable instances returned, so a way to have
such a Trackable is:

```ruby
  trackable = Reacto::Trackable.never
```


### Programming Trackable behavior

#### make

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

#### SharedTrackable

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

### Tracking for notifications

#### on

The easiest way to listen a `Reacto::Trackable` is to call `#on` on it:

```ruby
  consumer = -> (value) do
    # Consume the incoming value
  end

  trackable.on(value: consumer)
```

Calling it like that will trigger the behaviour of the `trackable` and
all the values it emits, will be passed to the consumer. A block can be passed
to `#on` and it will have the same effect:

```ruby
  trackable.on do |value|
    # Consume the incoming value
  end
```

If we want to fetch an error we can call `#on` like that:

```ruby
  error_consumer = -> (error) do
    # Consume the incoming error
  end

  trackable.on(error: error_consumer)
```

Only one error can be emitted by a `Trackable` for subscription and that will
close the `Reacto::Trackable`. If there is no error, the normal closing
notification should be emitted. We can fetch it like this:

```ruby
  to_be_called_on_close = -> () do
    # Fnalize?
  end

  trackable.on(close: to_be_called_on_cloe)
```

#### track

Under the hood `#on` creates a new `Reacto::Tracker` instance with the right
methods. If we want to create our own tracker, we can always call `#track` on
the trackable with the given instance:

```ruby
  consumer = -> (value) do
    # Consume the incoming value
  end
  error_consumer = -> (error) do
    # Consume the incoming error
  end

  trackable.track(Reacto::Trackable.new(
    value: consumer, error: error_consumer, close: -> () { p 'Closing!' }
  ))
```

All of these keyword parameters have default values - for example if we don't
pass a `value:` action, a _no-action_ will be used, doing nothing with the
value, the same is right about not passing `close:` action. Be aware that
the default `error:` action is raising the error.


### Subscriptions

Calling `#on` or `#track` will create and return a `Reacto::Subscription`.
We can unsubscribe form the `Trackable` with it by calling `#unsubscribe`:


```ruby
  subscription = trackable.on(value: consumer)

  subscription.unsubscribe
```

This way our notification tracker won't receive notification any more.
Checking if a `Subscription` is subscribed can be done by calling `subscribed?`
on it.

```ruby
  subscription = trackable.on(value: consumer)

  subscription.subscribed? # true
```

Subscriptions can be used for other things, adding additional subscriptions
to them, adding resources, which should be closed on receiving the `close`
notification and waiting for trackable operating on background to finish.

### Operations

Operations are methods which can be invoked on a `Reacto::Trackable` instance,
and always return a new `Reacto::Trackable` instance. The new trackable has
emits all or some of the notifications of the source, somewhat changed by
the operation. Let's look at an example:

#### map

The `map` operation is a transformation, it transforms every
value (and not only), emitted by the source using the _block_ given.

```ruby
  source_trackable = Reacto::Trackable.enumerable((1..100))

  trackable = source_trackable.map do |value|
    value - 1
  end

  trackable.on(value: -> (val) { puts val })
  # the numbers from 0 to 99 will be printed
```

The `map` operation is able to transform errors as well, it can transform
the stream of notifications itself and add new notification before the
close notification for example.

#### select

The `select` operation filters values using a predicate block:

```ruby
  source_trackable = Reacto::Trackable.enumerable((1..100))

  trackable = source_trackable.select do |value|
    value % 5 == 0
  end

  trackable.on(value: -> (val) { puts val })
  # the numbers printed will be 5, 10, 15, ... 95, 100
```

There are more filtering operations - `drop`, `skip`, `first`, `last`, etc.
Look at the specs for examples of them.

## Tested with rubies

 * Ruby 2.0.0+
 * JRuby 9.1.2.0
