library(jsonlite)
library(plumber)
## load the model
load('tree_model.RData')

## writing a POST request, we can write get request with the same syntax

#* @post /diagnose
diagnose <- function(
  temperature, nausea, lumbar_pain, urine_pushing,
  micturition_pain, burning_swelling_urethra) {
  data <- list(
    temperature = temperature, nausea = nausea,
    lumbar_pain = lumbar_pain, urine_pushing = urine_pushing,
    micturition_pain = micturition_pain,
    burning_swelling_urethra = burning_swelling_urethra
  )
  diagnosis <- predict(tree_model, data, type = 'class')
  d = unbox(toJSON(data.frame(diagnosis)))
  lst <- list(diagnosis = d)
  return(lst)
}

#* @get /vimp
vimp <- function(){
  importance <- round(tree_model$variable.importance, 2)
  variable <- names(importance)
  varimp <- data.frame(variable, importance)
  rownames(varimp) <- NULL
  list(varimp)
}

