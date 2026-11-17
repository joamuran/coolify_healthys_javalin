package com.ieseljust.ad.healthys;

import com.ieseljust.ad.healthys.controller.ProductesController;
import com.ieseljust.ad.healthys.infra.ConnexioBD;
import com.ieseljust.ad.healthys.repository.ProductesRepository;
import com.ieseljust.ad.healthys.service.ProductesService;
import com.ieseljust.ad.healthys.service.SalutService;
import com.ieseljust.ad.healthys.view.JsonView;
import io.javalin.Javalin;
import io.javalin.http.staticfiles.Location;
import java.sql.SQLException;
import java.util.Map;

/** Composició i arrencada: ara el procés espera peticions HTTP. */
public class App {
    private static final System.Logger LOGGER = System.getLogger(App.class.getName());

    public static void main(String[] args) {
        ConnexioBD configuracio = ConnexioBD.desDeEntorn();
        ProductesRepository repositori = new ProductesRepository();
        SalutService salut = new SalutService(configuracio);
        ProductesService servei = new ProductesService(configuracio, repositori);
        JsonView vista = new JsonView();
        ProductesController controlador = new ProductesController(servei, vista);
        int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "7070"));

        Javalin app = Javalin.create(config -> {
            // /public és una carpeta del classpath, empaquetada per Gradle.
            // public/img/foto.png queda disponible com /img/foto.png, sense /public.
            config.staticFiles.add("/public", Location.CLASSPATH);

            // API pública de lectura; CORS no substitueix autenticació o autorització.
            config.bundledPlugins.enableCors(cors -> cors.addRule(rule -> rule.anyHost()));
            config.routes.get("/api/estat", ctx -> vista.respondre(ctx, 200, Map.of("estat", "ok")));
            config.routes.get("/api/salut", ctx -> {
                try {
                    salut.comprovar();
                    vista.respondre(ctx, 200, Map.of("estat", "ok", "baseDades", "ok"));
                } catch (SQLException error) {
                    LOGGER.log(System.Logger.Level.WARNING, "Salut JDBC fallida [SQLState " + error.getSQLState() + "]");
                    vista.error(ctx, 503, "Base de dades no disponible");
                }
            });
            config.routes.get("/api/{tipus}", controlador::get);

            // Una excepció afecta la resposta actual, no ha de finalitzar el servidor.
            config.routes.exception(IllegalArgumentException.class, (error, ctx) ->
                    vista.error(ctx, 400, error.getMessage()));
            config.routes.exception(SQLException.class, (error, ctx) -> {
                LOGGER.log(System.Logger.Level.ERROR, "Error JDBC [SQLState "
                        + error.getSQLState() + "]", error);
                vista.error(ctx, 500, "No s'ha pogut consultar el catàleg");
            });
            config.routes.exception(UnsupportedOperationException.class, (error, ctx) ->
                    vista.error(ctx, 501, error.getMessage()));
            config.routes.exception(Exception.class, (error, ctx) -> {
                LOGGER.log(System.Logger.Level.ERROR, "Error processant la petició", error);
                vista.error(ctx, 500, "Error intern del servidor");
            });
            config.routes.error(404, ctx -> vista.error(ctx, 404, "Ruta inexistent"));
        });

        app.start("0.0.0.0", port);
        Runtime.getRuntime().addShutdownHook(new Thread(app::stop));
    }
}
