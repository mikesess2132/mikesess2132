# Load Survey Ratings from Conjoint Compact Data
# ------------------------------------------------

# Read the raw rating data from the conjoint survey CSV
rating_raw <- read.csv("Conjoint_Compact.csv", header = TRUE)

# Choose only the nine columns with rating data and convert to matrix
rating <- as.matrix(rating_raw[, 2:10])
