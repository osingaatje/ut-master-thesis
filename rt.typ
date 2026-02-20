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
#set page("a4", margin: DOC-MARGIN)

#let seshat = text([_Seshat_])

#columns(2, gutter: 10pt, [

// todo styling
#set todo(radius: 2pt)

#abstr(content: 
  [
    During computer science studies, students are often required to submit diagrams. The grading of these diagrams is currently done by humans, resulting in a costly, lengthy, and error-prone process. In this paper, we investigate the theoretical feasibility of automatically grading diagrams, focusing on Unified Modelling Lanuage diagrams and the UTML file format used by the University of Twente. Existing work shows that graph isomorphism algorithms which account for the use of synonyms and the presence of spelling mistakes provide the best results, but that existing autograders are not adaptable UTML format. Based on these findings, we propose #seshat, an autograder that combines the aforementioned techniques into a generic autograder capable of supporting arbitrary diagrams and file formats, including UML diagrams or Entity-Relation diagrams stored in arbitrary formats, with built-in support for UTML. In the final thesis, we realise #seshat and compare it to human grading for multiple UTML exam submission datasets.
  ]
)

= Introduction <intro>
// Current state of grading + autograding, University of Twente is looking into ways to save time and money in grading by automating (parts of) it.

Unified Modelling Language (UML) diagrams, introduced by the Object Management Group @omg-group, play a significant role in computer science, as they allow for communicating software designs in a standardised format. During technical studies, students are often required to make UML diagrams for graded assignments or exams.

However, the grading of these diagrams is often a costly and lengthy process, involving multiple paid members of staff @Ahmed2024#footnote("From personal experience.")<footnote:pers-exp>. Additionally, this process is prone to grading inconsistencies due to various reasons @Ahmed2024, but mainly the inconsistency of human graders @Ahmed2024 @Meadows2005. #cite(<Meadows2005>, form: "prose") pose two possible solutions to the problem of human grading: either "report the level of reliability associated with marks/grades, or find alternatives to [grading]." We propose a third alternative: finding alternatives to the grading _process_.

The (partial) automatisation of grading diagrams ('autograding') provides a grading paradigm that can both reduce the cost and time required for institutions and reduce the inherently present inconsistencies in human grading#footnote("Given that the process is deterministic")<footnote:determinism> @osinga2024 @Bian2020. This could result in similar or superior performance compared to human grading in terms of *accuracy*, *grading transparency*, and *consistency*.

With _accuracy_, we mean the percentage of points assigned to a submission that are prescribed by the rubric for a particular excercise. With _consistency_, we mean both the extent to which similar grades are given to similar submissions and the difference between consecutive runs (i.e. determinism). With _grading transparency_, we mean the extent to which the reasoning for a particular grade is explained with regards to the rubric for the exercise or to the Intended Learning Objectives (ILOs) of a module. These properties are desirable in the grading process, as it means that students are graded in a way that reflects their performance (_accuracy_), allows them to see which parts they could improve for future assignments (_grading transparency_), and is minimally unfair (_consistency_).

Specifically for the implementation, we desire an autograder that can _link its grading to ILOs_, as described by the previous paragraph. Furthermore, built-in _UTML support_ is a must, as it is the main file format the University of Twente uses. Finally, an _easily extensible_ autograder would be ideal, since we might want to extend support to other file formats or alter the behaviour of the autograder.

== Background <bg>
The idea of letting a computer program (partially) grade tests has been discussed in papers since the 70s #cite(<pirie1975>, supplement: "p.13"), with some papers with implementations starting to appear around the 80s, primarily focused on grading the writing style of computer programs @Rees1982. Interest in grading diagrams specifically seems to have started around the early 2000s @smith2004 @thomas2004.

Diagrams themselves have multiple variants for different purposes. UML diagrams, for example, mainly serve to visualise and document software @omg-group, while Entity-Relation diagrams focus on the relations between different components, making it ideal for visualising database designs @Bagui2003.

Different formats exist for storing these diagrams. Examples include XMI - the standard diagram interchange format for UML, most commonly used by the Eclipse Modelling Framework @xmi-omg, the Rose Petal format - used by the UML development program IBM Rational Rose @ibm-rational-rose, PlantUML - an open-source textual standard for representing various diagrams including UML and ER diagrams @plantuml, Visual Paradigm files - software that allows for modelling UML, architecture diagrams, business flows etc. @visualparadigm, and UTML - an in-house developed program and file format used at the University of Twente for representing UML and various other types of diagrams, building on the JSON standard @utml-internal @utml-website.

