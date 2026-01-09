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
=== Frameworks / Theoretical<subsec:relatedwork-autograder-frameworks>
@smith2004 @Ali2007 @batmaz2010 @Bian2019 @Vachharajani2014 

#cite(<smith2004>, form: "prose") provides a five-step framework for assessing "possibly ill-formed or inaccurate diagrams" that include (1) segmentation, (2) assimilation, (3) identification, (4) aggregation, and (5) interpretation. While the first two steps are aimed at translating images or other "raster-based input" into diagrammatic primitives, the latter stages provide a foundation to grade diagrams used by other papers @thomas2009.

#cite(<Ali2007>, form: "prose") proposes a UML class diagram assessment system using Rose Petal files, but does not mention enough specifics about algorithms to warrant further investigation.

#cite(<batmaz2010>, form: "prose") takes a broader look at the process of grading, identifying and developing techniques to reduce repetitive actions, focusing on database Entity Relation diagrams. It proposes a semi-automatic grading system which identifies identical segments between a submission and the solution. Assuming multiple submission revisions are available, it suggests to "not only [use] the reference text but also the intermediate diagrams" for identifying semantic matches #cite(<batmaz2010>, supplement: "p.40").

#cite(<Vachharajani2014>, form: "prose") proposes a UML use case assessment architecture. It provides a useful catalogue about edge cases related to (use case) diagram assessment, such as the chance of misspellings, synonyms, abbreviations, directionality of relationships, etc.

#cite(<Bian2019>, form: "prose") establishes a metamodel to map submissions to example solutions and proposes a metamodel to grade submissions. It suggests using syntactic matching, semantic matching, and structural matching, with the goal to optimally match parts of a student submission with those of a teacher, considering spelling mistakes, synonyms and related words, and neighbours / inheritance, respectively. 

=== Non-ML/LLM<subsec:relatedwork-autograder-algorithmic>
The automatic analysis of diagrams seems to be a relatively new field, having started somewhere in the early 2000s @thomas2004. Multiple types of diagrams are researched, including UML class and use case diagrams @Bian2020 @Hosseinibaghdadabadi2023 @anas2021 @Jebli2023 @Modi2021 @Ali2007b @AlRawashdeh2014 @Striewe2011

and Entity-Relation Diagrams @Foss2022 @Foss2022a @Foss2022b @thomas2006 @thomas2004 @thomas2008 @thomas2009 @thomas2011 @smith2013.

#cite(<Bian2020>, form: "year") expands their previous work @Bian2019 with a case study. Their main findings are that multiple teacher solutions result in more accurate grades, that grading configurations change per exam if you want similar grades to the teacher, and that their autograding "has shown to be more consistent and able to ensure fairness in the grading process" #cite(<Bian2020>, supplement: "p.11").

#cite(<Hosseinibaghdadabadi2023>, form: "prose") implements the work of #cite(<Bian2019>, form: "prose") by comparing UML use case diagrams to one or multiple example solutions, preferring the maximum grade. It uses a graph similarity strategy which matches nodes based on structural matching, along with syntactic and semantic word matching. Syntactic matching with Levenshtein distance, semantic matching with WordNet similarity score (uses HSO, WUP, LIN metrics). It achieves high correlation with human grades. #highlight("more?")

#cite(<anas2021>, form: "prose") compares UML class diagram submissions to an example solution. It uses graph similarity scores based on structural matching along with syntactic and semantic matching. Syntactic matching is done with substring matching, semantic matching is done with neighbour similarity ("the comparison of the neighboring classes" #cite(<anas2021>, supplement: "p.1585")), relationship name, type, multiplicity, and inheritance. It achieves high correlation with human grading (more than 80% is perfectly similar, over 90% had a correlation >0.85, no correlation was lower than 0.7).

Multiple papers mention the use of XMI @Modi2021 @Jebli2023, the object notation standard by OMG @xmi, or Rose Petal files @Ali2007b, the standard of IBM Rational Rose @ibm-rational-rose, but fail to mention specifics about matching algorithms or results.

#cite(<AlRawashdeh2014>, form: "prose") provides an interesting alternative way of grading submissions: by means of combining many UML diagram validators, model checkers, and even LTL properties given by instructors, but a clear purpose, scope, and results are lacking from the paper.

#cite(<Striewe2011>, form: "prose") continues this trend by focusing on graph queries for evaluation, providing a Domain-Specific Language that looks relatively similar to SQL. While it looks promising, the fact that teachers would have to learn a query language and transform their existing rubrics/example solutions into this format could be a real hurdle, especially given the high similarity to existing grading of graph-isomorphism-based solutions. Additionally, the paper does not provide approximate matching that would account for misspelling or synonyms.

