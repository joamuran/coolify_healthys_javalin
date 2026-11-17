plugins { application }
repositories { mavenCentral() }
dependencies {
    // Javalin incorpora el servidor HTTP Jetty; no cal instal·lar Tomcat.
    implementation("io.javalin:javalin:7.2.4")
    // Conservem el connector i Jackson 3, que ja hem utilitzat en les unitats anteriors.
    implementation("org.postgresql:postgresql:42.7.14")
    implementation("tools.jackson.core:jackson-databind:3.2.3")
    // Implementació senzilla de registre per als missatges de Javalin i Jetty.
    runtimeOnly("org.slf4j:slf4j-simple:2.0.17")
}
java { toolchain { languageVersion = JavaLanguageVersion.of(21) } }
application { mainClass = "com.ieseljust.ad.healthys.App" }
