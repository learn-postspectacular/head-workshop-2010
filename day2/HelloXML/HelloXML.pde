XMLElement xml;

void setup() {
  size(200, 200);
  xml = new XMLElement(this, "addressbook.xml");
  int numPeople = xml.getChildCount();
  println(numPeople);
  for (int i = 0; i < numPeople; i++) {
    XMLElement person = xml.getChild(i);
    String name=person.getChild(0).getContent();
    String addr=person.getChild(1).getContent();
    String tel=person.getChild(2).getContent();
    println(name+" "+addr+" "+tel);
  }
}

