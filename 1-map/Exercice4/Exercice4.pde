PImage carte;

PFont fontTitre;
PFont fontLegende;
PFont font;

Table positions;
Table maisons;
Table fans;

int lignes;

int dminM = 1;
int dmaxM = 5;

float dminF = 10000;
float dmaxF = 50001;

Integrator[] interpM;
Integrator[] interpF;

void setup() {
  size(650, 775);
  frameRate(15);
  fontTitre = loadFont("Roboto-Regular-16.vlw");
  fontLegende = loadFont("Roboto-Regular-14.vlw");
  font = loadFont("Roboto-Regular-12.vlw");
  carte = loadImage("carte.png");
  positions = new Table("positions.tsv");
  lignes = positions.getRowCount();
  maisons = new Table("maisons.tsv");
  interpM = new Integrator[lignes];
  for (int ligne = 0; ligne < lignes; ligne++) {
    interpM[ligne] = new Integrator(maisons.getFloat(ligne, 1));
  }
  fans = new Table("fans.tsv");
  interpF = new Integrator[lignes];
  for (int ligne = 0; ligne < lignes; ligne++) {
    interpF[ligne] = new Integrator(fans.getFloat(ligne, 1));
  }
  trouverMinMax();
  noStroke();
}

void draw() {
  background(255);
  image(carte, 25, 50, width-50, height-94);

  smooth();

  if (key == 'm') {
    affichageMaisons();
  } else if (key == 'f') {
    affichageFans();
  } else {
    affichageAccueil();
  }

  //saveFrame("sortie.png");
}

void affichageAccueil() {
  String titre = "Bienvenue ! Pressez la touche M pour afficher les maisons de\n Games of Thrones et la touche F pour les fans de Games of Thrones";
  fill(0);
  textFont(fontTitre);
  textAlign(CENTER);
  text(titre, width/2, 20);
  
  for(int ligne=0; ligne < lignes; ligne++) {
    float x = positions.getFloat(ligne, 1);
    float y = positions.getFloat(ligne, 2);
    ellipse(x, y, 15, 15);
  }
  
  String texte = "Pressez une touche autre que M ou F pour revenir à l'accueil\nLa mise à jour des données s'effectue lorsque la souris est pressée";
  fill(0);
  textAlign(LEFT);
  textFont(fontLegende);
  text(texte, 20, 745);
  
  survole();
}

void affichageMaisons() {
  String titre = "Les grandes maisons de Westeros préférées\ndes français en fonction des régions de France";
  fill(0);
  textFont(fontTitre);
  textAlign(CENTER);
  text(titre, width/2, 20);

  for (int ligne=0; ligne < lignes; ligne++) {
    interpM[ligne].update();
    String cle = maisons.getRowName(ligne);
    float x = positions.getFloat(cle, 1);
    float y = positions.getFloat(cle, 2);
    dessinerDonneesMaisons(x, y, ligne);
  }
  survoleMaisons();
  legendeMaisons();
}

void affichageFans() {
  String titre = "Le nombre de fans de Games of Thrones\nen fonction des régions de France";
  fill(0);
  textFont(fontTitre);
  textAlign(CENTER);
  text(titre, width/2, 20);

  for (int ligne=0; ligne < lignes; ligne++) {
    interpF[ligne].update();
    String cle = fans.getRowName(ligne);
    float x = positions.getFloat(cle, 1);
    float y = positions.getFloat(cle, 2);
    dessinerDonneesFans(x, y, ligne);
  }
  survoleFans();
  legendeFans();
}


