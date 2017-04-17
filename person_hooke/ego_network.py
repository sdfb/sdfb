#! /usr/bin/env python3

import psycopg2
import networkx as nx
import json

# Connect to database and open cursor
conn = psycopg2.connect('dbname=mysdfb')
cur = conn.cursor()

# Get nodes as list of tuples from database
cur.execute("SELECT id, display_name, historical_significance, ext_birth_year, ext_death_year, group_list FROM people WHERE is_approved = true;")
node_tuples = cur.fetchall()

# Get edges as list of tuples from database
cur.execute("SELECT person1_index, person2_index, max_certainty, last_edit, types_list, id FROM relationships WHERE is_approved = true AND max_certainty >= 60;")
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
    print(e[3])
    if e[3] == None or e[3] == '--- []\n':
        altered[(e[0], e[1])] = False
        print('none!')
    elif e[3].split()[2] == '2':# and e[4] != '--- []\n':
        altered[(e[0], e[1])] = False
        print('not altered!')
    else:
        altered[(e[0], e[1])] = True

edge_id = {(e[0], e[1]):e[-1] for e in edge_tuples}

print('Number of edges:', len(edges))

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
nx.set_edge_attributes(G, 'edge_id', edge_id)

# Create subgraph

bacon = 10000473
one_degree = G.neighbors(bacon)
two_degree = list(set(sum([G.neighbors(n) for n in one_degree], [])))

all_nodes = [bacon] + one_degree + two_degree
# distance_dict = {}
# source_dict = {}
# for a in all_nodes:
#     if a == bacon:
#         distance_dict[a] = 0
#     elif a in one_degree:
#         distance_dict[a] = 1
#     else:
#         distance_dict[a] = 2

SG = G.subgraph(all_nodes)

# nx.set_node_attributes(SG, 'distance', distance_dict)

# Create a dictionary for the JSON needed by D3.
new_data = dict(
        data=dict(
            type='networks',
            id='1',
            attributes=dict(
                nodes=[dict(
                    id=n,
                    person_info=dict(name=SG.node[n]['name']),
                    degree=SG.node[n]['degree']) for n in SG.nodes()],
                links=[dict(
                    source=e[0],
                    target=e[1],
                    weight=e[2]['weight'],
                    altered=e[2]['altered'],
                    id=e[2]['edge_id']) for e in SG.edges(data=True)])),
        errors=[dict(
            status='404',
            title='Page not found')],
        meta=dict(
            principal_investigators=['Daniel Shore', 'Chris Warren', 'Jessica Otis']),
        included=dict(
            type='people',
            id=str(bacon),
            name=SG.node[bacon]['name'],
            historical_significance=SG.node[bacon]['historical_significance'],
            birth_year=SG.node[bacon]['birth_year'],
            death_year=SG.node[bacon]['death_year'])
        )
# Output json of the graph.
with open('baconnetwork.json', 'w') as output:
        json.dump(new_data, output, sort_keys=True, indent=4, separators=(',',':'))
