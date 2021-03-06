#details can be found in the readme file

p_impute <- function(geno_file, out_format) {
if (!out_format %in% c("coma", "space")) {
  stop("Only coma or space delimitation allowed for the output file. If other options
       are preffered, the function can be easily be modified")
}

#read genotype file and remove the first 6 columns
data_full <- read.table(geno_file, header = T)
data <- data_full[,-c(1:6) ]

#calculate probabilities of the three genotypes for each column (SNP)
n <- nrow(data)
p_0 <- apply(data, 2, function(x){sum(x == 0, na.rm = T)/(n - sum(is.na(x)))})
p_1 <- apply(data, 2, function(x){sum(x == 1, na.rm = T)/(n - sum(is.na(x)))})
p_2 <- apply(data, 2, function(x){sum(x == 2, na.rm = T)/(n - sum(is.na(x)))})
p <- data.frame(p_0, p_1, p_2)

#make sure the probalilities add up to one so that it won't be a problem for the sampling function
p <- t(apply(p, 1, function(x){x/sum(x)}))

#make a table for indices of missing genotypes
NA_indices <- which(is.na(data), arr.ind = T)

#replace missing genotypes by sampling from (0,1,2) based on probabilities given in table p
for (i in 1:nrow(NA_indices)) {
  x <- NA_indices[i, ]
  data[x[1], x[2]] <- sample(c(0:2), 1, replace = T, prob = p[x[2], ])
}

#bind the first 6 columns to the imputed data
data <- cbind(data_full[, 1:6], data)

#write output file
if (out_format == "coma") {
write.csv(data, "geno_imputed.csv", row.names = F, quote = F)
  } else {write.table(data, "geno_imputed.txt", row.names = F, quote = F)}
return(data)
}
