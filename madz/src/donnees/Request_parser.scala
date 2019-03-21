package donnees

/*
 * parse request of format specified in below specification:
 * Pour chaque ligne `r c d` du fichier `user.txt` initial et tel que  `rI cI vI` indique qu’après l’exécution de la commande `r c d` la  valeur de la cellule à la rI-ième ligne et la c*-ième colonne  vaut l’entier vI.
 */
trait Request_parser {
  def parser (data: Array[String]) = data match{
			  case null => null
			  case _ => if (data.length == 3){
			    new Estimate_change(
				Case(Integer.parseInt(data(0)),Integer.parseInt(data(1))),
				DataParser.parseData(data(2))
			)
			  } else { 
			    //new java.util.zip.DataFormatException().printStackTrace()
			    null}
	    
			}
}