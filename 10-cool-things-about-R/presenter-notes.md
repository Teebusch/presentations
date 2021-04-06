![](https://i.imgur.com/QThpLod.png)


# 10 Cool Things About R


**Tobias Busch** 
06/04/2021 ISP ComPros Meeting at UiO 
90 minutes

(*Speaker notes / handout*)

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

### I'm assuming...

- No real programming experience 
- Not particularly interested in computers or programing
- You are curiouse because you want to get things done and R might help you

---

## What will we do

- 90 minutes - *brief* introduction to R
- Provide motivation for learning R (or for not learning R)
- Learn 10 cool things about R
- Hands-on mini data analysis demo to demonstrate the power of R

*(If I forget: remind me to take a break...)*

### Take aways

- Is R for you?
- basic data wrangling, modeling, data visualization
- How to continue learning?

---

## What is R

- A domain specific programming language?
- An environment for interactive data analysis [that *has* a programming language](https://youtu.be/6S9r_YbqHy8) 
- Built with interactive data analysis in mind - a really fancy calculator
- More than in most other languages, data and stats are *first-class citizens*
- (most ?) popular statistical programming environment, used in academia (bioinformatics, geoscience, digital humanities) and industry (finance, pharmaceutical, ...)
- Versatile & Powerful - Can be your *one-stop-shop* for the whole data science workflow: Data collection, Data cleaning, transformation, visualisation, modeling, reporting / communicating [(and beyond...)](https://youtu.be/m6nUdoP6894)

> **Sidenote:** Many people use [**RStudio**](https://www.rstudio.com/products/rstudio/) to work with **R**. RStudio is an Integrated Development Environment (*IDE*) that provides a convenient user interface for working with R.

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

---

## Why *not* learn R?

- Considerable time investment - Coding needs practice! 
- Depending on previous experience, steep learning curve (and even if you are an experienced programmer - [R can be weird](https://youtu.be/6S9r_YbqHy8))
- Pays off when doing lots of analyses, complex data transformation,... if you only do one or two small things, it may not be worth it.
- Never change a winning team -- If your current setup works for you, don't change it!
- You may actually prefer commercial software like SPSS, SAS, MATLAB (customer support, usually "one right way" to do things, less "agony of choice")
- Not all methods may be implemented in R (e.g., handling missing data with Maximum Likelihood in MPlus, not available in R's MClust)
- There are good code-free alternatives to R, even free ones, for example...
  - Stats with [Jamovi](https://www.jamovi.org/), [JASP](https://jasp-stats.org/)
  - DataVis with [RAWgraphs](https://rawgraphs.io/), [Flourish](https://flourish.studio/)
  
> **Sidenote.** Coding is a valuable skill; Knowing weird languages can pay off. It can also be a lot of fun. Once mastered, the *expressiveness* of programming is unmatched by any point-and-click tool. 

---

## 1. R is Free and Open Source

- Trying it won't hurt!
- Less bureaucracy, easier collaboration and sharing
- Can use everywhere

## 2. It's Easy to get started

- Install [R](https://www.r-project.org/)
- Install [RStudio](https://www.rstudio.com/products/rstudio/)
- Alternatively: [rstudio.cloud](https://rstudio.cloud/)
- Install [`{tidyverse}`](https://www.tidyverse.org/) package - ready to rock!
- RStudio - All-in-one programming environment (IDE) has you covered

## 3. Flexible language  that Grows with you

- allows many different programming paradigms.
- grows with your needs - start easy, ramp up complexity as you 
- Allows some crazy stuff that's impossible in other languages
- [Tidyverse](https://www.tidyverse.org/) - Consistent verb-based functions with user-friendly APIs (cf. "base R")
- Most people don't need to worry about many of the "standard" programming stuff - conditionals, iteration, OOP, ...


#### Demo - R Programming 101

- *A brief overview of the RStudio GUI*
- Create an RStudio Project and a script file
- console vs. scripts
- Run commands / individual lines using <kbd>Ctrl</kbd> + <kbd>Enter</kbd>

```r
# Assigning variables and playing around with them
x <- "Hello World!"
x

# boolean
a <- TRUE
b <- FALSE

c(1,2,3,4)

c(1, 2, 3, 4) * 10

mean(c(1,2,3,4))

data.frame("first" = c(1,2,3,4), "second" = c(2,4,5,6))

# We will use data from Tidy Tuesday: 
# https://github.com/rfordatascience/tidytuesday/blob/master/data/2020/2020-09-22/readme.md`

install.packages("tidyverse")
library(tidyverse)

peaks <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-22/peaks.csv')

# get an overview of the data
glimpse(peaks)
head(peaks)
view(peaks)

count(peaks, climbing_status)

# A simple data wrangling task: 
# Find all peaks that are higher than 7k and climbed before 1980, 
# then count which countries climbers came from

# One way to chain functions: use intermediate variable
climbed_before80_higher_7k <- filter(peaks, first_ascent_year < 1980, height_metres > 7000)
count(peaks, climbed_before80_higher_7k)

# More convenient and readable: use the pipe operator %>% (Ctrl + Shift + M)
# read as '...and then...'
peaks %>%
  filter(first_ascent_year < 1980, height_metres > 7000) %>% 
  count(first_ascent_country, sort = TRUE) %>% 
  filter(n > 3) # ... the pipe can continue, e.g., filter nations with >3 ascents

# Use `mutate` to create new variables in the data set or change existing ones 
peaks %>% 
  select(peak_name, climbing_status, first_ascent_year, first_ascent_country) %>% 
  mutate(climbed_before80 = first_ascent_year < 1980)

# Use `group_by()` and `summarize()` for powerful split-apply-combine
peaks %>% 
  filter(first_ascent_year > 201) %>% 
  group_by(first_ascent_country) %>% 
  summarise(min_ascent = min(first_ascent_year, na.rm = TRUE)) %>% 
  arrange(min_ascent)

# simple stats are built into R...
t.test()
lm()
```

- variables / objects (naming conventions!), assignment with `<-` (Keyboard Shortcut: <kbd>Alt</kbd>+<kbd>-</kbd>)
- data types (numbers, characters, NA - a special data type for missing data)
- boolean (`TRUE`, `FALSE`)
- vectors, lists, objects, data frames/tibbles
- functions, e.g. `c()`, `mean()`, ...
- packages are a collection of functions
- The PIPE `%>%` to connect functions in a more readable way (Keyboard Shortcut: <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>M</kbd>)

---

## 4. R has great documentation

- Documentation is easy to access, well-written, comprehensive -- helps to learn the basics
- Use <kbd>F1</kbd> to access the help file for anything
- RStudio has excellent fuzzy auto-complete while you type
- Cheat sheets (RStudio Menu: `Help > Cheatsheets > ...`)
- package vignettes and package websites are often well written
- Everything is open source so you can read the code...
- Google, [StackOverflow](https://stackoverflow.com/questions/tagged/r), [RStudio Community](https://community.rstudio.com/)
- Lots of blogs with Tutorials
- Twitter `#RStats` helps to keep track of things, and answers questions. 

---

## 5. R is Expandable 

- Part of the open source advantage: lots of packages!
- The R package ecosystem is a candy store for stats and productivity tools. see [rdrr.io](https://rdrr.io/), [Metacran](https://www.r-pkg.org/)
- Packages on repositories are peer reviewed ([CRAN](https://cran.r-project.org/), [BioConductor](https://www.bioconductor.org/), [Neuroconductor](https://neuroconductor.org/)) and often written by domain experts
- DIY: Build your own tools, build them together with others across the globe (`{TextGrid}`, `{rLENA}`, `{mifa}`, `{noah}`)

---

## 6. Powerful data wrangling

- Interface with all sorts of data sources - [Databases](https://db.rstudio.com/getting-started/connect-to-database/), [SPSS, Stata, SAS,...](https://haven.tidyverse.org/), [APIs](https://httr.r-lib.org/), [websites](https://rvest.tidyverse.org/)
- Work with all sorts of data -- Tabular data, EEG, fMRI, Eye tracking, Geodata)
- [`{dplyr}`](https://dplyr.tidyverse.org/)'s workhorse functions: `filter()`, `select()`, `mutate()`, `group_by()`, `summarize()`, `pivot_wider()`, `pivot_longer()` are very expressive
- powerful "split apply combine" paradigm with `group_by()` and `summarize()`
- [`{tidyverse}`](https://www.tidyverse.org/) and friends: Many convenience functions for tasks like splitting and merging columns, renaming stuff, counting things, ...
- Integrate with [Python](https://rstudio.github.io/reticulate/), [C](http://www.rcpp.org/), and other languages
- Interface with other software ([MPLUS](https://mclust-org.github.io/mclust/)), Computing Clusters, parallel computing, ...

> **Sidenote: Tidy Data**
> 
> - *Core idea:* once the data is in *tidy* format, all the tools can be used fluently.
> - one variable by column, one observation by row (and nice variable names!)
> - The pipe `%>%` glues it all together
> - [Excel is bad for storing data!](https://www.theverge.com/2020/8/6/21355674/human-genes-rename-microsoft-excel-misreading-dates) Better: csv, json, [feather](https://blog.rstudio.com/2016/03/29/feather/), [databases](https://db.rstudio.com/databases/sqlite/), ...

---

## 7. Powerful statistical methods at your fingertips 

- Many basic stats built in (`glm()`, `chisq.test()` and many more)
- GLM, [GAM](https://noamross.github.io/gams-in-r-course/), [HLM](https://github.com/lme4/lme4/), [Mixture Models](https://mclust-org.github.io/mclust/)...
- [SEM with `{lavaan}`](https://lavaan.ugent.be/)
- time series with [`{forecast}`](https://github.com/robjhyndman/forecast) `{zoo}`, `{xts}`
- [Bayesian Statistics](https://github.com/rmcelreath/statrethinking_winter2019) with [`{brms}`](https://paul-buerkner.github.io/brms/), [`{rstanarm}`](https://mc-stan.org/rstanarm/), [`{rstan}`](https://mc-stan.org/users/interfaces/rstan)
- [Text mining with `{tidytext}`](https://www.tidytextmining.com/)
- [Machine learning with `{tidymodels}`](https://www.tidymodels.org/)
- network analysis
- meta analysis
- ...

Many different packages and often multiple packages for the same kind of analysis. Best to ask a domain expert what they use (or Google...).

---

## 8. Powerful flexible data visualisation

- Great data visualisation with [`{ggplot}`](https://ggplot2.tidyverse.org/index.html)- see [examples from Tidy Tuesday](https://www.cedricscherer.com/top/dataviz/))
- [Plotly](https://plotly.com/r/), [Shiny](https://shiny.rstudio.com/gallery/) for interactive visualisations and dashboards
- integration with [JS, D3, ...](https://book.javascript-for-r.com/) - the sky is the limit
- [Make generative Art](https://www.data-imaginist.com/art)
- Use as a [teaching tool with {learnR}](https://tinystats.github.io/teacups-giraffes-and-statistics/02_bellCurve.html)
- Too much? Use GUIs like [`{esquisse}`](https://cran.r-project.org/web/packages/esquisse/vignettes/get-started.html)

--- 

## 9. Encourages reproducible research

- RStudio Projects: portable, reproducible, self-contained, organized
- Code provides documentation & data provenance
- [Version control with Git](https://happygitwithr.com/) - a time machine for your analysis
- [`{renv}`](https://rstudio.github.io/renv/articles/renv.html), "freeze" environment 
- [`{targets}`](https://books.ropensci.org/targets/) - make-files for your analysis. 
- [Docker with Rocker](https://www.rocker-project.org/) - fully reproducible data analysis in a Docker container (virtual machine)

#### Reproducible reports with RMarkdown

- [RMarkdown](https://bookdown.org/yihui/rmarkdown/), make 
    - reports
    - papers [`{papaja}`](https://github.com/crsh/papaja), [`{rticles}`](https://github.com/rstudio/rticles)
    - books [`{bookdown}`](https://bookdown.org/)
    - websites, blogs with [`{blogdown}`](https://github.com/rstudio/blogdown), [`{hugodown}`](https://hugodown.r-lib.org/), [`{distill}`](https://rstudio.github.io/distill/)
    - slides with [`{xaringan}`](https://github.com/yihui/xaringan), [`{xaringanthemer}`](https://github.com/gadenbuie/xaringanthemer)
    - ... all from within R!
- [RMarkdown with parameters](https://rmarkdown.rstudio.com/lesson-6.html) for simple tools, recurring tasks/reports, ...
- Make pretty APA [tables for models](http://www.danieldsjoberg.com/gtsummary/index.html), [summary](https://cran.r-project.org/web/packages/table1/vignettes/table1-examples.html) [stats](https://cran.r-project.org/web/packages/sjPlot/vignettes/tab_model_estimates.html), ... No more copy and paste!
- Interface with Microsoft Office - Excel, Word, PowerPoint with [`{officeR}`](https://davidgohel.github.io/officer/)

--- 

## 10. Awesome Community

- R is mainly used by non-computer scientists, hence lots of great learning material
- Friendly, diverse and welcoming community
- Free and open learning material -- great books, videos, podcasts
- Widespread - always an R nerd nearby

---

## How to learn more?

### Books

- [Data Science in Education with R](https://datascienceineducation.com/)
- [R for Data Science Book](https://r4ds.had.co.nz/)
- [Introductory Statistics in Psychology using R](https://rpsystats.com/)
- [Introduction to Statistical Learning](https://www.statlearning.com/)
- [Advanced R](https://adv-r.hadley.nz/index.html) *(Warning: It's advanced!)*

### Free courses

- Datacarpentry material: [R for Social Sciences](https://datacarpentry.org/r-socialsci/) and [R for Ecologists](https://datacarpentry.org/R-ecology-lesson/)
- [Take a Carpentries R course at UiO](https://www.ub.uio.no/english/writing-publishing/dsc/carpentry-uio/)
- [A list of R Tutorials on YouTube](http://flavioazevedo.com/stats-and-r-blog/2016/9/13/learning-r-on-youtube)

### More

- Remember the [R Studio cheat sheets](https://www.rstudio.com/resources/cheatsheets/)
- Twitter `#RStats` can help to keep track of all the new things (if you like Twitter ...)
- Participate in [Tidy Tuesday](https://github.com/rfordatascience/tidytuesday) or [Makeover Monday](https://www.makeovermonday.co.uk/)
- [Join Meetups of R User Group Oslo](https://www.meetup.com/Oslo-useR-Group/)
- *Create an ISP R user group?*