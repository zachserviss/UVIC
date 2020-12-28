// Name:Zach Serviss
// Student number: V00950002

public class WordFrequencyBST {
	private TreeNode root;
	private int numElements;

	public WordFrequencyBST() {
		root = null;
		numElements = 0;
	}

	/*
	 * Purpose: Update the BST by handling input word
	 * Parameters: String word - The new word to handle
	 * Returns: Nothing
	 * Explanation: If there is no entry in the tree
	 *   representing the word, then the a new entry
	 *   should be created and placed into the correct
	 *   location of the BST. Otherwise, the existing
	 *   entry for the word should have its frequency
	 *   value incremented.
	 */

	public void handleWord(String word) {
    //adding new element then start handling
    numElements++;
    root = handleWordRecursive(root,word);
	}
  //recursive to move through tree to find right place
  public TreeNode handleWordRecursive(TreeNode root,String word) {
    //set word as an Entry
    Entry wordEntry = new Entry(word);
    //first inserting of word, add it and return
    if (root==null) {
      root = new TreeNode(wordEntry);
      return root;
    }
    //wait i've seen this word before, add frequency.
    if (root.compareTo(word) ==0){
      root.addToFrequency();
      numElements--;
      return root;
    }
    //move to the left or right to keep in alphabetical binary order
    if (root.compareTo(word) > 0) {
      root.left = handleWordRecursive(root.left, word);
    }else if (root.compareTo(word) < 0) {
      root.right = handleWordRecursive(root.right, word);
    }
    //bringing it back home
    return root;
  }


	/*
	 * Purpose: Get the frequency value of the given word
	 * Parameters: String word - the word to find
	 * Returns: int - the word's associated frequency
	 */
  //
	public int getFrequency(String word) {
    //get back frequency if we matched a word. if not return 0
    TreeNode cur = getFrequencyRecursive(root, word);
    if (cur != null) {
      int num = cur.getData().getFrequency();
  		return num;
    }else{
      return 0;
    }
	}
  //recursivly move through tree to find word, then its frequency
  public TreeNode getFrequencyRecursive(TreeNode root,String word){
    //matched word or empty BST. eiter way were returning something
    if (root == null || root.compareTo(word) ==0) {
      return root;
    }
    //move down tree with binary search
    if (root.compareTo(word) > 0) {
      return getFrequencyRecursive(root.left, word);
    }
    return getFrequencyRecursive(root.right, word);
  }


	/****************************************************
	* Helper functions for Insertion and Search testing *
	****************************************************/

	public String inOrder() {
		if (root == null) {
			return "empty";
		}
		return "{" + inOrderRecursive(root) + "}";
	}

	public String inOrderRecursive(TreeNode cur) {
		String result = "";
		if (cur.left != null) {
			result = inOrderRecursive(cur.left) + ",";
		}
		result += cur.getData().getWord();
		if (cur.right != null) {
			result += "," + inOrderRecursive(cur.right);
		}
		return result;
	}

	public String preOrder() {
		if (root == null) {
			return "empty";
		}
		return "{" + preOrderRecursive(root) + "}";
	}

	public String preOrderRecursive(TreeNode cur) {
		String result = cur.getData().getWord();
		if (cur.left != null) {
			result += "," + preOrderRecursive(cur.left);
		}
		if (cur.right != null) {
			result += "," + preOrderRecursive(cur.right);
		}
		return result;
	}

	/****************************************************
	* Helper functions to populate a Heap from this BST *
	****************************************************/

	public MaxFrequencyHeap createHeapFromTree() {
		MaxFrequencyHeap maxHeap = new MaxFrequencyHeap(numElements+1);
		addToHeap(maxHeap, root);
		return maxHeap;
	}

	public void addToHeap(MaxFrequencyHeap h, TreeNode n) {
		if (n != null) {
			addToHeap(h, n.left);
			h.insert(n.getData());
			addToHeap(h, n.right);
		}
	}
}
