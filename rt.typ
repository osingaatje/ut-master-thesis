#import "typst-template-ut/typst-template-paper.typ" : conf, abstr

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
  [
    During computer science studies, students are often required to submit UML diagrams. The grading of these diagrams is mainly done by humans, resulting in a costly, lengthy, and error-prone process. In this paper, we investigate the theoretical feasability of automatically grading UML diagrams, focusing on the UTML variant developed at the University of Twente. We find that #highlight("TODO results") and propose _Seshat_, an algorithmic autograder that combines principles from graph isomorphism with structural, semantic, and syntactic matching #highlight("TODO mention this in paper"). In the final thesis, we compare the most suitable autograder from our related works to human grading.
  ]
)

= Introduction <intro>
// Current state of grading + autograding, University of Twente is looking into ways to save time and money in grading by automating (parts of) it.

UML diagrams play a significant role in computer science, as they allow for communicating software designs in a standardised format. During technical studies, students are often required to make UML diagrams for graded assignments or exams.

However, the grading of these diagrams can often be a costly and lengthy process, involving multiple paid members of staff @Ahmed2024#footnote("From personal experience.")<footnote:pers-exp>. Additionally, this process is prone to grading inconsistencies @Ahmed2024, as humans are inherently unreliable, according to #cite(<Meadows2005>, form: "prose"), who pose two possible solutions: either "report the level of reliability associated with marks/grades, or find alternatives to [grading]." We propose a third alternative: finding alternatives to the grading _process_. Letting the grading process based on a (human) rubric be performed by software@footnote:determinism instead of a human reduces human inconsistencies and the time it takes to grade.


The automatisation of grading diagrams provides an grading marking method that could both reduce the cost and time required for institutions and reduce the inherently present inconsistencies in human grading#footnote("Given that the process is deterministic")<footnote:determinism> @osinga2024 @Bian2020. This could result in similar or superior, performance compared to human grading in terms of *accuracy* and *process transparency*, while improving *consistency*.

With _accuracy_, we mean the percentage of points assigned to a submission that are prescribed by the rubric for a particular excercise. With _consistency_, we mean both the extent to which similar grades are given to similar submissions, and the difference between consecutive runs (i.e. determinism). With _process transparency_, we mean the extent to which the reasoning for a particular grade is explained. These properties are desirable in the grading process, as it means that students are graded in a way that reflects their performance. For transparency, it would also be desirable to be able to link Intended Learning Objectives (ILOs) to the autograders, as this would help relate the grading to the objectives of the module @osinga2024.

For this research, we focus on the automatic grading of _UTML_ UML diagrams, a recent, in-house developed diagram format of the University of Twente @utml-internal @utml. However, as UTML is just a representation format and tool for creating UML diagrams, we aim to generalise these results to provide advice on the automatic grading of UML diagrams as a whole.

== Research Questions <rqs>
In order to examin the feasibility of automatically grading UTML UML diagrams, we provide a main research question (*MRQ*):

#align(center, [
  *To what extent can UML diagrams be graded automatically while maintaining or improving the accuracy, consistency, and transparency of human grading?*
])

We aim to answer the main research question with the following sub-research questions:

#let rq(content) = box(inset: (left: 10pt), content)

#rq([
*RQ1*: What existing work can be found for automatically analysing and/or grading UML diagrams?
- *RQ1a*: What correction models are employed by existing works?
- *RQ1b*: To what extent can Intended Learning Objectives be translated into different types of autograder correction models?
])

#rq([
*RQ2*: To what extent are existing solutions suitable for use in autograding UTML diagrams with regards to (1) accuracy, (2) consistency, (3) transparency, (4) availability of source code, (5) extent of linking ILOs to grading instructions, (6) ease of integration into the grading process, and (7) UTML support?
])

#rq([
*RQ3*: To what extent can a suitable autograder be constructed from previous work to be able to grade UTML UML diagrams?
])

#rq([
*RQ4*: To what extent does the autograder compare to human grading in the context of grading first-year UML exam questions?
])

*RQ1* is answered in @relatedwork, giving us an overview of existing solutions and their grading methodologies. *RQ2* is answered in @relatedwork by analysing these works for suitability of grading. Finally, *RQ3* and *RQ4* are to be answered in the final thesis, where we grade UTML diagrams using an implementation based on related work and compare it to human grading.

