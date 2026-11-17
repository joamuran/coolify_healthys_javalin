-- Inicialització única del catàleg sobre una base healthys buida.
-- Esquema i dades de mostra de la pràctica AD; no es carrega en cada arrancada.
BEGIN;

-- Dins d'una cadena SQL escapem l'apòstrof amb dos apòstrofs consecutius ('').
-- Evitem crear accidentalment l'esquema en una base diferent.
DO $$
BEGIN
    IF current_database() <> 'healthys' THEN
        RAISE EXCEPTION 'Seleccionem la base healthys abans d''executar aquest script';
    END IF;
END
$$;

CREATE SCHEMA IF NOT EXISTS healthys;

CREATE TABLE healthys.tipus_producte (
    codi varchar(20) PRIMARY KEY,
    nom varchar(60) NOT NULL UNIQUE
);

-- Una categoria pertany a un tipus: amanides d'entrants i de principals
-- són categories diferents, encara que compartisquen el mateix codi.
CREATE TABLE healthys.categoria (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipus_producte_codi varchar(20) NOT NULL REFERENCES healthys.tipus_producte(codi),
    codi varchar(60) NOT NULL,
    UNIQUE (tipus_producte_codi, codi)
);

CREATE TABLE healthys.producte (
    id varchar(20) PRIMARY KEY,
    categoria_id integer NOT NULL REFERENCES healthys.categoria(id),
    nom text NOT NULL,
    descripcio text NOT NULL,
    preu numeric(10,2) NOT NULL CHECK (preu >= 0),
    calories integer NOT NULL CHECK (calories >= 0),
    informacio_addicional text,
    imatge text,
    -- NULL significa que la font no proporciona isAlcoholic (entrants/principals).
    es_alcoholica boolean
);

CREATE TABLE healthys.allergen (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom text NOT NULL UNIQUE
);

CREATE TABLE healthys.producte_allergen (
    producte_id varchar(20) NOT NULL REFERENCES healthys.producte(id) ON DELETE CASCADE,
    allergen_id integer NOT NULL REFERENCES healthys.allergen(id),
    -- Conservem també l'ordre de la llista original.
    posicio integer NOT NULL CHECK (posicio > 0),
    PRIMARY KEY (producte_id, allergen_id),
    UNIQUE (producte_id, posicio)
);

CREATE TABLE healthys.tipus_dieta (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom text NOT NULL UNIQUE
);

CREATE TABLE healthys.producte_dieta (
    producte_id varchar(20) NOT NULL REFERENCES healthys.producte(id) ON DELETE CASCADE,
    tipus_dieta_id integer NOT NULL REFERENCES healthys.tipus_dieta(id),
    posicio integer NOT NULL CHECK (posicio > 0),
    PRIMARY KEY (producte_id, tipus_dieta_id),
    UNIQUE (producte_id, posicio)
);

-- Índexs per a consultes de productes per categoria, al·lergen o dieta.
CREATE INDEX ON healthys.producte(categoria_id);
CREATE INDEX ON healthys.producte_allergen(allergen_id);
CREATE INDEX ON healthys.producte_dieta(tipus_dieta_id);

-- Catàlegs compartits. Els identificadors numèrics els genera PostgreSQL.
INSERT INTO healthys.tipus_producte (codi, nom) VALUES
    ('entrants', 'Entrants'), ('principals', 'Principals'), ('begudes', 'Begudes');

INSERT INTO healthys.categoria (tipus_producte_codi, codi) VALUES
    ('entrants', 'amanides'),
    ('entrants', 'tartars'),
    ('entrants', 'rotllets'),
    ('entrants', 'altres');

INSERT INTO healthys.categoria (tipus_producte_codi, codi) VALUES
    ('principals', 'pokes'),
    ('principals', 'wraps'),
    ('principals', 'amanides'),
    ('principals', 'altres');

