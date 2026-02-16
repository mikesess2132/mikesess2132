# Load Survey Ratings from Conjoint Compact Data
# ------------------------------------------------

# Read the raw rating data from the conjoint survey CSV
rating_raw <- read.csv("Conjoint_Compact.csv", header = TRUE)

# Choose only the nine columns with rating data and convert to matrix
rating <- as.matrix(rating_raw[, 2:10])

# Read a matrix of dummy variables that describe specification of each profile
X_raw <- read.csv("Design_Matrix.csv", header = TRUE)
