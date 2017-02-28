#! /usr/bin/env python3

import psycopg2
import networkx as nx
import json

# Connect to database and open cursor
conn = psycopg2.connect('dbname=mysdfb')
cur = conn.cursor()

# Get nodes as list of tuples from database
cur.execute("SELECT id, display_name, historical_significance, ext_birth_year, ext_death_year, group_list FROM people;")
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


# Add display_name and centrality as node attributes
nx.set_node_attributes(G, 'name', name_dict)
nx.set_node_attributes(G, 'degree',  G.degree(G.nodes()))
nx.set_node_attributes(G, 'historical_significance', sig_dict)
nx.set_node_attributes(G, 'birth_year', birth_dict)
nx.set_node_attributes(G, 'death_year', death_dict)

nx.set_edge_attributes(G, 'altered', altered)

# Create subgraph

bacon = 10000473
one_degree = G.neighbors(bacon)
two_degree = list(set(sum([G.neighbors(n) for n in one_degree], [])))

all_nodes = [bacon] + one_degree + two_degree
connected_dict = {}
source_dict = {}
for a in all_nodes:
    if a in one_degree or a == bacon:
        connected_dict[a] = True
    else:
        connected_dict[a] = False

for a in all_nodes:
    if a == bacon:
        source_dict[a] = True
    else:
        source_dict[a] = False

SG = G.subgraph(all_nodes)

nx.set_node_attributes(SG, 'connected', connected_dict)
nx.set_node_attributes(SG, 'is_source', source_dict)

# Create a dictionary for the JSON needed by D3.
new_data = dict(
        nodes=[dict(
            id=n,
            name=SG.node[n]['name'],
            degree=SG.node[n]['degree'],
            one_degree=SG.node[n]['connected'],
            is_source=SG.node[n]['is_source'],
            # group=SG.node[n]['group'],
            historical_significance=SG.node[n]['historical_significance'],
            birth_year=SG.node[n]['birth_year'],
            death_year=SG.node[n]['death_year']) for n in SG.nodes()],
        links=[dict(
            source=e[0],
            target=e[1],
            weight=e[2]['weight'],
            altered=e[2]['altered']) for e in SG.edges(data=True)])
# Output json of the graph.
with open('baconnetwork.json', 'w') as output:
        json.dump(new_data, output, sort_keys=True, indent=4, separators=(',',':'))