INSERT INTO healthys.categoria (tipus_producte_codi, codi) VALUES
    ('begudes', 'kombuches'),
    ('begudes', 'aigues'),
    ('begudes', 'te'),
    ('begudes', 'altres');

INSERT INTO healthys.allergen (nom) VALUES
    ('Cacauet'),
    ('Cervesa'),
    ('Gluten'),
    ('Llet'),
    ('Ous'),
    ('Peix'),
    ('Sèsam');

INSERT INTO healthys.tipus_dieta (nom) VALUES
    ('Alta en proteïnes'),
    ('Baja en carbohidrats'),
    ('Sense gluten'),
    ('Vegetarià'),
    ('Vegà');

-- Productes: mantenim els identificadors ENT, PRI i BEG de l'API.
INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('ENT01', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'entrants' AND codi = 'amanides'), 'Amanida mediterrània', 'Enciam, tomàquet, cogombre, olives, formatge feta i vinagreta.', 9.00, 220, 'Fresca i lleugera.', 'img/amanida_mediterrania.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('ENT02', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'entrants' AND codi = 'amanides'), 'Amanida de quinoa i verdures', 'Quinoa, espinacs, pebrot, ceba morada i alvocat.', 8.50, 300, 'Una opció nutritiva i lleugera.', 'img/amanida_quinoa_verdures.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('ENT03', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'entrants' AND codi = 'amanides'), 'Amanida caprese', 'Tomàquet, mozzarella fresca, alfàbrega i oli d''oliva extra verge.', 6.50, 200, 'Fresca i lleugera.', 'img/amanida_caprese.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('ENT04', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'entrants' AND codi = 'tartars'), 'Tartar de tonyina', 'Tartar fresc de tonyina amb alvocat, llavors de sèsam i salsa de soja.', 7.50, 200, 'Rica en omega 3.', 'img/tartar_tonyina.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('ENT05', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'entrants' AND codi = 'tartars'), 'Tartar de salmó', 'Salmó fresc amb alvocat, llavors de sèsam i salsa teriyaki.', 8.00, 180, 'Proteïna saludable per començar.', 'img/tartar_salmo.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('ENT06', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'entrants' AND codi = 'tartars'), 'Tartar de verdures', 'Tartar fresc de cogombre, alvocat, tomàquet i ceba morada.', 5.50, 180, 'Lleuger i fresc.', 'img/tartar_verdures.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('ENT07', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'entrants' AND codi = 'rotllets'), 'Rotllets vietnamites', 'Rollitos d''arròs farcits de verdures fresques i salsa de cacauet.', 7.00, 230, 'Edat de l''orient més saludable.', 'img/rollets_vietnamites.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('ENT08', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'entrants' AND codi = 'rotllets'), 'Rotllets de primavera', 'Rotllets d''arròs farcits amb verdures i salsa de soja.', 6.00, 200, 'Frescos i lleugers.', 'img/rollitos_primavera.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('ENT09', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'entrants' AND codi = 'altres'), 'Hummus clàssic', 'Hummus casolà amb pa de pita i verdures fresques.', 5.00, 250, 'Ideal per a picoteig saludable.', 'img/hummus_classic.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('ENT10', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'entrants' AND codi = 'altres'), 'Guacamole amb nachos', 'Guacamole fresc fet amb alvocat madur i servit amb nachos cruixents.', 6.00, 300, 'Un clàssic mexicà amb un toc saludable.', 'img/guacamole_nachos.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('ENT11', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'entrants' AND codi = 'altres'), 'Pà de pita amb hummus', 'Pita calenta acompanyada de hummus casolà.', 4.50, 220, 'Ideal per a vegans.', 'img/pa_pita_hummus.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('ENT12', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'entrants' AND codi = 'altres'), 'Bruschetta de tomàquet', 'Pa torrat amb tomàquet fresc, all i oli d''oliva.', 4.00, 150, 'Fresca i deliciosa.', 'img/bruschetta_tomaquet.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('ENT13', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'entrants' AND codi = 'altres'), 'Carpaccio de vedella', 'Carpaccio de vedella acompanyat de rúcula, parmesà i oli d''oliva.', 9.50, 250, 'Una opció sofisticada per a carnívors.', 'img/carpaccio_vedella.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('PRI01', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'principals' AND codi = 'pokes'), 'Poke de tonyina', 'Poke de tonyina fresca amb alvocat, ceba, alga nori, i salsa de soja.', 12.00, 350, 'Ric en omega 3 i perfecte per a una dieta alta en proteïnes.', 'img/poke_tonyina.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('PRI02', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'principals' AND codi = 'pokes'), 'Poke vegà', 'Poke vegà amb quinoa, alvocat, tomàquet, cogombre, edamame i salsa de sèsam.', 11.00, 300, 'Una opció vegana, nutritiva i deliciosa.', 'img/poke_vega.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('PRI03', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'principals' AND codi = 'wraps'), 'Wrap de pollastre i verdures', 'Wrap amb pollastre, cogombre, alvocat, i salsa de mostassa.', 8.50, 350, 'Una opció ràpida i saludable.', 'img/wrap_pollastre.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('PRI04', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'principals' AND codi = 'wraps'), 'Wrap vegà', 'Wrap de verdures fresques, alvocat, i salsa de tahini.', 7.00, 280, 'Lleuger i ple de nutrients.', 'img/wrap_vega.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('PRI05', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'principals' AND codi = 'amanides'), 'Amanida de quinoa i pollastre', 'Quinoa, pollastre a la planxa, espinacs, tomàquet i alvocat.', 10.50, 400, 'Perfecte per a una dieta equilibrada.', 'img/amanida_quina_pollastre.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('PRI06', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'principals' AND codi = 'amanides'), 'Amanida  de salmó i alvocat', 'Salmó a la planxa, alvocat, enciam, cogombre i vinagreta de llimona.', 11.00, 350, 'Una opció fresca i saludable.', 'img/amanida_salmo.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('PRI07', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'principals' AND codi = 'amanides'), 'Amanida mediterrània', 'Amanida amb enciam, tomàquet, cogombre, olives, formatge feta i vinagreta.', 9.00, 220, 'Una opció lleugera i fresca.', 'img/amandia_mediterrania.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('PRI08', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'principals' AND codi = 'amanides'), 'Amanida César', 'Amanida amb enciam, pollastre, crostons, formatge parmesà i salsa César.', 10.00, 450, 'Una opció clàssica amb un toc saludable.', 'img/amanida_cesar.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('PRI09', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'principals' AND codi = 'amanides'), 'Amanida de fruites tropicals', 'Barreja de fruites tropicals amb mango, pinya, kiwi i llavors de chia.', 7.00, 150, 'Una opció fresca i lleugera.', 'img/amanida_fruites_tropicals.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('PRI10', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'principals' AND codi = 'altres'), 'Bowl de salmó', 'Bowl de salmó amb quinoa, alvocat, alga nori, edamame i salsa de soja.', 12.50, 400, 'Ideal per als amants del peix cru.', 'img/bowl_salmo.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('PRI11', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'principals' AND codi = 'altres'), 'Sushi vegà', 'Sushi amb arròs, alvocat, cogombre, pebrot i algues.', 13.00, 350, 'Deliciós i perfecte per a vegans.', 'img/sushi_vega.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('PRI12', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'principals' AND codi = 'altres'), 'Tàrtar de vedella', 'Tàrtar de vedella amb ceba morada, mostassa, ou, i oli d''oliva.', 14.00, 400, 'Rica en proteïnes i ideal per als amants de la carn.', 'img/tartar_vedella.png', NULL);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('BEG01', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'begudes' AND codi = 'kombuches'), 'Kombucha de gingebre i llimona', 'Kombucha refrescant amb gingebre natural i un toc de llimona.', 3.50, 60, 'Una opció ideal per millorar la digestió.', 'img/kombucha_gingebre.png', FALSE);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('BEG02', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'begudes' AND codi = 'kombuches'), 'Kombucha de fruites del bosc', 'Kombucha amb fruits del bosc i un toc d''herbes fresques.', 3.50, 70, 'Una beguda refrescant i rica en antioxidants.', 'img/kombucha_fruits_bosc.png', FALSE);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('BEG03', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'begudes' AND codi = 'aigues'), 'Aigua de coco', 'Aigua de coco natural sense sucre afegit.', 2.50, 45, 'Hidrata''t de forma natural.', 'img/aigua_coco.png', FALSE);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('BEG04', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'begudes' AND codi = 'aigues'), 'Aigua amb gas', 'Aigua mineral amb gas per a un toc refrescant.', 2.00, 0, 'Una opció lleugera i refrescant.', 'img/aigua_gas.png', FALSE);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('BEG05', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'begudes' AND codi = 'te'), 'Té gelat de menta', 'Té fresc amb un toc de menta i llima.', 3.00, 50, 'Refresca''t amb un te saludable.', 'img/te_gelat_menta.png', FALSE);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('BEG06', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'begudes' AND codi = 'te'), 'Té verd', 'Té verd natural amb un toc de llimona.', 3.00, 30, 'Perfecte per a relaxar-se durant el sopar.', 'img/te_verd.png', FALSE);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('BEG07', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'begudes' AND codi = 'altres'), 'Cervesa sense alcohol', 'Cervesa sense alcohol refrescant.', 2.50, 100, 'Una opció refrescant per a qualsevol hora.', 'img/cervesa_sense_alcohol.png', FALSE);

