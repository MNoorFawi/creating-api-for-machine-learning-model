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
  d <- data.frame(diagnosis)
  lst <- list(results = d)
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


## another way to do the post method for diagnosis
# diagnosis <- predict(tree_model, data, type = 'class')
# d <- unbox(toJSON(data.frame(diagnosis)))
# lst <- list(diagnosis = d)
# return(lst)
#}

## this can go exactly the same way we did in command line to parse it,
## and with python we will use "ast.literal_eval(d['key'])
## before "pd.DataFrame(d)".

