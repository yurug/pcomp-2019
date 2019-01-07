import scala.io.Source

object Anagram extends App {

  val f = Source.fromFile(args(0)).getLines

  for (i <- 1 to args.length - 1) {
    println(args(i) + ":")

    f.foreach(w =>
      if (matches(args(i), w))
        println(w)
    )
  }

  def matches(w1: String, w2: String): Boolean = {
    if (w1.length != w2.length) {
      false
    }

    val set = w1.toSet

    for (c <- set)
      if (w1.count(_ == c) != w2.count(_ == c))
        false

    true
  }

}
