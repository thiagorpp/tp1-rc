import networkx as nx
import matplotlib.pyplot as plt
import csv
import random

eRows = csv.reader(open('data/edges100.csv'))

G=nx.Graph()

for row in eRows:
	n1, n2, weight = row[0], row[1], 1
	G.add_edge(n1, n2, weight=weight)

pos=dict((G.nodes()[i],(random.gauss(0,2),random.gauss(0,2))) for i in range(G.number_of_nodes()))
nx.set_node_attributes(G, 'pos', pos)
pos=nx.get_node_attributes(G,'pos')

dmin=1
ncenter=0
for n in pos:
    x,y=pos[n]
    d=(x-0.5)**2+(y-0.5)**2
    if d<dmin:
        ncenter=n
        dmin=d

# color by path length from node near center
p=nx.single_source_shortest_path_length(G,ncenter)

plt.figure(figsize=(20,20))
nx.draw_networkx_edges(G,pos,nodelist=[ncenter],alpha=0.4)
nx.draw_networkx_nodes(G,pos,nodelist=p.keys(),
                       node_size=80,
                       node_color=p.values(),
                       cmap=plt.cm.Reds_r)

# plt.xlim(-0.05,1.05)
# plt.ylim(-0.05,1.05)
plt.axis('off')
plt.savefig('graph100.png')
plt.show()
