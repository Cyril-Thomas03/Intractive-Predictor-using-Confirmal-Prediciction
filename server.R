library(shiny)
library(ggplot2)

# Define Server
server <- function(input, output, session) {
  # Reactive data generation
  data <- eventReactive(input$generate, {
    age <- seq(input$age_range[1], input$age_range[2], length.out = 200)
    noise <- rnorm(200, sd = input$noise)
    exercise_factor <- input$exercise
    blood_pressure <- switch(input$model_type,
                             "Linear" = 120 + 0.5 * age - 1.5 * exercise_factor + noise,
                             "Quadratic" = 120 + 0.5 * age - 0.01 * age^2 - 1.5 * exercise_factor + noise,
                             "Cubic" = 120 + 0.5 * age - 0.01 * age^2 + 0.0001 * age^3 - 1.5 * exercise_factor + noise)
    data.frame(age = age, blood_pressure = blood_pressure)
  })
  
  # Conformal prediction
  conformal <- function(data, model_type, alpha) {
    model_formula <- switch(model_type,
                            "Linear" = blood_pressure ~ age,
                            "Quadratic" = blood_pressure ~ age + I(age^2),
                            "Cubic" = blood_pressure ~ age + I(age^2) + I(age^3))
    fit <- lm(model_formula, data = data)
    residuals <- abs(data$blood_pressure - predict(fit))
    threshold <- quantile(residuals, 1 - alpha)
    predictions <- predict(fit, newdata = data)
    data.frame(age = data$age, lower = predictions - threshold, upper = predictions + threshold, fit = predictions)
  }
  
  # Render plot
  output$predictionPlot <- renderPlot({
    df <- data()
    conf <- conformal(df, input$model_type, 1 - input$alpha)
    ggplot(df, aes(x = age, y = blood_pressure)) +
      geom_point(alpha = 0.6) +
      geom_line(data = conf, aes(x = age, y = fit), color = "blue") +
      geom_ribbon(data = conf, aes(x = age, ymin = lower, ymax = upper), alpha = 0.2, fill = "blue") +
      labs(title = paste("Conformal Prediction for", input$model_type, "Model"),
           x = "Age (Years)", y = "Blood Pressure (mmHg)")
  })
  
  # Render model metrics
  output$modelMetrics <- renderTable({
    df <- data()
    fit <- lm(switch(input$model_type,
                     "Linear" = blood_pressure ~ age,
                     "Quadratic" = blood_pressure ~ age + I(age^2),
                     "Cubic" = blood_pressure ~ age + I(age^2) + I(age^3)), 
              data = df)
    data.frame(
      Model = input$model_type,
      R2 = summary(fit)$r.squared,
      MSE = mean(residuals(fit)^2)
    )
  })
}