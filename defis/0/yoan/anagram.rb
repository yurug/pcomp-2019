def anagram(str)
  str.chars.permutation.uniq.map(&:join).reject { |s| s == str }
end

dic, words = ARGV[0], ARGV[1..-1]
words_list = File.readlines(ARGV[0]).map(&:chomp)

words.each do |w|
  list = (anagram(w) & words_list).sort
  puts "#{w}:"
  puts list
end