= Related work <relatedwork>
In order to answer research questions *RQ1* and *RQ2*, we conduct a small-scale study covering roughly 40 works. These works are collected from sources such as Google Scholar#footnote(link("https://scholar.google.com")) and ResearchGate#footnote(link("https://www.researchgate.net")), using terms such as "automatically grading UML diagrams", "autograder diagram", "UML diagram assessment", "machine learning diagrams", "diagram evaluation assessment AI", and similar for autograder-based related works.

== Autograders
Automatic grading of diagrams seems to be a relatively new field, having started somewhere in the early 2000s @smith2004 @thomas2004. Multiple methods and types of diagrams are researched, including purely algorithmic methods for UML class- and use case diagrams, database Entity-Relation Diagrams, and Generative AI (GenAI)-based methods.

=== Frameworks / Theoretical<subsec:relatedwork-autograder-frameworks>
#cite(<smith2004>, form: "prose") provide a five-step framework for assessing "possibly ill-formed or inaccurate diagrams" that include (1) segmentation, (2) assimilation, (3) identification, (4) aggregation, and (5) interpretation. While the first two steps are aimed at translating images or other "raster-based input" into diagrammatic primitives, the latter stages provide a foundation to grade diagrams used by other papers @thomas2009.

#cite(<Ali2007>, form: "prose") propose a UML class diagram assessment system using Rose Petal files, but does not mention enough specifics about algorithms to warrant further investigation.

#cite(<batmaz2010>, form: "prose") takes a broader look at the process of grading, identifying and developing techniques to reduce repetitive actions, focusing on database Entity Relation diagrams. The paper suggests a semi-automatic grading system which identifies identical segments between a submission and the solution. Assuming multiple submission revisions are available, it suggests to "not only [use] the reference text but also the intermediate diagrams" for identifying semantic matches #cite(<batmaz2010>, supplement: "p.40").

#cite(<Vachharajani2014>, form: "prose") propose a UML use case assessment architecture. It provides a useful catalogue about edge cases related to (use case) diagram assessment, such as the chance of misspellings, synonyms, abbreviations, directionality of relationships, etc.

#cite(<Bian2019>, form: "prose") establish a metamodel to map submissions to example solutions and present a metamodel to grade submissions. It suggests using syntactic matching, semantic matching, and structural matching, with the goal to optimally match parts of a student submission with those of a teacher, considering spelling mistakes, synonyms and related words, and neighbours / inheritance, respectively. 

In conclusion, most autograder strategies recommend structural matching (to identify similar segments of graphs), often in combination with syntactic matching that accounts for misspellings and semantic matching to account for synonyms. Unfortunately, the strategies do not account for integrating ILOs into the grading process explicitly.

=== Algorithmic <subsec:relatedwork-autograder-algorithmic>

#cite(<Bian2020>, form: "prose") expand their previous work @Bian2019 (see @subsec:relatedwork-autograder-frameworks) with a case study. Their main findings are that multiple teacher solutions result in more accurate grades with an average accuracy of more than 95% #cite(<Bian2020>, supplement: "p.10"), that grading configurations change per exam if you want similar grades to the teacher, and that their autograding "has shown to be more consistent and able to ensure fairness in the grading process" #cite(<Bian2020>, supplement: "p.11"). Additionally, their visual feedback system seems to be a nice addition for easily seeing where marks were awarded / taken away (see @fig:Bian2020_Fig9).

#figure(image("pics/Bian2020_Fig9.png", width: 95%),
  caption: [Visual feedback module from #cite(<Bian2020>, form: "prose", supplement: "Fig.9")]
  )<fig:Bian2020_Fig9>

#cite(<Hosseinibaghdadabadi2023>, form: "prose") also implements the framework by #cite(<Bian2019>, form: "prose") by comparing UML use case diagrams to one or multiple example solutions, preferring the maximum grade. It uses a graph similarity strategy which matches nodes based on structural matching, along with syntactic and semantic word matching. Syntactic matching with Levenshtein distance, semantic matching with WordNet similarity score (uses HSO, WUP, LIN metrics). It achieves a very high correlation with human grades, with a similarity percentage of 93.31% #cite(<Hosseinibaghdadabadi2023>, supplement: "p.114").

