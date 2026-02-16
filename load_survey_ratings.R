# Load Survey Ratings from Conjoint Compact Data
# ------------------------------------------------

# Read the raw rating data from the conjoint survey CSV
rating_raw <- read.csv("Conjoint_Compact.csv", header = TRUE)

# Choose only the nine columns with rating data and convert to matrix
rating <- as.matrix(rating_raw[, 2:10])

# Read a matrix of dummy variables that describe specification of each profile
X_raw <- read.csv("Design_Matrix.csv", header = TRUE)

# Convert to matrix, excluding the "Profile" column
XD <- as.matrix(X_raw[, 2:10])

## Prepare data to run HB Regression and obtain partworths for each participant
nreg <- length(rating[, 1]) # number of observations
nz <- 1
nvar <- 9 # number of partworths to be estimated
nrating <- 9 # number of rating tasks

regdata <- NULL
for (i in 1:nreg) {
  M.x <- XD # read dummy variables plus an intercept
  ytmp <- matrix(c(0), nrating, 1)
  ytmp <- rating[i, ] # read rating data for each participant
  regdata[[i]] <- list(y = ytmp, X = M.x)
}
individualz <- matrix(0, nrow = nreg, ncol = nz)
individualz[, 1] <- rep(1, nreg)

## Prepare data to run regression to obtain one set of partworths across all participants
nnvar <- nvar + 2
newdata <- matrix(c(0), nreg * nrating, nnvar)
for (i in 1:nreg) {
  begin <- ((i - 1) * nrating) + 1
  end <- ((i - 1) * nrating) + nrating
  ind <- begin:end
  ynew.tmp <- t(rating[i, ])
  ynew <- t(ynew.tmp)
  newdata[ind, 1] <- rating_raw[i, 1]
  newdata[ind, 2] <- ynew
  newdata[ind, 3:nnvar] <- M.x
}
newdata <- as.data.frame(newdata)
colnames(newdata)[1] <- "PID"
colnames(newdata)[2] <- "Rating"
colnames(newdata)[3] <- "Intercept" # each name partworth
colnames(newdata)[4] <- "Ford"
colnames(newdata)[5] <- "Toyota"
colnames(newdata)[6] <- "Fuel43"
colnames(newdata)[7] <- "Fuel54"
colnames(newdata)[8] <- "HEV"
colnames(newdata)[9] <- "PHEV"
colnames(newdata)[10] <- "Pr15500"
colnames(newdata)[11] <- "Pr19000"

## Run the multiple linear regression model to obtain aggregate partworths across all participants
## You don't need to explicitly add the intercept column in here. The intercept will be estimated automatically.
reg.compact <- lm(Rating ~ Ford + Toyota + Fuel43 + Fuel54 + HEV + PHEV + Pr15500 + Pr19000, data = newdata)
summary(reg.compact) # print out the result

## Run the Hierarchical Bayes regression model to obtain different sets of partworths for different participants
# You need to call these special libraries to perform HB regression
install.packages("bayesm") # you may need to install bayesm package before you can call it from your library
library(bayesm)
library(MASS)
Data1 <- NULL
Data1 <- list(regdata = regdata, Z = individualz)
Mcmc1 <- list(R = 20000, keep = 10)
out <- rhierLinearModel(Data = Data1, Mcmc = Mcmc1)

nvar <- 9 # number of partworths
burnout <- 1000:2000
betai <- matrix(c(0), nreg, nvar)
betabar <- matrix(c(0), nvar, burnout)
for (i in 1:nreg) {
  betai[i, ] <- apply(out$betadraw[i, , burnout], 1, mean)
}

dim(rating_raw) # check the number of variables in the original data set (65)
rating_new <- cbind(rating_raw, round(betai, digit = 3)) # add participants' part-worths back to the "rating_raw" dataframe
colnames(rating_new)[66] <- "Intercept" # each name partworth
colnames(rating_new)[67] <- "Ford"
colnames(rating_new)[68] <- "Toyota"
colnames(rating_new)[69] <- "Fuel43"
colnames(rating_new)[70] <- "Fuel54"
colnames(rating_new)[71] <- "HEV"
colnames(rating_new)[72] <- "PHEV"
colnames(rating_new)[73] <- "Pr15500"
colnames(rating_new)[74] <- "Pr19000"

write.csv(rating_new, file = "Conjoint_Compact_Partworths.csv") # write out a new data file with participant-level partworths
