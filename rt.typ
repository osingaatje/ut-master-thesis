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
Work @Hosseinibaghdadabadi2023 @anas2021 @batmaz2010 @Bian2019 @Bian2020 @Foss2022 @Jebli2023 @Modi2021 @Ali2007 @Ali2007b @thomas2006 @thomas2004 @thomas2009 @thomas2008 @Striewe2011 @Smith2013

More focused on interactivity: @Foss2022b 

Work on AI @Bouali2025 @Stikkolorum2019
(nondeterminism of AI @he2025 @brenndoerfer2025 @atil2025 + counterarg: inherent lack of transparency, risks of nondeterminism in grading (see sources) == bad because same solution might not give same grade), lack of consistency (contexxt window, importance of reducing prompt length, ...)

Experience on TAs @Ahmed2024

Reliability of human marking/grading in general @Meadows2005


= Tools and Techniques <tools-techniques>
Adopt existing tool(s), make own tool, what frameworks/languages, ...

= Planning <planning>
TODO: Graduation planning. Phases, goals per phase.


#pagebreak()
#bibliography("refs.bib")

