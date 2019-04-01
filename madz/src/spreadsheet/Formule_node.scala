package spreadsheet

class Formule_node {
  private var expression: Formule = null
  private var value: Value = null
  private var position: Case = null
  def get_expression =  expression
def set_expression (f:Formule)= {this.expression = f}
def get_value = value
def set_value(v:Value) = {this.value = v}
def get_position = position
def set_position(v:Case) = {this.position = v}
}