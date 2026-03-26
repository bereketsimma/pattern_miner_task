from hyperon import MeTTa  
import time  
  
def time_metta_function(m, code, iterations=10):  
    """Time execution of MeTTa function with 10-run averaging"""  
    times = []  
    result = None  
      
    for _ in range(iterations):  
        start = time.perf_counter()  
        result = m.run(f"! {code}")  
        end = time.perf_counter()  
        times.append(end - start)  
      
    avg_time = sum(times) / len(times)  
    return avg_time, result  
  
def load_metta_file(filepath):  
    """Load a MeTTa file and return the MeTTa instance with code loaded"""  
    m = MeTTa()  
    with open(filepath, 'r') as f:  
        code = f.read()  
    m.run(code)  
    return m  
  
def run_performance_comparison():  
    # Load both implementations  
    print("Loading MeTTa implementations...")  
      
    # Load DSU implementation  
    dsu_metta = load_metta_file("disjoint_conjuction.metta")  
    print("✓ DSU implementation loaded")  
      
    # Load surp-utils implementation  
    surp_metta = load_metta_file("hyperon-miner/experiments/utils/surp-utils/surp-utils.metta")  
    print("✓ surp-utils implementation loaded")  
      
    # Enhanced test cases with complex connection patterns  
    test_cases = [  
        # Basic tests  
        ("Simple disjoint patterns", "(dsu-are-disjoint '(inheritance $x $y) '(inheritance $z $w))"),  
        ("Simple connected patterns", "(dsu-are-disjoint '(inheritance $x $y) '(inheritance $y $z))"),  
          
        # Complex multi-pattern tests  
        ("Complex disjoint patterns", "(dsu-are-disjoint '(inheritance $a $b) '(inheritance $c $d) '(inheritance $e $f))"),  
        ("Complex connected patterns", "(dsu-are-disjoint '(inheritance $a $b) '(inheritance $b $c) '(inheritance $c $d))"),  
          
        # Circular connection tests  
        ("Circular - First to Last", "(dsu-are-disjoint '(inheritance $a $b) '(inheritance $c $d) '(inheritance $d $a))"),  
        ("Circular - Last to First", "(dsu-are-disjoint '(inheritance $x $y) '(inheritance $y $z) '(inheritance $z $x))"),  
        ("Circular - Chain Connection", "(dsu-are-disjoint '(inheritance $p $q) '(inheritance $q $r) '(inheritance $r $s) '(inheritance $s $p))"),  
          
        # Transitive connection tests  
        ("Transitive - Indirect Connection", "(dsu-are-disjoint '(inheritance $a $b) '(inheritance $c $d) '(inheritance $b $c))"),  
        ("Transitive - Multi-step", "(dsu-are-disjoint '(inheritance $w $x) '(inheritance $y $z) '(inheritance $x $y) '(inheritance $z $w))"),  
        ("Transitive - Complex Chain", "(dsu-are-disjoint '(inheritance $m $n) '(inheritance $o $p) '(inheritance $q $r) '(inheritance $n $o) '(inheritance $p $q))"),  
          
        # Edge cases  
        ("Empty pattern test", "(dsu-are-disjoint '(inheritance $x $y) '())"),  
        ("Single variable patterns", "(dsu-are-disjoint '(inheritance $x $x) '(inheritance $y $z))"),  
        ("Identical patterns", "(dsu-are-disjoint '(inheritance $a $b) '(inheritance $a $b))"),  
        ("Large disjoint set", "(dsu-are-disjoint '(inheritance $a1 $b1) '(inheritance $a2 $b2) '(inheritance $a3 $b3) '(inheritance $a4 $b4) '(inheritance $a5 $b5))"),  
        ("Large connected set", "(dsu-are-disjoint '(inheritance $v1 $v2) '(inheritance $v2 $v3) '(inheritance $v3 $v4) '(inheritance $v4 $v5) '(inheritance $v5 $v1))"),  
          
        # Mixed connection patterns  
        ("Mixed - Partial Connection", "(dsu-are-disjoint '(inheritance $x $y) '(inheritance $z $w) '(inheritance $y $z) '(inheritance $a $b))"),  
        ("Mixed - Multiple Components", "(dsu-are-disjoint '(inheritance $p $q) '(inheritance $r $s) '(inheritance $q $r) '(inheritance $t $u) '(inheritance $v $w))"),  
    ]  
      
    print("\n" + "="*80)  
    print("COMPREHENSIVE PERFORMANCE COMPARISON RESULTS")  
    print("="*80)  
      
    # Run tests on DSU implementation  
    print("\n--- DSU Implementation Results ---")  
    dsu_results = {}  
    for name, test_code in test_cases:  
        try:  
            dsu_time, dsu_result = time_metta_function(dsu_metta, test_code)  
            dsu_results[name] = (dsu_time, dsu_result)  
            print(f"{name:<35} {dsu_time:.6f}s - Result: {dsu_result}")  
        except Exception as e:  
            print(f"{name:<35} ERROR - {e}")  
            dsu_results[name] = (None, None)  
      
    # Run tests on surp-utils implementation  
    print("\n--- surp-utils Implementation Results ---")  
    surp_results = {}  
    for name, test_code in test_cases:  
        try:  
            surp_time, surp_result = time_metta_function(surp_metta, test_code)  
            surp_results[name] = (surp_time, surp_result)  
            print(f"{name:<35} {surp_time:.6f}s - Result: {surp_result}")  
        except Exception as e:  
            print(f"{name:<35} ERROR - {e}")  
            surp_results[name] = (None, None)  
      
    # Detailed performance comparison  
    print("\n--- Detailed Performance Comparison ---")  
    print(f"{'Test Case':<35} {'DSU Time':<12} {'surp-utils':<12} {'Speedup':<10} {'Winner'}")  
    print("-" * 80)  
      
    dsu_total = 0  
    surp_total = 0  
    dsu_wins = 0  
    surp_wins = 0  
      
    for name in dsu_results.keys():  
        dsu_time, dsu_result = dsu_results[name]  
        surp_time, surp_result = surp_results[name]  
          
        if dsu_time is not None and surp_time is not None:  
            dsu_total += dsu_time  
            surp_total += surp_time  
              
            if surp_time > 0:  
                speedup = dsu_time / surp_time  
                speedup_str = f"{speedup:.2f}x"  
                winner = "DSU" if dsu_time < surp_time else "surp-utils"  
                if dsu_time < surp_time:  
                    dsu_wins += 1  
                else:  
                    surp_wins += 1  
            else:  
                speedup_str = "N/A"  
                winner = "N/A"  
              
            print(f"{name:<35} {dsu_time:<12.6f} {surp_time:<12.6f} {speedup_str:<10} {winner}")  
        else:  
            print(f"{name:<35} {'ERROR':<12} {'ERROR':<12} {'N/A':<10} {'N/A'}")  
      
    # Summary statistics  
    print(f"\n--- Performance Summary ---")  
    if dsu_total > 0 and surp_total > 0:  
        overall_speedup = dsu_total / surp_total  
        print(f"Total DSU time:     {dsu_total:.6f} seconds")  
        print(f"Total surp-utils:   {surp_total:.6f} seconds")  
        print(f"Overall speedup:    {overall_speedup:.2f}x")  
        print(f"DSU wins:           {dsu_wins} test cases")  
        print(f"surp-utils wins:    {surp_wins} test cases")  
        print(f"Overall winner:     {'DSU' if dsu_total < surp_total else 'surp-utils'}")  
      
    # Correctness verification  
    print(f"\n--- Correctness Verification ---")  
    all_match = True  
    mismatched_cases = []  
      
    for name in dsu_results.keys():  
        dsu_time, dsu_result = dsu_results[name]  
        surp_time, surp_result = surp_results[name]  
          
        if dsu_result is not None and surp_result is not None:  
            match = dsu_result == surp_result  
            status = "✓" if match else "✗"  
            print(f"{status} {name}: Results match = {match}")  
            if not match:  
                all_match = False  
                mismatched_cases.append(name)  
                print(f"   DSU: {dsu_result}")  
                print(f"   surp-utils: {surp_result}")  
        else:  
            print(f"✗ {name}: Could not compare (errors in execution)")  
            all_match = False  
      
    print(f"\nOverall correctness: {'✓ All tests match' if all_match else '✗ Some tests differ'}")  
      
    if mismatched_cases:  
        print(f"Mismatched test cases: {', '.join(mismatched_cases)}")  
      
    # Performance analysis by test category  
    print(f"\n--- Performance Analysis by Category ---")  
    categories = {  
        "Basic Tests": ["Simple disjoint patterns", "Simple connected patterns"],  
        "Circular Connections": ["Circular - First to Last", "Circular - Last to First", "Circular - Chain Connection"],  
        "Transitive Connections": ["Transitive - Indirect Connection", "Transitive - Multi-step", "Transitive - Complex Chain"],  
        "Edge Cases": ["Empty pattern test", "Single variable patterns", "Identical patterns"],  
        "Large Patterns": ["Large disjoint set", "Large connected set"],  
        "Mixed Patterns": ["Mixed - Partial Connection", "Mixed - Multiple Components"]  
    }  
      
    for category, tests in categories.items():  
        dsu_cat_total = sum(dsu_results[test][0] for test in tests if dsu_results[test][0] is not None)  
        surp_cat_total = sum(surp_results[test][0] for test in tests if surp_results[test][0] is not None)  
          
        if dsu_cat_total > 0 and surp_cat_total > 0:  
            cat_speedup = dsu_cat_total / surp_cat_total  
            winner = "DSU" if dsu_cat_total < surp_cat_total else "surp-utils"  
            print(f"{category:<25}: DSU={dsu_cat_total:.6f}s, surp-utils={surp_cat_total:.6f}s, Speedup={cat_speedup:.2f}x, Winner={winner}")  
  
if __name__ == "__main__":  
    run_performance_comparison()