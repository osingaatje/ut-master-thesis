#import "typst-template-ut/typst-template-paper.typ" : conf, abstr, appendix

#let darkyellow = color.rgb("#B3A638")

// shortcuts / other helper functions
#let hl = highlight
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
)
#set page("a4", margin: DOC-MARGIN)

#set text(hyphenate: true)

#columns(2, gutter: 10pt, [


#abstr([
    During computer science studies, students are often required to submit diagrams. The grading of these diagrams is currently done by humans, resulting in a costly, lengthy, and error-prone process. In this paper, we investigate the theoretical feasibility of automatically grading diagrams, focusing on Unified Modelling Language diagrams and the UTML software and file format used by the University of Twente. Existing work shows that graph isomorphism algorithms which incorporate algorithms to account for the use of synonyms and the presence of spelling mistakes provide the best grading results. However, autograders utilising these techniques are not reproducible or open-source. Therefore, we propose #seshat, an open-source autograder that combines the aforementioned techniques and is capable of supporting arbitrary diagrams and file formats, with built-in support for UTML. #hl([comparison to human grading here])
])

= Motivation
Unified Modelling Language (UML) diagrams, introduced by the Object Management Group @omg-group, play a significant role in computer science, as they allow for communicating software designs in a standardised format. During technical studies, students are often required to make such diagrams for graded assignments or exams.

However, the grading of these diagrams is often a costly and lengthy process, involving multiple paid staff members @Ahmed2024#footnote("From personal experience.")<footnote:pers-exp>. Additionally, this process is prone to grading inconsistencies due to various reasons @Ahmed2024, with a major factor being the inherent inconsistency of human graders @Ahmed2024 @Meadows2005. #cite(<Meadows2005>, form: "prose") pose two possible solutions to the problem of human grading: either "report the level of reliability associated with marks/grades, or find alternatives to [grading]." We propose a third alternative: finding alternatives to the grading _process_.

The (partial) automatisation of grading diagrams ('autograding')  a grading paradigm that can both reduce the cost and time required for institutions and reduce the inherently present inconsistencies in human grading#footnote("Given that the process is deterministic.")<footnote:determinism> @osinga2024 @Bian2020. This could result in similar or superior performance compared to human grading in terms of *accuracy*, *grading transparency*, and *consistency*.

With _accuracy_, we mean the percentage of points assigned to a submission that are prescribed by the rubric for a particular excercise. With _consistency_, we mean both the extent to which similar grades are given to similar submissions and the difference between consecutive runs (i.e. determinism). With _grading transparency_, we mean the extent to which the reasoning for a particular grade is explained with regards to the rubric for the exercise or to the Intended Learning Objectives (ILOs) of a module. These properties are desirable in the grading process, as it means that students are graded in a way that reflects their performance (_accuracy_), allows them to see which parts they could improve for future assignments (_grading transparency_), and is minimally unfair (_consistency_).

Specifically for the implementation, we desire an autograder that can _link its grading to ILOs_, as described by the previous paragraph. Furthermore, built-in _UTML support_ is a must, as it is the main file format the University of Twente uses. Finally, an _easily extensible_ autograder would be ideal, since we might want to extend support to other file formats or alter the behaviour of the autograder later on.

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

*RQ1* is answered in @relatedwork, by analysing existing work for suitability of grading. These works are categorised according to the requirements outlined by *RQ1* and presented in @tbl:grader-suitability. @solution explains the features and reasoning behind #seshat. @results offers perspectives into its performance compared to human grading, after which we discuss and conclude in #hl([SECTION TODO]).

= Related work <relatedwork>
In order to answer research questions *RQ1*, we conduct a small-scale literature study covering roughly 40 works.  It aims to provide an exploratory view into the world of autograders and ILOs, which is why we omit formal inclusion and exclusion criteria. Works are collected using the search engines Google Scholar#footnote(link("https://scholar.google.com")) and ResearchGate#footnote(link("https://www.researchgate.net")), with related work for autograders being searched with terms including but not limited to "automatically grading UML diagrams", "autograder diagram", "UML diagram assessment", "machine learning diagrams", and "diagram evaluation assessment AI". For papers on ILOs and ILO integration into rubrics, terms were used such as "learning outcomes include in rubric", "learning objectives in rubrics", and similar. Snowballing (the practice of looking at sources of sources) was used to a depth of 1.

