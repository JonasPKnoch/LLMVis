from token_tree_generator import TokenTreeGenerator
import distributions
import os

class ConceptCompare:
    def __init__(self, client, text1: str, text2: str, temperature=1.5, max_tokens=15, noisy=False):
        self.tree_gen1 = TokenTreeGenerator(client, prompt=text1, temperature=temperature, max_tokens=max_tokens)
        self.tree_gen2 = TokenTreeGenerator(client, prompt=text2, temperature=temperature, max_tokens=max_tokens)
        self.tree1 = self.tree_gen1.root
        self.tree1.root_id = "tree1"
        self.tree2 = self.tree_gen2.root
        self.tree2.root_id = "tree2"
        self.noisy = noisy
        self.contributions = {}

    def expand_trees(self, iter):
        for i in range(iter):
            self.tree_gen1.expand_best_node()
            self.get_all_distances()
            self.tree_gen2.expand_best_node()
            self.get_all_distances()
    
    def get_all_distances(self):
        max_depth = max(self.tree1.max_depth, self.tree2.max_depth)
        contributions = {}
        distances = [(self.get_distance(i, contributions) if i == max_depth else self.get_distance(i)) for i in range(max_depth + 1)]

        print(f"dist@@@{"@@@".join(str(dist) for dist in distances)}")
        print(f"cont@@@{"@@@".join(f"{obs}@@@{contributions[obs]}" for obs in contributions)}")

        self.set_tree_distance(self.tree1, distances)
        self.set_tree_distance(self.tree2, distances)
        return distances[-1]

    def set_tree_distance(self, tree, distances):
        tree.distance = distances[tree.depth]
        for child in tree.children.values():
            self.set_tree_distance(child, distances)


    def get_distance(self, max_depth=9999, contributions={}):
        d1 = distributions.get_tree_distribution(self.tree1, max_depth)
        d2 = distributions.get_tree_distribution(self.tree2, max_depth)

        return distributions.JS_divergence(d1, d2, contributions)
