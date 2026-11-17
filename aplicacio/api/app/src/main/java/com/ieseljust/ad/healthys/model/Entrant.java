package com.ieseljust.ad.healthys.model;
import java.util.ArrayList;
import java.util.List;
/** Plat amb els camps comuns i una llista de dietes. */
public class Entrant extends Producte {
    private List<String> dietes = new ArrayList<>();
    public List<String> getDietes() { return dietes; }
    public void setDietes(List<String> dietes) { this.dietes = dietes; }
}
