import numpy as np

file = open(r"C:\\Users\\JonasPK\Desktop\\LLMConceptComparison\\log.txt", "w")

class TokenTree:
    def __init__(self, text: str):
        self.token = ""
        self.text = text
        self.logprob = 0
        self.total_logprob = 0
        self.depth = 0
        self.children = {}
        self.root = self
        self.total_node_count = 0
        self.max_depth = 0
        self.distId = f"{self.token}[{self.depth}]"
        self.id = ""
        self.root_id = ""

    def add_child(self, token, logprob):
        child = TokenTree(self.text + token)

        child.token = token
        child.depth = self.depth + 1
        child.logprob = logprob
        child.total_logprob = self.total_logprob + logprob
        child.distId = f"{child.token}[{child.depth}]"
        child.id = f"{self.id}[{child.token}]"
        child.root_id = self.root.root_id

        self.children[child.token] = child

        child.root = self.root
        self.root.total_node_count += 1
        self.root.max_depth = max(self.root.max_depth, child.depth)

        print(f"child@@@{self.id}@@@{child.id}@@@{token}@@@{child.text}@@@{np.exp(logprob)}@@@{self.root_id}")
        #file.write(f"{self.id}@@@{child.id}@@@{token}@@@{np.exp(logprob)}\n")

        return child
    
    def __lt__(self, o):
        return self.total_logprob > o.total_logprob

