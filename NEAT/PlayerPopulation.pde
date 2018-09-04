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
    showBestPlayers();
  }
  
  void update() {
    for (int i = 0; i < players.length; i++) {
      players[i].update();
    }
    
    if (isAllDead()) {
      setFitness();
      //println(avgScore());
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
  
  void showBestPlayers() {
    if (playersRendered > 0) {
      if (frameCount - framesSinceLastSort > 200) {
        Arrays.sort(players, new Comparator<Player>() {
          @Override
          public int compare(Player p1, Player p2) {
            int score1 = p1.level.score;
            int score2 = p2.level.score;
            
            if (p1.level.snake.dead) {
              score1 = -1;
            }
            
            if (p2.level.snake.dead) {
              score2 = -1;
            }
            
            return Float.compare(score1, score2);
          }
        });
        
        Collections.reverse(Arrays.asList(players));
        
        framesSinceLastSort = frameCount;
      }
      
      for (int i = 1; i < playersRendered; i++) {
        players[i].show();
        players[i].level.isBest = false;
      }
      
      players[0].level.isBest = true;
      players[0].show();
    }
    
  }
}
