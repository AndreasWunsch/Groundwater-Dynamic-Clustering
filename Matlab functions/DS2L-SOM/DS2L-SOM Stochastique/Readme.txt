DS2L-SOM version Stochastique


C = S2LD_SOM(Data,...)


Fonctionne sous Matlab(R).

Nécessite aussi la SOM Toolbox(C), qui peut être téléchargée gratuitement :
http://www.cis.hut.fi/projects/somtoolbox/about


Arguments obligatoires :

- Data : les données brutes ou le nom d'un fichier nom.data de format SOM Toolbox

Arguments optionnels :

- 'vote', 'add' ou 'freq' : défini l'affichage des labels (cf la doc de la SOM Toolbox)
- 'norm' : permet de normaliser les données
- 'ng' : visualisation de la segmentation de la carte
- 'umat' : visualisation des distances entre prototypes
- 'comp' : permet de visualiser les coordonnées des prototypes pour chaque composante
- 'data' : visualisation des données (en rouge) projeté en 2D par ACP avec et sans la projection des prototypes (en noir)
- 'den' : visualisation des étapes de la segmentation, affiche aussi la carte segmentée
- 'datacolorden' : visualisation des données projeté dans un espace de faible dimensions et colorés selon leur appartenance Ã  un cluster
- 'sammon' : utilise une projection de Sammon pour visualiser les prototypes et leurs connexions, la couleur des prototypes reflÃ¨te les différents clusters

Sorties : 

- C.ngconnect : valeurs associées aux connexions entre neurones voisins
- C.valclust : segmentation de la carte en utilisant uniquement les connexions (clusters bien séparés dans l'espace), les nombres positifs représentent différents clusters associés aux neurones, -1 indique un neurone qui n'appartient Ã  aucun cluster (il ne représentante aucune donnée).
- C.density : valeurs de densités associées Ã  chaque neurone
- C.denclust : segmentation finale de la SOM


Exemple d'utilisation :

C=S2LD_SOM('Exemple.data','ng','datacolorden','data','sammon');
