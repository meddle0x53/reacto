# Reactive programming with Reacto

## Patterns

### Enumerator

Using Reacto is basically using a specific programming pattern.
It even looks like a familiar one - the `Enumerator` (or Iterator).
As you know we can call `each` on every `Enumerable` in Ruby and we'll get
one `Enumerator`. Then we can call `next` on it to _pull_ values.

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
one that generates infinite integer sequential integer values, beginning
from zero.

```ruby
  enumerator = Enumerator.new do |yielder|
    n = 0

    loop do
      yielder << n
      n = n + 1
    end

    p enumerator.next # 1
    p enumerator.next # 2
    p enumerator.next # 3
    # .....
  end
```

OK so we can look at the `Enumerator` as a behaviour or a source which
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

This way the `Trackable` will _push_ the values to our _consumer_ lambda.
So in this case it is pretty much the same as with the `Enumerator`. The
main difference is that our code is not _pulling_ the values from the
`Trackable`, instead, the `Trackable` is _pushing_ the values when they are
ready to our client code.

As with the `Enumerator`, which includes `Enumerable`, `Reacto::Trackable` has
what's of handy functions we can chain to it. As `map`, `filter`, etc.
In the future, it will include `Enumerable` too.
Another difference is that we can track for errors and end-of-data notifications
too.

```ruby
  trackable.on(
    error: ->(e) { p e.message }, value: ->(v) { p v }, close: ->() { p 'DONE' }
  )
```

Now if there is an error while receiving the values, it will be passed to
the error-handling lambda.
So we can react to incoming notifications and even errors. The `close`
notification is flaging that all the incoming data has arrived.

Let's sum it up - a `Reacto::Trackable` is much line an `Enumerator`, but
our consumer code is not _pulling_ the data from it, it is instead _tracking_
it for notifications. These notifications could be values, errors, or
end-of-data ones. They are _pushed_ to our consumer code when available.

## Asynchronous programming

By default when we call `on` on a `Reacto::Trackable`, our program blocks
and waits for all the notifications to arrive until an error or close
notification is received. That's OK and all, but as said, values are received
when available, so in some cases it will be more efficient to do something else
while waiting for the values to come.
Enter `execute_on`. It, as all the other operations that can be called on
`Trackable`, creates a new `Trackable` with source the caller. The new
one will execute all of its operations on the Executor passed to the
`execute_on`. An _Executor_ is a service that manages threads.

```ruby
  trackable = trackable.execute_on(:background)
  trackable.on(
    error: ->(e) { p e.message }, value: ->(v) { p v }, close: ->() { p 'DONE' }
  )

  # The call to `on` won't block so we can have some code here, which will
  # execute immediatelly after it. When the values arrive, they'll be printed.

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
