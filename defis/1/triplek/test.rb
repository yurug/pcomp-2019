Dir.chdir("./tests/")
nb_test = Dir.entries('./').select {|entry| File.directory?(entry) }.size - 2
Dir.chdir("../")
(0...nb_test).each do |i|
  puts "=== Test #{i} ===\n"
  puts File.readlines("tests/#{i}/README.md")
  system("./ws tests/#{i}/test.csv tests/#{i}/user.txt tests/#{i}/r.csv tests/#{i}/c.txt > /dev/null")
  r = File.readlines("tests/#{i}/r.csv")
  c = File.readlines("tests/#{i}/c.txt")
  er = File.readlines("tests/#{i}/expected_r.csv")
  ec = File.readlines("tests/#{i}/expected_c.txt")
  b1 = r != er
  b2 = c != ec
  if !b1 && !b2
    puts "OK"
  else
    puts "NOK"
    if b1
      puts "Not expected result. Should obtain\n", er
      puts "\nand obtain\n", r
    end
    if b2
      puts "Not expected changes. Should obtain\n", ec
      puts "\nand obtain\n", c
    end
  end
  puts
  system("rm tests/#{i}/c.txt tests/#{i}/r.csv")
  puts "\n=========\n"
  gets
end
