#import "typst-template-ut/conf.typ" : conf
#set document(title: [Automatic analysis and grading of UTML UML diagrams])

#show: conf.with(
  doctyp: [MSc Thesis],
  authors: (
    (
      name: "Douwe Osinga",
      email: "d.r.osinga@student.utwente.nl",
    ),
  ),
  abstract: lorem(80),
)
#set page("a4", margin: 2cm, numbering: "1")


= Intro
test text

= Bullshit words
#lorem(100)

= More words 
#lorem(1000)
