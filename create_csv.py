#! /usr/bin/env python3

import psycopg2, sys, time, csv, json, os, glob
from psycopg2 import extras

def open_cursor(database_name, password):
    conn = psycopg2.connect(dbname=database_name, user='postgres', password=password)
    dict_cur = conn.cursor(cursor_factory=extras.DictCursor)
    return dict_cur

def make_nodelist(current_time, dict_cur):
    # Get nodes as list of dictionaries from database
    dict_cur.execute("SELECT id, first_name, last_name, created_by, historical_significance, prefix, suffix, title, birth_year_type, birth_year, death_year_type, death_year, gender, approved_by, approved_on, odnb_id, created_at, updated_at, display_name, search_names_all, citation, aliases FROM people WHERE is_approved = true;")
    node_dicts = dict_cur.fetchall()
    node_dicts = [dict(n) for n in node_dicts]
    keys = ['id', 'display_name', 'first_name', 'last_name', 'created_by', 'historical_significance', 'prefix', 'suffix', 'title', 'birth_year_type', 'birth_year', 'death_year_type', 'death_year', 'gender', 'approved_by', 'approved_on', 'odnb_id', 'created_at', 'updated_at', 'search_names_all', 'citation', 'aliases']
    filename = '/var/www/sdfb/angular/dist/data/SDFB_people_{}.csv'.format(current_time)
    with open(filename, 'w') as output_file:
        dict_writer = csv.DictWriter(output_file, keys)
        dict_writer.writeheader()
        dict_writer.writerows(node_dicts)

def make_edgelist(current_time, dict_cur):
    # Get relationships as list of dictionaries from database
    dict_cur.execute("SELECT id, person1_index, person2_index, max_certainty, original_certainty, created_by, start_year, end_year, approved_by, start_date_type, end_date_type, citation FROM relationships WHERE is_approved = true;")
    edge_dicts = dict_cur.fetchall()
    edge_dicts = [dict(n) for n in edge_dicts]
    keys = ['id', 'person1_index', 'person2_index', 'max_certainty', 'original_certainty', 'created_by', 'start_date_type', 'start_year', 'end_date_type', 'end_year', 'approved_by', 'citation']
    filename = '/var/www/sdfb/angular/dist/data/SDFB_relationships_{}.csv'.format(current_time)
    with open(filename, 'w') as output_file:
        dict_writer = csv.DictWriter(output_file, keys)
        dict_writer.writeheader()
        dict_writer.writerows(edge_dicts)

def make_grouplist(current_time, dict_cur):
    # Get groups as list of dictionaries from database
    dict_cur.execute("SELECT id, name, description, start_date_type, start_year, end_date_type, end_year, created_by, created_at, approved_by, approved_on, citation FROM groups WHERE is_approved = true;")
    edge_dicts = dict_cur.fetchall()
    edge_dicts = [dict(n) for n in edge_dicts]
    keys = ['id', 'name', 'description', 'start_date_type', 'start_year', 'end_date_type', 'end_year', 'created_by', 'created_at', 'approved_by', 'approved_on', 'citation']
    filename = '/var/www/sdfb/angular/dist/data/SDFB_groups_{}.csv'.format(current_time)
    with open(filename, 'w') as output_file:
        dict_writer = csv.DictWriter(output_file, keys)
        dict_writer.writeheader()
        dict_writer.writerows(edge_dicts)

def make_groupassignments(current_time, dict_cur):
    # Get group assignments as list of dictionaries from database
    dict_cur.execute("SELECT id, group_id, person_id, start_date_type, start_year, end_date_type, end_year, created_by, created_at, approved_by, approved_on, citation FROM group_assignments WHERE is_approved = true;")
    edge_dicts = dict_cur.fetchall()
    edge_dicts = [dict(n) for n in edge_dicts]
    keys = ['id', 'group_id', 'person_id', 'start_date_type', 'start_year', 'end_date_type', 'end_year', 'created_by', 'created_at', 'approved_by', 'approved_on', 'citation']
    filename = '/var/www/sdfb/angular/dist/data/SDFB_group_assignments_{}.csv'.format(current_time)
    with open(filename, 'w') as output_file:
        dict_writer = csv.DictWriter(output_file, keys)
        dict_writer.writeheader()
        dict_writer.writerows(edge_dicts)

def make_relationshiptypes(current_time, dict_cur):
    with open('/var/www/sdfb/angular/dist/data/rel_cats.json', 'r') as reltypefile:
        reltypes = json.loads(reltypefile.read())
    reltypes = {r['id']:r for r in reltypes}
    dict_cur.execute("SELECT id, relationship_id, relationship_type_id, certainty, start_date_type, start_year, end_date_type, end_year, created_by, created_at, approved_by, approved_on, citation FROM user_rel_contribs WHERE is_approved = true;")
    edge_dicts = dict_cur.fetchall()
    edge_dicts = [dict(n) for n in edge_dicts]
    new_edge_dicts = []
    for e in edge_dicts:
        e['relationship_type_name'] = reltypes[e['relationship_type_id']]['name']
        e['relationship_category'] = reltypes[e['relationship_type_id']]['category']
        new_edge_dicts.append(e)
    keys = ['id', 'relationship_id', 'relationship_type_id', 'relationship_type_name', 'relationship_category', 'certainty', 'start_date_type', 'start_year', 'end_date_type', 'end_year', 'created_by', 'created_at', 'approved_by', 'approved_on', 'citation']
    filename = '/var/www/sdfb/angular/dist/data/SDFB_relationship_types_{}.csv'.format(current_time)
    with open(filename, 'w') as output_file:
        dict_writer = csv.DictWriter(output_file, keys)
        dict_writer.writeheader()
        dict_writer.writerows(edge_dicts)

if __name__ == '__main__':
    database_name = sys.argv[1]
    password = sys.argv[2]
    for f in glob.glob('/var/www/sdfb/angular/dist/data/SDFB*'):
        os.remove(f)
    current_time = time.strftime("%Y_%m_%d", time.gmtime())
    dict_cur = open_cursor(database_name, password)
    make_nodelist(current_time, dict_cur)
    make_edgelist(current_time, dict_cur)
    make_grouplist(current_time, dict_cur)
    make_groupassignments(current_time, dict_cur)
    make_relationshiptypes(current_time, dict_cur)
