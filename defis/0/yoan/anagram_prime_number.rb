require 'prime'

class String
  PRIMES = Prime.each
  LETTERS_VALUE = Hash.new { |h, k| h[k] = PRIMES.next }
  
  def value
    each_char.map { |c| LETTERS_VALUE[c] }.reduce(:*)
  end
end

# Puts anagram of words present in dictionary. For that, map each letter to
# a prime number and then map a string to the product of its letter map.
# Since the product is commutative, this value is invariant by anagrams.
# Hence, we just have to create a hash where a list of words is associated
# to its value. The anagrams of a word w is then hash[w.value].
module AnagramsPrimeNumber
  def self.anagrams(dictionary, words)
    hash = dictionary.each.with_object(Hash.new { |h, k| h[k]=[] }) do |w, h|
      h[w.value] << w
    end
    words.each { |w| puts "#{w}:", (hash[w.value] - [w]).sort }
  end
end
