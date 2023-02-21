FloatTable donnees;

Integrator[] interp;

// Valeurs pour les données min et max
float donneeMin, donneeMax;

// Valeurs pour les axes
float traceX1, traceY1, traceX2, traceY2;

// Valeurs pour les légendes des axes
float axeX, axeY;

// Valeur pour la largeur d'une barre de l'histogramme
float histogrammeLargeur;

// Le nombre de lignes
int nbLigne;
// Le nombre de colonnes
int nbColonne;

// La colonne de données actuellement utilisée
int colonneCourante = 0;
int modeActuel = 1;

// Valeurs pour les années, les années min et max
int anneeMin, anneeMax;
int[] annees;

// L'intervalle d'années
int intervalleAnnees = 10;
// L'intervalle des volumes
int intervalleVolume = 10;
int intervalleVolumeMineur = 5;

float[] tabLeft, tabRight;
float tabTop, tabBottom;
float tabPad = 10;

// La police de caractères
PFont police;

// Les couleurs
color couleurFond, couleurCourbe, couleurTitre, couleurTexte;

void setup() {
  size(720, 405);

  donnees = new FloatTable("lait-the-cafe.tsv");

  // Le nombre de lignes
  nbLigne = donnees.getRowCount();
  // Le nombre de colonnes
  nbColonne = donnees.getColumnCount(); 

  // Valeurs des données min et max
  donneeMin = 0;
  donneeMax = ceil(donnees.getTableMax() / intervalleVolume) * intervalleVolume;

  // Valeurs des années, des années min et max
  annees = int(donnees.getRowNames());
  anneeMin = annees[0];
  anneeMax = annees[annees.length - 1];

  // Faire interpoler les données
  interp = new Integrator[nbLigne];
  for (int ligne = 0; ligne < nbLigne; ligne++) {
    float valeur = donnees.getFloat(ligne, 0);
    interp[ligne] = new Integrator(valeur);
    interp[ligne].attraction = 0.1;
  }

  // Valeurs pour la zone du graphe
  traceX1 = 120;
  traceY1 = 60;
  traceX2 = width - 80;
  traceY2 = height - 70;

  // Valeurs pour les légendes des axes du graphe
  axeX = 55;
  axeY = height - 25;

  // Valeur pour la largeur d'une barre de l'histogramme
  histogrammeLargeur = 4;

  // Import de la police de caractère et application
  police = loadFont("Roboto-Regular-20.vlw");
  textFont(police);

  // Déclaration des couleurs
  couleurFond = color(#DBCBBD);
  couleurCourbe = color(#C87941);
  couleurTitre = color(#290001);
  couleurTexte = color(#87431D);

  smooth();
}

void draw() {
  background(couleurFond);

  // Affiche la zone du graphe en blanc
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(traceX1, traceY1, traceX2, traceY2);

  // Dessine le titre
  dessinerTitre();
  // Dessine les titres des axes
  dessinerAxesTitres();

  // Mise à jour des données avec l'interpolation
  for (int ligne = 0; ligne < nbLigne; ligne++) {
    interp[ligne].update( );
  }

  // Dessine l'axe des années
  dessinerAxeAnnees();
  // Dessine l'axe des volumes
  dessinerAxeVolume();

  affichage(colonneCourante);
}

/* Fonction qui va dessiner le titre du graphe */

void dessinerTitre() {
  fill(couleurTitre);
  textSize(20);
  textAlign(LEFT);
  text(donnees.getColumnName(colonneCourante), traceX1, traceY1 - 10);
}

/* Fonction qui va dessiner le titre des axes du graphe */

void dessinerAxesTitres() {
  fill(couleurTexte);
  textSize(14);
  textLeading(15);
  textAlign(CENTER, CENTER);
  text("Litres\nconsommés\npar per.", axeX, (traceY1+traceY2)/2);
  text("Années", (traceX1+traceX2)/2, axeY);
}

/* Fonction qui va dessiner l'axe des abscisses (les années) du graphe */

void dessinerAxeAnnees() {
  fill(couleurTexte);
  textSize(12);
  textAlign(CENTER, TOP);

  // On va dessiner des lignes fines verticales
  stroke(couleurFond);
  strokeWeight(1);

  for (int ligne = 0; ligne < nbLigne; ligne++) {
    if (annees[ligne] % intervalleAnnees == 0) {
      float x = map(annees[ligne], anneeMin, anneeMax, traceX1, traceX2);
      text(annees[ligne], x, traceY2 + 10);
      // On dessine les lignes.
      line(x, traceY1, x, traceY2);
    }
  }
}

/* Fonction qui va dessiner l'axe des ordonnées (les volumes) du graphe */

void dessinerAxeVolume() {
  fill(couleurTexte);
  stroke(couleurTexte);
  strokeWeight(1);
  textSize(12);

  for (float v = donneeMin; v <= donneeMax; v+=intervalleVolumeMineur) {
    if (v % intervalleVolumeMineur == 0) {
      float y = map(v, donneeMin, donneeMax, traceY2, traceY1);
      if (v % intervalleVolume == 0) {
        if (v == donneeMin) {
          textAlign(RIGHT, BOTTOM);
        } else if (v == donneeMax) {
          textAlign(RIGHT, TOP);
        } else {
          textAlign(RIGHT, CENTER);
        }
        text(floor(v), traceX1 - 10, y);
        // On dessine le tiret majeur
        line(traceX1 - 4, y, traceX1, y);
      } else {
        // On dessine le tiret mineur
        line(traceX1 - 2, y, traceX1, y);
      }
    }
  }
}

/* Fonction qui va dessiner les données du graphe sous la forme de points */

void dessinerPointsDonnees(int colonne) {
  for (int ligne = 0; ligne < nbLigne; ligne++) {
    if (donnees.isValid(ligne, colonne)) {
      float valeur = interp[ligne].value;
      float x = map(annees[ligne], anneeMin, anneeMax, traceX1, traceX2);
      float y = map(valeur, donneeMin, donneeMax, traceY2, traceY1);
      point(x, y);
    }
  }
}

/* Fonction qui va dessiner les données du graphe sous la forme d'une ligne */

void dessinerLigneDonnees(int colonne) {
  // On commence la ligne
  beginShape();
  for (int ligne = 0; ligne < nbLigne; ligne++) {
    if (donnees.isValid(ligne, colonne)) {
      float valeur = interp[ligne].value;
      float x = map(annees[ligne], anneeMin, anneeMax, traceX1, traceX2);
      float y = map(valeur, donneeMin, donneeMax, traceY2, traceY1);
      vertex(x, y);
    }
  }
  endShape();
  // On termine la ligne sans fermer la forme
}

/* Fonction qui va dessiner les données du graphe sous la forme d'une courbe */

void dessinerCourbeDonnees(int colonne) {
  // On commence la courbe
  beginShape();
  for (int ligne = 0; ligne < nbLigne; ligne++) {
    if (donnees.isValid(ligne, colonne)) {
      float valeur = interp[ligne].value;
      float x = map(annees[ligne], anneeMin, anneeMax, traceX1, traceX2);
      float y = map(valeur, donneeMin, donneeMax, traceY2, traceY1);
      curveVertex(x, y);
      if ((ligne == 0) || (ligne == nbLigne-1)) {
        curveVertex(x, y);
      }
    }
  }
  endShape();
  // On termine la courbe sans fermer la forme
}

/* Fonction qui va dessiner les données du graphe sous la forme d'une ligne
 avec affichage des données lors du survol de la ligne */

void dessinerSurvolDonnees(int colonne) {
  for (int ligne = 0; ligne < nbLigne; ligne++) {
    if (donnees.isValid(ligne, colonne)) {
      float valeur = interp[ligne].value;
      float x = map(annees[ligne], anneeMin, anneeMax, traceX1, traceX2);
      float y = map(valeur, donneeMin, donneeMax, traceY2, traceY1);
      if (dist(mouseX, mouseY, x, y) < 3) {
        strokeWeight(8);
        point(x, y);
        fill(couleurTexte);
        textSize(10);
        textAlign(CENTER);
        text(nf(valeur, 0, 2) + " (" + annees[ligne] + ")", x, y-8);
      }
    }
  }
}

/* Fonction qui va dessiner les données du graphe sous la forme d'une aire */

void dessinerAireDonnees(int colonne) {
  beginShape();
  for (int ligne = 0; ligne < nbLigne; ligne++) {
    if (donnees.isValid(ligne, colonne)) {
      float valeur = interp[ligne].value;
      float x = map(annees[ligne], anneeMin, anneeMax, traceX1, traceX2);
      float y = map(valeur, donneeMin, donneeMax, traceY2, traceY1);
      vertex(x, y);
    }
  }
  vertex(traceX2, traceY2);
  vertex(traceX1, traceY2);
  endShape(CLOSE);
}

/* Fonction qui va dessiner les données du graphe sous la forme d'un histogramme */

void dessinerHistogrammeDonnees(int colonne) {
  noStroke();
  rectMode(CORNERS);
  for (int ligne = 0; ligne < nbLigne; ligne++) {
    if (donnees.isValid(ligne, colonne)) {
      float valeur = interp[ligne].value;
      float x = map(annees[ligne], anneeMin, anneeMax, traceX1, traceX2);
      float y = map(valeur, donneeMin, donneeMax, traceY2, traceY1);
      rect(x-histogrammeLargeur/2, y, x+histogrammeLargeur/2, traceY2);
    }
  }
}

/* La méthode d'affichage en fonction du mode */

void affichage(int colonne) {
  switch(modeActuel) {
  case 1:
    stroke(couleurCourbe);
    strokeWeight(4);
    // on utilise la colonne courante
    dessinerPointsDonnees(colonne);
    break;
  case 2:
    stroke(couleurCourbe);
    strokeWeight(3);
    noFill();
    dessinerLigneDonnees(colonne);
    break;
  case 3:
    stroke(couleurCourbe);
    strokeWeight(3);
    noFill();
    dessinerCourbeDonnees(colonne);
    break;
  case 4:
    stroke(couleurCourbe);
    strokeWeight(4);
    dessinerPointsDonnees(colonne);
    noFill();
    strokeWeight(1);
    dessinerLigneDonnees(colonne);
    break;
  case 5:
    stroke(couleurCourbe);
    noFill();
    strokeWeight(2);
    dessinerLigneDonnees(colonne);
    dessinerSurvolDonnees(colonne);
    break;
  case 6:
    noStroke();
    fill(couleurCourbe);
    dessinerAireDonnees(colonne);
    dessinerAxeAnnees();
    dessinerAxeVolume();
    break;
  default:
    stroke(couleurFond);
    fill(couleurCourbe);
    dessinerHistogrammeDonnees(colonne);
    break;
  }
}

void miseAJourDonnees() {
  for (int ligne = 0; ligne < nbLigne; ligne++) {
    interp[ligne].target(donnees.getFloat(ligne, colonneCourante));
  }
}


/* Fonction qui va nous permettre de switch entre les modes Lait, Thé et Café
 avec les flèches gauche et droite du clavier */

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      colonneCourante = (colonneCourante + 2) % 3;
    } else if (keyCode == RIGHT) {
      colonneCourante = (colonneCourante + 1) % 3;
    }
    if (keyCode == UP) {
      modeActuel = (modeActuel + 1) % 7;
    } else if (keyCode == DOWN) {
      if (modeActuel==0) {
        modeActuel=7;
      }
      modeActuel = (modeActuel - 1) % 7;
    }
    miseAJourDonnees();
  }
}
