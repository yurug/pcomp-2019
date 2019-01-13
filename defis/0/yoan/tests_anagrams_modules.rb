require_relative 'anagrams_by_prime_number'
require_relative 'anagrams_by_frequencies'
require_relative 'anagrams_by_trie'
require_relative 'anagrams_by_frequencies_hash'
require_relative 'anagrams_brutal' 
require 'test/unit'

class TestAnagramsModules < Test::Unit::TestCase

  ANAGRAMS_MODULES = [
    AnagramsByPrimeNumber,
    AnagramsBrutal,
    AnagramsByFrequencies,
    AnagramsByTrie,
    AnagramsByFrequenciesHash
  ]
  
  def test_anagrams_in_dic
    dic = ['abc', 'acb', 'bca']
    words = ['abc']
    ANAGRAMS_MODULES.each do |anagrams_module|
      result = anagrams_module.anagrams(dic, words)
      assert_equal result['abc'], ['acb', 'bca']
    end
  end
  
  def test_anagrams_in_words
    dic = ['acbd', 'cabd', 'cbad', 'cdab']
    words = ['abcd', 'abdc']
    ANAGRAMS_MODULES.each do |anagrams_module|
      result = anagrams_module.anagrams(dic, words)
      assert_equal result['abcd'], result['abcd'] 
    end
  end
  
  def test_void_dic
    ANAGRAMS_MODULES.each do |anagrams_module|
      result = anagrams_module.anagrams([], ['ab'])
      assert_equal result['ab'], []
    end
  end
  
  def test_anagrams_are_sorted
    dic = ['abcd', 'abdc', 'acbd', 'acdb', 'adbc', 'adcb']
    ANAGRAMS_MODULES.each do |anagrams_module|
      result = anagrams_module.anagrams(dic, ['bcda'])
      assert_equal result['bcda'], result['bcda'].sort
    end
  end
end
