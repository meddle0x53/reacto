# Reacto

Reactive Programming for Ruby with some concurrency thrown into the mix!

[![Gem Version](https://badge.fury.io/rb/reacto.svg)](https://badge.fury.io/rb/reacto)

#Table of Contents

  * [How to install?](#how-to-install)
  * [Why?](#why)
  * [Usage](#usage)
    * [Simple Trackables](#simple-trackables)
      * [value](#value)
      * [error](#error)
      * [close](#close)
      * [enumerable](#enumerable)
      * [interval](#interval)
      * [never](#never)
    * [Programming Trackable behavior](#programming-trackable-behavior)
      * [make](#make)
      * [SharedTrackable](#sharedtrackable)
    * [Tracking for notifications](#tracking-for-notifications)
      * [on](#on)
      * [track](#track)
    * [Subscriptions](#subscriptions)
    * [Operations](#operations)
      * [map](#map)
      * [select](#select)
      * [inject](#inject)
      * [flat_map](#flat_map)
      * [... and even more operations](#-and-even-more-operations)
    * [Interacting Trackables](#interacting-trackables)
      * [merge](#merge)
      * [zip](#zip)
      * [combine](#combine)
      * [concat](#concat)
      * [depend_on](#depend_on)
    * [Concurency](#concurency)
      * [execute_on](#execute_on)
      * [track_on](#track_on)
      * [Executors and factory methods](#executors-and-factory-methods)
    * [Buffering, delaying and skipping](#buffering-delaying-and-skipping)
      * [buffer](#buffer)
      * [delay](#delay)
      * [throttle](#throttle)
    * [Grouping](#grouping)
      * [group_by_label](#group_by_label)
      * [chunk](#chunk)
      * [operating only on given group](#operating-only-on-given-group)
      * [flatten_labeled](#flatten_labeled)
    * [Error handling](#error-handling)
      * [retrying](#retrying)
      * [how to rescue from errors](#how-to-rescue-from-errors)
  * [Dependencies](#dependencies)
  * [Tested with](#tested-with)

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
  is easier to use it. The goal of `Reacto` is to be alternative to `RxRuby`
  in the ruby world.
  Still the author of Reacto is big fan of `RX` especially `RxJava`. He even has
  a book on the topic using `RxJava` :
  [Learning Reactive Programming with Java 8](https://www.packtpub.com/application-development/learning-reactive-programming-java-8)
* [Frappuccino](https://github.com/steveklabnik/frappuccino) : Very cool lib,
  easy to use and simply beautiful. The only drawback - it is a bit limited :
  no concurrency and small set of operations.
  But if you don't need more complicated operations it works.
  The author of `Reacto` highly recommends it.

## Usage

### Simple Trackables

The main entry point to the library is the `Reacto::Trackable` class.
It represents something you can track for notifications.
Usually a `Reacto::Trackable` implemenation is pushing notifications to
some notification tracker. It depends on the source. We can have some remote
streaming service as a source or an asynchronous HTTP request or some process
pushing updates to another.

#### value

Of course the source can be very simple, for example a single value:

```ruby
  trackable = Reacto::Trackable.value(5)
```

This value won't be emitted as notification until there is no tracker (listener)
attached to `trackable` - so this `Trackable` instance is lazy - won't do
anything until necessary.

```ruby
  trackable.on(value: ->(v) { puts v })

  # => 5
```

This line attaches a notification tracker to the `trackable` - a lambda that
should be called when `trackable` emits any value. This example is very
simple and the `trackable` emits only one value - `5` when a tracker is attached
to it so the lambda will be called and the value will be printed. Shortcuts
for `Reacto::Trackable.value(val)` are `Reacto.value(val)` and `Reacto[val]`.

#### error

If we want to emit only an error notification we can do it with
`Trackable.error`. It works the same way as `Trackable.value`,
but the notification is of type _error_:

```ruby
  trackable = Reacto::Trackable.error(StandardError.new('Some error!'))

  trackable.on(error: ->(e) { raise e })
```

Shorcuts for `Reacto::Trackable.error(err)` are `Reacto.error(err)` and
`Reacto[err]`. Notice that `Reacto[simple_vlue]` is like `Reacto.value`, but
`Reacto[some_standart_error]` is like calling `Reacto.error`.

#### close

There is a way to create a `Reacto::Trackable` emitting only _close_
notification too:

```ruby
  trackable = Reacto::Trackable.error(StandardError.new('Some error!'))

  trackable.on(close: ->() { p 'closed' })
```

Shorcuts are `Reacto.close` and `Reacto[:close]`.

#### enumerable

Another example is `Trackable` with source an Enumerable instance:

```ruby
  trackable = Reacto::Trackable.enumerable([1, 3, 4])
```

Again we'll have to call `#on` on it in order to push its values to a tracker.
Shorcuts are `Reacto.enumerable(enumerable)` and `Reacto[enumerable]`.

#### interval

A neat way to create `Trackable` emitting the values of some _Enumerable_ on
every second, for example is `Reacto::Trackable.interval`:

```ruby
  trackable = described_class.interval(0.3)
```

This one emits the natural numbers on every _0.3_ seconds.
The second argument can be an `Enumerator` - limited or unlimited, for example:

```ruby
  trackable = described_class.interval(2, ('a'..'z').each)
```

Emits the letters _a to z_ on every two seconds. We can create a custom
enumerator and use it.
Note that `.interval` creates `Reacto::Trackable` which emits in a special
thread, so calling `#on` on it won't block the current thread.
Shortcut is `Reacto.interval`.

#### never

It is possible that a Trackable which never emits anything is needed. Some
operations behave according to `Trackable` instances returned, so a way to have
such a `Reacto::Trackable` is:

```ruby
  trackable = Reacto::Trackable.never
```

Shortcuts for this one are `Reacto.never` and `Reacto[:never]`


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
Shorcut is `Reacto.make`.

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

Calling it like that will trigger the behavior of `trackable` and
all the values it emits, will be passed to the consumer. A block can be passed
to `#on` and it will have the same effect:

```ruby
  trackable.on do |value|
    # Consume the incoming value
  end
```

If we want to listen for errors we can call `#on` like that:

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
    # Finalize?
  end

  trackable.on(close: to_be_called_on_close)
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

This way our notification tracker won't receive notification anymore.
Checking if a `Subscription` is subscribed can be done by calling `subscribed?`
on it.

```ruby
  subscription = trackable.on(value: consumer)

  subscription.subscribed? # true
```

Subscriptions can be used for other things, adding additional subscriptions
to them, adding resources, which should be closed on receiving the `close`
notification and waiting for a `Trackable` operating on background to finish.

### Operations

Operations are methods which can be invoked on a `Reacto::Trackable` instance,
and always return a new `Reacto::Trackable` instance. The new trackable has
emits all or some of the notifications of the source, somewhat changed by
the operation. Let's look at an example:

#### map

The `map` operation is a transformation, it transforms every value
(and not only), emitted by the source using the _block_ given.

```ruby
  source_trackable = Reacto.enumerable((1..100))

  trackable = source_trackable.map { |value| value - 1 }

  trackable.on(value: -> (val) { puts val })
  # the numbers from 0 to 99 will be printed
```

The `map` operation is able to transform errors as well, it can transform
the stream of notifications itself and add new notification before the
close notification for example.

#### select

The `select` operation filters values using a predicate block:

```ruby
  source_trackable = Reacto.enumerable((1..100))

  trackable = source_trackable.select { |value| value % 5 == 0 }

  trackable.on(value: -> (val) { puts val })
  # the numbers printed will be 5, 10, 15, ... 95, 100
```

There are more filtering operations - `drop`, `take`, `first`, `last`, etc.
Look at the specs for examples of them.

#### inject

Using `inject` is a way to accumulate and emit data based on the current
incoming value and the accumulated data from the previous ones. A better way
to explain it is an example:

```ruby
  source_trackable = Reacto.enumerable((1..100))

  trackable = source.inject(0) { |prev, v| prev + v }

  trackable.on(value: -> (val) { puts val })
  # Will print a sequesnce of sums 0+1 then 1+2=3, then 3+4=7, etc, the last
  # value will be the sum of all the source values
```

Operation similar to `inject` is `diff`, which calls a given block for every
two emitted in sequence values and the `Reacto::Trackable` resulting from it,
emits this the block's return value. Another one is `each_with_object`, which
calls a given block for each value emitted by the source with an arbitrary
object given, and emits the initially given object.

#### flat_map

This operation takes a block which will be called for every emitted value
by the source. The block has to return a `Reacto::Trackable` instance for
every value. So if the source emits 10 values, ten Trackable instances will
be created, all of which will emit values. All these values are flattened
and emitted by the `Reacto::Trackable` created by calling `flat_map`.

```ruby
  source = Reacto.enumerable([(-10..-1), [0], (1..10)])
  trackable = source.flat_map { |v| Reacto[v] }

  trackable.on(value: -> (val) { puts val })
  # Will print all the numbers from -10 to 10
```

It is a very powerful operation, which allows us to create `Reacto::Trackable`
instances from incoming data and write logic using operations on them.

#### ... and even more operations

*Reacto* is in continuous development more and more _operations_ are being added
to it and there are even more to come.
So soon there will be a documentation page for all of the available operations,
which will be updated when new ones are added, or existing ones are modified.
Keep in mind that `Reacto::Trackable` mirrors `Enumerable`, it even includes
it in itself. This means that for every method in `Enumerable`, there is a
corresponding operation or method in `Reacto::Trackable`.

TODO

### Interacting Trackables

Trackables can interact with one another, for example one `Reacto::Trackable`
instance can be merged with another to produce a new one - emitting the
notifications of the two sources.

#### merge

This is done by calling `merge` on one of the Trackables and passing to it
the other. `merge` is an operation - it produces a new `Reacto::Trackable`
instance:

```ruby
  trackable = Reacto.interval(2).map { |v| v.to_s + 'a'}.take(5)
  to_be_merged = Reacto.interval(3.5).map { |v| v.to_s + 'b'}.take(4)

  subscription = trackable.merge(to_be_merged).on(value: -> (val) { puts val })
  trackable.await(subscription)

  # Something like '0a', '0b', '1a', '2a', '1b', '3a', '4a', '2b', '3b' will
  # be printed
```

As mentioned before, interval is executed in the background by default, so
adding trackers to either of the sources won't block the current thread.
This means that the `Reacto::Trackable` created by `merge` will emit the
source notifications in the order they are coming and that doesn't depend on
which source they are coming from. We call `#await` to it passing the
_subscription_ because we don't want the current thread to terminate, we want
it to wait for the threads of the two sources to finish. More on that later.

#### zip

Zip combines the notifications emitted by multiple `Reacto::Trackable` instances
into one, using a combinator function. The first notifications of all the
trackables are combined, then the second notifications and when one of the
sources emits close/error notification, the one produced by `zip` emits it and
closes.

```ruby
  source1 = Reacto.interval(3).drop(1).take(4)
  source2 = Reacto.interval(7, ('a'..'b').each)
  source3 = Reacto.interval(5, ('A'..'C').each)

  trackable = Reacto::Trackable.zip(source1, source2, source3) do |v1, v2, v3|
    "#{v1} : #{v2} : #{v3}"
  end

  subscription = trackable.on(
    value: -> (val) { puts val }, close: -> () { puts 'Bye!' }
  )
  trackable.await(subscription)

  # '1 : a : A' and '2 : b : B' will be printed, then 'Bye!', because the second
  # source will emit the close notification after emitting 'b'.
```

Here the first source - `source1` is emitting the numbers from `0` to infinity
on every 3 seconds, we want to drop the `0` and start by emitting `1`, so we
drop the first emitted value with `drop(1)`, then we don't want to emit to
infinity, so we `take(4)` - only the first `4` numbers, so `1`, `2`, `3` and `4`
. This is an example of how to use the positional filtering operations.
A shortcut for this one is `Reacto.zip`.

#### combine

There is the `combine` operation which behaves in a fashion similar to `zip`
but combines the last emitted values with its combinator function on every new
value incoming from any source and closes when all of the sources have closed.

```ruby
  source1 = Reacto.interval(3).take(4)
  source2 = Reacto.interval(7, ('a'..'b').each)
  source3 = Reacto.interval(5, ('A'..'C').each)

  trackable = Reacto::Trackable.combine(source1, source2, source3) do |v1, v2, v3|
    "#{v1} : #{v2} : #{v3}"
  end

  subscription = trackable.on(
    value: -> (val) { puts val }, close: -> () { puts 'Bye!' }
  )
  trackable.await(subscription)

  # '1 : a : A', '2 : a : A', '2 : a : B', '3 : a : B', '3 : b : B',
  # '3 : b : C' and then 'Bye!' will be printed.
```

All of these values will be emitted on the right intervals. For example
`'1 : a : A'` will be emitted `7` seconds after the subscription, because `a`
takes the most time and the first notification of the combined trackable have
to include data from all of the sources. Then the second - `'2 : a : A'` will be
emitted the `9th` second from the start, because `2` is emitted on the `9th`
second, etc. In the beginning the `0` emitted by the first source is silently
skipped.
Shortcut for this one is `Reacto.combine`; `Reacto::Trackable.combine_latest`
is an alias.

#### concat

Concatenating one `Reacto::Trackable` to another, basically means that the
resulting `Trackable` will emit the values of the first one, then the values
of the second one:

```ruby
  source1 = Reacto.enumerable((1..5))
  source2 = Reacto.enumerable((6..10))

  trackable = source1.concat(source2)

  trackable.on(
    value: -> (val) { puts val }, close: -> () { puts 'Bye!' }
  )

  # The values from 1 to 10 will be printed, then 'Bye!'
```

Another way to use it would be
`Reacto::Trackable.concat(trackable1, trackable2, ... , trackableN)` with
shortcut `Reacto.concat`.

#### depend_on

One `Reacto::Trackable`'s notifications can depend on another's accumulated
notifications. The `depend_on` operation, expects a `Trackable` and a block,
the block is used in the same manner as `inject` uses its block on this passed
`Trackable`. When the passed `Trackable` closes, the accumulated data by the
block (the last value) is emitted with every notification of the caller:

```ruby
  dependency = Reacto.enumerable((1..10))
  trackable = Reacto.enumerable([5, 4]).depend_on(dependency, &:+)

  trackable.on(
    value: -> (val) { puts val }, close: -> () { puts 'Bye!' }
  )

  # The emitted notifications will printed:
  # Value notification : notification.value: 5, notification.data: 55
  # Value notification : notification.value: 4, notification.data: 55
  # Close notification : prints 'Bye!'
```

Without passed block, the first emitted value of the dependency is used as data.
If there is an error from the dependency, it is emitted by the caller. The key
of the dependency, can be changed from `data` to something else by passing a
`key:` to the operation.

### Concurency

Aside from factory methods like `.interval` or `.later`, `Reacto::Trackable`
has two other ways of emitting its notification concurrently to the thread
that created it (or some other thread). Every trackable can do that by using
the two dedicated operations `execute_on` and `track_on`.

#### execute_on

This operation returns a `Reacto::Trackable` which operations will be executed
on the given `executor` plus the operations of its source will be executed on
that `executor` as well. Basically this means that the whole logic - the
behavior of the first `Trackable` in the chain of operations and all subsequent
operations will be executed on the given `executor`.
By `executor`, we mean the ones provided by the `Reacto::Executors`'s methods or
a custom implementation complying to `concurrent-ruby`'s
`Concurrent::ExecutorService`. These executors menage threads for us, some of
them are thread pools, which allows us to reuse unused threads from the pool,
others provide always new threads on demand or just a single thread. In the
following example the `Reacto::Executors.io`
executor is used (passed as just `:io`) :

```ruby
  require 'net/http'
  require 'uri'
  require 'json'

  request_url_behavior = -> (url) do
    -> (subscriber) do
      begin
        response = Net::HTTP.get_response(URI.parse(url))

        if response.code == '200'
          subscriber.on_value(response.body)
          subscriber.on_close
        else
          subscriber.on_error(StandardError.new(response))
        end
      rescue StandardError => e
        subscriber.on_error(e)
      end
    end
  end

  trackable = Reacto.make(
    &request_url_behavior.call('https://api.github.com/repos/meddle0x53/reacto')
  )

  trackable = trackable.map { |response| JSON.parse(response) }

  star_count = trackable.map { |val| val['stargazers_count'] }.map do |val|
    "#{val} star(s) on Reacto's github page!"
  end

  star_count = star_count.execute_on(:io)

  star_count_subscription = star_count.on(
    value: -> (val) { puts val }, close: -> () { puts '---------' }
  )

  star_gazers = trackable.map { |val| val['stargazers_url'] }.flat_map do |url|
    Reacto.make(&request_url_behavior.call(url)).map do |response|
      JSON.parse(response)
    end.flat_map do |array|
      Reacto.enumerable(array).map { |data| data['login'] }
    end
  end

  star_gazers = star_gazers.execute_on(:io)

  star_gazers_subscription = star_gazers.on(
    value: -> (val) { puts val }, close: -> () { puts 'Thank you all!' }
  )

  star_gazers.await(star_gazers_subscription, 60)
  star_count.await(star_count_subscription, 60)

```

This example is a bit silly because it makes two requests to the same URL,
but they are concurrent thanks to `execute_on` and that's the important thing.
The first trackable reads the number of the stars of this repository and its
consumer prints them, and the second one requests the _stargazers_ list, using
`flat_map` and prints the names of the star gazers. The two chains are
executed concurrently.
The `IO` executor is a cached thread pool, which means that threads are reused
if available, otherwise new are created, the thread pool does not have fixed
size.

#### track_on

The difference between `execute_on` and `track_on` is that `track_on` executes
on the given executor only the operations positioned after it in the chain.

```ruby
  trackable = Reacto.enumerable((1..100)).map { |v| v * 10 }.track_on(:tasks)
  trackable = trackable.inject(&:+).last

  subscription = trackable.on(
    value: -> (val) { puts val }, close: -> () { puts 'DONE.' }
  )

  trackable.await(subscription, 10)
```

Only the sum and `last` will happen on the `tasks` executor - a thread pool
with fixed number of threads. The `map` will execute on the current thread.

#### Executors and factory methods

Executors can be passed to most of the methods which create `Reacto::Trackable`
instances. The methods can receive a keyword argument - `executor:` and will
execute the whole trackable chain on it. The same way if it was passed to
`execute_on`.

```ruby
 trackable = Reacto.enumerable((1..1000), executor: :new_thread)
```

All the operations on called on this `Trackable` and its derivative
`Trackable`s will be executed in the `new_thread` executor. This executor
creates a new thread always.

The available executors are:

* `IO` - can be passed as `:io` or `Executors.io` - an unlimited cached thread
  pool.
* `Tasks` - can be passed as `:tasks`, `:background` and `Executors.tasks` -
  a thread pool with fixed size.
* `New thread` - can be passed as `:new_thread` ot `Executors.new_thread` -
  always creates a new thread.
* `Current` - can be passed as `:immediate`, `:current`, `:now`,
  `Executors.current` and `Executors.immediate` - uses the current thread to
  execute operations, does not create a new thread at all.

### Buffering, delaying and skipping

There are a few special operations related to buffering incoming notifications
and emit notifications consisting of the buffered ones.

#### buffer

It is possible to buffer values using a count and then emit them as one array
of values.

```ruby
  trackable = Reacto.enumerable((1..20)).buffer(count: 5)

  trackable.on(value: -> (val) { p val })

  # Will print [1, 2, 3, 4, 5], then [6, 7, 8, 9, 10], then [11, 12, 13, 14, 15]
  # and in the end [16, 17, 18 , 19, 20]
```

Buffering helps lowering the number of value notification, when the source is
emitting too many of them, too fast.

#### delay

Notifications can be buffered using a delay too, for example : don't emit
anything from the source for 5 seconds, then emit everything received until
now and repeat.

```ruby
  trackable = Reacto.interval(1).take(20).buffer(delay: 5)

  subscription = trackable.on(value: -> (val) { p val })
  trackable.await(subscription)

  # Will print on each 5 seconds something like
  # [0, 1, 2, 3]
  # [4, 5, 6, 7, 8]
  # [9, 10, 11, 12, 13]
  # [14, 15, 16, 17, 18]
  # [19]
```

Instead of using `buffer(delay: 5)`, we can use the shortcut `delay(5)`.
We can buffer by both count and delay using the `buffer` operation.

#### throttle

If too many notifications are received too fast, sometimes it is better to
skip some of them and emit only the last one. That can be done with `throttleb`.

```ruby
  trackable = Reacto.interval(1).take(30).throttle(5)

  values = []
  subscription = trackable.on(value: -> (val) { values << val })
  trackable.await(subscription)

  puts values.size # just 6
```

### Grouping

Incoming notifications can be grouped by some common property they have.
The resulting `Reacto::Trackable` emits special `LabeledTrackable` instances
which are just trackables with additional property - `label` - the name of
the group.

#### group_by_label

The most basic operation which groups values into sub-trackables is
`group_by_label` or just `group_by`:

```ruby
  trackable = Reacto.enumerable((1..10)).group_by_label do |value|
    [(value % 3), value]
  end

  trackable.on do |labeled_trackable|
    p "Label: #{labeled_trackable.label}"
    p "Values: #{labeled_trackable.to_a.join(',')}"
  end

  # This produces:
  # Label: 1
  # Values: 1,4,7,10
  # Label: 2
  # Values: 2,5,8
  # Label: 0
  # Values: 3,6,9
```

This example prints the label of every `Reacto::LabeledTrackable` emitted and
its values. It uses the `#to_a` method, which blocks and waits for every value
to be received, then produces an array with all the values in the order they
were received.

#### chunk

With `chunk` we can create `LabeledTrackable` instances emitting chunks based
on the return value of a block called on an emitted value. The difference with
`group_by` is that there can be multiple trackables with the same key.

```ruby
  source = Reacto.enumerable([3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5])
  trackable = source.chunk { |val| val.even? }

  trackable.on do |labeled_trackable|
    p "Label: #{labeled_trackable.label}"
    p "Values: #{labeled_trackable.to_a.join(',')}"
  end

  # This produces:
  # Label: false
  # Values: 3,1
  # Label: true
  # Values: 4
  # Label: false
  # Values: 1,5,9
  # Label: true
  # Values: 2,6
  # Label: false
  # Values: 5,3,5
```

The first chunk consists of `3` and `1` - odd values, then on the first even
value - `4` we get another chink, then we've got 3 sequential odd values, so
a `false` chunk of `1`, `5` and `9`, then one with `2` and `6` with label
`true`, because the values are even. The last chunk is an odd one.

#### operating only on given group

The `map` operator is able to operate only on a given group by passing it
a `label:` argument:

```ruby
  source = Reacto.enumerable((1..10)).group_by_label do |value|
    [(value % 3), value]
  end
  trackable = source.map(label: 0) { |value| value / 3 }

  trackable.on do |labeled_trackable|
    p "Label: #{labeled_trackable.label}"
    p "Values: #{labeled_trackable.to_a.join(',')}"
  end

  # This produces:
  # Label: 1
  # Values: 1,4,7,10
  # Label: 2
  # Values: 2,5,8
  # Label: 0
  # Values: 1,2,3
```

As we can see only the values emitted by the `Trackable` with label `0`, the
ones that can be divided by 3 without remainder are affected by the `map`
operation. The operations `select`, `inject` and `flat_map` have a `label:`
argument too and can be applied only to sub-trackables with the passed label.

#### flatten_labeled

The `Reacto::LabeledTrackable` instances emitted by a `Trackable` after grouping
can be turned to simple value notifications by using the `flatten_labeled`
operation. It turns every sub-trackable into an object with two fields
label and value. The label is the same as the label of the sub-trackable the
object represents, and the value is accumulated with a block passed to
`flatten_labeled` from the notifications emitted by the sub-trackable.
It is the same as using inject:

```ruby
  source = Reacto.enumerable((1..10)).group_by_label do |value|
    [(value % 3), value]
  end
  trackable = source.flatten_labeled { |prev, curr| prev + curr }

  trackable.on { |object| puts "#{object.label} : #{object.value}"}

  # This produces:
  # 1 : 22
  # 2 : 15
  # 0 : 18
```

Prints the original label and the sums of the values emitted by the original
`Reacto::LabeledTrackable`.

### Error handling

Sometimes we want to handle incoming error notification before actually going
out of the operation chain and in the error consumer code. This can be achieved
with some special operations, designed to work with errors.

#### retrying

The `retry` operator will execute the source's behavior when there is an error
notification instead of emitting it and closing the `Reacto::Trackable`.

```ruby
  source = Reacto.make do |subscriber|
    subscriber.on_value('Test your luck!')
    number = Random.new.rand(1..10)

    if number <= 5
      subscriber.on_error(
        StandardError.new("Bad luck, last number was : #{number}")
      )
    else
      subscriber.on_value("Lucky number #{number}!")
      subscriber.on_close
    end
  end

  trackable = source.retry(5)
  trackable.on(
    value: -> (v) { puts v },
    close: -> () { puts 'Done' },
    error: -> (e) { puts e.message }
  )
```

This piece of code will retry up to 5 times when the number is `5` or smaller.
On the sixth time if we don't have luck the error will be emitted. The default
retry count (when a value is not passed) is just `1`. There is a `retry_when`
operation, which uses a block to determine if the error should be emitted, or
the source should be retried. For example:

```ruby
  source = Reacto.make do |subscriber|
    subscriber.on_value('Test your luck!')
    number = Random.new.rand(1..10)

    if number <= 5
      subscriber.on_error(
        StandardError.new("Bad luck, last number was : #{number}")
      )
    else
      subscriber.on_value("Lucky number #{number}!")
      subscriber.on_close
    end
  end

  trackable = source.retry_when do |error, retries|
    retries < 5 && !error.message.include?('3')
  end

  trackable.on(
    value: -> (v) { puts v },
    close: -> () { puts 'Done' },
    error: -> (e) { puts e.message }
  )
```

In this example we use the block to say the that we retry at most 5 times
again, but this time if the unlucky number was `3` we should not retry.

#### how to rescue from errors

The simples way to not emit an error but to continue emitting something else
is by using the `rescue_and_replace_error_with` operation. This one accepts
a `Reacto::Trackable` instance as its sole argument.
When an error notification is emitted by its source `Trackable`, it is not
emitted by the trackable it returns. Instead the notifications of the argument
are emitted.

```ruby
  source = Reacto.enumerable([1, 2, 3, 0, 7, 8, 9]).map do |val|
    10 / val
  end

  trackable = source.rescue_and_replace_error_with(
    Reacto::Trackable.enumerable((4..6)).map { |val| 10 / val }
  )

  trackable.on(
    value: -> (v) { puts v },
    close: -> () { puts 'Done' },
    error: -> (e) { puts e.message }
  )
```

We want see the error cause the by division by `0`, instead after the emission
of `10/1` -> `10`, `10/2` -> `5` and `10/3` -> `3`, the values `2`, `2` and `1`
will be emitted -> that's `10/4`, `10/5` and `10/6`.

Another more precise way to do that is to use the `rescue_and_replace_error`
operation which receives a block returning a `Reacto::Trackable` -
the replacement. The block has as an argument the original error, so some logic
can be written around that.

```ruby
  source = Reacto.enumerable([1, 2, 3, 0, 7, 8, 9]).map do |val|
    10 / val
  end

  trackable = source.rescue_and_replace_error do |error|
    if error.is_a?(ArgumentError)
      Reacto.error(error)
    else
      Reacto.value(1)
    end
  end

  trackable.on(
    value: -> (v) { puts v },
    close: -> () { puts 'Done' },
    error: -> (e) { puts e.message }
  )
```

The number `1` will be emitted instead of the `ZeroDivisionError` because it is
not an `ArgumentError`.

## Dependencies

Reacto is powered by [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby)

## Tested with

 * Ruby 2.0.0+
 * JRuby 9.1.2.0
