#! /usr/bin/env python3

import psycopg2, sys, time, csv
from psycopg2 import extras

def open_cursor(database_name):
    conn = psycopg2.connect('dbname='+database_name)
    dict_cur = conn.cursor(cursor_factory=extras.DictCursor)
    return dict_cur

def make_nodelist(current_time, dict_cur):
    # Get nodes as list of dictionaries from database
    dict_cur.execute("SELECT id, first_name, last_name, created_by, historical_significance, prefix, suffix, title, birth_year_type, ext_birth_year, alt_birth_year, death_year_type, ext_death_year, alt_death_year, gender, justification, approved_by, approved_on, odnb_id, created_at, updated_at, display_name, search_names_all, bibliography, aliases FROM people WHERE is_approved = true;")
    node_dicts = dict_cur.fetchall()
    node_dicts = [dict(n) for n in node_dicts]
    keys = list(node_dicts[0].keys())
    with open('angular/app/data/SDFB_people_'+current_time+'.csv', 'w') as output_file:
        dict_writer = csv.DictWriter(output_file, keys)
        dict_writer.writeheader()
        dict_writer.writerows(node_dicts)

def make_edgelist(current_time, dict_cur):
    # Get nodes as list of dictionaries from database
    dict_cur.execute("SELECT id, person1_index, person2_index, max_certainty, original_certainty, created_by, start_year, end_year, approved_by, start_date_type, end_date_type, bibliography, types_list FROM relationships WHERE is_approved = true;")
    edge_dicts = dict_cur.fetchall()
    edge_dicts = [dict(n) for n in edge_dicts]
    keys = list(edge_dicts[0].keys())
    with open('angular/app/data/SDFB_relationships_'+current_time+'.csv', 'w') as output_file:
        dict_writer = csv.DictWriter(output_file, keys)
        dict_writer.writeheader()
        dict_writer.writerows(edge_dicts)

if __name__ == '__main__':
    database_name = sys.argv[1]
    current_time = time.strftime("%Y_%m_%d", time.gmtime())
    dict_cur = open_cursor(database_name)
    make_nodelist(current_time, dict_cur)
    make_edgelist(current_time, dict_cur)