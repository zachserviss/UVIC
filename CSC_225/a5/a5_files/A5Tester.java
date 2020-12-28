public class A5Tester {

	public static void main(String[] args) {
		h1Test();
		h2Test();
	}
	
	public static void h1Test() {
		HNode r = new HNode("", new HNode("b"), new HNode("c"));
		HNode root = new HNode("", new HNode("a"), r);
		
		HuffmanTree h1 = new HuffmanTree(root);
		String result = h1.decode(new BitQueue("0"));
		System.out.println(result); // should print "a"
		
		result = h1.decode(new BitQueue("01011"));
		System.out.println(result);//abc
		
		result = h1.decode(new BitQueue("100101010110"));
		System.out.println(result);
		
		result = h1.decode(new BitQueue("111101001101001111"));
		System.out.println(result);
		
	}
		
	public static void h2Test() {
		HNode lrr = new HNode("", new HNode("h"), new HNode("l"));
		HNode lr = new HNode("", new HNode("e"), lrr);
		HNode l = new HNode("", new HNode(" "), lr);
		HNode rl = new HNode("", new HNode("a"), new HNode("s"));
		HNode r = new HNode("", rl, new HNode("t"));
		HNode root = new HNode("", l, r);
		
		HuffmanTree h2 = new HuffmanTree(root);
		
		String result = h2.decode(new BitQueue("100001101010111"));
		System.out.println(result);
		
		result = h2.decode(new BitQueue("100001011000111010001001100011110010111"));
		System.out.println(result);
		
		result = h2.decode(new BitQueue("1101100100010110001111100111001011101010100101111000111010"));
		System.out.println(result);
		
		result = h2.decode(new BitQueue("10011000111010100101110011100101110100011010101110011011001000101100011111"));
		System.out.println(result);
	}
}	
			