class KnowException implements Exception{
  @override
  bool operator ==(dynamic other) => other is KnowException;
}

class UnKnowException implements Exception{
  @override
  bool operator ==(dynamic other) => other is UnKnowException;
}