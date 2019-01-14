all: anagram
	$(info *** Use "make command" to execute "/usr/bin/time java anagram mydict foo bar baz" ***)

anagram: anagram.java
	javac anagram.java

command: anagram
	/usr/bin/time java anagram mydict foo bar baz