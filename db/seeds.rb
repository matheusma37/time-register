require 'factory_bot_rails'
require 'faker'

puts 'Populating users and time_logs...'

FactoryBot.create_list(:user, 100).each do |user|
  puts "Populating time_logs for user with id=#{user.id}..."

  months_qtd = Random.rand(3..6)
  10.times do |i|
    day = Faker::Date.between(from: months_qtd.months.ago, to: Date.today)
    clock_in = day.to_time.change(hour: 8, min: rand(50..80) % 60)
    lunch_start = clock_in + 4.hours + rand(0..15).minutes
    FactoryBot.create(:time_log, user: user, clock_in: clock_in, clock_out: lunch_start)
    lunch_end = lunch_start + 1.hour + rand(0..10).minutes
    clock_out = clock_in.change(hour: 18, min: rand(0..20))
    FactoryBot.create(:time_log, user: user, clock_in: lunch_end, clock_out: clock_out)
  end

  puts "Populating for user with id=#{user.id} is finished..."
end

puts 'Seed finished.'
