package com.ieseljust.ad.healthys.infra;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Guarda la configuració JDBC, no una connexió oberta.
 * Cada crida a obrir() crea una sessió nova amb PostgreSQL.
 * Qui rep la Connection és responsable de tancar-la amb try-with-resources.
 */
public final class ConnexioBD {
    // final impedeix substituir la configuració després de construir l'objecte.
    private final String url;
    private final String usuari;
    private final String contrasenya;

    /** Permet proporcionar la configuració explícitament, sense llegir l'entorn. */
    public ConnexioBD(String url, String usuari, String contrasenya) {
        this.url = url;
        this.usuari = usuari;
        this.contrasenya = contrasenya;
    }

    /**
     * Mètode de fàbrica estàtic: construeix un objecte configurat des de l'entorn.
     * No llig cap fitxer .env ni variables_entorn i encara no contacta amb la BD.
     * Les variables s'han d'exportar abans d'executar Java (directament o amb source).
     */
    public static ConnexioBD desDeEntorn() {
        return new ConnexioBD(requireEnv("AD_DB_URL"),
                requireEnv("AD_DB_USER"), requireEnv("AD_DB_PASSWORD"));
    }

    /** Rebutja la configuració absent abans d'intentar obrir la connexió. */
    private static String requireEnv(String nom) {
        // getenv consulta les variables que el procés Java ha heretat del terminal.
        String valor = System.getenv(nom);
        if (valor == null || valor.isBlank()) {
            // Mostrem el nom de la variable, mai el contingut de la contrasenya.
            throw new IllegalArgumentException("Falta la variable d'entorn " + nom);
        }
        return valor;
    }

    /** Obri la connexió; una fallada de xarxa o autenticació es comunica amb SQLException. */
    public Connection obrir() throws SQLException {
        // pgJDBC es registra automàticament des del classpath: no cal Class.forName.
        // DriverManager tria el driver a partir del prefix jdbc:postgresql: de l'URL.
        return DriverManager.getConnection(url, usuari, contrasenya);
    }
}
