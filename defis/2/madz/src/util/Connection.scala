package util
case class Connection[N]( _start: N, _finish: N) {


  def getStart: N = { return _start }

  def getFinish: N = { return _finish }


  def getLink: (N, N) = { return (_start, _finish) }
}
