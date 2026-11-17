# Despleguem Healthy’s en Coolify des d’un subdirectori

Seguim la mateixa idea que en el desplegament web anterior: repositori Git, projecte, entorn i recurs. Ara el recurs és un conjunt Compose amb una API i PostgreSQL; no un lloc estàtic. Primer comprovem [l’execució local](LOCAL.md) i després registrem els passos reals del desplegament.

## Local i núvol: què canvia?

| Aspecte | Local | Coolify |
| --- | --- | --- |
| Compose | `compose.yaml` + `compose.local.yaml`. | Només `compose.yaml`. |
| Entrada HTTP | Port loopback 18085. | Domini HTTPS gestionat pel proxy de Coolify, dirigit al servei `api` i port intern 7070. |
| Credencials | `aplicacio/.env`, exclòs de Git. | Variables del recurs en el panell; no es puja `.env`. |
| PostgreSQL | Xarxa interna de Compose. | Xarxa interna del recurs; no publiquem un port de BD al VPS. |
| Dades | Volum local persistent. | Volum persistent del servidor; l’operació i les còpies són responsabilitat nostra. |

Amb la configuració actual no necessitem modificar el Dockerfile ni els fitxers Compose per passar a Coolify. En local combinem la base amb el complement, com expliquem en [la guia local](LOCAL.md#configuració-base-i-complement-local); en Coolify seleccionem únicam’nt `compose.yaml`. El complement local ’ublica un port en el nostre ordinador, mentre que en Coolify el proxy proporciona l'accés públic al port intern’7070. Configurarem en el panell les variables, les rutes del repositori i el domini que indiquem a continuació.

En tots dos casos despleguem els serveis: en local ho fem en el nostre ordinador i en Coolify’en el servidor. La ruta `aplicacio/` és un directori del repositori, no el prefix de la URL pública. Les peticions continuaran sent `/api/entrants`, no `/aplicacio/api/entrants`.

