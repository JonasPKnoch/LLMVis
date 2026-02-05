import os
from openai import OpenAI
from compare import ConceptCompare
import numpy as np
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("prompt1", help="First prompt for the LLM")
parser.add_argument("prompt2", help="Second prompt for the LLM")
parser.add_argument("iterations", help="Number of times to expand the tree")
args = parser.parse_args()

client = OpenAI(api_key="sk-86203aa4deec4941ad33ae0e97e6c102", base_url="https://api.deepseek.com/beta")

cc = ConceptCompare(client, 
args.prompt1,
args.prompt2)

cc.expand_trees(int(args.iterations))