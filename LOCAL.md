# Posem Healthy's en marxa en local

Necessitem Docker amb Compose i accés al motor. No cal instal·lar PostgreSQL, JDK o Gradle per executar els contenidors: el Dockerfile construeix l'aplicació en una etapa Gradle/JDK i copia la distribució a una imatge JRE amb usuari sense privilegis. És el mateix patró de construcció multietapa treballat en Cloud.

## Configuració base i complement local

Compose permet indicar diversos fitxers amb `-f`: els combina en l'ordre indicat per obtenir una única configuració. En el nostre cas utilitzem:

- `compose.yaml`: defineix els serveis `api` i `postgres`, la xarxa interna, el volum persistent i les comprovacions de salut. És la base que també utilitzarem en Coolify.
- `compose.local.yaml`: adapta aquests mateixos serveis al nostre ordinador. Publica l'API en `127.0.0.1:18085`, desactiva el reinici automàtic i assigna un nom al projecte local.

Per tant, `docker compose -f compose.yaml -f compose.local.yaml up -d` arranca **dos contenidors**, no dos conjunts de contenidors. El segon fitxer completa o modifica el primer: afegeix la publicació del port i substitueix el valor de `restart`. No elimina les altres propietats dels serveis. L'ordre dels fitxers importa; mantenim aquests mateixos arguments `-f` quan consultem els logs, aturem o retirem aquest desplegament.

Ací també fem un **desplegament local**: construïm les imatges i posem en marxa els contenidors en el nostre ordinador. L'API queda accessible només des d'aquest equip perquè publiquem el port en `127.0.0.1`. En Coolify farem el desplegament en un servidor i hi accedirem mitjançant un domini HTTPS. No cal canviar el codi de l'aplicació per aquesta diferència.

## Preparem i arranquem

Des de l'arrel del repositori entrem en `aplicacio/` i copiem l'exemple de configuració. Amb `cp -n` conservem un `.env` existent:

```bash
cd aplicacio
cp -n .env.example .env
chmod 600 .env
```

Obrim `.env` amb l’editor i substituïm `POSTGRES_PASSWORD` i `HEALTHYS_API_PASSWORD` per dues contrasenyes diferents de les d’exemple. Conservem els noms de les variables i `HEALTHYS_HTTP_PORT=18085`, llevat que necessitem un altre port local. No pugem `.env` a Git ni l’incloem en captures; ja està exclòs en `.gitignore`. En Coolify definirem les claus en el panell, sense pujar aquest fitxer.

Després de guardar la configuració validem i arranquem:

```bash
docker compose -f compose.yaml -f compose.local.yaml config --quiet
docker compose -f compose.yaml -f compose.local.yaml up -d --build --wait
docker compose -f compose.yaml -f compose.local.yaml ps
```

Si necessitem `sudo` per al motor, l’anteposem a les ordres Docker, no a curl. `config --quiet` valida sense imprimir les variables expandides.

### Comprovem les respostes

```bash
curl -i http://127.0.0.1:18085/api/estat
curl -i http://127.0.0.1:18085/api/salut
curl -f http://127.0.0.1:18085/api/entrants
curl -f http://127.0.0.1:18085/api/principals
curl -f http://127.0.0.1:18085/api/begudes
curl -I http://127.0.0.1:18085/img/amanida_mediterrania.png
```

Esperem 200 en estat i salut, arrays JSON en els tres catàlegs i una resposta correcta amb tipus `image/png` per a la imatge. `-i` mostra capçaleres i cos, `-I` consulta només les capçaleres i `-f` fa que curl informe d’un error davant d’un estat HTTP de fallada. Els recomptes esperats són 13 entrants, 12 principals i 8 begudes; els contrastarem també amb SQL. Podem obrir les respostes en el navegador per inspeccionar-les amb més comoditat. Si hem canviat el port de `.env`, l’adaptem en aquestes URL.

| Connexió | Adreça |
| --- | --- |
| Navegador o client local → API | `http://127.0.0.1:18085`; el port es pot canviar amb `HEALTHYS_HTTP_PORT` en `.env`. |
| API → PostgreSQL | `postgres:5432`, base `healthys`, usuari `healthys_api`. |
| Administració des de dins del contenidor | `docker compose exec postgres psql -U healthys_admin -d healthys`. |

PostgreSQL no publica cap port en l'ordinador: les consultes de prova es fan amb psql dins del contenidor, com en el conjunt final de Cloud. Si després necessitem DBeaver, definirem una publicació local explícita; no cal per provar l'API.

