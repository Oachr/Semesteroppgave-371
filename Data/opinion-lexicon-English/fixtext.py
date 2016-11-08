
import sys


with open("negative_ord.txt") as f:
    content = [line.rstrip('\n') for line in f]
    

str_list = filter(None, content) # fastest
[x for x in str_list if " " in x]

with open("negative_ord.txt", 'w') as f:
    for s in str_list:
        f.write(s + '\n')


