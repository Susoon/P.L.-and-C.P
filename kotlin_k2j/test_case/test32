import java.util.*;
public class Example {
abstract class Shape (final sides ) {
final double perimeter = sides.sum();
abstract final double perimeter = sides.sum()public static double calculateArea () };
interface RectangleProperties {
 final bool isSquare ;
} ;
class Rectangle (height ,  length ) : Shape(List.of(height , length , height , length )), RectangleProperties {
 final bool isSquare = length == height ;
 public static double calculateArea () {
return height * length ;
}
};
class Triangle (sideA , sideB ,  sideC ) : Shape(List.of(sideA , sideB , sideC )){
 public static double calculateArea () {
final double s = perimeter / 2 ;
return Math.sqrt(s * (s - sideA )* (s - sideB )* (s - sideC ));
}
};
public static void main (String[] args) {
final Rectangle rectangle = Rectangle(5.0 , 2.0 );
final Triangle triangle = Triangle(3.0 , 4.0 , 5.0 );
System.out.println("Area of rectangle is ${rectangle.calculateArea()}, its perimeter is ${rectangle.perimeter}" );
System.out.println("Area of triangle is ${triangle.calculateArea()}, its perimeter is ${triangle.perimeter}" );
}
}
 