#cite(<anas2021>, form: "prose") compares UML class diagram submissions to an example solution. It uses graph similarity scores based on structural matching along with syntactic and semantic matching. Syntactic matching is done with substring matching, semantic matching is done with neighbour similarity ("the comparison of the neighboring classes" #cite(<anas2021>, supplement: "p.1585")), relationship name, type, multiplicity, and inheritance. It achieves a respectable correlation with human grading, with more than 80% is perfectly similar, over 90% >0.85 correlated, and no correlations lower than 0.7.

Multiple papers mention the use of XMI @Modi2021 @Jebli2023, the object notation standard by OMG @xmi, or Rose Petal files @Ali2007b, the standard of IBM Rational Rose @ibm-rational-rose, but fail to mention specifics about matching algorithms or results.

#cite(<AlRawashdeh2014>, form: "prose") provides an interesting alternative way of grading submissions: by means of combining many UML diagram validators, model checkers, and even LTL properties given by instructors. However, a clear purpose, scope, and results are lacking from the paper.

#cite(<Striewe2011>, form: "prose") continues #cite(<AlRawashdeh2014>, form: "prose")'s property checking trend by focusing on graph queries for evaluation, providing a Domain-Specific Language that looks relatively similar to SQL. While it looks promising, the fact that teachers would have to learn a query language and transform their existing rubrics/example solutions into this format could be a real hurdle, especially given the high similarity to existing grading of graph-isomorphism-based solutions @Bian2020 @Hosseinibaghdadabadi2023 @anas2021. Additionally, the paper does not provide approximate matching that would account for misspelling or synonyms.

#cite(<Foss2022>, form: "author") provide multiple papers on AutoER, a database diagram generator and evaluator that provides direct interaction with a description text @Foss2022 @Foss2022a @Foss2022b. Unfortunately, concrete comparisons to manual grading or source code could not be found.

#cite(<thomas2004>, form: "author") also provides a selection of paperse on the automatic grading of database diagrams @thomas2004 @thomas2006 @thomas2008 @thomas2009 @thomas2011. These papers provide a grading strategy that accounts in its basis for _imprecise_ diagrams (diagrams containing misspellings, duplicate entities, etc.), basing their analysing on comparing ever increasing subsets of the graph ((Minimal) Meaningful Units) based on the work of #cite(<smith2004>, form: "prose"). By #cite(<thomas2009>, form: "year"), #cite(<thomas2009>, form: "author") manage to achieve a correlation to human grading of 92%, along with statistically proving that the autograder grades more consistently than human grading. The graphed grading distribution can be viewed in @fig:thomas2009-results.

In #cite(<thomas2011>, form: "year") #cite(<thomas2011>, form: "author") provide an online platform for both students and teachers to ease the process of automatic grading further, also used by #cite(<smith2013>, form: "prose"), which further mathematically specify #cite(<thomas2011>, form: "author")'s work. Unfortunately, we were not able to retrace the source code of this grader.

#figure(
  box(inset: (left: -10pt), image("pics/thomas2009_Fig3.png", width: 95%)),
    caption: [#cite(<thomas2009>, form: "prose", supplement: "Fig. 3"): Human vs. automatic grading in database ER diagrams.],
)<fig:thomas2009-results>

In conclusion, most existing implementations of autotgraders use some form of graph isomorphism algorithm with a combination of structural, semantic, and syntactic matching, also suggested by the majority of frameworks. Some solutions attempt to autograde using property or formula checking, but fail to mention detailed enough methodology or results to warrant further investigation. No autograders provide methods on integrating ILOs into the grading process.

// Note to self: replicating Bian 2020 with Smith 2004 steps with advice from Thomas2004-2011 would be a good bet.

=== Machine Learning / Generative AI / Large Language Model-driven<subsec:relatedwork-autograder-AI>
There has also been work on using Generative AI / Large Language Models (LLMs) to automatically grade solutions @Stikkolorum2019 @Wang2025 @Bouali2025 @RajiRamachandran2025.

#cite(<Stikkolorum2019>, form: "prose") is one of the first papers that was found that attempts Machine Learning-based autograding, using several machine learning algorithms to compare it to expert grades. Unfortunately, the grading reaches only a maximum accuracy of 42.76% using a 10-point scale. Exact methods and algorithms are not mentioned.

