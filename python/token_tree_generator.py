import heapq
from openai import OpenAI
from token_tree import TokenTree

class TokenTreeGenerator:
    def __init__(self, client: OpenAI, prompt: str, temperature = 1.0, max_tokens = 10):
        self.client = client
        self.prompt = prompt
        self.temperature = temperature
        self.max_tokens = max_tokens

        self.root = TokenTree("")
        self.nodes = [self.root]
        self.unexpanded_nodes_heap = [self.root]

    def get_completion(self, text):
        response = self.client.chat.completions.create(
            model = "deepseek-chat",
            messages=[
                {"role": "user", "content": self.prompt},
                {"role": "assistant", "content": text, "prefix": True}
                ],
            temperature = self.temperature,
            max_tokens = self.max_tokens,
            logprobs=True,
            top_logprobs=20)
        return response
    
    def expand_best_node(self):
        node = heapq.heappop(self.unexpanded_nodes_heap)
        self.expand_node_completion(node)
        return node

    def expand_node_completion(self, node):
        response = self.get_completion(node.text)
        if response.choices[0].logprobs == None:
            return
        content = response.choices[0].logprobs.content

        current_node = node
        for el in content:
            token = el.token.replace("\n", "\\n")
            self.expand_node_single(current_node, el.top_logprobs, token)
            if(not token in current_node.children.keys()): #Can happen rarely when a very unlikely token is chosen
                return
            current_node = current_node.children[token]
        heapq.heappush(self.unexpanded_nodes_heap, current_node)

    def expand_node_single(self, node, top_logprobs, heap_exclude):
        for el in top_logprobs:
            logprob = el.logprob
            if logprob > -9999.0:
                child = node.add_child(el.token.replace("\n", "\\n"), el.logprob)

                if el.token != heap_exclude:
                    heapq.heappush(self.unexpanded_nodes_heap, child)
                self.nodes.append(child)
