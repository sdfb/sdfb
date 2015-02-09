--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;

DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS flags CASCADE;
DROP TABLE IF EXISTS group_assignments CASCADE;
DROP TABLE IF EXISTS group_cat_assigns CASCADE;
DROP TABLE IF EXISTS group_categories CASCADE;
DROP TABLE IF EXISTS groups CASCADE;
DROP TABLE IF EXISTS people CASCADE;
DROP TABLE IF EXISTS rel_cat_assigns CASCADE;
DROP TABLE IF EXISTS relationship_categories CASCADE;
DROP TABLE IF EXISTS relationship_types CASCADE;
DROP TABLE IF EXISTS relationships CASCADE;
DROP TABLE IF EXISTS schema_migrations CASCADE;
DROP TABLE IF EXISTS user_group_contribs CASCADE;
DROP TABLE IF EXISTS user_person_contribs CASCADE;
DROP TABLE IF EXISTS user_rel_contribs CASCADE;
DROP TABLE IF EXISTS users CASCADE;



--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: combination_edge_key(); Type: FUNCTION; Schema: public; Owner: sixdfbor_admin
--

CREATE FUNCTION combination_edge_key() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

  begin
    NEW.id := NEW.person1_index::text||NEW.person2_index::text;
    return NEW;
  end;

$$;


ALTER FUNCTION public.combination_edge_key() OWNER TO sixdfbor_admin;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    comment_type character varying(255),
    associated_contrib integer,
    created_by integer,
    content text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE comments OWNER TO sixdfbor_admin;

--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: sixdfbor_admin
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE comments_id_seq OWNER TO sixdfbor_admin;

--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sixdfbor_admin
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: flags; Type: TABLE; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