The degree to which automated grading is implemented can vary as well. We divide autograding into the following categories: _non-automated_ (everything must be done by a human), _automated_ (part of the process requires no human input), and (fully) _automatic_ (no human input is required). In this paper, we only consider autograders that fall into the categories _automated_ and _automatic_.

== Research Questions <rqs>
In order to examine the feasibility of automatically grading UML diagrams saved in the UTML format, we provide a main research question (*MRQ*):

#align(center, [
  *To what extent can UML diagrams be graded automatically while maintaining or improving the accuracy, consistency, and grading transparency of human grading?*
])

We aim to answer the main research question with the following research questions:

#let rq(content) = box(inset: (left: 10pt), content)

#rq([
*RQ1*: To what extent are existing solutions suitable for use in autograding UTML diagrams with regards to (1) accuracy, (2) consistency, (3) grading transparency, (4) extent of linking ILOs to grading instructions, (5) UTML support, and (6) ease of extending the source code to alter functionality?
])

#rq([
*RQ2*: To what extent can a suitable autograder be constructed from previous work to be able to grade UTML diagrams?
])

#rq([
*RQ3*: To what extent does the suitable autograder compare to human grading in the context of grading first-year UML exam questions?
])

*RQ1* is answered in @relatedwork, by analysing these works for suitability of grading. Existing works are categorised according to the requirements outlined by *RQ1* in @tbl:grader-suitability. @tools-techniques explains the plan for building the autograder and @planning outlines the planning for research questions *RQ2* and *RQ3*, which are to be answered in the final thesis, where we grade UTML diagrams using an implementation based on related work and compare it to human grading.

= Related work <relatedwork>
In order to answer research questions *RQ1*, we conduct a small-scale literature study covering roughly 40 works.  It aims to provide an exploratory view into the world of autograders and ILOs, which is why we omit formal inclusion and exclusion criteria. Works are collected using the search engines Google Scholar#footnote(link("https://scholar.google.com")) and ResearchGate#footnote(link("https://www.researchgate.net")), with related work for autograders being searched with terms including but not limited to "automatically grading UML diagrams", "autograder diagram", "UML diagram assessment", "machine learning diagrams", and "diagram evaluation assessment AI". For papers on ILO and ILO integration into rubrics, terms were used such as "learning outcomes include in rubric", "learning objectives in rubrics", and similar. Snowballing (the practice of looking at sources of sources) was used to a depth of 1.

== Autograders
Multiple types of papers on autogrades are researched, which we categorise into frameworks for autograders, purely algorithmic autograders, and AI-driven autograders (using Machine Learning (ML) / Generative AI (GenAI) techniques). Findings on autograder implementations are summarised in @tbl:grader-suitability.

=== Frameworks / Theoretical<subsec:relatedwork-autograder-frameworks>
Autograder frameworks dictate certain designs or methodologies for building autograders. We present summaries of the explored frameworks and provide a general summary of all frameworks.

#cite(<smith2004>, form: "prose") provide a five-step framework for assessing "possibly ill-formed or inaccurate diagrams" that include the steps (1) segmentation, (2) assimilation, (3) identification, (4) aggregation, and (5) interpretation. While the first two steps are meant for translating images or other "raster-based input" into diagrammatic primitives, which is not useful for us, the latter stages provide a solid conceptual foundation to grade diagrams.

#cite(<batmaz2010>, form: "prose") takes a broader look at the process of grading, identifying and developing techniques to reduce repetitive actions, focusing on database ER diagrams. The paper suggests a semi-automatic grading system, including automatic grading based on identifying identical segments between a submission and the solution. Assuming multiple submission revisions are available, it suggests to "not only [use] the reference text but also the intermediate diagrams" for identifying semantic matches #cite(<batmaz2010>, supplement: "p.40"). While multiple solutions are not useful for the purpose of grading only a single submitted diagram after an exam, this might be useful for live feedback.

#cite(<Vachharajani2014>, form: "prose") propose a UML use case assessment architecture, providing a useful catalogue about edge cases related to use case diagram assessment which are also applicable to other types of diagrams, such as the chance of misspellings, synonyms, abbreviations, directionality of relationships, and more.

#cite(<Bian2019>, form: "prose") establish a model to map submissions to example solutions and one to grade submissions. It recommends syntactic matching to help with spelling mistakes, semantic matching to match related words, and structural matching to match neighbouring elements and/or inheritance, with the goal to optimally match parts of a student submission with a sample solution. 