## Què crea la primera arrancada?

`compose.yaml` munta el volum `dades` en `/var/lib/postgresql`, la ruta de volum de PostgreSQL 18. El directori `postgres/init/` es munta només de lectura: el primer script crea l'esquema `healthys` i carrega els 33 productes, categories, al·lèrgens i dietes; el segon crea `healthys_api` amb connexió, ús de l'esquema i SELECT. L'API no utilitza el rol administrador ni necessita permisos d'escriptura.

La base s'anomena `healthys`, independent de `empresa`, que utilitzàvem en AD. El catàleg i el seu mapatge no canvien; hem adaptat la comprovació de nom de base del script. Els fitxers d'inicialització només s'executen quan el volum és buit. Una reconstrucció de l'API no recarrega ni elimina dades.

Comprovem els recomptes:

```bash
docker compose -f compose.yaml -f compose.local.yaml exec postgres psql -U healthys_admin -d healthys -c "SELECT c.tipus_producte_codi, count(*) FROM healthys.producte p JOIN healthys.categoria c ON c.id=p.categoria_id GROUP BY c.tipus_producte_codi ORDER BY 1;"
```

Esperem begudes 8, entrants 13 i principals 12. La comprovació psql local no demostra l'autenticació TCP; `/api/salut` sí que prova JDBC amb l'usuari de lectura.

## Desenvolupament, recuperació i aturada

Podem arrancar només PostgreSQL amb `up -d --wait postgres`. En aquest exemple no publica port; per executar Java des de l'IDE caldria afegir un port loopback a PostgreSQL i adaptar `AD_DB_URL`. Per a la prova inicial utilitzem els dos contenidors i mantenim una única configuració JDBC interna.

Després de canviar el codi reconstruïm l'API amb `up -d --build --wait api`. Podem seguir els logs amb `logs --tail 80 api`. Les operacions utilitzen sempre els dos fitxers de Compose en local.

Per provar la recuperació:

```bash
docker compose -f compose.yaml -f compose.local.yaml stop postgres
curl -i http://127.0.0.1:18085/api/estat
curl -i http://127.0.0.1:18085/api/salut
docker compose -f compose.yaml -f compose.local.yaml start postgres
```

L'estat HTTP continua a 200 i la salut passa a 503 fins que PostgreSQL torna a estar disponible. En recuperar-se la base, la salut ha de tornar a 200 sense reconstruir. Per acabar, `docker compose -f compose.yaml -f compose.local.yaml down` retira contenidors i xarxa, però conserva el volum. No utilitzem `down -v` si volem conservar les dades.

Canviar una clau en `.env` no canvia la d'un rol d'un volum existent. Les modificacions d'esquema i les rotacions de contrasenya s'han d'aplicar també a PostgreSQL; no s'arreglen tornant a executar els scripts sobre una base ja poblada.

## Recuperem una inicialització interrompuda

Si un script de `postgres/init/` falla, el volum pot contindre ja el clúster PostgreSQL, encara que falten les taules. En arrancar de nou, la imatge detecta el clúster existent i no repeteix automàticament els scripts. Corregir el fitxer i executar `up` no completa per si mateix la càrrega pendent.

Si el registre mostra l'error de sintaxi en el missatge `abans d'executar` de `00-healthys.sql`, utilitzem el fitxer corregit, amb `d''executar` dins de la cadena SQL. Com que la càrrega està dins de `BEGIN` i `COMMIT`, aquella fallada ha desfet els canvis de la transacció. Per a aquest cas concret podem completar la inicialització sense eliminar el volum:

```bash
docker compose -f compose.yaml -f compose.local.yaml up -d --wait postgres
docker compose -f compose.yaml -f compose.local.yaml exec postgres psql -U healthys_admin -d healthys -v ON_ERROR_STOP=1 -f /docker-entrypoint-initdb.d/00-healthys.sql
docker compose -f compose.yaml -f compose.local.yaml exec postgres bash /docker-entrypoint-initdb.d/01-permisos.sh
docker compose -f compose.yaml -f compose.local.yaml up -d --wait api
curl -i http://127.0.0.1:18085/api/salut
```

Aquestes ordres de càrrega són una recuperació puntual, no el procediment habitual d'arrancada: el SQL crea taules i el segon script crea el rol, de manera que no els repetim sobre una instal·lació ja completada. Per a errors diferents revisem primer fins on ha arribat la inicialització.