#cite(<Foss2022>, form: "author") provide multiple papers on AutoER, a database diagram generator and evaluator that provides direct interaction with a description text @Foss2022 @Foss2022a @Foss2022b. Unfortunately, concrete comparisons to manual grading or source code could not be found.

#cite(<thomas2004>, form: "author") also provides a selection of paperse on the automatic grading of database diagrams @thomas2004 @thomas2006 @thomas2008 @thomas2009 @thomas2011. These papers provide a grading strategy that accounts in its basis for _imprecise_ diagrams (diagrams containing misspellings, duplicate entities, etc.), basing their analysing on comparing ever increasing subsets of the graph ((Minimal) Meaningful Units) based on the work of #cite(<smith2004>, form: "prose"). By #cite(<thomas2009>, form: "year"), #cite(<thomas2009>, form: "author") manage to achieve a correlation to human grading of 92%, along with statistically proving that the autograder grades more consistently than human grading.

In #cite(<thomas2011>, form: "year") #cite(<thomas2011>, form: "author") provide an online platform for both students and teachers to ease the process of automatic grading further, also used by #cite(<smith2013>, form: "prose"), which fruther mathematically specify #cite(<thomas2011>, form: "author")'s work. Unfortunately, we were not able to retrace the source code of this grader.

// Note to self: replicating Smith 2004 steps with advice from Thomas2004-2011 would be a good bet.

=== Machine Learning/Large Language Model-driven<subsec:relatedwork-autograder-AI>
There has also been work on including Machine Learning (ML) and/or Large Language Models (LLMs) in the process of automatic grading @Bouali2025 @Stikkolorum2019.

#cite(<Wang2025>, form: "prose") evaluate the feasibility of LLM-based grading with ChatGPT-4o, specifically for entire reports containing multiple types of UML diagrams. It feeds pictures of student-submitted UML diagrams directly into the model along with an explanatory prompt that should trigger Chain-of-Thought, and runs the model one time per student, with a temperature of 0.1. It finds that score differences range from -0.25 to +3.75 points, with significantly lower average scores given by the LLM compared to humans. Additionally, there are many occurrences of incorrect grading (wrong identifications, overstrictness, misunderstandings), as seen by Figure 6 #cite(<Wang2025>, supplement: "p.18"), which means that, while the authors claim that their solution "demonstrates particular proficiency in the automated evaluation of UML use case diagrams", they do note occurrences of hallucination: "In the evaluation based on UC4, GPT deducts points for missing relationships between specified actors and use cases, but theses relationships existed in the UML use case" #cite(<Wang2025>, supplement: "p.13"). Furthermore, the paper does not express a strong correlation between LLM grading and human grading, at least compared to papers utilising graph matching algorithms @thomas2009 @Hosseinibaghdadabadi2023, nor does it recognise the inherent bias of LLMs @ranjan2024 or their inherent non-determinism (even with a zeroed temperature) @brenndoerfer2025 @atil2025, which make it a sub-optimal solution for consistent, fair grading.

#cite(<Bouali2025>, form: "prose") uses various Large Language Models (Llama, GPT o1-mini, Claude) to grade, translating the models into text instead of giving the LLM images directly like #cite(<Wang2025>, form: "prose"). While they achieve a Pearson correlation to human grading of 0.76 with both ChatGPT and Claude, they run into the same inconsistency issues as #cite(<Wang2025>, form: "author"): "while the models would provide a final score as requested in the prompt’s response format, this score often did not match the actual sum of points awarded in their criterion-by-criterion assessment", and ""One ChargingPort is associated with One Vehicle" was matched with "One ChargingPort is associated with One ChargingStation" with a similarity of 0.92, despite describing different domain relationships" #cite(<Bouali2025>, supplement: "p.164"). 

#cite(<Bouali2025>, form: "author") identify the problem with grading with LLMs perfectly, stating that "This discrepancy can be attributed to the autoregressive nature of LLMs, where they generate responses token by token" #cite(<Bouali2025>, supplement: "p.164"). Because these models are in their very essence based on predicting tokens @Ferraris2025, there is no formal guarantee that results are internally consistent and thus grades are produced with accuracy. The fact that LLMs produce grades that correlate with human grading does not mean that this grading is done in a fair, consistent, or reliable manner. While #cite(<Bouali2025>, form: "author") try to reduce the non-determinism of LLMs by setting the temperature to zero, this does remove non-determinism necesssarily, nor does it correct training biases, as mentioned before.

== ILO translation



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

