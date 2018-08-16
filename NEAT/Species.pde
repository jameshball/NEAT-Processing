class Species {
  Genome[] genomes;
  
  Species(int size, int inputNodes, int outputNodes) {
    genomes = new Genome[size];
    
    for (int i = 0; i < size; i++) {
      genomes[i] = new Genome(inputNodes, outputNodes);
    }
  }
}
