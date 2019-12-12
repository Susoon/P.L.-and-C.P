import java.util.*;
public class output/output11 {
public static void main (String[] args) {
 int a = 1 ;
// simple name in template:
final String s1 = "a is $a";
a = 2 ;
// arbitrary expression in template:
final String s2 = "${s1.replace(is, was)}, but now is $a";
System.out.println(s2 );
}
}
 