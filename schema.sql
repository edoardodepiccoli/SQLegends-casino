-- public.giocatore definition
-- Drop table
-- DROP TABLE public.giocatore;
CREATE TABLE public.giocatore (
  codice_fiscale varchar NOT NULL,
  nome varchar NOT NULL,
  cognome varchar NOT NULL,
  data_nascita varchar NOT NULL,
  vincite_totali int4 NULL,
  CONSTRAINT giocatore_pk PRIMARY KEY (codice_fiscale)
);
CREATE UNIQUE INDEX giocatore_codice_fiscale_idx ON public.giocatore USING btree (codice_fiscale);
-- public.gioco definition
-- Drop table
-- DROP TABLE public.gioco;
CREATE TABLE public.gioco (
  id int4 NOT NULL,
  nome varchar NULL,
  CONSTRAINT gioco_pk PRIMARY KEY (id)
);
-- public.sala definition
-- Drop table
-- DROP TABLE public.sala;
CREATE TABLE public.sala (
  nome_sala varchar NOT NULL,
  livello varchar NULL,
  CONSTRAINT sala_pk PRIMARY KEY (nome_sala)
);
-- public.sessione definition
-- Drop table
-- DROP TABLE public.sessione;
CREATE TABLE public.sessione (
  timestamp_inizio timestamp NOT NULL,
  CONSTRAINT sessione_pk PRIMARY KEY (timestamp_inizio)
);
-- public.dealer definition
-- Drop table
-- DROP TABLE public.dealer;
CREATE TABLE public.dealer (
  codice_fiscale varchar NOT NULL,
  nome varchar NULL,
  cognome varchar NULL,
  data_nascita varchar NULL,
  anni_esperienza int4 NULL,
  gioco int4 NULL,
  sala varchar NULL,
  CONSTRAINT dealer_pk PRIMARY KEY (codice_fiscale),
  CONSTRAINT dealer_unique UNIQUE (gioco),
  CONSTRAINT dealer_gioco_fk FOREIGN KEY (gioco) REFERENCES public.gioco(id),
  CONSTRAINT dealer_sala_fk FOREIGN KEY (sala) REFERENCES public.sala(nome_sala)
);
-- public.giocatore_sessione definition
-- Drop table
-- DROP TABLE public.giocatore_sessione;
CREATE TABLE public.giocatore_sessione (
  giocatore varchar NOT NULL,
  sessione timestamp NOT NULL,
  CONSTRAINT giocatore_sessione_pk PRIMARY KEY (giocatore, sessione),
  CONSTRAINT giocatore_sessione_giocatore_fk_1 FOREIGN KEY (giocatore) REFERENCES public.giocatore(codice_fiscale),
  CONSTRAINT giocatore_sessione_sessione_fk FOREIGN KEY (sessione) REFERENCES public.sessione(timestamp_inizio)
);
-- public.partita definition
-- Drop table
-- DROP TABLE public.partita;
CREATE TABLE public.partita (
  timestamp_inizio timestamp NOT NULL,
  durata_minuti int4 NULL,
  gioco int4 NULL,
  CONSTRAINT partita_pk PRIMARY KEY (timestamp_inizio),
  CONSTRAINT partita_gioco_fk FOREIGN KEY (gioco) REFERENCES public.gioco(id)
);
-- public.transazione definition
-- Drop table
-- DROP TABLE public.transazione;
CREATE TABLE public.transazione (
  "timestamp" timestamp NOT NULL,
  quantita int4 NULL,
  giocatore varchar NOT NULL,
  transazione timestamp NULL,
  CONSTRAINT transazione_pk PRIMARY KEY (giocatore, "timestamp"),
  CONSTRAINT transazione_giocatore_fk FOREIGN KEY (giocatore) REFERENCES public.giocatore(codice_fiscale),
  CONSTRAINT transazione_partita_fk FOREIGN KEY ("timestamp") REFERENCES public.partita(timestamp_inizio)
);