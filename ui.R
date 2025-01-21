library(shiny)

# Define UI
ui <- fluidPage(
  titlePanel("Interactive Conformal Prediction for Blood Pressure"),
  sidebarLayout(
    sidebarPanel(
      tabsetPanel(
        tabPanel("Controls",
                 sliderInput("age_range", "Age Range:", min = 18, max = 80, value = c(18, 80)),
                 sliderInput("exercise", "Time Spent Exercising (Hours/Week):", min = 0, max = 20, value = 5, step = 1),
                 sliderInput("noise", "Noise Level (SD):", min = 0.1, max = 10, value = 5, step = 0.1),
                 selectInput("model_type", "Model Type:", 
                             choices = c("Linear", "Quadratic", "Cubic")),
                 sliderInput("alpha", "Confidence Level (1 - Alpha):", min = 0.8, max = 0.99, value = 0.95),
                 actionButton("generate", "Generate Data")
        ),
        tabPanel("About Me",
                 h4("About This App"),
                 p("This app demonstrates interactive conformal prediction for blood pressure data."),
                 p("It allows users to explore the impact of factors like age and exercise on blood pressure."),
                 p("Created by: [Your Name]"),
                 p("Contact: your.email@example.com"),
                 p("Version: 1.0")
        )
      )
    ),
    mainPanel(
      plotOutput("predictionPlot"),
      tableOutput("modelMetrics")
    )
  )
)
