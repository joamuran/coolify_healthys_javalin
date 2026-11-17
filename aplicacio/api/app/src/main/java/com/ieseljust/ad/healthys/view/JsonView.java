package com.ieseljust.ad.healthys.view;

import com.ieseljust.ad.healthys.model.*;
import io.javalin.http.Context;
import tools.jackson.databind.json.JsonMapper;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Representació HTTP/JSON: el domini continua independent de Jackson i Javalin. */
public class JsonView {
    // Reutilitzem el mapper immutable; cada petició construeix la seua resposta local.
    private final JsonMapper mapper = JsonMapper.builder().build();

    public void respondre(Context ctx, int estat, Object dades) {
        // Serialitzem una sola vegada. Enviem JSON, no una cadena JSON dins d'una altra.
        String json = mapper.writeValueAsString(dades);
        ctx.status(estat).contentType("application/json; charset=utf-8").result(json);
    }

    public void error(Context ctx, int estat, String missatge) {
        respondre(ctx, estat, Map.of("error", missatge));
    }

    public Map<String, Object> representarProducte(Producte producte) {
        // Comencem amb id/name i afegim els altres camps comuns amb els getters.
        // tipus és getCategoria(), no entrants/principals/begudes.
        // Amb instanceof afegim dietType per als plats o isAlcoholic per a Beguda.
        Map<String, Object> dades = new LinkedHashMap<>();

        dades.put("id", producte.getId());
        dades.put("name", producte.getNom());
        dades.put("description", producte.getDescripcio());
        dades.put("tipus", producte.getCategoria());
        dades.put("allergens", producte.getAllergens());
        dades.put("price", producte.getPreu());
        dades.put("calories", producte.getCalories());
        dades.put("additionalInfo", producte.getInformacioAddicional());
        dades.put("img", producte.getImatge());

        if (producte instanceof Entrant entrant) {
            dades.put("dietType", entrant.getDietes());
        } else if (producte instanceof Principal principal) {
            dades.put("dietType", principal.getDietes());
        } else if (producte instanceof Beguda beguda){
            dades.put("isAlcoholic", beguda.getAlcoholica());
        }

        return dades;
    }

    public void mostrarProductes(Context ctx, List<Producte> productes) {
        // afegim representarProducte(producte) i responem amb estat 200.
        // Una llista buida és [] amb 200; no emboliquem la llista en un altre objecte.

        List<Map<String, Object>> llistaProductes=new ArrayList<Map<String,Object>>();
        for (Producte p: productes){
            llistaProductes.add(representarProducte(p));
        }

        // I ara responem la petició enviant la llista!
        respondre(ctx, 200, llistaProductes);

    }
}
