--
-- PostgreSQL database dump
--

-- Dumped from database version 10.23 (Ubuntu 10.23-0ubuntu0.18.04.2)
-- Dumped by pg_dump version 14.18 (Ubuntu 14.18-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

--
-- Name: customer; Type: TABLE; Schema: public; Owner: mpanek
--

CREATE TABLE public.customer (
    customer_id integer NOT NULL,
    first_name character varying,
    last_name character varying,
    email character varying,
    address_id integer,
    active boolean,
    CONSTRAINT customer_email_check CHECK (("position"((email)::text, '@'::text) > 1)),
    CONSTRAINT first_name_capital_check CHECK (("substring"((first_name)::text, 1, 1) = upper("substring"((first_name)::text, 1, 1)))),
    CONSTRAINT last_name_capital_check CHECK (("substring"((last_name)::text, 1, 1) = upper("substring"((last_name)::text, 1, 1))))
);


ALTER TABLE public.customer OWNER TO mpanek;

--
-- Name: rental; Type: TABLE; Schema: public; Owner: mpanek
--

CREATE TABLE public.rental (
    rental_id integer NOT NULL,
    rental_date date,
    inventory_id integer,
    customer_id integer,
    return_date date,
    staff_id integer,
    CONSTRAINT rental_dates_check CHECK ((return_date >= rental_date))
);


ALTER TABLE public.rental OWNER TO mpanek;

--
-- Name: active_customer_rental; Type: VIEW; Schema: public; Owner: mpanek
--

CREATE VIEW public.active_customer_rental AS
 SELECT c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    count(r.rental_id) AS total_rentals
   FROM (public.customer c
     JOIN public.rental r ON ((c.customer_id = r.customer_id)))
  WHERE (c.active = true)
  GROUP BY c.customer_id, c.first_name, c.last_name, c.email;


ALTER TABLE public.active_customer_rental OWNER TO mpanek;

--
-- Name: address; Type: TABLE; Schema: public; Owner: pjasiak
--

CREATE TABLE public.address (
    address_id integer NOT NULL,
    address character varying NOT NULL,
    address2 integer,
    district character varying NOT NULL,
    city_id integer,
    postal_code character varying NOT NULL,
    phone character varying,
    CONSTRAINT address_number_positive CHECK ((address2 > 0)),
    CONSTRAINT phone_number_format CHECK (((phone)::text ~ '^\d{9}$'::text))
);


ALTER TABLE public.address OWNER TO pjasiak;

--
-- Name: author; Type: TABLE; Schema: public; Owner: kserocki
--

CREATE TABLE public.author (
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    author_id integer NOT NULL,
    CONSTRAINT first_name_check CHECK (("substring"((first_name)::text, 1, 1) = upper("substring"((first_name)::text, 1, 1))))
);


ALTER TABLE public.author OWNER TO kserocki;

--
-- Name: book; Type: TABLE; Schema: public; Owner: kserocki
--

CREATE TABLE public.book (
    book_id integer NOT NULL,
    title character varying NOT NULL,
    description character varying NOT NULL,
    release_year integer NOT NULL,
    length integer NOT NULL,
    replacement_cost numeric NOT NULL,
    language_id integer NOT NULL,
    CONSTRAINT book_length_check CHECK ((length > 0)),
    CONSTRAINT book_release_year_check CHECK ((release_year <= 2025)),
    CONSTRAINT book_replacement_cost_check CHECK ((replacement_cost > (0)::numeric))
);


ALTER TABLE public.book OWNER TO kserocki;

--
-- Name: book_author; Type: TABLE; Schema: public; Owner: kserocki
--

CREATE TABLE public.book_author (
    book_id integer NOT NULL,
    author_id integer NOT NULL
);


ALTER TABLE public.book_author OWNER TO kserocki;

--
-- Name: book_category; Type: TABLE; Schema: public; Owner: kserocki
--

CREATE TABLE public.book_category (
    book_id integer NOT NULL,
    category_id integer NOT NULL
);


ALTER TABLE public.book_category OWNER TO kserocki;

--
-- Name: category; Type: TABLE; Schema: public; Owner: kserocki
--

CREATE TABLE public.category (
    category_id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.category OWNER TO kserocki;

--
-- Name: book_cat_desc; Type: VIEW; Schema: public; Owner: kserocki
--

CREATE VIEW public.book_cat_desc AS
 SELECT DISTINCT b.title,
    c.name AS category,
    b.description
   FROM ((public.book b
     JOIN public.book_category bc ON ((b.book_id = bc.book_id)))
     JOIN public.category c ON ((bc.category_id = c.category_id)));


ALTER TABLE public.book_cat_desc OWNER TO kserocki;

--
-- Name: city; Type: TABLE; Schema: public; Owner: pjasiak
--

CREATE TABLE public.city (
    city_id integer NOT NULL,
    city character varying NOT NULL,
    country_id integer,
    CONSTRAINT first_letter CHECK (("left"((city)::text, 1) = upper("left"((city)::text, 1))))
);


ALTER TABLE public.city OWNER TO pjasiak;

--
-- Name: country; Type: TABLE; Schema: public; Owner: pjasiak
--

CREATE TABLE public.country (
    country_id integer NOT NULL,
    country character varying NOT NULL,
    CONSTRAINT first_letter CHECK (("left"((country)::text, 1) = upper("left"((country)::text, 1))))
);


ALTER TABLE public.country OWNER TO pjasiak;

--
-- Name: customer_address; Type: VIEW; Schema: public; Owner: mpanek
--

CREATE VIEW public.customer_address AS
 SELECT c.customer_id,
    c.first_name,
    c.last_name,
    a.address,
    a.address2,
    a.district,
    a.postal_code,
    ci.city,
    co.country
   FROM (((public.customer c
     JOIN public.address a ON ((c.address_id = a.address_id)))
     JOIN public.city ci ON ((a.city_id = ci.city_id)))
     JOIN public.country co ON ((ci.country_id = co.country_id)));


ALTER TABLE public.customer_address OWNER TO mpanek;

--
-- Name: inventory; Type: TABLE; Schema: public; Owner: mpanek
--

CREATE TABLE public.inventory (
    inventory_id integer NOT NULL,
    book_id integer,
    CONSTRAINT inventory_book_id_check CHECK ((book_id > 0))
);


ALTER TABLE public.inventory OWNER TO mpanek;

--
-- Name: language; Type: TABLE; Schema: public; Owner: kserocki
--

CREATE TABLE public.language (
    language_id integer NOT NULL,
    name character varying NOT NULL,
    CONSTRAINT language_check CHECK (("substring"((name)::text, 1, 1) = upper("substring"((name)::text, 1, 1))))
);


ALTER TABLE public.language OWNER TO kserocki;

--
-- Name: language_quantity; Type: VIEW; Schema: public; Owner: kserocki
--

CREATE VIEW public.language_quantity AS
 SELECT l.name AS language,
    count(*) AS quantity
   FROM (public.book b
     JOIN public.language l ON ((b.language_id = l.language_id)))
  GROUP BY l.name
  ORDER BY (count(*)) DESC;


ALTER TABLE public.language_quantity OWNER TO kserocki;

--
-- Name: payment; Type: TABLE; Schema: public; Owner: mpanek
--

CREATE TABLE public.payment (
    payment_id integer NOT NULL,
    customer_id integer,
    staff_id integer,
    library_card_paid boolean,
    payment_date date,
    CONSTRAINT payment_date_check CHECK ((payment_date >= '2022-01-01'::date))
);


ALTER TABLE public.payment OWNER TO mpanek;

--
-- Name: staff; Type: TABLE; Schema: public; Owner: pjasiak
--

CREATE TABLE public.staff (
    staff_id integer NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    address_id integer,
    email character varying NOT NULL,
    username character varying NOT NULL,
    password character varying NOT NULL,
    CONSTRAINT email_library CHECK (((email)::text ~~ '%@library.edu.pl'::text)),
    CONSTRAINT password_length CHECK ((char_length((password)::text) > 4))
);


ALTER TABLE public.staff OWNER TO pjasiak;

--
-- Name: staff_address; Type: VIEW; Schema: public; Owner: pjasiak
--

CREATE VIEW public.staff_address AS
 SELECT s.staff_id,
    s.first_name,
    s.last_name,
    a.address,
    a.address2,
    a.district,
    a.postal_code,
    c.city,
    co.country
   FROM (((public.staff s
     JOIN public.address a ON ((s.address_id = a.address_id)))
     JOIN public.city c ON ((a.city_id = c.city_id)))
     JOIN public.country co ON ((c.country_id = co.country_id)))
  ORDER BY s.staff_id;


ALTER TABLE public.staff_address OWNER TO pjasiak;

--
-- Name: staff_data; Type: VIEW; Schema: public; Owner: pjasiak
--

CREATE VIEW public.staff_data AS
 SELECT s.staff_id,
    s.first_name,
    s.last_name,
    s.email,
    s.username,
    a.phone
   FROM (public.staff s
     JOIN public.address a ON ((s.address_id = a.address_id)))
  ORDER BY s.staff_id;


ALTER TABLE public.staff_data OWNER TO pjasiak;

--
-- Name: title_author; Type: VIEW; Schema: public; Owner: kserocki
--

CREATE VIEW public.title_author AS
 SELECT DISTINCT b.title,
    a.first_name,
    a.last_name
   FROM ((public.book b
     JOIN public.book_author ba ON ((b.book_id = ba.book_id)))
     JOIN public.author a ON ((ba.author_id = a.author_id)));


ALTER TABLE public.title_author OWNER TO kserocki;

--
-- Data for Name: address; Type: TABLE DATA; Schema: public; Owner: pjasiak
--

COPY public.address (address_id, address, address2, district, city_id, postal_code, phone) FROM stdin;
1	Oxford Street	15	Westminster	9	WC2-456	601892437
2	Regent Street	19	Soho	9	WC2-789	619407152
3	Church Street	37	City Centre	10	L1-123	604782195
4	Hope Street	53	Liverpool Central	10	L1-234	625310479
5	Unter den Linden	81	Mitte	11	10115	635829410
6	Friedrichstrasse	72	Friedrichshain	11	10117	609483716
7	Leopoldstrasse	93	Altstadt-Lehel	12	80331	647283190
8	Marienplatz	55	Maxvorstadt	12	80333	616978342
9	Gran Via	146	Centro	13	28001	634892705
10	Calle Mayor	98	Chamberi	13	28002	658204319
11	Passeig de Gracia	212	Eixample	14	18001	613920874
12	La Rambla	220	Barri Gotic	14	18002	627193850
13	Birger Jarlsgatan	157	Norrmalm	15	11122	640219857
14	Vasagatan	167	Sodermalm	15	11123	659378124
15	Kungsportsavenyn	180	Centrum	16	41101	615839201
16	Haga Nygata	185	Vasastan	16	41102	668290413
17	Rue de Rivoli	268	Le Marais	17	75001	603198427
18	Boulevard Saint-Germain	182	Saint-Germain-des-Pres	17	75002	675103928
19	Rue de la Republique	177	Vieux Lyon	18	69001	638102954
20	Place Bellecour	289	Presquile	18	69002	624809136
21	Via Nazionale	312	Monti	19	30100	649218730
22	Corso Vittorio Emanuele	222	Prati	19	30101	617843905
23	Via del Corso	278	Centro Storico	20	20100	662014938
24	Via Dante	291	Brera	20	20101	609843217
25	Jerozolimskie	12	Srodmiescie	1	00-123	507948372
26	Krakowskie Przedmiescie	45	Stare Miasto	1	00-456	538204761
27	Wiatraczna	78	Praga-Poludnie	1	00-789	504129873
28	Marynarska	33	Wlochy	1	00-234	509371624
29	Dietla	55	Kazimierz	2	31-456	511642390
30	Dietla	61	Kazimierz	2	31-456	517023186
31	Grodzka	101	Stare Miasto	2	31-789	532817649
32	Grodzka	89	Stare Miasto	2	31-789	506712948
33	Pieciomorgowa	57	Borowki	3	89-456	537294801
34	Gorzyslawa	68	Stare Miasto	3	89-789	558916204
35	Boczna	79	Wojewodzka	3	89-123	563780129
36	Zielona	80	Siedliska	3	89-234	549361782
37	Swidnicka	39	Stare Miasto	4	50-789	524761903
38	Pilsudskiego	90	Stare Miasto	4	50-123	547392681
39	Legnicka	12	Fabryczna	4	50-234	568213470
40	Wyszynskiego	77	Srodmiescie	4	50-345	553187260
41	Mscislawa	20	Jezyce	5	60-456	508964731
42	Strzeszynska	31	Stare Miasto	5	60-789	523481076
43	Gorzyslawa	42	Srodmiescie	5	60-123	534286194
44	Nowa	53	Wilda	5	60-234	546972831
45	Wyszynskiego	13	Srodmiescie	6	70-789	533016429
46	Piastow	24	Centrum	6	70-123	545819736
47	Hryniewickiego	35	Stare Miasto	6	70-234	509387216
48	Krolewska	46	Zachod	6	70-345	572640198
49	Lowicka	27	Redlowo	7	81-456	561834290
50	Morska	38	Srodmiescie	7	81-789	527391684
51	Slowianska	49	Orlowo	7	81-123	589731065
52	Gdanska	50	Chylonia	7	81-234	500194827
53	Dluga	88	Srodmiescie	8	80-456	574839102
54	Dluga	91	Srodmiescie	8	80-456	519234875
55	Mickiewicza	11	Wrzeszcz	8	80-123	500218463
56	Swietojanska	44	Srodmiescie	8	80-234	531926487
\.


--
-- Data for Name: author; Type: TABLE DATA; Schema: public; Owner: kserocki
--

COPY public.author (first_name, last_name, author_id) FROM stdin;
Anthony	Doerr	1
Emily	St. John Mandel	2
Brit	Bennett	3
Herman	Melville	4
Michelle	Zauner	5
Ralph	Ellison	6
Margaret	Atwood	7
Stieg	Larsson	8
T.J.	Klune	9
Ashley	Audrain	10
Yaa	Gyasi	11
Charlotte	Bronte	12
Harper	Lee	13
Richard	Osman	14
V.E.	Schwab	15
Fyodor	Dostoevsky	16
Alex	Michaelides	17
Lauren	Groff	18
Sally	Rooney	19
Oscar	Wilde	20
Tara	Westover	21
Elena	Armas	22
Lucy	Foley	23
Min Jin	Lee	24
Dan	Brown	25
Victor	Hugo	26
Aldous	Huxley	27
Jane	Austen	28
Mary	Shelley	29
Ray	Bradbury	30
J.R.R.	Tolkien	31
Sarah	Pearse	32
Kazuo	Ishiguro	33
Silvia Moreno	Garcia	34
Ali	Hazelwood	35
Amor	Towles	36
Delia	Owens	37
Gabriel	Garcia Marquez	38
James	McBride	39
Madeline	Miller	40
Neil	Gaiman	41
Nita	Prose	42
J.K.	Rowling	43
S.E.	Hinton	44
Lily	Brooks-Dalton	45
Markus	Zusak	46
Bram	Stoker	47
Laura	Dave	48
Paulo	Coelho	49
Colson	Whitehead	50
Stephen	King	51
Leo	Tolstoy	52
Jane	Harper	53
Matt	Haig	54
Orson Scott	Card	55
Khaled	Hosseini	56
Susanna	Clarke	57
Alix E.	Harrow	58
Frances	Burnett	59
Kristin	Hannah	60
Yann	Martel	61
Andy	Weir	62
Miguel	de Cervantes	63
Colleen	Hoover	64
Frank	Herbert	65
Ken	Follett	66
Emily	Bronte	67
Antoine	de Saint-Exupery	68
N.K.	Jemisin	69
Rebecca	Roanhorse	70
Ta-Nehisi	Coates	71
George	Orwell	72
Erin	Morgenstern	73
Cormac	McCarthy	74
Taylor Jenkins	Reid	75
John	Green	76
Terry	Pratchett	77
Fredrik	Backman	78
Maggie	O'Farrell	79
Michelle	Obama	80
J.D.	Salinger	81
Patrick	Rothfuss	82
Sarah J.	Maas	83
Suzanne	Collins	84
Miranda	Cowley Heller	85
Lois	Lowry	86
\.


--
-- Data for Name: book; Type: TABLE DATA; Schema: public; Owner: kserocki
--

COPY public.book (book_id, title, description, release_year, length, replacement_cost, language_id) FROM stdin;
1	The Da Vinci Code	A symbologist uncovers a secret society's mysteries.	2003	689	24.95	3
2	Harry Potter and the Philosopher's Stone	A young wizard begins his magical education.	1997	309	16.15	1
3	Harry Potter and the Philosopher's Stone	A young wizard begins his magical education.	1997	309	16.15	2
4	Harry Potter and the Philosopher's Stone	A young wizard begins his magical education.	1997	309	16.15	3
5	The Catcher in the Rye	A teenager's journey through New York City.	1951	277	15.87	3
6	One Hundred Years of Solitude	The rise and fall of the Buendía family.	1967	417	22.93	3
7	The Girl with the Dragon Tattoo	A journalist and hacker uncover dark secrets.	2005	465	15.22	4
8	The Girl with the Dragon Tattoo	A journalist and hacker uncover dark secrets.	2005	465	15.22	1
9	The Girl with the Dragon Tattoo	A journalist and hacker uncover dark secrets.	2005	465	15.22	5
10	The Alchemist	A shepherd's journey to fulfill his destiny.	1988	208	18.21	1
11	The Alchemist	A shepherd's journey to fulfill his destiny.	1988	208	18.21	5
12	The Alchemist	A shepherd's journey to fulfill his destiny.	1988	208	18.21	2
13	To Kill a Mockingbird	A young girl confronts deep-seated prejudice in the American South.	1960	336	18.53	2
14	To Kill a Mockingbird	A young girl confronts deep-seated prejudice in the American South.	1960	336	18.53	5
15	1984	A dystopian novel exploring totalitarianism and surveillance.	1949	328	16.37	4
16	1984	A dystopian novel exploring totalitarianism and surveillance.	1949	328	16.37	5
17	1984	A dystopian novel exploring totalitarianism and surveillance.	1949	328	16.37	3
18	Pride and Prejudice	A romantic clash between opinionated Elizabeth and proud Mr. Darcy.	1813	279	15.86	4
19	The Hobbit	A hobbit embarks on an unexpected journey with dwarves.	1937	310	26.32	4
20	The Hobbit	A hobbit embarks on an unexpected journey with dwarves.	1937	310	26.32	1
21	The Hobbit	A hobbit embarks on an unexpected journey with dwarves.	1937	310	26.32	5
22	Brave New World	A futuristic society shaped by genetic engineering and social conditioning.	1932	268	13.81	1
23	Brave New World	A futuristic society shaped by genetic engineering and social conditioning.	1932	268	13.81	2
24	Fahrenheit 451	Books are banned and burned in a dystopian future.	1953	194	20.27	4
25	Fahrenheit 451	Books are banned and burned in a dystopian future.	1953	194	20.27	5
26	Fahrenheit 451	Books are banned and burned in a dystopian future.	1953	194	20.27	3
27	The Book Thief	A girl steals books in Nazi Germany.	2005	552	18.18	1
28	The Book Thief	A girl steals books in Nazi Germany.	2005	552	18.18	4
29	The Book Thief	A girl steals books in Nazi Germany.	2005	552	18.18	3
30	Crime and Punishment	A student commits a crime and wrestles with guilt.	1866	671	32.15	4
31	Crime and Punishment	A student commits a crime and wrestles with guilt.	1866	671	32.15	3
32	War and Peace	A panoramic view of Russian society during the Napoleonic wars.	1869	1225	24.87	4
33	War and Peace	A panoramic view of Russian society during the Napoleonic wars.	1869	1225	24.87	1
34	War and Peace	A panoramic view of Russian society during the Napoleonic wars.	1869	1225	24.87	3
35	The Brothers Karamazov	Three brothers wrestle with faith, doubt and justice.	1880	796	14.17	2
36	The Brothers Karamazov	Three brothers wrestle with faith, doubt and justice.	1880	796	14.17	4
37	Les Misérables	An ex-convict tries to redeem himself in revolutionary France.	1862	1463	22.75	1
38	Les Misérables	An ex-convict tries to redeem himself in revolutionary France.	1862	1463	22.75	3
39	Don Quixote	A man sets out to revive chivalry with comic results.	1605	1072	22.67	3
40	Don Quixote	A man sets out to revive chivalry with comic results.	1605	1072	22.67	5
41	The Little Prince	A young prince explores the universe and life’s mysteries.	1943	96	16.36	1
42	The Little Prince	A young prince explores the universe and life’s mysteries.	1943	96	16.36	2
43	Moby Dick	A captain's obsessive quest to hunt a white whale.	1851	635	21.27	3
44	Moby Dick	A captain's obsessive quest to hunt a white whale.	1851	635	21.27	2
45	Moby Dick	A captain's obsessive quest to hunt a white whale.	1851	635	21.27	1
46	Jane Eyre	An orphaned girl's journey through hardship and love.	1847	500	20.20	3
47	Wuthering Heights	A tale of passionate and doomed love on the moors.	1847	416	19.71	4
48	Wuthering Heights	A tale of passionate and doomed love on the moors.	1847	416	19.71	3
49	Wuthering Heights	A tale of passionate and doomed love on the moors.	1847	416	19.71	2
50	Dracula	A vampire terrorizes Victorian England.	1897	418	21.48	3
51	Dracula	A vampire terrorizes Victorian England.	1897	418	21.48	1
52	Frankenstein	A scientist creates a monster that defies nature.	1818	280	13.74	5
53	Frankenstein	A scientist creates a monster that defies nature.	1818	280	13.74	4
54	The Picture of Dorian Gray	A man remains young while his portrait ages.	1890	254	16.19	2
55	The Picture of Dorian Gray	A man remains young while his portrait ages.	1890	254	16.19	3
56	Life of Pi	A boy survives a shipwreck with a tiger.	2001	319	20.57	4
57	Life of Pi	A boy survives a shipwreck with a tiger.	2001	319	20.57	3
58	Life of Pi	A boy survives a shipwreck with a tiger.	2001	319	20.57	5
59	The Road	A father and son journey through a post-apocalyptic world.	2006	287	15.15	1
60	The Road	A father and son journey through a post-apocalyptic world.	2006	287	15.15	4
61	The Kite Runner	A man seeks redemption for betraying a childhood friend.	2003	371	24.83	5
62	The Kite Runner	A man seeks redemption for betraying a childhood friend.	2003	371	24.83	3
63	A Thousand Splendid Suns	Two women in Afghanistan form a deep bond.	2007	384	24.98	1
64	A Thousand Splendid Suns	Two women in Afghanistan form a deep bond.	2007	384	24.98	5
65	The Shining	A haunted hotel drives a man to madness.	1977	447	22.94	2
66	It	A group of friends face a shape-shifting monster.	1986	1138	16.16	1
67	It	A group of friends face a shape-shifting monster.	1986	1138	16.16	3
68	Misery	An author is held captive by an obsessed fan.	1987	320	23.46	5
69	Pet Sematary	A burial ground brings the dead back to life.	1983	374	20.98	5
70	Dune	A young noble becomes the messiah of a desert planet.	1965	412	21.32	1
71	Dune	A young noble becomes the messiah of a desert planet.	1965	412	21.32	5
72	Dune	A young noble becomes the messiah of a desert planet.	1965	412	21.32	2
73	The Martian	An astronaut is stranded on Mars and must survive.	2011	369	13.43	1
74	The Martian	An astronaut is stranded on Mars and must survive.	2011	369	13.43	4
75	The Martian	An astronaut is stranded on Mars and must survive.	2011	369	13.43	5
76	Ender's Game	A boy is trained to fight aliens in a military school.	1985	324	16.59	1
77	The Name of the Wind	A gifted young man becomes the most notorious wizard.	2007	662	24.64	2
78	American Gods	A man gets caught in a war between old and new gods.	2001	465	13.99	1
79	American Gods	A man gets caught in a war between old and new gods.	2001	465	13.99	2
80	Good Omens	An angel and demon team up to prevent the apocalypse.	1990	412	23.51	4
81	Good Omens	An angel and demon team up to prevent the apocalypse.	1990	412	23.51	5
82	Neverwhere	A man enters a hidden world beneath London.	1996	370	20.63	5
83	Neverwhere	A man enters a hidden world beneath London.	1996	370	20.63	2
84	Neverwhere	A man enters a hidden world beneath London.	1996	370	20.63	1
85	Coraline	A girl discovers a sinister mirror world.	2002	192	22.43	4
86	Coraline	A girl discovers a sinister mirror world.	2002	192	22.43	5
87	Coraline	A girl discovers a sinister mirror world.	2002	192	22.43	3
88	The Giver	A boy discovers the dark truth behind a utopian society.	1993	240	19.64	5
89	The Outsiders	A teenager navigates gang rivalry and identity.	1967	192	13.19	2
90	The Outsiders	A teenager navigates gang rivalry and identity.	1967	192	13.19	1
91	The Outsiders	A teenager navigates gang rivalry and identity.	1967	192	13.19	3
92	The Secret Garden	An orphan discovers a magical hidden garden.	1911	331	19.99	3
93	The Fault in Our Stars	Two teens with cancer fall in love.	2012	313	14.65	3
94	The Fault in Our Stars	Two teens with cancer fall in love.	2012	313	14.65	1
95	The Fault in Our Stars	Two teens with cancer fall in love.	2012	313	14.65	2
96	Looking for Alaska	A boy falls for a mysterious girl at boarding school.	2005	221	14.98	1
97	Looking for Alaska	A boy falls for a mysterious girl at boarding school.	2005	221	14.98	3
98	Looking for Alaska	A boy falls for a mysterious girl at boarding school.	2005	221	14.98	4
99	Paper Towns	A teen follows clues to find a missing girl.	2008	305	21.95	1
100	Paper Towns	A teen follows clues to find a missing girl.	2008	305	21.95	3
101	Paper Towns	A teen follows clues to find a missing girl.	2008	305	21.95	2
102	The Silent Patient	A psychological thriller about a woman's shocking act of violence.	2019	323	18.99	1
103	The Silent Patient	A psychological thriller about a woman's shocking act of violence.	2019	323	18.99	3
104	Where the Crawdads Sing	A mystery surrounding a girl who grew up in the marshes.	2018	368	20.50	2
105	Educated	A memoir of a woman's escape from a survivalist family.	2018	334	19.75	4
106	The Night Circus	A magical competition between two illusionists.	2011	387	17.25	5
107	Becoming	Michelle Obama's journey from the South Side to the White House.	2018	426	22.00	1
108	Circe	A mythological tale of the witch Circe's life and struggles.	2018	385	21.30	2
109	Circe	A mythological tale of the witch Circe's life and struggles.	2018	385	21.30	1
110	The Vanishing Half	Twins take diverging paths, one passing as white.	2020	343	19.99	3
111	The Midnight Library	A woman explores alternate lives in a magical library.	2020	304	18.50	4
112	Normal People	A complex relationship between two Irish teenagers.	2018	273	16.75	5
113	Normal People	A complex relationship between two Irish teenagers.	2018	273	16.75	2
114	The Seven Husbands of Evelyn Hugo	A Hollywood star reveals her secrets.	2017	388	20.45	1
115	The Song of Achilles	A retelling of the Iliad from Patroclus' perspective.	2011	352	17.80	3
116	Pachinko	A Korean family's struggles in Japan across generations.	2017	490	22.99	2
117	The Testaments	A sequel to The Handmaid's Tale revealing Gilead's fall.	2019	422	21.95	4
118	The Water Dancer	A young man’s journey using magical powers to escape slavery.	2019	403	20.00	5
119	Anxious People	A bank robbery turns into a hostage drama with dark humor.	2019	341	18.25	1
120	The Invisible Life of Addie LaRue	A woman makes a Faustian bargain to live forever.	2020	448	19.50	2
121	The Four Winds	A family's struggle during the Great Depression.	2021	464	21.75	3
122	The Four Winds	A family's struggle during the Great Depression.	2021	464	21.75	2
123	Klara and the Sun	An AI companion observes human behavior.	2021	307	20.40	4
124	The Push	A chilling exploration of motherhood and trauma.	2021	307	18.90	5
125	Malibu Rising	A family's explosive party reveals buried secrets.	2021	369	19.25	1
126	Project Hail Mary	An astronaut's desperate mission to save humanity.	2021	476	21.99	2
127	The Last Thing He Told Me	A woman uncovers her husband's dark past.	2021	320	18.75	3
128	The Paris Apartment	A journalist investigates her brother's disappearance.	2022	352	19.80	4
129	It Ends with Us	A turbulent romance addressing cycles of abuse.	2016	376	17.99	5
130	The Maid	A hotel maid becomes entangled in a murder mystery.	2022	289	18.40	1
131	The Lincoln Highway	Two brothers embark on a cross-country journey.	2021	592	22.50	2
132	The Lincoln Highway	Two brothers embark on a cross-country journey.	2021	592	22.50	1
133	Cloud Cuckoo Land	Interconnected stories across time and space.	2021	640	23.00	3
134	Matrix	A feminist reimagining of the life of Marie de France.	2021	368	19.95	4
135	Harlem Shuffle	A heist novel set in 1960s Harlem.	2021	318	18.60	5
136	The Paper Palace	A woman confronts a life-changing secret.	2021	389	19.30	1
137	Beautiful World, Where Are You	Friends navigate love and existential crises.	2021	356	19.99	2
138	The Spanish Love Deception	A fake relationship turns real.	2021	364	16.99	1
139	The Spanish Love Deception	A fake relationship turns real.	2021	364	16.99	3
140	Crying in H Mart	A memoir about grief and Korean identity.	2021	256	17.50	4
141	The Love Hypothesis	A fake dating scheme in academia.	2021	384	16.75	5
142	A Court of Silver Flames	A fantasy romance in a magical world.	2021	757	24.99	1
143	The Sanatorium	A chilling mystery set in a remote hotel.	2021	390	18.95	2
144	The Thursday Murder Club	Retirees solve cold cases in a cozy mystery.	2020	382	17.25	3
145	The Guest List	A wedding on a remote island turns deadly.	2020	330	18.50	4
146	The Guest List	A wedding on a remote island turns deadly.	2020	330	18.50	2
147	The Midnight Sky	A post-apocalyptic journey to save humanity.	2020	301	16.80	5
148	The House in the Cerulean Sea	A social worker visits a magical orphanage.	2020	398	19.40	1
149	The House in the Cerulean Sea	A social worker visits a magical orphanage.	2020	398	19.40	2
150	The House in the Cerulean Sea	A social worker visits a magical orphanage.	2020	398	19.40	3
151	Piranesi	A man explores a mysterious endless house.	2020	272	17.99	2
152	Transcendent Kingdom	A neuroscientist grapples with faith and addiction.	2020	264	18.20	3
153	The City We Became	A battle for the soul of New York City.	2020	437	20.25	4
154	Mexican Gothic	A haunting tale set in 1950s Mexico.	2020	301	18.75	5
155	The Once and Future Witches	Three sisters revive witchcraft in the 1890s.	2020	528	21.50	1
156	The Once and Future Witches	Three sisters revive witchcraft in the 1890s.	2020	528	21.50	3
157	Black Sun	A fantasy inspired by pre-Columbian Americas.	2020	464	19.99	2
158	The Invisible Man	A modern thriller about gaslighting and revenge.	2020	337	17.40	3
159	The Invisible Man	A modern thriller about gaslighting and revenge.	2020	337	17.40	2
160	The Invisible Man	A modern thriller about gaslighting and revenge.	2020	337	17.40	4
161	The Survivors	Secrets resurface after a tragedy in a coastal town.	2020	373	18.60	4
162	The Evening and the Morning	A prequel to The Pillars of the Earth.	2020	913	24.50	5
163	The Ballad of Songbirds and Snakes	The origin story of President Snow.	2020	517	22.25	1
164	Deacon King Kong	A crime story set in 1960s Brooklyn.	2020	371	19.75	3
165	Deacon King Kong	A crime story set in 1960s Brooklyn.	2020	371	19.75	2
166	Hamnet	A fictional account of Shakespeare's son's death.	2020	305	20.00	3
167	The Glass Hotel	A collapse of wealth and interconnected lives.	2020	301	18.90	4
\.


--
-- Data for Name: book_author; Type: TABLE DATA; Schema: public; Owner: kserocki
--

COPY public.book_author (book_id, author_id) FROM stdin;
1	25
2	43
3	43
4	43
5	81
6	38
7	8
8	8
9	8
10	49
11	49
12	49
13	13
14	13
15	72
16	72
17	72
18	28
19	31
20	31
21	31
22	27
23	27
24	30
25	30
26	30
27	46
28	46
29	46
30	16
31	16
32	52
33	52
34	52
35	16
36	16
37	26
38	26
39	63
40	63
41	68
42	68
43	4
44	4
45	4
46	12
47	67
48	67
49	67
50	47
51	47
52	29
53	29
54	20
55	20
56	61
57	61
58	61
59	74
60	74
61	56
62	56
63	56
64	56
65	51
66	51
67	51
68	51
69	51
70	65
71	65
72	65
73	62
74	62
75	62
76	55
77	82
78	41
79	41
80	77
81	77
82	41
83	41
84	41
85	41
86	41
87	41
88	86
89	44
90	44
91	44
92	59
93	76
94	76
95	76
96	76
97	76
98	76
99	76
100	76
101	76
102	17
103	17
104	37
105	21
106	73
107	80
108	40
109	40
110	3
111	54
112	19
113	19
114	75
115	40
116	24
117	7
118	71
119	78
120	15
121	60
122	60
123	33
124	10
125	75
126	62
127	48
128	23
129	64
130	42
131	36
132	36
133	1
134	18
135	50
136	85
137	19
138	22
139	22
140	5
141	35
142	83
143	32
144	14
145	23
146	45
147	45
148	9
149	9
150	9
151	57
152	11
153	69
154	34
155	58
156	58
157	70
158	6
159	6
160	6
161	53
162	66
163	84
164	39
165	39
166	79
167	2
\.


--
-- Data for Name: book_category; Type: TABLE DATA; Schema: public; Owner: kserocki
--

COPY public.book_category (book_id, category_id) FROM stdin;
1	4
2	1
3	1
4	1
5	1
6	1
7	5
8	5
9	5
10	5
11	5
12	5
13	4
14	4
15	4
16	4
17	4
18	4
19	12
20	12
21	12
22	12
23	12
24	12
25	12
26	12
27	5
28	5
29	5
30	5
31	5
32	10
33	10
34	10
35	10
36	10
37	10
38	10
39	5
40	5
41	1
42	1
43	1
44	1
45	1
46	1
47	10
48	10
49	10
50	10
51	10
52	10
53	10
54	10
55	10
56	10
57	10
58	10
59	8
60	8
61	8
62	8
63	8
64	8
65	5
66	5
67	5
68	8
69	8
70	8
71	8
72	8
73	5
74	5
75	5
76	5
77	5
78	5
79	5
80	5
81	5
82	5
83	5
84	5
85	14
86	14
87	14
88	14
89	5
90	5
91	5
92	5
93	5
94	5
95	5
96	5
97	5
98	5
99	13
100	13
101	13
102	13
103	13
104	13
105	13
106	13
107	13
108	13
109	13
110	13
111	13
112	12
113	12
114	12
115	12
116	10
117	10
118	11
119	11
120	11
121	11
122	11
123	3
124	3
125	3
126	3
127	3
128	2
129	2
130	2
131	2
132	2
133	2
134	2
135	2
136	1
137	1
138	1
139	1
140	1
141	1
142	1
143	1
144	1
145	3
146	3
147	3
148	3
149	3
150	3
151	10
152	6
153	6
154	6
155	14
156	14
157	6
158	6
159	6
160	6
161	6
162	6
163	6
164	6
165	6
166	6
167	6
\.


--
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: kserocki
--

COPY public.category (category_id, name) FROM stdin;
1	Fantasy
2	Science Fiction
3	Horror
4	Thriller
5	Classic Literature
6	Young Adult
7	Romance
8	Historical Fiction
9	Biography
10	Dystopia
11	Contemporary Literature
12	Adventure
13	Gothic Literature
14	Children's Literature
\.


--
-- Data for Name: city; Type: TABLE DATA; Schema: public; Owner: pjasiak
--

COPY public.city (city_id, city, country_id) FROM stdin;
1	Warsaw	2
2	Krakow	2
3	Chojnice	2
4	Wroclaw	2
5	Poznan	2
6	Szczecin	2
7	Gdynia	2
8	Gdansk	2
9	London	1
10	Liverpool	1
11	Berlin	3
12	Munich	3
13	Madrid	4
14	Barcelona	4
15	Stockholm	5
16	Gothenburg	5
17	Paris	6
18	Lyon	6
19	Rome	7
20	Milan	7
\.


--
-- Data for Name: country; Type: TABLE DATA; Schema: public; Owner: pjasiak
--

COPY public.country (country_id, country) FROM stdin;
1	England
2	Poland
3	Germany
4	Spain
5	Sweden
6	France
7	Italy
\.


--
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: mpanek
--

COPY public.customer (customer_id, first_name, last_name, email, address_id, active) FROM stdin;
1	Anna	Kowalska	anna.kowalska@example.com	8	t
2	Piotr	Nowak	p.nowak84@mail.com	45	t
3	Maria	Wiśniewska	maria.wisnia@wp.pl	33	t
4	Tomasz	Wójcik	tomwojcik@gmail.com	11	f
5	Katarzyna	Kowalczyk	kat.kowa@example.com	1	t
6	Michał	Kamiński	michal.kaminski@mail.pl	26	t
7	Agnieszka	Lewandowska	agnieszka.lewa@o2.pl	23	t
8	Krzysztof	Zieliński	krzys.zielinski@interia.pl	14	f
9	Monika	Szymańska	mon.szymanska@gmail.com	37	t
10	Marek	Woźniak	marek.wozniak@poczta.pl	5	t
11	Joanna	Dąbrowska	joanna.dab@mail.pl	41	t
12	Adam	Kozłowski	adamkozlo@onet.eu	47	t
13	Barbara	Jankowska	bar.jank@poczta.com	34	t
14	Grzegorz	Mazur	grzeg.mazur@xyz.pl	18	f
15	Ewa	Kwiatkowska	ewakw@interia.eu	22	t
16	Łukasz	Krawczyk	luk.krawczyk@abc.pl	38	t
17	Paulina	Piotrowska	paula.pio@example.pl	31	t
18	Artur	Grabowski	art.grab@onet.pl	15	t
19	Natalia	Zając	natalia.zajac@mail.com	9	t
20	Paweł	Pawlak	pawel.pawlak@mail.net	49	t
21	Sylwia	Michalska	sylwia.mich@o2.pl	12	f
22	Sebastian	Król	seb.krol@onet.com	46	t
23	Patrycja	Wieczorek	patrycja.wieczorek@xyz.pl	4	t
24	Wojciech	Wróbel	wojtek.wrobel@poczta.pl	35	t
25	Kinga	Nowicka	kinga.nowicka@gmail.com	50	t
26	Andrzej	Malinowski	and.malin@mail.pl	10	t
27	Izabela	Jaworska	iza.jaworska@example.pl	2	t
28	Rafał	Dudek	raf.dudek@onet.pl	21	t
29	Magdalena	Górska	mag.gorska@poczta.pl	7	t
30	Dawid	Czarnecki	dawid.czarny@onet.com	6	t
31	Alicja	Sokołowska	alicja.sokol@interia.pl	43	t
32	Bartosz	Sikora	bart.sikora@gmail.com	42	t
33	Renata	Walczak	ren.walczak@onet.pl	13	t
34	Kamil	Baran	kamil.baran@example.com	17	t
35	Emilia	Rutkowska	emilia.rut@wp.pl	25	t
36	Szymon	Michalak	szymon.mich@gmail.com	32	t
37	Weronika	Szewczyk	wer.szewczyk@mail.pl	30	t
38	Mateusz	Ostrowski	mateusz.ostr@poczta.pl	40	t
39	Julia	Tomaszewska	julia.toma@onet.eu	3	t
40	Patryk	Jasiński	patryk.jasinski@interia.pl	29	t
41	Helena	Zawadzka	helena.zawadzka@mail.com	28	f
42	Konrad	Bąk	konrad.bak@example.com	27	t
43	Zofia	Chmielewska	zofia.chmiel@onet.pl	20	t
44	Daniel	Urbaniak	daniel.urb@poczta.pl	48	t
45	Wiktoria	Sławińska	wiktoria.slaw@wp.pl	44	t
46	Igor	Głowacki	igor.glowacki@gmail.com	36	t
47	Maja	Zięba	maja.zieba@mail.net	19	t
48	Marcel	Leszczyński	marcel.leszcz@example.pl	16	t
49	Oliwia	Bednarek	oliwia.bednarek@o2.pl	24	t
50	Jan	Czajka	jan.czajka@interia.com	39	t
\.


--
-- Data for Name: inventory; Type: TABLE DATA; Schema: public; Owner: mpanek
--

COPY public.inventory (inventory_id, book_id) FROM stdin;
1	54
2	43
3	118
4	88
5	2
6	66
7	100
8	91
9	82
10	31
11	15
12	139
13	85
14	37
15	12
16	153
17	52
18	7
19	53
20	127
21	144
22	87
23	161
24	63
25	21
26	17
27	65
28	67
29	104
30	122
31	149
32	36
33	90
34	107
35	42
36	11
37	13
38	10
39	27
40	72
41	18
42	101
43	92
44	125
45	48
46	29
47	34
48	130
49	147
50	119
51	6
52	115
53	69
54	111
55	78
56	38
57	142
58	50
59	96
60	98
61	76
62	89
63	28
64	126
65	1
66	9
67	103
68	121
69	84
70	3
71	136
72	116
73	5
74	106
75	20
76	39
77	45
78	41
79	59
80	110
81	112
82	108
83	25
84	49
85	143
86	146
87	158
88	80
89	140
90	117
91	56
92	24
93	93
94	102
95	46
96	44
97	123
98	151
99	35
100	94
101	26
102	83
103	23
104	71
105	95
106	33
107	19
108	157
109	109
110	75
111	8
112	77
113	68
114	86
115	62
116	105
117	145
118	55
119	129
120	14
121	73
122	138
123	40
124	132
125	22
126	137
127	60
128	124
129	4
130	70
131	79
132	47
133	165
134	97
135	32
136	148
137	154
138	58
139	30
140	134
141	133
142	81
143	114
144	99
145	120
146	135
147	61
148	141
149	113
150	74
151	159
152	150
153	155
154	152
155	156
156	162
157	164
158	160
159	163
160	166
161	167
162	16
163	157
164	50
165	88
166	99
167	27
168	35
169	64
170	119
171	61
172	45
173	112
174	131
175	11
176	134
177	122
178	36
179	13
180	28
181	84
182	70
183	141
184	6
185	65
186	153
187	111
188	98
189	58
190	124
191	139
192	85
193	126
194	40
195	7
196	128
197	69
198	130
199	19
200	47
201	4
202	105
203	102
204	39
205	26
206	1
207	59
208	12
209	16
210	117
211	24
212	73
213	9
214	149
215	10
216	87
217	91
218	144
219	30
220	14
221	33
222	20
223	160
224	100
225	83
226	21
227	96
228	2
229	123
230	90
232	35
233	25
234	44
235	97
236	100
237	22
238	15
239	79
240	38
241	83
242	86
243	85
244	72
245	84
246	82
247	23
248	76
249	77
250	92
231	36
\.


--
-- Data for Name: language; Type: TABLE DATA; Schema: public; Owner: kserocki
--

COPY public.language (language_id, name) FROM stdin;
1	English
2	Polish
3	German
4	Spanish
5	Swedish
\.


--
-- Data for Name: payment; Type: TABLE DATA; Schema: public; Owner: mpanek
--

COPY public.payment (payment_id, customer_id, staff_id, library_card_paid, payment_date) FROM stdin;
1	5	1	t	2024-08-27
2	33	5	t	2024-09-14
3	7	4	t	2024-07-05
4	8	6	f	2023-09-27
5	40	3	t	2024-09-25
6	1	5	t	2024-07-28
7	31	4	t	2024-12-07
8	13	1	t	2024-12-09
9	37	1	t	2025-01-01
10	24	5	t	2025-01-07
11	46	1	t	2024-07-11
12	18	1	t	2025-02-22
13	34	3	t	2024-07-10
14	3	2	t	2024-07-23
15	11	4	t	2025-02-09
16	45	6	t	2024-06-16
17	14	5	f	2022-12-07
18	49	6	t	2024-08-03
19	33	5	t	2024-09-14
20	6	1	t	2024-09-12
21	16	2	t	2024-11-23
22	27	3	t	2024-10-10
23	50	4	t	2024-12-02
24	35	3	t	2024-09-07
25	48	4	t	2025-03-22
26	39	4	t	2025-01-27
27	44	1	t	2025-03-12
28	22	5	t	2024-07-24
29	25	5	t	2024-06-30
30	20	4	t	2024-08-19
31	10	6	t	2024-09-12
32	41	1	f	2023-10-15
33	42	5	t	2024-12-16
34	36	6	t	2024-11-14
35	28	5	t	2025-01-26
36	19	6	t	2024-09-16
37	30	4	t	2024-06-29
38	9	6	t	2024-08-18
39	32	4	t	2025-01-28
40	4	1	f	2023-04-03
41	43	1	t	2025-01-20
42	38	6	t	2025-04-23
43	12	2	t	2024-11-14
44	17	2	t	2024-08-20
45	29	3	t	2025-01-19
46	15	1	t	2024-06-01
47	23	3	t	2024-07-13
48	2	5	t	2025-01-05
49	47	2	t	2025-01-19
50	21	4	f	2024-04-22
\.


--
-- Data for Name: rental; Type: TABLE DATA; Schema: public; Owner: mpanek
--

COPY public.rental (rental_id, rental_date, inventory_id, customer_id, return_date, staff_id) FROM stdin;
1	2023-10-30	228	5	2023-11-02	4
2	2022-01-13	16	47	2022-01-21	1
3	2023-01-27	100	48	2023-02-26	3
4	2024-01-04	110	49	2024-01-18	2
5	2024-10-29	145	15	2024-11-25	1
6	2022-10-23	4	44	2022-10-29	1
7	2025-02-08	177	28	2025-02-18	5
8	2024-04-03	149	15	2024-05-03	4
9	2022-03-04	156	5	2022-03-18	1
10	2022-07-09	121	38	2022-08-05	4
11	2025-02-20	56	36	2025-03-12	3
12	2023-10-16	53	36	2023-10-31	4
13	2024-05-11	86	48	2024-06-01	6
14	2024-11-15	152	18	2024-11-25	5
15	2024-02-15	170	23	2024-02-26	1
16	2022-09-16	114	5	2022-09-25	6
17	2022-07-10	83	42	2022-07-12	2
18	2022-11-04	95	24	2022-11-07	1
19	2022-08-04	37	19	2022-08-18	5
20	2023-10-11	10	28	2023-10-16	3
21	2024-04-27	197	1	2024-05-27	6
22	2023-12-28	59	13	2024-01-13	5
23	2023-12-26	115	3	2024-01-11	3
24	2024-03-07	135	34	2024-04-03	6
25	2022-10-07	98	49	2022-10-24	6
26	2023-08-23	15	47	2023-09-22	2
27	2024-06-20	171	38	2024-06-30	3
28	2024-03-21	198	12	2024-04-11	5
29	2022-06-05	155	40	2022-07-02	4
30	2024-12-29	66	47	2025-01-19	2
31	2024-05-09	144	16	2024-06-07	6
32	2025-02-10	3	12	2025-02-13	2
33	2022-11-24	51	26	2022-12-05	1
34	2023-03-20	18	42	2023-03-28	5
35	2024-06-17	12	17	2024-06-23	4
36	2024-05-06	113	38	2024-05-19	3
37	2022-04-26	180	34	2022-05-26	5
38	2023-03-30	72	1	2023-04-22	5
39	2023-12-04	161	11	2023-12-11	1
40	2022-09-13	141	37	2022-09-28	5
41	2024-07-23	44	23	2024-08-01	1
42	2023-01-04	184	2	2023-01-09	1
43	2022-02-19	49	45	2022-03-18	1
44	2022-05-03	226	39	2022-05-23	4
45	2022-12-16	187	6	2022-12-31	6
46	2023-02-12	173	12	2023-02-19	3
47	2024-06-15	79	35	2024-06-25	6
48	2024-05-11	91	42	2024-05-17	3
49	2025-01-24	186	9	2025-02-05	1
50	2022-04-13	8	23	2022-04-17	4
51	2022-11-26	240	7	2022-12-15	5
52	2024-06-27	182	1	2024-07-07	1
53	2022-10-04	27	39	2022-10-17	2
54	2022-04-14	202	25	2022-04-22	3
55	2024-05-24	213	22	2024-06-13	5
56	2023-02-18	34	33	2023-03-04	6
57	2023-07-23	206	31	2023-07-26	2
58	2023-03-20	191	15	2023-04-04	1
59	2023-06-12	30	19	2023-06-22	3
60	2023-10-15	62	46	2023-10-29	3
61	2022-01-19	250	50	2022-02-01	3
62	2024-10-31	69	36	2024-11-07	3
63	2022-03-18	235	38	2022-04-15	4
64	2023-08-18	158	19	2023-09-01	4
65	2024-07-04	219	37	2024-07-08	4
66	2023-06-03	102	42	2023-07-03	6
67	2023-11-29	20	5	2023-12-21	4
68	2022-03-06	214	15	2022-04-05	3
69	2022-04-16	136	32	2022-04-21	5
70	2022-11-22	140	17	2022-11-27	2
71	2022-08-24	128	31	2022-08-28	2
72	2023-07-15	109	36	2023-07-25	2
73	2024-04-12	74	40	2024-05-03	6
74	2024-01-27	192	37	2024-02-02	2
75	2022-01-18	143	34	2022-02-03	2
76	2024-05-01	126	50	2024-05-24	3
77	2024-02-20	222	28	2024-03-13	2
78	2022-08-29	236	10	2022-09-11	4
79	2022-09-11	108	25	2022-10-04	5
80	2022-10-28	151	15	2022-11-03	6
81	2022-09-17	116	10	2022-09-23	2
82	2022-05-27	111	42	2022-06-14	2
83	2024-11-28	80	18	2024-12-16	3
84	2023-10-15	225	9	2023-11-05	3
85	2022-06-26	125	10	2022-07-17	2
86	2024-07-19	101	44	2024-08-05	4
87	2023-03-11	54	2	2023-03-21	4
88	2023-05-13	52	5	2023-05-24	1
89	2022-09-24	225	10	2022-10-23	3
90	2022-02-23	33	26	2022-03-05	2
91	2023-08-30	2	15	2023-09-06	6
92	2023-10-14	23	30	2023-11-01	4
93	2023-10-27	200	39	2023-11-01	5
94	2023-01-14	70	22	2023-01-22	2
95	2022-03-30	146	26	2022-04-15	2
96	2023-06-19	243	1	2023-07-06	4
97	2023-09-03	220	1	2023-09-18	2
98	2022-10-28	243	48	2022-11-11	5
99	2023-07-12	122	13	2023-08-05	2
100	2024-03-18	203	39	2024-03-28	6
101	2022-12-05	118	43	2022-12-07	3
102	2022-07-10	224	35	2022-07-30	1
103	2025-01-15	85	48	2025-01-26	1
104	2022-12-09	169	6	2023-01-08	5
105	2023-09-21	9	30	2023-10-04	4
106	2023-05-13	71	42	2023-05-20	6
107	2022-05-15	40	38	2022-05-17	4
108	2024-09-17	231	47	2024-10-14	4
109	2022-12-22	157	28	2023-01-07	5
110	2023-04-22	244	7	2023-05-12	1
111	2022-11-19	21	34	2022-12-06	5
112	2023-02-17	211	1	2023-02-24	5
113	2022-07-18	57	10	2022-08-12	2
114	2023-04-13	176	2	2023-05-02	1
115	2022-04-29	59	2	2022-05-03	1
116	2023-06-18	68	7	2023-07-13	5
117	2024-01-09	24	19	2024-01-24	2
118	2024-11-23	194	36	2024-12-10	6
119	2022-05-14	209	34	2022-06-08	3
120	2022-07-07	36	40	2022-07-13	5
121	2023-11-29	208	35	2023-12-03	4
122	2022-10-21	64	15	2022-11-01	2
123	2024-12-14	93	7	2024-12-18	4
124	2025-01-17	61	1	2025-01-22	5
125	2022-08-09	32	44	2022-08-15	6
126	2022-03-17	242	29	2022-04-09	2
127	2024-02-04	147	5	2024-02-08	1
128	2023-10-20	55	34	2023-11-15	6
129	2023-04-21	183	3	2023-05-13	6
130	2024-03-07	105	13	2024-03-20	6
131	2025-01-15	234	31	2025-02-09	4
132	2022-01-28	73	29	2022-02-01	2
133	2022-05-05	1	47	2022-05-26	3
134	2024-09-23	174	24	2024-10-23	3
135	2024-06-24	212	24	2024-07-16	4
136	2022-02-28	106	5	2022-03-29	5
137	2023-12-21	163	17	2024-01-04	2
138	2023-05-11	25	46	2023-05-15	5
139	2024-09-24	84	46	2024-10-08	6
140	2024-08-01	195	10	2024-08-12	4
141	2023-11-15	206	24	2023-11-28	2
142	2024-08-09	124	46	2024-08-28	2
143	2024-11-15	17	11	2024-11-24	3
144	2025-01-17	205	46	2025-01-20	1
145	2024-08-08	45	17	2024-08-10	2
146	2023-06-12	139	38	2023-06-28	2
147	2023-07-04	137	3	2023-08-03	1
148	2024-09-12	160	40	2024-10-10	4
149	2024-11-26	119	39	2024-12-22	1
150	2022-12-07	60	40	2022-12-31	6
151	2022-12-03	58	7	2022-12-29	1
152	2023-08-02	233	37	2023-08-26	2
153	2024-06-21	246	17	2024-07-03	1
154	2023-08-01	199	31	2023-08-18	3
155	2024-12-22	43	38	2024-12-27	2
156	2022-02-28	94	50	2022-03-14	6
157	2025-01-01	239	32	2025-01-19	1
158	2023-11-15	11	30	2023-11-23	5
159	2022-09-05	189	16	2022-09-19	6
160	2023-07-18	63	31	2023-08-05	2
161	2022-07-08	89	25	2022-07-30	5
162	2022-03-21	221	12	2022-04-06	6
163	2022-09-13	250	37	2022-09-28	5
164	2022-12-28	164	11	2023-01-23	4
165	2022-07-06	76	11	2022-08-05	6
166	2024-11-24	19	3	2024-12-16	5
167	2023-01-01	46	24	2023-01-14	6
168	2022-09-09	204	32	2022-09-18	3
169	2024-02-29	97	44	2024-03-15	4
170	2024-03-28	165	43	2024-04-22	2
171	2022-04-18	150	43	2022-04-26	1
172	2024-12-15	26	37	2024-12-18	4
173	2024-08-01	153	7	2024-08-21	5
174	2024-07-14	99	24	2024-07-25	6
175	2023-08-04	31	37	2023-08-20	6
176	2023-02-09	201	37	2023-02-19	1
177	2023-10-23	6	39	2023-11-19	5
178	2023-07-15	5	6	2023-08-11	6
179	2023-06-05	237	27	2023-07-05	1
180	2022-09-09	123	15	2022-10-05	3
181	2023-04-20	81	9	2023-05-14	6
182	2022-02-16	185	48	2022-03-17	6
183	2023-08-20	47	27	2023-08-30	5
184	2023-06-24	29	10	2023-06-30	6
185	2023-05-21	227	28	2023-05-29	6
186	2022-12-22	217	34	2023-01-19	3
187	2024-07-21	134	38	2024-08-08	6
188	2023-09-09	13	44	2023-09-20	6
189	2023-06-07	42	42	2023-07-02	3
190	2024-03-09	167	42	2024-04-03	5
191	2024-09-09	112	20	2024-09-29	2
192	2022-09-09	104	16	2022-09-30	1
193	2023-08-15	142	5	2023-09-08	6
194	2022-10-31	218	23	2022-11-22	1
195	2022-10-03	16	29	2022-10-21	3
196	2024-12-24	244	31	2025-01-10	6
197	2024-03-30	91	37	2024-04-22	3
198	2024-08-27	7	16	2024-09-23	5
199	2024-09-25	179	44	2024-10-17	6
200	2024-06-25	229	17	2024-07-13	1
201	2024-07-25	130	46	2024-08-01	4
202	2024-06-04	248	30	2024-06-10	3
203	2023-05-06	35	50	2023-05-17	4
204	2024-07-16	207	31	2024-07-25	3
205	2023-11-22	75	24	2023-12-02	1
206	2024-08-08	117	29	2024-08-17	2
207	2024-08-29	107	25	2024-09-18	5
208	2024-10-29	19	34	2024-11-15	6
209	2024-05-14	14	35	2024-06-04	2
210	2023-01-21	247	38	2023-02-04	6
211	2023-03-02	196	22	2023-03-21	3
212	2023-12-29	168	5	2024-01-12	3
213	2024-05-15	127	30	2024-06-06	1
214	2024-07-08	103	1	2024-07-26	1
215	2023-10-07	132	10	2023-10-19	2
216	2023-05-14	78	9	2023-06-12	6
217	2022-03-15	192	2	2022-04-04	1
218	2022-11-12	66	6	2022-11-21	3
219	2024-06-23	193	47	2024-07-10	6
220	2023-07-25	90	22	2023-08-14	6
221	2024-06-27	175	22	2024-06-29	3
222	2022-12-21	22	15	2023-01-13	5
223	2023-01-30	96	46	2023-02-02	4
224	2022-06-24	38	13	2022-07-06	6
225	2024-04-21	48	30	2024-05-13	6
226	2023-04-19	187	50	2023-05-14	5
227	2024-02-24	28	27	2024-03-15	3
228	2023-10-22	190	2	2023-10-26	1
229	2023-04-23	241	40	2023-05-05	4
230	2024-11-25	148	46	2024-12-21	6
231	2024-11-10	133	37	2024-11-22	2
232	2023-02-15	87	20	2023-02-21	2
233	2024-11-18	82	37	2024-12-16	6
234	2023-06-08	65	32	2023-07-08	4
235	2024-06-30	41	37	2024-07-04	5
236	2022-04-21	232	24	2022-05-06	1
237	2023-07-18	159	6	2023-08-08	3
238	2024-09-01	39	27	2024-09-10	3
239	2023-09-24	67	3	2023-10-03	1
240	2022-09-13	210	31	2022-09-23	5
241	2022-05-08	166	33	2022-05-12	1
242	2024-07-30	215	25	2024-08-22	4
243	2023-02-23	249	2	2023-03-14	1
244	2023-07-13	120	26	2023-07-19	6
245	2022-06-29	50	50	2022-07-19	4
246	2024-05-02	238	22	2024-05-12	5
247	2023-03-26	131	6	2023-03-28	1
248	2024-03-17	77	32	2024-04-08	5
249	2024-06-18	162	30	2024-06-26	6
250	2023-10-21	216	44	2023-11-01	5
\.


--
-- Data for Name: staff; Type: TABLE DATA; Schema: public; Owner: pjasiak
--

COPY public.staff (staff_id, first_name, last_name, address_id, email, username, password) FROM stdin;
1	Robert	Zalewski	51	r.zalewski@library.edu.pl	rzalewski	558581
2	Marcin	Nowak	52	m.nowak@library.edu.pl	mnowak	565652
3	Natalia	Sobczak	53	n.sobczak@library.edu.pl	nsobczak	577773
4	Paulina	Krawczyk	54	p.krawczyk@library.edu.pl	pkrawczyk	578784
5	Walter	White	55	w.white@library.edu.pl	wwhite	565655
6	John	Pork	56	j.pork@library.edu.pl	jpork	544446
\.


--
-- Name: address address_pkey; Type: CONSTRAINT; Schema: public; Owner: pjasiak
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_pkey PRIMARY KEY (address_id);


--
-- Name: author author_pkey; Type: CONSTRAINT; Schema: public; Owner: kserocki
--

ALTER TABLE ONLY public.author
    ADD CONSTRAINT author_pkey PRIMARY KEY (author_id);


--
-- Name: book book_pkey; Type: CONSTRAINT; Schema: public; Owner: kserocki
--

ALTER TABLE ONLY public.book
    ADD CONSTRAINT book_pkey PRIMARY KEY (book_id);


--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: kserocki
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (category_id);


--
-- Name: city city_pkey; Type: CONSTRAINT; Schema: public; Owner: pjasiak
--

ALTER TABLE ONLY public.city
    ADD CONSTRAINT city_pkey PRIMARY KEY (city_id);


--
-- Name: country country_pkey; Type: CONSTRAINT; Schema: public; Owner: pjasiak
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (country_id);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: mpanek
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- Name: inventory inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: mpanek
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (inventory_id);


--
-- Name: language language_pkey; Type: CONSTRAINT; Schema: public; Owner: kserocki
--

ALTER TABLE ONLY public.language
    ADD CONSTRAINT language_pkey PRIMARY KEY (language_id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: mpanek
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (payment_id);


--
-- Name: rental rental_pkey; Type: CONSTRAINT; Schema: public; Owner: mpanek
--

ALTER TABLE ONLY public.rental
    ADD CONSTRAINT rental_pkey PRIMARY KEY (rental_id);


--
-- Name: staff staff_pkey; Type: CONSTRAINT; Schema: public; Owner: pjasiak
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (staff_id);


--
-- Name: address address_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pjasiak
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.city(city_id);


--
-- Name: book_author book_author_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kserocki
--

ALTER TABLE ONLY public.book_author
    ADD CONSTRAINT book_author_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.author(author_id);


--
-- Name: book_author book_author_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kserocki
--

ALTER TABLE ONLY public.book_author
    ADD CONSTRAINT book_author_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.book(book_id);


--
-- Name: book_category book_category_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kserocki
--

ALTER TABLE ONLY public.book_category
    ADD CONSTRAINT book_category_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.book(book_id);


--
-- Name: book_category book_category_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kserocki
--

ALTER TABLE ONLY public.book_category
    ADD CONSTRAINT book_category_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(category_id);


--
-- Name: book book_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kserocki
--

ALTER TABLE ONLY public.book
    ADD CONSTRAINT book_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.language(language_id);


--
-- Name: city city_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pjasiak
--

ALTER TABLE ONLY public.city
    ADD CONSTRAINT city_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.country(country_id);


--
-- Name: customer customer_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mpanek
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.address(address_id);


--
-- Name: inventory inventory_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mpanek
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.book(book_id);


--
-- Name: payment payment_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mpanek
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id);


--
-- Name: payment payment_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mpanek
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staff(staff_id);


--
-- Name: rental rental_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mpanek
--

ALTER TABLE ONLY public.rental
    ADD CONSTRAINT rental_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id);


--
-- Name: rental rental_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mpanek
--

ALTER TABLE ONLY public.rental
    ADD CONSTRAINT rental_inventory_id_fkey FOREIGN KEY (inventory_id) REFERENCES public.inventory(inventory_id);


--
-- Name: rental rental_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mpanek
--

ALTER TABLE ONLY public.rental
    ADD CONSTRAINT rental_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staff(staff_id);


--
-- Name: staff staff_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pjasiak
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.address(address_id);


--
-- Name: TABLE customer; Type: ACL; Schema: public; Owner: mpanek
--

GRANT ALL ON TABLE public.customer TO kserocki;
GRANT ALL ON TABLE public.customer TO pjasiak;


--
-- Name: TABLE rental; Type: ACL; Schema: public; Owner: mpanek
--

GRANT ALL ON TABLE public.rental TO kserocki;
GRANT ALL ON TABLE public.rental TO pjasiak;


--
-- Name: TABLE active_customer_rental; Type: ACL; Schema: public; Owner: mpanek
--

GRANT ALL ON TABLE public.active_customer_rental TO kserocki;
GRANT ALL ON TABLE public.active_customer_rental TO pjasiak;


--
-- Name: TABLE address; Type: ACL; Schema: public; Owner: pjasiak
--

GRANT ALL ON TABLE public.address TO mpanek;
GRANT ALL ON TABLE public.address TO kserocki;


--
-- Name: TABLE author; Type: ACL; Schema: public; Owner: kserocki
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.author TO mpanek;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.author TO pjasiak;


--
-- Name: TABLE book; Type: ACL; Schema: public; Owner: kserocki
--

GRANT ALL ON TABLE public.book TO mpanek;
GRANT ALL ON TABLE public.book TO pjasiak;


--
-- Name: TABLE book_author; Type: ACL; Schema: public; Owner: kserocki
--

GRANT ALL ON TABLE public.book_author TO mpanek;
GRANT ALL ON TABLE public.book_author TO pjasiak;


--
-- Name: TABLE book_category; Type: ACL; Schema: public; Owner: kserocki
--

GRANT ALL ON TABLE public.book_category TO mpanek;
GRANT ALL ON TABLE public.book_category TO pjasiak;


--
-- Name: TABLE category; Type: ACL; Schema: public; Owner: kserocki
--

GRANT ALL ON TABLE public.category TO mpanek;
GRANT ALL ON TABLE public.category TO pjasiak;


--
-- Name: TABLE book_cat_desc; Type: ACL; Schema: public; Owner: kserocki
--

GRANT ALL ON TABLE public.book_cat_desc TO mpanek;
GRANT ALL ON TABLE public.book_cat_desc TO pjasiak;


--
-- Name: TABLE city; Type: ACL; Schema: public; Owner: pjasiak
--

GRANT ALL ON TABLE public.city TO kserocki;
GRANT ALL ON TABLE public.city TO mpanek;


--
-- Name: TABLE country; Type: ACL; Schema: public; Owner: pjasiak
--

GRANT ALL ON TABLE public.country TO mpanek;
GRANT ALL ON TABLE public.country TO kserocki;


--
-- Name: TABLE customer_address; Type: ACL; Schema: public; Owner: mpanek
--

GRANT ALL ON TABLE public.customer_address TO kserocki;
GRANT ALL ON TABLE public.customer_address TO pjasiak;


--
-- Name: TABLE inventory; Type: ACL; Schema: public; Owner: mpanek
--

GRANT ALL ON TABLE public.inventory TO kserocki;
GRANT ALL ON TABLE public.inventory TO pjasiak;


--
-- Name: TABLE language; Type: ACL; Schema: public; Owner: kserocki
--

GRANT ALL ON TABLE public.language TO mpanek;
GRANT ALL ON TABLE public.language TO pjasiak;


--
-- Name: TABLE language_quantity; Type: ACL; Schema: public; Owner: kserocki
--

GRANT ALL ON TABLE public.language_quantity TO mpanek;
GRANT ALL ON TABLE public.language_quantity TO pjasiak;


--
-- Name: TABLE payment; Type: ACL; Schema: public; Owner: mpanek
--

GRANT ALL ON TABLE public.payment TO kserocki;
GRANT ALL ON TABLE public.payment TO pjasiak;


--
-- Name: TABLE staff; Type: ACL; Schema: public; Owner: pjasiak
--

GRANT ALL ON TABLE public.staff TO mpanek;
GRANT ALL ON TABLE public.staff TO kserocki;


--
-- Name: TABLE staff_address; Type: ACL; Schema: public; Owner: pjasiak
--

GRANT ALL ON TABLE public.staff_address TO mpanek;
GRANT ALL ON TABLE public.staff_address TO kserocki;


--
-- Name: TABLE staff_data; Type: ACL; Schema: public; Owner: pjasiak
--

GRANT ALL ON TABLE public.staff_data TO kserocki;
GRANT ALL ON TABLE public.staff_data TO mpanek;


--
-- Name: TABLE title_author; Type: ACL; Schema: public; Owner: kserocki
--

GRANT ALL ON TABLE public.title_author TO pjasiak;
GRANT ALL ON TABLE public.title_author TO mpanek;


--
-- PostgreSQL database dump complete
--

