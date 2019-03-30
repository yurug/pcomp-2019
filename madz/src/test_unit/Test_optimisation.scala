package test_unit
import org.junit.Assert._;
import donnees._;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import junit.framework.TestCase
class Test_optimisation {
  def test_defi2 = {
		    val f= new FeuilleSimple("data.csv","view0.txt")
		    val I = new DataInterpreteur(f)
		    I.evalCellules()
		    I.writeView(args(2))
		    }
}