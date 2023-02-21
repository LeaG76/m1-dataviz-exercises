import java.text.*;
import java.util.*;

// 30 équipes
int nequipes = 30;
// Nombre de jours dans la saison
int nb_jours;
// Date actuelle du curseur
int dateIndex;
// Date minimal (on met 10 car on ne prend pas en compte les 10 premières dates, c'est-à-dire on commence le 11 avril 2007)
int minDateIndex = 10;
// Date maximal
int maxDateIndex;

// Positions x et y du curseur des dates
int dateSlideX;
int dateSlideY = 30;

// Valeurs pour la représentation des résultats
static final int HLIGNE = 23;
static final int BORDS = 30;

// Valeurs pour la taille des logos
float logow;
float logoh;

// Valeur pour la représentation des résultats
static final float DEMI_HLIGNE = HLIGNE / 2.0;

// Millisecondes par jour
static final long MS_PAR_JOUR = 24 * 60 * 60 * 1000;

// Premier, dernier et jour actuel
String premierJour = "20070401";
String dernierJour = "20070930";
String jourActuel;
// Noms
String[] noms;
// Codes
String[] codes;
// Stockage des dates dans un tableau de string
String[] dateFormat;
//  Stockage des dates formatées dans un tableau de string
String[] dateFormatJoli;

// Indices
HashMap indices;

// Images des logos
PImage[] logos;

// Police de caractère
PFont font;

// Format AAAAMMDD.
DateFormat formatOriginal = new SimpleDateFormat("yyyyMMdd");
// Format JJ MM AAAA en français
DateFormat joliFormat = new SimpleDateFormat("d MMMM yyyy");

ListeSalaires salaires;
ListeClassements classements;
ListeClassements[] saison;

Integrator[] positionClassement;

/*******************
 * Setup principal *
 *******************/

void setup() {
  size(480, 750);

  setupEquipes();
  setupDates();
  setupSalaires();
  setupClassements();
  setupPalmares();
  setupLogos();

  font = createFont("Georgia", 12);
  textFont(font);
  
  frameRate(15);
  setDate(minDateIndex);
}

/********
 * Draw *
 ********/

void draw() {
  background(255);
  smooth();
  
  drawDatesSlider();
  
  translate(BORDS, BORDS);

  for (int i = 0; i < nequipes; i++) {
    positionClassement[i].update();
  }
  
  float gaucheX = 160;
  float droiteX = 335;
  textAlign(LEFT, CENTER);
  for (int i=0; i<nequipes; i++) {
    fill(50);
    float classementY = positionClassement[i].value * HLIGNE + DEMI_HLIGNE;
    image(logos[i], 0, classementY - logoh/2, logow, logoh);
    textAlign(LEFT, CENTER);
    text(noms[i], 28, classementY);
    textAlign(RIGHT, CENTER);
    text(classements.getTitle(i), gaucheX-10, classementY);
    float salaireY = salaires.getRank(i) * HLIGNE + DEMI_HLIGNE;
    // Mettre de la couleur pour les lignes
    if (salaireY <= classementY) {
      stroke(33, 85, 156); // Les lignes sont en bleu pour les équipes qui dépensent mal leurs recettes
    } else {
      stroke(206, 0, 82); // Sinon les lignes sont en rouge
    }
    // Mettre de l'épaisseur pour les lignes
    float taille = map(salaires.getValue(i), salaires.getMinValue( ), salaires.getMaxValue( ), 0.25, 6);
    strokeWeight(taille);
    line(gaucheX, classementY, droiteX, salaireY);
    fill(50);
    textAlign(LEFT, CENTER);
    text(salaires.getTitle(i), droiteX + 10, salaireY);
  }
}

/************************************
 * Tout ce qui concerne les équipes *
 ************************************/

void setupEquipes() {
  String[] lignes = loadStrings("equipes.tsv");
  nequipes = lignes.length;
  codes = new String[nequipes];
  noms = new String[nequipes];
  indices = new HashMap();

  for (int i = 0; i < nequipes; i++) {
    String[] parties = split(lignes[i], TAB);
    codes[i] = parties[0];
    noms[i] = parties[1];
    indices.put(codes[i], new Integer(i));
  }
}

int indexEquipe(String code) {
  return ((Integer) indices.get(code)).intValue();
}

/*************************************
 * Tout ce qui concerne les salaires *
 *************************************/

void setupSalaires() {
  salaires = new ListeSalaires(loadStrings("salaires.tsv"));
}

/****************************************
 * Tout ce qui concerne les classements *
 ****************************************/

void lireClassements(String fichier, PrintWriter writer) {
  String[] lignes = loadStrings(fichier);
  String code = "";
  int wins = 0;
  int losses = 0;
  for (int i=0; i < lignes.length; i++) {
    String[] matches = match(lignes[i], "\\s+([\\w\\d]+):\\s'(.*)',?");
    if (matches != null) {
      String attr = matches[1];
      String valeur =  matches[2];

      if (attr.equals("code")) {
        code = valeur;
      } else if ( attr.equals("w")) {
        wins = parseInt(valeur);
      } else if (attr.equals("l")) {
        losses = parseInt(valeur);
      }
    } else {
      if (lignes[i].startsWith("}")) {
        // Fin du groupe on écrit les valeurs.
        writer.println(code + TAB + wins + TAB + losses);
      }
    }
  }
}

