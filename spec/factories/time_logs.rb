FactoryBot.define do
  factory :time_log do
    association :user
    clock_in { Time.current + (1..4).to_a.sample.hours }
    clock_out { nil }

    trait :with_clock_out do
      clock_out { clock_in + (1..8).to_a.sample.hours }
    end
  end
end
