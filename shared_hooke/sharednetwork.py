#! /usr/bin/env python3

import psycopg2
import networkx as nx
import json
from networkx.algorithms import centrality as cn
from networkx.algorithms import connectivity as ct

# Connect to database and open cursor
conn = psycopg2.connect('dbname=mysdfb')
cur = conn.cursor()

# Get nodes as list of tuples from database
cur.execute("SELECT id, display_name, historical_significance, ext_birth_year, ext_death_year FROM people;")
node_tuples = cur.fetchall()

# Get edges as list of tuples from database
cur.execute("SELECT person1_index, person2_index, max_certainty, last_edit, types_list FROM relationships WHERE max_certainty >=60;")
edge_tuples = cur.fetchall()

print('Total number of nodes:', len(node_tuples))


# Make node list into a dictionary (for NetworkX attribute input)
name_dict = {}
sig_dict = {}
birth_dict = {}
death_dict = {}
for n in node_tuples:
    name_dict[n[0]] = n[1]
    sig_dict[n[0]] = n[2]
    birth_dict[n[0]] = n[3]
    death_dict[n[0]] = n[4]

# Get a list of only the node ids
node_ids = list(name_dict.keys())

edges = []
altered = {}
for e in edge_tuples:
    edges.append((e[0], e[1], e[2]))
    if e[3] == None:
        altered[(e[0], e[1])] = False
        print('none!')
    elif e[3].split()[2] == '2':# and e[4] != '--- []\n':
        altered[(e[0], e[1])] = False
        print('not altered!')
    else:
        altered[(e[0], e[1])] = True


print('Number of edges with confidence 60% and above:', len(edges))

# Build full network using NetworkX
G = nx.Graph()
G.add_nodes_from(node_ids)
G.add_weighted_edges_from(edges)

# Calculate three centrality measures
degree = cn.degree_centrality(G)
#betweenness = cn.betweenness_centrality(G, weight='weight')
#eigenvector = cn.eigenvector_centrality(G, weight='weight')

# Add display_name and centrality as node attributes
nx.set_node_attributes(G, 'name', name_dict)
nx.set_node_attributes(G, 'degree', G.degree(G.nodes()))#degree)
nx.set_node_attributes(G, 'historical_significance', sig_dict)
nx.set_node_attributes(G, 'birth_year', birth_dict)
nx.set_node_attributes(G, 'death_year', death_dict)

nx.set_edge_attributes(G, 'altered', altered)
# Create subgraph based on Cavendish and Glanvill:

    # 1. Get ids for Glanvill and Cavendish
glanvill_id = [n[0] for n in node_tuples if n[1] == "Joseph Glanvill"]
cavendish_ids = [n[0] for n in node_tuples if n[1] == "Margaret Cavendish"] #There are 3 Margaret Cavendishes in the database, I know I need the second one (index #1)

glanvill_neighbors = G.neighbors(glanvill_id[0])
cavendish_neighbors = G.neighbors(cavendish_ids[1])
one_degree = glanvill_neighbors + cavendish_neighbors + [glanvill_id[0], cavendish_ids[1]]
print(one_degree)


SG = G.subgraph(one_degree)

color_dict = {}
for n in SG.nodes():
    if n == glanvill_id[0]:
        color_dict[n] = 0
    if n in glanvill_neighbors and SG.degree(n) == 1:
        color_dict[n] = 0
    if n == cavendish_ids[1]:
        color_dict[n] = 4
    if n in cavendish_neighbors and SG.degree(n) == 1:
        color_dict[n] = 4
    if n in glanvill_neighbors and n in cavendish_neighbors:
        color_dict[n] = 2
    if n in cavendish_neighbors and n not in glanvill_neighbors and SG.degree(n) != 1:
        color_dict[n] = 3
    if n in glanvill_neighbors and n not in cavendish_neighbors and SG.degree(n) != 1:
        color_dict[n] = 1

print(SG.edges(data=True))
nx.set_node_attributes(SG, 'color', color_dict)
# Create a dictionary for the JSON needed by D3.
new_data = dict(
        nodes=[dict(
            id=n,
            name=SG.node[n]['name'],
            degree=SG.node[n]['degree'],
            # connected_path=SG.node[n]['connected_path'],
            # shortest_path=SG.node[n]['shortest_path'],
            historical_significance=SG.node[n]['historical_significance'],
            birth_year=SG.node[n]['birth_year'],
            death_year=SG.node[n]['death_year'],
            color=SG.node[n]['color']) for n in SG.nodes()],
        links=[dict(
            source=e[0],
            target=e[1],
            weight=e[2]['weight'],
            altered=e[2]['altered']) for e in SG.edges(data=True)])

# Output json of the graph.
with open('sharednetwork.json', 'w') as output:
        json.dump(new_data, output, sort_keys=True, indent=4, separators=(',',':'))
