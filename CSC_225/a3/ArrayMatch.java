/*
 * CSC 225 - Assignment 3
 * Name: Zach Serviss
 * Student number: V00950002
 */

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;
import java.util.NoSuchElementException;

import java.util.Arrays;

public class ArrayMatch {

	/*
	 * match
	 * Purpose: Determine if the two given arrays 'match'
	 * Parameters: int[] a, int[] b - the two arrays
	 * Returns: boolean - true if arrays 'match', false otherwise
	 * Preconditions: a and b have the same number of elements
	 */

  public static boolean duplicate(int[] a, int[] b) {

    boolean duplicate = true;
    for (int i =0;i <(a.length);i++) {
      if (a[i]!=b[i]) {
        duplicate = false;
      }
    }
    return duplicate;
  }
	public static boolean match(int[] a, int[] b) {
		// TODO complete the implementation

    //check if two arrays are duplicates of eachother and return
    boolean duplicate = duplicate(a,b);
    if(duplicate) return duplicate;
    int size = a.length;
    //check if array is even, else return false
    if ((a.length %2 ==0) && (b.length %2 ==0)) {
      int[] a1 = new int[size/2];
      int[] a2 = new int[size/2];
      int[] b1 = new int[size/2];
      int[] b2 = new int[size/2];
      //first array split
      for (int i =0;i<size ;i++) {
        if (i < size/2)
          a1[i] = a[i];
        if (i >= size/2)
          a2[i-(size/2)] = a[i];
      }
      //second array split
      for (int i =0;i<size ;i++) {
        if (i < size/2)
          b1[i] = b[i];
        if (i >= size/2)
          b2[i-(size/2)] = b[i];
      }

      //check sub array for match in pairs
      boolean a1b1 = duplicate(a1,b1);
      boolean a1b2 = duplicate(a1,b2);
      boolean a2b1 = duplicate(a2,b1);
      boolean a2b2 = duplicate(a2,b2);

      //check for logical statements and return if true
      if ((a1b1 && a2b2)==true)
        return true;
      else if ((a1b1 && a1b2)==true)
        return true;
      else if((a2b1 && a2b2)==true)
        return true;

      //start recursing on sub arrays
      if (match(a1,b1))
        return true;
      if (match(a2,b2))
        return true;


    }

		return false; // change this - set to false so it compiles
	}

	/*
	 * fillArray
	 * Purpose: Fills arrays with contents read from Scanner
	 * Parameters: int[] x, Scanner fileReader
	 * Returns: nothing
	 */
	public static void fillArray(int[] x, Scanner fileReader) throws NoSuchElementException {
		Scanner f = new Scanner(fileReader.nextLine());
		for (int i = 0; i < x.length; i++) {
			x[i] = f.nextInt();
		}
	}

	/*
	 * a3Setup
	 * Purpose: Initializes the input arrays for Assignment 3 match detection
	 *          by reading data from the text file named fname
	 * Parameters: String fname - name of the file containig input data
	 * Returns: nothing
	 */
	public static void a3Setup(String fname) {
		Scanner fileReader = null;
		int[] A = null;
		int[] B = null;

		try {
			fileReader = new Scanner(new File(fname));
		} catch (FileNotFoundException e) {
			System.out.println("Error finding input file");
			e.printStackTrace();
			return;
		}

		try {
			int size = Integer.parseInt(fileReader.nextLine());
			A = new int[size];
			B = new int[size];
			fillArray(A, fileReader);
			fillArray(B, fileReader);
		} catch (NoSuchElementException e) {
			System.out.println("Error reading input file data");
			e.printStackTrace();
		}

		if (match(A,B)) {
			System.out.println("match found");
		} else {
			System.out.println("no matches");
		}
	}

	public static void main(String[] args) {
		if (args.length < 1) {
			System.out.println("Incorrect usage, should be:");
			System.out.println("java MysteryArray filename.txt");
			return;
		}
		a3Setup(args[0]);
	}
}
