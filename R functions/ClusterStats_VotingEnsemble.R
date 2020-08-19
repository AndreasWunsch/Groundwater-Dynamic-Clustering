start_time <- Sys.time()
library(readr)

#load data from Matlab path
features_z <- read_csv("./features_z_forR.txt", 
                       col_names = FALSE)
clusters <- read.table(file = "./02_Ensemble_voting_bestFeatureConfig.txt",
                       header = FALSE, sep = ",", dec = ".")

fz<-data.matrix(features_z)


library(clusterCrit)
clustering <- clusters#[,c(1:100)]

library(parallel)
# Calculate the number of cores
no_cores <- detectCores() - 1 #-1 helps not to freeze the PC

# Initiate cluster
cl <- makeCluster(no_cores)

#send function and data to workers
clusterExport(cl, list("intCriteria","fz"))

#calc. Indices
evaluation <- parLapply(cl, clustering, function(X)
  intCriteria(fz,as.integer(X),c("cal","McC","PBM","Rat","c_i"))
)
stopCluster(cl)

# melt results
library(reshape2)
meltedlist<-melt(evaluation)
ml<-meltedlist$value

#save to text
write(ml,file = "./R_ClusterVal_stats_votingEnsemble.txt") #please adapt this path to your matlab directory, but do not change the file name

end_time <- Sys.time()
end_time - start_time
