#import "typst-template-ut/typst-template-paper.typ" : conf, abstr, appendix
#import "stats/stats.typ" : *
#import "@preview/lilaq:0.6.0" as lq // graphing

#let darkyellow = color.rgb("#B3A638")

// shortcuts / other helper functions
#let hl = highlight
#let todos_on = false
#let todo(..content) = if todos_on { block([#text(fill: red, [TODO]) #highlight(..content)]) } else { none }

#let seshat = text([_Seshat_])

#let DOC-MARGIN = 1.5cm

#set document(title: [Automatic analysis and grading of UTML UML diagrams])

#show: conf.with(
  doctyp: "Final Project",
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

  citestyle: "../shared/bib/modified-ieee.csl",
  bibstyle: "../shared/bib/modified-ieee-all-authors.csl",
)

#set page("a4", margin: DOC-MARGIN)

#set text(hyphenate: true)

#columns(2, gutter: 10pt, [


#abstr([
    During computer science studies, students are often required to submit diagrams. The grading of these diagrams is currently done by humans, resulting in a costly, lengthy, and error-prone process. In this paper, we investigate the theoretical feasibility of automatically grading diagrams, focusing on Unified Modelling Language diagrams and the UTML software and file format used by the University of Twente. Existing work shows that graph isomorphism algorithms which incorporate algorithms to account for the use of synonyms and the presence of spelling mistakes provide the best grading results. However, autograders utilising these techniques are not reproducible or open-source. Therefore, we propose #seshat, an open-source autograder that combines the aforementioned techniques and is capable of supporting arbitrary diagrams and file formats, with built-in support for UTML. We compare #seshat to human grading across four datasets entries and find that, with an exercise that demands a specified set of solutions, autograding can largely replace human grading.
])

= Motivation
Unified Modelling Language (UML) diagrams, introduced by the Object Management Group @omg-group, play a significant role in computer science, as they allow for communicating software designs in a standardised format. During technical studies, students are often required to make such diagrams for graded assignments or exams.

However, the grading of these diagrams is often a costly and lengthy process, involving multiple paid staff members#footnote("From personal experience.")<footnote:pers-exp>@Ahmed2024. Additionally, this process is prone to grading inconsistencies due to various reasons @Ahmed2024, with a major factor being the inherent inconsistency of human graders @Ahmed2024 @Meadows2005. #cite(<Meadows2005>, form: "prose") pose two possible solutions to the problem of human grading: either "report the level of reliability associated with marks/grades, or find alternatives to [grading]." We propose a third alternative: finding alternatives to the grading _process_.

The (partial) automatisation of grading diagrams ('autograding')  a grading paradigm that can both reduce the cost and time required for institutions and reduce the inherently present inconsistencies in human grading#footnote("Given that the process is deterministic.")<footnote:determinism> @osinga2024 @Bian2020. This could result in similar or superior performance compared to human grading in terms of *accuracy*, *consistency*, and *grading transparency*.

With _accuracy_, we mean the percentage of points assigned to a submission that are prescribed by the rubric for a particular excercise. With _consistency_, we mean both the extent to which similar grades are given to similar submissions and the difference between consecutive runs (i.e. determinism). With _grading transparency_, we mean the extent to which the reasoning for a particular grade is explained with regards to the rubric for the exercise or to the Intended Learning Objectives (ILOs) of a module. These properties are desirable in the grading process, as it means that students are graded in a way that reflects their performance (_accuracy_), allows them to see which parts they could improve for future assignments (_grading transparency_), and is minimally unfair (_consistency_).

Specifically for the implementation, we desire an autograder that can _link its grading to ILOs_, as described by the previous paragraph. Furthermore, _UTML support_ must either be included or able to be programmed in, as it is the main file format the University of Twente uses. Finally, _extensibility_ in general would be ideal, since we might want to extend support to other file formats or alter the behaviour of the autograder later on.

== A brief history of autograding<bg>
The idea of letting a computer program (partially) grade tests has been discussed in papers since the 70s #cite(<pirie1975>, supplement: "p.13"), with some documented implementations starting to appear around the 80s. These were primarily focused on grading the writing style of computer programs @Rees1982. Interest in grading diagrams specifically seems to have started around the early 2000s @smith2004 @thomas2004.

== Diagrams categories and formats
#box(width: 98%, inset: (left:1%), [
  #figure(caption: [ An example UTML UML class diagram. ], [
    #image("./pics/example-UML-diagram.png")
  ])<pic:ex-class-diag>
])
Diagrams themselves have several categories, each for different purposes. UML diagrams, as shown in @pic:ex-class-diag, mainly serve to visualise and document software @omg-group, while Entity-Relation diagrams, such as shown in @pic:ex-ER-diag, focus on the relations between different components, making it ideal for visualising database designs @Bagui2003.

#box(width: 98%, inset: (left:1%), [
  #figure(caption: [ An example Entity Relation diagram \ in the Chen format. ], [
    #image("./pics/ex-ER-diag.png")
  ])<pic:ex-ER-diag>
])

Different formats exist for storing these diagrams. Examples include XMI - the standard diagram interchange format for UML, most commonly used by the Eclipse Modelling Framework @xmi-omg, the Rose Petal format - used by IBM Rational Rose @ibm-rational-rose, PlantUML - an open-source textual standard for representing various diagrams including UML and ER diagrams @plantuml, VPP files - used by Visual Paradigm, software that allows for modelling UML, architecture diagrams, business flows etc. @visualparadigm, and UTML - a program and file format used at the University of Twente for representing UML and various other types of diagrams, its file format building on the JSON standard @utml-internal @utml-website.

The degree to which automated grading is implemented can vary as well. We divide autograding into the following categories: _non-automated_ (everything must be done by a human), _automated_ (part of the process requires no human input), and (fully) _automatic_ (no human input is required). In this paper, we only consider autograders that fall into the categories _automated_ and _automatic_.

= Research Questions <rqs>
In order to examine the feasibility of automatically grading UML diagrams saved in the UTML format, we provide a main research question (*MRQ*):

#align(center, [
  *To what extent can UML diagrams be graded automatically while maintaining or improving the accuracy, consistency, and grading transparency of human grading?*
])

We aim to answer the main research question with the following research questions:

#let rq(content) = box(inset: (left: 10pt), content)

#rq([ *RQ1*: To what extent are existing solutions suitable for use in autograding UTML diagrams with regards to (1) accuracy, (2) consistency, (3) grading transparency, (4) extent of linking ILOs to grading instructions, (5) UTML support, and (6) extensibility? ])

#rq([ *RQ2*: To what extent can a suitable autograder be constructed from previous work to be able to grade UTML diagrams? ])

#rq([ *RQ3*: To what extent does the suitable autograder compare to human grading in the context of grading first-year UML exam questions? ])

*RQ1* is answered in @relatedwork, by analysing existing work for suitability of grading. These works are categorised according to the requirements outlined by *RQ1* and presented in @tbl:grader-suitability. @solution explains the features and reasoning behind #seshat. @results offers perspectives into its performance compared to human grading, after which we discuss in @discussion and conclude in @conclusion.

= Related work <relatedwork>
In order to answer research questions *RQ1*, we conduct a small-scale literature mapping study @Soaita2019. We aim to provide an comprehensive, but not exhaustive, view into the world of autograders and ILOs, which is why we omit formal inclusion and exclusion criteria. Works are collected using the search engines Google Scholar#footnote(link("https://scholar.google.com")) and ResearchGate#footnote(link("https://www.researchgate.net")). Autograder material is queried with terms including but not limited to "automatically grading UML diagrams", "autograder diagram", "UML diagram assessment", "machine learning diagrams", and "diagram evaluation assessment AI". Material regarding ILOs and ILO integration into rubrics was searched with terms such as "learning outcomes include in rubric", "learning objectives in rubrics", and similar. Snowballing (the practice of looking at sources of sources) is used, to a depth of 1. After starting with roughly 40-45 works and removing the non-relevant or less noteworthy papers, we arrive at a compact set of sources that offer a general view of autograding across literature.

== Autograders
Multiple technologies and strategies for autograding exist, which we categorise into the following categories: frameworks for autograders, purely algorithmic autograder implementations, and Generative AI (GenAI) or Machine Learning (ML) implementations. Findings on implementations are summarised in @tbl:grader-suitability.

=== Frameworks / Theoretical<subsec:relatedwork-autograder-frameworks>
Autograder frameworks dictate certain designs or methodologies for building autograders. We present summaries of the most relevant explored frameworks, and provide a general summary at the end.

#cite(<smith2004>, form: "prose") provide a five-step framework for assessing "possibly ill-formed or inaccurate diagrams" that include the steps (1) segmentation, (2) assimilation, (3) identification, (4) aggregation, and (5) interpretation. While the first two steps are meant for translating images or other "raster-based input" into diagrammatic primitives, which is not useful for us, the latter stages provide a solid conceptual foundation to grade diagrams.

