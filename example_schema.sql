-- =============================
-- File: schema.sql
-- Progetto: Casino e Clienti
-- Database: PostgreSQL
-- =============================

-- =============================
-- TABELLE
-- =============================

CREATE TABLE agenzia (
    codice SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    anno_fondazione INT,
    sede_principale VARCHAR(100) NOT NULL
);

CREATE TABLE casino (
    codice SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    paese VARCHAR(100) NOT NULL,
    citta VARCHAR(100) NOT NULL,
    n_dipendenti INT,
    data_apertura DATE NOT NULL,
    agenzia INT NOT NULL,
    FOREIGN KEY (agenzia) REFERENCES agenzia(codice)
);

CREATE TABLE casino_pubblico (
    casino INT PRIMARY KEY,
    percentuale_stato DECIMAL(5,2) NOT NULL,
    ente_regolatore VARCHAR(100) NOT NULL,
    FOREIGN KEY (casino) REFERENCES casino(codice)
);

CREATE TABLE autorita_regolamentazione (
    codice VARCHAR(16) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    paese VARCHAR(100) NOT NULL,
    data_istituzione DATE NOT NULL
);

CREATE TABLE regolamentazione (
    casino_pubblico INT,
    autorita_codice VARCHAR(16),
    data_inizio DATE NOT NULL,
    PRIMARY KEY (casino_pubblico, autorita_codice),
    FOREIGN KEY (casino_pubblico) REFERENCES casino_pubblico(casino),
    FOREIGN KEY (autorita_codice) REFERENCES autorita_regolamentazione(codice)
);

CREATE TABLE casino_privato (
    casino INT PRIMARY KEY,
    gruppo_proprietario VARCHAR(100) NOT NULL,
    valore_stimato DECIMAL(15,2),
    FOREIGN KEY (casino) REFERENCES casino(codice)
);

CREATE TABLE persona (
    cf VARCHAR(16) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cognome VARCHAR(100) NOT NULL,
    data_nascita DATE NOT NULL,
    nazionalita VARCHAR(100) NOT NULL
);

CREATE TABLE dirigente (
    persona_cf VARCHAR(16),
    casino_privato INT,
    ruolo VARCHAR(100) NOT NULL,
    data_inizio DATE NOT NULL,
    PRIMARY KEY (persona_cf, casino_privato),
    FOREIGN KEY (persona_cf) REFERENCES persona(cf),
    FOREIGN KEY (casino_privato) REFERENCES casino_privato(casino)
);

CREATE TABLE regolatore (
    persona_cf VARCHAR(16),
    autorita_codice VARCHAR(16),
    data_inizio DATE NOT NULL,
    PRIMARY KEY (persona_cf, autorita_codice),
    FOREIGN KEY (persona_cf) REFERENCES persona(cf),
    FOREIGN KEY (autorita_codice) REFERENCES autorita_regolamentazione(codice)
);

CREATE TABLE area_gioco (
    casino INT,
    codice INT,
    nome VARCHAR(100) NOT NULL,
    dimensione INT NOT NULL,
    n_tavoli INT NOT NULL,
    capacita_max INT NOT NULL,
    PRIMARY KEY (casino, codice),
    FOREIGN KEY (casino) REFERENCES casino(codice)
);

CREATE TABLE area_vip (
    casino INT,
    area INT,
    soglia_ingresso DECIMAL(15,2) NOT NULL,
    n_tavoli_privati INT NOT NULL,
    PRIMARY KEY (casino, area),
    FOREIGN KEY (casino, area) REFERENCES area_gioco(casino, codice)
);

CREATE TABLE cliente (
    tessera VARCHAR(16) PRIMARY KEY,
    persona_cf VARCHAR(16) NOT NULL,
    data_registrazione DATE NOT NULL,
    livello_fidelizzazione INT DEFAULT 1,
    FOREIGN KEY (persona_cf) REFERENCES persona(cf)
);

CREATE TABLE visita (
    cliente VARCHAR(16),
    data_visita DATE,
    orario_ingresso TIME NOT NULL,
    orario_uscita TIME,
    casino INT NOT NULL,
    importo_speso DECIMAL(15,2),
    PRIMARY KEY (cliente, data_visita),
    FOREIGN KEY (cliente) REFERENCES cliente(tessera),
    FOREIGN KEY (casino) REFERENCES casino(codice)
);

