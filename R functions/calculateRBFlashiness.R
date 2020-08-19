#load data
gwdata <- read.csv("C:/Users/Andreas Wunsch/Workspace/01_Matlab/gwdata.txt", sep=";")

#calculate RBI
library(rwrfhydro)
RBI<-numeric(length(gwdata)-1)
for (i in 2:length(gwdata)){
  RBI[i-1] <- RBFlash(as.numeric(unlist(gwdata[i])), na.rm = TRUE)
}
#save results
write.table(RBI,file = "C:/Users/Andreas Wunsch/Workspace/01_Matlab/RBI.txt",row.names = FALSE,col.names = FALSE)

