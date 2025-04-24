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
