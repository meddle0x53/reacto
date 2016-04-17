require 'spec_helper'

context Reacto::Trackable do
  let(:source_updates) { [] }
  let(:source) do
    Reacto::Trackable.make do |tracker|
      source_updates << true

      tracker.on_value(3)
      tracker.on_value(4)
      tracker.on_value(5)
      tracker.on_close
    end
  end

  def check_cache(trackable)
    trackable.on(value: test_on_value, close: test_on_close)
    expect(test_data).to be == [3, 4, 5, '|']
    expect(source_updates).to be == [true]

    trackable.on(value: test_on_value, close: test_on_close)
    expect(test_data).to be == [3, 4, 5, '|', 3, 4, 5, '|']
    expect(source_updates).to be == [true]
  end

  context '#cache' do
    context 'memory' do
      it 'caches all the values received before the closing notifincation and ' \
        'replayes them on subsequent subscriptions' do
        check_cache(source.cache)
      end
    end

    context 'file' do
      after(:each) do
        File.delete('tmp/test.cache')
      end

      it 'caches all the values received before the closing notifincation and ' \
        'replayes them on subsequent subscriptions' do
        check_cache(source.cache(type: :file, location: 'tmp/test.cache'))
      end

      it 'uses the cache only if it is fresh' do
        trackable1 =
          source.cache(type: :file, location: 'tmp/test.cache', ttl: 0.5)

        check_cache(trackable1)

        trackable2 =
          source.cache(type: :file, location: 'tmp/test.cache', ttl: 0.5)
        trackable2.on
        expect(source_updates).to be == [true]

        sleep(1)

        trackable3 =
          source.cache(type: :file, location: 'tmp/test.cache', ttl: 0.5)
        trackable3.on
        expect(source_updates).to be == [true] * 2
      end
    end
  end
end
