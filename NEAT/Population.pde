class Population {
  ArrayList<Species> species;
  
  Population(int size, int inputNodes, int outputNodes) {
    species = new ArrayList<Species>();
    species.add(new Species(size, inputNodes, outputNodes));
  }
}