INSERT INTO healthys.producte (id, categoria_id, nom, descripcio, preu, calories, informacio_addicional, imatge, es_alcoholica)
VALUES ('BEG08', (SELECT id FROM healthys.categoria WHERE tipus_producte_codi = 'begudes' AND codi = 'altres'), 'Cervesa zero zero Tostada', 'Cervesa 0.0 tostada refrescant.', 2.50, 100, 'Una opció refrescant i de sabor intens.', 'img/cervesa_00.png', FALSE);

-- Les llistes buides no generen files en la taula de relació.
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('ENT01', (SELECT id FROM healthys.allergen WHERE nom = 'Llet'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('ENT03', (SELECT id FROM healthys.allergen WHERE nom = 'Llet'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('ENT04', (SELECT id FROM healthys.allergen WHERE nom = 'Peix'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('ENT04', (SELECT id FROM healthys.allergen WHERE nom = 'Sèsam'), 2);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('ENT05', (SELECT id FROM healthys.allergen WHERE nom = 'Peix'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('ENT05', (SELECT id FROM healthys.allergen WHERE nom = 'Sèsam'), 2);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('ENT07', (SELECT id FROM healthys.allergen WHERE nom = 'Cacauet'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('ENT07', (SELECT id FROM healthys.allergen WHERE nom = 'Gluten'), 2);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('ENT08', (SELECT id FROM healthys.allergen WHERE nom = 'Sèsam'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('ENT09', (SELECT id FROM healthys.allergen WHERE nom = 'Gluten'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('ENT09', (SELECT id FROM healthys.allergen WHERE nom = 'Llet'), 2);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('ENT10', (SELECT id FROM healthys.allergen WHERE nom = 'Gluten'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('ENT11', (SELECT id FROM healthys.allergen WHERE nom = 'Gluten'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('ENT12', (SELECT id FROM healthys.allergen WHERE nom = 'Gluten'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('ENT13', (SELECT id FROM healthys.allergen WHERE nom = 'Llet'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('PRI01', (SELECT id FROM healthys.allergen WHERE nom = 'Peix'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('PRI01', (SELECT id FROM healthys.allergen WHERE nom = 'Sèsam'), 2);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('PRI02', (SELECT id FROM healthys.allergen WHERE nom = 'Sèsam'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('PRI03', (SELECT id FROM healthys.allergen WHERE nom = 'Gluten'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('PRI04', (SELECT id FROM healthys.allergen WHERE nom = 'Gluten'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('PRI06', (SELECT id FROM healthys.allergen WHERE nom = 'Peix'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('PRI07', (SELECT id FROM healthys.allergen WHERE nom = 'Llet'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('PRI08', (SELECT id FROM healthys.allergen WHERE nom = 'Gluten'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('PRI08', (SELECT id FROM healthys.allergen WHERE nom = 'Llet'), 2);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('PRI10', (SELECT id FROM healthys.allergen WHERE nom = 'Peix'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('PRI10', (SELECT id FROM healthys.allergen WHERE nom = 'Sèsam'), 2);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('PRI11', (SELECT id FROM healthys.allergen WHERE nom = 'Sèsam'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('PRI12', (SELECT id FROM healthys.allergen WHERE nom = 'Ous'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('PRI12', (SELECT id FROM healthys.allergen WHERE nom = 'Sèsam'), 2);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('BEG07', (SELECT id FROM healthys.allergen WHERE nom = 'Cervesa'), 1);
INSERT INTO healthys.producte_allergen (producte_id, allergen_id, posicio) VALUES ('BEG08', (SELECT id FROM healthys.allergen WHERE nom = 'Cervesa'), 1);

-- Les llistes buides no generen files en la taula de relació.
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('ENT01', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Sense gluten'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('ENT01', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Vegetarià'), 2);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('ENT02', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Vegà'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('ENT02', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Sense gluten'), 2);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('ENT03', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Sense gluten'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('ENT03', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Vegetarià'), 2);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('ENT04', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Sense gluten'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('ENT04', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Baja en carbohidrats'), 2);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('ENT05', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Sense gluten'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('ENT06', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Vegà'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('ENT06', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Sense gluten'), 2);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('ENT07', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Vegà'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('ENT08', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Vegà'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('ENT08', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Sense gluten'), 2);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('ENT09', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Vegà'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('ENT10', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Vegà'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('ENT11', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Vegà'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('ENT12', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Vegà'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('ENT13', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Sense gluten'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('PRI01', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Sense gluten'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('PRI01', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Alta en proteïnes'), 2);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('PRI02', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Vegà'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('PRI02', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Sense gluten'), 2);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('PRI03', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Alta en proteïnes'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('PRI04', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Vegà'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('PRI05', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Sense gluten'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('PRI05', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Alta en proteïnes'), 2);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('PRI06', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Sense gluten'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('PRI06', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Alta en proteïnes'), 2);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('PRI07', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Vegetarià'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('PRI07', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Sense gluten'), 2);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('PRI09', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Vegà'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('PRI09', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Sense gluten'), 2);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('PRI10', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Sense gluten'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('PRI10', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Alta en proteïnes'), 2);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('PRI11', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Vegà'), 1);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('PRI11', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Sense gluten'), 2);
INSERT INTO healthys.producte_dieta (producte_id, tipus_dieta_id, posicio) VALUES ('PRI12', (SELECT id FROM healthys.tipus_dieta WHERE nom = 'Sense gluten'), 1);

COMMIT;

-- Comprovem els recomptes: begudes 8, entrants 13 i principals 12.
SELECT c.tipus_producte_codi AS tipus, count(*) AS productes
FROM healthys.producte p
JOIN healthys.categoria c ON c.id = p.categoria_id
GROUP BY c.tipus_producte_codi
ORDER BY c.tipus_producte_codi;

-- Consultem el detall bàsic sense multiplicar files per les llistes.
SELECT p.id, p.nom, c.tipus_producte_codi AS tipus, c.codi AS categoria,
       p.preu, p.calories, p.es_alcoholica
FROM healthys.producte p
JOIN healthys.categoria c ON c.id = p.categoria_id
ORDER BY p.id;
