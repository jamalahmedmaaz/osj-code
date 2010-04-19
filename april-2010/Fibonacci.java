public class Fibonacci {

    public static void main(String[] args) {
	System.out.println(fib_recur(Integer.parseInt(args[0])));
    }

    public static int fib(int n) {
      int f = 0, g = 1;

      for (int i = 1; i <= n; i++) {
         f = f + g;
         g = f - g;
      }
      return f;
    }

    public static int fib_recur(int n) {
	if(n <= 1) {
	    return n;
	} else {
	    return fib_recur(n-1) + fib_recur(n-2);
	}
	
    }
}