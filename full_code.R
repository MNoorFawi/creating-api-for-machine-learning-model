data <- read.table('diagnosis.data', fileEncoding="UTF-16", dec=",")
names(data) <- c('temperature', 'nausea', 'lumbar_pain',
                 'urine_pushing', 'micturition_pain', 
                 'burning_swelling_urethra', 'd1', 'd2')

diagnosis <- factor(ifelse(
  data$d1 == 'no' & data$d2 == 'no', 'none', 
  ifelse(data$d2 == 'yes' & data$d1 == 'yes', 'both',
         ifelse(data$d1 == 'yes' & data$d2 == 'no',
                'urinary', 'nephritis'))))

data$diagnosis <- diagnosis
data <- data[, -c(7:8)]
head(data)
str(data)

library(reshape)
library(ggplot2)
ggplot(data, aes(x = temperature, fill = diagnosis)) + 
  geom_density(alpha = 0.6, color = 'white', size = 0.5) +
  scale_fill_brewer(palette = 'Set1') +
  theme_minimal() +
  facet_wrap(~ diagnosis, ncol = 1)

melted <- melt(data[, -1], id.vars = 'diagnosis')
ggplot(melted, aes(x = diagnosis, fill = value)) + 
  geom_bar(position = 'dodge', color = 'black') + 
  facet_wrap(~ variable) + 
  scale_fill_brewer(palette = 'Pastel1') + 
  theme(legend.position = c(0.8, 0.2)) 

library(rpart)
library(rpart.plot)
tree_model <- rpart(diagnosis ~ ., data = data)
tree_pred <- predict(tree_model, newdata = data, type = 'class')
## measuring model accuracy
mean(tree_pred == data$diagnosis)
## plotting the model
rpart.plot(tree_model)

save(tree_model, file = 'tree_model.RData')

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

library(plumber)
r <- plumb('tree_api.R')
r$run(port = 8080)

