According to benchmark, the ranking is the following.

1. Prime number O(NK + MK) (does not consider prime numbers computation time).
2. Frequencies O((N + M) K LN(K)).
3. Trie O((N + M) K LN(K)).
4. Frequencies_Hash O(NK + MK).
5. Brutal O(too much).

When no too long words, `Brutal` is very efficient.

If the dictionary is already sorted, some operations are useless in the code,
but it is not specified, then I kept these operations. But because of this,
it is certainly impossible to reach a O(NK + MK) time complexity.
