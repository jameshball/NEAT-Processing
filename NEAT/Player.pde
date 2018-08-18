class Player {
  Genome genome;
  Level level;
  PVector startPos;
  PVector startAngle;
  float[] input = new float[0];
  
  Player(int inputNodes, int outputNodes) {
    genome = new Genome(inputNodes, outputNodes);
    level = new Level(20, 20);
  }
  
  Player(Genome genomeInput) {
    genome = genomeInput;
    level = new Level(20, 20);
  }
  
  void show() {
    level.show();
  }
  
  void update() {
    if (!level.snake.dead) {
      input = level.vision();
      
      float[] output = genome.feedForward(input);
      
      float max = output[0];
      int maxIndex = 0;
      
      for (int i = 1; i < output.length; i++) {
        if (output[i] > max) {
          max = output[i];
          maxIndex = i;
        }
      }
      
      level.snake.direction = maxIndex;
    }
    
    level.frameRateUpdate();
  }
}
