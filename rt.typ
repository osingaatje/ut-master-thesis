#import "typst-template-ut/typst-template-paper.typ" : conf, abstr, appendix

#let todo = highlight

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

#let seshat = text([_Seshat_])

#columns(2, gutter: 10pt, [

// todo styling
#set todo(radius: 2pt)

#abstr(content: 
  [
    During computer science studies, students are often required to submit UML diagrams. The grading of these diagrams is mainly done by humans, resulting in a costly, lengthy, and error-prone process. In this paper, we investigate the theoretical feasability of automatically grading UML diagrams, focusing on the UTML variant developed at the University of Twente. We find that graph isomorphism algorithms that account for synonyms and spelling mistakes provide the best results and propose #seshat, an algorithmic autograder that combines the aforementioned techniques and adapts them for UTML. In the final thesis, we compare #seshat to human grading for multiple UTML exam submission datasets.
  ]
)

= Introduction <intro>
// Current state of grading + autograding, University of Twente is looking into ways to save time and money in grading by automating (parts of) it.

Unified Modelling Language (UML) diagrams, introduced by the Object Management Group @omg-group, play a significant role in computer science, as they allow for communicating software designs in a standardised format. During technical studies, students are often required to make UML diagrams for graded assignments or exams.

However, the grading of these diagrams is often a costly and lengthy process, involving multiple paid members of staff @Ahmed2024#footnote("From personal experience.")<footnote:pers-exp>. Additionally, this process is prone to grading inconsistencies @Ahmed2024, as humans are inherently unreliable graders @Meadows2005. #cite(<Meadows2005>, form: "prose") pose two possible solutions to this problem: either "report the level of reliability associated with marks/grades, or find alternatives to [grading]." We propose a third alternative: finding alternatives to the grading _process_. Grading submissions based on a rubric, if performed by software instead of a human, reduces human inconsistencies@footnote:determinism and the time it takes to grade.

The (partial) automatisation of grading diagrams ('autograding') provides a grading paradigm that can both reduce the cost and time required for institutions and reduce the inherently present inconsistencies in human grading#footnote("Given that the process is deterministic")<footnote:determinism> @osinga2024 @Bian2020. This could result in similar or superior performance compared to human grading in terms of *accuracy*, *process transparency*, and *consistency*.

With _accuracy_, we mean the percentage of points assigned to a submission that are prescribed by the rubric for a particular excercise. With _consistency_, we mean both the extent to which similar grades are given to similar submissions, and the difference between consecutive runs (i.e. determinism). With _process transparency_, we mean the extent to which the reasoning for a particular grade is explained. These properties are desirable in the grading process, as it means that students are graded in a way that reflects their performance. 

For transparency, it would also be desirable to link Intended Learning Objectives (ILOs) to the autograder results, as this would help relate the grading to the objectives of the module, and would additionally force teachers to critically evaluate the relation of their questions to the ILOs of the module @osinga2024.

For this research, we focus on the automatic grading of _UTML_ UML diagrams: a new diagram format developed for the University of Twente @utml-internal @utml. However, as UTML is just a representation format and tool for creating UML diagrams, we aim to generalise these results to provide advice on the automatic grading of UML diagrams as a whole.

== Background <bg>
The idea of letting a computer program (partially) grade tests has been discussed in papers since the 70s #cite(<pirie1975>, supplement: "p.13"), with some implementation papers starting to appear around the 80s, primarily focused on grading the writing style of computer programs @Rees1982. Interest in specifically diagram grading seems to have started around the early 2000s @smith2004 @thomas2004.

Different types of diagrams exist, including UML diagrams, Entity-Relation diagrams, and biomedical diagrams, among others. Different formats exist for storing diagrams: XMI - the standard diagram interchange format for UML, most commonly used by the Eclipse Modelling Framework @xmi-omg, the Rose Petal format - used by the UML development program IBM Rational Rose @ibm-rational-rose, PlantUML - an open-source textual standard for representing various diagrams including UML and ER diagrams @plantuml, Visual Paradigm files - software that allows for modelling UML, architecture diagrams, business flows etc. @visualparadigm, and UTML - an in-house standard developed at the University of Twente for representing UML diagrams @utml-internal @utml-website.

