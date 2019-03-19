#!/usr/local/bin/Rscript

task <- dyncli::main()

library(jsonlite)
library(readr)
library(dplyr)
library(purrr)

library(reCAT)

#   ____________________________________________________________________________
#   Load data                                                               ####

expression <- task$expression
params <- task$params

#   ____________________________________________________________________________
#   Infer trajectory                                                        ####

# TIMING: done with preproc
checkpoints <- list(method_afterpreproc = as.numeric(Sys.time()))

# run reCAT
result <- reCAT::bestEnsembleComplexTSP(
  test_exp = expression,
  TSPFold = params$TSPFold,
  beginNum = params$beginNum,
  endNum = params$endNum,
  base_cycle_range = seq(params$base_cycle_range[1], params$base_cycle_range[2]),
  step_size = params$step_size,
  max_num = params$max_num,
  clustMethod = params$clustMethod,
  threads = 1,
  output = FALSE
)

# TIMING: done with method
checkpoints$method_aftermethod <- as.numeric(Sys.time())

pseudotime <- result$ensembleResultLst[dim(result$ensembleResultLst)[1], ] %>% set_names(rownames(expression))

#   ____________________________________________________________________________
#   Save output                                                             ####

output <- dynwrap::wrap_data(cell_ids = names(pseudotime)) %>%
  dynwrap::add_cyclic_trajectory(pseudotime = pseudotime) %>%
  dynwrap::add_timings(checkpoints)

dyncli::write_output(output, task$output)
