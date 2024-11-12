library(shiny)
library(lubridate)
library(shinyjs)
library(bslib)

# Define UI
ui <- page_sidebar(
  tags$head(
    tags$link(rel = "stylesheet", href = "style.css"),
    tags$script(src = "custom.js"),
    useShinyjs(),
    tags$style(HTML("
      .shiny-textarea-input {
        width: 100% !important;
        height: 80vh !important;
        resize: none;
      }
    "))
  ),
  titlePanel("Internship Journal"),
  sidebar = sidebar(
    id = "main-sidebar",
    # sidebar title
    tags$h2(
      class = "sidebar-title",
      "Parameters"
    ),
    # sidebar position
    position = "left",
    # themes
    selectInput("theme_selector", "Themes",
                choices = c(
                  "Menthol" = "mint",
                  "Photosynthesis" = "forest",
                  "H2O" = "ocean",
                  "Phenolphthalein" = "sunset",
                  "Linalool" = "lavender",
                  "Citric acid cycle" = "citrus",
                  "Zooxanthellae" = "coral",
                  "Anthocyanin" = "berry",
                  "Phototropism" = "spring",
                  "Stratosphere" = "sky",
                  "Argentum" = "silver"
                ),
                selected = "Menthol"
    ),
    fileInput("file_upload", "Attach Files", multiple = TRUE),
    actionButton("submit", "Submit")
  ),
  
  fluidPage(
    textAreaInput("journal_entry", "Journal Entry", value = "Hello World", width = "100%", height = "400px"),
    textOutput("confirmation")
  )
)

# Define server logic
server <- function(input, output) {
  observeEvent(input$submit, {
    # set theme
    observe({
      theme <- input$theme_selector
      js <- sprintf("document.documentElement.setAttribute('data-theme', '%s');", theme)
      shinyjs::runjs(js)
    })
    
    # Get the current date
    current_date <- Sys.Date()
    day <- sprintf("%02d", day(current_date))
    month <- sprintf("%02d", month(current_date))
    year <- year(current_date)
    
    # Create month folder if it doesn't exist
    month_folder <- file.path(year, month, day)
    if (!dir.exists(month_folder)) {
      dir.create(month_folder, recursive = TRUE)
    }
    
    # Create the filename
    filename <- sprintf("Journal-%s-%s-%s.txt", day, month, year)
    filepath <- file.path(month_folder, filename)
    
    # Write the journal entry to the file
    writeLines(input$journal_entry, con = filepath)
    
    # Save the attached files if they exist
    if (!is.null(input$file_upload)) {
      for (i in 1:nrow(input$file_upload)) {
        file_path <- file.path(month_folder, input$file_upload$name[i])
        file.copy(input$file_upload$datapath[i], file_path)
      }
    }
    
    # Display confirmation message
    output$confirmation <- renderText({
      paste("Journal entry and files saved to:", month_folder)
    })
  })
}

# Run the application 
shinyApp(ui = ui, server = server)