#cite(<Wang2025>, form: "prose") evaluate the feasibility of LLM-based grading with the model ChatGPT-4o, specifically for entire student reports, containing multiple types of UML diagrams. They feed pictures of student-submitted UML diagrams directly into the model along with an explanatory prompt that aims to trigger a Chain-of-Thought process (which helps LLMs "tackle complex arithmetic, commonsense, and symbolic reasoning tasks" @wei2023), and runs the model one time per student, with a temperature of 0.1. It finds that score differences range from -0.25 to +3.75 points, with significantly lower average scores given by the LLM compared to humans. Additionally, there are many occurrences of incorrect grading (wrong identifications, overstrictness, misunderstandings) #cite(<Wang2025>, supplement: "p.18"), which means that, while the authors claim that their solution "demonstrates particular proficiency in the automated evaluation of UML use case diagrams", they do note occurrences of hallucination: "In the evaluation based on UC4, GPT deducts points for missing relationships between specified actors and use cases, but theses relationships existed in the UML use case" #cite(<Wang2025>, supplement: "p.13"). Furthermore, the paper does not express a strong correlation between LLM grading and human grading, at least compared to papers utilising graph matching algorithms @thomas2009 @Hosseinibaghdadabadi2023, nor does it recognise the inherent bias of LLMs @ranjan2024 or their inherent non-determinism (even with a zeroed temperature) @brenndoerfer2025 @atil2025, which make it a sub-optimal solution for consistent, fair grading.

#cite(<Bouali2025>, form: "prose") uses various LLMs (Llama, GPT-o1 mini, Claude) to grade, translating the models into text instead of giving the LLM images directly such as #cite(<Wang2025>, form: "prose"). While they achieve a Pearson correlation to human grading of 0.76 with both ChatGPT and Claude, they run into the same inconsistency issues as #cite(<Wang2025>, form: "author"): "while the models would provide a final score as requested in the prompt’s response format, this score often did not match the actual sum of points awarded in their criterion-by-criterion assessment", and ""One ChargingPort is associated with One Vehicle" was matched with "One ChargingPort is associated with One ChargingStation" with a similarity of 0.92, despite describing different domain relationships" #cite(<Bouali2025>, supplement: "p.164").

#cite(<Bouali2025>, form: "author") identify the problem with grading with LLMs perfectly, stating that "This discrepancy can be attributed to the autoregressive nature of LLMs, where they generate responses token by token" #cite(<Bouali2025>, supplement: "p.164"). Because these models are in their very essence based on predicting tokens @Ferraris2025, there is no formal guarantee that results are internally consistent and thus grades are produced with accuracy. The fact that LLMs produce grades that correlate with human grading does not mean that this grading is done in a fair, consistent, or reliable manner. While #cite(<Bouali2025>, form: "author") try to reduce the non-determinism of LLMs by setting the temperature to zero, this does remove non-determinism necesssarily, nor does it correct training biases, as mentioned before.

#cite(<RajiRamachandran2025>, form: "prose"), unlike the previous papers, use a human-in-the-loop design in combination with both purely algorithmic steps, using LLMs only for similarity matching. Using structural matching algorithms similar to papers presented in @subsec:relatedwork-autograder-algorithmic, it achieves a Mean Average Error of only 0.611, aligning very closely to human grading (see @fig:RajiRamachandran2025_Fig3). Unfortunately, the sample size was a self-procured test set of only ten images, which negatively impacts the significance of these results, not to mention that the nondeterminism introduced by the LLMs will impact the consistency of grading, although it is unclear how much.

#figure(
  box(inset: (left: -10pt), image("pics/RajiRamachandran2025_Fig3.jpg", width: 98%)),
  caption: [ #cite(<RajiRamachandran2025>, form: "prose", supplement: "p.13"): Comparison of expert scores and CodeLLama scores using a combination of `all-MiniLM-L6-v2` and `msmarc-MiniLM` as word similarity models. ],
)<fig:RajiRamachandran2025_Fig3>


