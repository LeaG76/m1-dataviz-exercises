// Importation de la librairie TreeMap
import treemap.*;

// Création d'un objet répertoire racine et d'un objet fichier courant
Repertoire racine;
Fichier courant;

// Création de deux polices de caractères pour les noms de dossiers/fichiers
PFont font, fontActive;

void setup() {
  // Taille de la fenêtre de 1024x768
  size(1024, 768);
  // On change la forme du curseur (en forme de croix)
  cursor(CROSS);
  // On change de mode pour les rectangles
  rectMode(CORNERS);
  // On charge les polices de caractères
  font = loadFont("GoogleSans-Regular-13.vlw");
  fontActive = loadFont("GoogleSans-Regular-17.vlw");
  // Le chemin d'exemple du cours :
  //File fichier = new File("/Users/antoine/Documents/Processing");
  // Mon chemin pour accéder à mon dossier où je stocke tous mes cours du Master M1
  File fichier = new File("/mnt/chromeos/MyFiles/Université/M1iWOCS");
  // On change la racine à partir du chemin précédent
  changerRacine(fichier);
  smooth();
  noStroke();
}

void draw() {
  background(255);
  courant = null;
  // Si racine non null on appelle la méthode draw sur la racine
  if (racine != null) {
    racine.draw();
  }
  // Si courant non null on appelle la méthode de dessin du titre du fichier/dossier sur le courant
  if (courant != null) {
    courant.dessineTitre();
  }
}

/* Fonction pour changer de racine (à partir d'un nom de fichier)
  avec mise à jour de la couleur du bloc du fichier/dossier */

void changerRacine(File rep) {
  Repertoire r = new Repertoire(null, rep, 0, 0);
  r.setBounds(0, 0, width, height);
  r.contenuVisible = true;
  racine = r;
  racine.majCouleurs();
}

/* Fonction pour l'action lors du clic avec la souris */

void mousePressed() {
  if (racine != null) {
    racine.mousePressed();
  }
}
