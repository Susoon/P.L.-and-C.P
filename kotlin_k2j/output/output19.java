import java.util.*;
public class output/output19 {
public static Integer getStringLength (Object obj ) {
if(obj !instanceof String )return null;
// 'obj' is automatically cast to 'String' in this branch
return obj.length ;
}
public static void main (String[] args) {
public static Object printLength (Object obj ) {
System.out.println("'$obj' string length is ${getStringLength(obj) ?: ... err, not a string} " );
}
printLength("Incomprehensibilities" );
printLength(1000 );
printLength(List.of(Anyy()));
}
}
 