Dir.chdir("./tests/")
nb_test = Dir.entries('./').select {|entry| File.directory?(entry) }.size - 2
Dir.chdir("../")
(0...nb_test).each do |i|
  puts "=== Test #{i} ===\n"
  puts File.readlines("tests/#{i}/README.md")
  system("./ws tests/#{i}/test.csv tests/#{i}/user.txt tests/#{i}/r.csv tests/#{i}/c.txt")
  puts "\n\nObtain\n"
  puts
  puts File.readlines("tests/#{i}/r.csv")
  puts
  puts "and"
  puts
  puts File.readlines("tests/#{i}/c.txt")
  system("rm tests/#{i}/c.txt tests/#{i}/r.csv")
  puts "\n=========\n"
  gets
end