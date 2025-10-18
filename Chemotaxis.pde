class Bacteria {
  int x, y;
  int c;

  Bacteria(int startX, int startY, int col) {
    x = startX;
    y = startY;
    c = col;
  }

  void move(int targetX, int targetY) {
    int dx = (int)(Math.random() * 7) - 3;
    int dy = (int)(Math.random() * 7) - 3;
    if (Math.random() < 0.7) {
      if (targetX > x) dx += 1;
      if (targetX < x) dx -= 1;
      if (targetY > y) dy += 1;
      if (targetY < y) dy -= 1;
    }
    x += dx;
    y += dy;
    x = constrain(x, 0, width);
    y = constrain(y, 0, height);
  }

  void show() {
    fill(c);
    noStroke();
    ellipse(x, y, 10, 10);
  }
}

class Food {
  int x, y;

  Food() {
    x = (int)random(50, width - 50);
    y = (int)random(50, height - 50);
  }

  void show() {
    fill(0, 255, 120);
    stroke(0, 180, 80);
    ellipse(x, y, 15, 15);
  }
}

final int NUM_BACTERIA = 15;
final int NUM_FOOD = 5;
final int WIN_SCORE = 1000;

Bacteria[] redTeam = new Bacteria[NUM_BACTERIA];
Bacteria[] blueTeam = new Bacteria[NUM_BACTERIA];
ArrayList<Food> foods = new ArrayList<Food>();

int redScore = 1;
int blueScore = 1;
boolean gameOver = false;
boolean started = false;
String winner = "";
String prediction = "";


int redButtonX, redButtonY, blueButtonX, blueButtonY;


void setup() {
  size(800, 600);
  smooth();
  redButtonX = width / 2 - 150;
  redButtonY = height / 2;
  blueButtonX = width / 2 + 50;
  blueButtonY = height / 2;
}


void draw() {
  background(0);

  if (!started && !gameOver) {
    showPredictionScreen();
    return;
  }

  if (!gameOver) {
    // Show food
    for (Food f : foods) f.show();

    // Move and show bacteria
    for (int i = 0; i < NUM_BACTERIA; i++) {
      Food redTarget = closestFood(redTeam[i]);
      Food blueTarget = closestFood(blueTeam[i]);
      redTeam[i].move(redTarget.x, redTarget.y);
      blueTeam[i].move(blueTarget.x, blueTarget.y);
      redTeam[i].show();
      blueTeam[i].show();
    }

    
    checkFoodCollection();

    // Display scores
    fill(255);
    textAlign(CENTER);
    textSize(22);
    text("Red: " + redScore + " Blue: " + blueScore, width / 2, 30);

    // Check win
    if (redScore >= WIN_SCORE) {
      winner = " Red Colony Wins!";
      gameOver = true;
    } else if (blueScore >= WIN_SCORE) {
      winner = " Blue Colony Wins!";
      gameOver = true;
    }
  } else {
    showGameOver();
  }
}


void showPredictionScreen() {
  fill(255);
  textAlign(CENTER);
  textSize(28);
  text("Who do you think will win?", width / 2, height / 2 - 100);

  // Red button
  fill(255, 80, 80);
  rect(redButtonX, redButtonY, 100, 50, 10);
  fill(255);
  textSize(20);
  text("RED", redButtonX + 50, redButtonY + 30);

  // Blue button
  fill(100, 150, 255);
  rect(blueButtonX, blueButtonY, 100, 50, 10);
  fill(255);
  textSize(20);
  text("BLUE", blueButtonX + 50, blueButtonY + 30);
}

void showGameOver() {
  fill(255);
  textAlign(CENTER);
  textSize(36);
  text(winner, width / 2, height / 2 - 40);

  textSize(22);
  if (winner.toLowerCase().contains(prediction)) {
    text("WOW You guessed right! (" + prediction.toUpperCase() + ")", width / 2, height / 2);
  } else {
    text(" Try again (" + prediction.toUpperCase() + ")", width / 2, height / 2);
  }

  fill(180);
  rect(width / 2 - 60, height / 2 + 60, 120, 40, 10);
  fill(0);
  textSize(18);
  text("Restart", width / 2, height / 2 + 87);
}

void checkFoodCollection() {
  for (int i = foods.size() - 1; i >= 0; i--) {
    Food f = foods.get(i);

    for (Bacteria b : redTeam) {
      if (dist(b.x, b.y, f.x, f.y) < 10) {
        redScore += 30;
        foods.set(i, new Food());
        break;
      }
    }

    for (Bacteria b : blueTeam) {
      if (dist(b.x, b.y, f.x, f.y) < 10) {
        blueScore += 30;
        foods.set(i, new Food());
        break;
      }
    }
  }
}

Food closestFood(Bacteria b) {
  Food nearest = foods.get(0);
  float minDist = dist(b.x, b.y, nearest.x, nearest.y);
  for (Food f : foods) {
    float d = dist(b.x, b.y, f.x, f.y);
    if (d < minDist) {
      minDist = d;
      nearest = f;
    }
  }
  return nearest;
}


void mousePressed() {
  if (!started && !gameOver) {
    // Red button clicked
    if (mouseX > redButtonX && mouseX < redButtonX + 100 &&
        mouseY > redButtonY && mouseY < redButtonY + 50) {
      prediction = "red";
      startGame();
    }
    // Blue button clicked
    if (mouseX > blueButtonX && mouseX < blueButtonX + 100 &&
        mouseY > blueButtonY && mouseY < blueButtonY + 50) {
      prediction = "blue";
      startGame();
    }
  }

  // Restart button
  if (gameOver && mouseX > width / 2 - 60 && mouseX < width / 2 + 60 &&
      mouseY > height / 2 + 60 && mouseY < height / 2 + 100) {
    resetGame();
  }
}

void startGame() {
  println("Prediction: " + prediction);
  redScore = 1;
  blueScore = 1;
  gameOver = false;
  started = true;
  winner = "";

  foods.clear();
  for (int i = 0; i < NUM_FOOD; i++) foods.add(new Food());

  for (int i = 0; i < NUM_BACTERIA; i++) {
    redTeam[i] = new Bacteria((int)random(100), (int)random(height), color(255, 80, 80));
    blueTeam[i] = new Bacteria((int)random(width - 100, width), (int)random(height), color(100, 150, 255));
  }
}

void resetGame() {
  started = false;
  gameOver = false;
  prediction = "";
  winner = "";
  redScore = 1;
  blueScore = 1;
}