The degree to which automated grading is implemented can vary as well. We divide autograding into the following categories: non-automated (manual), automated (part of the process requires no human input), and (fully) automatic (no human input is required). In this paper, we consider autograders that fall into the categories _automated_ and _automatic_.

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

*RQ1* is answered in @relatedwork, giving us an overview of existing solutions and their grading methodologies. *RQ2* is answered in @relatedwork and @tbl:grader-suitability, by analysing these works for suitability of grading. Finally, *RQ3* and *RQ4* are to be answered in the final thesis, where we grade UTML diagrams using an implementation based on related work and compare it to human grading.

= Related work <relatedwork>
In order to answer research questions *RQ1* and *RQ2*, we conduct a small-scale literature study covering roughly 40 works. This literature study aims to provide merely an exploratory view into the world of autograders, which means that formal inclusion and exclusion criteria are not set up. Works are collected from Google Scholar#footnote(link("https://scholar.google.com")) and ResearchGate#footnote(link("https://www.researchgate.net")), using terms including but not limited to "automatically grading UML diagrams", "autograder diagram", "UML diagram assessment", "machine learning diagrams", "diagram evaluation assessment AI".

== Autograders
Multiple methods and types of diagrams are researched, including proposed frameworks for autograders, purely algorithmic implementations, and Machine Learning (ML) / Generative AI (GenAI) / Large Language Model (LLM)-based methods.

=== Frameworks / Theoretical<subsec:relatedwork-autograder-frameworks>
#cite(<smith2004>, form: "prose") provide a five-step framework for assessing "possibly ill-formed or inaccurate diagrams" that include (1) segmentation, (2) assimilation, (3) identification, (4) aggregation, and (5) interpretation. While the first two steps are aimed at translating images or other "raster-based input" into diagrammatic primitives, the latter stages provide a foundation to grade diagrams used by other papers @thomas2009.

#cite(<batmaz2010>, form: "prose") takes a broader look at the process of grading, identifying and developing techniques to reduce repetitive actions, focusing on database Entity Relation diagrams. The paper suggests a semi-automatic grading system which identifies identical segments between a submission and the solution. Assuming multiple submission revisions are available, it suggests to "not only [use] the reference text but also the intermediate diagrams" for identifying semantic matches #cite(<batmaz2010>, supplement: "p.40"). While multiple solutions are not useful for the purpose of grading only a single submitted diagram after an exam, this might be useful for live feedback.

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

Multiple papers mention the use of XMI @Modi2021 @Jebli2023, the object notation standard by OMG @xmi-omg, or Rose Petal files @Ali2007 @Ali2007b, the standard of IBM Rational Rose @ibm-rational-rose, but fail to mention specifics about matching algorithms or results.

#cite(<AlRawashdeh2014>, form: "prose") provides an interesting alternative way of grading submissions: by means of combining many UML diagram validators, model checkers, and even LTL properties given by instructors. However, a clear purpose, scope, and results are lacking from the paper.

#cite(<Striewe2011>, form: "prose") continues #cite(<AlRawashdeh2014>, form: "prose")'s property checking trend by focusing on graph queries for evaluation, providing a Domain-Specific Language that looks relatively similar to SQL. While it looks promising, the fact that teachers would have to learn a query language and transform their existing rubrics/example solutions into this format could be a real hurdle, especially given the high similarity to existing grading of graph-isomorphism-based solutions @Bian2020 @Hosseinibaghdadabadi2023 @anas2021. Additionally, the paper does not provide approximate matching that would account for misspelling or synonyms.

#cite(<Foss2022>, form: "author") provide multiple papers on AutoER, a database diagram generator and evaluator that provides direct interaction with a description text @Foss2022 @Foss2022a @Foss2022b. It is more geared towards interactive use, as a feedback model before submission. Unfortunately, concrete comparisons to manual grading and source code could not be found.

