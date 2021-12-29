<script type="text/javascript" id="MathJax-script" async
  src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js">
</script>

<center> <h1> <b> Conception Controlleur Ethernet sur Vivado en VHDL </b> </h1> </center>

<center> <h3> Léa Scheer et Andrea Pérez </h3>
Groupe TP1 - 4AE-SE
</center>

## Fichier Ethernet.vhd
Nous avons conçu notre code de façon à avoir au total 5 processus synchrone qui s'exécutent simultanément dans notre contrôleur ethernet à chaque front montant de clock:
- **Deux processus de compteur de clock** pour la transmission et la réception. Le compteur pour la transmission se déclenche dès qu’il y a des données à envoyer (tavailp à ‘1’) et de forme analogue le compteur pour la réception démarre quand il y a des données à lire (renabp à ‘1’). Ils ont aussi une variable etat qui leur permet de savoir s'ils viennent de démarrer pour pas compter juste 7 fronts au lieu de 8 lors de la première boucle.
-   **Un processus qui gère la réception** avec un compteur interne qui lui aide à se repérer à quel niveau du message nous nous situons.
-   **Un processus qui gère la transmission** avec aussi une variable qui nous indique s’il la transmission avait déjà commencé pour lever le signal tdonep seulement en fin de transmission et pas chaque fois que tavailp passe en ‘0’.
-   **Un processus qui vérifie s’il y a collision** en regardant si les signaux renabp et tavailp sont levés en même temps. Il passe alors tsocolp à ‘1’ aussi bien que le signal intern tcollision pour pouvoir le lire dans le processus de transmision.


## Fichier test_reception.vhd

Initialement, nous déclenchons la Clock et désactivons le Reset au bout de 200ns. (indiqué par la doc je crois)

##### Bonne trame de reception

Dans un premier temps nous réalisons une réception de trame correcte à savoir avec un bon début et une bonne fin (X”AB”), la bonne adresse MAC et une donnée correcte.

##### Collision réception transmission

Ensuite nous simulons une collision puisque nous activons le “tavailp” en même temps que le “renabp”, donc on essaye à la fois de lire une donnée et d’en transmettre une. Tous les signaux passent alors à 0 et le “rcleanp” se déclenche.

##### Mauvaise trame réception

On teste ensuite la réception d’une mauvaise trame à savoir avec une mauvaise adresse MAC et un mauvais début de trame. Nous observons alors …
Nous testons ensuite le cas où la trame n’a pas la bonne longueur (elle est trop courte). Ceci déclenche également le ‘rcleanp’ indiquant une mauvaise lecture de la donnée.

##### Bonne trame transmission

Le signal ‘tavailp’ est actif depuis la collision, puis nous attribuons à ‘tdatai’ la bonne trame à transmettre. La transmission s’effectue correctement et une fois terminée le signal ‘tdonep’ s’active, indiquant la bonne transmission de trame.

##### Mauvaise trame transmission

Signal ‘tfinishp’...
Nous simulons finalement une mauvaise transmission en activant le signal ‘tabortp’ ce qui interrompt la transmission au top d’horloge suivant. Une fois qu’il repasse à ‘0’ la transmission s’effectue à nouveau.

## Résultats de la synthèse

##### Fréquence maximale de fonctionnement
Les spécifications étaient d’avoir une clock à 100ns, et le ‘slack’ est de 94.163ns (valeur positive), ce qui signifie que l’on pourrait fonctionner à une période d’horloge de 100ns - 94.163ns et que la simulation fonctionnerait aussi. Ainsi la fréquence maximale est de
\[
\frac 1(100-94.163)e-6=171 321
\]
