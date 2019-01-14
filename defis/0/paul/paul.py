def isAnagram(s1, s2):
    if(len(s1) == len(s2)):
        for letter in s1:
            # print(s1.count(letter))
            # print(s2.count(letter))
            if(s1.count(letter) != s2.count(letter)):
                return False
        return True
    return False

# Retrouve les anagrammes de word dans le fichier nomme fileName et les affiche
def findAnagrams(fileName, word):
    file = open(fileName, "r")
    output = open("output", "w")
    text = file.read()
    lines = text.split('\n')
    anagrams = []
    for line in lines:
        if(isAnagram(line, word)):
            print(line)
    print(";")


findAnagrams("anagrams", "foo")
findAnagrams("anagrams", "bar")
findAnagrams("anagrams", "baz")