#cite(<thomas2004>, form: "author") also provides a selection of paperse on the automatic grading of database diagrams @thomas2004 @thomas2006 @thomas2008 @thomas2009 @thomas2011. These papers provide a grading strategy that accounts in its basis for _imprecise_ diagrams (diagrams containing misspellings, duplicate entities, etc.), basing their analysing on comparing ever increasing subsets of the graph ((Minimal) Meaningful Units) based on the work of #cite(<smith2004>, form: "prose"). By #cite(<thomas2009>, form: "year"), #cite(<thomas2009>, form: "author") manage to achieve a correlation to human grading of 92%, along with statistically proving that the autograder grades more consistently than human grading. The graphed grading distribution can be viewed in @fig:thomas2009-results.

In #cite(<thomas2011>, form: "year") #cite(<thomas2011>, form: "author") provide an online platform for both students and teachers to ease the process of automatic grading further, also used by #cite(<smith2013>, form: "prose"), which further mathematically specify #cite(<thomas2011>, form: "author")'s work. Unfortunately, we were not able to retrace the source code of this grader.

#figure(
  box(inset: (left: -10pt), image("pics/thomas2009_Fig3.png", width: 95%)),
    caption: [#cite(<thomas2009>, form: "prose", supplement: "Fig. 3"): Human vs. automatic grading in database ER diagrams.],
)<fig:thomas2009-results>

In conclusion, most existing implementations of autotgraders use some form of graph isomorphism algorithm with a combination of structural, semantic, and syntactic matching, also suggested by the majority of frameworks. Some solutions attempt to autograde using property or formula checking, but fail to mention detailed enough methodology or results to warrant further investigation. No autograders provide methods on integrating ILOs into the grading process.

// Note to self: replicating Bian 2020 with Smith 2004 steps with advice from Thomas2004-2011 would be a good bet.

=== ML- / GenAI- / LLM-driven <subsec:relatedwork-autograder-AI>
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
In the explored related work, existing frameworks primarily recommend structural matching in combination with syntactic and semantic matching to be able to match solutions containing spelling mistakes and the use of synonyms. Existing implementations mostly use the methods recommended by the frameworks, with the best results stemming from determinstic, graph isomorphism algorithms, albeit at the cost of the teacher having to produce one or more sample solutions. Purely GenAI methods require less effort from teachers, since they do not need to produce sample solution(s), but produce noticeably subpar results to graph matching algorithms. Using hybrid methods, with GenAI for semantic/syntactic matching and graph isomorphism for structural matching, seems to produce similar results to 'pure' graph matching algorithms, but seemingly does not provide major advantages over algorithmic solutions and can additionally introduce nondeterminism in otherwise determinstic solutions, which reduces consistency.


