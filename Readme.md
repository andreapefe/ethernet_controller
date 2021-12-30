<center> <h1> <b> Conception Controlleur Ethernet sur Vivado en VHDL </b> </h1> </center>

<center> <h3> Léa Scheer et Andrea Pérez </h3>
Groupe TP1 - 4AE-SE
</center>

## Fichier Ethernet.vhd
Nous avons conçu notre code de façon à avoir au total 5 processus synchrone qui s'exécutent simultanément dans notre contrôleur ethernet à chaque front montant de clock:
- **Deux processus de compteur de clock** Deux processus de compteur de clock : un pour la transmission et un pour la réception. Le compteur pour la transmission se déclenche dès qu’il y a des données à envoyer (tavailp à ‘1’) et de forme analogue le compteur pour la réception démarre quand il y a des données à lire (renabp à ‘1’). Ils ont aussi une variable etat qui leur permet de savoir s'ils viennent de démarrer pour ne pas compter juste 7 fronts au lieu de 8 lors de la première boucle.
-   **Un processus qui gère la réception** avec un compteur interne qui lui aide à se repérer à quel niveau du message nous nous situons.
-   **Un processus qui gère la transmission** avec aussi une variable qui nous indique s’il la transmission avait déjà commencé pour lever le signal tdonep seulement en fin de transmission et pas chaque fois que tavailp passe en ‘0’.
-   **Un processus qui vérifie s’il y a collision** en regardant si les signaux renabp et tavailp sont levés en même temps. Il passe alors tsocolp à ‘1’ aussi bien que le signal intern tcollision pour pouvoir le lire dans le processus de transmision.


## Fichier test_reception.vhd

Initialement, nous déclenchons la Clock et désactivons le Reset au bout de 200ns comme indiqué dans la doc.

#### Bonne trame réception

Dans un premier temps nous réalisons une réception de trame correcte à savoir avec un bon début et une bonne fin (X”AB”), la bonne adresse MAC et une donnée correcte. A la fin de la bonne réception, le signal rdonep s’active.


#### Mauvaise trame réception

On teste ensuite la réception d’une mauvaise trame à savoir avec une mauvaise adresse MAC et un mauvais début de trame. Nous observons alors
Nous testons ensuite le cas où la trame n’a pas la bonne longueur (elle est trop courte). Ceci déclenche également le ‘rcleanp’ indiquant une mauvaise lecture de la donnée.

#### Collision réception transmission

On commence par une “petite” collision qui dure sur 4 essais.
Nous activons le “tavailp” en même temps que le “renabp”, donc on essaye à la fois de lire une donnée et d’en transmettre une. Tous les signaux passent alors à 0 et le signal ‘tsocolp’ passe à 1 jusqu’à ce que ‘renabp’ se remette à 0. Pendant toute cette durée, la data transmise est passée à 0 jusqu’au 5ème essai ou tsocolp est repassé à 0 et la donnée peut être transmise.
Ensuite nous réalisons une collision qui dure sur plus de 15 essais ce qui active le signal tdonep indiquant la fin de transmission.


#### Bonne trame transmission

Le signal ‘tavailp’ est actif depuis la collision, puis nous attribuons à ‘tdatai’ la bonne trame à transmettre. La transmission s’effectue correctement et une fois terminée le signal ‘tdonep’ s’active, indiquant la bonne transmission de trame.

#### Transmission interrompue

Lorsque l’on active le signal ‘tfinishp’, cela interrompt la transmission jusqu’à ce que ce dernier revienne à 0 (visible  à 75µs). Une fois désactivé la transmission reprend de façon normale.
Nous simulons finalement une mauvaise transmission en activant le signal ‘tabortp’ ce qui interrompt la transmission au top d’horloge suivant. Une fois qu’il repasse à ‘0’ la transmission s’effectue à nouveau.


## Résultats de la synthèse

#### Fréquence maximale de fonctionnement
Les spécifications étaient d’avoir une clock à 100ns, et **le ‘slack’ est de 94.163ns** (temps requis - temps d’arrivée qui a une valeur positive ici), ce qui signifie que l’on pourrait fonctionner à une période d’horloge de 100ns - 94.163ns et que la simulation fonctionnerait aussi. Ainsi la fréquence maximale est de :
1/(T-WNS) = 1/((100-94.163)10^-9)= 171, 321 MHz. 



#### Nombre de portes et bascules
Les portes logiques sont appelées LUT dans le rapport de synthèse (LookUp Tables) reproduit ci-dessous. Celles qui nous intéressent sont les portes logiques (LUT as Logic) qui sont au nombre de **109** ici. Il indique aussi le nombre de bascules (Flip-Flop) nécessaires à l’implémentation du circuit. Dans notre cas, nous avons besoin de **72 bascules**.

![Extrait du papport de synthèse](/gates.jpg "Titre de l'image").

#### Consommation de puissance

La consommation (en puissance) peut se lire sur le rapport suivant qui estime la puissance consommée à partir de la netlist décrivant le circuit électrique implémenté. Ici nous lisons **0.071W** pour la puissance total.

![Schéma réaprtition de la consommation de puissance ](/power_consumption.jpg "Titre de l'image").
