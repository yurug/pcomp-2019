class String
  def sort
    chars.sort.join
  end
end

module AnagramsByFrequencies
  def self.anagrams(dictionary, words)
    sorted_dictionary = dictionary.each_with_index.map { |w, i| [i, w.sort] }.sort_by(&:last)
    sorted_words = words.each_with_index.map { |w, i| [i, w.sort] }.sort_by(&:last)
    
    hash = Hash.new { |h, k| h[k] = [] } 
    i = 0
    sorted_words.each do |j, w|
      i += 1 while sorted_dictionary[i] && sorted_dictionary[i][1] < w
      while sorted_dictionary[i] && sorted_dictionary[i][1] == w
        hash[w] << dictionary[sorted_dictionary[i][0]]
        i += 1
      end
    end
    words.each.with_object({}) { |w, h| h[w] = (hash[w.sort] - [w]).sort }
 end
end
