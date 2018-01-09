args <- commandArgs(trailingOnly=TRUE)
pvalue <- 2*pt(as.double(args[1]), as.integer(args[2]), lower=FALSE)
print(pvalue, digits=3)
