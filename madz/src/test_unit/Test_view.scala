
package test

import org.junit.Assert._;
import donnees._;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import junit.framework.TestCase

class Test_view0 extends TestCase {
    	var f : FeuilleSimple = null 
  @Before
  	override def setUp() {
    f= new FeuilleSimple("test/data.csv","test/view0.csv")
    f.copyF()
    }
  
  @Test
  def test_dependance_correct() = {
    f= new FeuilleSimple("test/data.csv","test/view0.csv")    
    val dep = new GestionnaireDependance(f)
    dep.addDependanceToList()
      /*{
    if (args.length <4) {
        println("4 agrs minimum")
    }
    val f= new FeuilleSimple(args(0))
    f.loadCalc()
    val I = new DataInterpreteur(f)
    I.evalCellules()
    I.writeView(args(2))
    */
    val size = f.listFormule.size
    assertFalse("listFormule size: "+size ,size == 0)
  }
}