#
# Copyright (C) 2018 University of Amsterdam
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# Main function ----
ClassicProcess <- function(jaspResults, dataset = NULL, options) {
  print("Hello World!")
  # Set title
  jaspResults$title <- "Process Analysis"
  # Init options: add variables to options to be used in the remainder of the analysis
  options <- .procInitOptions(jaspResults, options)
  # read dataset
  dataset <- .procReadData(options)
  # error checking
  ready <- .procErrorHandling(dataset, options)

  # Compute (a list of) results from which tables and plots can be created
  procResults <- .procComputeResults(jaspResults, dataset, options)

  # Output containers, tables, and plots based on the results. These functions should not return anything!
  mainContainer <- .procContainerMain(jaspResults, options, procResults)

  jaspSem:::.medPathPlot(jaspResults, options, ready)
  # .procTableSomething(jaspResults, options, procResults)
  # .procTableSthElse(  jaspResults, options, procResults)
  # .procPlotSomething( jaspResults, options, procResults)
  jaspResults[["plot"]]$dependOn(.procGetDependencies())

  return()
}

.procGetDependencies <- function() {
  return(c('dependent', 'covariates', 'factors', 'processModels'))
}

# Init functions ----
.procInitOptions <- function(jaspResults, options) {
  # Determine if analysis can be run with user input
  # Calculate any options common to multiple parts of the analysis
  model = options[["processModels"]][[1]]

  outcomes = sapply(model[["processRelationships"]], function(rel) rel[["processDependent"]])
  predictors = sapply(model[["processRelationships"]], function(rel) rel[["processIndependent"]])
  mediators = sapply(model[["processRelationships"]], function(rel) rel[["processMediatorModerator"]])

  options[["outcomes"]] <- encodeColNames(outcomes)
  options[["predictors"]] <- encodeColNames(predictors)
  options[["mediators"]] <- encodeColNames(mediators)

  options[["pathPlot"]] <- TRUE
  options[["pathPlotParameter"]] <- TRUE
  options[["pathPlotLegend"]] <- FALSE

  return(options)
}

.procReadData <- function(options) {
  # Read in selected variables from dataset
  vars <- lapply(c('dependent', 'covariates', 'factors'), function(x) options[[x]])
  dataset <- .readDataSetToEnd(columns = unlist(vars))
  return(dataset)
}

.procErrorHandling <- function(dataset, options) {
  # See error handling
  vars <- lapply(.procGetDependencies(), function(x) options[[x]])
  .hasErrors(dataset, "run", type = c('observations', 'variance', 'infinity'),
             all.target = vars,
             observations.amount = '< 2',
             exitAnalysisIfErrors = TRUE)

  return(TRUE)
}

# Results functions ----
.procComputeResults <- function(jaspResults, dataset, options) {
  # Function to compute and store results in container
  if (is.null(jaspResults[["stateProcResults"]])) {
    syntax = jaspSem:::.medToLavMod(options)
    procResults <- .procResultsHelper(dataset, options)
    jaspResults[["model"]] <- createJaspState(object = procResults, dependencies = .procGetDependencies())
  } else {
    procResults <- jaspResults[["model"]]$object
  }
  procResults
}

.procResultsHelper <- function(dataset, options) {
  # Helper function to compute actual results
  procResult <- lavaan::sem(
    model           = jaspSem:::.medToLavMod(options),
    data            = dataset,
    se              = "standard"
  )

  return(procResult)
}

# Output functions ----
# These are not in use for now, but left here as orientation for later
.procContainerMain <- function(jaspResults, options, procResults) {
  if (!is.null(jaspResults[["procMainContainer"]])) {
    mainContainer <- jaspResults[["procMainContainer"]]
  } else {
    mainContainer <- createJaspContainer("Model fit tables")
    mainContainer$dependOn(.procGetDependencies())
    
    jaspResults[["procMainContainer"]] <- mainContainer
  }

  return(mainContainer)
}

.procTableSomething <- function(jaspResults, options, procResults) {
  if (!is.null(jaspResults[["procMainContainer"]][["procTable"]])) return()

  # Below is one way of creating a table
  procTable <- createJaspTable(title = "proc Table")
  procTable$dependOnOptions(c("variables", "someotheroption")) # not strictly necessary because container

  # Bind table to jaspResults
  jaspResults[["procMainContainer"]][["procTable"]] <- procTable

  # Add column info
  procTable$addColumnInfo(name = "chisq",  title = "\u03a7\u00b2", type = "number", format = "sf:4")
  procTable$addColumnInfo(name = "pvalue", title = "p",            type = "number", format = "dp:3;p:.001")
  procTable$addColumnInfo(name = "BF",     title = "Bayes Factor", type = "number", format = "sf:4")
  procTable$addColumnInfo(name = "sth",    title = "Some Title",   type = "string")

  # Add data per column
  procTable[["chisq"]]  <- procResults$column1
  procTable[["pvalue"]] <- procResults$column2
  procTable[["BF"]]     <- procResults$column3
  procTable[["sth"]]    <- procResults$sometext
}

.procTableSthElse <- function(jaspResults, options, procResults) {
  if (!is.null(jaspResults[["procMainContainer"]][["procTable2"]])) return()
  
  # Below is one way of creating a table
  procTable2 <- createJaspTable(title = "proc Table Something Else")
  procTable2$dependOnOptions(c("variables", "someotheroption"))
  
  # Bind table to jaspResults
  jaspResults[["procMainContainer"]][["procTable2"]] <- procTable2
  
  # Add column info
  procTable2$addColumnInfo(name = "hallo", title = "Hallo", type = "string")
  procTable2$addColumnInfo(name = "doei",  title = "Doei",  type = "string")
  
  # Calculate some data from results
  procSummary <- summary(procResults$someObject)
  
  # Add data per column. Calculations are allowed here too!
  procTable2[["hallo"]] <- ifelse(procSummary$hallo > 1, "Hallo!", "Hello!")
  procTable2[["doei"]]  <- procSummary$doei^2
}

.procPlotSomething <- function(jaspResults, options, procResults) {
  if (!is.null(jaspResults[["procPlot"]])) return()

  procPlot <- createJaspPlot(title = "proc Plot", height = 320, width = 480)
  procPlot$dependOnOptions(c("variables", "someotheroption"))
  
  # Bind plot to jaspResults
  jaspResults[["procPlot"]] <- procPlot

  procPlot$plotObject <- plot(procResults$someObject)
}
