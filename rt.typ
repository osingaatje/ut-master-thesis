#import "typst-template-ut/conf.typ" : conf, abstr
#set document(title: [Automatic analysis and grading of UTML UML diagrams])

#let DOC-MARGIN = 1.5cm

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
  margin-x: DOC-MARGIN,
  margin-y: DOC-MARGIN,
)
#set page("a4", margin: DOC-MARGIN, numbering: "1")
#columns(2, gutter: 10pt, [

// highlight styling
#set highlight(radius: 2pt)

#abstr(content: 
  "During computer science studies, students are often required to submit UML diagrams. The grading of these diagrams is often done by humans, resulting in a costly, lengthy, and error-prone process. In this paper, we investigate the theoretical feasability of automatically grading UML diagrams, focusing on the UTML variant developed at the University of Twente. In the final thesis, we compare the most suitable autograder from our related works to human grading."
)

= Introduction <intro>
// Current state of grading + autograding, University of Twente is looking into ways to save time and money in grading by automating (parts of) it.

UML diagrams play a significant role in computer science, as they allow for communicating system designs in a standardised format. During technical studies, students are often required to make a UML diagram for a graded assignment or exam.

However, the grading of these diagrams can often be a costly and lengthy process, involving multiple paid members of staff @Ahmed2024#footnote("Also from personal experience.")<footnote:pers-exp>.

Additionally, this process is prone to grading inconsistencies @Ahmed2024, as humans are inherently unreliable when grading @Meadows2005. Letting the process of determining a grade based on a rubric be performed by a (deterministic) program instead of a human reduces these inconsistencies @Bian2020.

In this Research Topics paper, I examine the current state of autograding diagrams and propose a plan for the implementation of _Seshat_, an automatic diagram grader that combines concepts from related works (@relatedwork), which is to be implemented and verified in the final thesis.


= Problem statement <prob-stat> 
The grading of (UML) diagram submissions by students can often be a costly and lengthy process, involving multiple paid members of staff @footnote:pers-exp, which can take multiple hours of active work. Additionally, human grading is inherently subject to inconsistencies in grading, according to #cite(<Meadows2005>, form: "prose"), who pose two possible solutions: either "report the level of reliability associated with marks/grades, or find alternatives to marking." We propose a third alternative: what if, instead of finding alternatives to marking/grading, we find alternatives to the grading _process_?

The automatisation of grading diagrams provides an grading marking method that could both reduce the cost and time required for institutions and reduce the inherently present inconsistencies in human grading#footnote("Given that the process is deterministic"). This could result in similar performance compared to human grading in terms of *accuracy* and *process transparency*, while improving *consistency*.

With accuracy, we mean the percentage of points assigned to a submission that are prescribed by the rubric for a particular excercise. With consistency, we mean both the extent to which similar grades are given to similar submissions, and the difference between consecutive runs (i.e. determinism). With transparency, we mean the extent to which the reasoning for a particular grade is explained. These properties are desirable in the grading process, as it means that students are graded in a way that reflects their performance.

For this research, we focus on the automatic grading of _UTML_ UML diagrams, a recent, in-house developed diagram format of the University of Twente @utml-internal@utml. However, as UTML is just a representation format and tool for creating UML diagrams, we aim to generalise these results to provide advice on the automatic grading of UML diagrams as a whole.


== Research Questions <rqs>
In order to examin the feasibility of automatically grading UTML UML diagrams, we provide a main research question (*MRQ*):

#align(center, [
  *To what extent can UML diagrams be graded automatically while keeping or improving the accuracy, consistency, and transparency of human grading?*
])

We aim to answer the main research question with the following sub-research questions:

#box(inset: (left: 10pt), [
*RQ1*: What existing work can be found for automatically analysing and/or grading UML diagrams?
- *RQ1a*: What correction models are employed by existing works?
- *RQ1b*: To what extent can Intended Learning Objectives be translated into different types of autograder correction models?

