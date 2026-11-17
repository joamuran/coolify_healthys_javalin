package com.ieseljust.ad.healthys.service;

import com.ieseljust.ad.healthys.infra.ConnexioBD;
import java.sql.SQLException;

/** Salut del desplegament: comprova xarxa, autenticació, esquema i permís de lectura. */
public final class SalutService {
    private final ConnexioBD configuracio;
    public SalutService(ConnexioBD configuracio) { this.configuracio = configuracio; }
    public void comprovar() throws SQLException {
        try (var connexio = configuracio.obrir();
             var consulta = connexio.prepareStatement("SELECT count(*) FROM healthys.producte");
             var resultat = consulta.executeQuery()) {
            if (!resultat.next()) throw new SQLException("Comprovació de catàleg sense resultat");
        }
    }
}