== Autograders
Multiple types of papers on autogrades are researched, which we categorise into frameworks for autograders, purely algorithmic autograders, and AI-driven autograders (using Machine Learning (ML) / Generative AI (Gen AI) techniques). Findings on autograder implementations are summarised in @tbl:grader-suitability.

=== Frameworks / Theoretical<subsec:relatedwork-autograder-frameworks>
Autograder frameworks dictate certain designs or methodologies for building autograders. We present summaries of the explored frameworks and provide a general summary of all frameworks.

#cite(<smith2004>, form: "prose") provide a five-step framework for assessing "possibly ill-formed or inaccurate diagrams" that include the steps (1) segmentation, (2) assimilation, (3) identification, (4) aggregation, and (5) interpretation. While the first two steps are meant for translating images or other "raster-based input" into diagrammatic primitives, which is not useful for us, the latter stages provide a solid conceptual foundation to grade diagrams.

#cite(<batmaz2010>, form: "prose") takes a broader look at the process of grading, identifying and developing techniques to reduce repetitive actions, focusing on database ER diagrams. The paper suggests a semi-automatic grading system, including automatic grading based on identifying identical segments between a submission and the solution. Assuming multiple submission revisions are available, it suggests to "not only [use] the reference text but also the intermediate diagrams" for identifying semantic matches #cite(<batmaz2010>, supplement: "p.40"). While multiple solutions are not useful for the purpose of grading only a single submitted diagram after an exam, this might be useful for live feedback.

#cite(<Vachharajani2014>, form: "prose") propose a UML use case assessment architecture, providing a useful catalogue about edge cases related to use case diagram assessment which are also applicable to other types of diagrams, such as the chance of misspellings, synonyms, abbreviations, directionality of relationships, and more.

#cite(<Bian2019>, form: "prose") establish a model to map submissions to example solutions and one to grade submissions. It recommends syntactic matching to help with spelling mistakes, semantic matching to match related words, and structural matching to match neighbouring elements and/or inheritance, with the goal to optimally match parts of a student submission with a sample solution. 

In conclusion, most autograder strategies recommend structural matching (to identify similar segments of graphs), often in combination with syntactic matching that accounts for misspellings and semantic matching to account for synonyms or related words. Unfortunately, the strategies do not account for integrating ILOs into the grading process explicitly.

=== Algorithmic <subsec:relatedwork-autograder-algorithmic>
Next to frameworks for autograders, implementations were also discovered during the literature review, of which a subset used purely algorithmic methods. Summaries of these sources are discussed in this section, along with a general summary on algorithmic autograders.

#cite(<Bian2020>, form: "prose") implements their previous framework @Bian2019 and validates it with a case study, using the Levenshtein distance between words for syntactic matching, several metrics for semantic matching, and structural matching based on similar attributes and operations within classes. They find that multiple teacher solutions result in more accurate grades with an average accuracy over 95% #cite(<Bian2020>, supplement: "p.10"). Additionally, they find that grading configurations need to change per exam if the goal is to produce the most similar scores to manual grading, likely because the focus of each exam or exercise is on a different aspect of diagram creation (associations, inheritance, etc.). Lastly, they state that autograding "has shown to be more consistent and able to ensure fairness in the grading process" compared to manual grading #cite(<Bian2020>, supplement: "p.11"). Additionally, their visual feedback system seems to provide a clear visualisation of the grading results, which might feel more intuitive for students. An example is shown in @fig:Bian2020_Fig9.

#cite(<Hosseinibaghdadabadi2023>, form: "prose") also implements the framework by #cite(<Bian2019>, form: "prose"), comparing UML use case diagrams to one or multiple example solutions and preferring the maximum grade. It uses a graph similarity algorithm which matches nodes based on structural matching, along with syntactic matching using the Levenshtein distance between words and semantic matching using WordNet similarity score (HSO, WUP, LIN metrics). It achieves a similarity percentage of 93.31% #cite(<Hosseinibaghdadabadi2023>, supplement: "p.114").

#place(top+left, dy: .5em, float: true, [
  #figure(image("pics/Bian2020_Fig9.png", width: 96%),
  caption: [Visual feedback module from #cite(<Bian2020>, form: "prose", supplement: "Fig.9")]
  )<fig:Bian2020_Fig9>
])