*RQ2*: To what extent are existing solutions suitable for use in autograding UTML diagrams with regards to (1) accuracy, (2) consistency, (3) transparency, (4) availability of source code, (5) extent of linking ILOs to grading instructions, (6) ease of integration into the grading process, and (7) UTML support?

*RQ3*: To what extent can a suitable autograder be constructed from previous work to be able to grade UTML UML diagrams?

*RQ4*: To what extent does the autograder compare to human grading in the context of grading first-year UML exam questions?
])


*RQ1* is answered in @relatedwork, giving us an overview of existing solutions and their grading methodologies. *RQ2* is answered in @relatedwork by analysing these works for suitability of grading. Finally, *RQ3* and *RQ4* are to be answered in the final thesis, where we grade UTML diagrams using an implementation based on related work and compare it to human grading.

= Related work <relatedwork>
In order to answer research questions *RQ1* until *RQ4*, we have conducted a small-scale study covering roughly #highlight("40") works. These works were collected from sources such as Google Scholar#footnote(link("https://scholar.google.com")) and ResearchGate#footnote(link("https://www.researchgate.net")), using terms such as "automatically grading UML diagrams", "autograder diagram", and "UML diagram assessment" for autograder-based related works, and terms such as "ILO translation", "intended learning objective grading", and #highlight("more terms and stuff about ILOs")

== Autograders
=== Non-ML/LLM
The automatic analysis of diagrams seems to be a relatively new field, having started somewhere in the early 2000s @thomas2004. Multiple types of diagrams are researched, including UML diagrams @Hosseinibaghdadabadi2023 @anas2021 @batmaz2010 @Bian2019 @Bian2020 @Jebli2023 @Modi2021 @Ali2007 @Ali2007b @AlRawashdeh2014 @Vachharajani2014 @Striewe2011, Entity-Relation Diagrams (including UML ERDs) @Foss2022 @Foss2022b @thomas2006 @thomas2004 @thomas2009 @thomas2008 @Smith2013.

#cite(<Bian2019>, form: "prose") establishes a metamodel to map submissions to example solutions and proposes a metamodel to grade submissions. It suggests using syntactic matching, semantic matching, and structural matching, with the goal to optimally match parts of a student submission with those of a teacher, considering spelling mistakes, synonyms and related words, and neighbours / inheritance, respectively. They expand their work in a paper from #cite(<Bian2020>, form: "year") which expands the work with a case study. Their main findings are that multiple teacher solutions result in more accurate grades, that grading configurations change per exam if you want similar grades to the teacher, and that their autograding "has shown to be more consistent and able to ensure fairness in the grading process" #cite(<Bian2020>, supplement: "p.11").

#cite(<Hosseinibaghdadabadi2023>, form: "prose") implements the work of #cite(<Bian2019>, form: "prose") by comparing UML use case diagrams to one or multiple example solutions, preferring the maximum grade. It uses a graph similarity strategy which matches nodes based on structural matching, along with syntactic and semantic word matching. Syntactic matching with Levenshtein distance, semantic matching with WordNet similarity score (uses HSO, WUP, LIN metrics). It achieves high correlation with human grades. #highlight("more?")

#cite(<anas2021>, form: "prose") compares UML class diagram submissions to an example solution. It uses graph similarity scores based on structural matching along with syntactic and semantic matching. Syntactic matching is done with substring matching, semantic matching is done with neighbour similarity ("the comparison of the neighboring classes" #cite(<anas2021>, supplement: "p.1585")), relationship name, type, multiplicity, and inheritance. It achieves high correlation with human grading (more than 80% is perfectly similar, over 90% had a correlation >0.85, no correlation was lower than 0.7).




=== ML/LLM-driven
Work on AI @Bouali2025 @Stikkolorum2019.

#cite(<Bouali2025>, form: "prose") uses various Large Language Models (Llama, GPT o1-mini, Claude) to grade 


