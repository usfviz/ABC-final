# Data-viz project
# Alice Zhao, Valentin Vrzheshch
# shiny::runGitHub('ABC-final', 'usfviz')

rm(list = ls())
cat("\014")

library(shiny)
library(googleVis)
library(treemap)
library(d3treeR)
library(shinydashboard)

df_sankey <- read.csv("df_sankey.csv", stringsAsFactors = FALSE)
df_map    <- read.csv("df_map.csv",    stringsAsFactors = FALSE)
df_tree   <- read.csv("df_tree.csv",   stringsAsFactors = FALSE)

non_countries <- c("World", "Extra-trade", "Other Africa", "Other Europe", "Other Asia", "Africa", "Europe", "ACP (Africa, Caribbean and Pacific Countries)", "Africa, CIS and Middle East", "Andean Community", "American Samoa", "APEC (Asia-Pacific Economic Cooperation)", "Aruba (the Netherlands with respect to)", "Asia", "Asia excluding Hong Kong re-exports", "Asia less JPN,ANZ,CHN,NICS4, IN", "Australia and New Zealand", "BRIC members", "BRICS members", "CACM (Central American Common Market)", "CARICOM (Caribbean Community)",  "CEMAC (Economic and Monetary Community of Central Africa)", "Chinese Taipei", "COMESA (Common Market for Eastern and Southern Africa)", "Commonwealth of Independent States (CIS)", "Czech and Slovak Fed. Rep., former", "Developing and Emerging Economies", "ECCAS (Economic Community of Central African States)", "ECOWAS (Economic Community of West African States)", "EFTA (European Free Trade Association)", "Europe (Indices only)", "Europe excluding EU(28) intra-trade", "European Union (12)", "European Union (15)", "European Union (27)", "European Union (28)", "Four East Asian traders", "French Southern and Antarctic Territory", "French Guiana", "French Polynesia", "G20 - Developed Economies", "G20 - Developed Economies excl EU", "G20 - Developing economies", "G20 Members", "G20 Members exc. EU incl.FR, DE,IT,UK", "GCC (Gulf Co-operation Council)", "German Dem. Rep., former", "LDC (Least developed countries)", "LDC exporters of agriculture", "LDC exporters of manufactures", "LDC oil exporters", "MERCOSUR (Southern Common Market)", "Middle East", "NAFTA (North American Free Trade Agreement)", "Netherlands Antilles", "North America", "SADC (Southern African Development Community)", "SAFTA (South Asian Free Trade Agreement)", "South Africa", "South America excluding Brazil", "South and Central America", "Switzerland (Excl. Gold)", "WAEMU (West African Economic and Monetary Union)", "World", "World (only indices- excluding HK RX and CH Gold)", "World excluding EU(28) intra-trade", "WTO Members 2015", "WTO Members 2015 Incl. HK RX", "Developing Asia excluding Hong Kong re-exports", "ASEAN (Association of South East Asian Nations)",'Other CIS (CIS11)')
non_countries_2 <- paste0(non_countries,' ')
     
ui <- dashboardPage(
    dashboardHeader(title = "World Trade"),
    dashboardSidebar(
      sidebarMenu(id = "sidebarmenu",
        menuItem("Sankey Plot", tabName = "sankey", icon = icon("exchange")),
        conditionalPanel("input.sidebarmenu === 'sankey'",
                         radioButtons("radio.left", "Left:", c("Countries" = "Countries", "Regions" = "Regions"), selected="Countries"),
                         radioButtons("radio.right", "Right:", c("Countries" = "Countries", "Regions" = "Regions"), selected="Regions")
          ),
        menuItem("Map", tabName = "globe", icon = icon("globe")),
        conditionalPanel("input.sidebarmenu === 'globe'",
                         radioButtons("radio.globe", "Flow Type:", c("Exports"="Exports", "Imports"="Imports")),
                         selectInput("ind.globe", "Indicator:", unique(df_map$Indicator_description))
          ),
        menuItem("Tree Map", tabName = "treemap", icon = icon("columns")),
        sliderInput("year", "Year", min = min(df_map$Year), max = max(df_map$Year), value = max(df_map$Year)-4, animate = TRUE, step = 1, sep = "")
      )
    ),
    dashboardBody(
      tabItems(
        tabItem(tabName = "sankey",  htmlOutput("sankey.plot")),
        tabItem(tabName = "treemap", d3tree2Output("d3tree",height=600, width=800)),
        tabItem(tabName = "globe",   htmlOutput("map"))
      )
    )
  )
  

server <- function(input, output) {
  sub_df_map <- reactive({ df_map[df_map$Year == input$year &
                                  df_map$Flow_Description == input$radio.globe &
                                  df_map$Indicator_description == input$ind.globe, ]})
  
  sub_df_tree <- reactive({df_tree[df_tree$Year == input$year, ]})

  sub_df_sankey <- reactive({
    df_sankey_year <- df_sankey[df_sankey$Year == input$year, 
                                c('Reporter_description','Partner_description','Value')]
    if (input$radio.left == "Countries"){
      df_sankey_left <- df_sankey_year[! (df_sankey_year$Reporter_description %in% non_countries), ]
    } else {
      df_sankey_left <- df_sankey_year[(df_sankey_year$Reporter_description %in% non_countries), ]
    }

    if (input$radio.right == "Countries"){
      df_sankey_right <- df_sankey_left[! (df_sankey_left$Partner_description %in% non_countries_2), ]
    } else {
      df_sankey_right <- df_sankey_left[(df_sankey_left$Partner_description %in% non_countries_2), ]
    }
    return(df_sankey_right)
    })

  output$map <- renderGvis({
    map <- gvisGeoChart(sub_df_map(), 
                        locationvar="Reporter_code",
                        hovervar = "Reporter_description",
                        colorvar='Value',
                        options=list(projection="kavrayskiy-vii", 
                                    displayMode="regions",  height = 600, width = 900,
                                    colorAxis="{colors: ['orange']}"
                                    )
                        )
          return(map)
    })

  output$sankey.plot <- renderGvis({
    gvisSankey(sub_df_sankey(), from="Reporter_description", to="Partner_description", weight="Value",
               options = list(height = 600, width = 900,
                              sankey="{link:{color:{fill:'lightblue', stroke: 'black', strokeWidth: .1}}}")
              )
    })

  output$d3tree <- renderD3tree2({
    m <- sub_df_tree()
    tm <- treemap(
      m, #m[1:200, ] for fast rendering
      index=c("Reporter_description", "Flow_Description", "Indicator_description"),
      vSize="Value", palette="-RdGy", fontsize.legend = 9,
      format.legend = list(scientific = FALSE, big.mark = " "))
    d3tree2(tm, rootname = "International Trade")
  })
}

shinyApp(ui, server)