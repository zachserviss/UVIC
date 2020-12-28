/*
	Name: Zach Serviss
	Student ID: V00950002
*/ 

import java.awt.Color;
import java.util.*;

public class GraphAlgorithms{

	/* FloodFillDFS(v, writer, fillColour)
	   Traverse the component the vertex v using DFS and set the colour 
	   of the pixels corresponding to all vertices encountered during the 
	   traversal to fillColour.
	   
	   To change the colour of a pixel at position (x,y) in the image to a 
	   colour c, use
			writer.setPixel(x,y,c);
	*/
	public static void FloodFillDFS(PixelVertex v, PixelWriter writer, Color fillColour){
		//stack to iterate through 
		Stack<PixelVertex> stack = new Stack<PixelVertex>();
		boolean visited = false;
		//add first clicked pixel to stack
		stack.push(v);
		//arraylist to keep track of visited pixels
		ArrayList<PixelVertex> visitedArray = new ArrayList<PixelVertex>();

		while(!stack.isEmpty()){
			//pop off whatever is in stack
			PixelVertex cur = stack.pop();
			//check if weve seen this pixel before
			for (PixelVertex t: visitedArray) {
				if (t.equals(cur)) {
					visited = true;
				}
			}
			/*if we havent seen it before, colour it and add neighours to the stack, 
			looping through all neighboring pixels colouring them*/
			if (visited == false) {
				visitedArray.add(cur);
				writer.setPixel(cur.getX(), cur.getY(), fillColour);
				for (PixelVertex i: cur.getNeighbours()){
					stack.push(i);
				}
			}
			visited = false;
		}
	}
	
	/* FloodFillBFS(v, writer, fillColour)
	   Traverse the component the vertex v using BFS and set the colour 
	   of the pixels corresponding to all vertices encountered during the 
	   traversal to fillColour.
	   
	   To change the colour of a pixel at position (x,y) in the image to a 
	   colour c, use
			writer.setPixel(x,y,c);
	*/
	public static void FloodFillBFS(PixelVertex v, PixelWriter writer, Color fillColour){
		//queue to iterate through pixels
		LinkedList<PixelVertex> queue = new LinkedList<PixelVertex>();
		boolean visited = false;
		queue.add(v);
		//arraylist to keep track of visited pixels
		ArrayList<PixelVertex> visitedArray = new ArrayList<PixelVertex>();

		while(!queue.isEmpty()){
			//remove first element in queue
			PixelVertex cur = queue.remove();
			//check if weve seen this pixel before
			for (PixelVertex t: visitedArray) {
				if (t.equals(cur)) {
					visited = true;
				}
			}
			/*if we havent seen it before, colour it and add neighours to the queue, 
			looping through all neighboring pixels colouring them*/
			if (visited == false) {
				visitedArray.add(cur);
				writer.setPixel(cur.getX(), cur.getY(), fillColour);
				for (PixelVertex i: cur.getNeighbours()){
					queue.add(i);
				}
			}
			visited = false;
		}
	}
	
}