#cite(<anas2021>, form: "prose") compares UML class diagram submissions to an example solution. It uses graph similarity scores based on structural matching along with syntactic and semantic matching. Syntactic matching is done with substring matching and semantic matching is done with neighbour similarity ("the comparison of the neighboring classes" #cite(<anas2021>, supplement: "p.1585")), relationship name, type, multiplicity, and inheritance. It achieves a respectable correlation with human grading, with more than 80% identical grades, more than 90% achieving a corelation larger than 0.85, and no grading achieving a correlation lower than 70%.

Multiple papers mention the use of XMI @Modi2021 @Jebli2023, the object notation standard by OMG @xmi-omg, or Rose Petal files @Ali2007 @Ali2007b, the standard of IBM Rational Rose @ibm-rational-rose, but fail to mention specifics about matching algorithms or results.

#cite(<AlRawashdeh2014>, form: "prose") provides an interesting alternative way of grading submissions: by means of combining many UML diagram validators, model checkers, and even LTL properties given by instructors. However, a clear purpose, scope, and results are missing from the paper.

#cite(<Striewe2011>, form: "prose") also attemps property checking akin to #cite(<AlRawashdeh2014>, form: "prose")'s work by focusing on graph queries for evaluation, providing a domain-specific language that looks similar to SQL. While it offers an interesting alternative approach, the fact that teachers would have to learn a query language and transform their existing rubrics/example solutions into this format could be a real hurdle, especially given the performance of graph-isomorphism-based solutions @Bian2020 @Hosseinibaghdadabadi2023 @anas2021. Additionally, the paper does not account for misspellings or the use of synonyms.

#cite(<Foss2022>, form: "author") provide multiple papers on AutoER, a database diagram generator and evaluator that provides direct interaction with a description text @Foss2022 @Foss2022a @Foss2022b. It is more geared towards interactive use, intended for providing intermediate results and hints during the diagram creation process, before handing in the final submission. Unfortunately, concrete comparisons to manual grading and its source code could not be found.

#cite(<thomas2004>, form: "author"), like #cite(<Foss2022>, form: "author"), also provides a selection of papers on the automatic grading of ER diagrams @thomas2004 @thomas2006 @thomas2008 @thomas2009 @thomas2011. Unlike #cite(<Foss2022>, form: "author"), these papers are focused on a _single_ assessment point and provide a grading strategy that accounts in its basis for imprecise diagrams (diagrams containing misspellings, duplicate entities, etc.). They base their analysis on comparing ever increasing subsets of the graph ((Minimal) Meaningful Units) based on the work of #cite(<smith2004>, form: "prose"). By #cite(<thomas2009>, form: "year"), #cite(<thomas2009>, form: "author") manage to achieve a correlation to human grading of 92%, along with statistically proving that the autograder grades more consistently than human grading. The grading results can be viewed in @fig:thomas2009-results.

In #cite(<thomas2011>, form: "year") #cite(<thomas2011>, form: "author") provide an online platform for both students and teachers to ease the process of automatic grading further, also used by #cite(<smith2013>, form: "prose"), which further mathematically specifies #cite(<thomas2011>, form: "author")'s work. Unfortunately, we were not able to locate the source code of this grader.

#figure(
  box(inset: (left: -10pt), image("pics/thomas2009_Fig3.png", width: 95%)),
    caption: [#cite(<thomas2009>, form: "prose", supplement: "Fig. 3"): Human vs. automatic grading in database ER diagrams.],
)<fig:thomas2009-results>

In conclusion, most existing implementations of autograders use some graph isomorphism algorithm with a combination of structural, semantic, and syntactic matching, as suggested by most frameworks. Some solutions attempt to autograde using property or formula checking, but fail to mention a detailed enough methodology or results to warrant further investigation. No autograders provide methods on integrating ILOs into the grading process.

// Note to self: replicating Bian 2020 with Smith 2004 steps with advice from Thomas2004-2011 would be a good bet.

=== ML- / Gen AI-driven <subsec:relatedwork-autograder-AI>
Next to using purely algorithmic methods, some papers experiment with Machine Learning / Generative AI (collectively: 'AI-driven solutions') to automatically grade submissions, and even mention some hybrid AI-driven / algorithmic solutions. We provide summaries of the explored sources below, along with a general conclusion on AI-driven autograders.

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