#cite(<batmaz2010>, form: "prose") takes a broader look at the grading process, identifying and developing techniques to reduce repetitive actions, focusing on database ER diagrams. The paper suggests a semi-automatic grading system, including automatic grading based on identifying identical segments between a submission and the solution.

#cite(<Vachharajani2014>, form: "prose") propose an architecture specifically for UML use case diagrams, providing a useful catalogue about edge cases related to diagram creation, such as the chance of misspellings, synonyms, abbreviations, directionality of relationships, to list a few.

#cite(<Bian2019>, form: "prose") establish two models: one to map submissions to example solutions and one to grade submissions. It recommends syntactic matching to help with spelling mistakes, semantic matching to match related words, and structural matching to match neighbouring elements and/or inheritance, with the goal to most efficiently match parts of a student submission with a sample solution.

In conclusion, most autograder frameworks recommend the same set of techniques for autograding: structural matching to identify similar segments of graphs, often in combination with syntactic matching that accounts for misspellings and semantic matching to account for synonyms or related words.

=== Algorithmic <subsec:relatedwork-autograder-algorithmic>
Some papers also mention concrete implementations of autograders, some of which based on the aforementioned frameworks, of which a subset uses purely algorithmic methods. Summaries of these sources are discussed in this section, along with a general summary on algorithmic autograders.

#cite(<Bian2020>, form: "prose") implement their previously mentioned framework @Bian2019 and validate it using a case study. They use the Levenshtein distance between words for syntactic matching, several algorithmic metrics for semantic similarity, and structural matching based on similar attributes and operations within classes. They find that comparing submissions to multiple solution variants results in more accurate grades with an average accuracy over 95% #cite(<Bian2020>, supplement: "p.10"). Additionally, they find that grading configurations need to change per exam if the goal is to produce the most similar scores to manual grading, likely because the focus of each exam or exercise lays on a different aspect of diagram creation. Additionally, they state that autograding "has shown to be more consistent and able to ensure fairness in the grading process" compared to manual grading #cite(<Bian2020>, supplement: "p.11"). Finally, their visual feedback system seems to be a useful addition, clearly visualise grading results which is likely to be more intuitive for both graders and students compared to pure text output. An example is shown in @fig:Bian2020_Fig9.

#place(top+left, dy: .5em, float: true, [
  #figure(image("pics/Bian2020_Fig9.png", width: 96%),
  caption: [Visual feedback module from #cite(<Bian2020>, form: "prose", supplement: "Fig.9")]
  )<fig:Bian2020_Fig9>
])

#cite(<Hosseinibaghdadabadi2023>, form: "prose") also implement #cite(<Bian2019>, form: "prose")'s framework, comparing UML use case diagrams to one or multiple example solutions and preferring the maximum grade. They use a graph similarity algorithm which matches nodes based on structural matching, along with syntactic matching using the Levenshtein distance between words and semantic matching using a WordNet similarity score (HSO, WUP, LIN metrics). It achieves a similarity percentage of 93.31% #cite(<Hosseinibaghdadabadi2023>, supplement: "p.114").

#cite(<anas2021>, form: "prose") compare UML class diagram submissions to an example solution. They use a graph similarity scoring algorithm based on structural matching along with syntactic and semantic matching. Syntactic matching is done with substring matching and semantic matching is done with neighbour similarity ("the comparison of the neighboring classes" #cite(<anas2021>, supplement: "p.1585")), relationship name, type, multiplicity, and inheritance. It achieves a respectable correlation with human grading, with more than 80% of submissions receiving identical grades, more than 90% of grades with a corelation larger than 0.85, and no grades with a correlation lower than 70%.

// Multiple papers mention the use of XMI @Modi2021 @Jebli2023, the object notation standard by OMG @xmi-omg, or Rose Petal files @Ali2007 @Ali2007b, the standard of IBM Rational Rose @ibm-rational-rose, but fail to mention specifics about matching algorithms or results.

#cite(<AlRawashdeh2014>, form: "prose") provide an interesting alternative way of grading submissions: they combine many UML diagram validators, model checkers, and even use LTL properties. However, a clear purpose, scope, and results are missing from the paper.

#cite(<Striewe2011>, form: "prose") also attemp property checking akin to the work of #cite(<AlRawashdeh2014>, form: "prose") by focusing on graph queries for evaluation, providing a domain-specific language that looks similar to SQL. While it offers an interesting alternative approach, the fact that teachers would have to learn a query language and transform their existing rubrics/example solutions into this format could be a real hurdle, especially given the performance of graph-isomorphism-based solutions @Bian2020 @Hosseinibaghdadabadi2023 @anas2021. Additionally, the paper does not account for misspellings or the use of synonyms.

// #cite(<Foss2022>, form: "author") present AutoER, a database diagram generator and evaluator that provides direct interaction with a description text @Foss2022 @Foss2022a @Foss2022b. However, instead of being geared towards exam grading, it is meant for interactive use: it provides intermediate results and hints during the diagram creation process, before handing in the final submission. While the solution may have been useful to our use case, concrete comparisons to manual grading and its source code could not be found.

#cite(<thomas2004>, form: "author") /*, like #cite(<Foss2022>, form: "author"),*/ provide a selection of works detailing the autograding of ER diagrams /*. Unlike #cite(<Foss2022>, form: "author"), */ which /*focuse on a _single_ assessment point and */ account in their basis for diagrams containing misspellings, duplicate entities, and other imprecisions @thomas2004 @thomas2006 @thomas2008 @thomas2009 @thomas2011. They analyse graphs by comparing ever increasing subgraphs called (Minimal) Meaningful Units, based on the work of #cite(<smith2004>, form: "prose"). By #cite(<thomas2009>, form: "year"), #cite(<thomas2009>, form: "author") manage to achieve a correlation to human grading of 92%, along with statistically proving that their autograder grades more consistently than human grading. The correlation to human grading can be seen in @fig:thomas2009-results.

In #cite(<thomas2011>, form: "year") #cite(<thomas2011>, form: "author") also mention an online platform for both students and teachers to ease the process of automatic grading further, also used by #cite(<smith2013>, form: "prose"), which additionally contains more mathematical explanations of their previous work. Unfortunately, the source code of this autograder is untraceable.

#figure(
  box(inset: (left: -10pt), image("pics/thomas2009_Fig3.png", width: 95%)),
    caption: [#cite(<thomas2009>, form: "prose", supplement: "Fig. 3"): Human vs. automatic \ grading in database ER diagrams.],
)<fig:thomas2009-results>

In conclusion, most existing implementations of autograders use some graph isomorphism algorithm with a combination of structural, semantic, and syntactic matching, as suggested by the majority of discovered frameworks. Some solutions attempt to autograde using property or formula checking, but fail to mention a detailed enough methodology or results to warrant further investigation.

// Note to self: replicating Bian 2020 with Smith 2004 steps with advice from Thomas2004-2011 would be a good bet.

=== Machine Learning / Generative AI <subsec:relatedwork-autograder-AI>
Next to using purely algorithmic methods, some papers experiment with Machine Learning / Generative AI (ML/GenAI) to automatically grade submissions. There are even some hybrid ML and algorithmic solutions. We provide summaries of the explored sources below, along with a general conclusion on ML/GenAI autograders.

#cite(<Stikkolorum2019>, form: "prose"), one of the earliest found sources, attempts Machine Learning-based autograding using several machine learning algorithms to compare submissions to expert grades. Unfortunately, the grading only reaches a maximum accuracy of 42.76%, while rounding off scores to a 10-point integer scale. Exact methods and algorithms are not mentioned.

#cite(<Wang2025>, form: "prose") evaluate the feasibility of LLM-based grading with the LLM model ChatGPT-4o, focusing on student reports containing multiple types of UML diagrams. They feed pictures of student-submitted UML diagrams directly into the model along with an explanatory prompt that aims to trigger a Chain-of-Thought process (which should help LLMs "tackle complex arithmetic, commonsense, and symbolic reasoning tasks" @wei2023), and runs the model once per submission, with a temperature of 0.1. They find that score differences range from -0.25 to +3.75 points, with with the LLM handing out significantly lower average scores compared to humans. Additionally, they note many occurrences of incorrect grading (wrong identifications, overstrictness, and misunderstandings) #cite(<Wang2025>, supplement: "p.18"), which means that, while the authors claim that their solution "demonstrates particular proficiency in the automated evaluation of UML use case diagrams", the grading is not internally consistent and contains hallucinations. In the words of the authors: "In the evaluation based on UC4, GPT deducts points for missing relationships between specified actors and use cases, but theses relationships existed in the UML use case" #cite(<Wang2025>, supplement: "p.13"). Furthermore, the paper does not express a strong correlation between LLM grading and human grading, at least compared to papers utilising graph matching algorithms @thomas2009 @Hosseinibaghdadabadi2023, nor does it recognise the inherent bias of LLMs @ranjan2024 or their inherent nondeterminisim (even with a zeroed temperature) @brenndoerfer2025 @atil2025.