CREATE TABLE sessione_gioco (
    cliente VARCHAR(16),
    data_sessione DATE,
    ora_inizio TIME NOT NULL,
    ora_fine TIME,
    casino INT NOT NULL,
    area INT NOT NULL,
    importo_iniziale DECIMAL(15,2) NOT NULL,
    importo_finale DECIMAL(15,2),
    PRIMARY KEY (cliente, data_sessione, ora_inizio),
    FOREIGN KEY (cliente) REFERENCES cliente(tessera),
    FOREIGN KEY (casino, area) REFERENCES area_gioco(casino, codice),
    FOREIGN KEY (cliente, data_sessione) REFERENCES visita(cliente, data_visita)
);

CREATE TABLE sessione_vip (
    cliente VARCHAR(16),
    data_sessione DATE,
    ora_inizio TIME,
    servizio_esclusivo BOOLEAN NOT NULL,
    prenotazione_anticipata BOOLEAN NOT NULL,
    host_personale VARCHAR(16),
    PRIMARY KEY (cliente, data_sessione, ora_inizio),
    FOREIGN KEY (cliente, data_sessione, ora_inizio) REFERENCES sessione_gioco(cliente, data_sessione, ora_inizio),
    FOREIGN KEY (host_personale) REFERENCES persona(cf)
);

CREATE TABLE gioco (
    codice SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    rtp DECIMAL(5,2)
);

CREATE TABLE disponibilita_gioco (
    gioco INT,
    casino INT,
    area INT,
    numero_tavoli INT NOT NULL,
    PRIMARY KEY (gioco, casino, area),
    FOREIGN KEY (gioco) REFERENCES gioco(codice),
    FOREIGN KEY (casino, area) REFERENCES area_gioco(casino, codice)
);

CREATE TABLE torneo (
    codice SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    data_inizio DATE NOT NULL,
    data_fine DATE NOT NULL,
    casino INT NOT NULL,
    area INT NOT NULL,
    gioco INT NOT NULL,
    buy_in DECIMAL(15,2) NOT NULL,
    montepremi DECIMAL(15,2) NOT NULL,
    numero_partecipanti INT,
    FOREIGN KEY (casino, area) REFERENCES area_gioco(casino, codice),
    FOREIGN KEY (gioco) REFERENCES gioco(codice)
);

CREATE TABLE partecipazione_torneo (
    cliente VARCHAR(16),
    torneo INT,
    posizione_finale INT,
    premio_vinto DECIMAL(15,2),
    PRIMARY KEY (cliente, torneo),
    FOREIGN KEY (cliente) REFERENCES cliente(tessera),
    FOREIGN KEY (torneo) REFERENCES torneo(codice)
);

-- =============================
-- INDICI
-- =============================

CREATE INDEX idx_visita_data ON visita(data_visita);
CREATE INDEX idx_casino_paese ON casino(paese);
CREATE INDEX idx_area_gioco_casino ON area_gioco(casino);
CREATE INDEX idx_area_gioco_tavoli ON area_gioco(n_tavoli);
CREATE INDEX idx_partecipazione_torneo_cliente ON partecipazione_torneo(cliente);

-- =============================
-- QUERY
-- =============================

-- Numero aree gioco per casino
SELECT c.nome AS nome_casino, COUNT(ag.codice) AS numero_aree
FROM casino c
JOIN area_gioco ag ON c.codice = ag.casino
GROUP BY c.codice, c.nome
ORDER BY numero_aree DESC;

-- Clienti che hanno visitato dopo una certa data
SELECT p.nome, p.cognome, v.data_visita, c.paese
FROM visita v
JOIN cliente cl ON v.cliente = cl.tessera
JOIN persona p ON cl.persona_cf = p.cf
JOIN casino c ON v.casino = c.codice
WHERE v.data_visita > '2024-08-15'
ORDER BY v.data_visita DESC;

-- Buy-in medio per paese nei tornei
SELECT c.paese, ROUND(AVG(t.buy_in),2) AS media_buy_in
FROM casino c
JOIN torneo t ON c.codice = t.casino
GROUP BY c.paese
ORDER BY media_buy_in DESC;

-- Clienti che hanno partecipato a più di un torneo
SELECT p.nome, p.cognome, COUNT(pt.torneo) AS numero_tornei
FROM persona p
JOIN cliente cl ON p.cf = cl.persona_cf
JOIN partecipazione_torneo pt ON cl.tessera = pt.cliente
GROUP BY p.cf, p.nome, p.cognome
HAVING COUNT(pt.torneo) > 1
ORDER BY numero_tornei DESC, p.cognome, p.nome;

-- Paesi con media più alta di tavoli per area
SELECT c.paese, COUNT(ag.codice) AS numero_aree, SUM(ag.n_tavoli) AS totale_tavoli,
       ROUND(AVG(ag.n_tavoli),2) AS media_tavoli_per_area
FROM casino c
JOIN area_gioco ag ON c.codice = ag.casino
GROUP BY c.paese
ORDER BY media_tavoli_per_area DESC;
