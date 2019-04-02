package util
class Graph[N, L<:Connection[N]]
(private var _nodes: List[N] = Nil, 
    private var _links: List[L] = Nil) {


  final def getNodes : List[N] = { return _nodes }

  final def getLinks : List[L] = { return _links }


  final def addNode(node : N) : Boolean = {
    _nodes = node::_nodes
    return true
  }

  final def addLink(link : L) : Boolean = {
    if(_nodes.contains(link.getStart) && _nodes.contains(link.getFinish)) {
      _links = link::_links
      return true
    }
    return false
  }


  final def removeLink(link: L): Unit = { _links = _links.filter(_ != link) }

  final def removeNode(node: N): Unit = {
    for(link <- _links) {
      if(link.getStart == node || link.getFinish == node) { _links = _links.filter(_ != link) }
    }
    _nodes = _nodes.filter(_ != node)
  }
  
  final def neighbour_of(node : N) : List[N] = {
    def is_neighbour (n:N, c:Connection[N]) = if (n == c.getStart) {true} else {false}
    _links.filter(is_neighbour(node,_)).map(l => l.getFinish)  
  }
  
  final def predecessor_of(node: N) :List[N] ={
    def is_predecessor (n:N, c:Connection[N]) = if (n == c.getFinish) {true} else {false}
    _links.filter(is_predecessor(node,_)).map(l => l.getStart)  
  }
  
  final def contains(node : N) : Boolean = { return _nodes.contains(node) }

  final def areLinked(start : N, finish : N) : Boolean = {
    for(link <- _links) {
      if(link.getLink == (start, finish)) { return true }
    }
    return false
  }

}
