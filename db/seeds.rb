admin = User.new(
  email: "rk_bart@yahoo.com",
  password: "password123",
  password_confirmation: "password123",
  role: :admin,
  status: "approved",
  confirmed_at: Time.now,
  confirmation_sent_at: Time.now
)
admin.save(validate: false) unless User.exists?(email: "rk_bart@yahoo.com")

# unless Portfolio.exists?(user_id: admin.id)
#   Portfolio.create!(user_id: admin.id, balance: 100000.00)
# end

puts "Admin user created"

stocks = [
  { symbol: 'AAPL', name: 'Apple Inc.' },
  { symbol: 'GOOGL', name: 'Alphabet Inc.' },
  { symbol: 'MSFT', name: 'Microsoft Corporation' },
  { symbol: 'META', name: 'Meta Platforms Inc.' },
  { symbol: 'NVDA', name: 'NVIDIA Corporation' }
]

stocks.each do |stock|
  Stock.find_or_create_by(symbol: stock[:symbol]) do |s|
    s.name = stock[:name]
    s.last_price = 0.0
  end
end

puts "#{Stock.count} stocks created."
