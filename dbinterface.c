#include <stdio.h>
#include <stdlib.h>
#include <libpq-fe.h>
//#include "/mnt/c/Program Files/PostgreSQL/17/include/libpq-fe.h"

void do_exit(PGconn *conn);
void printMenu();
void checkExecError(PGresult *res, PGconn *conn);


int main()
{
    PGconn *conn = PQconnectdb("dbname=casino_db user=wpacoman password=magobianco24 host=localhost port=5432"); //Connessione al database
    PGresult *res;
    printMenu();
    int choice;
    int numTuple;
    int numAttributi;
    
    // Controllo se la connessione è stata stabilita
    if (PQstatus(conn) != CONNECTION_OK) {
        fprintf(stderr, "Connection to database failed: %s", PQerrorMessage(conn));
        do_exit(conn);
    }

    while(1){ // Cambiato in loop infinito, uscita via case 0
        printf("Enter your choice: ");
        scanf("%d", &choice);
        while(getchar() != '\n'); // Pulizia del buffer di input

        switch(choice){
            case 0: // Esci dal programma
                printf("Esci dal programma.\n");
                do_exit(conn);
                break;
            case 1: // Numero totale di transazioni per ogni giocatore
                res = PQexec(conn, "SELECT g.codice_fiscale, g.nome || ' ' || g.cognome AS player_name, SUM(t.quantita) AS total_transactions FROM transazione t JOIN giocatore g ON t.giocatore = g.codice_fiscale GROUP BY g.codice_fiscale, player_name;");
                checkExecError(res, conn);
                numTuple = PQntuples(res);
                numAttributi = PQnfields(res);

                for(int i = 0; i < numAttributi; i++)
                {
                    fprintf(stdout, "%s\t\t", PQfname(res, i));
                }
                fprintf(stdout, "\n");

                for(int i = 0; i < numTuple; i++)
                {
                    for (int j = 0; j < numAttributi; j++)
                    {
                        fprintf(stdout, "%s\t\t", PQgetvalue(res, i, j));
                    }
                    fprintf(stdout, "\n");
                }
                PQclear(res);
                break;
            case 2: // Durata media per ogni tipo di gioco
                res = PQexec(conn, "SELECT gc.nome AS game_name, AVG(p.durata_minuti) AS avg_duration FROM partita p JOIN gioco gc ON p.gioco = gc.id GROUP BY gc.nome;");
                checkExecError(res, conn);
                numTuple = PQntuples(res);
                numAttributi = PQnfields(res);

                for(int i = 0; i < numAttributi; i++)
                {
                    fprintf(stdout, "%s\t\t", PQfname(res, i));
                }
                fprintf(stdout, "\n");

                for(int i = 0; i < numTuple; i++)
                {
                    for (int j = 0; j < numAttributi; j++)
                    {
                        fprintf(stdout, "%s\t\t", PQgetvalue(res, i, j));
                    }
                    fprintf(stdout, "\n");
                }
                PQclear(res);
                break;
            case 3: // Players con più di una sessione
                res = PQexec(conn, "SELECT gs.giocatore, COUNT(*) AS session_count FROM giocatore_sessione gs GROUP BY gs.giocatore HAVING COUNT(*) > 1;");
                checkExecError(res, conn);
                numTuple = PQntuples(res);
                numAttributi = PQnfields(res);

                for(int i = 0; i < numAttributi; i++)
                {
                    fprintf(stdout, "%s\t\t", PQfname(res, i));
                }
                fprintf(stdout, "\n");

                for(int i = 0; i < numTuple; i++)
                {
                    for (int j = 0; j < numAttributi; j++)
                    {
                        fprintf(stdout, "%s\t\t", PQgetvalue(res, i, j));
                    }
                    fprintf(stdout, "\n");
                }
                PQclear(res);
                break;
            case 4: // Dealers per ogni sala con esperienza
                res = PQexec(conn, "SELECT s.nome_sala, s.livello, COUNT(d.codice_fiscale) AS dealers_count, ROUND(AVG(d.anni_esperienza)) AS avg_experience FROM dealer d JOIN sala s ON d.sala = s.nome_sala GROUP BY s.nome_sala, s.livello;");
                checkExecError(res, conn);
                numTuple = PQntuples(res);
                numAttributi = PQnfields(res);

                // Stampa i headers con larghezza fissa
                fprintf(stdout, "%-15s %-10s %-15s %-15s\n", 
                    PQfname(res, 0), 
                    PQfname(res, 1), 
                    PQfname(res, 2), 
                    PQfname(res, 3));
                fprintf(stdout, "--------------------------------------------------------\n");

                //Stampa i dati con larghezza fissa per un output più leggibile
                for(int i = 0; i < numTuple; i++)
                {
                    fprintf(stdout, "%-15s %-10s %-15s %-15s\n",
                        PQgetvalue(res, i, 0),
                        PQgetvalue(res, i, 1),
                        PQgetvalue(res, i, 2),
                        PQgetvalue(res, i, 3));
                }
                PQclear(res);
                break;
            case 5: // High-stakes games (quantita > 1000) per sessione
                res = PQexec(conn, "SELECT s.timestamp_inizio, p.gioco, COUNT(t.*) AS high_stakes_transactions FROM transazione t JOIN partita p ON t.\"timestamp\" = p.timestamp_inizio JOIN sessione s ON t.transazione = s.timestamp_inizio WHERE t.quantita > 1000 GROUP BY s.timestamp_inizio, p.gioco;");
                checkExecError(res, conn);
                numTuple = PQntuples(res);
                numAttributi = PQnfields(res);

                for(int i = 0; i < numAttributi; i++)
                {
                    fprintf(stdout, "%s\t\t", PQfname(res, i));
                }
                fprintf(stdout, "\n");

                for(int i = 0; i < numTuple; i++)
                {
                    for (int j = 0; j < numAttributi; j++)
                    {
                        fprintf(stdout, "%s\t\t", PQgetvalue(res, i, j));
                    }
                    fprintf(stdout, "\n");
                }
                PQclear(res);
                break;
            case 6: // Get player's total transactions by codice_fiscale (Query Parametrica)
            {
                char codice_fiscale[20]; // Assumendo che la lunghezza massima di codice_fiscale sia 20
                printf("Enter player's Codice Fiscale: ");
                scanf("%19s", codice_fiscale); // Legge fino a 19 caratteri per lasciare spazio per il terminatore null
                while(getchar() != '\n'); // Pulizia del buffer di input

                const char *paramValues[1] = {codice_fiscale};
                int paramLengths[1] = {0}; // 0 per stringa terminata da null, -1 per formato binario
                int paramFormats[1] = {0}; // 0 per formato testo, 1 per formato binario

                // Prima dealloca la dichiarazione se esiste
                PGresult *dealloc_res = PQexec(conn, "DEALLOCATE get_player_transactions");
                PQclear(dealloc_res);

                PGresult *prep_res = PQprepare(conn, "get_player_transactions",
                                            "SELECT g.codice_fiscale, g.nome || ' ' || g.cognome AS player_name, SUM(t.quantita) AS total_transactions FROM transazione t JOIN giocatore g ON t.giocatore = g.codice_fiscale WHERE g.codice_fiscale = $1 GROUP BY g.codice_fiscale, player_name;",
                                            1,
                                            NULL);

                if (PQresultStatus(prep_res) != PGRES_COMMAND_OK) {
                    fprintf(stderr, "Prepare statement failed: %s", PQerrorMessage(conn));
                    PQclear(prep_res);
                    break;
                }
                PQclear(prep_res); 

                // Esegui la dichiarazione preparata
                res = PQexecPrepared(conn, "get_player_transactions",
                                     1,
                                     paramValues,
                                     paramLengths,
                                     paramFormats,
                                     0); 

                checkExecError(res, conn);
                numTuple = PQntuples(res);
                numAttributi = PQnfields(res);

                if (numTuple == 0) {
                    printf("No transactions found for player with Codice Fiscale: %s\n", codice_fiscale);
                } else {
                    for(int i = 0; i < numAttributi; i++)
                    {
                        fprintf(stdout, "%s\t\t", PQfname(res, i));
                    }
                    fprintf(stdout, "\n");

                    for(int i = 0; i < numTuple; i++)
                    {
                        for (int j = 0; j < numAttributi; j++)
                        {
                            fprintf(stdout, "%s\t\t", PQgetvalue(res, i, j));
                        }
                        fprintf(stdout, "\n");
                    }
                }
                PQclear(res);
                break;
            }
            case 7: // Trova le partite giocate da un dealer in un intervallo di date (Query Parametrica)
            {
                char codice_fiscale_dealer[20];
                char data_inizio_str[11]; // Formato YYYY-MM-DD + '\0'
                char data_fine_str[11];   // Formato YYYY-MM-DD + '\0'

                printf("Inserisci il Codice Fiscale del dealer: ");
                scanf("%19s", codice_fiscale_dealer);
                while(getchar() != '\n');

                printf("Inserisci la data di inizio (YYYY-MM-DD): ");
                scanf("%10s", data_inizio_str);
                while(getchar() != '\n');

                printf("Inserisci la data di fine (YYYY-MM-DD): ");
                scanf("%10s", data_fine_str);
                while(getchar() != '\n');

                const char *paramValues[3] = {codice_fiscale_dealer, data_inizio_str, data_fine_str};
                int paramLengths[3] = {0, 0, 0};
                int paramFormats[3] = {0, 0, 0};

                PGresult *dealloc_res_dealer_games = PQexec(conn, "DEALLOCATE get_dealer_games");
                PQclear(dealloc_res_dealer_games);

                PGresult *prep_res_dealer_games = PQprepare(conn, "get_dealer_games",
                                                          "SELECT d.nome || ' ' || d.cognome AS dealer_name, g.nome AS game_name, p.timestamp_inizio, p.durata_minuti FROM partita p JOIN gioco g ON p.gioco = g.id JOIN dealer d ON d.gioco = g.id WHERE d.codice_fiscale = $1 AND p.timestamp_inizio BETWEEN $2 AND $3 ORDER BY p.timestamp_inizio;",
                                                          3,    
                                                          NULL);

                if (PQresultStatus(prep_res_dealer_games) != PGRES_COMMAND_OK) {
                    fprintf(stderr, "Prepare statement failed for dealer games: %s", PQerrorMessage(conn));
                    PQclear(prep_res_dealer_games);
                    break;
                }
                PQclear(prep_res_dealer_games);

                res = PQexecPrepared(conn, "get_dealer_games",
                                    3,
                                    paramValues,
                                    paramLengths,
                                    paramFormats,
                                    0);

                checkExecError(res, conn);
                numTuple = PQntuples(res);
                numAttributi = PQnfields(res);

                if (numTuple == 0) {
                    printf("Nessuna partita trovata per il dealer con Codice Fiscale: %s nell'intervallo %s a %s\n", codice_fiscale_dealer, data_inizio_str, data_fine_str);
                } else {
                    for(int i = 0; i < numAttributi; i++) {
                        fprintf(stdout, "%s\t\t", PQfname(res, i));
                    }
                    fprintf(stdout, "\n");

                    for(int i = 0; i < numTuple; i++) {
                        for (int j = 0; j < numAttributi; j++) {
                            fprintf(stdout, "%s\t\t", PQgetvalue(res, i, j));
                        }
                        fprintf(stdout, "\n");
                    }
                }
                PQclear(res);
                break;
            }
            default:
                printf("Invalid choice. Please try again.\n");
                break;
        }
    }
    PQfinish(conn);
    return 0;
}

void do_exit(PGconn *conn)
{
    PQfinish(conn);
    exit(1);
}

void printMenu(){
    printf("Menu Database\n-----------------------------------\n\nSelezionare azione desiderata:\n");
    printf("0) Esci dal programma\n");
    printf("1) Trova il numero totale di transazioni per ogni giocatore\n");
    printf("2) Trova la durata media per ogni tipo di gioco\n");
    printf("3) Trova giocatori con più di una sessione\n");
    printf("4) Trova i dealer per ogni sala che hanno dell'esperienza.\n");
    printf("5) Trova gli High-stakes games (quantita > 1000) per sessione.\n");
    printf("6) Trova il numero totale di transazioni per un giocatore specifico (Query Parametrica).\n");
    printf("7) Trova le partite giocate da un dealer in un intervallo di date (Query Parametrica).\n");
    printf("\n-----------------------------------\n");
}

void checkExecError(PGresult *res, PGconn *conn){
    if(PQresultStatus(res) != PGRES_TUPLES_OK){
        fprintf(stderr, "SELECT failed: %s", PQerrorMessage(conn));
        PQclear(res);
        do_exit(conn);
    }
}