#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

required_packages <- c(
    "dotenv",
    "RPostgreSQL",
    "shiny",
    "DT"
)

# install or load dependencies
for (package in required_packages) {
    if (!require(package, character.only = TRUE)) {
        install.packages(package, repos = "http://cran.us.r-project.org")
        library(package, character.only = TRUE)
    }
}

# Load environmental variables
load_dot_env()
host <- Sys.getenv("POSTGRES_HOST")
port <- Sys.getenv("POSTGRES_PORT")
dbname <- Sys.getenv("POSTGRES_DB")
user <- Sys.getenv("POSTGRES_USER")
password <- Sys.getenv("POSTGRES_PASSWORD")


# Read in data from database
drv <- dbDriver("PostgreSQL")
con <- dbConnect(
    drv = drv,
    host = host,
    port = port,
    dbname = dbname,
    user = user,
    password = password
)
table_names <- c(
    "master",
    "timelog",
    "title",
    "posting",
    "reporting"
)
data_set <- list()
for (table_name in table_names) {
    query <- sprintf("SELECT * FROM %s;", table_name)
    results <- dbGetQuery(con, query)
    data_set[[table_name]] <- as.data.frame(results)
}

# close the connection
dbDisconnect(con)
dbUnloadDriver(drv)


# UI component
ui <- navbarPage(
    "Revelio Labs",
    tabPanel(
        "GHR Data",
        sidebarLayout(
            sidebarPanel(
                uiOutput("select"),
                uiOutput("check"),
                textInput(
                    "job_id",
                    "Job ID:",
                    value = "",
                    placeholder = "(e.g. 1111111111)"
                ),
                downloadButton("download", "Download as TSV"),
                width = 2
            ),
            mainPanel(DT::dataTableOutput("records"), width = 10)
        )
    )
)

# Server componenet
server <- function(input, output) {
    datatable_input <- reactive({
        dt <- data_set[[input$table]][, input$fields]
        if (input$job_id != "") {
            dt <- dt[dt$job_id == input$job_id, ]
        }
        return(dt)
    })

    output$select <- renderUI({
        selectInput(
            "table",
            "Select a Table:",
            choices = names(data_set)
        )
    })

    output$check <- renderUI({
        fields <- names(data_set[[input$table]])
        checkboxGroupInput(
            "fields",
            "Choose a Field(s):",
            choices = fields,
            selected = fields,
        )
    })

    output$download <- downloadHandler(
        file_name <- function() {
            paste(input$table, ".tsv", sep = "")
        },
        content <- function(file) {
            write.table(
                datatable_input(), file, sep = "\t", row.names = FALSE
            )
        }
    )

    output$records <- DT::renderDataTable({
        datatable_input()
    }, options = list(pageLength = 25))
}

# Bind UI and server to an application
shinyApp(ui = ui, server = server)