void dessinerDonneesMaisons(float x, float y, int ligne) {
  int valeur = int(interpM[ligne].value);
  switch(valeur) {
  case 1: 
    fill(#2A9345);
    break;
  case 2:
    fill(#A9181E);
    break;
  case 3:
    fill(#194C97);
    break;
  case 4:
    fill(#ffd700);
    break;
  }
  ellipse(x, y, 20, 20);
}

void dessinerDonneesFans(float x, float y, int ligne) {
  float valeur = interpF[ligne].value;
  float taille = map(valeur, dminF, dmaxF, 10, 50);
  if (valeur >= 40000) {
    fill(#6E3300);
  } else if (valeur >= 30000 && valeur < 40000) {
    fill(#CE2525);
  } else if (valeur >= 20000 && valeur < 30000) {
    fill(#FF6600);
  } else {
    fill(#F1C550);
  }
  ellipse(x, y, taille, taille);
}

void trouverMinMax() {
  for (int ligne = 0; ligne < lignes; ligne++) {
    float valeur = fans.getFloat(ligne, 1);
    if (valeur > dmaxF) dmaxF = valeur;
    if (valeur < dminF) dminF = valeur;
  }
}

void mousePressed() {
  if (key == 'm') {
    majDonneesMaisons();
  }
  if (key == 'f') {
    majDonneesFans();
  }
}

void majDonneesMaisons() {
  for (int ligne = 0; ligne < lignes; ligne++) {
    float nouvelleMaison = random(dminM, dmaxM);
    interpM[ligne].target(nouvelleMaison);
    maisons.setInt(ligne,1,(int)nouvelleMaison);
  }
}

void majDonneesFans() {
  for (int ligne = 0; ligne < lignes; ligne++) {
    float nouveauxFans = random(dminF, dmaxF);
    interpF[ligne].target(nouveauxFans);
    fans.setFloat(ligne,1,nouveauxFans);
  }
}

void survole() {
  for (int ligne=0; ligne < lignes; ligne++) {
    String region = positions.getRowName(ligne);
    float x = positions.getFloat(ligne, 1);
    float y = positions.getFloat(ligne, 2);
    switch(region) {
    case "ARA":
      region = "Auvergne-Rhône-Alpes";
      break;
    case "BFC":
      region = "Bourgogne-Franche-Comté";
      break;
    case "BRE":
      region = "Bretagne";
      break;
    case "CVL":
      region = "Centre-Val de Loire";
      break;
    case "COR":
      region = "Corse";
      break;
    case "GES":
      region = "Grand Est";
      break;
    case "HDF":
      region = "Hauts-de-France";
      break;
    case "IDF":
      region = "Île-de-France";
      break;
    case "NOR":
      region = "Normandie";
      break;
    case "NAQ":
      region = "Nouvelle-Aquitaine";
      break;
    case "OCC":
      region = "Occitanie";
      break;
    case "PDL":
      region = "Pays de la Loire";
      break;
    case "PAC":
      region = "Provence-Alpes-Côte d'Azur";
      break;
    }
    textFont(font);
    textAlign(CENTER, BOTTOM);
    if (dist(mouseX, mouseY, x, y) < 10) {
      fill(255, 220);
      stroke(#CCCCCC, 220);
      strokeWeight(2);
      rectMode(CENTER);
      rect(x, y-17.5, 165, 15, 2);
      fill(0);
      noStroke();
      text(region, x, y-10);
    }
  }
}

void survoleMaisons() {
  for (int ligne=0; ligne < lignes; ligne++) {
    String cle = maisons.getRowName(ligne);
    String region = maisons.getRowName(ligne);
    float x = positions.getFloat(cle, 1);
    float y = positions.getFloat(cle, 2);
    int valeur = maisons.getInt(cle, 1);
    String maison ="";
    switch(region) {
    case "ARA":
      region = "Auvergne-Rhône-Alpes";
      break;
    case "BFC":
      region = "Bourgogne-Franche-Comté";
      break;
    case "BRE":
      region = "Bretagne";
      break;
    case "CVL":
      region = "Centre-Val de Loire";
      break;
    case "COR":
      region = "Corse";
      break;
    case "GES":
      region = "Grand Est";
      break;
    case "HDF":
      region = "Hauts-de-France";
      break;
    case "IDF":
      region = "Île-de-France";
      break;
    case "NOR":
      region = "Normandie";
      break;
    case "NAQ":
      region = "Nouvelle-Aquitaine";
      break;
    case "OCC":
      region = "Occitanie";
      break;
    case "PDL":
      region = "Pays de la Loire";
      break;
    case "PAC":
      region = "Provence-Alpes-Côte d'Azur";
      break;
    }
    switch(valeur) {
    case 1:
      maison = "Maison Barathéon";
      break;
    case 2:
      maison = "Maison Targaryen";
      break;
    case 3:
      maison = "Maison Stark";
      break;
    case 4:
      maison = "Maison Lannister";
      break;
    }
    textFont(font);
    textAlign(CENTER, BOTTOM);
    if (dist(mouseX, mouseY, x, y) < 10) {
      fill(255, 220);
      stroke(#CCCCCC, 220);
      strokeWeight(2);
      rectMode(CENTER);
      rect(x, y-30, 165, 30, 2);
      fill(0);
      noStroke();
      text(maison + "\n(" + region + ")", x, y-15);
    }
  }
}

void survoleFans() {
  for (int ligne=0; ligne < lignes; ligne++) {
    String cle = fans.getRowName(ligne);
    String region = fans.getRowName(ligne);
    float x = positions.getFloat(cle, 1);
    float y = positions.getFloat(cle, 2);
    int valeur = fans.getInt(cle, 1);
    switch(region) {
    case "ARA":
      region = "Auvergne-Rhône-Alpes";
      break;
    case "BFC":
      region = "Bourgogne-Franche-Comté";
      break;
    case "BRE":
      region = "Bretagne";
      break;
    case "CVL":
      region = "Centre-Val de Loire";
      break;
    case "COR":
      region = "Corse";
      break;
    case "GES":
      region = "Grand Est";
      break;
    case "HDF":
      region = "Hauts-de-France";
      break;
    case "IDF":
      region = "Île-de-France";
      break;
    case "NOR":
      region = "Normandie";
      break;
    case "NAQ":
      region = "Nouvelle-Aquitaine";
      break;
    case "OCC":
      region = "Occitanie";
      break;
    case "PDL":
      region = "Pays de la Loire";
      break;
    case "PAC":
      region = "Provence-Alpes-Côte d'Azur";
      break;
    }
    textFont(font);
    textAlign(CENTER, BOTTOM);
    if (dist(mouseX, mouseY, x, y) < 15) {
      fill(255, 220);
      stroke(#CCCCCC, 220);
      strokeWeight(2);
      rectMode(CENTER);
      rect(x, y-30, 165, 30, 2);
      fill(0);
      noStroke();
      text("Nombre de fans : " + valeur + "\n(" + region + ")", x, y-15);
    }
  }
}

void legendeMaisons() {
  ellipseMode(CENTER);
  fill(#2A9345);
  ellipse(40, 696, 12, 12);
  fill(#A9181E);
  ellipse(40, 716, 12, 12);
  fill(#194C97);
  ellipse(40, 736, 12, 12);
  fill(#ffd700);
  ellipse(40, 756, 12, 12);
  String baratheon = "Maison Barathéon | Devise : \"Nôtre est la fureur\"";
  String targaryen = "Maison Targaryen | Devise : \"Feu et Sang\"";
  String stark = "Maison Stark | Devise : \"L'hiver vient\"";
  String lannister = "Maison Lannister | Devise : \"Un Lannister paie toujours ses dettes\"";
  fill(0);
  textAlign(LEFT);
  textFont(fontLegende);
  text("Légende :", 30, 675);
  textFont(font);
  text(baratheon, 60, 700);
  text(targaryen, 60, 720);
  text(stark, 60, 740);
  text(lannister, 60, 760);
}

void legendeFans() {
  ellipseMode(CENTER);
  fill(#F1C550);
  ellipse(40, 696, 12, 12);
  fill(#FF6600);
  ellipse(40, 716, 12, 12);
  fill(#CE2525);
  ellipse(40, 736, 12, 12);
  fill(#6E3300);
  ellipse(40, 756, 12, 12);
  String jaune = "Nombre moyen de fans inférieur à 20000";
  String orange = "Nombre moyen de fans entre 20000 et 30000";
  String rouge = "Nombre moyen de fans entre 30000 et 40000";
  String marron = "Nombre moyen de fans supérieur à 40000";
  fill(0);
  textAlign(LEFT);
  textFont(fontLegende);
  text("Légende :", 30, 675);
  textFont(font);
  text(jaune, 60, 700);
  text(orange, 60, 720);
  text(rouge, 60, 740);
  text(marron, 60, 760);
}