In conclusion, most autograder strategies recommend structural matching (to identify similar segments of graphs), often in combination with syntactic matching that accounts for misspellings and semantic matching to account for synonyms or related words. Unfortunately, the strategies do not account for integrating ILOs into the grading process explicitly.

=== Algorithmic <subsec:relatedwork-autograder-algorithmic>
Next to frameworks for autograders, implementations were also discovered during the literature review, of which a subset used purely algorithmic methods. Summaries of these sources are discussed in this section, along with a general summary on algorithmic autograders.

#cite(<Bian2020>, form: "prose") implements their previous framework @Bian2019 and validates it with a case study, using the Levenstein distance between words for syntactic matching, several metrics for semantic matching, and structural matching based on similar attributes and operations within classes. They find that multiple teacher solutions result in more accurate grades with an average accuracy over 95% #cite(<Bian2020>, supplement: "p.10"). Additionally, they find that grading configurations need to change per exam if the goal is to produce the most similar scores to manual grading, likely because the focus of each exam or exercise is on a different aspect of diagram creation (associations, inheritance, etc.). Lastly, they state that autograding "has shown to be more consistent and able to ensure fairness in the grading process" compared to manual grading #cite(<Bian2020>, supplement: "p.11"). Additionally, their visual feedback system seems to provide a clear visualisation of the grading results, which might feel more intuitive for students. An example is shown in @fig:Bian2020_Fig9.

#cite(<Hosseinibaghdadabadi2023>, form: "prose") also implements the framework by #cite(<Bian2019>, form: "prose"), comparing UML use case diagrams to one or multiple example solutions and preferring the maximum grade. It uses a graph similarity algorithm which matches nodes based on structural matching, along with syntactic matching using the Levenstein distance between words and semantic matching using WordNet similarity score (HSO, WUP, LIN metrics). It achieves a similarity percentage of 93.31% #cite(<Hosseinibaghdadabadi2023>, supplement: "p.114").

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

In conclusion, most existing implementations of autotgraders use some graph isomorphism algorithm with a combination of structural, semantic, and syntactic matching, as suggested by most frameworks. Some solutions attempt to autograde using property or formula checking, but fail to mention a detailed enough methodology or results to warrant further investigation. No autograders provide methods on integrating ILOs into the grading process.

// Note to self: replicating Bian 2020 with Smith 2004 steps with advice from Thomas2004-2011 would be a good bet.

=== ML- / GenAI-driven <subsec:relatedwork-autograder-AI>
Next to using purely algorithmic methods, some papers experiment with Machine Learning / Generative AI (collectively: 'AI-driven solutions') to automatically grade submissions, and even mention some hybrid AI / algorithmic solutions. We provide summaries of the explored sources below, along with a general conclusion on AI-driven autograders.

#cite(<Stikkolorum2019>, form: "prose") is one of the earliest papers found that attempts Machine Learning-based autograding, using several machine learning algorithms to compare submissions to expert grades. Unfortunately, the grading only reaches a maximum accuracy of 42.76%, while rounding off scores to a 10-point integer scale. Exact methods and algorithms are not mentioned.

#cite(<Wang2025>, form: "prose") evaluate the feasibility of LLM-based grading with the LLM model ChatGPT-4o, focusing on student reports containing multiple types of UML diagrams. They feed pictures of student-submitted UML diagrams directly into the model along with an explanatory prompt that aims to trigger a Chain-of-Thought process (which should help LLMs "tackle complex arithmetic, commonsense, and symbolic reasoning tasks" @wei2023), and runs the model once per submission, with a temperature of 0.1. They find that score differences range from -0.25 to +3.75 points, with with the LLM handing out significantly lower average scores compared to humans. Additionally, they note many occurrences of incorrect grading (wrong identifications, overstrictness, and misunderstandings) #cite(<Wang2025>, supplement: "p.18"), which means that, while the authors claim that their solution "demonstrates particular proficiency in the automated evaluation of UML use case diagrams", the grading is not internally consistent and contains hallucinations. In the words of the authors: "In the evaluation based on UC4, GPT deducts points for missing relationships between specified actors and use cases, but theses relationships existed in the UML use case" #cite(<Wang2025>, supplement: "p.13"). Furthermore, the paper does not express a strong correlation between LLM grading and human grading, at least compared to papers utilising graph matching algorithms @thomas2009 @Hosseinibaghdadabadi2023, nor does it recognise the inherent bias of LLMs @ranjan2024 or their inherent non-determinism (even with a zeroed temperature) @brenndoerfer2025 @atil2025.