In conclusion, while GenAI-based grading has been attempted in recent years, purely GenAI solutions produce lacking similarity to human grading compared to graph isomorphism-based solutions as well as introducing fundamental non-deterministic behaviour / hallucinations. This makes these types of solutions inferior to graph isomorphism solutions for full automatic grading. However, when used particularly for semantic and/or syntactic matching, it may provide similar performance to algorithmic solutions (although it still gives way to nondeterminstic grading and should be carefully evaluated.

== Conclusion
Existing frameworks seem to recommend structural matching in combination with syntactic and semantic matching to still match solutions containing typos and/or synonyms.

Existing implementations mostly use the recommended methods from frameworks. Using determinstic, graph isomorphism algorithms seem to produce the best results. Purely GenAI methods require less effort from teachers, since they do not need to produce sample solution(s), but produce subpar results to graph matching. Using GenAI for semantic matching seems to produce similar results, but does not provide major advantages over algorithmic solutions and can introduce nondeterminism in otherwise determinstic solutions, which reduces consistency.

#highlight([TODO mention techniques to use from the conclusion here? or at Tools&Techniques?])

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
  #show table.cell.where(body: [M]): t => text(fill: rgb("#EA7C32"), strong(t))
  #show table.cell.where(body: [L]): t => text(fill: rgb("#C84312"), strong(t))
  #show table.cell.where(body: [?]): t => t
  #show table.cell.where(y: 0): c => { 
    set block(fill: rgb("#252525"))
    set text(fill: white)
    c
  }

  #figure(
    table(columns: (4fr, 2fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      inset: 3pt,
      align: (left+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon,),
        table.header(
        [Author],                                        [Diagram(s)],   [Ac], [Co], [Tr], [OSS], [ILO], [Int], [UTML],
      ),

      [#cite(<Bian2020>, form: "prose")],                [UML Class],    [H],  [H],  [H],  [N],   [N],   [?],   [N],
      [#cite(<Hosseinibaghdadabadi2023>, form: "prose")],[UML Use Case], [H],  [H],  [?],  [N],   [N],   [?],   [N],
      [#cite(<anas2021>, form: "prose")],                [UML Class],    [M],  [H],  [?],  [N],   [N],   [?], [N],
      [#cite(<Modi2021>, form: "prose")],                [UML Class],    [?],  [H],  [?],  [N],   [N],   [?], [N],
      [#cite(<Jebli2023>, form: "prose")],               [UML Class],    [?],  [H],  [?],  [N],   [N],   [?], [N],
      [#cite(<Ali2007>, form: "prose")],                 [UML Class],    [?],  [H],  [?],  [N],   [N],   [?], [N],
      [#cite(<AlRawashdeh2014>, form: "prose")],         [UML State/Sequence],[?],[H],[?],  [N],   [N],   [?], [N],
      [#cite(<Striewe2011>, form: "prose")],             [UML Class],    [?],  [H],  [?],  [N],   [N],   [?], [N],
      [#cite(<Foss2022>, form: "author") @Foss2022 @Foss2022a @Foss2022b],[ER],[?],[H],[?],[N],[N],[?], [N],
      [#cite(<thomas2009>, form: "author") @thomas2004 @thomas2006 @thomas2009 @thomas2009 @thomas2011],[ER],[H],[H],[?],[M],[N],[?], [N],

      [#cite(<Stikkolorum2019>, form: "prose")],         [UML Class],    [L],  [L],  [L],  [L],   [N],   [?], [N],
      [#cite(<Wang2025>, form: "prose")],                [UML],          [M],  [L],  [M],  [H],   [N],   [M], [N],
      [#cite(<Bouali2025>, form: "prose")],              [UML Class],    [M],  [M],  [M],  [H],   [N],   [M], [N],
      [#cite(<RajiRamachandran2025>, form: "prose")],    [ER],           [H],  [M],  [H],  [L],   [N],   [?], [N],
    ),
    caption: figure.caption(position: bottom, [
      #highlight([TODO FIX TRANSPARENCY]) \
      #highlight([TODO explain integration ease]) \
      #highlight([TODO explain Transparency]) \
      Autograders and their suitability scores. \
      #align(left, [ 
        \*Di(_agram type_), Ac(_curacy_), Co(_nsistency_), Tr(_ansparency_), OSS = _availability of source code_, ILO = _ease of linking grading to ILOs_, Int(_egration ease_), UTML _support_. \
        #v(2pt)
        Scoring is divided into "N" (_No Support_), "L" (_Low_), "M" (_Medium_), "H" (_High_), and "?" (_Unknown_), which gives an indication of suitability w.r.t. that particular criterium. The scoring is done in a comparative way, with the lowest-scoring solution receiving a "L", the highest scoring receiving a "H". A high *consistency* is awarded for determinstic solutions. High *transparency* is awarded for solutions that explain the exact grade that was given in terms of rubrics (medium for full rubrics that might not match (i.e. LLM solutions)). High *integration ease* is given to solutions that features solutions that have guides on building and deploying them (medium for small custom programs that are needed).
      ])
    ]),
  )
]

