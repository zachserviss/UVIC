// Name:Zach Serviss
// Student number: V00950002

public class MaxFrequencyHeap implements PriorityQueue {

	private static final int DEFAULT_CAPACITY = 10;
	private Entry[] data;
	private int size;

	public MaxFrequencyHeap() {
		data = new Entry[DEFAULT_CAPACITY];
		size = 0;
	}

	public MaxFrequencyHeap(int size) {
		data = new Entry[size];
		size = 0;
	}

	public void insert(Entry element) {
    //start with 1 instead of zero
    data[++size] = element;
    //cur is the index we're currently working with
    int cur = size;
    //if the node has a parent, check to make sure we maintain heap
    if (data[parent(cur)]!=null) {
      //swap and bubble up max number if inserted
      while (data[parent(cur)]!=null && (data[cur].getFrequency() > data[parent(cur)].getFrequency())) {
        swap(cur, parent(cur));
        cur = parent(cur);
    }
  }


	}

	public Entry removeMax() {
    //first element is the max
    Entry popped = data[1];
    //if removing last element do a couple extra things, if not just remove and heapify heap
    if (size()>1) {
      data[1] = data[size--];
      maxHeapify(1);
    }else{
      size--;
      data[1] = null;
    }
    return popped;
	}

	public boolean isEmpty() {
    if (size == 0) {
      return true;
    }else if (size != 0) {
      return false;
    }
    return true;
	}

	public int size() {
		return size;
	}
  //helper to get parent
  public int parent(int cur){
    return cur / 2;
  }
  //helper to get children
  public int leftChild(int cur) {
    return (2 * cur);
  }
  public int rightChild(int cur){
    return (2 * cur) + 1;
  }
  //helper to decide if node is leaf
  public boolean isLeaf(int cur){
    if (cur >= (size / 2) && cur <= size) {
      return true;
    }
    return false;
  }

  public void swap(int cur, int parent){
    Entry tmp = data[cur];
    data[cur] = data[parent];
    data[parent] = tmp;
  }
  //heres the magic everyone came for
  public void maxHeapify(int cur){
    //if we removed a leaf were good! lets go home
    if (isLeaf(cur))
        return;
    //check for childern larger than parent, then pinpoint issue
    if ((data[cur].getFrequency() < data[leftChild(cur)].getFrequency())||(data[cur].getFrequency() < data[rightChild(cur)].getFrequency())){
      //if the left child is the largest one, swap and check again
      if (data[leftChild(cur)].getFrequency() > data[rightChild(cur)].getFrequency()) {
          swap(cur, leftChild(cur));
          maxHeapify(leftChild(cur));
      //it was the right child
      } else {
          swap(cur, rightChild(cur));
          maxHeapify(rightChild(cur));
      }
    }
  }
  public void print() {
        for (int i = 1; i <= size / 2; i++) {
            System.out.print(" PARENT : " + data[i] + " LEFT CHILD : " +
                      data[2 * i] + " RIGHT CHILD :" + data[2 * i + 1]);
            System.out.println();
        }
    }

}
