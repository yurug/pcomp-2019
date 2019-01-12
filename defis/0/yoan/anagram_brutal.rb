class String
  def anagrams
    chars.permutation.uniq.map(&:join) - [self]
  end
end

module AnagramsBrutal
  def self.anagrams(dictionary, words)
    words.each { |w| puts "#{w}:", (w.anagrams & dictionary).sort }
  end
end
