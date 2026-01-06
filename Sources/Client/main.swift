#if os(macOS)

import Algorithms
import Foundation
import RealModule

@available(macOS 13.0, *)
func Measure<T>(
  _ label: String,
  _ cycles: Int,
  setUp: () -> () = { },
  body: () -> (T),
  condition: (T) -> Bool = { _ in true },
  tearDown: () -> () = { },
) {
  var duration = Duration.nanoseconds(0)
  
  for _ in (1 ... cycles) {
    setUp()
    let clock = ContinuousClock()
    let instant = clock.now
    let result = body()
    duration += instant.duration(to: clock.now)
    precondition(condition(result))
    tearDown()
  }
  
  duration /= cycles
  
  let microseconds = duration.formatted(
    .units(
      allowed: [.microseconds],
      fractionalPart: .show(length: 3)
    )
  )
  print("\(label): \(microseconds)")
}

@available(macOS 13.0, *)
func Benchmark(
  n: Int,
  k: Int,
  cycles: Int
) {
  let a = Array(1 ... n)
  do {
    var temp = a
    Measure("Sort", cycles) {
      temp.shuffle()
    } body: {
      temp.sort()
      return temp[k]
    } condition: { result in
      result == a[k]
    }
  }
  do {
    var temp = a
    Measure("Min", cycles) {
      temp.shuffle()
    } body: {
      return temp.min(count: k + 1)[k]
    } condition: { result in
      result == a[k]
    }
  }
}

func base(_ x: Int) -> Double {
  ((1.0 + Double(x)) / Double(x))
}

func log(_ n: Int, base: Double) -> Double {
  Double.log(Double(n)) / Double.log(base)
}

@available(macOS 13.0, *)
func main() {
  let bases = (0 ... 11).map { base(2 << $0) }
  for base in bases {
    let sizes = [10, 100, 1_000, 10_000, 100_000, 1_000_000]
    for size in sizes {
      print("--- Size: \(size) ---")
      print("--- Base: \(base) ---")
      let log = Int(log(size, base: base))
      print("--- Log: \(log) ---")
      let k = min(
        log,
        (size - 1)
      )
      Benchmark(
        n: size,
        k: k,
        cycles: 100
      )
      print()
    }
  }
}

if #available(macOS 13.0, *) {
  main()
}

//
//  swift run -c release
//
//  --- Size: 100 ---
//  base: 1.001953125
//  log: 2360
//  k: 99
//  Sort: 1.912 μs
//  Min: 1.897 μs
//
//  --- Size: 1000 ---
//  base: 1.001953125
//  log: 3540
//  k: 999
//  Sort: 25.943 μs
//  Min: 27.156 μs
//
//  --- Size: 10000 ---
//  base: 1.001953125
//  log: 4720
//  k: 4720
//  Sort: 356.034 μs
//  Min: 1,125.500 μs
//
//  --- Size: 100000 ---
//  base: 1.001953125
//  log: 5900
//  k: 5900
//  Sort: 4,523.975 μs
//  Min: 5,709.863 μs
//
//  --- Size: 1000000 ---
//  base: 1.001953125
//  log: 7080
//  k: 7080
//  Sort: 55,377.114 μs
//  Min: 14,687.002 μs
//

#endif