#cite(<Bouali2025>, form: "prose") uses various LLMs (Llama 3.2B, ChatGPT-o1 mini, and Claude Sonnet) to grade diagrams, first translating the diagrams into text instead of giving the LLM images directly like #cite(<Wang2025>, form: "prose"). While they achieve a Pearson correlation to human grading of 0.76 with both ChatGPT and Claude, they run into the same inconsistency issues as #cite(<Wang2025>, form: "author"): "while the models would provide a final score as requested in the prompt’s response format, this score often did not match the actual sum of points awarded in their criterion-by-criterion assessment", and "'One ChargingPort is associated with One Vehicle' was matched with 'One ChargingPort is associated with One ChargingStation' with a similarity of 0.92, despite describing different domain relationships" #cite(<Bouali2025>, supplement: "p.164").

#cite(<Bouali2025>, form: "author") identify the problem with grading with LLMs perfectly, stating that "This discrepancy can be attributed to the autoregressive nature of LLMs, where they generate responses token by token" #cite(<Bouali2025>, supplement: "p.164"). Because these models are in their very essence based on predicting tokens @Ferraris2025, there is no formal guarantee that the grades are internally consistent and that grades are produced accurately with respect to the rubric. The fact that LLMs produce grades that correlate with human grading does not mean that this grading is done in a fair, consistent, or reliable manner. While #cite(<Bouali2025>, form: "author") try to reduce the nondeterminisim of LLMs by setting the temperature to zero, this does not necesssarily remove non-determinism @brenndoerfer2025 @atil2025, nor does it account for training biases @ranjan2024, as mentioned before.

#place(top+center, float: true, scope: "column", [
  #figure(
    box(inset: (left: -10pt), image("pics/RajiRamachandran2025_Fig3.jpg", width: 98%)),
    caption: [ #cite(<RajiRamachandran2025>, form: "prose", supplement: "p.13"): Comparison of expert scores and CodeLLama scores using a combination of `all-MiniLM-L6-v2` and `msmarc-MiniLM` as word similarity models. ],
  )<fig:RajiRamachandran2025_Fig3>
])

#cite(<RajiRamachandran2025>, form: "prose"), unlike the previous papers, use a human-in-the-loop design in combination with both purely algorithmic steps, using LLMs only for semantic and syntactic matching. Using structural matching algorithms similar to papers presented in @subsec:relatedwork-autograder-algorithmic, it achieves a Mean Average Error of only 0.611, aligning very closely to human grading (see @fig:RajiRamachandran2025_Fig3). Unfortunately, the data set contains only ten self-procured diagrams, which negatively impacts the significance of these results, not to mention that the nondeterminism introduced by the LLMs will impact the consistency of grading, although it is unclear to what extent.


In conclusion, while ML/GenAI grading has been attempted in recent years, purely ML/GenAI solutions produce lacking similarity to human grading compared to graph isomorphism-based solutions. Additionally, GenAI solutions introduce non-deterministic and biased behaviour, while providing no consistency guarantees. This makes using only these types of solutions inferior to graph isomorphism solutions in terms of _consistency_ and _grading transparency_. When used only for semantic matching, however, it can provide equal or possibly superior accuracy to algorithmic solutions, although one must be careful to not introduce nondetermism in the grading process this way which would negatively affect _consistency_.

// line break for readability
== Intended Learning Objectives \ and examination
#cite(<dinur2009>, form: "prose") states that analytical rubrics (those which mention explicit criteria) provide more details than global, holistic rubrics. These types of rubrics (and their exercises) can be constructed directly from the ILOs of a course or module, which would provide a detailed grading rubric that aligns closely to its ILOs @osinga2024. Given that rubrics and exercises are defined in such a way, one could link these ILOs to the grading rubric and provide functionality for an autograder to show these in the final grade This would indicate to students how well they achieved the learning goals of the module in order to improve _grading transparency_.


== Conclusion
In the explored related work, existing frameworks primarily recommend structural matching in combination with syntactic and semantic matching to account for spelling mistakes and the use of synonyms. Existing implementations mostly use the methods recommended by the frameworks, with the best results stemming from determinstic graph isomorphism algorithms. While GenAI autograders may require less effort from teachers, since teachers do not need to produce sample diagrams but can describe their rubric in words, they produce noticeably inferior results to graph matching algorithms and are likely to introduce nondeterminism into the grading process which reduces consisency. Using hybrid methods, specifically using ML classification algorithms only for semantic/syntactic matching, seems to produce similar results to 'pure' graph matching algorithms, but is not guaranteed to provide accuracy gains over algorithmic solutions.


