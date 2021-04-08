---
title: 10 Cool Things About R
description: A 90 minutes long hands-on introduction to R and why you should or should not learn it.
---

![](https://i.imgur.com/QThpLod.png)

# 10 Cool Things About R

**Tobias Busch**  
April 6th, 2021 @ ISP ComPros Lunch Meeting at UiO   
90 minutes hands-on presentation

*Speaker notes / handout*

---

:::success
## What will we do?

- 90 minutes - *brief* introduction to R
- Provide motivation for learning R (or for not learning R)
- Learn 10 cool things about R
- Hands-on mini data analysis demo to demonstrate the power of R

### Take aways :takeout_box: 

- Is R for you?
- Basic data wrangling, modeling, data visualization
- How to continue learning?
:::

---

## Who am I?

- Worked with R for almost 10 years
- Experience with other languages (Matlab, Python, ...)
- I sometimes teach R (usually half/full day courses)

---

## Who is this for?

- You are doing research / data analysis with other tools
- You are curious about R, because...
    - FOMO - What's all the fuzz about?
    - You feel that your current "workflow" isn't good? sufficient? robust? reproducible?
    - There's this one package you would like to use
    - You tried R and were overwhelmed, but would like to give it a second chance

#### I'm assuming you...

- have no real programming experience 
- are not particularly interested in computers or programing
- are curious about R because you want to get things done and R might help you with it

---

## What is R?

- A domain specific programming language (?)
- [An environment for interactive data analysis that *has* a programming language](https://youtu.be/6S9r_YbqHy8) 
- An open source implementation of the [*S* language](https://en.wikipedia.org/wiki/S_(programming_language)), created in the 1970s with *interactive data analysis* in mind:
    - **Interactive:** A really fancy calculator
    - **Data Analysis:** More than in many other languages, data and stats are *first-class citizens*
- Popular in academia (bioinformatics, geoscience, digital humanities) and industry (finance, pharmaceutical, ...)
- Versatile & Powerful - R can be your *one-stop-shop* for the whole data science workflow:
    -  Data collection 
    -  Data cleaning & transformation *(aka "Data Wrangling")*
    -  Data Visualisation 
    -  Modeling
    -  Reporting / Communicating 
    -  [and more](https://youtu.be/m6nUdoP6894)

![](https://i.imgur.com/sclqeRc.jpg)

---

## 10 cool things about R


1. Free and open source
2. Easy to get started
3. Flexible language
4. Well documented
5. Expandible
6. Powerful data wrangling
7. Powerful statistical methods
8. Powerful data visualisation
9. Encourages reproducible research
10. Awesome community

We will have a closer look at these later, but first ...

---

## Why you should *not* learn R


![](https://i.imgur.com/1RXxM5z.jpg)
*Regardless of what R enthusiasts will tell you, R is not the solution to every problem.*
  
- Learning R is a considerable time investment - Coding needs practice! 
    - Depending on previous experience, steep learning curve. 
    - Even if you are an experienced programmer, [R can be weird!](https://youtu.be/6S9r_YbqHy8)
    - Pays off when doing lots of analyses, complex data transformation,... if you only do one or two small things, it may not be worth it.
- Never change a winning team -- If your current setup works for you, don't change it!
- Commercial software like SPSS, SAS, Stata, MATLAB.... has customer support and usually "one right way" to do things (less "agony of choice")
- Not all methods may be available in R. For example, handling missing data with Maximum Likelihood in MPlus is not available in R's equivalent `{MClust}`
- There are good *no-coding-needed* alternatives to R, even free ones, for example...
  - Stats with [Jamovi](https://www.jamovi.org/), [JASP](https://jasp-stats.org/)
  - Data visualisation with [RAWgraphs](https://rawgraphs.io/), [Flourish](https://flourish.studio/), DataWrapper, Tableau...
- If you are interested in learning a language that is more generally useful, you might want to learn Python instead.
  
:::spoiler *Yes, but...*
Once mastered, the [*expressiveness*](https://en.wikipedia.org/wiki/Expressive_power_(computer_science)) of programming is unmatched by any point-and-click tool. Moreover, coding is a valuable skill and can also be a lot of fun to learn. And R, while certainly not as widespread as Python, is quite popular in the data analysis world and a pretty useful skill to have 'under your belt', even if you end up not using it much.  
:::

---

## 1. R is free and Open Source

- Trying it won't hurt!
- No license fees or purchasing cost - Less bureaucracy 
- Can use everywhere - Good for collaboration and sharing

:::info
**Free and open source does not mean unprofessional!** The R project is very stable with a sort of business model around it and a core team of computer science and statistics experts guiding its development.

R is *directly* supported by companies like RStudio, who employ developers to improve R, and *indirectly* through people building R packages as part of their jobs (e.g., research software engineers, statisticians).  

R even has [peer-reviewed](https://www.jstatsoft.org/index) [journals](https://journal.r-project.org/archive/2020-2/) which academics use to get credited for working on R projects. It's also not uncommon to see papers about new statistical methods that are accompanied by R implementations.  
:::

---

## 2. It's easy to get started

- Install [R](https://www.r-project.org/) and [RStudio](https://www.rstudio.com/products/rstudio/) (Alternatively: give it a spin at [rstudio.cloud](https://rstudio.cloud/))
- That's it! You're ready to rock! :sunglasses: 

:::spoiler *Well, actually...*  
- For some things (e.g., Bayesian statistics), you might need some additional tools that don't come with the standard installation (first and foremost a C/C++ compiler). For this you might have to install [RTools](https://cran.r-project.org/bin/windows/Rtools/). However, you can always do that later.
- For more reproducible research, you should also have [Git](https://git-scm.com/) installed. RStudio has a Git GUI built in, but personally I prefer [Github Desktop](https://desktop.github.com/). We will talk a bit about Git later, but it really deserves its own 90 minutes introduction, so we will keep it brief.  
- For even more reproducibility you could instead make an RStudio [Docker container](https://www.rocker-project.org/) for each project, but that is way beyond the scope of this intro.  
:::

---

:::info
[**RStudio**](https://www.rstudio.com/products/rstudio/) is an *all-in-one* development environment (Integrated Development Environment, *IDE*) that most people use to work with **R**. It provides a convenient user interface for working with R.  
There are good alternatives to RStudio, but  **R's own GUI** is not one of them:  
![](https://i.imgur.com/GVARFyH.jpg)
*R's own GUI --- The 90s called...they want their user interface back.*
:::

---

### :hammer_and_wrench:  **Hands-on.** First steps with RStudio 


![](https://i.imgur.com/bHTZyfC.gif)
 
- Create a new RStudio Project, check "Use version control" and "use renv" -- we will get back to those later. 
- Create a script file (first step towards reproducibility!)
- Note the difference between the *console* (fancy calculator) vs. *scripts* (code you want to keep)
- Run commands / individual lines from your script using <kbd>Ctrl</kbd> + <kbd>Enter</kbd> or the button on the top right

---

## 3. A flexible programming language that grows with you

- Very little *boilerplate* code necessary
- Beginners don't need to worry about much of the programming concepts that are central in other languages (control-flow, OOP, ...) because R's vector-based approach to data manipulation will go a long way
- Also many convenience functions hide the nitty-gritty from you
- Grows with your needs - start easy, ramp up complexity as you go
- Functional language but also supports different programming paradigms
- Allows some wild *meta-programming* stuff that's impossible in other languages

--- 
### :hammer_and_wrench:  **Hands-on.** R Programming 101 

#### Basic Data Types and Operators

- Assign values to variables (objects) with `<-` (Keyboard Shortcut: <kbd>Alt</kbd>+<kbd>-</kbd>)
- data types: numbers, characters, `NA` (a special value for missing data), logical (`TRUE` or `FALSE`), ...


```r
# Assigning variables and playing around with them
a <- 1
b <- 9
a + b

a <- 10 # Quiz: what would a + b return now?

x <- "Hello World!"
x

# logical
a <- TRUE
b <- FALSE
```

#### Vectors and Data Frames

- When working with data, you will encounter **vectors** and **data frames**. - Vectors are a *data structure* that stores values of the same type (e.g., numbers) in a particular order and allows you to operate on them.
- To create a vector we use a function, `c()` ("combine").
- Note: Use <kbd>F1</kbd> to access the help file for any function

```r
# Create a vector
c(1,2,3,4)

# R is good at working with vectors. 
# See how easy it is to multiply all numbers by a scalar...
c(1, 2, 3, 4) * 10

# ...or take the mean using the mean() function
mean(c(1,2,3,4))
```

- Often data is more complex than this, and for that R has *data frames*.
- Data frame are spreadheet-like tables with *rows* (observations) and *columns* (variables). 
- Columns are vectors. Everything you can do with a vector can be done with a data frame column.

```r
# You can make your own data frame by hand
my_precious_data <- data.frame(
    "first" = c(1,2,3,4), 
    "second" = c(2,4,5,6)
)
```

:::spoiler *Well, actually...*
You will also encounter other data types and structures, including 

- **Integer** -- whole numbers
- **Double** -- decimal numbers
- **Factors** -- a fixed set of values
- **Lists** -- similar to vectors, but they can contain a mix of data types, including other lists
- **Tibbles** -- a 'modern' version of data frames, provided by the tidyverse
- objects -- R even has 3 types of objects, R6, S3, and S4 

It's far beyond the scope of this intro, but you can read more about it [here.](http://adv-r.had.co.nz/Data-structures.html)
:::

---

## 4. R has great documentation

- Documentation is easy to access, well-written, comprehensive -- helps to learn the basics
- Use <kbd>F1</kbd> to access the documentation for anything
- Use <kbd>F2</kbd> to access the documentation for anything (It is open source!)
- RStudio has excellent fuzzy auto-complete and help while you type
- Great [cheatsheets](https://www.rstudio.com/resources/cheatsheets/) for popular packages (RStudio Menu: `Help > Cheatsheets > ...`)
- Function documentation, package vignettes and package websites are usually well written and comprehensive
- Google, [StackOverflow](https://stackoverflow.com/questions/tagged/r), [RStudio Community](https://community.rstudio.com/)
- Lots of blogs with tutorials written by other R users
- Use `#RStats` on Twitter to keep track of new things and answer your questions 

---

## 5. R is expandable (there's a package for everything!)

- Part of the open source advantage: tens of thousands of packages to make yur life easier!
- The R package ecosystem is a candy store for stats and productivity tools. see [rdrr.io](https://rdrr.io/), [Metacran](https://www.r-pkg.org/)
- Packages in repositories ([CRAN](https://cran.r-project.org/), [BioConductor](https://www.bioconductor.org/), [Neuroconductor](https://neuroconductor.org/)) are peer-reviewed and often written by domain experts
- DIY: Build your own tools, build them together with others across the globe. It's fun! (e.g, [`{TextGrid}`](https://github.com/patrickreidy/textgRid), [`{rlena}`](https://github.com/HomeBankCode/rlena), [`{mifa}`](https://teebusch.github.io/mifa/), [`{noah}`](https://teebusch.github.io/noah/))

:::info
[**The Tidyverse**](https://www.tidyverse.org/) is a set of packages that share a common design philosophy. It aims to provide consistent user-friendly verb-based functions for common data-tasks and to iron out many of the ideosyncracies of *Base R*. It is a relatively recent addition to the R ecosystem and some people still prefer the latter. 

The **Tidy Data** that gives the Tidyverse its name has one variable per column and one observation per row (and nice variable names!). *Core idea:* once the data is in *tidy* format, all the tidyverse functions can be used seamlessly. The pipe `%>%` (see below) glues it all together.
:::
---

### :hammer_and_wrench: **Hands-on.** Install a package, load data from a file

Often you will read data files from external sources. For this example we will use [data from Tidy Tuesday](https://github.com/rfordatascience/tidytuesday/blob/master/data/2020/2020-09-22/readme.md`) and load it straight into our computer's memory from the web. The data is provided as a *CSV* file (comma separated value), a very common plain text format for sharing data across the internet.

To read a CSV file and turn it into a data frame we will use the `read_csv()` function. To use it, we first have to install the `{tidyverse}` package (if we haven't already) and then load it. Then we can read in the data and have a look at it with some of the other functions that were loaded with `{tidyverse}`.

```r
install.packages("tidyverse")
library(tidyverse)

peaks <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-22/peaks.csv')

# get an overview of the data
glimpse(peaks)
head(peaks)
view(peaks)

count(peaks, climbing_status)
```

:::info 
**Note.** [Excel is bad for sharing data!](https://www.theverge.com/2020/8/6/21355674/human-genes-rename-microsoft-excel-misreading-dates) Instead, use csv, json, [feather](https://blog.rstudio.com/2016/03/29/feather/), [databases](https://db.rstudio.com/databases/sqlite/), ...
:::

:::info
Usually, **packages** are collections of functions. The `{tidyverse}` package is a bit different, as it is actually a collection of packages --- a *meta-package*. When you load it, it loads, other packages, including `{ggplot2}`, `{readr}`, and `{dplyr}`. For example, the `read_csv()` function is from the `{readr}` package.
:::

---

## 6. R has powerful data wrangling tools

- Interface with all sorts of data sources - [Databases](https://db.rstudio.com/getting-started/connect-to-database/), [SPSS, Stata, SAS,...](https://haven.tidyverse.org/), [APIs](https://httr.r-lib.org/), [websites](https://rvest.tidyverse.org/)
- Work with all sorts of data -- Tabular data, EEG, fMRI, Eye tracking, Geodata...)
- [`{tidyverse}`](https://www.tidyverse.org/) and friends: Many convenience functions for tasks like splitting and merging columns, renaming stuff, counting things, ...
- Workhorse functions: `filter()`, `select()`, `mutate()`, `group_by()`, `summarize()`, `pivot_wider()`, `pivot_longer()`, `group_by()` and `summarize()` are very expressive
- Integrate with [Python](https://rstudio.github.io/reticulate/), [C](http://www.rcpp.org/), and other languages
- Interface with other software ([MPLUS](https://mclust-org.github.io/mclust/)), Computing Clusters, parallel computing, ...

---

### :hammer_and_wrench: **Hands-on.** Wrangling Data

The tidyverse package is very powerful! Let's try a simple data wrangling task: 

1. Find all peaks that are higher than 7,000 metres and were climbed before 1980  
2. Count which countries the climbers came from

We can use the `filter()` and `count()` functions for that:

```r
before80_7k <- filter(peaks, first_ascent_year < 1980, height_metres > 7000)
count(peaks, before80_7k)
```

#### The %>% operator ("pipe")

Above, we stored the result of the first function in an intermediate variables and then gave it to the second. There's another way to chain functions that is often more convenient and readable: Use the **pipe operator `%>%`** to pass data from one function to the next. 

You can read `%>%` as *"...and then..."*. Use the keyboard shortcut <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>M</kbd> to make it.

```r
peaks %>%
  filter(first_ascent_year < 1980, height_metres > 7000) %>% 
  count(first_ascent_country, sort = TRUE) %>% 
  filter(n > 3) 
  # ... the pipe can continue. Here, we filter all peaks that 
  # were climbed more than 3 times
```

Did you notice that the first argument of all functions (the data frame you want to operate on) has disappeared? The pipe operator fills that one in automatically.

![](https://i.imgur.com/bIyqtxz.jpg)
*Indubitably, sir!*

#### Other useful data wrangling functions

- Use `select()` to select variables (columns) from a data frame
- Use `mutate()` to create new variables in the data frame or change existing ones 
- Use `group_by()` and `summarize()` for powerful *split-apply-combine* operations

```r
peaks %>% 
  select(peak_name, climbing_status, first_ascent_year, first_ascent_country) %>% 
  mutate(climbed_before80 = first_ascent_year < 1980)

peaks %>% 
  filter(first_ascent_year > 201) %>% 
  group_by(first_ascent_country) %>% 
  summarise(min_ascent = min(first_ascent_year, na.rm = TRUE)) %>% 
  arrange(min_ascent)
```

---

## 7. Powerful statistical methods at your fingertips 

There are many different packages and often multiple packages for the same kind of analysis. Best to ask a domain expert what they use (or Google). Here are just a few examples:

- Many basic stats built into base R (`glm()`, `chisq.test()` and many more)
- GLM, [GAM](https://noamross.github.io/gams-in-r-course/), [HLM](https://github.com/lme4/lme4/), [Mixture Models](https://mclust-org.github.io/mclust/)...
- [SEM with `{lavaan}`](https://lavaan.ugent.be/)
- Robust stats with {WRS2}
- Time series with [`{forecast}`](https://github.com/robjhyndman/forecast) `{zoo}`, `{xts}`
- [Bayesian Statistics](https://github.com/rmcelreath/statrethinking_winter2019) with [`{brms}`](https://paul-buerkner.github.io/brms/), [`{rstanarm}`](https://mc-stan.org/rstanarm/), [`{rstan}`](https://mc-stan.org/users/interfaces/rstan)
- [Text mining with `{tidytext}`](https://www.tidytextmining.com/)
- [Machine learning with `{tidymodels}`](https://www.tidymodels.org/)
- [Network analysis](https://kateto.net/network-visualization) with `{tidygraph}` or `{igraph}`
- [Meta analysis](https://bookdown.org/MathiasHarrer/Doing_Meta_Analysis_in_R/) with `{metafor}` and `{rmeta}`

---

### :hammer_and_wrench: **Hands-on.** Statistical Modeling 

Many simple stats are built into R (no additional packages needed)...

```r
t.test()
lm()
```

---

## 8. R has powerful data visualisation tools

- Great data visualisation with [`{ggplot2}`](https://ggplot2.tidyverse.org/index.html) and friends -- see [examples from Tidy Tuesday](https://www.cedricscherer.com/top/dataviz/)
- [Plotly](https://plotly.com/r/), [Shiny](https://shiny.rstudio.com/gallery/) for interactive visualisations and dashboards
- Integration with [JavaScript (e.g., D3.js)](https://book.javascript-for-r.com/) - the sky is the limit!
- Use interactive visualisation as a [teaching tool with {learnR}](https://tinystats.github.io/teacups-giraffes-and-statistics/02_bellCurve.html)
- Coding is hard? Use GUIs like [`{esquisse}`](https://cran.r-project.org/web/packages/esquisse/vignettes/get-started.html)
- Bored of data vis? [Make generative Art!](https://www.data-imaginist.com/art)

---

###  :hammer_and_wrench: **Hands-on.** Data Visualization 

Perhaps the most popular package for data visualization in R is `{ggplot2}`. It comes with the `{tidyverse}` package.

```r
# ...
```

--- 

## 9. R encourages reproducible research

- RStudio Projects: portable, reproducible, self-contained, organized
- Code provides documentation & data provenance
- [Version control with Git](https://happygitwithr.com/) - a time machine for your analysis
- [`{targets}`](https://books.ropensci.org/targets/) - smart make-files for your analysis 
- [`{renv}`](https://rstudio.github.io/renv/articles/renv.html), "freeze" your development environment 
- [Docker with Rocker](https://www.rocker-project.org/) - fully reproducible data analysis in a Docker container (virtual machine)
- No more copy and paste!
    - Packages to make pretty APA [tables for models](http://www.danieldsjoberg.com/gtsummary/index.html), [summary](https://cran.r-project.org/web/packages/table1/vignettes/table1-examples.html) [stats](https://cran.r-project.org/web/packages/sjPlot/vignettes/tab_model_estimates.html), ...
    - Interface with Microsoft Office - Excel, Word, PowerPoint with [`{officeR}`](https://davidgohel.github.io/officer/)


#### Reproducible reports with RMarkdown

- [RMarkdown](https://bookdown.org/yihui/rmarkdown/) allows you to make 
    - reports 
    - papers with [`{papaja}`](https://github.com/crsh/papaja), [`{rticles}`](https://github.com/rstudio/rticles)
    - books with [`{bookdown}`](https://bookdown.org/)
    - websites, blogs with [`{blogdown}`](https://github.com/rstudio/blogdown), [`{hugodown}`](https://hugodown.r-lib.org/), [`{distill}`](https://rstudio.github.io/distill/)
    - slides with [`{xaringan}`](https://github.com/yihui/xaringan), [`{xaringanthemer}`](https://github.com/gadenbuie/xaringanthemer)
    - ... all from within R!
- [RMarkdown with parameters](https://rmarkdown.rstudio.com/lesson-6.html) for simple tools, recurring tasks/reports, ...

---

### :hammer_and_wrench: **Hands-on.** Make your Research Reproducible 

#### Use {renv} to 'freeze' your development environment

R changes quickly! Packages get updated frequently, and your analysis from a few years ago might suddenly not run anymore!? Save yourself the frustration by storing the 

```r
# ...
```

#### Save your project's state with Git

Organising your project as a self-contained RStudio project was only the first step to reproducibility. [Git](https://git-scm.com/) is to code what the :floppy_disk: is to a Word document (but better). 

Git allows you to...

- store the state of your project 
- see changes you or others have made
- create parallel versions of your code and merge them back together
- go back in time
- Safely collaborate with others on the same code
- and more 

[Learn to use Git](https://happygitwithr.com/), and use it often!

```r
# ...
```

#### Make a reproducible report with RMarkdown

In an *RMarkdown* document, you can mix text, R code, and the output of that R code. With the click of a button, you can turn this into a self-contained document (an HTML page, a PDF, a Word file) that you can share with others.

[You can use this to make websites, slides, or even write papers](https://rmarkdown.rstudio.com/lesson-1.html). And if a reviewer asks you to exclude a subject? Remove the data point and click the button again --- all the figures and stats update!  

```r
# ...
```
---

## 10. The R community is awesome!

The best way to learn R is to practice, practice, practice and find other people to practice with. R has a friendly, diverse and welcoming community.

- Don't be afraid to ask questions, make mistakes, or write bad code! Read other people's code!
- Widespread - always an R nerd nearby
- Twitter `#RStats` can help to keep track of all the new things (if you like Twitter ...)
- Participate in [Tidy Tuesday](https://github.com/rfordatascience/tidytuesday) or [Makeover Monday](https://www.makeovermonday.co.uk/)
- [Join Meetups of R User Group Oslo](https://www.meetup.com/Oslo-useR-Group/)
- Create your own R user group?

R is mainly used by non-computer scientists, hence lots of learning material for non-techy people (books, videos, podcasts, blog posts) -- amazingly, much of it is free!

#### Books, available for free online

- [Data Science in Education with R](https://datascienceineducation.com/)
- [R for Data Science Book](https://r4ds.had.co.nz/)
- [Introductory Statistics in Psychology using R](https://rpsystats.com/)
- [Introduction to Statistical Learning](https://www.statlearning.com/)
- [ggplot2 -- Elegant graphics for data analysis](https://ggplot2-book.org/)
- [Advanced R](https://adv-r.hadley.nz/index.html)

#### Free courses

- Datacarpentry material: [R for Social Sciences](https://datacarpentry.org/r-socialsci/) and [R for Ecologists](https://datacarpentry.org/R-ecology-lesson/)
- [Take a Carpentries R course at UiO](https://www.ub.uio.no/english/writing-publishing/dsc/carpentry-uio/)
- [A list of R Tutorials on YouTube](http://flavioazevedo.com/stats-and-r-blog/2016/9/13/learning-r-on-youtube)
- Check  Coursera and other MOOCs for free R courses


---

# That's it for now...

This concludes this short intro to R. We barely scratched the surface of what R has to offer --- I hope this made you want to learn more!
