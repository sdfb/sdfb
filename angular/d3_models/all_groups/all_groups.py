#! /usr/bin/env python3

import psycopg2
import networkx as nx
import json
from itertools import permutations
from collections import Counter

# Connect to database and open cursor
conn = psycopg2.connect('dbname=mysdfb')
cur = conn.cursor()

cur.execute("SELECT person_id, group_id FROM group_assignments WHERE is_approved=true;")
group_tuples = cur.fetchall()

cur.execute("SELECT id, name, description, start_year, end_year, start_date_type, end_date_type FROM groups WHERE is_approved=true;")
group_info = cur.fetchall()

nodes = list(set([g[0] for g in group_info]))
print(nodes)


groups_by_person = {}
for g in group_tuples:
    if g[0] not in groups_by_person:
        groups_by_person[g[0]] = [g[1]]
    else:
        groups_by_person[g[0]].append(g[1])

edges = [list(permutations(v, 2)) for v in groups_by_person.values() if len(v) > 1]
edges = sum(edges, [])
edges = [e for e in edges if not any(i == 84 for i in e) and not any(i==107 for i in e)]
counted_edges = Counter(edges)
weighted_edges = [(k[0], k[1], v) for k,v in counted_edges.items()]


G = nx.Graph()
G.add_nodes_from(nodes)
G.add_weighted_edges_from(weighted_edges)


name_dict = {}
description_dict = {}
start_year_dict = {}
end_year_dict = {}
start_type_dict = {}
end_type_dict = {}
for n in group_info:
    name_dict[n[0]] = n[1]
    description_dict[n[0]] = n[2]
    start_year_dict[n[0]] = n[3]
    end_year_dict[n[0]] = n[4]
    start_type_dict[n[0]] = n[5]
    end_type_dict[n[0]] = n[6]

nx.set_node_attributes(G, 'name', name_dict)
nx.set_node_attributes(G, 'degree',  G.degree(G.nodes()))
nx.set_node_attributes(G, 'description', description_dict)
nx.set_node_attributes(G, 'start_year', start_year_dict)
nx.set_node_attributes(G, 'end_year', end_year_dict)
nx.set_node_attributes(G, 'start_year_type', start_type_dict)
nx.set_node_attributes(G, 'end_year_type', end_type_dict)

print([(n) for n in G.nodes()])

new_data = dict(
        data=dict(
            type='network',
            id="all_groups",
            attributes=dict(
                connections=[dict(
                    type="relationship",
                    attributes=dict(
                        source=e[0],
                        target=e[1],
                        weight=e[2]['weight']
                    )
                ) for e in G.edges(data=True)])),
        meta=dict(
            principal_investigators=['Daniel Shore', 'Chris Warren', 'Jessica Otis']),
        included=[dict(
            id=n,
            type="group",
            attributes = dict(
                name=G.node[n]['name'],
                degree=G.node[n]['degree'],
                description=G.node[n]['description'],
                start_year=G.node[n]['start_year'],
                end_year=G.node[n]['end_year'],
                start_year_type=G.node[n]['start_year_type'],
                end_year_type=G.node[n]['end_year_type']
            )) for n in G.nodes()]
        )

# Output json of the graph.
with open('allgroups.json', 'w') as output:
        json.dump(new_data, output, sort_keys=True, indent=4, separators=(',',':'))