#place(top+center, scope: "parent", float: true, [
  #let grn = rgb("#12CC12")
  #let ylw = rgb("#EA7C32")
  #let red = rgb("#CC1111")
  #let dark-ylw = rgb("#DD4545")

  #let bg-col-algo = rgb("#e7ffe2")
  #let bg-col-ai = rgb("#ffe4bd")
  #let bg-col-ml = rgb("#ffd8f7")

  #show table.cell.where(body: [L]): t => text(fill: red, strong(t))
  #show table.cell.where(body: [N]): t => text(fill: dark-ylw, strong(t))
  #show table.cell.where(body: [M]): t => text(fill: ylw, strong(t))
  #show table.cell.where(body: [H]): t => text(fill: grn, strong(t))
  #show table.cell.where(body: [?]): t => t

    // fair
  #show table.cell.where(body: [F]): t => text(fill: grn, strong(t))
  #show table.cell.where(body: [A]): t => text(fill: grn, strong(t))
  #show table.cell.where(body: [I]): t => text(fill: grn, strong(t))
  #show table.cell.where(body: [R]): t => text(fill: grn, strong(t))

  #show table.cell.where(body: [f]): t => text(fill: ylw, strong(t))
  #show table.cell.where(body: [a]): t => text(fill: ylw, strong(t))
  #show table.cell.where(body: [i]): t => text(fill: ylw , strong(t))
  #show table.cell.where(body: [r]): t => text(fill: ylw, strong(t))

  #show table.cell.where(body: [-]): t => text(fill: red, strong(t))

  #figure(
    table(fill: (x,y) => if x > 0 { none } else if y < 11 { bg-col-algo } else if y == 11 { bg-col-ml } else if y < 14 { bg-col-ai } else { gradient.linear(bg-col-algo, bg-col-algo, bg-col-algo,bg-col-ml, bg-col-ml, bg-col-ml, angle: 40deg) },
      columns: (1.65cm, auto, auto, 1fr, 1fr, 1fr, auto,auto,auto,auto,1.4fr,1.8fr),
      inset: 3pt,
      align: (center+horizon, left+horizon, left+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon,),
      table.header(
        [Met.], [Author],                                        [Diagrams types],         [Ac], [Co], [Tr], [F],[A],[I],[R], [ILO],[UTML],
      ),

      [Alg.], [#cite(<Bian2020>, form: "prose")],                [UML Class],    [H],  [H],  [H],  [-],[-],[i],[r],   [N],  [N],
      [Alg.], [#cite(<Hosseinibaghdadabadi2023>, form: "prose")],[UML Use Case], [H],  [H],  [H],  [-],[-],[i],[r],   [N],  [N],
      [Alg.], [#cite(<anas2021>, form: "prose")],                [UML Class],    [M],  [H],  [H],  [-],[-],[i],[r],  [N],  [N],
      [Alg.], [#cite(<Modi2021>, form: "prose")],                [UML Class],    [?],  [H],  [H],  [-],[-],[-],[-],  [N],  [N],
      [Alg.], [#cite(<Jebli2023>, form: "prose")],               [UML Class],    [?],  [H],  [H],  [-],[-],[-],[-],  [N],  [N],
      [Alg.], [#cite(<Ali2007>, form: "author") @Ali2007 @Ali2007b],[UML Class], [?],  [H],  [L],  [-],[-],[-],[-],  [N],  [N],
      [Alg.], [#cite(<AlRawashdeh2014>, form: "prose")],      [UML State/Sequence],[?],  [H],  [?],  [-],[-],[I],[-],  [N],  [N],
      [Alg.], [#cite(<Striewe2011>, form: "prose")],             [UML Class],    [?],  [H],  [H],  [-],[-],[I],[-],  [N],  [N],
      [Alg.], [#cite(<Foss2022>, form: "author") @Foss2022 @Foss2022a @Foss2022b],[ER],[?],[H],[?],[-],[-],[I],[r],  [N],  [N],
      [Alg.], [#cite(<thomas2009>, form: "author") @thomas2004 @thomas2006 @thomas2008 @thomas2009 @thomas2011],[ER],[H],[H],[H],[-],[-],[I],[r],[N],[N],

      [ML], [#cite(<Stikkolorum2019>, form: "prose")],         [UML Class],    [L],  [L],  [L],  [-],[-],[-],[-],   [N],  [N],
      [GenAI], [#cite(<Wang2025>, form: "prose")],                [UML],          [M],  [L],  [M],  [F],[a],[I],[r],   [N],  [N],
      [GenAI], [#cite(<Bouali2025>, form: "prose")],              [UML Class],    [M],  [L],  [M],  [F],[a],[I],[r],   [N],  [N],
      [Alg./ML], [#cite(<RajiRamachandran2025>, form: "prose")],    [ER],           [H],  [H],  [H],  [F],[a],[i],[r],   [N],  [N],
    ),
    caption: figure.caption(position: bottom, [
      Autograders and their suitability scores. \
      #align(left, [ 
        *Explanation of columns*: _What_ *Met*_hod is used_ (Alg(orithmic), ML, GenAI), which *Diagram types* _are supported_, _how high is the_ *Ac*(_curacy_), *Co*(_nsistency_), and _Grading_ *Tr*(_ansparency_), _how_ *F*_indable,_*A*_ccessible,_*I*_nteroperable, and_ *R*_eproduable is the tool_, _can the tool link_ *ILO*_s to grading_, _and how well is_ *UTML* _supported_? \
        #v(2pt)
        *Scoring* is generally divided into "N" (_No Support_), "L" (_Low_), "M" (_Medium_), "H" (_High_), and "?" (_Unknown_), which gives an indication of each autograder's suitability w.r.t. that particular criterium. The scoring for these rubrics is done in a comparative way, with the lowest-scoring solution receiving a "L" or "N" and the highest scoring receiving a "H". High *accuracy* is awarded for deterministic solutions, with lower values given to nondeterministic programs. High *consistency* is awarded for determinstic solutions. High *grading transparency* is awarded for solutions that explain the final grade in terms of rubrics (medium for full rubrics that might not match (i.e. GenAI solutions)). *ILO* and *UTML* support is given a "H" or "N" based on inclusion of these features. \
        *FAIR* scoring is done by verifying the Findability, Accessibility, Interoperability, and Reusability, inspired by #cite(<Wilkinson2016>, form: "prose", supplement: "Box 2, p.4"). We specifically look at the autogarder program. For example: if the code is findable with permalink, the project is available but only through a paywall, the algorithms in the paper are not designed to be interoperable with other diagram formats or types, and the work contains partial algorithms for autograding, it gets a score of '#text(fill: grn, [F])#text(fill: red, [a])#text(fill: red, [\_])#text(fill: dark-ylw, [r])'.
      ])
    ]),
  )<tbl:grader-suitability>
])


= Seshat <solution>
In order to automatically grade student submissions, we develop #seshat @seshat: a generic autograder theoretically capable of automatically analysing and grading any type of diagram, with out-of-the-box support for UTML.

== Techniques
#seshat uses the techniques from @relatedwork and @tbl:grader-suitability which gave the best results in terms of accuracy, consistency, and grading transparency: a graph isomorphism algorithm for structural matching, Levenshtein distance for syntatic matching, and `all-MiniLM-L6-v2` @all-minilm-l6-v2 for semantic matching.

We first tried out Princeton's WordNet @princeton-wordnet as semantic matching, as it also performs semantic similarity checks and was mentioned in multiple papers @Bian2019 @Hosseinibaghdadabadi2023, but these scores did not reflect the expected semantic similarity after testing with several self-synthesised examples and some example synonyms from the datasets#footnote([See `semantic_match_test.go` @seshat]). This is likely the case because WordNet strictly matches according to the hierarchy of singular words, meaning that examples in the dataset such as 'ChargingPort' v.s. 'ChargingStation' would not be matched since 'Port' is in a different WordNet category than 'Station', even though in the exercise they are semantically similar, while examples such as 'Team Member' and 'Virtual Machine' got a semantic match, while sharing no semantic similarity within any of the datasets. It may of course also be the case that our comparison algorithm, which splits the reference and submission text/sentence into words, sums all semantic similarities of each word combination, and divides it by the longest sentence, is not the correct way to approach this manner.

== Architecture and Language
#place(top+center, float: true, scope: "column", [
  #figure(caption: [Query architecture for #seshat.],
    image("pics/design/2026-02-10/seshat-design.svg", width: 98%)
  )<fig:arch>
])

The goal of #seshat is to take input (from either exam exports, a list of files, or via some other format), transform the input into an internal graph representation, run comparison algorithms on it defined in @subsec:relatedwork-autograder-algorithmic which produces a set of scores (a 'grade'), and format this grade in a certain way. The exact methodology, algorithms, and visualisations are likely to change, which is why we aim to maximally decouple these parts.

In order to achieve this, we implement a query-based architecture akin to that of the Rust compiler @rustc-book, shown in @fig:arch. This encourages decoupling each stage of the process, and additionally increases transparency internally in the grading process, as one can easily query intermediate solutions from the grading process. Testing components is also inherently made easier due to the split-up functionality.

This architecture also allows us to cache all stages of the grading process if they are split up into separate queries, which should allow for some improvements in grading speed. Note that this is only possible without altering the results of #seshat because it does not contain non-determinstic algorithms.

The autograder is entirely written in Go @golang. We opted for Go as it is a compiled, statically typed language, which has strict enough typing to enforce the architecture seen in @fig:arch, but still has a garbage collector, which speeds up development and eliminates memory leaks.

Additionally, #seshat includes a Command Line Interface (CLI) to showcase the query architecture, as well as provide the author with an easy way to grade the datasets.

== Features
This section describes the feature set of #seshat by walking the reader through the process of grading a dataset. Features are explained in the order of the grading process.

=== Parsing
The parsing step transforms a diagram file into an structure that #seshat can understand. For UTML, it merely parses the JSON UTML structure and adds some metadata such as the file name.

=== Transformation into \ internal representation
In order to be able to grade diagrams, #seshat uses an internal representation of a graph. This choice is made to separate the grading from any one specific diagram format, a mistake made in some other autograders (see @tbl:grader-suitability). Separating the grading from a diagram format has the benefit of being able to easily integrate new diagram formats into #seshat, just by writing a translation from a particular format into the internal representation.

To support as many diagram formats as possible, this internal graph definition is very loosely defined. It contains as little semantic concepts as possible (inheritance, multiplicities, etc.) as it aims to capture the literal shapes and text. This allows #seshat to store possibly broken submissions according to standards such as UML, which gives us the flexibility to check the well-formedness of a graph at a defined stage after parsing, or ignore certain 'broken' aspects of graphs, which helps in the perceived _leniency_ of the autograder and should bring it closer to human grading.

The structure is defined by some metadata such as the filename and a collection of vertices and edges. Each vertex and edge has a unique identifier. Vertices additionally contain a title, some values (fields or methods), certain optional semantic properties such as visibility (public/private/protected/...) and type (Class/Interface/...), and visual properties such as location and size. Edges are always directed and can connect at either end to a vertex, edge or nothing. Next to an identifier, they have stylistic properties for the starting and ending point of the edge, such as arrow style and text, as well as general stylistic properties, such as the style of the edge (dotted or solid). Finally, each edge has visual properties that define the edge's path. This path can be of any length, allowing for complex paths.

=== Error correction<subsec:err-corr>
After a diagram is converted into #seshat's internal representation, #seshat tries to correct specific kinds of mistakes made in the diagram creation process, depending on which options are enabled and how they are configured. This also allows for encoding semantic meaning into the diagram if the original diagram format does not allow for expressing certain semantics. 

For example, since UTML does not allow edge-to-edge connections, the 'reparation' phase can correct for this, given that edges are sufficiently visually close. These error-correcting and/or semantic encoding features exist to allow maximum leniency in grading and exist on the internal representation level, meaning they automatically apply to all diagram formats #seshat supports. 

For visualising error corrections, we refer to submission 154286, shown in @fig:submission-154286, as well as its corrected version, shown in @fig:submission-154286-corrected.


// figures for grading / error correction
#place(bottom+center, float: true, scope:"parent", [
  #figure(image("pics/grading/154286-annotated.png", width: 100%),
  caption: [
    A student submission #cite(<seshat>, supplement: [`2025_M2_BIT/q/1/154286.json`]) containing several inconsistencies (marked #text(fill: red, [ red ]) and #text(fill: darkyellow, [yellow])): \
    'Internal Information' has a disconnected edge. The edge between 'Project' and 'Deliverable' has internally swapped labels (see @lst:submission-154286-json-snippet). The edge of 'Record' is not connected to the 'attends ->' edge between 'Developer' and 'TrainingSession'. The inherited classes of 'Resources' are all separate edges, and most edges are not connected to the inheriting classes.
  ]
  )<fig:submission-154286>

  #figure(caption: [154286.json lines 96-111, showing internally flipped labels. From the graph of @fig:submission-154286.], [ ```JSON
...
"middleLabel": { // middleLabel denotes the center of the edge
  "offset": { //...but the offset places it at the location of 'endLabel'
    "x": 45,
    "y": -6
  },
  "edgeLocation": 1,
  "value": "0..1"
},
"endLabel": { // endLabel denotes the end of the edge
  "offset": { //...but the offset places it at the location of 'middleLabel'
    "x": -70,
    "y": -6
  },
  "edgeLocation": 2,
  "value": "has ->"
},
...
```])<lst:submission-154286-json-snippet>
])

#place(top+center, float: true, scope: "parent", [
  #figure(image("pics/grading/154286-DOTRENDER-combinedEdges-annotated.svg", width: 110%),
  caption: [A GraphViz view of the corrected internal representation of submission 154286. Note that due to the limitations of GraphViz we show edges as two edges with a fake node inbetween. Edge paths are correctly stored internally.]
  )<fig:submission-154286-corrected>
])



==== Edge Label Swapping
Firstly, #seshat supports edge label swapping. It can happen during the diagram creation process that a student creates labels on an edge, but then drags the labels to other locations. This can be seen with the edge 'Project' $arrow$ 'Deliverable', which has swapped labels 'has ->' and '0..1', in @fig:submission-154286 and @lst:submission-154286-json-snippet.

Having swapped labels is a problem for automatic grading, because #seshat does not consider the visual representation of the submission. When a student drags around labels and the diagram tooling does not automatically swap the labels internally, the file structure does not match the visual structure, which would make #seshat grade a diagram 'incorrectly' according to student and teacher expectations, putting students at an unfair disadvantage.

#seshat includes an option `swap_edge_labels` for this, which looks for labels with large offsets towards another position on the edge and swaps them if possible. The distance at which this occurs is configurable as a percentage of the length of an edge.

==== Edge 'Anchoring'
Some diagram software, such as UTML, sadly does not allow connecting edges to other edges, which is mandatory syntax for concepts such as UML association classes. Alternatively, students may drag arrows close to vertices or edges but not connect them directly for several possible reasons, including time limitations of exams.

This is a problem for autograders, since _technically_, those edges are not connected to anything, meaning that students will get points deducted for a solution that looks visually correct.

In order to allow some level of leniency which compensates for the inability of students to connect edges and/or the diagram software's inability to support it, #seshat allows for 'anchoring' disconnected edges that are sufficiently close to another vertex or edge with `connect_edge_ends`. The distance at which anchoring occurs can be configured as a percentage of the length of an edge. for vertices, this is the length of the top, left, right, or bottom part of the vertex (which is assumed to be a rectangle). A demonstration of this reparation can be seen in the connections 'Record' and 'Internal Information' in @fig:submission-154286-corrected.

==== Directed Edge Recombination
In diagrams, it is not uncommon to have a set of multiple vertices connect to one 'main' vertex. This happens especially often when drawing multiple inheritance classes in UML. However, diagram software might not make it easy to draw these in a visually pleasing manner, or students might choose to draw separate edges which capture the semantics visually, but which is not represented in the underlying diagram format. A good example of this is presented in @fig:submission-154286, where classes ranging from 'SoftwareLicense' until 'CloudService' connect to 'Resources'. However, these edges are drawn individually as straight edges, and any given edge does not connect an inheriting class to the inherited class.

This is a major problem for autograding, as the representation mismatch will cause autograders to grade the individual edges, instead of the semantic concept (for example, multiple-inheritance).

#seshat includes an option `simplify-directed-edges` for this, which looks for multiple edge-to-edge connections that end in a directed edge (an edge with some kind of arrow or diamond on one side). The effect of this recombination is demonstrated in @fig:submission-154286-corrected.
=== Grading process<sec:grading-process>
After the internal representation is repaired, it can be graded. This is done based on graph comparisons / isomorphism. It requires (1) a teacher solution, (2) a student solution, and (3) a grading rubric which instructs the autograder which error corrections to apply and how many points to give or subtract. It is also possible to define a set of ILOs in the grading rubric, and mention to which extent certain attributes such as vertex presence affect ILOs.

Given a teacher and student graph, #seshat first attempts to map the vertices and edges of the teacher graph (reference) to those drawn by the student (submission). #seshat grades with the following general graph comparison algorithm:

1. take the teacher's reference graph ($r$) and the student submission graph ($s$). Vertices in a graph $g$ are denoted by $V_g$. Edges in $g$ are denoted by $E_g$.
2. analyse the semantic and syntactic equivalence of all $(v_r,v_s), v_r in V_r, v_s in V_s$ and score it in a range of 0 (no similarity) to 1 (perfect similarity), i.e. $s c o r e(v_r,v_s) arrow [0..1]$.

3. for each $v_r in V_r$, take $m a x( s c o r e(v_r,v_s)) forall v_s in V_s$, given that the score is higher than the similarity threshold defined in the grading instructions. Put these pairs $v_r arrow v_s$ into a minimal subgraph pair ($g_v_r, g_v_s$)

4. repeat for each pair $g_v_r, g_v_s$ until no progress is made:
  1. get a list of $e_r in E_r$ that connect to $v_r in g_v_r$ ($E_g_v_r$), and a list of $e_s in E_s$ that connect to $v_s in g_v_s$ ($E_g_v_s$).
  2. $forall e_r in E_r$ get the starting and ending vertices of $e_r$ (if they exist), collect them into $V_g_v_r$. Do the same for $E_s$ ($V_g_v_s$).
    -  for each $v_r in V_g_v_r$, make a mapping of $m a x(s c o r e(v_r,v_s)) forall v_s in V_g_v_s$ and collect it into `newFixedIds`.
    - for each $e_r in E_g_v_r$, try to match the first edge in $E_g_v_s$ for which the starting/ending vertices are in `newFixedIds`. Collect these into `newFixedEdgeIds`.
  3. Add all $(v_r,v_s) in$ `newFixedIds` and add all $(e_r,e_s) in$ `newFixedEdgeIds`.

5. Once no further progress is made, score the subgraphs $(g_v_r, g_v_s)$ based on how many vertices and edges have been mapped: $s c o r e(g_v_r,g_v_s) arrow RR$.
6. Take the highest-scoring subgraph pair as basis.
  - For all other subgraphs pairs $g_v_r, g_v_s)$, sorted by score, add , given that the edges and vertices of other subgraph pairs do not appear in the final combined solution yet.

After the last step, we have one final mapping $(g_v_r, g_v_s)_"fin"$ which decides which vertices of the reference solution likely map to the student submission.

After arriving on a final mapping, we apply the user-supplied grading configuration: we hand out additions or deductions in points based on vertex or edge presence, absence, or incorrectness, and for specific parts of vertices or edges such as vertex attributes or edge arrow style.

This grading configuration also specifies the reparation options specified in @subsec:err-corr. This allows a teacher / grader to specify stricter or looser corrections for a particular dataset, if #seshat performs undesired repairs.

=== Visualisation<sec:visualise>
After calculating a grade, #seshat needs a way to show this to the user. Three built-in methods exist for exporting data: export only the final grades to a `.csv` file, export the final grade and a detailed reasoning for why this is the final grade to a `.json` file per submission, or export both a `.csv` file and `.json` files. An example of a `.json` grade export can be seen in @fig:ex-json-export.

#place(bottom+center, float: true, scope: "parent", [
  #figure(caption: [Snippets from the grading configuration for TCS 2025 q.6], [```json
 {
  "ilos": {...},
  "grader_config": {
    "semantic_certainty": 0.7,
    "repair_options": {
    	"swap_edge_labels": 	   { "enable": true, "distance_threshold_percent": 0.35 },
    	"connect_edge_ends": 	   { "enable": true, "edge-to-edge_closeness_percent": 0.5, "vertex-to-edge_closeness_percent": 0.75 },
    	"simplify_directed_edges": { "enable": false }
  }},
  "scores": {
    "vertex": { ... }, "vertex_title": { "present": 0, "absent/incorrect": 0,  "superfluous": 0 },
    "vertex_type": { ... }, "vertex_visibility": { ... }, "vertex_attribute": { ... }, "vertex_attribute_type": { ... }, "vertex_attribute_visibility": { ... },
    "edge": { "present": 1, "absent/incorrect": 0, "superfluous": 0 },
    "edge_type": { "present": 0.25, "absent/incorrect": -0.1, "superfluous": 0 },
    "edge_association_label": { "present": 0.1, "absent/incorrect": -0.25, "superfluous": 0 },
    "edge_middle_label": { "present": 0, "absent/incorrect": 0, "superfluous": 0 }
}} 
```])

  #figure(caption: [Snippets from the `.json` grade export of submission 1027326 from TCS 2025 q.6], [```json
{ "final_grade": 4.95, "reason": {
  "missing_reference_vertices": {},
  "vertex_grades": { ... },
  "missing_reference_edges": {},
  "edge_grades": { 
    "0": {
      "presence": { "grade": 1, ... "explanation": "present" },
      "line_style": { "grade": 0.25, ... "explanation": "equal to sample solution" },
      "vertex_start": { "grade": 0.1, ... "explanation": "equal to sample solution" },
      "vertex_end": { "grade": 0.1, ... "explanation": "equal to sample solution" }
    },
    "3": { 
      "presence": { "grade": 1, ... "explanation": "present" },
      ...
      "vertex_start": { "grade": 0.1, ... "explanation": "equal to sample solution" },
      "vertex_end": { "grade": 0.05, ... "explanation": "50% correct multiplicity: should have been '1'" }
    }, ...
  }},
  "vertex_mapping": { "0": 0, "1": 1, ... },
  "edge_mapping": { "0": 0, "1": 1, "2": 2, "3": 3, "4": 4 }
}
```])<fig:ex-json-export>

#figure(caption: [Demo graph (`.dot`) export of submission 1027326 from TCS 2025 q.6.],
  image("pics/grading/1027326_graded_graph.svg")
)<fig:ex-graph-export>

])


We also include a demo graph export of a grade in GraphViz format, which uses the same graph export functionality as seen in @fig:submission-154286-corrected to visualise a grade. It shows in red, yellow, and green which vertices / edges were incorrect, superfluous, or correct.

There also exists a GraphViz export function for #seshat's internal structure. This allows for easily viewing how different reparation options affect a solution. A JSON export of the graph is also possible, which outputs the exact internal representation of the graph. An example is given in @fig:submission-154286-corrected. Note that GraphViz neither supports fixed edge paths nor edge-to-edge connections, meaning that edge placement is incorrect. However, edge locations are preserved, and are shown correctly in the JSON export.

== Testing
When developing an autograder, it is vitally important to verify its correctness and expected behaviour. We implement a variety of automated tests to ensure this. Because #seshat includes a lot of parsing and graph corrections, not unlike compilers and Syntax Tree / Control Flow Graph analysis, we take inspiration from the terms used for compiler testing, as introduced in #cite(<Zaytsev2018>, form: "prose").

#seshat is tested in an automated fashion for all large features it possesses: for parsing, conversion into the internal graph structure, repairing the internal graph, and for grading.

For the initial stage of parsing UTML into our own in-memory data structure, we employ P-testing @Zaytsev2018. This means that we verify that, for each file in our test data the data sets, #seshat should produce the exact same JSON structure as is inputted. One noteable exception is UTML's `attributes` and `methods` fields. the UTML files sometimes either lack these fields, they are `null`, or they contain an an empty array (`[]`). Because this is semantically equivalent in our context, we explicitly treat `null`/`[]` or a missing `attributes`/`methods` field as the same.

For the conversion from UTML into the internal representation, we use a form of N-testing @Zaytsev2018: we parse a UTML file into `ParseResultUTML`, then convert it into our `InternalGraph`, and then perform checks comparing the parse result and internal representation. We validate whether the vertex and edge IDs remain the same, and whether edges are still connected to their respective vertices or edges, to name a few.

For special features such as connecting edge ends and swapping labels (see @subsec:err-corr) we perform unit testing with fixed examples, which test both a couple of happy paths (where the program should modify the graph) and control paths (where the program should not change the graph).

#todo[
== Using Seshat
This section will include the context of Seshat in the grading process: in what stage the tool is intended to be used, what settings need to be tweaked in which ways by teaching staff, how to interpret the results, what the general methodology is. For the process we largely copy over from @results. This will be done by the 13th of July 2026.
]


= Threats to valididty
The internal validity of this paper may be affected by a few factors. 

Firstly, selection bias in the researched papers and reporting bias in those papers may affect the perceived performance of certain types of autograders, which could negatively affect the choice of algorithms used for #seshat. As we aim to provide a _comprehensive_ overview, not an exhaustive one, selection bias becomes more important, especially when using snowballing, as one can easily focus disproportionately on a specific sub-strategy and lose the overall picture. This is also why we keep snowballing at a minimum.

Secondly, the manner in which humans have constructed the rubrics in the dataset is inherently biased towards human graders, which generally do not apply rubrics exactly to the letter @Ahmed2024 @Meadows2005. We also could not capture the live talk between teaching staff which, from experience, happens during the grading process and generally makes a rubric more nuanced and detailed. This limits our first attempt at autograding and likely results in significant discrepancies in grading, at least initially.

Thirdly, the datasets do not provide details about which humans graded which submissions, when those submissions were graded, which reasoning was behind each of the grades, along with a variety of other factors. Especially the reasoning behind a grade would have been useful to discern the different types of grading deductions, which would help with result quality. However, since we only get a final grade to work with, we have to guess why grades were constructed by humans and aim to achieve a similar leniency and error correction. This process is additionally prone to bias from the author.

#todo[
We will adjust this validity section to follow the work of #cite(<Larsen2025>, form: "prose"). Internal validity is part of 'causal' validity. We also provide reasoning for criterion validity and context (a.k.a. 'external') validity before the 13th of July 2026.
]

= Results<results>
For gathering results, we employed the following methodology: we read the rubric and, if present, the explanatory text of the exercise, and make a first sample solution. We also exactly construct a grader config with error reparation enabled and we award / subtract as many points as the grading rubric instructs to.

Then, we run #seshat on the dataset with our initial rubric, combine the human and autograding into one file, and graph the difference in grading in the paper. We aim to get a flat line, meaning that there is no difference in human or autograding. #todo[we also use the Shapiro-Wilk Royston analysis @Royston1982 for normality and, using that, determine whether which]

We inspect the outliers, sorting by biggest difference and sampling roughly every 20 submissions. We note our initial results in the paper, giving the initial average difference. We determine if the difference is up to human error or if #seshat is configured or programmed wrongly. If #seshat is incorrect, we revise the code or the grading rubric and grade the entire dataset again.

We repeat this procedure two to five times, after which we write down our final results. We save the raw scores, example rubrics, and the results in our code repository @seshat.

Each dataset contains one exercise. We start each section by giving the origin of the data, a quantitative summary mentioning the number of submissions and total the number of points the grading rubric contains. We mention qualitative data such as the goal of each exercise and how this affects the grading rubric. We then mention our process of aligning #seshat's grades to those produced by teaching staff and present our final statistical analysis.


#let ABS_DIFF(d: (), fr: 2) = calc.round(digits: fr, d.fold(0, (v, r) => v + calc.abs(r.at(1) - r.at(0))) / d.len())


#let diagram_comparison(title: [], ylabel: [$Delta$ score ], xlabel: [submission], data: (/*two-column array of points*/), maxscore: 1, lim: (-1.25,1.25), ..args) = {
  show lq.selector(lq.tick-label): set text(0.7em)
  show lq.selector(lq.legend): set text(0.8em)
  lq.diagram(
    width: 95%,
    height: 3cm,
    title: title, ylabel: ylabel, xlabel: xlabel,
    legend: (position: center + bottom),
    xaxis: ( ticks: none, //data.map(rotate.with(-90deg, reflow: true)).enumerate()
      subticks: none ),
    yaxis: ( lim: lim, ticks: ((-1,$100%$),(-0.5,$-50%$),(-0.25,$-25%$),(0,$0%$),(0.25,$25%$),(0.5,$50%$),(1,$100%$)), subticks: 5 ),
    ..args,
    lq.bar(
      range(data.len()), data.map(r => (r.at(1)-r.at(0)) / maxscore).sorted(),
      fill: blue,
      label: none, //[ human grade - #seshat grade ]
      width: 100%,
    ),

    lq.hlines(-1, 1, stroke: 0.25mm + purple, label: none),
    lq.hlines(ABS_DIFF(d: data) / maxscore, stroke: 0.25mm + orange, label: [ average absolute difference ])
  )
}


#let diagram_histogram(title: [], ylabel: [frequency], xlabel: [score], data, start: 0, end: 10, step: 0.5, ..args, y_range: (0,10)) = {
  lq.diagram(
    width: 100%, height: 2cm, title: title, ylabel: ylabel, xlabel: xlabel,
    legend: (position: center+bottom),
    yaxis: ( lim: y_range ),
    xaxis: ( lim: (start,end) ),
    ..args,
    lq.bar(
      /*x*/ range(start, int(calc.round(end/step))).map(r => r*step), 
      // /*y*/ (x) => data.filter(r => (calc.abs(calc.floor(r * (1/step)) * step - x) < step)).len(),
      /* y */ (x) => data.filter(r => { r >= x and r < x+step }).len(),
      fill: blue,
      width: 100%,
      stroke: none, // blue+0.5mm,
    )
  )
}

== BIT 2024<subsec:bit2024>
#let bit2024data = csv("data/2024_M2_BIT/GRADE_RESULTS/2024_M2_BIT_combined.csv").slice(1)
#let (bit2024c, bit2024human, bit2024seshat, bit2024d) = (
  bit2024data.map(r => r.at(0)),
  bit2024data.map(r => float(r.at(1))),
  bit2024data.map(r => float(r.at(2))),
  bit2024data.map(r => (float(r.at(1)), float(r.at(2)))))

#let bit2024humanmean = bit2024human.sum() / bit2024human.len()
#let bit2024humanvar = calc.root(estimate_variance(s: bit2024human), 2)
#let bit2024maxscore = 40

#let bit2024mannw = mann_whitney_utest(s: bit2024d)

#place(bottom+center, float: true, scope: "column", [
  #figure(caption: [Human grading of BIT 2024 dataset],
    diagram_histogram(title: [BIT 2024, q.1, Human], bit2024human, start: -2, end: bit2024maxscore, step: 0.5, y_range: (0,7))
      //lq.bar(range(0, 80).map(r => r/2), (x) => bit2024data.filter(r => calc.round(float(r.at(1)), digits: 1) == x).len())
  )<fig:bit2024human>

  #figure(caption: [Automated grading of BIT 2024 dataset],
    diagram_histogram(title: [BIT 2024, q.1, #seshat], bit2024seshat, start: -2, end: bit2024maxscore, step: 0.5, y_range: (0,7))
  )<fig:bit2024seshat>

  #figure(caption: [ Difference in grading between humans and #seshat per submission in the BIT 2024 dataset, normalised to the maximum number of points in the original rubric. Sorted by increasing difference. Positive scores mean that #seshat awarded more points. ],
    diagram_comparison(data: bit2024d, maxscore: 40, title: [BIT 2024, question 1], ylabel: [$Delta$ score ], xlabel: [submission])
  )<fig:bit2024>
])

This dataset is an export of the first question from an exam from the second module of Business Information Technology (BIT) at the UT, in 2024. It requires drawing a class diagram for an Electric Vehicle Charging Network, with 92 submissions in total. The rubric awards 40 points in total in the categories _classes_, _associations_, and _multiplicities_#todo[, and can be seen in @app:gr-rub-bit2024]. The exercise expects a simple UML class diagram, with the focus on the presence of certain classes and association types.

The grades are not normally distributed, as a Shapiro-Wilk Royston test on human grading gives $W = 0.9448, p = 0.000696$, using R's `shapiro.test()` function based on Royston's extension of Shapiro-Wilk which better suits sample sizes over $n=50$ @Royston1982 @Royston1995, which did not change significantly when removing outliers.

After implementing the rubric in code exactly, giving 1 point per present class and association, along with a point in total for correct edge multiplicities, the scores were quite negative compared to the human grading, with an average normalised score difference of #{calc.round(digits: 4, 10/40*100)}%. After inspecting a few of the most outrageous offenders with differences of 50-75% /*20-30 points*/, it turned out #seshat was not mapping edges correctly between the solution and submission. After resolving this, and giving _just over_ 1 point for each present vertex and edge (simulating human forgiveness), the equivalence improved slightly with an average normalised difference of #{calc.round(digits: 2, ABS_DIFF(d: bit2024d)/40*100)}%. This can be seen in @fig:bit2024.
#todo[
However, regrading this dataset twice or thrice will likely yield more closer alignment to human grading. This will be done before the 13th of July 2026.

We add statistical analysis including a mean-differences test before the 13th of July 2026.]

== TCS 2025<subsec:tcs2025>
=== Question 5<subsec:tcs2025q5>
#let tcs2025q5data = csv("data/2025_M2_TCS/GRADE_RESULTS/5/2025_M2_TCS_q5_combined.csv").slice(1)
#let (tcs2025q5c, tcs2025q5human, tcs2025q5seshat, tcs2025q5d) = (
  tcs2025q5data.map(r => r.at(0)), 
  tcs2025q5data.map(r => float(r.at(1))), 
  tcs2025q5data.map(r => float(r.at(2))), 
  tcs2025q5data.map(r => (float(r.at(1)), float(r.at(2)))))

#place(top+center, float: true, scope: "column", [
  #figure(caption: [Humand grading of TCS 2025 q.5],
    diagram_histogram(title: [ TCS 2025 q.5 - Human ], tcs2025q5human, start: -2, end: 4, step: 0.5, y_range: (0,70))
  )<fig:tcs2025q5human>

  #figure(caption: [Automated grading of TCS 2025 q.5],
    diagram_histogram(title: [ TCS 2025 q.5 - #seshat ], tcs2025q5seshat, start: -2, end: 4, step: 0.5, y_range: (0,70))
  )<fig:tcs2025q5seshat>

  #figure(caption: [Difference in human and automatic grading _per submission_ for the TCS 2025 dataset, question 5. Normalised to the maximum number of points in the rubric and sorted by increasing difference. Positive scores mean that #seshat awarded more points.],
    diagram_comparison(data: tcs2025q5d, maxscore: 4, title: [TCS 2025 q.5])
  )<fig:tcs2025q5>
])

This dataset comes from a module 2 exam from Technical Computer Science at the UT, from 2025. The dataset has 241 submissions, which differs one from @subsec:tcs2025q6 as one person did not hand in this exercise. The question requires making a UML class diagram that models a theme park. The sample rubric leans toward a holistic rubric, giving one point for _all_ correct classes (but not mentioning which exact classes), one point for correct methods / attributes, and a combined two points for correct associations and -types,for a combined 4 points in total.#todo[ It can be seen in @app:gr-rub:tcs2025q5.]

Like in @subsec:bit2024, this dataset is not normally distributed, receiving a Shapiro Wilk Royston score of $W = 0.82358, p = 6.543e-16$.

Here, the strategy we opted for was similar to the BIT 2024 dataset, giving only scores for present classes and associations and not deducting points for extra classes. Unlike @subsec:bit2024, the scores awarded by #seshat were enormous at first, regularly reaching over 10 points higher than the TA grading, while the maximum score for the exercise was 5. After adjusting the grading of classes and associations to only award a point in _total_, and not _per element_, the grading looked slightly more reasonable, at an average grade difference of #ABS_DIFF(d: tcs2025q5d) out of 4 points. 

#todo[
However, regrading this dataset twice or thrice will likely yield more closer alignment to human grading. This will be done before the 13th of July 2026.

We add statistical analysis including a mean-differences test before the 13th of July 2026.
]

=== Question 6<subsec:tcs2025q6>
#let tcs2025q6data = csv("data/2025_M2_TCS/GRADE_RESULTS/6/2025_M2_TCS_q6_combined.csv").slice(1)
#let (tcs2025q6c, tcs2025q6human, tcs2025q6seshat, tcs2025q6d) = (
  tcs2025q6data.map(r => r.at(0)),
  tcs2025q6data.map(r => float(r.at(1))),
  tcs2025q6data.map(r => float(r.at(2))),
  tcs2025q6data.map(r => (float(r.at(1)), float(r.at(2))))
)

#place(top+center, float:true, scope: "column", [
  #figure(caption: [ Human grading for TCS 2025 q.6 ],
    diagram_histogram(title: [ TCS 2025 q.6 - Human ], tcs2025q6human, start: -2, end: 5, step: 0.25, y_range: (1,100))
  )<fig:tcs2025q6human>

  #figure(caption: [ Automated grading of TCS 2025 q.6 ],
    diagram_histogram(title: [ TCS 2025 q.6 - #seshat ], tcs2025q6seshat, start: -2, end: 5, step: 0.25, y_range: (0,100))
  )<fig:tcs2025q6seshat>

  #figure(caption: [Difference in human and automatic grading for the TCS 2025 dataset, question 6. Normalised to the maximum points in the rubric and sorted by increasing difference. Positive scores mean that #seshat awarded more points.],
    diagram_comparison(data: tcs2025q6d, maxscore: 5, title: [TCS 2025 q.6])
  )<fig:tcs2025q6>
])

Question 6 comes from the same exam as @subsec:tcs2025q5, with 242 submissions in total. The question is all about associations: it asks to draw the correct (types of) associations with the correct multiplicities between predetermined classes. As a consequence, the original grading rubric only awards points for correct associations and association types.#todo[ It can be viewed in @app:gr-rub:tcs2025q6.]

#hl("normality of dataset!")

Initially, we copied over the grading rubric to #seshat. However#todo[, initially], it gave quite optimistic scores, on average giving out scores that were #{calc.round(digits: 4, 2.43 / 5 * 100)}% /*ABS_DIFF(d: tcs2025q6d)*/ higher, which can be seen in @fig:tcs2025q6. #todo[ To compensate, I will be regrading this dataset twice or thrice to more closely align #seshat to human grading. This will be done before the 13th of July 2026.

We add statistical analysis including a mean-differences test before the 13th of July 2026.]

== BIT 2025<subsec:bit2025>
#let bit2025data = csv("data/2025_M2_BIT/GRADE_RESULTS/2025_M2_BIT_combined.csv").slice(1)
#let (bit2025dc, bit2025d) = (bit2025data.map(r => r.at(0)), bit2025data.map(r => (float(r.at(1)), float(r.at(2)))))


#place(bottom+center, float:true, scope: "column", [
  #figure(caption: [Difference in human and automatic grading for the BIT 2025 dataset, question 1. Normalised to the maximum points in the rubric and sorted by increasing difference.],
    diagram_comparison(data: bit2024d, maxscore: 40, title: [BIT 2025 q.1])
  )<fig:bit2025>
])

The BIT 2025 dataset asks students to make a relatively complicated UML class diagram that appears to model the relationships in software development teams. The rubric hands out individual points for present classes and for asscociations, as well as some points for specific multiplicities.#todo[ It can be viewed in @app:gr-rub:bit2025.]

The strategy to emulate this grading the best was to give points for present classes and associations that are mentioned in the rubric, as well as giving small fractions of points for correct multiplicities. After revising the grading a time or two, we arrived at an average difference of #{calc.round(digits: 2, ABS_DIFF(d: bit2025d, fr: 10) / 40 * 100)}% of the maximum number of points. The grade differences can be seen in @fig:bit2025.

#todo[
I will be regrading this dataset twice or thrice to more closely align #seshat to human grading. This will be done before the 13th of July 2026. /* TODO */

We add statistical analysis including a mean-differences test before the 13th of July 2026.
]

= Discussion<discussion>
As seen in @results, #seshat can emulate human grading pretty effectively, with most differences likely stemming from human errors#todo[, but this will be definititively answered before 13th of July 2026 /* TODO */]. However, it remains important to manually check a few solutions, especially the ones that receive a lower grade. From our investigations, #seshat can very effectively detect correct solutions, but it is often harsh when grading slightly different solutions compared to human grading.

While trying to emulate human grading, it took a few rounds of revision to the example solution and the scoring system to get an approximately similar result. After fixing some bugs and improving autograder performance, the difference mainly seems to stem from human grading not very strictly following the rubric.

The differences are also likely caused from the different paradigm of grading with a sample solution. Wit h a sample solution, instead of having a teacher make a rubric for a particular exercise and having graders interpret the rubric, inherently leaving room for error, it forces teachers to think about concrete possible solutions. With sample solutions, the possible solutions *are* the rubric. This works quite well for exercises with defined solutions (for example TCS 2025 q.6 mentioned in @subsec:tcs2025q6), but for less clear exercises, the number of possible solutions expands rapidly. This makes more ambiguous exercises inherently worse for autograding when using example solutions.

== Future work
#todo[
/* Firstly, Due to time constraints we did not end up fully integrating ILO linking into the grading process. While it offers a concrete summary for students into which how well they achieved certain learning objectives, there is not a lot of use for it in the pure grading work. Future work could look at the effectiveness of giving students grading results with ILO scores to see how this helps students understand their test results.*/ /* TODO */ This paragraph included aparagraph on ILO linking not being implemetned. We will revise the paper to include ILO linking in the solution and/or to not disregard other tools because they do not link ILOs.

]
Functionality could be added to compare multiple solutions. Since authors such as #cite(<Hosseinibaghdadabadi2023>, form: "prose") report a higher score when grading with multiple sample solutions and preferring the maximum grade, it would be interesting to see if we can come even closer to human grading by including more sample solutions.

Additionally, #seshat is currently not user-friendly and unfit for use by teaching staff that are not intimately familiar with the terminal. Luckily, given its architecture, it is trivial to build wrappers around it, including graphical interfaces. It would be an interesting idea to see if #seshat can, with some user experience improvements, be adopted into a real-life grading workflow, possibly using the suggested workflow used in @results.

As previously mentioned in @discussion, #seshat does not directly work with the traditional grading rubrics of teaching staff. It might be interesting to see whether adopting #seshat's grading process for using grading rubrics could help it resemble human grading more or whether it makes a change in how effectively teaching staff can construct grading configurations.

Lastly, we compared grading purely to humans in this paper. It would be quite interesting to see how #seshat compares to other autograders mentioned in @tbl:grader-suitability, to see where #seshat excels or falls short.
#todo[ Compare to LLM grading from #cite(<Bouali2025>, form: "prose") ]


= Conclusion<conclusion>
In this research, we investigate to what extent we can automate the process of grading UML diagrams while maintaining or improving the _accuracy_, _consistency_, and _grading transparency_ of human grading. To achieve this, we consult existing work for possible solutions (*RQ1*), but find no implementations that share the full program (source code or other types of instructions) _and_ that offer high accuracy, consistency, grading transparency, and support UTML or can be extended to support it.

Hence, we successfully build our own autograder: #seshat (*RQ2*). #seshat uses the best performing algorithms from existing work: a custom structural graph matching algorithm based on the work of #cite(<thomas2009>, form: "prose") to map parts of a sample solution to a given student submission, semantic matching using the sentence transformer `all-MiniLM-L6-v2` to account for synonyms, and syntactic matching using Levenshtein distance to account for spelling mistakes.

While building and testing #seshat, we discover that UTML fundamentally cannot express certain UML concepts and that student submissions often appear visually correct but have an incorrect internal structure. We implement, explain, and showcase a few _reparation_ methods to still be able to grade 'imprecise' solutions.

Finally, we compare #seshat's grading against human grades (*RQ3*). We discover that our initial results are not great, but that we can likely improve the grading rubrics to match human grading more. #todo[We write the final conclusions before the 13th of July 2026. /* TODO */]

To answer our main research question (*MRQ*): we can almost entirely automate the process of grading diagrams, at least for questions that have a clearly defined (set of) sample solution(s). The only thing a human needs to do in order to use #seshat is to provide a grading rubric specifying how many points to award/deduct for certain attributes of a diagram and to provide a (set of) sample solution(s). However, to ensure the grading aligns with the expectations of a teacher, the results need to be randomly sampled and verified, and the grading rubric / sample solution revised. According to our experience with #seshat, if the goal is similar grading to teaching staff, this revision typically requires two to three cycles.

The automation of human grades can also be done while theoretically *maintaining* accuracy and arguably *improving* consistency, and transparency, compared to human grading. While practically we initially did not get close enough to the , you can theoretically construct a grading rubric and a set of alternative sample solutions to perfectly mimic the rubric, thereby acing accuracy. Additionally, since #seshat uses determinstic algorithms for comparing a sample solution to a student submission, it is guaranteed that the same submission receives the same grade, hence resulting in perfect consistency. Finally, transparency is also hard to beat, since the detailed grading rubric states exactly which points were awarded or deducted, for what reason, and optionally for which ILO it counts.

#seshat offers a new grading paradigm for grading diagrams: the process no longer has to be done by multiple paid members of staff, but can instead be done much more quickly by one teacher. The challenge now becomes how to design unambiguous exercises in order to guide students towards one 'correct' solution, in order to both reduce the number of alternative solutions and thus the effort required by a teacher, as well as the time it takes to grade for #seshat.

// - #seshat offers a new way of viewing diagram grading: example solutions become the rubric, and the focus shifts to developing clearer exercises to minimise the number of possible solutions. Clear exercises are more easily automatable because they require less alternative graphs. This is a benefit to both students and teachers: teachers get a positive nudge towards developing exercises that are clearer for students and get rewarded with more accurate autograding and students get clearer exercises. (there is something to be said about disambiguating statements in communication, that is a nice skill, but it is not inherently related to diagram creation. I think it is good to separate the two, because the exercises are not labeled 'make diagram and communicate with stakeholders')

]) // 2-column

#pagebreak()
#bibliography("refs.bib")

#todo[
#heading(numbering: none, [ Appendices ])
#show: appendix

= Grading rubrics
== BIT 2024, question 1<app:gr-rub-bit2024>
/* TODO */
This will be filled by the 13th of July, 2026.

== TCS 2025, question 5<app:gr-rub:tcs2025q5>
/* TODO */
This will be filled by the 13th of July, 2026.

== TCS 2025, question 6<app:gr-rub:tcs2025q6>
/* TODO */
This will be filled by the 13th of July, 2026.

== BIT 2025, question 1<app:gr-rub:bit2025>
/* TODO */
This will be filled by the 13th of July, 2026.
]
