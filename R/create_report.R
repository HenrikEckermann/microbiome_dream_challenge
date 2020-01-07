library(glue)

# This function creates an a report that can be viewed on github
create_report <- function(
  task, 
  feature_name, 
  classifier, 
  k = 10, 
  p = 0.8, 
  seed = 4) {
    
    plain_text <- glue("---\noutput: md_document\n---\n\n```{r setup, include=FALSE}\nlibrary(knitr)\nopts_chunk$set(echo = TRUE, message = FALSE)\n```\n\n### Model: {{task}-{{feature_name}-{{classifier}-k={{k}-p={{p}\n\n```{r}\nlist_object <- fit_and_evaluate(\n\t\"IBD_vs_nonIBD\",\n\t\"species\",\n\t\"XGBoost\",\n\tk = 10,\n\tp = 0.8,\n\tseed = 4)\n```\n### Logloss\n\n```{r}\nkable(list_object$logloss)\nlist_object$logloss_plot\n```\n\n### Confusion matrices per k-fold\n```{r}\nmap(list_object$confusion_matrix, ~kable(.x))\n```\n", .open = "{{")
    path <- glue(here("data/output/{task}_{classifier}_{feature_name}_{k}_{p}.Rmd"))
    output <- file(path)
    writeLines(plain_text, output)
    rmarkdown::render(path)
    file.remove(path)
  }