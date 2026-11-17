package com.ieseljust.ad.healthys.controller;

import com.ieseljust.ad.healthys.service.ProductesService;
import com.ieseljust.ad.healthys.view.JsonView;
import io.javalin.http.Context;
import java.sql.SQLException;

/** El controlador adapta la petició HTTP al servei ja conegut. */
public class ProductesController {
    private final ProductesService servei;
    private final JsonView vista;

    public ProductesController(ProductesService servei, JsonView vista) {
        this.servei = servei;
        this.vista = vista;
    }

    public void get(Context ctx) throws SQLException {
        // i passem la llista a vista.mostrarProductes(ctx, productes).
        // No retornem un codi de procés ni fem System.exit: responem a una petició.

        String tipus = ctx.pathParam("tipus");      // Obtenim el paràmetre tipus de la petició
        var productes = servei.obtindrePerTipus(tipus);  // Obtenim la llista de productes del tipus concret des del servei
        vista.mostrarProductes(ctx, productes);          // Passem el resultat (llista mapes) a la vista

    }
}
