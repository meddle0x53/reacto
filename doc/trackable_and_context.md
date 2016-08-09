# Reactive programming with Reacto

## Patterns

### Enumerator

Using Reacto is basically using a specific programming pattern.
It even looks like a familiar one - the `Enumerator` (or Iterator).
We can call `each` on any `Enumerable` in Ruby and we'll get
an `Enumerator`. Then we can call `next` on it to _pull_ values.

```ruby
  enumerator = [1, 2, 3].each
  p enumerator.next # 1
  p enumerator.next # 2
  p enumerator.next # 3
  p enumerator.next # a StopIteration error will be raised
```

It is more common to pass a *block* to `each`, which will be called for every
`next` value and the exception will be avoided.

```ruby
  [1, 2, 3].each { |value| p value }
```

Lastly we can create our own implementations of `Enumerator`. For example
one that generates infinite sequential integer values, beginning
from zero.

```ruby
  enumerator = Enumerator.new do |yielder|
    n = 0

    loop do
      yielder << n
      n = n + 1
    end
  end

  p enumerator.next # 1
  p enumerator.next # 2
  p enumerator.next # 3
  # .....
```

OK so we can look at the `Enumerator` as a behavior or a source which
produces values _on demand_. We _pull_ values from it.

### Reacto::Trackable

The central abstraction in Reacto is the `Trackable`. It, like the `Enumerator` implements
a pattern. An instance can be created depending on the underlying behaviour
or data source using different methods. As with the `Enumerator` we can
create a `Reacto::Trackable` using an `Enumerable`.

```ruby
  trackable = Reacto::Trackable.enumerable([1, 2, 3])
```

Now we can track for values by calling `on(value: <Proc>)` on it.

```ruby
  trackable.on(value: ->(v) { p v })

  # same as
  trackable.on do |val|
    p val
  end
```

This way the `Trackable` will _push_ the values to our _consumer_ lambda/block.
So in this case it is pretty much the same as with the `Enumerator`. The
main difference is that our code is not _pulling_ the values from the
`Trackable`, instead, the `Trackable` is _pushing_ the values, when they are
ready, to our client code.

As with the `Enumerator`, which includes the `Enumerable` module, `Reacto::Trackable` has
a lot of handy functions (called operations - `map`, `select`, etc. - more on them later) we can chain to it.
A difference between `Trackable` and `Enumerator` is that we can track for errors and `close` notifications
too.

```ruby
  trackable.on(
    error: ->(e) { p e.message }, value: ->(v) { p v }, close: ->() { p 'DONE' }
  )
```

Now if there is an error while receiving the values, it will be passed to
the error-handling lambda.
So we can react to incoming notifications and even errors. The `close`
notification is flagging that all the incoming data has arrived.

Let's sum it up - a `Reacto::Trackable` is much like an `Enumerator`, but
our consumer code is not _pulling_ the data from it, it is instead _tracking_
it for notifications. These notifications could be values, errors, or
`close` ones. They are _pushed_ to our consumer code when available.

## Asynchronous programming

By default when we call `on` on a `Reacto::Trackable` instance, our program blocks
and waits for all the notifications to arrive until an error or `close`
notification is received. That's OK, but as said, values are received
when available, so in some cases it will be more efficient to do something else
while waiting for the values to come.
Enter `execute_on`. It, like all the other operations that can be called on
`Reacto::Trackable`, creates a new `Trackable` with source the caller.
The new one will execute all of its operations on the _Executor_ passed to the
`execute_on`. An _Executor_ is a service that manages threads.

```ruby
  trackable = trackable.execute_on(:background)
  trackable.on(
    error: ->(e) { p e.message }, value: ->(v) { p v }, close: ->() { p 'DONE' }
  )

  # The call to `on` won't block so we can have some code here, which will
  # execute immediately after it. When the values arrive, they'll be printed.

```

It's that easy to have code in the background. And what if we want to block
at some point?
First of all the `on` method returns a `Reacto::Subscription` instance
which we can use to `unsubscribe` from the `Reacto::Trackable` or do other
things. One of this things is to pass it to `Reacto::Trackable#await`:

```ruby
  trackable = trackable.execute_on(:background)
  subscription = trackable.on(
    error: ->(e) { p e.message }, value: ->(v) { p v }, close: ->() { p 'DONE' }
  )

  # Some code we want to be executed while waiting for values

  trackable.await(subscription) # Block until an error or close notification arives
```

That's how easy it is.

## Operations

So we were just talking about the _code_ in the background, but what kind of
code can we attach to the `Reacto::Trackable`s exactly?
We can answer that by defining what an *operation* is. An *operation* is
called on a `Reacto::Trackable` instance and it always returns a new
`Reacto::Trackable` instance with source the caller.
The *operation* will change the incoming notifications,
when the tracking takes places. Let's look at some examples:

#### Map

The `map` operation is a simple transformation. It's the same as
the `Enumerable`'s `map` - transforms each of the values into something else
using the passed `block`'s return values'.

```ruby
  source = Reacto::Trackable.enumerable((1..5))

  trackable = source.map { |v| v * v * v }
  trackable.on { |val| p val } # Will print 1 8 27 64 125
```

#### Select

The `select` operation filters incoming values, again similar to its
`Enumerable` counterpart.


```ruby
  source = Reacto::Trackable.enumerable((1..5))

  trackable = source.select { |v| v % 2 == 0 }
  trackable.on { |val| p val } # will print 2 4
```

#### Inject

Of course there is the `inject` operation which gives us the opportunity
to combine the current incoming value with the previous one and emit that
as value.


```ruby
  source = Reacto::Trackable.enumerable((1..5))

  trackable = source.inject { |prev, val| prev + val }
  trackable.on { |val| p val } # will print 1 3(1+2) 6(3 + 3) 10(6 + 4) 15(10 + 5)
```

#### FlatMap

Interesting operation is the `flat_map`. It accepts a block, which for
every call with a value must return an instance of `Reacto::Trackable`.
In the end the resulting `Reacto::Trackable` will emit all the values,
emitted by all of these returned by the block `Reacto::Trackable`s.

```ruby
  source = Reacto::Trackable.enumerable((1..5))

  trackable = source.flat_map { |val| Reacto::Trackable.enumerable(val..6) }
  trackable.on { |val| p val }
  # will print 1 2 3 4 5 6 2 3 4 5 6 3 4 5 6 4 5 6 5 6
```

This basically means that we can add operations to the inner `Reacto::Trackable`s too,
because all the available operations are producing `Reacto::Trackable` instances.

## Links

TODO
