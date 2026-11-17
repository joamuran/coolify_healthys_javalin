package com.ieseljust.ad.healthys.service;

import com.ieseljust.ad.healthys.infra.ConnexioBD;
import com.ieseljust.ad.healthys.model.Producte;
import com.ieseljust.ad.healthys.repository.ProductesRepository;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

/** Valida l'operació i delimita el temps de vida de la connexió. */
public class ProductesService {
    private final ConnexioBD configuracio;
    private final ProductesRepository repositori;

    public ProductesService(ConnexioBD configuracio, ProductesRepository repositori) {
        this.configuracio = configuracio;
        this.repositori = repositori;
    }

    public List<Producte> obtindrePerTipus(String tipus) throws SQLException {
        // Si el tipus no és vàlid, llancem IllegalArgumentException.

        // if (!tipus.equals("entrants") && !tipus.equals("principals") && !tipus.equals("begudes"))
        //   throw new IllegalArgumentException("Tipus vàlids: entrants | principals | begudes");
        // La part de dalt podria donar una NullPointerException si el tipus fora null, en l'accés a equals, 
        // millor fer-ho al revés:
        if (!"entrants".equals(tipus)
                && !"principals".equals(tipus)
                && !"begudes".equals(tipus)) {
            throw new IllegalArgumentException(
                    "Tipus vàlids: entrants | principals | begudes");
        }


        // Obrim amb try-with-resources, invoquem llistarPerTipus i retornem la llista.
        // No ocultem SQLException ni retornem null davant d'un error.
        try (Connection connexio = configuracio.obrir()) {
            return repositori.llistarPerTipus(connexio, tipus);
        }

    }
}
