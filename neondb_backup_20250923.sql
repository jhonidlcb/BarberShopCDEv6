--
-- PostgreSQL database dump
--

\restrict MuEBIvXL9BbPSkB7dMPcT2LC6BNcxiYCdsQFEJSbhdtKTjif9aqsAdjGcgBNWHo

-- Dumped from database version 17.5 (84bec44)
-- Dumped by pg_dump version 17.6 (Ubuntu 17.6-1.pgdg22.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: clean_phone_format(text); Type: FUNCTION; Schema: public; Owner: neondb_owner
--

CREATE FUNCTION public.clean_phone_format(phone_input text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Remover espacios y caracteres especiales excepto +
  RETURN regexp_replace(phone_input, '[^0-9+]', '', 'g');
END;
$$;


ALTER FUNCTION public.clean_phone_format(phone_input text) OWNER TO neondb_owner;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: services; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.services (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    name_pt text NOT NULL,
    description text NOT NULL,
    description_pt text NOT NULL,
    price numeric(10,2) NOT NULL,
    duration_minutes integer NOT NULL,
    image_url text,
    active boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    price_usd numeric(10,2),
    price_brl numeric(10,2),
    price_pyg numeric(12,0),
    is_popular boolean DEFAULT false,
    name_es text,
    description_es text
);


ALTER TABLE public.services OWNER TO neondb_owner;

--
-- Name: active_services_view; Type: VIEW; Schema: public; Owner: neondb_owner
--

CREATE VIEW public.active_services_view AS
 SELECT id,
    name,
    name_pt AS "namePt",
    description,
    description_pt AS "descriptionPt",
    price_usd AS "priceUsd",
    price_brl AS "priceBrl",
    price_pyg AS "pricePyg",
    duration_minutes AS "durationMinutes",
    image_url AS "imageUrl",
    is_popular AS "isPopular",
    sort_order AS "sortOrder"
   FROM public.services
  WHERE (active = true)
  ORDER BY sort_order, name;


ALTER VIEW public.active_services_view OWNER TO neondb_owner;

--
-- Name: admin_sessions; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.admin_sessions (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    user_id character varying NOT NULL,
    token text NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.admin_sessions OWNER TO neondb_owner;

--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.admin_users (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    username text NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    role text DEFAULT 'admin'::text NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.admin_users OWNER TO neondb_owner;

--
-- Name: appointments; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.appointments (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    customer_name text NOT NULL,
    customer_phone text NOT NULL,
    customer_email text,
    service_type text NOT NULL,
    appointment_date date NOT NULL,
    appointment_time time without time zone NOT NULL,
    notes text,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    phone_country_code character varying(10),
    phone_validated boolean DEFAULT false,
    CONSTRAINT status_check CHECK ((status = ANY (ARRAY['pending'::text, 'confirmed'::text, 'completed'::text, 'cancelled'::text])))
);


ALTER TABLE public.appointments OWNER TO neondb_owner;

--
-- Name: blog_posts; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.blog_posts (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    title_pt text NOT NULL,
    slug text NOT NULL,
    content text NOT NULL,
    content_pt text NOT NULL,
    excerpt text NOT NULL,
    excerpt_pt text NOT NULL,
    category text NOT NULL,
    image_url text,
    published boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    title_es text,
    content_es text,
    excerpt_es text,
    CONSTRAINT category_check CHECK ((category = ANY (ARRAY['hair-care'::text, 'beard-care'::text, 'styling-tips'::text])))
);


ALTER TABLE public.blog_posts OWNER TO neondb_owner;

--
-- Name: company_info; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.company_info (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    section text NOT NULL,
    title text,
    title_pt text,
    content text,
    content_pt text,
    metadata jsonb,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    content_es text,
    title_es text,
    image_url text,
    content2 text,
    content2_pt text,
    barber_name text,
    barber_title text,
    barber_title_pt text,
    years_experience text,
    total_clients text,
    satisfaction text
);


ALTER TABLE public.company_info OWNER TO neondb_owner;

--
-- Name: country_codes; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.country_codes (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    country_code character varying(2) NOT NULL,
    country_name character varying(100) NOT NULL,
    dial_code character varying(10) NOT NULL,
    flag_emoji character varying(10),
    active boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.country_codes OWNER TO neondb_owner;

--
-- Name: currency_settings; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.currency_settings (
    id integer NOT NULL,
    currency_code character varying(3) NOT NULL,
    currency_name character varying(50) NOT NULL,
    currency_symbol character varying(10) NOT NULL,
    exchange_rate_to_usd numeric(10,6) DEFAULT 1.0,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.currency_settings OWNER TO neondb_owner;

--
-- Name: currency_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.currency_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.currency_settings_id_seq OWNER TO neondb_owner;

--
-- Name: currency_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.currency_settings_id_seq OWNED BY public.currency_settings.id;


--
-- Name: gallery_images; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.gallery_images (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    title text,
    title_pt text,
    image_url text NOT NULL,
    description text,
    description_pt text,
    category text DEFAULT 'general'::text,
    active boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    title_es text,
    description_es text
);


ALTER TABLE public.gallery_images OWNER TO neondb_owner;

--
-- Name: language_settings; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.language_settings (
    id integer NOT NULL,
    language_code character varying(2) NOT NULL,
    language_name character varying(50) NOT NULL,
    is_default boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.language_settings OWNER TO neondb_owner;

--
-- Name: language_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.language_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.language_settings_id_seq OWNER TO neondb_owner;

--
-- Name: language_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.language_settings_id_seq OWNED BY public.language_settings.id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.reviews (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    customer_name text NOT NULL,
    rating integer NOT NULL,
    comment text NOT NULL,
    service_type text,
    approved boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.reviews OWNER TO neondb_owner;

--
-- Name: service_hours; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.service_hours (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    day_of_week integer NOT NULL,
    day_name character varying(20) NOT NULL,
    day_name_es character varying(20),
    day_name_pt character varying(20) NOT NULL,
    is_available boolean DEFAULT true,
    start_time time without time zone,
    end_time time without time zone,
    break_start_time time without time zone,
    break_end_time time without time zone,
    slot_duration_minutes integer DEFAULT 30,
    active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    available_slots jsonb,
    CONSTRAINT service_hours_day_of_week_check CHECK (((day_of_week >= 0) AND (day_of_week <= 6))),
    CONSTRAINT service_hours_slot_duration_minutes_check CHECK ((slot_duration_minutes > 0))
);


ALTER TABLE public.service_hours OWNER TO neondb_owner;

--
-- Name: site_config; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.site_config (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    key text NOT NULL,
    value text NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.site_config OWNER TO neondb_owner;

--
-- Name: staff_members; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.staff_members (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    "position" text NOT NULL,
    position_es text,
    position_pt text NOT NULL,
    description text,
    description_es text,
    description_pt text,
    image_url text,
    years_experience integer DEFAULT 0,
    specialties text,
    specialties_es text,
    specialties_pt text,
    social_instagram text,
    social_facebook text,
    active boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.staff_members OWNER TO neondb_owner;

--
-- Name: working_hours; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.working_hours (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    day_of_week integer NOT NULL,
    day_name text NOT NULL,
    day_name_es text,
    day_name_pt text NOT NULL,
    is_open boolean DEFAULT true NOT NULL,
    open_time time without time zone,
    close_time time without time zone,
    break_start_time time without time zone,
    break_end_time time without time zone,
    slot_duration_minutes integer DEFAULT 30,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT day_of_week_check CHECK (((day_of_week >= 0) AND (day_of_week <= 6)))
);


ALTER TABLE public.working_hours OWNER TO neondb_owner;

--
-- Name: currency_settings id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.currency_settings ALTER COLUMN id SET DEFAULT nextval('public.currency_settings_id_seq'::regclass);


--
-- Name: language_settings id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.language_settings ALTER COLUMN id SET DEFAULT nextval('public.language_settings_id_seq'::regclass);


--
-- Data for Name: admin_sessions; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.admin_sessions (id, user_id, token, expires_at, created_at) FROM stdin;
526199fb-ad9a-4c79-bf42-2b2a47b18af8	23ebe38b-3e9b-47cd-857c-82d34e3b3d70	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyM2ViZTM4Yi0zZTliLTQ3Y2QtODU3Yy04MmQzNGUzYjNkNzAiLCJpYXQiOjE3NTg2Njk0MDJ9.Bf62RDiGRlViTd6yEhLkBSgJPU5NHZea_o1Ruh2LZdM	2025-09-24 23:16:42.819	2025-09-23 23:16:42.917025
8f6e11c0-97ff-4346-a1b8-2335bb17dcad	23ebe38b-3e9b-47cd-857c-82d34e3b3d70	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyM2ViZTM4Yi0zZTliLTQ3Y2QtODU3Yy04MmQzNGUzYjNkNzAiLCJpYXQiOjE3NTg2NzA1MTB9.D9Z2TfWrNk55HIderqwsTc4TfvWOs_7HSAUB8hQO77Y	2025-09-24 23:35:10.15	2025-09-23 23:35:10.247468
9ef52e69-efde-4a02-9f81-08552487cc2b	23ebe38b-3e9b-47cd-857c-82d34e3b3d70	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyM2ViZTM4Yi0zZTliLTQ3Y2QtODU3Yy04MmQzNGUzYjNkNzAiLCJpYXQiOjE3NTg3MTAzMDJ9.HNZxil6A4Aeu0puUV4zvN9sAjMkISG6_ExXMoZ81i3E	2025-09-25 10:38:22.997	2025-09-24 10:38:23.090376
644e8726-163d-485c-b184-580602a38334	23ebe38b-3e9b-47cd-857c-82d34e3b3d70	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyM2ViZTM4Yi0zZTliLTQ3Y2QtODU3Yy04MmQzNGUzYjNkNzAiLCJpYXQiOjE3NTg3MTI5Mjl9.6yuBOpGqvIccu8KXztl5uSqMGL-vMdnnLhL_WpNMvM0	2025-09-25 11:22:09.494	2025-09-24 11:22:09.568613
1e324558-23c8-4950-b943-b3755840d146	23ebe38b-3e9b-47cd-857c-82d34e3b3d70	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyM2ViZTM4Yi0zZTliLTQ3Y2QtODU3Yy04MmQzNGUzYjNkNzAiLCJpYXQiOjE3NTg3MTQ2MDh9.sFN3KKc_YEUFoqfojCPMoj6m7Hpup-BEri0UDUMhjjk	2025-09-25 11:50:08.506	2025-09-24 11:50:08.580087
c0b2e316-568d-47e6-8618-1c5968de696f	23ebe38b-3e9b-47cd-857c-82d34e3b3d70	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyM2ViZTM4Yi0zZTliLTQ3Y2QtODU3Yy04MmQzNGUzYjNkNzAiLCJpYXQiOjE3NTg3MTc5MTh9.U3gOyRkdKsx3izd50wpT77E6-EG1c6SaG3Rc2MAA4zA	2025-09-25 12:45:18.044	2025-09-24 12:45:18.119434
a516677a-be87-4846-8f20-83b81ffb7f13	23ebe38b-3e9b-47cd-857c-82d34e3b3d70	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyM2ViZTM4Yi0zZTliLTQ3Y2QtODU3Yy04MmQzNGUzYjNkNzAiLCJpYXQiOjE3NTg3MjE5MjR9.N9xefmWXgeYh6sX3US_7vrgVtXx9dRvTApzJxZIoltk	2025-09-25 13:52:04.684	2025-09-24 13:52:04.78023
fcdafd1c-51a7-414f-86cc-66eb5f52816b	23ebe38b-3e9b-47cd-857c-82d34e3b3d70	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyM2ViZTM4Yi0zZTliLTQ3Y2QtODU3Yy04MmQzNGUzYjNkNzAiLCJpYXQiOjE3NTg3MjM3NDR9.dTrJi97n2hQbcqTbPFOQXJFFqIOybPBLRJC6DhxIeZE	2025-09-25 14:22:24.108	2025-09-24 14:22:24.204943
b453329e-4e04-4684-b777-70d65716d242	23ebe38b-3e9b-47cd-857c-82d34e3b3d70	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyM2ViZTM4Yi0zZTliLTQ3Y2QtODU3Yy04MmQzNGUzYjNkNzAiLCJpYXQiOjE3NTg3MjYyNTB9.QANrRIqNOUWZwwloVB4N7v5LKr9P13-CD5qlhKCihq0	2025-09-25 15:04:10.885	2025-09-24 15:04:10.981561
26cecde3-a7a3-413f-b5cf-dea07e4bdda1	23ebe38b-3e9b-47cd-857c-82d34e3b3d70	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyM2ViZTM4Yi0zZTliLTQ3Y2QtODU3Yy04MmQzNGUzYjNkNzAiLCJpYXQiOjE3NTg3Mzc4NzJ9.XXlgP0l8cxTJrXWO69DnXqGSlh4GM4ovPXi1NUSQ9F8	2025-09-25 18:17:52.971	2025-09-24 18:17:53.045455
8dae4762-39ab-474c-9c4f-4f39b8f200ce	23ebe38b-3e9b-47cd-857c-82d34e3b3d70	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyM2ViZTM4Yi0zZTliLTQ3Y2QtODU3Yy04MmQzNGUzYjNkNzAiLCJpYXQiOjE3NTg3Mzg4MTZ9.f3IueLTbc7zJbu1i8dHKcTGS5dM2Qse6ec_W1yGfBFE	2025-09-25 18:33:36.039	2025-09-24 18:33:36.114636
963a5950-41cd-4944-b08a-aba0cc3fe3ae	23ebe38b-3e9b-47cd-857c-82d34e3b3d70	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyM2ViZTM4Yi0zZTliLTQ3Y2QtODU3Yy04MmQzNGUzYjNkNzAiLCJpYXQiOjE3NTg3NDExOTF9.efVuvZBMyjDPRLF5nqzHeMSbpuBgz4YWXRD1gcAEE4U	2025-09-25 19:13:11.284	2025-09-24 19:13:11.358423
\.


--
-- Data for Name: admin_users; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.admin_users (id, username, email, password, role, active, created_at, updated_at) FROM stdin;
23ebe38b-3e9b-47cd-857c-82d34e3b3d70	admin	admin@barberia.com	$2b$10$FuHFhTc0ctLQqAfTWnUk9e5fbbha/vx2AhragKYn6MRT5R4SM4336	admin	t	2025-09-23 10:10:35.799212	2025-09-23 23:11:53.509984
\.


--
-- Data for Name: appointments; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.appointments (id, customer_name, customer_phone, customer_email, service_type, appointment_date, appointment_time, notes, status, created_at, phone_country_code, phone_validated) FROM stdin;
27d30797-8bd7-4965-9db5-a092e37a1582	Jhoni	0985990046	alfagroupstoreok@gmail.com	haircut	2025-09-25	17:00:00	Quiero un corte clásico nomas	confirmed	2025-09-24 11:40:22.889536	\N	f
5f05f7f2-987e-40d4-bd7c-9ed2054f04ba	jhoni	+595990046		complete	2025-09-24	09:30:00	hola tarola	pending	2025-09-24 13:22:36.594967	\N	f
53febcf6-1565-432a-bce1-be8116e6f7d5	Test Cliente	+595123456789	test@test.com	1bdc6481-6d1e-43f3-87fe-63469f89b5c3	2025-09-26	10:00:00	Prueba de notificación email	pending	2025-09-24 13:48:32.51015	\N	f
35c6d75c-3ec1-4880-9be7-781ccee7861c	jhoni	+595990046		kids	2025-09-26	12:30:00	probando 	pending	2025-09-24 13:53:04.970147	\N	f
d9458f10-5b19-4e5c-ae1c-6970b1ea66a4	jhoni	+595985990046		treatments	2025-09-25	09:30:00	quiero tratamiento	pending	2025-09-24 14:16:10.447792	\N	f
\.


--
-- Data for Name: blog_posts; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.blog_posts (id, title, title_pt, slug, content, content_pt, excerpt, excerpt_pt, category, image_url, published, created_at, updated_at, title_es, content_es, excerpt_es) FROM stdin;
\.


--
-- Data for Name: company_info; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.company_info (id, section, title, title_pt, content, content_pt, metadata, created_at, updated_at, content_es, title_es, image_url, content2, content2_pt, barber_name, barber_title, barber_title_pt, years_experience, total_clients, satisfaction) FROM stdin;
705eebe0-dca1-4494-8182-0d1c05096f5c	about	Nuestra Historia	Nossa História	Más de 15 años ofreciendo los mejores servicios de barbería en Ciudad del Este. Combinamos técnicas tradicionales con un toque moderno para brindar a nuestros clientes una experiencia única. Nuestro equipo de profesionales está comprometido con la excelencia y la satisfacción del cliente. 	Mais de 15 anos oferecendo os melhores serviços de barbearia em Ciudad del Este. Combinamos técnicas tradicionais com um toque moderno para proporcionar aos nossos clientes uma experiência única. Nossa equipe de profissionais está comprometida com a excelência e a satisfação do cliente.	{"clients_count": "5000+", "experience_years": "15"}	2025-09-22 22:39:05.134276	2025-09-24 18:12:07.974	Más de 15 años ofreciendo los mejores servicios de barbería en Ciudad del Este. Combinamos técnicas tradicionales con un toque moderno.	Sobre Nosotros	/uploads/image-1758726491237-362980867.jpg	Creemos que cada cliente es único y merece un servicio personalizado. Por eso, nos tomamos el tiempo necesario para entender tus necesidades y brindarte exactamente lo que buscas.	Acreditamos que cada cliente é único e merece um atendimento personalizado. Por isso, dedicamos o tempo necessário para entender suas necessidades e oferecer exatamente o que você procura.	Carlos Silva	Maestro Barbero	Mestre Barbeiro	15	1556	100
1021f62d-1dd6-42ab-b9a6-9bb22befadc5	contact	Contacto	Contato	Av. San Blas 123, Ciudad del Este	Av. San Blas 123, Ciudad del Este	{"email": "info@barberiaclasica.com", "phone": "+595 61 123456", "whatsapp": "+595984123456"}	2025-09-23 10:14:26.207826	2025-09-24 18:12:08.271	Av. San Blas 123, Ciudad del Este	Contacto	\N	\N	\N	\N	\N	\N	\N	\N	\N
080ffbfc-5ef5-4cf0-8590-0ed6c51c098e	hero	Barbería Clásica	Barbearia Clássica	Tu barbería de confianza en Ciudad del Este	Sua barbearia de confiança em Ciudad del Este	{"subtitle": "BARBEARIA TRADICIONAL", "subtitle_pt": "BARBEARIA TRADICIONAL"}	2025-09-22 22:39:05.134276	2025-09-24 18:12:08.564	Tu barbería de confianza en Ciudad del Este	Barbería Clásica	\N	\N	\N	\N	\N	\N	\N	\N	\N
c5e94ccc-06e2-42bc-8f87-6882c9e5093e	hours	Horarios	Horários	Lunes a Viernes: 8:00 - 20:00\\nSábados: 8:00 - 18:00\\nDomingos: Cerrado	Segunda a Sexta: 8:00 - 20:00\\nSábados: 8:00 - 18:00\\nDomingos: Fechado	{}	2025-09-23 10:14:26.207826	2025-09-24 18:12:08.857	Lunes a Viernes: 8:00 - 20:00\\nSábados: 8:00 - 18:00\\nDomingos: Cerrado	Horarios	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: country_codes; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.country_codes (id, country_code, country_name, dial_code, flag_emoji, active, sort_order, created_at) FROM stdin;
37dfbe5d-0ad9-4ecb-bcaf-c2403fcd54e5	PY	Paraguay	+595	🇵🇾	t	1	2025-09-24 14:30:03.071637
898bce2f-5f3a-4938-bfb7-792965cc3a16	BR	Brasil	+55	🇧🇷	t	2	2025-09-24 14:30:03.071637
e9ee5173-613b-4921-bd6a-fe9b02fbb940	AR	Argentina	+54	🇦🇷	t	3	2025-09-24 14:30:03.071637
862fbf6f-8676-4b40-9e8c-60766826dc11	US	Estados Unidos	+1	🇺🇸	t	4	2025-09-24 14:30:03.071637
324de128-eba6-4450-8f86-5987a5ddb327	ES	España	+34	🇪🇸	t	5	2025-09-24 14:30:03.071637
\.


--
-- Data for Name: currency_settings; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.currency_settings (id, currency_code, currency_name, currency_symbol, exchange_rate_to_usd, is_active, created_at, updated_at) FROM stdin;
1	USD	Dólar Estadounidense	$	1.000000	t	2025-09-23 21:44:41.079202	2025-09-23 21:44:41.079202
2	BRL	Real Brasileño	R$	5.500000	t	2025-09-23 21:44:41.079202	2025-09-23 21:44:41.079202
3	PYG	Guaraní Paraguayo	₲	7300.000000	t	2025-09-23 21:44:41.079202	2025-09-23 21:44:41.079202
\.


--
-- Data for Name: gallery_images; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.gallery_images (id, title, title_pt, image_url, description, description_pt, category, active, sort_order, created_at, title_es, description_es) FROM stdin;
4e6658a9-638d-4eb6-b75e-9600bb16f254	Interior Principal	Interior Principal	https://images.unsplash.com/photo-1585747860715-2ba37e788b70	\N	\N	interior	t	0	2025-09-22 22:39:05.326406	Interior Principal	\N
85da0677-9e95-45c1-86f1-a45cf1da9d36	Herramientas	Ferramentas	https://images.unsplash.com/photo-1503951914875-452162b0f3f1	\N	\N	tools	t	0	2025-09-22 22:39:05.326406	Herramientas	\N
204c7fb8-ef4d-4f09-a21e-41e8b480536d	Corte Clásico	Corte Clássico	https://images.unsplash.com/photo-1621605815971-fbc98d665033	\N	\N	services	t	0	2025-09-22 22:39:05.326406	Corte Clásico	\N
a4bf2f1d-3532-45b5-aff1-12bf5b7275ef	Interior Principal	Interior Principal	https://images.unsplash.com/photo-1585747860715-2ba37e788b70	\N	\N	interior	t	0	2025-09-22 22:39:41.094772	Interior Principal	\N
21b1ea0e-3e30-418b-8680-aa7a7a543780	Herramientas	Ferramentas	https://images.unsplash.com/photo-1503951914875-452162b0f3f1	\N	\N	tools	t	0	2025-09-22 22:39:41.094772	Herramientas	\N
b778dff2-b379-4d3c-83f3-ecdac6f2bf83	Corte Clásico	Corte Clássico	https://images.unsplash.com/photo-1621605815971-fbc98d665033	\N	\N	services	t	0	2025-09-22 22:39:41.094772	Corte Clásico	\N
7e65279f-9de7-4e17-8a81-a5c7010e4054	Corte Clásico 1	Corte Clássico 1	https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400	Ejemplo de corte clásico	Exemplo de corte clássico	haircuts	t	1	2025-09-23 10:10:36.155991	Corte Clásico 1	Ejemplo de corte clásico
a44be9df-8bb9-40ca-b54c-5d699590cf1c	Barbería Interior	Interior da Barbearia	https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=400	Interior de nuestra barbería	Interior da nossa barbearia	interior	t	2	2025-09-23 10:10:36.155991	Barbería Interior	Interior de nuestra barbería
b3761149-8a67-499d-9ccf-2bb5f7941d4d	Corte Clásico Masculino	Corte Clássico Masculino	https://images.unsplash.com/photo-1503951914875-452162b0f3f1	Ejemplo de nuestro corte clásico	Exemplo do nosso corte clássico	cortes	t	1	2025-09-23 10:14:26.032883	Corte Clásico Masculino	Ejemplo de nuestro corte clásico
035e37a8-1ee7-43b0-9a93-787237451724	Arreglo de Barba	Arreglo de Barba	https://images.unsplash.com/photo-1621605815971-fbc98d665033	Barba perfectamente arreglada	Barba perfeitamente arrumada	barbas	t	2	2025-09-23 10:14:26.032883	Arreglo de Barba	Barba perfectamente arreglada
4804dc49-737a-4db3-9d09-778f43b96bdf	Interior Barbería	Interior Barbearia	https://images.unsplash.com/photo-1585747860715-2ba37e788b70	Nuestro acogedor interior	Nosso interior aconchegante	local	t	3	2025-09-23 10:14:26.032883	Interior Barbería	Nuestro acogedor interior
312a3567-6933-47ad-8dc2-bd4616849aca	Nombre es	Nombre pt	/uploads/image-1758726336268-305717748.png	Descripción es	Descripción pt	services	t	0	2025-09-24 15:06:11.915936	\N	\N
\.


--
-- Data for Name: language_settings; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.language_settings (id, language_code, language_name, is_default, is_active, created_at) FROM stdin;
1	es	Español	t	t	2025-09-23 21:44:41.432026
2	pt	Português	f	t	2025-09-23 21:44:41.432026
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.reviews (id, customer_name, rating, comment, service_type, approved, created_at) FROM stdin;
ca0c6576-8f31-4159-a610-87ca975aab4c	Carlos López	5	Excelente servicio, muy profesional	corte-cabello	t	2025-09-22 22:28:24.427301
98c3006c-39ce-4c5c-9d11-397015d5d520	Ana Martín	4	Muy buena atención, recomendado	barba	t	2025-09-22 22:28:24.427301
\.


--
-- Data for Name: service_hours; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.service_hours (id, day_of_week, day_name, day_name_es, day_name_pt, is_available, start_time, end_time, break_start_time, break_end_time, slot_duration_minutes, active, created_at, updated_at, available_slots) FROM stdin;
f496596b-9921-41b1-9662-ddbff36d6022	0	Sunday	Domingo	Domingo	f	\N	\N	\N	\N	30	t	2025-09-24 19:12:35.138658	2025-09-24 19:12:35.138658	\N
c395198e-256f-4af5-b132-75baf8361a93	1	Monday	Lunes	Segunda-feira	t	08:00:00	20:00:00	\N	\N	30	t	2025-09-24 19:12:35.138658	2025-09-24 19:12:35.138658	["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30"]
0ac7f5d0-f11b-45ea-b65f-dabc2caffa30	3	Wednesday	Miércoles	Quarta-feira	t	08:00:00	20:00:00	\N	\N	30	t	2025-09-24 19:12:35.138658	2025-09-24 19:12:35.138658	["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30"]
3e3841ef-224e-4fdb-a0d8-f1e960a4346b	4	Thursday	Jueves	Quinta-feira	t	08:00:00	20:00:00	\N	\N	30	t	2025-09-24 19:12:35.138658	2025-09-24 19:12:35.138658	["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30"]
1306f480-a841-46c0-ba6d-87e23f674bca	5	Friday	Viernes	Sexta-feira	t	08:00:00	20:00:00	\N	\N	30	t	2025-09-24 19:12:35.138658	2025-09-24 19:12:35.138658	["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30"]
74adfe62-5377-4704-85ad-6e01dada65ba	6	Saturday	Sábado	Sábado	t	08:00:00	18:00:00	\N	\N	30	t	2025-09-24 19:12:35.138658	2025-09-24 19:12:35.138658	["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30"]
8b679d6e-0f70-434a-a84e-8f00e649c55c	2	Tuesday	Martes	Terça-feira	t	08:00:00	21:00:00	\N	\N	30	t	2025-09-24 19:12:35.138658	2025-09-24 19:14:52.57	["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.services (id, name, name_pt, description, description_pt, price, duration_minutes, image_url, active, sort_order, created_at, updated_at, price_usd, price_brl, price_pyg, is_popular, name_es, description_es) FROM stdin;
1bdc6481-6d1e-43f3-87fe-63469f89b5c3	Corte Clásicoss	Corte Clássico	Corte tradicional con tijera y navaja	Corte tradicional com tesoura e navalha	25.00	45	\N	t	0	2025-09-22 22:39:04.939692	2025-09-24 14:46:40.764	250.00	137.50	182500	t	Corte Clásico	Corte tradicional con tijera y navaja
fa015ba4-057d-472d-ac14-2bdd47c0e9ac	Barba y Bigote	Barba e Bigode	Arreglo completo de barba y bigote	Arranjo completo de barba e bigode	20.00	30	\N	t	0	2025-09-22 22:39:04.939692	2025-09-22 22:39:04.939692	20.00	110.00	146000	f	Barba y Bigote	Arreglo completo de barba y bigote
8d6de9d6-8b88-499d-b910-2fcb63b79cb5	Corte + Barba	Corte + Barba	Servicio completo de corte y barba	Serviço completo de corte e barba	40.00	75	\N	t	0	2025-09-22 22:39:04.939692	2025-09-22 22:39:04.939692	40.00	220.00	292000	f	Corte + Barba	Servicio completo de corte y barba
7766f643-4ef4-4ea4-bb09-28e0727de03f	Corte Clásico	Corte Clássico	Corte tradicional con tijera y navaja	Corte tradicional com tesoura e navalha	25.00	45	\N	t	0	2025-09-22 22:39:40.742657	2025-09-22 22:39:40.742657	25.00	137.50	182500	f	Corte Clásico	Corte tradicional con tijera y navaja
58965c31-bd45-4b08-abbf-7b88f8325473	Barba y Bigote	Barba e Bigode	Arreglo completo de barba y bigote	Arranjo completo de barba e bigode	20.00	30	\N	t	0	2025-09-22 22:39:40.742657	2025-09-22 22:39:40.742657	20.00	110.00	146000	f	Barba y Bigote	Arreglo completo de barba y bigote
25458afb-61cc-48f9-91a9-6ed0e6cc7174	Corte + Barba	Corte + Barba	Servicio completo de corte y barba	Serviço completo de corte e barba	40.00	75	\N	t	0	2025-09-22 22:39:40.742657	2025-09-22 22:39:40.742657	40.00	220.00	292000	f	Corte + Barba	Servicio completo de corte y barba
c26bcf4a-27df-4df7-806b-bd87b64856f9	Corte Clásico	Corte Clássico	Corte tradicional con tijera y navaja	Corte tradicional com tesoura e navalha	25.00	30	\N	t	1	2025-09-23 10:10:35.975213	2025-09-23 10:10:35.975213	25.00	137.50	182500	f	Corte Clásico	Corte tradicional con tijera y navaja
17db7365-360a-438d-8746-02e9e6e60e6f	Afeitado	Barbeado	Afeitado tradicional con navaja	Barbeado tradicional com navalha	20.00	20	\N	t	2	2025-09-23 10:10:35.975213	2025-09-23 10:10:35.975213	20.00	110.00	146000	f	Afeitado	Afeitado tradicional con navaja
ee13f67c-15cf-4756-a222-e0f31d755d93	Corte Clásico	Corte Clássico	Corte tradicional con tijera y máquina, incluye lavado	Corte tradicional com tesoura e máquina, inclui lavagem	25.00	30	https://images.unsplash.com/photo-1503951914875-452162b0f3f1	t	1	2025-09-23 10:14:25.858824	2025-09-23 10:14:25.858824	25.00	137.50	182500	f	Corte Clásico	Corte tradicional con tijera y máquina, incluye lavado
16bd17a9-610a-4fde-9ee4-42d210945e16	Barba Completa	Barba Completa	Arreglo de barba con navaja, incluye toallas calientes	Arreglo de barba com navalha, inclui toalhas quentes	20.00	25	https://images.unsplash.com/photo-1621605815971-fbc98d665033	t	2	2025-09-23 10:14:25.858824	2025-09-23 10:14:25.858824	20.00	110.00	146000	f	Barba Completa	Arreglo de barba con navaja, incluye toallas calientes
b4dd0da7-6334-4734-be3e-3f681e142e92	Corte + Barba	Corte + Barba	Servicio completo de corte y arreglo de barba	Serviço completo de corte e arreglo de barba	40.00	50	https://images.unsplash.com/photo-1599351431202-1e0f0137899a	t	3	2025-09-23 10:14:25.858824	2025-09-23 10:14:25.858824	40.00	220.00	292000	f	Corte + Barba	Servicio completo de corte y arreglo de barba
\.


--
-- Data for Name: site_config; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.site_config (id, key, value, description, created_at, updated_at) FROM stdin;
7ccaa500-ab6a-43f5-9448-fdd6991cfe55	site_description	Tu barbería de confianza en Ciudad del Este	Descripción del sitio web	2025-09-23 10:14:26.392693	2025-09-24 18:57:39.45
144d2e9c-2578-4dfe-89ec-b8d597983188	site_email	softwarepar.lat@gmail.com	Email principal de contacto	2025-09-22 22:39:40.562549	2025-09-24 18:57:39.743
de6fb741-ae55-4055-a91f-2b7b0883dd98	site_name	Barbería Clasica	Nombre del sitio web	2025-09-22 22:39:40.562549	2025-09-24 18:57:40.037
53277746-1fca-4d98-b153-72f3c05ebc70	site_phone	+595 985990046	Teléfono principal	2025-09-22 22:39:40.562549	2025-09-24 18:57:40.331
318b3ade-00de-49fc-82a5-af5a1b1c4804	system_timezone	America/Asuncion	Zona horaria del sistema	2025-09-23 23:33:16.617538	2025-09-24 18:57:40.625
fd38e581-b99f-44f9-a98e-059ff8d73143	whatsapp_number	+595985990046	Número de WhatsApp	2025-09-22 22:39:40.562549	2025-09-24 18:57:40.919
db7e39f0-3636-4f0d-9c69-3164769c1fa3	address	Av. Monseñor Rodríguez 1245, Ciudad del Este, Paraguay	Dirección completa	2025-09-22 22:39:40.562549	2025-09-24 18:57:35.623
e6ab6b3e-4508-4ffe-83ce-832d8e283941	admin_panel_theme	modern	Tema del panel de administración	2025-09-23 23:33:16.424363	2025-09-24 18:57:35.918
01d84fff-76a8-425d-bb9d-12582f4c5374	business_hours	{"monday": "8:00-20:00", "tuesday": "8:00-20:00", "wednesday": "8:00-20:00", "thursday": "8:00-20:00", "friday": "8:00-20:00", "saturday": "8:00-18:00", "sunday": "closed"}	Horarios de atención	2025-09-23 10:14:26.392693	2025-09-24 18:57:36.212
c17175d4-7e1f-417d-849d-78ac9de58078	facebook_url	https://facebook.com/barberiaelite	URL de Facebook	2025-09-22 22:39:40.562549	2025-09-24 18:57:36.506
f1d2330f-f0df-4c97-a7f4-b456b78846d6	google_maps_url	https://maps.google.com/?q=Ciudad+del+Este	URL de Google Maps	2025-09-23 10:14:26.392693	2025-09-24 18:57:36.8
77258ae5-6a65-4daf-b07c-7ba8c4a1553d	hours_friday	8:00 - 20:00	Horario de atención - Viernes	2025-09-24 10:37:38.848505	2025-09-24 18:57:37.096
5a575585-9a90-485f-977e-f4859de517ad	hours_monday	8:00 - 20:00	Horario de atención - Lunes	2025-09-24 10:37:38.848505	2025-09-24 18:57:37.39
9fea7919-00a3-4498-b95c-6a9719f587ba	hours_saturday	8:00 - 13:00	Horario de atención - Sábado	2025-09-24 10:37:38.848505	2025-09-24 18:57:37.685
9ae31f87-1476-42f3-a862-8f0ab4e5bb9e	hours_sunday	Cerrado	Horario de atención - Domingo	2025-09-24 10:37:38.848505	2025-09-24 18:57:37.979
4afb7594-203b-4457-984a-a8f2c93c28ba	hours_thursday	8:00 - 20:00	Horario de atención - Jueves	2025-09-24 10:37:38.848505	2025-09-24 18:57:38.273
0a6d1dc2-a9c2-4108-9819-2e14464667cc	hours_tuesday	8:00 - 20:00	Horario de atención - Martes	2025-09-24 10:37:38.848505	2025-09-24 18:57:38.569
4e199a00-7ffa-42fc-bdfd-d39b8d0386ef	hours_wednesday	8:00 - 20:00	Horario de atención - Miércoles	2025-09-24 10:37:38.848505	2025-09-24 18:57:38.863
49ca6006-9592-4e88-a792-7ddef4c6009c	instagram_url	https://instagram.com/barberiaelite	URL de Instagram	2025-09-22 22:39:40.562549	2025-09-24 18:57:39.156
\.


--
-- Data for Name: staff_members; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.staff_members (id, name, "position", position_es, position_pt, description, description_es, description_pt, image_url, years_experience, specialties, specialties_es, specialties_pt, social_instagram, social_facebook, active, sort_order, created_at, updated_at) FROM stdin;
d3fafe29-392d-483b-8583-13b58e47fec5	Miguel Rodríguez	Barbero Senior	Barbero Senior	Barbeiro Sênior	Experto en estilos modernos y técnicas avanzadas de corte.	Experto en estilos modernos y técnicas avanzadas de corte.	Especialista em estilos modernos e técnicas avançadas de corte.	https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400	15	Cortes modernos, Fade, Diseños	Cortes modernos, Fade, Diseños	Cortes modernos, Fade, Desenhos	\N	\N	t	2	2025-09-24 18:29:31.045553	2025-09-24 18:29:31.045553
5cf0f63a-a631-4daf-9858-a13e43fa14f1	Juan López	Barbero	Barbero	Barbeiro	Joven talento especializado en tendencias actuales y atención al cliente.	Joven talento especializado en tendencias actuales y atención al cliente.	Jovem talento especializado em tendências atuais e atendimento ao cliente.	https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400	8	Tendencias actuales, Cortes juveniles	Tendencias actuales, Cortes juveniles	Tendências atuais, Cortes juvenis	\N	\N	t	3	2025-09-24 18:29:31.045553	2025-09-24 18:29:31.045553
8996664a-6d57-48f5-9091-d0e462f7fe06	Carlos Silva	Maestro Barbero	Maestro Barbero1	Mestre Barbeiro2	Especialista en cortes clásicos y modernos con más de 20 años de experiencia.	Especialista en cortes clásicos y modernos con más de 20 años de experiencia.	Especialista em cortes clássicos e modernos com mais de 20 anos de experiência.	/uploads/image-1758740800271-758935995.png	20	Cortes clásicos, Afeitado tradicional, Barba	Cortes clásicos, Afeitado tradicional, Barba	Cortes clássicos, Barbeado tradicional, Barba			t	1	2025-09-24 18:29:31.045553	2025-09-24 19:06:43.377
\.


--
-- Data for Name: working_hours; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.working_hours (id, day_of_week, day_name, day_name_es, day_name_pt, is_open, open_time, close_time, break_start_time, break_end_time, slot_duration_minutes, active, created_at, updated_at) FROM stdin;
5d5a038a-d21c-4e7f-9c24-65c4272f635d	1	Monday	Lunes	Segunda-feira	t	08:00:00	20:00:00	\N	\N	30	t	2025-09-24 18:29:31.286554	2025-09-24 18:29:31.286554
bf0a64de-d81e-46b1-be9a-6e217370ed40	2	Tuesday	Martes	Terça-feira	t	08:00:00	20:00:00	\N	\N	30	t	2025-09-24 18:29:31.286554	2025-09-24 18:29:31.286554
98e88451-85e8-418d-8bee-1a677206baee	3	Wednesday	Miércoles	Quarta-feira	t	08:00:00	20:00:00	\N	\N	30	t	2025-09-24 18:29:31.286554	2025-09-24 18:29:31.286554
0f20e705-d6f2-4046-b433-a5c68402a1e7	4	Thursday	Jueves	Quinta-feira	t	08:00:00	20:00:00	\N	\N	30	t	2025-09-24 18:29:31.286554	2025-09-24 18:29:31.286554
c38d170f-8da7-4094-be66-8366779fe08c	5	Friday	Viernes	Sexta-feira	t	08:00:00	20:00:00	\N	\N	30	t	2025-09-24 18:29:31.286554	2025-09-24 18:29:31.286554
e3ad0020-a584-40da-93d5-38a31ae2ae7f	6	Saturday	Sábado	Sábado	t	08:00:00	18:00:00	\N	\N	30	t	2025-09-24 18:29:31.286554	2025-09-24 18:29:31.286554
2ca6f95b-181f-448b-b7f4-80b3bf163239	0	Sunday	Domingo	Domingo	f	\N	\N	\N	\N	30	t	2025-09-24 18:29:31.286554	2025-09-24 18:29:31.286554
\.


--
-- Name: currency_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.currency_settings_id_seq', 7, true);


--
-- Name: language_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.language_settings_id_seq', 5, true);


--
-- Name: admin_sessions admin_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.admin_sessions
    ADD CONSTRAINT admin_sessions_pkey PRIMARY KEY (id);


--
-- Name: admin_sessions admin_sessions_token_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.admin_sessions
    ADD CONSTRAINT admin_sessions_token_key UNIQUE (token);


--
-- Name: admin_users admin_users_email_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_email_key UNIQUE (email);


--
-- Name: admin_users admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: admin_users admin_users_username_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_username_key UNIQUE (username);


--
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (id);


--
-- Name: blog_posts blog_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blog_posts
    ADD CONSTRAINT blog_posts_pkey PRIMARY KEY (id);


--
-- Name: blog_posts blog_posts_slug_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blog_posts
    ADD CONSTRAINT blog_posts_slug_key UNIQUE (slug);


--
-- Name: company_info company_info_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.company_info
    ADD CONSTRAINT company_info_pkey PRIMARY KEY (id);


--
-- Name: company_info company_info_section_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.company_info
    ADD CONSTRAINT company_info_section_key UNIQUE (section);


--
-- Name: country_codes country_codes_country_code_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.country_codes
    ADD CONSTRAINT country_codes_country_code_key UNIQUE (country_code);


--
-- Name: country_codes country_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.country_codes
    ADD CONSTRAINT country_codes_pkey PRIMARY KEY (id);


--
-- Name: currency_settings currency_settings_currency_code_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.currency_settings
    ADD CONSTRAINT currency_settings_currency_code_key UNIQUE (currency_code);


--
-- Name: currency_settings currency_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.currency_settings
    ADD CONSTRAINT currency_settings_pkey PRIMARY KEY (id);


--
-- Name: gallery_images gallery_images_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.gallery_images
    ADD CONSTRAINT gallery_images_pkey PRIMARY KEY (id);


--
-- Name: language_settings language_settings_language_code_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.language_settings
    ADD CONSTRAINT language_settings_language_code_key UNIQUE (language_code);


--
-- Name: language_settings language_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.language_settings
    ADD CONSTRAINT language_settings_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: service_hours service_hours_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.service_hours
    ADD CONSTRAINT service_hours_pkey PRIMARY KEY (id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: site_config site_config_key_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.site_config
    ADD CONSTRAINT site_config_key_key UNIQUE (key);


--
-- Name: site_config site_config_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.site_config
    ADD CONSTRAINT site_config_pkey PRIMARY KEY (id);


--
-- Name: staff_members staff_members_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.staff_members
    ADD CONSTRAINT staff_members_pkey PRIMARY KEY (id);


--
-- Name: service_hours unique_day_of_week; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.service_hours
    ADD CONSTRAINT unique_day_of_week UNIQUE (day_of_week);


--
-- Name: appointments unique_slot; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT unique_slot UNIQUE (appointment_date, appointment_time);


--
-- Name: working_hours working_hours_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.working_hours
    ADD CONSTRAINT working_hours_pkey PRIMARY KEY (id);


--
-- Name: idx_admin_sessions_expires; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_admin_sessions_expires ON public.admin_sessions USING btree (expires_at);


--
-- Name: idx_appointments_date; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_appointments_date ON public.appointments USING btree (appointment_date);


--
-- Name: idx_appointments_date_time; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_appointments_date_time ON public.appointments USING btree (appointment_date, appointment_time);


--
-- Name: idx_appointments_status; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_appointments_status ON public.appointments USING btree (status);


--
-- Name: idx_blog_posts_category; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_blog_posts_category ON public.blog_posts USING btree (category);


--
-- Name: idx_blog_posts_published; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_blog_posts_published ON public.blog_posts USING btree (published);


--
-- Name: idx_company_info_section; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_company_info_section ON public.company_info USING btree (section);


--
-- Name: idx_gallery_images_active; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_gallery_images_active ON public.gallery_images USING btree (active);


--
-- Name: idx_reviews_approved; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_reviews_approved ON public.reviews USING btree (approved);


--
-- Name: idx_service_hours_available; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_service_hours_available ON public.service_hours USING btree (is_available, active);


--
-- Name: idx_service_hours_day_active; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_service_hours_day_active ON public.service_hours USING btree (day_of_week, active);


--
-- Name: idx_services_active; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_services_active ON public.services USING btree (active);


--
-- Name: idx_services_active_sort; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_services_active_sort ON public.services USING btree (active, sort_order);


--
-- Name: idx_staff_members_active; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_staff_members_active ON public.staff_members USING btree (active);


--
-- Name: idx_staff_members_sort; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_staff_members_sort ON public.staff_members USING btree (active, sort_order);


--
-- Name: idx_working_hours_day; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX idx_working_hours_day ON public.working_hours USING btree (day_of_week);


--
-- Name: admin_sessions admin_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.admin_sessions
    ADD CONSTRAINT admin_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.admin_users(id) ON DELETE CASCADE;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO neon_superuser WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON TABLES TO neon_superuser WITH GRANT OPTION;


--
-- PostgreSQL database dump complete
--

\unrestrict MuEBIvXL9BbPSkB7dMPcT2LC6BNcxiYCdsQFEJSbhdtKTjif9aqsAdjGcgBNWHo

