import networkx as nx
import matplotlib.pyplot as plt
import csv

# read data files
eRows = csv.reader(open('data/edges1.csv'))

G=nx.Graph()

for row in eRows:
	n1, n2, weight = row[0], row[1], row[2]
	G.add_edge(n1, n2, weight=weight)

# b) grau (degree)
print "Writing B) degree"
with open("results/b-degree.csv", 'w') as f:
	writer = csv.writer(f)
	for v in sorted(G.degree().values()):
		writer.writerow([v])

# c) clusterizacao de cada no e do grafo
print "Writing C) cluster"
with open("results/c-nodes_cluster.csv", 'w') as f:
	writer = csv.writer(f)
	for v in sorted(nx.clustering(G).values()):
		writer.writerow([v])

with open("results/c-graph_cluster.csv", 'w') as f:
	writer = csv.writer(f)
	writer.writerow([nx.average_clustering(G)])

# d) Components
print "Writing D) components"
with open("results/d-components_size.csv", 'w') as f:
	writer = csv.writer(f)
	for l in sorted(nx.connected_components(G), reverse=True):
		writer.writerow([len(l)])

# e) overlap
print "Writing E) overlap"
with open("results/e-overlap30.csv", 'w') as f:
	writer = csv.writer(f)
	print G.number_of_nodes()
	for i in range(0, G.number_of_nodes()):
		overlaps = []
		for j in range(i+1, G.number_of_nodes()):
			source = G.nodes()[i]
			target = G.nodes()[j]

			if source in G.edge and target in G.edge[source]:

				common = sorted(nx.common_neighbors(G, source, target))
				union = set(nx.all_neighbors(G,source)) | set(nx.all_neighbors(G, target))

				if len(union) == 0:
					overlaps.append(0.0)

				else:
					overlaps.append("%.2f" % (len(common)/float(len(union))))

		for over in overlaps:
			writer.writerow([over])
		print i

# f) distance
print "Writing G) distance"
with open("results/g-distance30.csv", 'w') as f:
	writer = csv.writer(f)

	print G.number_of_nodes()
	for i in range(0, G.number_of_nodes()):
		print i
		dists = []
		for j in range(i+1, G.number_of_nodes()):
			source = G.nodes()[i]
			target = G.nodes()[j]

			dists.append(nx.shortest_path_length(G,source=source,target=target))

		for d in dists:
			writer.writerow([d])

# g) betweeness
print "Writing G) betweeness nodes"
with open("results/g-betweeness-nodes.csv", 'w') as f:
	writer = csv.writer(f)
	bb = nx.betweenness_centrality(G)
	for v in sorted(bb):
		writer.writerow([bb[v]])

print "Writing G) betweeness edges"
with open("results/g-betweeness-edges.csv", 'w') as f:
	writer = csv.writer(f)
	bb = nx.edge_betweenness_centrality(G)
	for v in sorted(bb):
		writer.writerow([bb[v]])

# h) local bridges
for i in range(0, G.number_of_nodes()):
	canditates = []
	for j in range(i+1, G.number_of_nodes()):
		source = G.nodes()[i]
		target = G.nodes()[j]

		if source in G.edge and target in G.edge[source]:
			common = sorted(nx.common_neighbors(G, G.nodes()[i], G.nodes()[j]))
			union = set(nx.all_neighbors(G, G.nodes()[i])) | set(nx.all_neighbors(G, G.nodes()[j]))

			overlap = len(common)/float(len(union))

			if overlap == 0:
				canditates.append((source, target))


print "Nodes:", G.number_of_nodes()
print "Edges:", G.number_of_edges()
