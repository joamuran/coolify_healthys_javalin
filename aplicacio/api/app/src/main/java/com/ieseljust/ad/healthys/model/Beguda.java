package com.ieseljust.ad.healthys.model;
/** Boolean conserva també l'absència d'informació, si apareix en les dades. */
public class Beguda extends Producte {
    private Boolean alcoholica;
    public Boolean getAlcoholica() { return alcoholica; }
    public void setAlcoholica(Boolean alcoholica) { this.alcoholica = alcoholica; }
}
