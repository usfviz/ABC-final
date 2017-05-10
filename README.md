# Data Visualization project

##Team
#### Alice Zhao :panda_face:, Valentin Vrzheshch :coffee:

Run gently in R:

_shiny::runGitHub('ABC-final', 'usfviz')_

or you can find the deployed app hosted at https://alicezhao.shinyapps.io/abc-final/

##Dataset 
The data is world trade data taken from WTO. The initial data is from 1946-2020.
However, there were a lot of missing values in the early years. Also, the speed of running the app was quite slow with too many years. 
As a result, we omitted the rows that had missing values and ended up with data starting from 2000.

##Packages
* `shiny`
* `googleVis`
* `treemap`
* `d3treeR`
* `shinydashboard`


