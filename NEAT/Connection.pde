class Connection {
  int in;
  int out;
  float weight;
  boolean enabled;
  int innovationNumber;
  
  Connection(int inInput, int outInput, float weightInput, boolean enabledInput) {
    in = inInput;
    out = outInput;
    weight = weightInput;
    enabled = enabledInput;
    innovationNumber = globalInnovationNumber;
    globalInnovationNumber++;
  }
  
  Connection(int inInput, int outInput) {
    in = inInput;
    out = outInput;
    weight = random(-1, 1);
    enabled = true;
    innovationNumber = globalInnovationNumber;
    globalInnovationNumber++;
  }
}
