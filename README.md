# Groundwater-Dynamic-Clustering
doi:
doi of according publication: XXXX - will be added once published

This repository should enable you to reproduce the dynamic-based Groundwater-Hydrograph clustering method proposed in: 
*Wunsch, A., Liesch, T., Broda, S., Feature-based Groundwater Hydrograph Clustering using unsupervised Self-Organizing-Map-Ensembles (submitted)*

*Contact: andreas.wunsch@kit.edu *

*ORCIDs of authors:*
*A.Wunsch: 0000-0002-0585-9549*
*T.Liesch: 0000-0001-8648-5333*
*S.Broda: 0000-0001-6858-6368*

For a detailed description of the workflow, please refer to the publication.
Please adapt all absolute loading/saving and software paths within the scripts to make them running, you need Matlab and R software for  a successful application.
Please note that our SOM-Clustering Technique can also be replaced by a CLustering TEchnique of your choice (e.g. k-means, HC-clustering)
# Content Overview:
* /01_Workflow_Preselection_and_Optimiziation
These scripts should be used for Feature preselection after a visual skill test of the explanatory power of the respective features, as well to optimize the Cluster-Algorithm Parameters. This is a iterative Process and once completed, the following will be used for the Ensemble-Modelling-Workflow:
-List of selected Features
-Cluster Parameters: SOM-size, NTH, DR, DM

* /02_Workflow_EnsembleModelling
These scripts are intended to use after the Preselection and optimization Step is done. 
Please adapt the scripts to the selected features, the chosen Cluster Parameters and also please adapt all absolute loading/saving and software paths within the scripts to make them running. 

* /Matlab functions/ClusterPack-V1.0
Third party scripts by Alexander Strehl, originally from: http://strehl.com/soft.html

* /Matlab functions/RunLength_2017_04_08
Third party scripts by Jan Simon, originally from: https://mathworks.com/matlabcentral/fileexchange/41813-runlength

* /Matlab functions/barvalues
Third party scripts by Elimelech Schreiber, originally from: https://mathworks.com/matlabcentral/fileexchange/64963-barvalues-h-precision?s_tid=FX_rc2_behav

* /Matlab functions/Consensus Voting
Third party scripts by Andrey Shestakov, originally from: https://github.com/shestakoff/consensus/

* /Matlab functions/DS2L
Third party scripts and modifications. Original scripts (folders: DS2L-SOM Batch, DS2L-SOM Stochastique) are written by Guenael Cabanes (see also: Cabanes, G., Bennani, Y., & Fresneau, D. (2012). Enriched topological learning for cluster detection and visualization. Neural Networks, 32, 186–195. https://doi.org/10/f3z7z8)

* /Matlab functions/
all other functions are written by Andreas Wunsch (2019) under the specified MIT license.

* /R functions
You will need the Hydrostats Package v.	0.2.7 (https://cran.r-project.org/web/packages/hydrostats/index.html) by Nick Bond (2019) and the ClusterCrit package 	v1.2.8 (https://cran.r-project.org/web/packages/clusterCrit/index.html) by 	Bernard Desgraupes (2018) to make these short scripts running. 