=== Other
More focused on interactivity: @Foss2022b 

#cite(<batmaz2010>, form: "prose") takes a broader look at the process of grading, identifying and developing techniques to reduce repetitive actions, focusing on database ER diagrams. It proposes a semi-automatic grading system which identifies identical segments between a submission and the solution. Assuming multiple submission revisions are available, it suggests to "not only [use] the reference text but also the intermediate diagrams" for identifying semantic matches #cite(<batmaz2010>, supplement: "p.40").

== ILO translation


== Suitability of autograders
Further proof of unreliability of using Large Language Models (LLMs) for automatic grading: "In the evaluation based on UC4, GPT deducts points for missing relationships between specified actors and use cases, but theses relationships existed in the UML use case" #cite(<Wang2025>, supplement: "p.13"), and "While the models would provide a final score as requested in the prompt’s response format, this  core often did not match the actual sum of points awarded in their criterion-by-criterion assessment, where #cite(<Bouali2025>, form: "prose", supplement: "p.164") identify the problem perfectly, stating that "This discrepancy can be attributed to the autoregressive nature of LLMs, where they generate responses token by token". 

I believe that the observation from #cite(<Bouali2025>, form: "prose") highlights the underlying problem of using LLMs for automatic grading. Because these models are in their very essence based on predicting tokens @Ferraris2025, there is no formal guarantee that grades are produced with accuracy. The fact that LLMs produce grades that correlate with human grading does not mean that this grading is done in a fair, consistent, or reliable manner. In particular, reliability is affected by the nondeterminism introduced into LLMs, either deliberately, with 'temperature' controls per model, or accidentally, because batch processing ordering for large-scale LLM deployments can introduce nondeterminism @brenndoerfer2025 @atil2025.

While @Bouali2025 attempts to lower the amount of nondeterminism by setting the model's temperature to zero, nondeterminism can still occur due to 

Nondeterminism of AI @he2025 @brenndoerfer2025 @atil2025 + counterarg: inherent lack of transparency, risks of nondeterminism in grading (see sources) == bad because same solution might not give same grade), lack of consistency (contexxt window, importance of reducing prompt length, ...). 


Experience on TAs @Ahmed2024

Reliability of human marking/grading in general @Meadows2005


= Tools and Techniques <tools-techniques>
Adopt existing tool(s), make own tool, what frameworks/languages, ...

= Planning <planning>
TODO: Graduation planning. Phases, goals per phase.

])

#pagebreak()
#bibliography("refs.bib")

= Appendices
== Autograder suitability table <app:grader-suitability>
#[
  #show table.cell.where(body: [N]): t => text(fill: rgb("#CC1212"), strong(t))
  #show table.cell.where(body: [H]): t => text(fill: rgb("#12CC12"), strong(t))
  #show table.cell.where(body: [?]): t => t

  #figure(
    table(columns: (4fr, 2fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      inset: 3pt,
      align: horizon,
        table.header(
        [Author],                                        [Di],           [Ac], [Co], [Tr], [OSS], [ILO], [Int], [UTML],
      ),

      [#cite(<Hosseinibaghdadabadi2023>, form: "prose")],[UML Use Case], [H],  [H],  [H],  [N],   [N],   [?],   [N], 

    ),
    caption: figure.caption(position: bottom, [
      Autograders and their suitability scores. \
      #align(left, [ 
        \*Di(_agram type_), Ac(_curacy_), Co(_nsistency_), Tr(_ansparency_), OSS = _availability of source code_, ILO = _ease of linking grading to ILOs_, Int(_egration ease_), UTML _support_. \
        #v(2pt)
        Scoring is divided into "N" (_No Support_), "L" (_Low_), "M" (_Medium_), "H" (_High_), and "?" (_Unknown_), which gives an indication of suitability w.r.t. that particular criterium.
      ])
    ]),
  )
]

