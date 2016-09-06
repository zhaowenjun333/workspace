package org.comparable;

import java.util.ArrayList;
import java.util.Collections;

public class UserTest {

	
	 public static void main(String[] args) {
		 
	        ArrayList<User> student = new ArrayList<User>();
	        User user1 = new User(1,"1");
	        User user2 = new User(2,"2");
	        User user3 = new User(3,"3");
	        User user4 = new User(4,"4");
	        User user5 = new User(2,"2");
	        
	        student.add(user1);
	        student.add(user2);
	        student.add(user3);
	        student.add(user4);
	        student.add(user5);
	        
	        Collections.sort(student);//用我们写好的Comparator对student进行排序
	        
	        for(int i=0;i<student.size();i++){
	            System.out.println(student.get(i).getId());
	        }
	        
	    }
	 
	
}