#cite(<RajiRamachandran2025>, form: "prose"), unlike the previous papers, use a human-in-the-loop design in combination with both purely algorithmic steps, using LLMs only for semantic and syntactic matching. Using structural matching algorithms similar to papers presented in @subsec:relatedwork-autograder-algorithmic, it achieves a Mean Average Error of only 0.611, aligning very closely to human grading (see @fig:RajiRamachandran2025_Fig3). Unfortunately, the data set contains only ten self-procured images, which negatively impacts the significance of these results, not to mention that the nondeterminism introduced by the LLMs will impact the consistency of grading, although it is unclear to what extent.


In conclusion, while AI-based grading has been attempted in recent years, purely AI-driven solutions produce lacking similarity to human grading compared to graph isomorphism-based solutions as well as introducing non-deterministic and biased behaviour, while providing no consistency guarantees. This makes these types of solutions inferior to graph isomorphism solutions in terms of _accuracy_, _consistency_, and _grading transparency_. When used only for semantic and/or syntactic matching, it can provide similar accuracy to algorithmic solutions, although it still introduces nondetermism in grading which negatively affects _consistency_.

// line break for readability
== Intended Learning Objectives \ and examination
#cite(<dinur2009>, form: "prose") states that analytical rubrics (those which mention explicit criteria) provide more details than global, holistic rubrics. These types of rubrics (and their exercises) can be constructed directly from the ILOs of a course or module, which would provide a detailed grading rubric that aligns closely to its ILOs @osinga2024. Given that rubrics and exercises are defined in such a way, one could link these ILOs to the grading rubric and provide functionality for an autograder to show these in the final grade This would indicate to students how well they achieved the learning goals of the module in order to improve _grading transparency_.


== Conclusion
In the explored related work, existing frameworks primarily recommend structural matching in combination with syntactic and semantic matching to account for spelling mistakes and the use of synonyms. Existing implementations mostly use the methods recommended by the frameworks, with the best results stemming from determinstic graph isomorphism algorithms. Purely AI-driven methods may require less effort from teachers, since teachers do not need to produce sample diagrams but can describe their rubric in words, but produce noticeably inferior results to graph matching algorithms. Using hybrid methods, specifically using AI-driven classification algorithms only for semantic/syntactic matching, seems to produce similar results to 'pure' graph matching algorithms, but does not necessarily provide accuracy gains over algorithmic solutions and can additionally introduce nondeterminism in otherwise determinstic solutions, reducing consistency.


