public class BitQueue {
	Node front;
	Node back;
	
	public BitQueue() {
		front = null;
		back = null;
	}
	
	public BitQueue(String inputData) {
		front = null;
		back = null;
		for (int i = 0; i < inputData.length(); i++) {
			enqueue(inputData.substring(i,i+1));
		}
	}
	
	public void enqueue(String bit) {
		if (isEmpty()) {
			front = new Node(bit);
			back = front;
		} else {
			back.next = new Node(bit);
			back = back.next;
		}
	}
	
	public String dequeue() {
		if (isEmpty()) {
			System.out.println("No bits left");
			return null;
		}
		String toReturn = front.bit;
		front = front.next;
		return toReturn;
	}
	
	public boolean isEmpty() {
		return front==null;
	}
}	
	
class Node {
	String bit;
	Node next;
	
	Node(String bit) {
		this.bit = bit;
		next = null;
	}
}