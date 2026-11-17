# API Healthy's

L'API publica la carta utilitzada en PMDM, mantenint l'estructura JSON i les rutes d'imatges de la solució Javalin d'AD. Només ofereix consultes; no hi ha comptes ni escriptura des de l'API. CORS permet consultar-la des d'un client web sense credencials, però no és un mecanisme d'autorització.

## Operacions

| Petició GET | Resposta correcta |
| --- | --- |
| `/api/estat` | 200 amb `{"estat":"ok"}`: el servidor HTTP està en marxa. |
| `/api/salut` | 200 amb `{"estat":"ok","baseDades":"ok"}` si podem llegir `healthys.producte`; 503 si fallen connexió, autenticació, esquema o permisos. |
| `/api/entrants` | Array JSON amb els 13 entrants inicials. |
| `/api/principals` | Array JSON amb els 12 principals inicials. |
| `/api/begudes` | Array JSON amb les 8 begudes inicials. |
| `/img/{fitxer}` | Imatge empaquetada en els recursos de l'aplicació, si existeix. |

Els llistats retornen directament un array, sense embolcall. Un catàleg buit retorna `[]` amb 200. Cada objecte conté `id`, `name`, `description`, `tipus`, `allergens`, `price`, `calories`, `additionalInfo` i `img`. `tipus` és la categoria, com amanides, no el grup entrants/principals/begudes. Els plats afegeixen `dietType`; les begudes afegeixen `isAlcoholic`. Els imports són números, les llistes arrays i els opcionals desconeguts `null`, segons les dades de mostra.

`img` és una ruta relativa com `img/amanida_mediterrania.png`. El client combina la URL base i aquella ruta; no cal canviar el client en passar de local a HTTPS. L'aplicació serveix les imatges en `/img/` des de `aplicacio/api/app/src/main/resources/public/img/`.

## Errors i prova manual

Un tipus de producte no admés, com `/api/postres`, retorna 400 amb un objecte `error`. Una ruta inexistent retorna 404. Una fallada JDBC en el catàleg retorna 500 amb un missatge genèric, mentre que `/api/salut` retorna 503. No enviem SQL, credencials ni traces Java en les respostes. Els missatges tècnics queden en els logs del servidor.

En local, amb el port predeterminat:

```bash
curl -i http://127.0.0.1:18085/api/salut
curl -f http://127.0.0.1:18085/api/entrants
curl -f http://127.0.0.1:18085/api/principals
curl -f http://127.0.0.1:18085/api/begudes
curl -i http://127.0.0.1:18085/api/postres
curl -I http://127.0.0.1:18085/img/amanida_mediterrania.png
```

En el núvol substituïm només la URL base per la del domini configurat. El desplegament inicial no crea una API diferent: els mateixos controladors, serveis, repositoris i dades funcionen en les dues configuracions.
