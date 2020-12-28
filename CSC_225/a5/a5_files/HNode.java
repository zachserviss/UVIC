/*
 * A Huffman Tree Node.
 * A pretty straightforward node with links to left and
 * right children, and the letter associated with the 
 * Huffman encoding for leaf nodes.
 */
public class HNode {
	String letter;
	HNode left;
	HNode right;
	
	public HNode(String letter) {
		this(letter, null, null);
	}
	
	public HNode(String letter, HNode left, HNode right) {
		this.letter = letter;
		this.left = left;
		this.right = right;
	}
}	
