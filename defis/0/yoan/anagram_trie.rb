module AnagramsByTrie
  class Trie
    def initialize(words=[])
      @trie = {}
      words.each { |word| append(word) }
    end
    
    def append(word)
      hash = @trie
      word.chars.sort.each do |c|
        hash[c] = hash[c].nil? ? {} : hash[c]
        hash = hash[c]
      end  
      if hash[0].nil? 
        hash[0] = [word]
      else
        hash[0] << word
      end
    end
    
    def [](word)
      hash = @trie
      word.chars.sort.each do |c|
        return [] unless hash.has_key?(c)
        hash = hash[c]
      end
      hash[0].to_a  
    end
  end
  
  def self.anagrams(dictionary, words)
    trie = Trie.new(dictionary)
    words.each { |w| puts "#{w}:", (trie[w] - [w]).sort }
  end
end
