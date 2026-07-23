--
-- PostgreSQL database dump
--


-- Dumped from database version 18.4 (2773af8)
-- Dumped by pg_dump version 18.1

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: outstanding_fees(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.outstanding_fees() RETURNS json
    LANGUAGE plpgsql
    AS $$
declare
  result json;
begin
  select json_agg(
    json_build_object(
      'student_id', s.student_id,
      'total_fee_due', s.total_fee_due,
      'total_paid', coalesce(paid.total_paid, 0),
      'remaining', s.total_fee_due - coalesce(paid.total_paid, 0)
    )
  )
  into result
  from student_info s
  left join (
    select student_id, sum(amount) as total_paid
    from student_fees
    group by student_id
  ) paid on s.student_id = paid.student_id;

  return result;
end;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: courses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.courses (
    course_id character varying(12) NOT NULL,
    course_name character varying(50) NOT NULL,
    credits integer NOT NULL
);


--
-- Name: enrollment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enrollment (
    enrollment_id integer NOT NULL,
    student_id character varying(8) NOT NULL,
    course_id character varying(12) NOT NULL,
    grade character varying(2)
);


--
-- Name: enrollment_enrollment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.enrollment_enrollment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enrollment_enrollment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.enrollment_enrollment_id_seq OWNED BY public.enrollment.enrollment_id;


--
-- Name: lecturer_course; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lecturer_course (
    lecturer_id character varying(8) NOT NULL,
    course_id character varying(12) NOT NULL
);


--
-- Name: lecturer_ta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lecturer_ta (
    lecturer_id character varying(8) NOT NULL,
    ta_id character varying(8) NOT NULL
);


--
-- Name: lecturers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lecturers (
    lecturer_id character varying(8) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(30) NOT NULL,
    CONSTRAINT chk_lect_id CHECK ((length((lecturer_id)::text) = 8))
);


--
-- Name: student_fees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.student_fees (
    payment_id integer NOT NULL,
    student_id character varying(8) NOT NULL,
    amount numeric(8,2) NOT NULL,
    date_of_payment date,
    CONSTRAINT chk_student_id CHECK ((length((student_id)::text) = 8))
);


--
-- Name: student_fees_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.student_fees_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: student_fees_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.student_fees_payment_id_seq OWNED BY public.student_fees.payment_id;


--
-- Name: student_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.student_info (
    student_id character varying(8) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(30) NOT NULL,
    date_of_birth date,
    total_fee_due numeric(8,2),
    CONSTRAINT chk_student_id CHECK ((length((student_id)::text) = 8))
);


--
-- Name: teaching_assistant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teaching_assistant (
    ta_id character varying(8) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(30) NOT NULL,
    CONSTRAINT ch_ta_id CHECK ((length((ta_id)::text) = 8))
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    student_id character varying(8) NOT NULL,
    email character varying(50) NOT NULL,
    password_hash character varying(100) NOT NULL
);


--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: enrollment enrollment_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollment ALTER COLUMN enrollment_id SET DEFAULT nextval('public.enrollment_enrollment_id_seq'::regclass);


--
-- Name: student_fees payment_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_fees ALTER COLUMN payment_id SET DEFAULT nextval('public.student_fees_payment_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.courses (course_id, course_name, credits) FROM stdin;
CPEN103	Computer Engineering Innovations	3
CPEN104	Engineering Design	2
CPEN201	C++ Programming	3
CPEN203	Digital Circuits	3
CPEN213	Discrete Mathematics	3
CPEN211	Database System Design	3
CPEN214	Digital Systems Design	3
CPEN204	Data Structures and Algorithms	3
CPEN206	Linear Circuits	3
CPEN208	Software Engineering	3
CPEN212	Data Communications	2
CPEN301	Signals and Systems	3
CPEN305	Computer Networks	3
CPEN307	Operating Systems	3
CPEN311	Object-Oriented Programming	3
CPEN313	Microelectronics Circuit Analysis and Design	3
CPEN315	Computer Organization and Architecture	3
CPEN304	Digital Signal Processing	3
CPEN314	Industrial Practice	1
CPEN316	Artificial Intelligence and Applications	3
CPEN318	Software for Distributed Systems	3
CPEN322	Microprocessor Programming and Interfacing	3
CPEN324	Research Methods	3
CPEN400	Independent Project	6
CPEN401	Control Systems Analysis and Design	3
CPEN403	Embedded Systems	3
CPEN419	Computer Vision	3
CPEN429	Emerging Trends in Computer Engineering	3
CPEN409	Computer Graphics	3
CPEN411	VLSI Systems Design	3
CPEN415	Distributed Computing	3
CPEN421	Mobile and Web Software Design	3
CPEN423	Digital Forensics	3
CPEN425	Real-Time Systems	3
CPEN427	Cryptography	3
CPEN406	Wireless Communication Systems	3
CPEN424	Robotics	3
CPEN426	Computer and Network Security	3
CPEN444	Professional Development	2
CPEN408	Human-Computer Interface	3
CPEN422	Multimedia Systems	3
CPEN432	Wireless Sensor Networks	3
CPEN434	Digital Image Processing	3
CPEN438	Advanced Computer Architecture Systems	3
CPEN442	Introduction to Machine Learning	3
\.


--
-- Data for Name: enrollment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.enrollment (enrollment_id, student_id, course_id, grade) FROM stdin;
1	22384451	CPEN214	\N
2	22384451	CPEN204	\N
3	22384451	CPEN206	\N
4	22384451	CPEN208	\N
5	22384451	CPEN212	\N
6	22357814	CPEN214	\N
7	22357814	CPEN204	\N
8	22357814	CPEN206	\N
9	22357814	CPEN208	\N
10	22357814	CPEN212	\N
11	22375367	CPEN214	\N
12	22375367	CPEN204	\N
13	22375367	CPEN206	\N
14	22375367	CPEN208	\N
15	22375367	CPEN212	\N
16	22397756	CPEN214	\N
17	22397756	CPEN204	\N
18	22397756	CPEN206	\N
19	22397756	CPEN208	\N
20	22397756	CPEN212	\N
21	22369321	CPEN214	\N
22	22369321	CPEN204	\N
23	22369321	CPEN206	\N
24	22369321	CPEN208	\N
25	22369321	CPEN212	\N
26	22301848	CPEN214	\N
27	22301848	CPEN204	\N
28	22301848	CPEN206	\N
29	22301848	CPEN208	\N
30	22301848	CPEN212	\N
31	22339520	CPEN214	\N
32	22339520	CPEN204	\N
33	22339520	CPEN206	\N
34	22339520	CPEN208	\N
35	22339520	CPEN212	\N
36	22333597	CPEN214	\N
37	22333597	CPEN204	\N
38	22333597	CPEN206	\N
39	22333597	CPEN208	\N
40	22333597	CPEN212	\N
41	22268986	CPEN214	\N
42	22268986	CPEN204	\N
43	22268986	CPEN206	\N
44	22268986	CPEN208	\N
45	22268986	CPEN212	\N
46	22381577	CPEN214	\N
47	22381577	CPEN204	\N
48	22381577	CPEN206	\N
49	22381577	CPEN208	\N
50	22381577	CPEN212	\N
51	22315830	CPEN214	\N
52	22315830	CPEN204	\N
53	22315830	CPEN206	\N
54	22315830	CPEN208	\N
55	22315830	CPEN212	\N
56	22388189	CPEN214	\N
57	22388189	CPEN204	\N
58	22388189	CPEN206	\N
59	22388189	CPEN208	\N
60	22388189	CPEN212	\N
61	22393520	CPEN214	\N
62	22393520	CPEN204	\N
63	22393520	CPEN206	\N
64	22393520	CPEN208	\N
65	22393520	CPEN212	\N
66	22312110	CPEN214	\N
67	22312110	CPEN204	\N
68	22312110	CPEN206	\N
69	22312110	CPEN208	\N
70	22312110	CPEN212	\N
71	22300896	CPEN214	\N
72	22300896	CPEN204	\N
73	22300896	CPEN206	\N
74	22300896	CPEN208	\N
75	22300896	CPEN212	\N
76	22397491	CPEN214	\N
77	22397491	CPEN204	\N
78	22397491	CPEN206	\N
79	22397491	CPEN208	\N
80	22397491	CPEN212	\N
81	22387715	CPEN214	\N
82	22387715	CPEN204	\N
83	22387715	CPEN206	\N
84	22387715	CPEN208	\N
85	22387715	CPEN212	\N
86	22382302	CPEN214	\N
87	22382302	CPEN204	\N
88	22382302	CPEN206	\N
89	22382302	CPEN208	\N
90	22382302	CPEN212	\N
91	22379061	CPEN214	\N
92	22379061	CPEN204	\N
93	22379061	CPEN206	\N
94	22379061	CPEN208	\N
95	22379061	CPEN212	\N
96	22368809	CPEN214	\N
97	22368809	CPEN204	\N
98	22368809	CPEN206	\N
99	22368809	CPEN208	\N
100	22368809	CPEN212	\N
101	22370498	CPEN214	\N
102	22370498	CPEN204	\N
103	22370498	CPEN206	\N
104	22370498	CPEN208	\N
105	22370498	CPEN212	\N
106	22382425	CPEN214	\N
107	22382425	CPEN204	\N
108	22382425	CPEN206	\N
109	22382425	CPEN208	\N
110	22382425	CPEN212	\N
111	22396551	CPEN214	\N
112	22396551	CPEN204	\N
113	22396551	CPEN206	\N
114	22396551	CPEN208	\N
115	22396551	CPEN212	\N
116	22398562	CPEN214	\N
117	22398562	CPEN204	\N
118	22398562	CPEN206	\N
119	22398562	CPEN208	\N
120	22398562	CPEN212	\N
121	22398596	CPEN214	\N
122	22398596	CPEN204	\N
123	22398596	CPEN206	\N
124	22398596	CPEN208	\N
125	22398596	CPEN212	\N
126	22385323	CPEN214	\N
127	22385323	CPEN204	\N
128	22385323	CPEN206	\N
129	22385323	CPEN208	\N
130	22385323	CPEN212	\N
131	22407033	CPEN214	\N
132	22407033	CPEN204	\N
133	22407033	CPEN206	\N
134	22407033	CPEN208	\N
135	22407033	CPEN212	\N
136	22299189	CPEN214	\N
137	22299189	CPEN204	\N
138	22299189	CPEN206	\N
139	22299189	CPEN208	\N
140	22299189	CPEN212	\N
141	22407837	CPEN214	\N
142	22407837	CPEN204	\N
143	22407837	CPEN206	\N
144	22407837	CPEN208	\N
145	22407837	CPEN212	\N
146	22412615	CPEN214	\N
147	22412615	CPEN204	\N
148	22412615	CPEN206	\N
149	22412615	CPEN208	\N
150	22412615	CPEN212	\N
151	22411009	CPEN214	\N
152	22411009	CPEN204	\N
153	22411009	CPEN206	\N
154	22411009	CPEN208	\N
155	22411009	CPEN212	\N
156	22382547	CPEN214	\N
157	22382547	CPEN204	\N
158	22382547	CPEN206	\N
159	22382547	CPEN208	\N
160	22382547	CPEN212	\N
161	22373317	CPEN214	\N
162	22373317	CPEN204	\N
163	22373317	CPEN206	\N
164	22373317	CPEN208	\N
165	22373317	CPEN212	\N
166	22339058	CPEN214	\N
167	22339058	CPEN204	\N
168	22339058	CPEN206	\N
169	22339058	CPEN208	\N
170	22339058	CPEN212	\N
171	22302628	CPEN214	\N
172	22302628	CPEN204	\N
173	22302628	CPEN206	\N
174	22302628	CPEN208	\N
175	22302628	CPEN212	\N
176	22396566	CPEN214	\N
177	22396566	CPEN204	\N
178	22396566	CPEN206	\N
179	22396566	CPEN208	\N
180	22396566	CPEN212	\N
181	22325819	CPEN214	\N
182	22325819	CPEN204	\N
183	22325819	CPEN206	\N
184	22325819	CPEN208	\N
185	22325819	CPEN212	\N
186	22344703	CPEN214	\N
187	22344703	CPEN204	\N
188	22344703	CPEN206	\N
189	22344703	CPEN208	\N
190	22344703	CPEN212	\N
191	22306910	CPEN214	\N
192	22306910	CPEN204	\N
193	22306910	CPEN206	\N
194	22306910	CPEN208	\N
195	22306910	CPEN212	\N
196	22385472	CPEN214	\N
197	22385472	CPEN204	\N
198	22385472	CPEN206	\N
199	22385472	CPEN208	\N
200	22385472	CPEN212	\N
201	22399214	CPEN214	\N
202	22399214	CPEN204	\N
203	22399214	CPEN206	\N
204	22399214	CPEN208	\N
205	22399214	CPEN212	\N
206	22263126	CPEN214	\N
207	22263126	CPEN204	\N
208	22263126	CPEN206	\N
209	22263126	CPEN208	\N
210	22263126	CPEN212	\N
211	22373463	CPEN214	\N
212	22373463	CPEN204	\N
213	22373463	CPEN206	\N
214	22373463	CPEN208	\N
215	22373463	CPEN212	\N
216	22381702	CPEN214	\N
217	22381702	CPEN204	\N
218	22381702	CPEN206	\N
219	22381702	CPEN208	\N
220	22381702	CPEN212	\N
221	22387846	CPEN214	\N
222	22387846	CPEN204	\N
223	22387846	CPEN206	\N
224	22387846	CPEN208	\N
225	22387846	CPEN212	\N
226	22263922	CPEN214	\N
227	22263922	CPEN204	\N
228	22263922	CPEN206	\N
229	22263922	CPEN208	\N
230	22263922	CPEN212	\N
231	22401641	CPEN214	\N
232	22401641	CPEN204	\N
233	22401641	CPEN206	\N
234	22401641	CPEN208	\N
235	22401641	CPEN212	\N
236	22403781	CPEN214	\N
237	22403781	CPEN204	\N
238	22403781	CPEN206	\N
239	22403781	CPEN208	\N
240	22403781	CPEN212	\N
241	22304260	CPEN214	\N
242	22304260	CPEN204	\N
243	22304260	CPEN206	\N
244	22304260	CPEN208	\N
245	22304260	CPEN212	\N
246	22304013	CPEN214	\N
247	22304013	CPEN204	\N
248	22304013	CPEN206	\N
249	22304013	CPEN208	\N
250	22304013	CPEN212	\N
251	22302188	CPEN214	\N
252	22302188	CPEN204	\N
253	22302188	CPEN206	\N
254	22302188	CPEN208	\N
255	22302188	CPEN212	\N
256	22299949	CPEN214	\N
257	22299949	CPEN204	\N
258	22299949	CPEN206	\N
259	22299949	CPEN208	\N
260	22299949	CPEN212	\N
261	22415339	CPEN214	\N
262	22415339	CPEN204	\N
263	22415339	CPEN206	\N
264	22415339	CPEN208	\N
265	22415339	CPEN212	\N
266	22328334	CPEN214	\N
267	22328334	CPEN204	\N
268	22328334	CPEN206	\N
269	22328334	CPEN208	\N
270	22328334	CPEN212	\N
271	22412982	CPEN214	\N
272	22412982	CPEN204	\N
273	22412982	CPEN206	\N
274	22412982	CPEN208	\N
275	22412982	CPEN212	\N
276	22321110	CPEN214	\N
277	22321110	CPEN204	\N
278	22321110	CPEN206	\N
279	22321110	CPEN208	\N
280	22321110	CPEN212	\N
281	22306021	CPEN214	\N
282	22306021	CPEN204	\N
283	22306021	CPEN206	\N
284	22306021	CPEN208	\N
285	22306021	CPEN212	\N
286	22385391	CPEN214	\N
287	22385391	CPEN204	\N
288	22385391	CPEN206	\N
289	22385391	CPEN208	\N
290	22385391	CPEN212	\N
291	22394866	CPEN214	\N
292	22394866	CPEN204	\N
293	22394866	CPEN206	\N
294	22394866	CPEN208	\N
295	22394866	CPEN212	\N
296	22382601	CPEN214	\N
297	22382601	CPEN204	\N
298	22382601	CPEN206	\N
299	22382601	CPEN208	\N
300	22382601	CPEN212	\N
301	22271867	CPEN214	\N
302	22271867	CPEN204	\N
303	22271867	CPEN206	\N
304	22271867	CPEN208	\N
305	22271867	CPEN212	\N
306	22401818	CPEN214	\N
307	22401818	CPEN204	\N
308	22401818	CPEN206	\N
309	22401818	CPEN208	\N
310	22401818	CPEN212	\N
311	22407018	CPEN214	\N
312	22407018	CPEN204	\N
313	22407018	CPEN206	\N
314	22407018	CPEN208	\N
315	22407018	CPEN212	\N
316	22376708	CPEN214	\N
317	22376708	CPEN204	\N
318	22376708	CPEN206	\N
319	22376708	CPEN208	\N
320	22376708	CPEN212	\N
321	22377537	CPEN214	\N
322	22377537	CPEN204	\N
323	22377537	CPEN206	\N
324	22377537	CPEN208	\N
325	22377537	CPEN212	\N
326	22400543	CPEN214	\N
327	22400543	CPEN204	\N
328	22400543	CPEN206	\N
329	22400543	CPEN208	\N
330	22400543	CPEN212	\N
331	22402666	CPEN214	\N
332	22402666	CPEN204	\N
333	22402666	CPEN206	\N
334	22402666	CPEN208	\N
335	22402666	CPEN212	\N
336	22416112	CPEN214	\N
337	22416112	CPEN204	\N
338	22416112	CPEN206	\N
339	22416112	CPEN208	\N
340	22416112	CPEN212	\N
341	22395074	CPEN214	\N
342	22395074	CPEN204	\N
343	22395074	CPEN206	\N
344	22395074	CPEN208	\N
345	22395074	CPEN212	\N
\.


--
-- Data for Name: lecturer_course; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lecturer_course (lecturer_id, course_id) FROM stdin;
LEC00006	CPEN103
LEC00009	CPEN104
LEC00007	CPEN201
LEC00009	CPEN203
LEC00005	CPEN213
LEC00008	CPEN211
LEC00004	CPEN204
LEC00003	CPEN206
LEC00006	CPEN212
LEC00008	CPEN208
LEC00003	CPEN301
LEC00006	CPEN305
LEC00004	CPEN307
LEC00001	CPEN214
LEC00002	CPEN311
LEC00003	CPEN313
LEC00004	CPEN315
LEC00005	CPEN304
LEC00006	CPEN314
LEC00007	CPEN316
LEC00008	CPEN318
LEC00009	CPEN322
LEC00001	CPEN324
LEC00002	CPEN400
LEC00003	CPEN401
LEC00004	CPEN403
LEC00005	CPEN419
LEC00006	CPEN429
LEC00007	CPEN409
LEC00008	CPEN411
LEC00009	CPEN415
LEC00001	CPEN421
LEC00002	CPEN423
LEC00003	CPEN425
LEC00004	CPEN427
LEC00005	CPEN406
LEC00006	CPEN424
LEC00007	CPEN426
LEC00008	CPEN444
LEC00009	CPEN408
LEC00001	CPEN422
LEC00002	CPEN432
LEC00003	CPEN434
LEC00004	CPEN442
\.


--
-- Data for Name: lecturer_ta; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lecturer_ta (lecturer_id, ta_id) FROM stdin;
LEC00003	TA000001
LEC00004	TA000001
LEC00009	TA000002
LEC00008	TA000002
LEC00007	TA000003
LEC00002	TA000003
LEC00001	TA000004
LEC00006	TA000004
\.


--
-- Data for Name: lecturers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lecturers (lecturer_id, first_name, last_name) FROM stdin;
LEC00001	Nii	Longdon Sowah
LEC00002	Robert	Sowah
LEC00003	Godfrey	Mills
LEC00004	Gifty	Osei
LEC00005	Percy	Okae
LEC00006	Isaac	Adjaye Aboagye
LEC00007	Margaret	Richardson
LEC00008	John	Assiamah
LEC00009	Prosper	Afriye
\.


--
-- Data for Name: student_fees; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.student_fees (payment_id, student_id, amount, date_of_payment) FROM stdin;
1	22384451	8879.00	2026-01-15
2	22357814	3200.00	2026-01-18
3	22375367	6450.00	2026-02-02
4	22397756	8879.00	2026-01-12
5	22369321	2100.00	2026-01-25
6	22301848	5000.00	2026-01-20
7	22339520	7300.00	2026-02-10
8	22333597	1500.00	2026-01-30
9	22268986	8879.00	2026-01-14
10	22381577	4200.00	2026-02-05
11	22315830	6000.00	2026-01-22
12	22388189	8879.00	2026-01-16
13	22393520	2900.00	2026-02-08
14	22312110	8879.00	2026-01-10
15	22300896	3600.00	2026-01-28
16	22397491	5500.00	2026-02-01
17	22387715	8879.00	2026-01-13
18	22382302	1200.00	2026-02-12
19	22379061	4700.00	2026-01-19
20	22368809	8879.00	2026-01-11
21	22370498	6900.00	2026-02-03
22	22382425	3400.00	2026-01-27
23	22396551	8879.00	2026-01-17
24	22398562	5800.00	2026-02-06
25	22398596	2200.00	2026-01-24
26	22385323	8879.00	2026-01-09
27	22407033	8879.00	2026-01-21
28	22299189	6100.00	2026-02-11
29	22407837	3900.00	2026-01-26
30	22412615	8879.00	2026-01-08
31	22411009	2700.00	2026-02-04
32	22382547	7100.00	2026-01-23
33	22373317	8879.00	2026-01-31
34	22339058	1900.00	2026-02-07
35	22302628	8879.00	2026-01-07
36	22396566	5300.00	2026-01-29
37	22325819	8879.00	2026-02-13
38	22344703	3100.00	2026-01-06
39	22306910	6700.00	2026-02-14
40	22385472	8879.00	2026-01-15
41	22399214	2500.00	2026-01-05
42	22263126	8879.00	2026-02-15
43	22373463	4900.00	2026-01-04
44	22381702	8879.00	2026-02-16
45	22387846	3300.00	2026-01-03
46	22263922	7600.00	2026-02-17
47	22401641	8879.00	2026-01-02
48	22403781	2000.00	2026-02-18
49	22304260	8879.00	2026-01-01
50	22304013	5900.00	2026-02-19
51	22302188	8879.00	2026-02-20
52	22299949	1700.00	2026-01-24
53	22415339	8879.00	2026-02-21
54	22328334	6300.00	2026-01-25
55	22412982	8879.00	2026-02-22
56	22321110	4100.00	2026-01-26
57	22306021	8879.00	2026-02-23
58	22385391	3700.00	2026-01-27
59	22394866	8879.00	2026-02-24
60	22382601	2400.00	2026-01-28
61	22271867	8879.00	2026-02-25
62	22401818	5100.00	2026-01-29
63	22407018	8879.00	2026-02-26
64	22376708	3800.00	2026-01-30
65	22377537	8879.00	2026-02-27
66	22400543	6600.00	2026-01-31
67	22402666	8879.00	2026-02-28
68	22416112	2800.00	2026-02-01
69	22395074	8879.00	2026-03-01
\.


--
-- Data for Name: student_info; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.student_info (student_id, first_name, last_name, date_of_birth, total_fee_due) FROM stdin;
22384451	Golda	Abu Neaquittae	2006-03-14	8879.00
22357814	Stephen Yaw	Adzasa	2005-07-22	8879.00
22375367	Afia Beaa	Osei-Safo	2007-01-09	8879.00
22397756	Ryan	Agbemavi	2006-11-30	8879.00
22369321	Nathaniel	Agormeda Tetteh	2005-04-18	8879.00
22301848	Mohammed	Ahmad Sahih Kayelgu	2006-09-05	8879.00
22339520	Amprofi Yaa	Obeng	2007-02-27	8879.00
22333597	Esme Lilian	Asante	2006-06-12	8879.00
22268986	Gabriel Kwaku	Asante	2005-12-03	8879.00
22381577	Daniel	Botchway	2006-08-19	8879.00
22315830	Brian	Assibey-Yeboah	2007-05-08	8879.00
22388189	Caleb	Mensah	2005-10-25	8879.00
22393520	Cyril	Desmond Ofori	2006-01-16	8879.00
22312110	David Kwame	Odoi-Anim	2007-03-29	8879.00
22300896	Collins Kweku	Doe	2006-07-02	8879.00
22397491	Douglas	Kwaw Adjei	2005-11-14	8879.00
22387715	Dzidzor	Apu Apawudza	2006-04-21	8879.00
22382302	Edward	Kakra Ankrah	2007-09-10	8879.00
22379061	Emmanuel	Akotuah Osae	2006-02-06	8879.00
22368809	Emmanuel	Dery	2005-06-28	8879.00
22370498	Ethan Edric Kweku	Nartey	2007-08-17	8879.00
22382425	Gilbert Akwasi Sarkodie	Yeboah	2006-12-09	8879.00
22396551	Jerrold	Xornam Kyekye	2005-03-23	8879.00
22398562	Joseph	Amankwah	2006-10-11	8879.00
22398596	Joshua	Appiah	2007-04-04	8879.00
22385323	Jude	Gyampoh Addo	2005-09-19	8879.00
22407033	Kenzi	Segbefia	2007-01-31	8879.00
22299189	David	Kessey Ntiako	2006-07-15	8879.00
22407837	Kingsley	Caldicock Quartey	2005-02-08	8879.00
22412615	Kofi	Boateng Oware-Tano	2006-11-02	8879.00
22411009	Kwaku	Aninkorah Barimah	2007-06-24	8879.00
22382547	Kwame	Ayeh Obeng	2005-08-13	8879.00
22373317	Kwamena	Kesse Quaicoe	2006-03-27	8879.00
22339058	Maame	Abena Amihere Ahu	2007-10-06	8879.00
22302628	Maame	Araba Grant-Aidoo	2005-05-17	8879.00
22396566	Manford Kelvin	 Oppong	2006-09-22	8879.00
22325819	Nana Adwoa	Dansowaah Odoom	2007-02-14	8879.00
22344703	Nana Anokye	Twum	2005-12-29	8879.00
22306910	Newlove	Yeboaah Kwarfo	2006-06-08	8879.00
22385472	Ernest	Obeng Antwi	2007-07-20	8879.00
22399214	Ruth	Obeng	2005-01-11	8879.00
22263126	Yaw	Owusu Koranteng Poku	2006-04-03	8879.00
22373463	Nana Boadiwaa	Owusu	2007-11-25	8879.00
22381702	Paula	Akosua Asiedua Frimpong	2005-07-07	8879.00
22387846	Emile	Quaicoo	2006-02-19	8879.00
22263922	Romel	Alvin Nii Lartey Lartey	2007-09-01	8879.00
22401641	Sandra	Naa Adaku Mettle	2005-10-16	8879.00
22403781	Kofi	Bempong Sekyere	2006-12-30	8879.00
22304260	Christian Edward Nii Mantey	Tetteh	2007-03-12	8879.00
22304013	Sonnu	Tietaah	2005-06-05	8879.00
22302188	Van Jerry	Quansah	2006-08-28	8879.00
22299949	William	Enchill	2007-01-23	8879.00
22415339	Kelvin	Kwesi Saah	2005-04-09	8879.00
22328334	Etsey Hannah	 Seyram	2006-10-31	8879.00
22412982	Mini	Adu	2007-05-15	8879.00
22321110	Gideon	Nana Osei Amofa	2005-11-06	8879.00
22306021	Paul Badu	 Amponsah	2006-01-27	8879.00
22385391	Abdul-Majeed Najiib	Stephen	2007-08-04	8879.00
22394866	Joshua Kwame	Asirifi	2005-05-21	8879.00
22382601	Juliet	Eklou	2006-09-13	8879.00
22271867	De-Andra Rebecca	Ayebo	2007-12-02	8879.00
22401818	Mas'ud	Nasir	2005-03-08	8879.00
22407018	Daniel	Dwomoh Frimpong	2006-07-24	8879.00
22376708	Priscilla	Adjei	2007-02-17	8879.00
22377537	Reuben	Adomako	2005-09-29	8879.00
22400543	Frederick	Ocansey	2006-06-11	8879.00
22402666	Darlington	Dogbatse	2007-10-23	8879.00
22416112	Troy	Thomas	2005-01-05	8879.00
22395074	Lydia	Tiwaah	2006-04-16	8879.00
\.


--
-- Data for Name: teaching_assistant; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.teaching_assistant (ta_id, first_name, last_name) FROM stdin;
TA000001	Nathaniel	Adika
TA000002	Larry	Wurapa
TA000003	Raphael	Kuayi
TA000004	Kwesi Adinkrah	Asamoah
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (user_id, student_id, email, password_hash) FROM stdin;
1	22268986	student22268986@example.com	$2b$10$uKNnC6/38BgfL1QkOxZLquToAPWqqRfPjdgIT.j0P0r8IznXL0hBm
\.


--
-- Name: enrollment_enrollment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.enrollment_enrollment_id_seq', 345, true);


--
-- Name: student_fees_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.student_fees_payment_id_seq', 69, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_user_id_seq', 1, true);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (course_id);


--
-- Name: enrollment enrollment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT enrollment_pkey PRIMARY KEY (enrollment_id);


--
-- Name: lecturer_course lecturer_course_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lecturer_course
    ADD CONSTRAINT lecturer_course_pkey PRIMARY KEY (lecturer_id, course_id);


--
-- Name: lecturer_ta lecturer_ta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lecturer_ta
    ADD CONSTRAINT lecturer_ta_pkey PRIMARY KEY (lecturer_id, ta_id);


--
-- Name: lecturers lecturers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lecturers
    ADD CONSTRAINT lecturers_pkey PRIMARY KEY (lecturer_id);


--
-- Name: student_fees student_fees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_fees
    ADD CONSTRAINT student_fees_pkey PRIMARY KEY (payment_id);


--
-- Name: student_info student_info_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_info
    ADD CONSTRAINT student_info_pkey PRIMARY KEY (student_id);


--
-- Name: teaching_assistant teaching_assistant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teaching_assistant
    ADD CONSTRAINT teaching_assistant_pkey PRIMARY KEY (ta_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: enrollment fk_course_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT fk_course_id FOREIGN KEY (course_id) REFERENCES public.courses(course_id);


--
-- Name: lecturer_course fk_course_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lecturer_course
    ADD CONSTRAINT fk_course_id FOREIGN KEY (course_id) REFERENCES public.courses(course_id);


--
-- Name: student_fees fk_fees_student; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_fees
    ADD CONSTRAINT fk_fees_student FOREIGN KEY (student_id) REFERENCES public.student_info(student_id);


--
-- Name: lecturer_course fk_lec_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lecturer_course
    ADD CONSTRAINT fk_lec_id FOREIGN KEY (lecturer_id) REFERENCES public.lecturers(lecturer_id);


--
-- Name: lecturer_ta fk_lec_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lecturer_ta
    ADD CONSTRAINT fk_lec_id FOREIGN KEY (lecturer_id) REFERENCES public.lecturers(lecturer_id);


--
-- Name: enrollment fk_std_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT fk_std_id FOREIGN KEY (student_id) REFERENCES public.student_info(student_id);


--
-- Name: lecturer_ta fk_ta_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lecturer_ta
    ADD CONSTRAINT fk_ta_id FOREIGN KEY (ta_id) REFERENCES public.teaching_assistant(ta_id);


--
-- Name: users users_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.student_info(student_id);


--
-- PostgreSQL database dump complete
--


