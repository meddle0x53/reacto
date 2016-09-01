require 'reacto/version'
require 'reacto/constants'

require 'reacto/subscriptions'
require 'reacto/tracker'
require 'reacto/trackable'
require 'reacto/shared_trackable'
require 'reacto/labeled_trackable'

module Reacto
  module_function

  def make(executor_param = nil, executor: nil, &block)
    Trackable.make(executor_param, executor: executor, &block)
  end

  def never
    Trackable.never
  end

  def close(executor: nil)
    Trackable.close(executor: executor)
  end

  def error(err, executor: nil)
    Trackable.error(err, executor: executor)
  end

  def value(value, executor: nil)
    Trackable.value(value, executor: executor)
  end

  def enumerable(enumerable, executor: nil)
    Trackable.enumerable(enumerable, executor: executor)
  end

  def later(secs, value, executor: :tasks)
    Trackable.later(secs, value, executor: executor)
  end

  def interval(
    interval, enumerator = Behaviours.integers_enumerator, executor: nil
  )
    Trackable.interval(interval, enumerator, executor: executor)
  end

  def repeat(array, int: 0.1, executor: nil)
    Trackable.repeat(array, int: int, executor: executor)
  end

  def combine(*trackables, &block)
    Trackable.combine(*trackables, &block)
  end

  def combine_last(*trackables, &block)
    Trackable.combine_last(*trackables, &block)
  end

  def zip(*trackables, &block)
    Trackable.zip(*trackables, &block)
  end

  def concat(*trackables)
    Trackable.concat(*trackables)
  end

  def [](object)
    if object.is_a?(Enumerable)
      enumerable(object)
    elsif object.is_a?(StandardError)
      error(object)
    elsif object == :close
      close
    elsif object == :never || object.nil?
      never
    else
      value(object)
    end
  end

  alias_method :combine_latest, :combine
end