#cite(<Bouali2025>, form: "prose") uses various LLMs (Llama 3.2B, ChatGPT-o1 mini, and Claude Sonnet) to grade diagrams, first translating the diagrams into text instead of giving the LLM images directly like #cite(<Wang2025>, form: "prose"). While they achieve a Pearson correlation to human grading of 0.76 with both ChatGPT and Claude, they run into the same inconsistency issues as #cite(<Wang2025>, form: "author"): "while the models would provide a final score as requested in the prompt’s response format, this score often did not match the actual sum of points awarded in their criterion-by-criterion assessment", and "'One ChargingPort is associated with One Vehicle' was matched with 'One ChargingPort is associated with One ChargingStation' with a similarity of 0.92, despite describing different domain relationships" #cite(<Bouali2025>, supplement: "p.164").

#cite(<Bouali2025>, form: "author") identify the problem with grading with LLMs perfectly, stating that "This discrepancy can be attributed to the autoregressive nature of LLMs, where they generate responses token by token" #cite(<Bouali2025>, supplement: "p.164"). Because these models are in their very essence based on predicting tokens @Ferraris2025, there is no formal guarantee that the grades are internally consistent and that grades are produced accurately with respect to the rubric. The fact that LLMs produce grades that correlate with human grading does not mean that this grading is done in a fair, consistent, or reliable manner. While #cite(<Bouali2025>, form: "author") try to reduce the non-determinism of LLMs by setting the temperature to zero, this does not necesssarily remove non-determinism @brenndoerfer2025 @atil2025, nor does it account for training biases @ranjan2024, as mentioned before.

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
#cite(<dinur2009>, form: "prose") states that analytical rubrics (those which mention explicit criteria) provide more details than global, holistic rubrics. These types of rubrics (and their exercises) can be constructed directly from the ILOs of a course or module, which would provide a detailed grading rubric that aligns closely to its ILOs #cite(<osinga2024>, form: "prose"). Given that rubrics and exercises are defined in such a way, one could link these ILOs to the grading rubric and provide functionality for an autograder to show these in the final grade This would indicate to students how well they achieved the learning goals of the module in order to improve _grading transparency_.


== Conclusion
In the explored related work, existing frameworks primarily recommend structural matching in combination with syntactic and semantic matching to account for spelling mistakes and the use of synonyms. Existing implementations mostly use the methods recommended by the frameworks, with the best results stemming from determinstic graph isomorphism algorithms. Purely AI-driven methods may require less effort from teachers, since teachers do not need to produce sample diagrams but can describe their rubric in words, but produce noticeably inferior results to graph matching algorithms. Using hybrid methods, specifically using AI-driven classification algorithms only for semantic/syntactic matching, seems to produce similar results to 'pure' graph matching algorithms, but does not necessarily provide accuracy gains over algorithmic solutions and can additionally introduce nondeterminism in otherwise determinstic solutions, reducing consistency.


#place(bottom+center, scope: "parent", float: true, [
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


= Tools and Techniques <tools-techniques>
Given the existing works mentioned in @relatedwork and @tbl:grader-suitability, the best approach for maximising accuracy, consistency, and grading transparency seems to be to use graph isomorphism algorithms akin to those suggested by #cite(<smith2013>, form: "prose"), implemented by papers such as #cite(<Bian2020>, form: "prose") and #cite(<thomas2009>, form: "prose"). Visualisations similar to @fig:Bian2020_Fig9 could prove to be a nice addition, so architectural support for visualisations will be taken into account, which can be implemented should there be time left.

Unfortunately, no solutions seem to support the integration of ILOs into their grading rubric inputs. While we believe that this is a vital point to consider when making rubrics or example solutons @osinga2024, we realise that it may require extra work for a teacher to add metrics on how much a certain ILO is tested, and may not be compatible with existing rubrics. Therefore, we aim to add support for optional ILO weights, either per diagram feature or for specific parts of an example solution. For example, a teacher would ideally be able to mark that the presence of certain classes, certain associations, the multiplicity of associations, or the connection between (certain) classes satisfies a certain set of ILOs.

Since existing solutions do not provide the features necessary, nor their source code (see @tbl:grader-suitability), we develop our own autograder, named #seshat#footnote([ The Egyptian record-keeping godess and daughter of _Thoth_, the name of #cite(<osinga2024>, form: "prose")'s autograder. ]).

== Architecture
#place(top+center, float: true, scope: "column", [
  #figure(caption: [Query architecture for #seshat. \ (UTML was not used to make this diagram)],
    image("pics/design/2026-02-10/seshat-design.svg", width: 98%)
  )<fig:arch>
])

