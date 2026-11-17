package com.ieseljust.ad.healthys.repository;

import com.ieseljust.ad.healthys.model.*;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/** Accés SQL i mapatge. No tanquem la connexió que ens passa el servei. */
public class ProductesRepository {
    public List<Producte> llistarPerTipus(Connection connexio, String tipus) throws SQLException {

        // Creem una llista, obrim PreparedStatement i ResultSet amb try-with-resources,
        // assignem el paràmetre i recorrem les files cridant maparProducte.
        // Després de tancar la consulta principal, R3/R4 completaran les llistes.
        List<Producte> llistaProductes = new ArrayList<Producte>();

        String sql = """
                SELECT p.id, p.nom, p.descripcio, p.preu, p.calories,
                       p.informacio_addicional, p.imatge, p.es_alcoholica,
                       c.codi AS categoria, c.tipus_producte_codi
                FROM healthys.producte p
                INNER JOIN healthys.categoria c ON p.categoria_id = c.id
                WHERE c.tipus_producte_codi = ?
                ORDER BY p.id
                """;


        // try-with-resources
        try (PreparedStatement sentencia = connexio.prepareStatement(sql)) {
            sentencia.setString(1, tipus);   // Assignem el tipus al primer paràmetre de la consulta

            // Executem la consulta i obtenim el ResultSet, amb un try-with-resources
            try (
                    ResultSet rs = sentencia.executeQuery();) {

                // Recorrem el resultset
                while (rs.next()) {
                    // I afegim el producte resultat del mapat de la fila
                    llistaProductes.add(maparProducte(rs));
                }
            }

            // Tornem a recórrer la llist ade productes per afegir els al·lèrgens i el tipus de dieta
            for (Producte p : llistaProductes) {
                // Afegim la llist ad'al·lergens per a l'id del producte
                p.setAllergens(carregarAllergens(connexio, p.getId()));

                // Com que només els entrants i principals tenen dietes, hem de comprovar el tipus amb instanceof, així:
                if (p instanceof Entrant entrant) {
                    // Amb esta expressió, si p és un entrant, podem utilitzar-lo dins aquest bloc amb la variable entrant
                    entrant.setDietes(
                            carregarDietes(connexio, entrant.getId()));

                } else if (p instanceof Principal principal) {
                    principal.setDietes(
                            carregarDietes(connexio, principal.getId()));
                }

            }

            return llistaProductes;

        }
    }


    private Producte maparProducte(ResultSet fila) throws SQLException {
        // Assignem tots els camps comuns amb setters: BigDecimal per al preu.
        // En Beguda llegim es_alcoholica com Boolean; desconegut -> SQLException.

        // Aci venen coses interessants de la POO:
        // La referència és de tipus Producte; l'objecte serà d'una subclasse.
        // (definim el producte, que és el que retornarem, però el new el farem de la subclasse)
        Producte p;

        switch (fila.getString("tipus_producte_codi")) {
            case "entrants":
                p = new Entrant();
                break;

            case "principals":
                p = new Principal();
                break;

            case "begudes":
                Beguda b = new Beguda();
                // Boolean permet conservar un possible NULL de la columna.
                b.setAlcoholica( // Si fem p.setAlcoholica dirà que no és un mètode de Producte
                        fila.getObject("es_alcoholica", Boolean.class));

                p = b; // Però això si que ho podem fer!
                break;


            default:
                throw new SQLException("Tipus de producte desconegut: "
                        + fila.getString("tipus_producte_codi"));

        }
        // Establim les propietats comunes a totes les subclasses
        p.setId(fila.getString("id"));
        p.setNom(fila.getString("nom"));
        p.setDescripcio(fila.getString("descripcio"));
        p.setCategoria(fila.getString("categoria")); // Aci hem fet un alies
        p.setPreu(fila.getBigDecimal("preu"));
        p.setCalories(fila.getInt("calories"));
        p.setInformacioAddicional(fila.getString("informacio_addicional"));
        p.setImatge(fila.getString("imatge"));



        return p;

    }


    private List<String> carregarAllergens(Connection connexio, String id) throws SQLException {
        // Retornem una llista buida quan no hi ha associacions, mai null.

        List<String> allergens = new ArrayList<String>();

        String sql = "select nom from healthys.producte_allergen pa " +
                "inner join  healthys.allergen a " +
                "on pa.allergen_id = a.id  " +
                "where producte_id=? " +
                "order by pa.posicio";

        // try-with-resources
        try (PreparedStatement sentencia = connexio.prepareStatement(sql)) {
            sentencia.setString(1, id);    // Assignem l'identificador del producte al primer paràmetre.


            // Executem la consulta i obtenim el ResultSet (amb try-with-resources)
            try (
                    ResultSet rs = sentencia.executeQuery();) {

                // Recorrem el resultset
                while (rs.next()) {
                    allergens.add(rs.getString("nom"));
                }
            }

            return allergens;
        }

    }

    private List<String> carregarDietes(Connection connexio, String id) throws SQLException {
        // Des de llistarPerTipus assignem les dietes a Entrant o Principal.

        List<String> dietes = new ArrayList<String>();

        String sql = "select nom from healthys.tipus_dieta td \n" + //
                "inner join healthys.producte_dieta pd  \n" + //
                "on td.id = pd.tipus_dieta_id    \n" + //
                "where pd.producte_id =? \n" + //
                "order by pd.posicio;";

        // try-with-resources
        try (PreparedStatement sentencia = connexio.prepareStatement(sql)) {
            sentencia.setString(1, id);    // Assignem l'identificador al primer paràmetre.


            // Executem la consulta i obtenim el ResultSet (amb try-with-resources)
            try (ResultSet rs = sentencia.executeQuery();) {

                // Recorrem el resultset
                while (rs.next()) {
                    dietes.add(rs.getString("nom"));
                }
            }

            return dietes;
        }


    }
}
