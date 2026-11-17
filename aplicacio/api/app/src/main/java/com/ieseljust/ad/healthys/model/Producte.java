package com.ieseljust.ad.healthys.model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/** Dades comunes del domini: sense SQL, connexions ni presentació. */
public abstract class Producte {
    private String id;
    private String nom;
    private String descripcio;
    private String categoria;
    private BigDecimal preu;
    private int calories;
    private String informacioAddicional;
    private String imatge;
    private List<String> allergens = new ArrayList<>();

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public String getDescripcio() { return descripcio; }
    public void setDescripcio(String descripcio) { this.descripcio = descripcio; }
    public String getCategoria() { return categoria; }
    public void setCategoria(String categoria) { this.categoria = categoria; }
    public BigDecimal getPreu() { return preu; }
    public void setPreu(BigDecimal preu) { this.preu = preu; }
    public int getCalories() { return calories; }
    public void setCalories(int calories) { this.calories = calories; }
    public String getInformacioAddicional() { return informacioAddicional; }
    public void setInformacioAddicional(String informacioAddicional) { this.informacioAddicional = informacioAddicional; }
    public String getImatge() { return imatge; }
    public void setImatge(String imatge) { this.imatge = imatge; }
    public List<String> getAllergens() { return allergens; }
    public void setAllergens(List<String> allergens) { this.allergens = allergens; }
}