#place(top+center, scope: "parent", float: true, [
  #let grn = rgb("#12CC12")
  #let ylw = rgb("#EA7C32")
  #let red = rgb("#CC1111")
  #let dark-ylw = rgb("#DD4545")

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
    table(columns: (auto, auto, 1fr, 1fr, 1fr, auto,auto,auto,auto,1.4fr,1.8fr),
      inset: 3pt,
      align: (left+horizon, left+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon,),
      table.header(
        [Author],                                        [Di],         [Ac], [Co], [Tr], [F],[A],[I],[R], [ILO],[UTML],
      ),

      [#cite(<Bian2020>, form: "prose")],                [UML Class],    [H],  [H],  [H],  [-],[-],[i],[r],   [N],  [N],
      [#cite(<Hosseinibaghdadabadi2023>, form: "prose")],[UML Use Case], [H],  [H],  [H],  [-],[-],[i],[r],   [N],  [N],
      [#cite(<anas2021>, form: "prose")],                [UML Class],    [M],  [H],  [H],  [-],[-],[i],[r],  [N],  [N],
      [#cite(<Modi2021>, form: "prose")],                [UML Class],    [?],  [H],  [H],  [-],[-],[-],[-],  [N],  [N],
      [#cite(<Jebli2023>, form: "prose")],               [UML Class],    [?],  [H],  [H],  [-],[-],[-],[-],  [N],  [N],
      [#cite(<Ali2007>, form: "author") @Ali2007 @Ali2007b],[UML Class], [?],  [H],  [L],  [-],[-],[-],[-],  [N],  [N],
      [#cite(<AlRawashdeh2014>, form: "prose")],      [UML State/Sequence],[?],  [H],  [?],  [-],[-],[I],[-],  [N],  [N],
      [#cite(<Striewe2011>, form: "prose")],             [UML Class],    [?],  [H],  [H],  [-],[-],[I],[-],  [N],  [N],
      [#cite(<Foss2022>, form: "author") @Foss2022 @Foss2022a @Foss2022b],[ER],[?],[H],[?],[-],[-],[I],[r],  [N],  [N],
      [#cite(<thomas2009>, form: "author") @thomas2004 @thomas2006 @thomas2008 @thomas2009 @thomas2011],[ER],[H],[H],[H],[-],[-],[I],[r],[N],[N],

      [#cite(<Stikkolorum2019>, form: "prose")],         [UML Class],    [L],  [L],  [L],  [-],[-],[-],[-],   [N],  [N],
      [#cite(<Wang2025>, form: "prose")],                [UML],          [M],  [L],  [M],  [F],[a],[I],[r],   [N],  [N],
      [#cite(<Bouali2025>, form: "prose")],              [UML Class],    [M],  [M],  [M],  [F],[a],[I],[r],   [N],  [N],
      [#cite(<RajiRamachandran2025>, form: "prose")],    [ER],           [H],  [M],  [H],  [F],[a],[i],[r],   [N],  [N],
    ),
    caption: figure.caption(position: bottom, [
      Autograders and their suitability scores. \
      #align(left, [ 
        \*_What_ *Di*_agram types are supported_, _how high is the_ *Ac*(_curacy_), *Co*(_nsistency_), and _Grading_ *Tr*(_ansparency_), _how_ *F*_indable,_*A*_ccessible,_*I*_nteroperable, and_ *R*_eproduable is the tool_, _can the tool link_ *ILO*_s to grading_, _and how well is_ *UTML* _supported_? \
        #v(2pt)
        Scoring (except FAIR) is divided into "N" (_No Support_), "L" (_Low_), "M" (_Medium_), "H" (_High_), and "?" (_Unknown_), which gives an indication of each autograder's suitability w.r.t. that particular criterium. The scoring for these rubrics is done in a comparative way, with the lowest-scoring solution receiving a "L" or "N" and the highest scoring receiving a "H". High *accuracy* is awarded for deterministic solutions, with lower values given to nondeterministic programs. High *consistency* is awarded for determinstic solutions. High *grading transparency* is awarded for solutions that explain the final grade in terms of rubrics (medium for full rubrics that might not match (i.e. AI-driven solutions)). *ILO* and *UTML* support is given a "H" or "N" based on inclusion of these features. *FAIR* scoring is done by checking the Findability, Accessibility, Interoperability, and Reusability, inspired by #cite(<Wilkinson2016>, form: "prose", supplement: "Box 2, p.4"). We focus purely on the autograder solutions for this rubric. For example, if the code is findable with a fixed ID or link, the project is available but only through a paywall, the algorithms in the paper are designed to be interoperable with only one diagram format (for example XMI) and only one type of diagram (for example ER diagrams), and the work is partially reproducible (deriving parts of the source code using algorithms in the paper), it gets a score of '#text(fill: grn, [F])#text(fill: red, [a])#text(fill: red, [\_])#text(fill: dark-ylw, [r])'.
      ])
    ]),
  )<tbl:grader-suitability>
])


= Seshat <solution>
In order to automatically grade student submissions, we develop #seshat @seshat: a generic autograder capable of automatically analysing and grading theoretically any type of diagram. For the purposes of this paper, we offer built-in support for UTML.

#seshat uses the techniques from @relatedwork and @tbl:grader-suitability which gave the best results in terms of accuracy, consistency, and grading transparency: a graph isomorphism algorithm for structural matching, Levenshtein distance for syntatic matching, and `all-MiniLM-L6-v2` @all-minilm-l6-v2 for semantic matching.

We first tried out Princeton's WordNet @princeton-wordnet, as it also performs semantic similarity checks, but these scores did not reflect the expected semantic similarity after testing with several self-synthesised examples and some example synonyms from the datasets. WordNet matches strictly according to the hierarchy of singular words, meaning that examples in the dataset such as 'ChargingPort' v.s. 'ChargingStation' would not be matched since 'Port' is in a different WordNet category than 'Station', even though in the exercise they are semantically similar, while examples such as 'Team Member' and 'Virtual Machine' got a semantic match, while sharing no semantic similarity within any of the datasets.

== Architecture and Language
#place(top+center, float: true, scope: "column", [
  #figure(caption: [Query architecture for #seshat.],
    image("pics/design/2026-02-10/seshat-design.svg", width: 98%)
  )<fig:arch>
])

The goal of #seshat is to take input (from either exam exports, a list of files, or via some other format), transform the input into an internal graph representation, run comparison algorithms on it defined in @subsec:relatedwork-autograder-algorithmic which produces a set of scores (a 'grade'), and format this grade in a certain way. The exact methodology, algorithms, and visualisations are likely to change, which is why we aim to maximally decouple these parts.

In order to achieve this, we implement a query-based architecture akin to that of the Rust compiler @rustc-book (an example is given in @fig:arch). This encourages decoupling each stage of the process, and additionally increases transparency internally in the grading process, as one can easily query intermediate solutions from the grading process. Testing components is also inherently made easier due to the split-up functionality.

This architecture also allows us to cache all stages of the grading process if they are split up into separate queries, which should allow for some improvements in grading speed. Note that this is only possible because the autograder only contains determinstic algorithms.

The autograder is entirely written in Go @golang. A minimal CLI is included to offer a minimal textual interface and showcase the query architecture.

== Features
This section describes the feature set of #seshat by walking the reader through the process of grading a dataset. Features are explained in the order of the grading process.

=== Parsing
The parsing step transforms a diagram file into an structure that #seshat can understand. For UTML, it merely parses the JSON UTML structure and adds some metadata such as the file name.

=== Transformation into \ internal representation
In order to be able to grade diagrams, #seshat uses an internal representation of a graph. This choice is made to separate the grading from any one specific diagram format, a mistake made in some other autograders (see @tbl:grader-suitability). Separating the grading from a diagram format has the benefit of being able to easily integrate new diagram formats into #seshat by merely writing a translation from a particular format into an internal representation.

To support as many diagram formats as possible, this internal graph definition is very loosely defined. It contains as little semantic concepts as possible (inheritance, multiplicities, etc.) as it aims to capture the literal shapes and text. This allows #seshat to store possibly broken submissions, which allows us to explicitly check the well-formedness of a graph at a defined stage, or ignore certain broken aspects of graphs, which helps in the perceived _leniency_ of the autograder and should bring it closer to human grading.

The structure is defined by some metadata such as the filename and a collection of vertices and edges. Each vertex and edge has a unique identifier. Vertices additionally contain a title, some values (fields or methods), certain optional semantic properties such as visibility (public/private/protected/...) and type (Class/Interface/...), and visual properties such as location and size. Edges are always directed and can connect at either end to a vertex, edge or nothing. Next to an identifier, they have stylistic properties for the starting and ending point of the edge, such as arrow style and text, as well as general stylistic properties, such as the style of the edge (dotted or solid). Finally, each edge has visual properties that define the edge's path. This path can be of any length, allowing for complex paths.

=== Error correction<subsec:err-corr>
After a diagram is converted into #seshat's internal representation, #seshat tries to correct specific kinds of mistakes made in the diagram creation process, depending on which options are enabled and how they are configured. This also allows for encoding semantic meaning into the diagram if the original diagram format does not allow for expressing certain semantics. 

For example, since UTML does not allow edge-to-edge connections, the 'reparation' phase can correct for this, given that edges are sufficiently visually close. These error-correcting and/or semantic encoding features exist to allow maximum leniency in grading and exist on the internal representation level, meaning they automatically apply to all diagram formats #seshat supports. 

For visualising error corrections, we refer to submission 154286, shown in @fig:submission-154286, as well as its corrected version, shown in @fig:submission-154286-corrected.

==== Edge Label Swapping
Firstly, #seshat supports edge label swapping. It can happen during the diagram creation process that a student creates labels on an edge, but then drags the labels to other locations. This can be seen with the edge 'Project' $arrow$ 'Deliverable', which has swapped labels 'has ->' and '0..1', in @fig:submission-154286 and @lst:submission-154286-json-snippet.

Having swapped labels is a problem for automatic grading, because #seshat does not consider the visual representation of the submission. When a student drags around labels and the diagram tooling does not automatically swap the labels internally, the file structure does not match the visual structure, which would make #seshat grade a diagram 'incorrectly' according to student and teacher expectations, putting students at an unfair disadvantage.

#seshat includes an option `swap_edge_labels` for this, which looks for labels with large offsets towards another position on the edge and swaps them if possible. The distance at which this occurs is configurable as a percentage of the length of an edge.

==== Edge 'Anchoring'
Some diagram software, such as UTML, sadly does not allow connecting edges to other edges, which is mandatory syntax for concepts such as UML association classes. Alternatively, students may drag arrows close to vertices or edges but not connect them directly for several possible reasons, including time limitations of exams.

This is a problem for autograders, since _technically_, those edges are not connected to anything, meaning that students will get points deducted for a solution that looks visually correct.

In order to allow some level of leniency which compensates for the inability of students to connect edges and/or the diagram software's inability to support it, #seshat allows for 'anchoring' disconnected edges that are sufficiently close to another vertex or edge. The distance at which anchoring occurs can be configured as a percentage of the length of an edge. for vertices, this is the length of the top, left, right, or bottom part of the vertex (which is assumed to be a rectangle). A demonstration of this reparation can be seen in the connections 'Record' and 'Internal Information' in @fig:submission-154286-corrected.

==== Directed Edge Recombination
In diagrams, it is not uncommon to have a set of multiple vertices connect to one 'main' vertex. This happens especially often when drawing multiple inheritance classes in UML. However, diagram software might not make it easy to draw these in a visually pleasing manner, or students might choose to draw separate edges which capture the semantics visually, but which is not represented in the underlying diagram format. A good example of this is presented in @fig:submission-154286, where classes ranging from 'SoftwareLicense' until 'CloudService' connect to 'Resources'. However, these edges are drawn individually as straight edges, and any given edge does not connect an inheriting class to the inherited class.

This is a major problem for autograding, as the representation mismatch will cause autograders to grade the individual edges, instead of the semantic concept (for example, multiple-inheritance).

#seshat includes an option `simplify-directed-edges` for this, which looks for multiple edge-to-edge connections that end in a directed edge (an edge with some kind of arrow or diamond on one side). The effect of this recombination is demonstrated in @fig:submission-154286-corrected.

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

=== Grading process<sec:grading-process>
After the internal representation is repaired, it can be graded. This is done based on graph comparisons / isomorphism: a teacher solution is compared to a student solution by trying to make a mapping of teacher vertices and edges to those drawn by the student. #seshat grades with the following general graph comparison algorithm:

1. take the teacher's graph ($r$) and a student submission ($s$). Vertices in a graph $g$ are denoted by $V_g$. Edges in $g$ are denoted by $E_g$.
2. analyse the semantic and syntactic equivalence of all $(v_r,v_s), v_r in V_r, v_s in V_s$ and score it in a range of 0 (no similarity) to 1 (perfect similarity), i.e. $"score"(v_r,v_s) arrow [0..1]$.

3. take $"max(score("v_r,v_s"))" forall v_r in V_r, v_s in V_s$, given that the score is higher than the threshold (defined in the grading instructions). Put these pairs $v_r arrow v_s$ into a minimal subgraph pair ($g_v_r, g_v_s$)

4. repeat for each pair $g_v_r, g_v_s$ until no progress is made:
  1. get a list of $e_r in E_r$ that connect to $v_r in g_v_r$ ($E_g_v_r$), and a list of $e_s in E_s$ that connect to $v_s in g_v_s$ ($E_g_v_s$).
  2. $forall e_r in E_r$ get the starting and ending vertices of $e_r$ (if they exist), collect them into $V_g_v_r$. Do the same for $E_s$ ($V_g_v_s$).
    - make a mapping of $"max(score("v_r,v_s"))", v_r in V_g_v_r, v_s in V_g_v_s$ into `newFixedIds`.
  3. Add all $(v_r,v_s) in$ `newFixedIds` and add all $e_r in E_r, e_s in E_s$ given that their starting/ending vertices are in $V_r$ or $V_s$ respectively.

5. Once no further progress is made, we score the subgraphs $(g_v_r, g_v_s)$ based on how many vertices and edges have been mapped.
6. We take the highest-scoring subgraph pair as basis and add as many other matching subgraphs, given that the edges and vertices of other subgraph pairs do not appear in the final combined solution yet.

After the last step, we have one final mapping $(g_v_r, g_v_s)_"fin"$ which decides which vertices of the reference solution likely map to the student submission.

After arriving on a final mapping, we apply the user-supplied grading configuration: we hand out additions or deductions in points based on vertex or edge presence, absence, or incorrectness, and for specific parts of vertices or edges such as vertex attributes or edge arrow style.

This grading configuration also specifies the reparation options specified in @subsec:err-corr. This allows a teacher / grader to specify stricter or looser corrections for a particular dataset, if #seshat performs undesired repairs.

=== Visualisation<sec:visualise>
After arriving on a grade, #seshat needs to show this to the user. Two built-in methods exist: an export to a `.csv` file, containing only the final grades per input file, and an export to `.json` files, one per input file, explaining in detail how #seshat calculated the grade.

#hl("Add example .csv / .json export")

There is also a demo graph export of a grade, which shows in red, yellow, and green which vertices / edges were incorrect, superfluous, or correct.

#hl("add example graded graph")

There also exists a GraphViz export function for #seshat's internal structure. This allows for easily viewing how different reparation options affect a solution. A JSON export of the graph is also possible, which outputs the exact internal representation of the graph. An example is given in @fig:submission-154286-corrected. Note that GraphViz neither supports fixed edge paths nor edge-to-edge connections, meaning that edge placement is incorrect, however, this is present in the JSON export.

== Testing
When developing an autograder, it is vitally important to verify its correctness and expected behaviour. We implement a variety of automated tests to ensure this. Because #seshat includes a lot of parsing and graph corrections, not unlike compilers and Syntax Tree / Control Flow Graph analysis, we take inspiration from the terms used for compiler testing, as mentioned in #cite(<Zaytsev2018>, form: "prose").

#seshat is tested in an automated fashion for all large features it possesses: for parsing, conversion into the internal graph structure, repairing the internal graph, and for grading.

For the initial stage of parsing UTML into our own in-memory data structure, we employ P-testing @Zaytsev2018. This means that we verify that, for each file in our test data the data sets, #seshat should produce the exact same JSON structure as is inputted. One noteable exception is UTML's `attributes` and `methods` fields. the UTML files sometimes either lack these fields, they are `null`, or they contain an an empty array (`[]`). Because this is semantically equivalent in our context, we explicitly treat `null`/`[]` or a missing `attributes`/`methods` field as the same.

For the conversion from UTML into the internal representation, we use a form of N-testing @Zaytsev2018: we parse a UTML file into `ParseResultUTML`, then convert it into our `InternalGraph`, and then perform checks comparing the parse result and internal representation. We validate whether the vertex and edge IDs remain the same, and whether edges are still connected to their respective vertices or edges, to name a few.

For special features such as connecting edge ends and swapping labels (see @subsec:err-corr) we perform unit testing with fixed examples, which test both a couple of happy paths (where the program should modify the graph) and control paths (where the program should not change the graph).

= Threats to valididty
The internal validity of this paper may be affected by a few factors. 

Firstly, selection bias in the researched papers and reporting bias in those papers may affect the perceived performance of certain types of autograders, which could negatively affect the choice of algorithms used for #seshat. As we aim to provide a _comprehensive_ overview, not an exhaustive one, selection bias becomes more important, especially when using snowballing, as one can easily fall into multiple papers about a specific sub-strategy and lose the overall picture. This is also why we keep snowballing at a minimum.

Secondly, the manner in which humans have constructed the rubrics in the dataset is inherently biased towards human graders, which generally do not apply it to the letter (which we will see in @results). When implementing a grading rubric that _does_ follows the rubric to a tee, we risk losing the leniency of human interpretation.

Thirdly, the datasets do not provide details about which humans graded which submissions, when those submissions were graded, which reasoning was behind each of the grades, along with a variety of other factors. Especially the reasoning behind a grade would have been useful to discern the different types of grading deductions, which would help with result quality. However, since we only get a final grade to work with, we have to guess why grades were constructed by humans, and aim to achieve a similar leniency and error correction. This process is additionally prone to bias from the author.

= Results<results>
/discussion?

== BIT 2024
#hl([results])

== TCS 2025
=== Question 5
- To compare against M2_2025_TCS, I will likely have to adjust the grading to not penalise extra classes and/or fields, just purely give points for the things that are present, like specified in the rubric.

=== Question 6
#hl([results])

== BIT 2025
#hl([results])


= Discussion
#hl([ add ])

= Conclusion
#hl([ add ])

]) // 2-column

#pagebreak()
#bibliography("refs.bib")

// #heading(numbering: none, [ Appendices ])
// #show: appendix

