import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;

public class A4Tester {

	private static int testPassCount = 0;
	private static int testCount = 0;

	public static void main(String[] args) {
		testHeapOperations();

		//Uncomment the following line once you have completed Part 1
		testBSTOperations();

		System.out.println("\nPASSED " + testPassCount + "/" + testCount + " TESTS");

		//Uncomment the following once you have completed Parts 1 and 2

		System.out.println();
		System.out.println("Analysis results:");
		testFrequencyReport(args);

	}

	public static void testHeapOperations() {
		System.out.println("\nStarting Heap Operation Tests");
		Entry e1 = new Entry("word", 6);
		Entry e2 = new Entry("heap", 9);
		Entry e3 = new Entry("bst", 13);
		Entry e4 = new Entry("test", 4);
		Entry e5 = new Entry("computer", 11);
		Entry e6 = new Entry("csc");
		Entry result, expected;

		MaxFrequencyHeap h1 = new MaxFrequencyHeap();
		displayResults(h1.isEmpty(), "Heap test1");
		displayResults(h1.size()==0, "Heap test2");

		h1.insert(e1);
		displayResults(!h1.isEmpty(), "Heap test3");
		displayResults(h1.size()==1, "Heap test4");

		h1.insert(e2);
		h1.insert(e3);

		result = h1.removeMax();
		expected = new Entry("bst", 13);
		if (result != null) {
			displayResults(result.equals(expected), "Heap test5");
		} else {
			displayResults(false, "Heap test5");
		}
		displayResults(!h1.isEmpty(), "Heap test6");
		displayResults(h1.size()==2, "Heap test7");

		h1.insert(e4);
		h1.insert(e5);
		h1.insert(e6);
		displayResults(h1.size()==5, "Heap test8");

		try {
			result = h1.removeMax();
			displayResults(result.equals(e5), "Heap test9");
			result = h1.removeMax();
			displayResults(result.equals(e2), "Heap test10");
			result = h1.removeMax();
			displayResults(result.equals(e1), "Heap test11");
			result = h1.removeMax();
			displayResults(result.equals(e4), "Heap test12");
			result = h1.removeMax();
			displayResults(result.equals(e6), "Heap test13");
		} catch (NullPointerException e) {
			displayResults(false, "One of Heap tests 9 through 13");
		}
		displayResults(h1.isEmpty(), "Heap test14");
	}

	public static void testBSTOperations() {
		System.out.println("\nStarting BST Operation Tests");
		Entry e1 = new Entry("heap", 9);
		Entry e2 = new Entry("test", 4);
		Entry e3 = new Entry("word", 6);
		Entry e4 = new Entry("comp", 11);
		Entry e5 = new Entry("bst", 13);
		Entry e6 = new Entry("csc");
		String expected, returned;
		int expectedFreq, returnedFreq;

		WordFrequencyBST bst = new WordFrequencyBST();
		bst.handleWord("heap");
		bst.handleWord("test");
		bst.handleWord("word");
		bst.handleWord("computer");
		bst.handleWord("bst");
		bst.handleWord("csc");

		expected = "{bst,computer,csc,heap,test,word}";
		returned = bst.inOrder();
    System.out.println(returned);
		displayResults(returned.equals(expected), "bst test1");

		expected = "{heap,computer,bst,csc,test,word}";
		returned = bst.preOrder();
		displayResults(returned.equals(expected), "bst test2");

		expectedFreq = 1;
		returnedFreq = bst.getFrequency("test");
		displayResults(returnedFreq==expectedFreq, "bst test3");

		expectedFreq = 0;
		returnedFreq = bst.getFrequency("science");
		displayResults(returnedFreq==expectedFreq, "bst test4");

		bst.handleWord("bst");
		bst.handleWord("bst");
		bst.handleWord("bst");
		bst.handleWord("csc");

		expectedFreq = 4;
		returnedFreq = bst.getFrequency("bst");
		displayResults(returnedFreq==expectedFreq, "bst test5");

		expectedFreq = 2;
		returnedFreq = bst.getFrequency("csc");
		displayResults(returnedFreq==expectedFreq, "bst test6");

	}

	public static void testFrequencyReport(String[] args) {

		testOverall(args);
		testAtLeastLength(args);
		testStartsWith(args);
	}

	public static void testOverall(String[] args) {
		MaxFrequencyHeap h = init(args);
    //h.print();
		if (h != null) {
			Entry[] results;
			System.out.println("\nOverall most frequent:");
			results = WordFrequencyReport.overallMostFrequent(h);
			printArray(results);
		}
	}

	public static void testAtLeastLength(String[] args) {
		MaxFrequencyHeap h = init(args);

		if (h != null) {
			Entry[] results;
			int minLength = 6;
			System.out.println("\nMost frequent words with "+minLength+" or more characters:");
			results = WordFrequencyReport.atLeastLength(h, minLength);
			printArray(results);
		}
	}

	public static void testStartsWith(String[] args) {
		MaxFrequencyHeap h = init(args);

		if (h != null) {
			Entry[] results;
			char letter = 'i';
			System.out.println("\nMost frequent words starting with a "+letter);
			results = WordFrequencyReport.startsWith(h, letter);
			printArray(results);
		}
	}

	public static void printArray(Entry[] arr) {
		for (int i = 0; i < arr.length; i++) {
			System.out.println(arr[i]);
		}
	}

	public static MaxFrequencyHeap init(String[] args) {
		if (args.length == 0) {
			System.out.println("invalid input arguments - should be: java A4Tester <filename>");
			System.exit(-1);
		}
		try {
			Scanner s = new Scanner(new File(args[0]));
			WordFrequencyBST bst = readFile(s);
			return bst.createHeapFromTree();
		} catch (FileNotFoundException e) {
			System.out.println("Can't find file specified - ensure it is saved in the right location");
			System.exit(-1);
		}
		return null;
	}

	public static WordFrequencyBST readFile(Scanner fileReader) {
		WordFrequencyBST wordTree = new WordFrequencyBST();

		while (fileReader.hasNextLine()) {
			String line = fileReader.nextLine();
			String[] words = line.split("[^a-zA-Z0-9]+");
			for (int i = 0; i < words.length; i++) {
				if (words[i].length() > 0) {
					wordTree.handleWord(words[i].toLowerCase());
				}
			}
		}
		fileReader.close();
		return wordTree;
	}


	public static void displayResults (boolean passed, String testName) {
       /* There is some magic going on here getting the line number
        * Borrowed from:
        * http://blog.taragana.com/index.php/archive/core-java-how-to-get-java-source-code-line-number-file-name-in-code/
        */

        testCount++;
        if (passed)
        {
            System.out.println ("Passed test: " + testName);
            testPassCount++;
        }
        else
        {
            System.out.println ("Failed test: " + testName + " at line "
                                + Thread.currentThread().getStackTrace()[2].getLineNumber());
        }
    }


}
