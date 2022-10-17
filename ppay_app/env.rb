file = File.open(File.join(File.dirname(__FILE__), '.env'))

file.readlines.each do |l|
  puts "export #{l}"
end