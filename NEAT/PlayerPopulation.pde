class PlayerPopulation {
  Population p;
  Player[] players;
  int framesSinceLastSort = 0;
  
  PlayerPopulation(int size, int inputNodes, int outputNodes) {
    p = new Population(size, inputNodes, outputNodes);
    
    setPlayers(size);
    framesSinceLastSort = frameCount;
  }
  
  void show() {
    players[0].level.isBest = true;
    players[0].show();
  }
  
  void update() {
    for (int i = 0; i < players.length; i++) {
      players[i].update();
    }
    
    if (isAllDead()) {
      setFitness();
      println(avgScore());
      p.naturalSelection();
      setPlayers(players.length);
    }
  }
  
  void setFitness () {
    for (int i = 0; i < players.length; i++) {
      p.genomes[i].updateFitness(players[i].level.score);
    }
  }
  
  float avgScore() {
    float totalScore = 0;
    
    for (int i = 0; i < players.length; i++) {
      totalScore += players[i].level.score;
    }
    
    return totalScore / (float)players.length;
  }
  
  void setPlayers (int size) {
    players = new Player[size];
    
    for (int i = 0; i < players.length; i++) {
      players[i] = new Player(p.genomes[i]);
    }
  }
  
  boolean isAllDead() {
    for (int i = 0; i < players.length; i++) {
      if (!players[i].dead()) {
        return false;
      }
    }
    
    return true;
  }
}
