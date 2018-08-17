class Connection {
  ConnectionGene gene;
  float weight;
  boolean enabled;
  
  Connection(ConnectionGene geneInput, float weightInput, boolean enabledInput) {
    gene = geneInput;
    weight = weightInput;
    enabled = enabledInput;
  }
}
