
# s2 est un anagram de s1 s'il a le même nombre de lettres et le même nombre d'occurrence
# de chaque lettre
def isAnagram(s1, s2):
    if(len(s1) == len(s2)):
        for letter in s1:
            if(s1.count(letter) != s2.count(letter)):
                return False
        return True
    return False

# Retrouve les anagrammes de word dans le fichier nomme fileName et les affiche
def findAnagrams(fileName, word):
    file = open(fileName, "r")
    text = file.read()
    lines = text.split('\n')
    for line in lines:
        if(isAnagram(line, word)):
            print(line)
    print(";")


findAnagrams("anagrams", "foo")
findAnagrams("anagrams", "bar")
findAnagrams("anagrams", "baz")
