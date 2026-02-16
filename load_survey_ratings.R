# Load Survey Ratings from Conjoint Compact Data
# ------------------------------------------------

# Read the raw rating data from the conjoint survey CSV
rating_raw <- read.csv("Conjoint_Compact.csv", header = TRUE)

# Inspect the structure and summary of the data
str(rating_raw)
summary(rating_raw)

# Display the first few rows
head(rating_raw)

# Check dimensions
cat("Number of observations:", nrow(rating_raw), "\n")
cat("Number of variables:", ncol(rating_raw), "\n")

# Convert categorical variables to factors
rating_raw$brand <- as.factor(rating_raw$brand)
rating_raw$price <- as.factor(rating_raw$price)
rating_raw$size <- as.factor(rating_raw$size)
rating_raw$color <- as.factor(rating_raw$color)

# Summary after factor conversion
cat("\nData structure after factor conversion:\n")
str(rating_raw)

# Check rating distribution
cat("\nRating distribution:\n")
table(rating_raw$rating)
