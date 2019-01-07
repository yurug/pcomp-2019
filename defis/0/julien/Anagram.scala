import scala.io.Source

object Anagram extends App {

  for (i <- 1 to args.length - 1) {
    printAnagrams(args(i), args(0))
  }

  def printAnagrams(word: String, filename: String): Unit = {
    println(word + ":")

    val list = getAnagrams(word, filename).sorted

    list.foreach(println)
  }

  def getAnagrams(word: String, filename: String): List[String] =
    Source.fromFile(filename).getLines.filter(w => checkAnagramity(word, w)).toList

  def checkAnagramity(w1: String, w2: String): Boolean = {
    if (w1.length != w2.length) {
      return false
    }

    val set = w1.toSet

    for (c <- set) {
      if (w1.count(_ == c) != w2.count(_ == c)) {
        return false
      }
    }

    return true
  }

}
