class Fichier extends SimpleMapItem {
  // Objet répertoire parent
  Repertoire parent;
  // Objet file fichier
  File fichier;

  // Niveau en valeur entière
  int niveau;

  // Différentes valeurs réelles pour par exemple la valeur de la couleur ou la teinte
  float sp; 
  float gauche, haut, droite, bas;
  float teinte;
  float valeur;
  float luminosite;

  // Chaine de caractères pour le nom du dossier/fichier
  String nom;

  // Couleur c
  color c;
  
  /* Constructeur de la classe Fichier qui fait appel à la classe Repertoire */

  Fichier(Repertoire parent, File fichier, int niveau, int ordre) {
    this.parent = parent;
    this.fichier = fichier;
    this.order = ordre;
    this.niveau = niveau;
    nom = fichier.getName();
    size = fichier.length();
  }

  void draw() {
    // On calcule les dimensions du bloc pour le fichier/dossier
    calcBoite();
    /* On applique une luminosité si ou non on est avec la souris sur le bloc du fichier/dossier
      => but de l'exercice 5.2 : pouvoir voir plus facilement le répertoire courant
      où se trouve la souris */
    if (contientSouris()) {
      luminosite = 150;
    } else {
      luminosite = 255;
    }
    // On applique la couleur 'c' ainsi que la luminosité
    fill(c, luminosite);
    // on dessine le bloc du fichier/dossier avec les dimensions obtenus avec la fonction calcBoite
    rect(gauche, haut, droite, bas);
    // Si le bloc est assez grand pour afficher le titre du fichier/dossier alors on l'affiche
    if (assezGrand()) {
      dessineTitre();
    } else if (contientSouris()) {
      courant = this;
    }
  }
  
  /* Fonction qui calcule la taille de la boite d'un fichier/dossier */

  void calcBoite() {
    gauche = x;
    haut = y;
    droite = x + w;
    bas = y + h;
  }
  
  /* Fonction qui dessine le titre du fichier/dossier avec une différente façon en fonction
    de si oui ou non on est avec la souris sur le bloc du fichier/dossier
    => but de l'exercice 5.2 : pouvoir voir plus facilement le répertoire courant
    où se trouve la souris */

  void dessineTitre() {
    textAlign(LEFT);
    if (!contientSouris()) {
      textFont(font);
      fill(255, 200);
      text(nom, gauche + sp, bas + sp);
    } else {
      textFont(fontActive);
      fill(0, 200);
      float tailleTexte = textAscent() - textDescent();
      text(nom, gauche + (droite-gauche)/2 - textWidth(nom)/2, haut + (bas-haut)/2 + tailleTexte/2);
    }
  }
  
  /* Fonction qui met à jour les couleurs des blocs des fichiers/dossiers,
    elle règle la couleur d'un élément en fonction de la couleur de son parent */

  void majCouleurs() {
    if (parent != null) {
      teinte = map(order, 0, parent.getItemCount(), 0, 360);
    }
    valeur = random(20, 80);
    colorMode(HSB, 360, 100, 100);
    if (parent == racine) {
      c = color(teinte, 80, 80);
    } else if (parent != null) {
      c = color(parent.teinte, 80, valeur);
    }
    colorMode(RGB, 255);
  }

  /* Fonction pour déterminer sur oui ou non le bloc est assez grand
   (on utilisera cette fonction pour l'affichage du titre du fichier/dossier) */
   
  boolean assezGrand() {
    float largeur = textWidth(nom) + sp*2;
    float hauteur = textAscent() + textDescent() + sp*2;
    return ((droite - gauche) > largeur) && ((bas-haut) > hauteur);
  }

  /* Fonction pour déterminer sur oui ou non le bloc contient la souris */
  
  boolean contientSouris() {
    return (mouseX > gauche && mouseX < droite && mouseY > haut && mouseY < bas);
  }
  
  /* Fonction pour l'action lors du clic avec la souris
    (on ouvre le dossier sur lequel on clique (donc on affiche
    ses fils et on cache donc le parent) */

  boolean mousePressed() {
    if (contientSouris()) {
      if (mouseButton == RIGHT) {
        parent.cacheLeContenu();
        return true;
      }
    }
    return false;
  }
}
