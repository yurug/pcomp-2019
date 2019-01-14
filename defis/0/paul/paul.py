
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
def applyFunction(fileName, word, function):
    file = open(fileName, "r")
    text = file.read()
    lines = text.split('\n')
    for line in lines:
        if(function(line, word)):
            print(line)
    print(";")

# Retrouve les anagrammes de word dans le fichier nomme fileName et les exporte dans le fichier output
def export(fileName, word, function, output):
    file = open(fileName, "r")
    op = open(output, "w")
    text = file.read()
    lines = text.split('\n')
    for line in lines:
        if(function(line, word)):
            op.write(line + "\n")
    op.write(";")


applyFunction("anagrams", "foo", isAnagram)
applyFunction("anagrams", "bar", isAnagram)
applyFunction("anagrams", "baz", isAnagram)
export("anagrams", "foo", isAnagram, "output")
