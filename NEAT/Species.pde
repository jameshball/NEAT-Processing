class Species {
  ArrayList<Float> maxFitness;
  boolean isDegenerate = false;
  
  Species() {
    maxFitness = new ArrayList<Float>();
  }
  
  void addFitness (float fitness) {
    if (maxFitness.size() == 0) {
      maxFitness.add(fitness);
    }
    else if (fitness > maxFitness.get(maxFitness.size() - 1)) {
      maxFitness.add(fitness);
    }
    else {
      maxFitness.add(new Float(maxFitness.get(maxFitness.size() - 1)));
    }
    
    if (isDegenerate()) {
      isDegenerate = true;
    }
  }
  
  boolean isDegenerate () {
    if (maxFitness.size() > 14) {
      if (maxFitness.get(maxFitness.size() - 15) == maxFitness.get(maxFitness.size() - 1)) {
        return true;
      }
    }
    
    return false;
  }
}
