User.find_or_create_by!(email: "rk_bart@yahoo.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :admin
  user.status = "approved"
end

puts "Admin user created."

stocks = [
  { symbol: 'AAPL', name: 'Apple Inc.' },
  { symbol: 'GOOGL', name: 'Alphabet Inc.' },
  { symbol: 'MSFT', name: 'Microsoft Corporation' },
  { symbol: 'AMZN', name: 'Amazon.com Inc.' },
  { symbol: 'TSLA', name: 'Tesla Inc.' },
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
