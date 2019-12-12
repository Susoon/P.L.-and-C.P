import java.util.*;
public class output/output15 {
public static String printProduct (String arg1 , String arg2 ) {
final String x = parseInt(arg1 );
final String y = parseInt(arg2 );
// Using 'x * y' yields error because they may hold nulls.
if(x != null&& y != null){
// x and y are automatically cast to non-nullable after null check
System.out.println(x * y );
}
else{
System.out.println("'$arg1' or '$arg2' is not a number" );
}
}
}
 