class String
  def frequencies
    each_char.with_object(Hash.new(0)) { |letter, freq| freq[letter] += 1}
  end
end

# Map each string to the frequencies of its letters. Two words are anagrams if 
# and only if they have the same frequencies.
# Hence we just have to create a hash where a list of words is associated to the
# frequencies of its letters. The anagrams of a word w is then 
# hash[w.frequencies].
module AnagramsByFrequenciesHash
  def self.create_frequencies_hash(dictionary)
    dictionary.each.with_object(Hash.new { |h, k| h[k] = [] }) do |w, h|
      h[w.frequencies] << w
    end
  end
  
  def self.anagrams(dictionary, words)
    hash = create_frequencies_hash(dictionary)
    words.each.with_object({}) { |w,h| h[w] = (hash[w.frequencies] - [w]).sort }
  end
end
