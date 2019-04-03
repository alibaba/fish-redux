typedef TypedApplyLike<R> = R Function(List<dynamic>, [Map<Symbol, dynamic>]);

/// Unified abstraction of functions which used in [Function.apply]
typedef ApplyLike = dynamic Function(List<dynamic>, [Map<Symbol, dynamic>]);

/// Unified abstraction of function AOP, input one function output another with some enhancement inside.
typedef ApplyLikeEnhancer = ApplyLike Function(ApplyLike functor);

ApplyLike _identity(ApplyLike f) => f;

ApplyLikeEnhancer _combine(ApplyLikeEnhancer e0, ApplyLikeEnhancer e1) =>
    (ApplyLike f) => (e1 ?? _identity)((e0 ?? _identity)(f));

const ApplyLikeEnhancer ApplyLikeEnhancerIdentity = _identity;

/// Implement AOP with Currying tec.
/// [AOP]: https://en.wikipedia.org/wiki/Aspect-oriented_programming
/// [Currying]: https://en.wikipedia.org/wiki/Currying
/// Process
/// 1. Input user [Function]
/// 2. Cast to [ApplyLike]
/// 3. Add some enhancement (by [ApplyLikeEnhancer])
/// 4. Get new [ApplyLike]
/// 5. Cast to [TypedApplyLike]
/// 6. Cast to user [Function]
class AOP {
  final ApplyLikeEnhancer _enhancer;

  AOP(List<ApplyLikeEnhancer> enhances)
      : _enhancer = enhances?.isNotEmpty == true
            ? enhances.reduce(_combine)
            : ApplyLikeEnhancerIdentity;

  TypedApplyLike<R> enhance<R>(Function functor) {
    /// cast functor to ApplyLike
    final ApplyLike init = (List<dynamic> positionalArguments,
            [Map<Symbol, dynamic> namedArguments]) =>
        Function.apply(functor, positionalArguments, namedArguments);

    /// enhance ApplyLike
    final ApplyLike enhanced = _enhancer(init);

    /// if not enhanced
    if (init == enhanced) {
      return null;
    }

    /// cast ApplyLike to TypedApplyLike<R>
    return (List<dynamic> positionalArguments,
        [Map<Symbol, dynamic> namedArguments]) {
      final R result = enhanced(positionalArguments);
      return result;
    };
  }

  R Function() withZero<R>(R Function() f) {
    final TypedApplyLike<R> enhanced = enhance<R>(f);
    return enhanced != null ? () => enhanced(<dynamic>[]) : f;
  }

  R Function(P) withOne<R, P>(R Function(P) f) {
    final TypedApplyLike<R> enhanced = enhance<R>(f);
    return enhanced != null ? (P p) => enhanced(<dynamic>[p]) : f;
  }

  R Function(P0, P1) withTwo<R, P0, P1>(R Function(P0, P1) f) {
    final R Function(List<dynamic>) enhanced = enhance<R>(f);
    return enhanced != null ? (P0 p0, P1 p1) => enhanced(<dynamic>[p0, p1]) : f;
  }

  R Function(P0, P1, P2) withThree<R, P0, P1, P2>(R Function(P0, P1, P2) f) {
    final TypedApplyLike<R> enhanced = enhance<R>(f);
    return enhanced != null
        ? (P0 p0, P1 p1, P2 p2) => enhanced(<dynamic>[p0, p1, p2])
        : f;
  }

  R Function(P0, P1, P2, P3) withFour<R, P0, P1, P2, P3>(
      R Function(P0, P1, P2, P3) f) {
    final TypedApplyLike<R> enhanced = enhance<R>(f);
    return enhanced != null
        ? (P0 p0, P1 p1, P2 p2, P3 p3) => enhanced(<dynamic>[p0, p1, p2, p3])
        : f;
  }

  R Function(P0, P1, P2, P3, P4) withFive<R, P0, P1, P2, P3, P4>(
      R Function(P0, P1, P2, P3, P4) f) {
    final TypedApplyLike<R> enhanced = enhance<R>(f);
    return enhanced != null
        ? (P0 p0, P1 p1, P2 p2, P3 p3, P4 p4) =>
            enhanced(<dynamic>[p0, p1, p2, p3, p4])
        : f;
  }

  R Function(P0, P1, P2, P3, P4, P5) withSix<R, P0, P1, P2, P3, P4, P5>(
      R Function(P0, P1, P2, P3, P4, P5) f) {
    final TypedApplyLike<R> enhanced = enhance<R>(f);
    return enhanced != null
        ? (P0 p0, P1 p1, P2 p2, P3 p3, P4 p4, P5 p5) =>
            enhanced(<dynamic>[p0, p1, p2, p3, p4, p5])
        : f;
  }
}
