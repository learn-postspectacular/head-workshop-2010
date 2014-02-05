void setup() {
  Human max=new Human("max");
  max.setAge(150);
  println(max);
  
  Animal turtle=new Animal("ninjaturtle");
  turtle.setAge(150);
  println(turtle.age);
  
  Human cassandre=new Human("cassandre");
  cassandre.buyACar();
  println(cassandre);
}

class Animal {
  String name;
  int age;

  Animal(String n) {
    this.name=n;
  }

  void setAge(int age) {
    this.age=age;
  }
}

class Human extends Animal {
  boolean hasCar;

  Human(String n) {
    super(n);
  }

  void buyACar() {
    hasCar=true;
  }

  void setAge(int age) {
    if (age>130) {
      println("don't think so...");
    } 
    else {
      this.age=age;
    }
  }

  String toString() {
    return "name: "+name+" has car: "+hasCar+" age: "+age;
  }
}

