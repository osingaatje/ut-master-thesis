#import "typst-template-ut/conf.typ" : conf
#set document(title: [Automatic analysis and grading of UTML UML diagrams])

#show: conf.with(
  doctyp: "Research Topics",
  //date: "2026-..-..",
  authors: (
    (
      name: "Douwe Osinga",
      email: "d.r.osinga@student.utwente.nl",
    ),
  ),
  supervisors: (
    (
      name: "dr. ir. Vadim Zaytsev",
      email: "v.zaytsev@utwente.nl",
    // institution: "University of Twente",
    ),
    (
      name: "dr. Nacir Bouali",
      email: "n.bouali@utwente.nl",
    ),
  ),
  faculty: "Faculty of Electrical Engineering, Mathematics, and Computer Science",
  abstract: lorem(80),
)
#set page("a4", margin: 2cm, numbering: "1")


// highlight styling
#set highlight(radius: 2pt)


= Introduction <intro>
// Current state of grading + autograding, University of Twente is looking into ways to save time and money in grading by automating (parts of) it.

UML diagrams play a significant role in computer science, as they allow for communicating system designs in a standardised format. During technical studies, students are often required at some point to make a UML diagram for a graded assignment or exam.

However, the grading of these diagrams can often be a costly and lengthy process, involving multiple paid members of staff. Therefore, the automation of this task is an interesting topic.

In this Research Topics paper, I examine the current state of autograding diagrams and propose #highlight("something - TODO proposal").


= Problem statement <prob-stat> 
The grading of (UML) diagram submissions by students can often be a costly and lengthy process, involving multiple paid members of staff, which can take multiple hours of active work#footnote("From personal experience.").

The automatisation of grading diagrams could reduce the cost and time required for universities and other institutions, providing financial benefit for universities and allowing for quicker grading times. Of course, these solutions must not be worse than human grading in terms of accuracy, consistency, and fairness.

Specifically, we are interested in the automatic grading of UTML UML diagrams, a recent in-house developed diagram format of the University of Twente @utml .

== Research Questions <rqs>
In order to examin the feasibility of automatically grading UML diagrams, we provide a main research question (*MRQ*), supported by research questions (*RQs*).

#align(center, [
  *To what extent can (UTML) UML diagrams be graded automatically?*
])

We aim to answer the main research question with the following sub-research questions:

#box(inset: (left: 10pt), [
*RQ1*: What existing solutions exist for automatically analysing and/or grading UML diagrams?

*RQ2*: To what extent can Intended Learning Objectives be translated into autograder instructions?

*RQ3*: To what extent can grading rubrics be translated into autograder instructions?

*RQ4*: What existing solutions are suitable for use in autograding with regards to UTML support, availability of source code, transparency, consistency, and fairness in grading, ease of linking ILOs to grading instructions, and ease of integration into the grading process?

*RQ5*: To what extent can suitable autograders be adjusted, extended, and/or incorporated to be able to grade UTML UML diagrams?

*RQ6*: To what extent do suitable autograders compare to human grading in the context of grading first-year UML exam questions?
])


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

