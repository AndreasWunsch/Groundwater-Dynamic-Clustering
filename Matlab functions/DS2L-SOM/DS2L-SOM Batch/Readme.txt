DS2L-SOM version BATCH


C=BS2L_SOM(Data,sM,...)


Fonctionne sous Matlab(R).

Nécessite aussi la SOM Toolbox(C), qui peut être téléchargée gratuitement :
http://www.cis.hut.fi/projects/somtoolbox/about


Arguments obligatoires :

- Data : les données brutes
- sM : une structure SOM obtenue avec la SOM Toolbox à partir des donnée data

Arguments optionels :

- 'vote', 'add' ou 'freq' : défini l'affichage des labels (cf la doc de la SOM Toolbox)
- 'norm' : à ajouter si la SOM à été entraînée sur des données normalisés (permet de normaliser les données)
- 'data' : visualisation des données (en rouge) projeté en 2D par ACP avec et sans la projection des prototypes (en noir)
- 'den' : visualisation des étapes de la segmentation, affiche aussi la carte segmentée
- 'datacolorden' : visualisation des données projeté dans un espace de faible dimensions et colorés selon leur appartenance à un cluster
- 'sammon' : utilise une projection de Sammon pour visualiser les prototypes et leurs connexions, la couleur des prototypes reflète les différents clusters

Sorties : 

- C.ngconnect : valeurs associées aux connexions entre neurones voisins
- C.valclust : segmentation de la carte en utilisant uniquement les connexions (clusters bien séparés dans l'espace), les nombres positifs représentent différents clusters associés aux neurones, -1 indique un neurone qui n'appartient à aucun cluster (il ne représentante aucune donnée).
- C.density : valeurs de densités associées à chaque neurone
- C.denclust : segmentation finale de la SOM


Exemple d'utilisation :

%% Apprentissage de la SOM avec la SOM Toolbox
sD = som_read_data('Exemple.data');
sM = som_make(sD);

%% Segmentation de la SOM avec S2L_SOM 
C=BS2L_SOM(sD.data,sM,'den','datacolorden','data','sammon');
