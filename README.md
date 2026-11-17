# Healthy's · Javalin i PostgreSQL amb Docker i Coolify

Anem a desplegar la solució Java de Healthy's amb dos contenidors: API Javalin i PostgreSQL amb el catàleg inicial. Aquest exemple reutilitza el patró de Cloud: Compose, xarxa interna, volum persistent, inicialització d'SQL i comprovacions de salut. El codi del backend conserva les entitats, servei, repositori JDBC i representació JSON de la pràctica d'AD.

## Recorregut de lectura

1. [Posem-ho tot en marxa en local](LOCAL.md).
2. [Consultem les rutes i el JSON de l'API](API.md).
3. [Despleguem des del subdirectori en Coolify](DESPLEGAMENT.md).

Comprovem el catàleg amb les ordres `curl` de [LOCAL.md](LOCAL.md) i [API.md](API.md); en el núvol substituïm la URL base pel domini HTTPS.

```text
aplicacio/
├── compose.yaml             # Conjunt per a Coolify, sense ports públics directes
├── compose.local.yaml       # Complement local: API en 127.0.0.1:18085
├── .env.example             # Noms de variables, sense claus reals
├── api/                     # Projecte Gradle i Dockerfile multietapa
└── postgres/init/           # Catàleg i rol d'API només de lectura
```

La documentació és a l'arrel i **el desplegament parteix d'`aplicacio/`**. Això permet practicar Base Directory en Coolify sense posar Dockerfile o Compose en l'arrel del repositori. No publiquem PostgreSQL a Internet; el proxy només exposa l'API. L'aplicació serveix les imatges des dels recursos Java.

## Arrancada ràpida local

```bash
cd aplicacio
cp -n .env.example .env
# Editem .env i substituïm les dues contrasenyes abans de continuar.
docker compose -f compose.yaml -f compose.local.yaml up -d --build --wait
curl -f http://127.0.0.1:18085/api/entrants
```

Podem necessitar `sudo` per accedir al motor Docker. El rol de l'API només llig; les dades inicials s'incorporen quan PostgreSQL crea el volum, no en cada petició ni reconstrucció. No pugem `.env`, memòries cau o resultats de construcció.

