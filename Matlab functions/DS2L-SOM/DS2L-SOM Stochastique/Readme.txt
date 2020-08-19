DS2L-SOM version Stochastique


C = S2LD_SOM(Data,...)


Fonctionne sous Matlab(R).

N�cessite aussi la SOM Toolbox(C), qui peut �tre t�l�charg�e gratuitement :
http://www.cis.hut.fi/projects/somtoolbox/about


Arguments obligatoires :

- Data : les donn�es brutes ou le nom d'un fichier nom.data de format SOM Toolbox

Arguments optionnels :

- 'vote', 'add' ou 'freq' : d�fini l'affichage des labels (cf la doc de la SOM Toolbox)
- 'norm' : permet de normaliser les donn�es
- 'ng' : visualisation de la segmentation de la carte
- 'umat' : visualisation des distances entre prototypes
- 'comp' : permet de visualiser les coordonn�es des prototypes pour chaque composante
- 'data' : visualisation des donn�es (en rouge) projet� en 2D par ACP avec et sans la projection des prototypes (en noir)
- 'den' : visualisation des �tapes de la segmentation, affiche aussi la carte segment�e
- 'datacolorden' : visualisation des donn�es projet� dans un espace de faible dimensions et color�s selon leur appartenance à un cluster
- 'sammon' : utilise une projection de Sammon pour visualiser les prototypes et leurs connexions, la couleur des prototypes reflète les diff�rents clusters

Sorties : 

- C.ngconnect : valeurs associ�es aux connexions entre neurones voisins
- C.valclust : segmentation de la carte en utilisant uniquement les connexions (clusters bien s�par�s dans l'espace), les nombres positifs repr�sentent diff�rents clusters associ�s aux neurones, -1 indique un neurone qui n'appartient à aucun cluster (il ne repr�sentante aucune donn�e).
- C.density : valeurs de densit�s associ�es à chaque neurone
- C.denclust : segmentation finale de la SOM


Exemple d'utilisation :

C=S2LD_SOM('Exemple.data','ng','datacolorden','data','sammon');
