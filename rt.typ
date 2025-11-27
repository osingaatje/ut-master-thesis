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


= Introduction <intro>
Current state of grading + autograding, University of Twente is looking into ways to save time and money in grading by automating (parts of) it.


= Problem statement <prob-stat> 
Grading takes long time etc. etc.
Want a solution that automatically grades UML diagrams (specifically class/sequence/...?), with as main goals: _transparency_, _consistency_, _fairness_. See initial plan description.

== Research Questions <rqs>


= Related work <relatedwork>
see `./refs.bib`

= Tools and Techniques <tools-techniques>
Adopt existing tool(s), make own tool, what frameworks/languages, ...

= Planning <planning>
TODO: Graduation planning. Phases, goals per phase.


