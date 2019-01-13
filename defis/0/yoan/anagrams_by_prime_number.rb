require 'prime'

class String
  PRIMES = Prime.each
  LETTERS_VALUE = Hash.new { |h, k| h[k] = PRIMES.next }
  
  def value
    each_char.map { |c| LETTERS_VALUE[c] }.reduce(:*)
  end
end

# Map each letter to a prime number, and map a string to the product of the 
# value associated to its letters. Since the product is commutative and because 
# of the unicity of the prime factorization, two strings are associated to the 
# same value iff they are anagrams.
# Hence, we just have to create a hash where a list of words is associated
# to its value. The anagrams of a word w is then hash[w.value].
module AnagramsByPrimeNumber
  def self.create_prime_value_hash(dictionary)
    dictionary.each.with_object(Hash.new { |h, k| h[k]=[] }) do |w, h|
      h[w.value] << w
    end
  end
  
  def self.anagrams(dictionary, words)
    hash = create_prime_value_hash(dictionary)
    words.each.with_object({}) { |w, h| h[w] = (hash[w.value] - [w]).sort }
  end
end