#place(bottom+center, scope: "column", float: true, [
    #set table(stroke: 0pt, inset: 0pt)
    #set table.hline(stroke: 1pt)
    #set table.vline(stroke: 1pt)
    #figure(
    table(
      columns: (auto,auto,auto,auto,1fr),
        inset: 3pt,
        align: (right+horizon, right+horizon, center+horizon, left+horizon, left+horizon),
        table.header(
          table.hline(),
          table.cell(align: center, colspan: 4, [ Increment ]),  [ Task ],
          table.hline(),
        ),
          table.vline(x: 0, start: 0, end: 1000), table.vline(x: 4, start: 0, end: 1000), table.vline(start: 0, end: 1000),

          [Wk.], [ 6],[-],[ 7],   [ set up prototype architecture ],  table.hline(),
          [Wk.], [ 8],[-],[ 9],   [ UTML input parsing ], table.hline(),
          [Wk.], [10],[-],[11],   [ internal graph representations ], table.hline(),
          [Wk.], [12],[-],[13],   [ implement/verify *syntactic* matching algorithm(s) \ @Bian2020 @thomas2009 @smith2013 ], table.hline(),
          [Wk.], [14],[-],[15],    [ implement/verify *semantic* matching algorithm(s) \ @Bian2020 @thomas2009 @smith2013 ], table.hline(),
          [Wk.], [16],[-],[17],   [ implement/verify *structural* matching algorithm(s) \ @Bian2020 @thomas2009 @smith2013 ], table.hline(),
          [Wk.], [18],[-],[19],   [ combine/verify algorithms \ @Bian2020 @thomas2009 @smith2013 ], table.hline(),
          [Wk.], [20],[-],[21],   [ combine/verify/document algorithms @Bian2020 @thomas2009 @smith2013, compare to manual grading ], table.hline(),
          [Wk.], [22],[-],[23],   [ compare to manual grading, document results in paper ], table.hline(),
          [Wk.], [24],[-],[25],   [ Finalise paper / buffer time / peer reviews by colleagues ], table.hline(),
          [Wk.], [26],[-],[27],   [ Finalise paper / buffer time / peer reviews by colleagues ], table.hline(),
    ),
    caption: [ Increment planning of the final thesis. Note that paper development is done in parallel to the development of #seshat. ]
  )<fig:planning>
])


#seshat needs to take input (from either exam exports, a list of files, or via some other format), transform the input into an internal graph representation, run comparison algorithms on it defined in @subsec:relatedwork-autograder-algorithmic which produces a set of scores (a 'grade'), and format this grade in a certain way. The exact methodology, algorithms, and visualisations are likely to change, which is why we want to maximally decouple these parts.

In order to achieve this, we aim to implement a query-based architecture akin to that of the Rust compiler @rustc-book, of which a draft architecture can be seen in @fig:arch. This encourages decoupling each stage of the process, and additionally increases transparency internally in the grading process, as one can easily query intermediate solutions from the grading process. Testing components is also inherently made easier due to the split-up functionality.

Finally, a query-based architecture allows for caching all stages of the process, which is possible since we make the explicit choice to use only deterministic algorithms. This allows for efficiency improvements if we need to fetch some query output multiple times, or if we need to grade a solution we have already seen before.

== Language
For this project, we opt for Go, as it is a multi-pardigm, statically typed, and compiled language. This should allow us to leverage both imperative and functional paradigms, create a robust architecture, and allow for fast grading. Additionally, the author is familiar with it, which should decrease the time it takes to implement features.

= Planning <planning>
We plan to develop #seshat according to the Agile methodology @agilemanifesto. This means that we divide the work up into increments, and aim to show new deliverables frequently. This prioritises prototyping and frequent feedback, allowing the supervisors to steer the direction of the project effectively.

We divide these increments up into two weeks. This should allow for enough time inbetween to make significant progress on #seshat and the final paper, while keeping increments small enough to be able to reflect on the progress made often enough and make adjustments to the plan if necessary. We meet with the main supervisor every increment. We invite the co-supervisor to every meeting: they are free to attend when they wish to see progress and/or give advice. When in doubt, we explicitly ask advice of both supervisors to get a view that spans multiple perspectives.

During the development of #seshat, we add to the paper in parallel, documenting design decisions and progress.

The increments are initially structured in the way defined in @fig:planning. Note that these are subject to change, and there is a bit of buffer time planned in, as it might turn out there is more research needed to complete certain algorithms .


]) // 2-column

#pagebreak()
#bibliography("refs.bib")

// #heading(numbering: none, [ Appendices ])
// #show: appendix

