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
*RQ1*: What existing work exist for automatically analysing and/or grading UML diagrams?
- *RQ1a*: What correction models are employed by existing works?

*RQ2*: To what extent can Intended Learning Objectives be translated into different types of autograder correction models?

*RQ3*: To what extent are existing solutions suitable for use in autograding UTML diagrams with regards to (1) UTML support, (2) availability of source code, (3) grading transparency, (4) grading consistency, (5) fairness in grading, (6) ease of linking ILOs to grading instructions, and (7) ease of integration into the grading process?

*RQ4*: To what extent can suitable autograders be adjusted, extended, and/or incorporated to be able to grade UTML UML diagrams?

*RQ5*: To what extent do suitable autograders compare to human grading in the context of grading first-year UML exam questions?
])


= Related work <relatedwork>
In order to answer research questions *RQ1* until *RQ4*, we conducted a small-scale literary study, collecting works from sources such as Google Scholar#footnote(link("https://scholar.google.com/")) and ResearchGate#footnote(link("https://www.researchgate.net"))

Work @Hosseinibaghdadabadi2023 @anas2021 @batmaz2010 @Bian2019 @Bian2020 @Foss2022 @Jebli2023 @Modi2021 @Ali2007 @Ali2007b @thomas2006 @thomas2004 @thomas2009 @thomas2008 @Striewe2011 @Smith2013

More focused on interactivity: @Foss2022b 

Work on AI @Bouali2025 @Stikkolorum2019

Nondeterminism of AI @he2025 @brenndoerfer2025 @atil2025 + counterarg: inherent lack of transparency, risks of nondeterminism in grading (see sources) == bad because same solution might not give same grade), lack of consistency (contexxt window, importance of reducing prompt length, ...)

Further proof of unreliability of using Large Language Models (LLMs) for automatic grading: "In the evaluation based on UC4, GPT deducts points for missing relationships between specified actors and use cases, but theses relationships existed in the UML use case" #cite(<Wang2025>, supplement: "p.13"), and "While the models would provide a final score as requested in the prompt’s response format, this  core often did not match the actual sum of points awarded in their criterion-by-criterion assessment.#cite(<Bouali2025>, supplement: "p.164"). Bouali et al. identify the problem perfectly, stating that "This discrepancy can be attributed to the autoregressive nature of LLMs, where they generate responses token by token". 

I believe that the observation from #cite(<Bouali2025>, form: "prose") highlights the underlying problem of using LLMs for automatic grading. Because these models are in their very essence based on predicting tokens @Ferraris2025, there is no formal guarantee that grades are produced with accuracy. The fact that LLMs produce grades that correlate with human grading does not mean that this grading is done in a fair, consistent, or reliable manner.

Experience on TAs @Ahmed2024

Reliability of human marking/grading in general @Meadows2005


= Tools and Techniques <tools-techniques>
Adopt existing tool(s), make own tool, what frameworks/languages, ...

= Planning <planning>
TODO: Graduation planning. Phases, goals per phase.


#pagebreak()
#bibliography("refs.bib")

