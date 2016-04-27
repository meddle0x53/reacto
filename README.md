# Reacto

Reactive Programming for Ruby with some concurrency thrown into the mix!

## How to install?

If you use `bundler` just add this line to your `Gemfile`:

```ruby
gem 'reacto'
```

Alternatively you can instal the gem with `gem install reacto` or clone this
repository and play with it!

## Why?

Because it is very cool to be reactive these days!
Seriously - to be reactive means that your code is able to react on changes
happening in various places right away. For example third party data sources or
other parts of the code. It helps writing multy-component apps which could
handle failures and still be availale.

Of course there are other implemenations of reactive programming for ruby:

* [RxRuby](https://github.com/ReactiveX/RxRuby) : Very powerful implemenation
  of RX. Handles concurrency and as a whole has more features than `Reacto`.
  So why `Reacto`? `Reacto` has simpler interface it is native Ruby lib and
  is easier to use it. The goal of `Reacto` is to be competitor to `RxRuby`
  in the ruby world.
  Still the author of reacto is big fan of `RX` especially `RxJava`. He even has
  a book on the topic using `RxJava` :
  [Learning Reactive Programming with Java 8](https://www.packtpub.com/application-development/learning-reactive-programming-java-8)
* [Frappuccino](https://github.com/steveklabnik/frappuccino) : Very cool lib,
  easy to use and simply beautiful. The only drawback - it is a bit limitted :
  no concurrency and small set of operators.
  But if you don't need more complicated operators it is the best.
  The author of `Reacto` highy recommends it.

## Usage

### Simple Trackables

The main entry point to the lib is the `Reacto::Trackable` class.
It is something you can track for notifications. Usually A `Reacto::Trackable`
implemenation is pushing notifications to some notification tracker.
It depends on the source. We can have some remote streaming service as a source,
or an synchronous HTTP request or some process pushing updates to another.
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

This line attaches a notification tracker to the `trackable` - a lamda that
should be called when the `trackable` emits any value. This example is very
simple and the `trackable` emits only one value - `5` when a tracker is attached
to it so the lambda will be called and the value will be printed.

### Programming Trackable behaviour

A `Reacto::Trackable` can have custom behaviour, defining what and when should
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

When a tracker is atached this behaviour will become active and the tracker
will receive the first two sentences as values, then, after one second the third
one and then a closing notification.

