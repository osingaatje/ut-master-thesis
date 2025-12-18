#import "typst-template-ut/conf.typ" : conf, abstr
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
)
#set page("a4", margin: 2cm, numbering: "1")

// highlight styling
#set highlight(radius: 2pt)

#abstr(content: 
  "During computer science studies, students are often required to submit UML diagrams. However, the grading of these diagrams is often done by humans, resulting in a costly and lengthy process. In this paper, we investigate the theoretical feasability of automatically grading UML diagrams, with a focus on the UTML variant developed at the University of Twente. In the final thesis, we compare the most suitable autograder from our related works to human grading."
)

= Introduction <intro>
// Current state of grading + autograding, University of Twente is looking into ways to save time and money in grading by automating (parts of) it.

UML diagrams play a significant role in computer science, as they allow for communicating system designs in a standardised format. During technical studies, students are often required at some point to make a UML diagram for a graded assignment or exam.

However, the grading of these diagrams can often be a costly and lengthy process, involving multiple paid members of staff. Therefore, the automation of this task is an interesting topic.

In this Research Topics paper, I examine the current state of autograding diagrams and propose a plan for the implementation of _Seshat_, an automatic diagram grader that combines concepts from related works (@relatedwork), which is to be implemented and verified in the final thesis.


= Problem statement <prob-stat> 
The grading of (UML) diagram submissions by students can often be a costly and lengthy process, involving multiple paid members of staff, which can take multiple hours of active work#footnote("From personal experience.").

The automatisation of grading diagrams could reduce the cost and time required for universities and other institutions, providing financial benefit for universities and allowing for quicker grading times, while providing the same or better performance compared to human grading in terms of *accuracy*, *consistency*, and *transparency*. 

With accuracy, we mean the percentage of points correctly assigned to a submission, according to the rubric for a particular excercise. With consistency, we mean the similarity between consecutive runs (i.e. determinism). With transparency, we mean the extent to which the reasoning for a particular grade is explained.

For this research, we focus on the automatic grading of _UTML_ UML diagrams, a recent, in-house developed diagram format of the University of Twente @utml-internal@utml. However, a UTML is just a representation format and creation tool for UML diagrams, we aim to generalise these results into an advice on the automatic grading of UML diagrams as a whole.


== Research Questions <rqs>
In order to examin the feasibility of automatically grading UTML UML diagrams, we provide a main research question (*MRQ*):

#align(center, [
  *To what extent can UML diagrams be graded automatically while keeping or improving the accuracy, consistency, and transparency of human grading?*
])

We aim to answer the main research question with the following sub-research questions:

#box(inset: (left: 10pt), [
*RQ1*: What existing work exist for automatically analysing and/or grading UML diagrams?
- *RQ1a*: What correction models are employed by existing works?

*RQ2*: To what extent can Intended Learning Objectives be translated into different types of autograder correction models?

*RQ3*: To what extent are existing solutions suitable for use in autograding UTML diagrams with regards to (1) accuracy, (2) consistency, (3) transparency, (4) availability of source code, (5) UTML support, (6) extent to which linking ILOs to grading instructions is possible, and (7) ease of integration into the grading process?

*RQ4*: To what extent can suitable autograders be used to be able to grade UTML UML diagrams?

*RQ5*: To what extent do suitable autograders compare to human grading in the context of grading first-year UML exam questions?
])


*RQ1* and *RQ2* is answered by collecting related work (@relatedwork), which will give us an overview of existing solutions and their grading methodologies. *RQ3* is answered in @relatedwork by analysing these works for suitability of grading. Finally, *RQ4* and *RQ5* are to be answered in the final thesis, where we aim to grade UTML diagrams with the most suitable autograder and compare it to human grading.

= Related work <relatedwork>
In order to answer research questions *RQ1* until *RQ4*, we have conducted a small-scale study covering roughly #highlight("40") works. These works were collected from sources such as Google Scholar#footnote(link("https://scholar.google.com")) and ResearchGate#footnote(link("https://www.researchgate.net")), using terms such as "automatically grading UML diagrams", "autograder diagram", and "UML diagram assessment" for autograder-based related works, and terms suchc as "ILO translation", "intended learning objective grading", and 

== Existing work
The automatic analysis of diagrams seems to be a relatively new field, having started somewhere in the early 2000s @thomas2004. Multiple types of diagrams are researched, including UML diagrams @Hosseinibaghdadabadi2023 @anas2021 @batmaz2010 @Bian2019 @Bian2020 @Jebli2023 @Modi2021 @Ali2007 @Ali2007b @AlRawashdeh2014 @Vachharajani2014 @Striewe2011, Entity-Relation Diagrams (including UML ERDs) @Foss2022 @Foss2022b @thomas2006 @thomas2004 @thomas2009 @thomas2008 @Smith2013

More focused on interactivity: @Foss2022b 

Work on AI @Bouali2025 @Stikkolorum2019

== ILO translation


== Suitability of autograders
Further proof of unreliability of using Large Language Models (LLMs) for automatic grading: "In the evaluation based on UC4, GPT deducts points for missing relationships between specified actors and use cases, but theses relationships existed in the UML use case" #cite(<Wang2025>, supplement: "p.13"), and "While the models would provide a final score as requested in the prompt’s response format, this  core often did not match the actual sum of points awarded in their criterion-by-criterion assessment.#cite(<Bouali2025>, supplement: "p.164"). Bouali et al. identify the problem perfectly, stating that "This discrepancy can be attributed to the autoregressive nature of LLMs, where they generate responses token by token". 

I believe that the observation from #cite(<Bouali2025>, form: "prose") highlights the underlying problem of using LLMs for automatic grading. Because these models are in their very essence based on predicting tokens @Ferraris2025, there is no formal guarantee that grades are produced with accuracy. The fact that LLMs produce grades that correlate with human grading does not mean that this grading is done in a fair, consistent, or reliable manner. In particular, reliability is affected by the nondeterminism introduced into LLMs, either deliberately, with 'temperature' controls per model, or accidentally, because batch processing ordering for large-scale LLM deployments can introduce nondeterminism @brenndoerfer2025 @atil2025.

While @Bouali2025 attempts to lower the amount of nondeterminism by setting the model's temperature to zero, nondeterminism can still occur due to 

Nondeterminism of AI @he2025 @brenndoerfer2025 @atil2025 + counterarg: inherent lack of transparency, risks of nondeterminism in grading (see sources) == bad because same solution might not give same grade), lack of consistency (contexxt window, importance of reducing prompt length, ...). 


Experience on TAs @Ahmed2024

Reliability of human marking/grading in general @Meadows2005


= Tools and Techniques <tools-techniques>
Adopt existing tool(s), make own tool, what frameworks/languages, ...

= Planning <planning>
TODO: Graduation planning. Phases, goals per phase.


#pagebreak()
#bibliography("refs.bib")