String[] chargerClassements(int annee, int mois, int jour) {
  String nom = annee + nf(mois, 2) + nf(jour, 2) + ".tsv";
  String chemin = dataPath(nom);
  File fichier = new File(chemin);
  if ((!fichier.exists()) || (fichier.length() == 0)) {
    // Si le fichier n'existe pas, on le crée à partir de données en ligne.
    // Attention pour cet exemple les années possibles sont entre 1999 et
    // 2011...
    println("on télécharge " + nom);
    PrintWriter writer = createWriter(chemin);
    String base = "http://mlb.mlb.com/components/game" +
      "/year_" + annee + "/month_" + nf(mois, 2) + "/day_" + nf(jour, 2) + "/";
    // American League
    lireClassements(base + "standings_rs_ale.js", writer);
    lireClassements(base + "standings_rs_alc.js", writer);
    lireClassements(base + "standings_rs_alw.js", writer);
    // National League
    lireClassements(base + "standings_rs_nle.js", writer);
    lireClassements(base + "standings_rs_nlc.js", writer);
    lireClassements(base + "standings_rs_nlw.js", writer);

    writer.flush();
    writer.close();
  }
  return loadStrings(chemin);
}

String[] chargerClassements(String timbre) {
  int annee = int(timbre.substring(0, 4));
  int mois = int(timbre.substring(4, 6));
  int jour = int(timbre.substring(6, 8));
  return chargerClassements(annee, mois, jour);
}

void setupClassements() {
  String[] lines = loadStrings("http://benfry.com/writing/salaryper/mlb.cgi");
  int nb_jours_obtenu = lines.length / nequipes;
  int nb_jours_attendu = (maxDateIndex - minDateIndex) + 1;
  if (nb_jours_obtenu < nb_jours_attendu) {
    maxDateIndex = minDateIndex + nb_jours_obtenu - 1;
  }
  saison = new ListeClassements[maxDateIndex + 1];
  for (int i = 0; i < nb_jours_obtenu; i++) {
    String[] portion = subset(lines, i*nequipes, nequipes);
    saison[i+minDateIndex] = new ListeClassements(portion);
  }
}

/**********************************
 * Tout ce qui concerne les logos *
 **********************************/

void setupLogos() {
  logos = new PImage[nequipes];
  for (int i=0; i<nequipes; i++) {
    logos[i] = loadImage("small/" + codes[i] + ".gif");
  }
  logow = logos[0].width / 2.0;
  logoh = logos[0].height / 2.0;
}

/**********************************
 * Tout ce qui concerne les dates *
 **********************************/

void setupDates() {
  try {
    Date premiereDate = formatOriginal.parse(premierJour);
    long premiereDateMillis = premiereDate.getTime();
    Date derniereDate = formatOriginal.parse(dernierJour);
    long derniereDateMillis = derniereDate.getTime();
    nb_jours = (int)
      ((derniereDateMillis - premiereDateMillis) / MS_PAR_JOUR) + 1;
    maxDateIndex = nb_jours;
    dateFormat = new String[nb_jours];
    dateFormatJoli = new String[nb_jours];
    jourActuel = year() + nf(month(), 2) + nf(day(), 2);

    for (int i = 0; i < nb_jours; i++) {
      Date date = new Date(premiereDateMillis + MS_PAR_JOUR*i);
      dateFormatJoli[i] = joliFormat.format(date);
      dateFormat[i] = formatOriginal.format(date);

      if (dateFormat[i].equals(jourActuel)) {
        maxDateIndex = i-1;
      }
    }
  } 
  catch (ParseException e) {
    die("Problème lors du réglage des dates", e);
  }
}

void drawDatesSlider() {
  dateSlideX = (width - nb_jours*2) / 2;
  strokeWeight(1);
  for (int i = 0; i < nb_jours; i++) {
    int x = dateSlideX + i*2;

    if (i == dateIndex) {
      stroke(0);
      line(x, 0, x, 13);
      textAlign(CENTER, TOP);
      text(dateFormatJoli[dateIndex], x, 15);
    } else {
      // Règle si on peut accéder au résultat de cette date ou non.
      if ((i >= minDateIndex) && (i <= maxDateIndex)) {
        stroke(128); 
      } else {
        stroke(204); 
      }
      line(x, 0, x, 7);
    }
  }
}

void setDate(int index) {
  dateIndex = index;
  classements = saison[dateIndex];
  for (int i = 0; i < nequipes; i++) {
    positionClassement[i].target(classements.getRank(i));
  }
  loop();
}

void mousePressed( ) {
  handleMouse();
}

void mouseDragged( ) {
  handleMouse();
}

void handleMouse( ) {
  if (mouseY < dateSlideY) {
    int date = (mouseX - dateSlideX) / 2;
    setDate(constrain(date, minDateIndex, maxDateIndex));
  }
}

void keyPressed( ) {
  if (key == CODED) {
    if (keyCode == LEFT) {
      int nouvelleDate = max(dateIndex - 1, minDateIndex);
      setDate(nouvelleDate);
    } else if (keyCode == RIGHT) {
      int nouvelleDate = min(dateIndex + 1, maxDateIndex);
      setDate(nouvelleDate);
    }
  }
}

/*************************************
 * Tout ce qui concerne les palmares *
 *************************************/

void setupPalmares() {
  positionClassement = new Integrator[nequipes];
  for (int i = 0; i < codes.length; i++) {
    positionClassement[i] = new Integrator(i);
  }
}
