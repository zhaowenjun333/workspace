package org.comparable;

public class User implements Comparable<User> {

	
	int id;
    String name;
    
    public User(int id,String name){
        this.id = id;
        this.name = name;
    }
    /*
     * Getters and Setters
    */
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
       
    
	public int compareTo(User o) {
		// TODO Auto-generated method stub
		System.out.println("source "+ id +" compareTo " +o.id);
		if(id > o.getId()){
			return 1;
		}
		if(id < o.getId()){
			return -1;
		}
		return 0;
	}

}
