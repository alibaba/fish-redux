/// Jenkins hash function, optimized for small integers.
///
/// Borrowed from the dart sdk: sdk/lib/math/jenkins_smi_hash.dart.
int hash(Iterable<int> values) {
  int hash = 0;

  /// combine
  for (int value in values) {
    hash = 0x1fffffff & (hash + value);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    hash = hash ^ (hash >> 6);
  }

  /// finish
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash = hash ^ (hash >> 11);
  return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}
