class ConnectionGeneCollection {
  int globalInnovationNumber;
  
  ArrayList<ConnectionGene> genes;
  
  ConnectionGeneCollection() {
    globalInnovationNumber = 0;
    genes = new ArrayList<ConnectionGene>();
  }
  
  ConnectionGene returnGene (int in, int out) {
    for (int i = 0; i < genes.size(); i++) {
      ConnectionGene currentGene = genes.get(i);
      
      if (currentGene.in == in && currentGene.out == out) {
        return currentGene;
      }
    }
    
    ConnectionGene newGene = new ConnectionGene(in, out, globalInnovationNumber);
    globalInnovationNumber++;
    
    genes.add(newGene);
    
    return newGene;
  }
}