#place(bottom+center, scope: "parent", float: true, [
  #show table.cell.where(body: [N]): t => text(fill: rgb("#CC1212"), strong(t))
  #show table.cell.where(body: [H]): t => text(fill: rgb("#12CC12"), strong(t))
  #show table.cell.where(body: [M]): t => text(fill: rgb("#EA7C32"), strong(t))
  #show table.cell.where(body: [L]): t => text(fill: rgb("#C84312"), strong(t))
  #show table.cell.where(body: [?]): t => t
  
  #figure(
    table(columns: (4fr, 2fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      inset: 3pt,
      align: (left+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon,),
      table.header(
        [Author],                                        [Diagram(s)],   [Ac], [Co], [Tr], [OSS], [ILO], [UTML],
      ),

      [#cite(<Bian2020>, form: "prose")],                [UML Class],    [H],  [H],  [H],  [M],   [N],  [N],
      [#cite(<Hosseinibaghdadabadi2023>, form: "prose")],[UML Use Case], [H],  [H],  [H],  [M],   [N],  [N],
      [#cite(<anas2021>, form: "prose")],                [UML Class],    [M],  [H],  [H],  [M],   [N],  [N],
      [#cite(<Modi2021>, form: "prose")],                [UML Class],    [?],  [H],  [H],  [M],   [N],  [N],
      [#cite(<Jebli2023>, form: "prose")],               [UML Class],    [?],  [H],  [H],  [M],   [N],  [N],
      [#cite(<Ali2007>, form: "author") @Ali2007 @Ali2007b],[UML Class], [?],  [H],  [L],  [L],   [N],  [N],
      [#cite(<AlRawashdeh2014>, form: "prose")],    [UML State/Sequence],[?],  [H],  [?],  [M],   [N],  [N],
      [#cite(<Striewe2011>, form: "prose")],             [UML Class],    [?],  [H],  [H],  [L],   [N],  [N],
      [#cite(<Foss2022>, form: "author") @Foss2022 @Foss2022a @Foss2022b],[ER],[?],[H],[?],[M],   [N],  [N],
      [#cite(<thomas2009>, form: "author") @thomas2004 @thomas2006 @thomas2008 @thomas2009 @thomas2011],[ER],[H],[H],[H],[M],[N],[N],

      [#cite(<Stikkolorum2019>, form: "prose")],         [UML Class],    [L],  [L],  [L],  [L],   [N],  [N],
      [#cite(<Wang2025>, form: "prose")],                [UML],          [M],  [L],  [M],  [M],   [N],  [N],
      [#cite(<Bouali2025>, form: "prose")],              [UML Class],    [M],  [M],  [M],  [M],   [N],  [N],
      [#cite(<RajiRamachandran2025>, form: "prose")],    [ER],           [H],  [M],  [H],  [M],   [N],  [N],
    ),
    caption: figure.caption(position: bottom, [
      Autograders and their suitability scores. \
      #align(left, [ 
        \*Di(_agram type_), Ac(_curacy_), Co(_nsistency_), Tr(_ansparency_), OSS = how open source is solution, ILO = _ease of linking grading to ILOs_, UTML _support_. \
        #v(2pt)
        Scoring is divided into "N" (_No Support_), "L" (_Low_), "M" (_Medium_), "H" (_High_), and "?" (_Unknown_), which gives an indication of suitability w.r.t. that particular criterium. The scoring is done in a comparative way, with the lowest-scoring solution receiving a "L", the highest scoring receiving a "H". A high *consistency* is awarded for determinstic solutions. High *transparency* is awarded for solutions that explain the exact grade that was given in terms of rubrics (medium for full rubrics that might not match (i.e. LLM solutions)). High *OSS* is given to solutions that completely open-source their work, with lower scores indicating that partial algorithms/methods are available. For GenAI solutions, OSS also takes into account the open source nature of the models used.
      ])
    ]),
  )<tbl:grader-suitability>
])


= Tools and Techniques <tools-techniques>
Given existing works, the best approach for maximising accuracy, consistency, and transparency seems to be to use graph isomorphism algorithms akin to those suggested by #cite(<smith2013>, form: "prose"), implemented by #cite(<Bian2020>, form: "prose") and #cite(<thomas2009>, form: "prose"). Using a visual representation such as @fig:Bian2020_Fig9 could prove to be a nice addition, so architectural support for visualisations will be taken into account, which can be implemented, should there be enough time.

Unfortunately, no solutions seem to support the integration of ILOs into their grading rubric inputs. While we believe that this is a vital point to consider when making rubrics or example solutons @osinga2024, we realise that it may incur extra work for a teacher to add metrics on how much a certain ILO is tested. #todo([ How to incorporate ILO weighting ])

Since existing solutions that feature these techniques have not published their source code (see @tbl:grader-suitability), we develop our own autograder, named #seshat#footnote([ The Egyptian record-keeping godess and daughter of _Thoth_, the name of #cite(<osinga2024>, form: "prose")'s autograder. ]).

== Architecture
Autograder needs to
- take input (might take a while, support for extensions / web interfaces / ...)
- run algorithm on it (specifically: MMU-based algorithm @thomas2009)
- produce set of scores according to matched elements etc.
- format these scores in a certain way (might take a while, support for extensions)

We use a query-based framework, akin to that of the Rust compiler @rustc-book. This choice is made because it encourages decoupling things such as input parsing, running the algorithm, and formatting output. This additionally supports transparency internally in the grading process, as one can easily query intermediate solutions from the grading process.

Additionally, a query-based architecture allows for caching all stages of the process, which is only possible since we make the explicit choice to use only deterministic algorithms. This allows for efficiency improvements if we need to refetch some parsed input, or if we need to grade a solution we have already seen before.

== Framework(s)


== Language(s) 
Many languages would be suitable to do this project in: Object-Oriented languages such as Java or JVM-based languages, C\#, or Python could be suitable because of their familiarity to us and the general programmer, increasing the chance that future programmers can extend this tool. Functional languages such as Haskell, Erlang, Elixir or F\# would also be quite suitable, since their functional nature coincides with the deterministic nature of the algorithms. However, multi-paradigm languages such as Go or Rust can strike a balance between the imperative nature of Object-Oriented languages and the overlapping mental model of functional languages and autograding.

We opt for Go, as it is a statically typed and compiled language, which should allow us to create a robust architecture that allows for fast grading. Additionally, it is not Object-Oriented, but still allows for attaching methods to certain data structures, thereby allowing us to express the diagrams as pure structs while still allowing for the familiar dot-syntax (`object.property` or `object.method()`) of Object-Oriented languages. Finally, we opt for Go as it needs not strictly adhere to concurrency models and memory safety such as Rust, but still has a garbage collector, which should make it faster and easier to develop #seshat.


= Planning <planning>
We plan to develop #seshat according to the Agile. This means that we divide the work up into increments, and aim to show new deliverables frequently. This prioritises prototyping and frequent feedback, allowing the supervisors to steer the direction of the project effectively. 

We divide these increments up into two weeks. This should allow for enough time inbetween to make significant progress on #seshat and the final paper, while keeping increments small enough to be able to reflect on the progress made often and make adjustments to the plan if necessary. We meet with the supervisor every increment, and a meeting is planned with the co-supervisor every two increments. We invite the co-supervisor to every meeting, but they are free to attend when they wish to see progress and/or give advice. When in doubt, we explicitly ask advice of both supervisors to get a view that spans multiple perspectives.

The general idea is to start off working on the final paper for two increments, mainly focused on formalising the literature review in order to get a bit more background information on how to continue. Afterwards, we move into the implementation phase, where we work on #seshat, prioritising a minimal product that can take UTML submissions and spit out some results. Finally, we compare the solution to existing grading in the last few increments, as well as finalising the paper and letting it be reviewed by peers.

During the development of #seshat, we add to the paper in parallel, documenting design decisions and progress, in addition to keeping a daily journal of our progress to be able to more effectively reflect on the process, which should aid in planning efficiency.

The increments are initially structured in the way defined in @fig:planning.
#place(bottom+center, scope: "parent", float: true,
    [
    #set table(stroke: 0pt)
    #set table.hline(stroke: 1pt)
    #set table.vline(stroke: 1pt)
    #figure(
    table(
      columns: (auto,auto,auto,auto,1fr),
        inset: 3pt,
        align: (center+horizon, center+horizon, center+horizon, left+horizon, left+horizon),
        table.header(
          table.hline(),
          table.cell(colspan: 4, [ Increment ]),  [ Task ],
          table.hline(),
        ),
          table.vline(x: 0, start: 0, end: 1000), table.vline(x: 4, start: 0, end: 1000), table.vline(start: 0, end: 1000),

          [Wk.], [ 6],[-],[ 7],   [ Literature review ],  table.hline(),
          [Wk.], [ 8],[-],[ 9],   [ Literature review ], table.hline(),
          [Wk.], [10],[-],[11],   [ #seshat - general framework ], table.hline(),
          [Wk.], [12],[-],[13],   [ #seshat - (UTML) input parsing ], table.hline(),
          [Wk.], [14],[-],[15],   [ #seshat - input parsing ], table.hline(),
          [Wk.], [16],[-],[17],   [ #seshat - grading/grade formatting ], table.hline(),
          [Wk.], [18],[-],[19],   [ #seshat - grading/grade formatting ], table.hline(),
          [Wk.], [20],[-],[21],   [ #seshat - finishing touches / comparison to manual grading ], table.hline(),
          [Wk.], [22],[-],[23],   [ #seshat - comparison to manual grading ], table.hline(),
          [Wk.], [24],[-],[25],   [ Paper finishing touches ], table.hline(),
          [Wk.], [26],[-],[27],   [ Paper finishing touches + peer reviews ], table.hline(),
    ),
    caption: [ Increment planning of the final thesis. Note that paper development is done in parallel to the development of #seshat. ]
  )<fig:planning>]
)

]) // 2-column

#pagebreak()
#bibliography("refs.bib")

// #heading(numbering: none, [ Appendices ])
// #show: appendix

