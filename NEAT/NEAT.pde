import java.util.*;

ConnectionGeneCollection connectionGenes;
int snakeWidth = 400;
int snakeHeight = 400;
int playersRendered = 10;
int gen = 0;
int popSize = 500;
boolean lowerFramerate = false;
PlayerPopulation pop;

Level level = new Level(20, 20);

void setup() {
  connectionGenes = new ConnectionGeneCollection();
  size(1700, 800, P2D);
  frameRate(1000);
  
  pop = new PlayerPopulation(popSize, 24, 4);
}

void draw() {
  background(255);
  fill(0);
  text(pop.players[0].level.moves, 450, 40);
  text(frameRate, 450, 20);
  
  pop.update();
  pop.show();
}

void keyPressed() {
  switch(key) {
    case '=':
      playersRendered++;
      break;
    case '-':
      playersRendered--;
      break;
    case 'f':
      lowerFramerate = toggle(lowerFramerate);
      break;
  }
}

boolean toggle(boolean bln) {
  if (bln) {
    return false;
  }
  
  return true;
}
