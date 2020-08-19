#load data from Matlab path
gwdata <- read.csv("./gwdata.txt", sep=";")

#calculate RBI
library(rwrfhydro)
RBI<-numeric(length(gwdata)-1)
for (i in 2:length(gwdata)){
  RBI[i-1] <- RBFlash(as.numeric(unlist(gwdata[i])), na.rm = TRUE)
}
#save results on Matlab path
write.table(RBI,file = "./RBI.txt",row.names = FALSE,col.names = FALSE)

