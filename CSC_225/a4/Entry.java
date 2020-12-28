public class Entry {
	
	private String word;
	private int frequency;
	
	public Entry(String word) {
		this.word = word;
		frequency = 1;
	}
	
	public Entry(String word, int frequency) {
		this.word = word;
		this.frequency = frequency;
	}
	
	public String getWord() {
		return word;
	}
	
	public void addToFrequency() {
		this.frequency++;
	}
	
	public int getFrequency() {
		return this.frequency;
	}

	public boolean equals(Entry other) {
		return word.equals(other.getWord()) && frequency == other.getFrequency();
	}
	
	public String toString() {
		return "{\""+word+ "\", "+frequency+"}";
	}
	
}