class String
  def frequencies
    each_char.with_object(Hash.new(0)) { |letter, freq| freq[letter] += 1}
  end
end

# Puts anagram of words present in dictionary. The frequencies of each letter is
# invariant by anagrams, hence we just have to create a hash where a list of 
# words is associated to the frequencies of each letter in this word.
# The anagrams of a word w is then hash[w.value].
module AnagramsByFrequenciesHash
  def self.anagrams(dictionary, words)
    hash = dictionary.each.with_object(Hash.new { |h, k| h[k] = [] }) do |w, h|
      h[w.frequencies] << w
    end
    words.each { |w| puts "#{w}:", (hash[w.frequencies] - [w]).sort }
  end
end
