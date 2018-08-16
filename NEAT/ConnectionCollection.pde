class ConnectionCollection {
  int globalInnovationNumber;
  
  ArrayList<Connection> genes;
  
  ConnectionCollection() {
    globalInnovationNumber = 0;
    genes = new ArrayList<Connection>();
  }
  
  // NEED TO CHANGE HOW THIS WORKS SO THAT THERE IS A CONNECTIONGENE CLASS THAT HOLDS PURELY THE GENES AND ANOTHER CLASS THAT USES CONNECTIONGENE ALONG WITH WEIGHTS ETC.
  
  
  int add(Connection gene) {
    int existingGene = locationOfExistingGene(gene);
    
    if (existingGene != -1) {
      
    }
    else {
      return existingGene;
    }
  }
  
  int locationOfExistingGene(Connection gene) {
    for (int i = 0; i < genes.size(); i++) {
      Connection currentGene = genes.get(i);
      
      if (gene.in == currentGene.in && gene.out == currentGene.out) {
        return i;
      }
    }
    
    return -1;
  }
}
