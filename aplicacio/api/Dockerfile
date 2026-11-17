# Construcció: Gradle i JDK, com en els exemples d'infraestructura del curs.
FROM gradle:9.7.1-jdk21 AS construccio
# Utilitzem root només per preparar el directori de construcció i assignar-ne el propietari.
# WORKDIR crea la carpeta si no existeix, però no garanteix que pertanga a gradle.
# COPY --chown assigna el contingut copiat; no canvia el propietari de la carpeta de destinació existent.
USER root
RUN mkdir -p /home/gradle/project && chown gradle:gradle /home/gradle/project
WORKDIR /home/gradle/project
# Compilem com a gradle: necessita escriure en .gradle/ i app/build/ dins del projecte.
# Sense els permisos anteriors, la construcció falla en crear la memòria cau fileHashes.
USER gradle
# El context ./api inclou els fonts; .dockerignore exclou les memòries cau i compilacions locals.
COPY --chown=gradle:gradle . .
# installDist prepara el llançador i les biblioteques que copiarem a la imatge final.
RUN gradle --no-daemon :app:installDist

# Execució: sense Gradle, fonts ni permisos root.
FROM eclipse-temurin:21-jre-jammy
# Aquesta etapa és independent: creem un usuari propi per executar el servidor.
RUN groupadd --system healthys && useradd --system --gid healthys --uid 10001 --create-home healthys
WORKDIR /app
COPY --from=construccio --chown=healthys:healthys /home/gradle/project/app/build/install/app/ ./
# El procés Java s’executa sense privilegis root, tant en local com en Coolify.
USER healthys
# Documentem el port intern; Compose o el proxy de Coolify gestionen l’accés des de fora.
EXPOSE 7070
ENTRYPOINT ["/app/bin/app"]
