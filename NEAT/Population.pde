class Population {
  Genome[] genomes;
  ArrayList<Species> species;
  int speciesCount;
  int gen;

  static final float c1 = 1.0;
  static final float geneDisabledInChild = 0.75;
  static final float interspeciesMatingRate = 0.001;
  static final float crossoverRate = 0.75;
  static final float compatibilityThreshold = 1.8;
  
  Population(int size, int inputNodes, int outputNodes) {
    genomes = new Genome[size];
    species = new ArrayList<Species>();
    
    for (int i = 0; i < size; i++) {
      genomes[i] = new Genome(inputNodes, outputNodes, false);
    }
    
    addSpecies();
    gen = 0;
  }
  
  void addSpecies() {
    speciesCount++;
    species.add(new Species());
  }
  
  void naturalSelection() {
    calculateSpeciesFitness();
    
    Genome[] newGenomes = new Genome[genomes.length];
    
    for (int i = 0; i < newGenomes.length; i++) {
      if (random(1) < crossoverRate) {
        newGenomes[i] = crossover(chooseParent(genomes[i]), chooseParent(genomes[i]));
      }
      else {
        newGenomes[i] = chooseParent(genomes[i]);
      }
      
      newGenomes[i].mutate();
      newGenomes[i].species = placeInSpecies(newGenomes[i], newGenomes);
      newGenomes[i].formatNodes();
    }
    
    
    
    genomes = newGenomes;
    gen++;
  }
  
  void calculateSpeciesFitness() {
    for (int i = 0; i < speciesCount; i++) {
      float max = 0;
      
      for (int j = 0; j < genomes.length; j++) {
        if (genomes[j].fitness > max && genomes[j].species == speciesCount) {
          max = genomes[j].fitness;
        }
      }
      
      species.get(i).addFitness(max);
    }
  }
  
  int placeInSpecies (Genome g, Genome[] newGenomes) {
    if (speciesCount > 1) {
      println("YES");
    }
    
    for (int i = 0; i < speciesCount; i++) {
      Genome rep = null;
      
      for (int j = 0; j < newGenomes.length; j++) {
        if (newGenomes[j] != null) {
          if (newGenomes[j].species == i) {
            rep = newGenomes[j];
            break;
          }
        }
      }
      
      if (compatibilityDistance(g, rep) < compatibilityThreshold) {
        println(compatibilityDistance(g, rep));
        return i;
      }
    }
    
    addSpecies();
    return speciesCount - 1;
  }
  
  Genome chooseParent (Genome g) {
    boolean parentOfOtherSpecies = random(1) < interspeciesMatingRate || species.get(g.species).isDegenerate;
    
    float runningSum = 0;
    float cutOff;
    
    //println(fitnessSum() + " - " + fitnessSum(g.species));
    
    if (parentOfOtherSpecies) {
      cutOff = random(fitnessSum());
    }
    else {
      cutOff = random(fitnessSum(g.species));
    }
    
    for (int i = 0; i < genomes.length; i++) {
      if (!parentOfOtherSpecies && genomes[i].species == g.species) {
        runningSum += genomes[i].fitness;
      }
      else if (parentOfOtherSpecies && !species.get(genomes[i].species).isDegenerate) {
        runningSum += genomes[i].fitness;
      }
      
      if (runningSum >= cutOff) {
        return genomes[i];
      }
    }
    
    return null;
  }
  
  float fitnessSum() {
    float sum = 0;
    
    for (int i = 0; i < genomes.length; i++) {
      if (!species.get(genomes[i].species).isDegenerate) {
        sum += genomes[i].fitness;
      }
    }
    
    return sum;
  }
  
  float fitnessSum(int s) {
    float sum = 0;
    
    for (int i = 0; i < genomes.length; i++) {
      if (genomes[i].species == s && !species.get(genomes[i].species).isDegenerate) {
        sum += genomes[i].fitness;
      }
    }
    
    return sum;
  }
  
  float compatibilityDistance (Genome candidate, Genome representative) {
    ArrayList<Connection> cNetwork = new ArrayList<Connection>(candidate.network);
    ArrayList<Connection> rNetwork = new ArrayList<Connection>(representative.network);
    
    float weightDiffTotal = 0;
    int matchingGenes = 0;
    
    for (int i = 0; i < cNetwork.size(); i++) {
      Connection c = cNetwork.get(i);
      
      for (int j = 0; j < rNetwork.size(); j++) {
        Connection r = rNetwork.get(j);
        
        if (c.gene.innovationNumber == r.gene.innovationNumber) {
          matchingGenes++;
          weightDiffTotal += Math.abs(c.weight - r.weight);
          cNetwork.remove(i);
          rNetwork.remove(j);
          break;
        }
      }
    }
    
    int unmatchingGenes = cNetwork.size() + rNetwork.size();
    int geneCount;
    
    if (candidate.network.size() > representative.network.size()) {
      geneCount = candidate.network.size();
    }
    else {
      geneCount = representative.network.size();
    }
    
    if (geneCount <= 20) {
      geneCount = 1;
    }
    
    return (((float)unmatchingGenes * c1) / (float)geneCount) + (weightDiffTotal / (float)matchingGenes);
  }
  
  Genome crossover(Genome p1, Genome p2) {
    if (p1.inputNodeCount == p2.inputNodeCount && p1.outputNodeCount == p2.outputNodeCount) {
      Genome child = new Genome(p1.inputNodeCount, p1.outputNodeCount, true);
      
      ArrayList<Connection> networkCopy1 = new ArrayList<Connection>(p1.network);
      ArrayList<Connection> networkCopy2 = new ArrayList<Connection>(p2.network);
      
      for (int i = 0; i < networkCopy1.size(); i++) {
        Connection c1 = networkCopy1.get(i);
        
        for (int j = 0; j < networkCopy2.size(); j++) {
          Connection c2 = networkCopy2.get(j);
          
          if (c2.gene.innovationNumber == c1.gene.innovationNumber) {
            if (random(1) < geneDisabledInChild && (!c1.enabled || !c2.enabled)) {
              c1.enabled = false;
              c2.enabled = false;
            }
            else {
              c1.enabled = true;
              c2.enabled = true;
            }
            
            if (random(1) < 0.5) {
              child.network.add(c1);
              if (c1.gene.out > child.nodes.size()) {
                child.addNode(NodeTypes.HIDDEN);
              }
            }
            else {
              child.network.add(c2);
              if (c2.gene.out > child.nodes.size()) {
                child.addNode(NodeTypes.HIDDEN);
              }
            }
            
            networkCopy1.remove(i);
            networkCopy2.remove(j);
          }
        }
      }
      
      if (p1.fitness >= p2.fitness) {
        child.network.addAll(networkCopy1);
      }
      else {
        child.network.addAll(networkCopy2);
      }
      
      for (int i = 0; i < child.network.size(); i++) {
        if (child.network.get(i).gene.out > child.nodes.size()) {
          child.addNode(NodeTypes.HIDDEN);
        }
      }
      
      return child;
    }
    else {
      return null;
    }
  }
}
