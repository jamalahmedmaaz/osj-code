public class LazyEvaluation {

    public static void main(String[] args) {
        LazyEvaluation eval = new LazyEvaluation();
        System.out.printf("%s\n", eval.fancy_if(true, 1 + 2, 3 + 4 ));
    }

    public <T> T fancy_if(boolean condition, T trueCase, T falseCase) {
        return condition ? trueCase : falseCase;
    }
}