CREATE TABLE flags (
    id integer NOT NULL,
    assoc_object_type character varying(255),
    assoc_object_id integer,
    flag_description text,
    created_by integer,
    resolved_by integer,
    resolved_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE flags OWNER TO sixdfbor_admin;

--
-- Name: flags_id_seq; Type: SEQUENCE; Schema: public; Owner: sixdfbor_admin
--

CREATE SEQUENCE flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE flags_id_seq OWNER TO sixdfbor_admin;

--
-- Name: flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sixdfbor_admin
--

ALTER SEQUENCE flags_id_seq OWNED BY flags.id;


--
-- Name: group_assignments; Type: TABLE; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

CREATE TABLE group_assignments (
    id integer NOT NULL,
    created_by integer,
    group_id integer,
    person_id integer,
    start_year integer,
    start_month character varying(255),
    start_day integer,
    end_year integer,
    end_month character varying(255),
    end_day integer,
    approved_by integer,
    approved_on timestamp without time zone,
    is_approved boolean,
    is_active boolean DEFAULT true,
    is_rejected boolean DEFAULT false,
    edited_by_on text DEFAULT '--- []
'::text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    person_autocomplete character varying(255)
);


ALTER TABLE group_assignments OWNER TO sixdfbor_admin;

--
-- Name: group_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: sixdfbor_admin
--

CREATE SEQUENCE group_assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE group_assignments_id_seq OWNER TO sixdfbor_admin;

--
-- Name: group_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sixdfbor_admin
--

ALTER SEQUENCE group_assignments_id_seq OWNED BY group_assignments.id;


--
-- Name: group_cat_assigns; Type: TABLE; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

CREATE TABLE group_cat_assigns (
    id integer NOT NULL,
    group_id integer,
    group_category_id integer,
    created_by integer,
    approved_by character varying(255),
    approved_on character varying(255),
    is_approved boolean DEFAULT false,
    is_active boolean DEFAULT true,
    is_rejected boolean DEFAULT false,
    edited_by_on text DEFAULT '--- []
'::text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE group_cat_assigns OWNER TO sixdfbor_admin;

--
-- Name: group_cat_assigns_id_seq; Type: SEQUENCE; Schema: public; Owner: sixdfbor_admin
--

CREATE SEQUENCE group_cat_assigns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE group_cat_assigns_id_seq OWNER TO sixdfbor_admin;

--
-- Name: group_cat_assigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sixdfbor_admin
--

ALTER SEQUENCE group_cat_assigns_id_seq OWNED BY group_cat_assigns.id;


--
-- Name: group_categories; Type: TABLE; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

CREATE TABLE group_categories (
    id integer NOT NULL,
    name character varying(255),
    description text,
    created_by integer,
    approved_by character varying(255),
    approved_on character varying(255),
    is_approved boolean DEFAULT false,
    is_active boolean DEFAULT true,
    is_rejected boolean DEFAULT false,
    edited_by_on text DEFAULT '--- []
'::text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE group_categories OWNER TO sixdfbor_admin;

--
-- Name: group_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: sixdfbor_admin
--

CREATE SEQUENCE group_categories_id_seq
    START WITH 7
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE group_categories_id_seq OWNER TO sixdfbor_admin;

--
-- Name: group_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sixdfbor_admin
--

ALTER SEQUENCE group_categories_id_seq OWNED BY group_categories.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

CREATE TABLE groups (
    id integer NOT NULL,
    created_by integer,
    name character varying(255),
    description text,
    justification text,
    start_year integer,
    end_year integer,
    approved_by character varying(255),
    approved_on character varying(255),
    is_approved boolean DEFAULT false,
    person_list text DEFAULT '--- []
'::text,
    is_active boolean DEFAULT true,
    is_rejected boolean DEFAULT false,
    edited_by_on text DEFAULT '--- []
'::text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE groups OWNER TO sixdfbor_admin;

--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: sixdfbor_admin
--

CREATE SEQUENCE groups_id_seq
    START WITH 76
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE groups_id_seq OWNER TO sixdfbor_admin;

--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sixdfbor_admin
--

ALTER SEQUENCE groups_id_seq OWNED BY groups.id;


--
-- Name: people; Type: TABLE; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

CREATE TABLE people (
    id integer NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    created_by integer,
    historical_significance text,
    rel_sum text DEFAULT '--- []
'::text,
    prefix character varying(255),
    suffix character varying(255),
    search_names_all character varying(255),
    title character varying(255),
    birth_year_type character varying(255),
    ext_birth_year character varying(255),
    alt_birth_year character varying(255),
    death_year_type character varying(255),
    ext_death_year character varying(255),
    alt_death_year character varying(255),
    gender character varying(255),
    justification text,
    approved_by integer,
    approved_on timestamp without time zone,
    odnb_id integer,
    is_approved boolean DEFAULT false,
    group_list text DEFAULT '--- []
'::text,
    is_active boolean DEFAULT true,
    is_rejected boolean DEFAULT false,
    edited_by_on text DEFAULT '--- []
'::text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE people OWNER TO sixdfbor_admin;

--
-- Name: people_id_seq; Type: SEQUENCE; Schema: public; Owner: sixdfbor_admin
--

CREATE SEQUENCE people_id_seq
    START WITH 10050000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE people_id_seq OWNER TO sixdfbor_admin;

--
-- Name: people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sixdfbor_admin
--

ALTER SEQUENCE people_id_seq OWNED BY people.id;


--
-- Name: rel_cat_assigns; Type: TABLE; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

CREATE TABLE rel_cat_assigns (
    id integer NOT NULL,
    relationship_category_id integer,
    relationship_type_id integer,
    created_by integer,
    approved_by character varying(255),
    approved_on character varying(255),
    is_approved boolean DEFAULT false,
    is_active boolean DEFAULT true,
    is_rejected boolean DEFAULT false,
    edited_by_on text DEFAULT '--- []
'::text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE rel_cat_assigns OWNER TO sixdfbor_admin;

--
-- Name: rel_cat_assigns_id_seq; Type: SEQUENCE; Schema: public; Owner: sixdfbor_admin
--

CREATE SEQUENCE rel_cat_assigns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE rel_cat_assigns_id_seq OWNER TO sixdfbor_admin;

--
-- Name: rel_cat_assigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sixdfbor_admin
--

ALTER SEQUENCE rel_cat_assigns_id_seq OWNED BY rel_cat_assigns.id;


--
-- Name: relationship_categories; Type: TABLE; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

CREATE TABLE relationship_categories (
    id integer NOT NULL,
    name character varying(255),
    description text,
    is_approved boolean DEFAULT false,
    approved_by integer,
    approved_on timestamp without time zone,
    created_by integer,
    is_active boolean DEFAULT true,
    is_rejected boolean DEFAULT false,
    edited_by_on text DEFAULT '--- []
'::text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE relationship_categories OWNER TO sixdfbor_admin;

--
-- Name: relationship_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: sixdfbor_admin
--

CREATE SEQUENCE relationship_categories_id_seq
    START WITH 9
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE relationship_categories_id_seq OWNER TO sixdfbor_admin;

--
-- Name: relationship_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sixdfbor_admin
--

ALTER SEQUENCE relationship_categories_id_seq OWNED BY relationship_categories.id;


--
-- Name: relationship_types; Type: TABLE; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

CREATE TABLE relationship_types (
    id integer NOT NULL,
    relationship_type_inverse integer,
    default_rel_category integer,
    name character varying(255),
    description text,
    is_active boolean DEFAULT true,
    approved_by integer,
    approved_on timestamp without time zone,
    is_approved boolean DEFAULT false,
    created_by integer,
    is_rejected boolean DEFAULT false,
    edited_by_on text DEFAULT '--- []
'::text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE relationship_types OWNER TO sixdfbor_admin;

--
-- Name: relationship_types_id_seq; Type: SEQUENCE; Schema: public; Owner: sixdfbor_admin
--

CREATE SEQUENCE relationship_types_id_seq
    START WITH 103
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE relationship_types_id_seq OWNER TO sixdfbor_admin;

--
-- Name: relationship_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sixdfbor_admin
--

ALTER SEQUENCE relationship_types_id_seq OWNED BY relationship_types.id;


--
-- Name: relationships; Type: TABLE; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

CREATE TABLE relationships (
    id bigint,
    original_certainty integer,
    person1_index integer NOT NULL,
    person2_index integer NOT NULL,
    created_by integer,
    max_certainty integer,
    start_year integer,
    start_month character varying(255),
    start_day integer,
    end_year integer,
    end_month character varying(255),
    end_day integer,
    justification text,
    approved_by integer,
    approved_on timestamp without time zone,
    types_list text DEFAULT '--- []
'::text,
    edge_birthdate_certainty integer,
    is_approved boolean DEFAULT false,
    is_active boolean DEFAULT true,
    is_rejected boolean DEFAULT false,
    edited_by_on text DEFAULT '--- []
'::text,
    created_at timestamp without time zone DEFAULT ('now'::text)::date,
    updated_at timestamp without time zone DEFAULT ('now'::text)::date,
    person1_autocomplete character varying(255),
    person2_autocomplete character varying(255)
);


ALTER TABLE relationships OWNER TO sixdfbor_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE schema_migrations OWNER TO sixdfbor_admin;

--
-- Name: user_group_contribs; Type: TABLE; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

CREATE TABLE user_group_contribs (
    id integer NOT NULL,
    group_id integer,
    created_by integer,
    annotation text,
    bibliography text,
    approved_by integer,
    approved_on timestamp without time zone,
    is_approved boolean DEFAULT true,
    is_active boolean DEFAULT true,
    is_rejected boolean DEFAULT false,
    edited_by_on text DEFAULT '--- []
'::text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE user_group_contribs OWNER TO sixdfbor_admin;

--
-- Name: user_group_contribs_id_seq; Type: SEQUENCE; Schema: public; Owner: sixdfbor_admin
--

CREATE SEQUENCE user_group_contribs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE user_group_contribs_id_seq OWNER TO sixdfbor_admin;

--
-- Name: user_group_contribs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sixdfbor_admin
--

ALTER SEQUENCE user_group_contribs_id_seq OWNED BY user_group_contribs.id;


--
-- Name: user_person_contribs; Type: TABLE; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

CREATE TABLE user_person_contribs (
    id integer NOT NULL,
    person_id integer,
    created_by integer,
    annotation text,
    bibliography text,
    approved_by integer,
    approved_on date,
    is_approved boolean DEFAULT true,
    is_active boolean DEFAULT true,
    is_rejected boolean DEFAULT false,
    edited_by_on text DEFAULT '--- []
'::text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    person_autocomplete character varying(255)
);


ALTER TABLE user_person_contribs OWNER TO sixdfbor_admin;

--
-- Name: user_person_contribs_id_seq; Type: SEQUENCE; Schema: public; Owner: sixdfbor_admin
--

CREATE SEQUENCE user_person_contribs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE user_person_contribs_id_seq OWNER TO sixdfbor_admin;

--
-- Name: user_person_contribs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sixdfbor_admin
--

ALTER SEQUENCE user_person_contribs_id_seq OWNED BY user_person_contribs.id;


--
-- Name: user_rel_contribs; Type: TABLE; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

CREATE TABLE user_rel_contribs (
    id integer NOT NULL,
    relationship_id integer,
    created_by integer,
    certainty integer,
    annotation text,
    bibliography text,
    relationship_type_id integer,
    start_year integer,
    start_month character varying(255),
    start_day integer,
    end_year integer,
    end_month character varying(255),
    end_day integer,
    approved_by integer,
    approved_on date,
    is_approved boolean DEFAULT true,
    is_active boolean DEFAULT true,
    is_rejected boolean DEFAULT false,
    edited_by_on text DEFAULT '--- []
'::text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    person1_autocomplete character varying(255),
    person2_autocomplete character varying(255),
    person1_selection character varying(255),
    person2_selection character varying(255)
);


ALTER TABLE user_rel_contribs OWNER TO sixdfbor_admin;

--
-- Name: user_rel_contribs_id_seq; Type: SEQUENCE; Schema: public; Owner: sixdfbor_admin
--

CREATE SEQUENCE user_rel_contribs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE user_rel_contribs_id_seq OWNER TO sixdfbor_admin;

--
-- Name: user_rel_contribs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sixdfbor_admin
--

ALTER SEQUENCE user_rel_contribs_id_seq OWNED BY user_rel_contribs.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    about_description text,
    affiliation character varying(255),
    email character varying(255),
    first_name character varying(255),
    is_active boolean,
    last_name character varying(255),
    password character varying(255),
    password_confirmation character varying(255),
    password_hash character varying(255),
    password_salt character varying(255),
    user_type character varying(255),
    prefix character varying(255),
    orcid character varying(255),
    created_by integer,
    is_curator boolean DEFAULT false,
    curator_revoked boolean DEFAULT false,
    username character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE users OWNER TO sixdfbor_admin;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: sixdfbor_admin
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users_id_seq OWNER TO sixdfbor_admin;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sixdfbor_admin
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sixdfbor_admin
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sixdfbor_admin
--

ALTER TABLE ONLY flags ALTER COLUMN id SET DEFAULT nextval('flags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sixdfbor_admin
--

ALTER TABLE ONLY group_assignments ALTER COLUMN id SET DEFAULT 
nextval('group_assignments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sixdfbor_admin
--

ALTER TABLE ONLY group_cat_assigns ALTER COLUMN id SET DEFAULT 
nextval('group_cat_assigns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sixdfbor_admin
--

ALTER TABLE ONLY group_categories ALTER COLUMN id SET DEFAULT 
nextval('group_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sixdfbor_admin
--

ALTER TABLE ONLY groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sixdfbor_admin
--

ALTER TABLE ONLY people ALTER COLUMN id SET DEFAULT nextval('people_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sixdfbor_admin
--

ALTER TABLE ONLY rel_cat_assigns ALTER COLUMN id SET DEFAULT 
nextval('rel_cat_assigns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sixdfbor_admin
--

ALTER TABLE ONLY relationship_categories ALTER COLUMN id SET DEFAULT 
nextval('relationship_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sixdfbor_admin
--

ALTER TABLE ONLY relationship_types ALTER COLUMN id SET DEFAULT 
nextval('relationship_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sixdfbor_admin
--

ALTER TABLE ONLY user_group_contribs ALTER COLUMN id SET DEFAULT 
nextval('user_group_contribs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sixdfbor_admin
--

ALTER TABLE ONLY user_person_contribs ALTER COLUMN id SET DEFAULT 
nextval('user_person_contribs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sixdfbor_admin
--

ALTER TABLE ONLY user_rel_contribs ALTER COLUMN id SET DEFAULT 
nextval('user_rel_contribs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sixdfbor_admin
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: flags_pkey; Type: CONSTRAINT; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

ALTER TABLE ONLY flags
    ADD CONSTRAINT flags_pkey PRIMARY KEY (id);


--
-- Name: group_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

ALTER TABLE ONLY group_assignments
    ADD CONSTRAINT group_assignments_pkey PRIMARY KEY (id);


--
-- Name: group_cat_assigns_pkey; Type: CONSTRAINT; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

ALTER TABLE ONLY group_cat_assigns
    ADD CONSTRAINT group_cat_assigns_pkey PRIMARY KEY (id);


--
-- Name: group_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

ALTER TABLE ONLY group_categories
    ADD CONSTRAINT group_categories_pkey PRIMARY KEY (id);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: people_pkey; Type: CONSTRAINT; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: rel_cat_assigns_pkey; Type: CONSTRAINT; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

ALTER TABLE ONLY rel_cat_assigns
    ADD CONSTRAINT rel_cat_assigns_pkey PRIMARY KEY (id);


--
-- Name: relationship_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: sixdfbor_admin; 
Tablespace: 
--

ALTER TABLE ONLY relationship_categories
    ADD CONSTRAINT relationship_categories_pkey PRIMARY KEY (id);


--
-- Name: relationship_types_pkey; Type: CONSTRAINT; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

ALTER TABLE ONLY relationship_types
    ADD CONSTRAINT relationship_types_pkey PRIMARY KEY (id);


--
-- Name: relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

ALTER TABLE ONLY relationships
    ADD CONSTRAINT relationships_pkey PRIMARY KEY (person1_index, person2_index);


--
-- Name: user_group_contribs_pkey; Type: CONSTRAINT; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

ALTER TABLE ONLY user_group_contribs
    ADD CONSTRAINT user_group_contribs_pkey PRIMARY KEY (id);


--
-- Name: user_person_contribs_pkey; Type: CONSTRAINT; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

ALTER TABLE ONLY user_person_contribs
    ADD CONSTRAINT user_person_contribs_pkey PRIMARY KEY (id);


--
-- Name: user_rel_contribs_pkey; Type: CONSTRAINT; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

ALTER TABLE ONLY user_rel_contribs
    ADD CONSTRAINT user_rel_contribs_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: sixdfbor_admin; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: combination_edge_key_trigger; Type: TRIGGER; Schema: public; Owner: sixdfbor_admin
--

CREATE TRIGGER combination_edge_key_trigger BEFORE INSERT ON relationships FOR EACH ROW EXECUTE 
PROCEDURE combination_edge_key();


--
-- Name: relationships_person1_index_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sixdfbor_admin
--

ALTER TABLE ONLY relationships
    ADD CONSTRAINT relationships_person1_index_fkey FOREIGN KEY (person1_index) REFERENCES people(id);


--
-- Name: relationships_person2_index_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sixdfbor_admin
--

ALTER TABLE ONLY relationships
    ADD CONSTRAINT relationships_person2_index_fkey FOREIGN KEY (person2_index) REFERENCES people(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: sixdfbor_admin
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
-- REVOKE ALL ON SCHEMA public FROM sixdfbor_admin;
-- GRANT ALL ON SCHEMA public TO sixdfbor_admin;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--


