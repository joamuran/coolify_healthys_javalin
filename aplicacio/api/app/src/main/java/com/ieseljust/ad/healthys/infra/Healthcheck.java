package com.ieseljust.ad.healthys.infra;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

/** Client del healthcheck HTTP; no necessitem instal·lar curl en la imatge Java. */
public final class Healthcheck {
    public static void main(String[] args) {
        try {
            var client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(2)).build();
            String port = System.getenv().getOrDefault("PORT", "7070");
            var peticio = HttpRequest.newBuilder(URI.create("http://127.0.0.1:" + port + "/api/salut"))
                    .timeout(Duration.ofSeconds(8)).GET().build();
            if (client.send(peticio, HttpResponse.BodyHandlers.discarding()).statusCode() != 200) System.exit(1);
        } catch (Exception e) {
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            System.exit(1);
        }
    }
}
