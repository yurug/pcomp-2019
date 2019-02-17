package test_unit
import org.junit.Assert._;
import donnees._;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import junit.framework.TestCase

class Test_gestionnaire_dependance extends TestCase {
    	var f : FeuilleSimple = null 
  @Before
  	override def setUp() {
    f= new FeuilleSimple("test/data.csv","test/view0.csv")
    f.copyF()
    }
  
  @Test
  def test_dependance_correct() = {
    val dep = new GestionnaireDependance(f)
    dep.addDependanceToList()
    val size = f.listFormule.size
    assertFalse("listFormule size: "+size ,size == 0)
  }
}