import java.util.*;
public class output/output24 {
public static String describe (Object obj ) {
switch(obj ){
case 1 : return "One";
case "Hello": return "Greeting";
caseinstanceof long : return "Long";
case!instanceof String : return "Not a string";
default: return "Unknown"}
}
public static void main (String[] args) {
System.out.println(describe(1 ));
System.out.println(describe("Hello" ));
System.out.println(describe(1000L ));
System.out.println(describe(2 ));
System.out.println(describe("other" ));
}
}
 