
# s2 est un anagram de s1 s'il a le même nombre de lettres et le même nombre d'occurrence
# de chaque lettre
def isAnagram(s1, s2):
    if(len(s1) == len(s2)):
        for letter in s1:
            if(s1.count(letter) != s2.count(letter)):
                return False
        return True
    return False

# Recupere sous le format attendu le contenu de fileName
def readFile(fileName):
    file = open(fileName, "r")
    text = file.read()
    lines = text.split('\n')
    return lines

# Retrouve les anagrammes de word dans lines et les affiche
def applyFunction(lines, word, function):
    for line in lines:
        if(function(line, word)):
            print(line)
    print(";")

def run(fileName, wordList, function):
    lines = readFile("anagrams")
    print("```")
    for word in wordList:
        applyFunction(lines, word, isAnagram)
    print("```")


# Retrouve les anagrammes de word dans le fichier nomme fileName et les exporte dans le fichier output
def export(lines, word, function, output):
    op = open(output, "w")
    for line in lines:
        if(function(line, word)):
            op.write(line + "\n")
    op.write(";")



run("anagrams", ["foo", "bar", "baz"], isAnagram)
