# Usar Tomcat 10 (Jakarta EE 9 / Servlet 5) o Tomcat 9 (javax.servlet)
# El proyecto usa javax.servlet (web.xml 4.0), así que Tomcat 9 es más seguro.
FROM tomcat:9.0-jdk11-temurin

# Metadatos
LABEL maintainer="UTS Ingenieria de Sistemas"
LABEL description="Sistema de Gestion de Trabajos de Grado"

# Eliminar apps por defecto de Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copiar driver MySQL (el que ya usas en XAMPP)
# Descargamos la versión exacta que tienes en lib para evitar incompatibilidades
RUN curl -fL "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.3.0/mysql-connector-j-8.3.0.jar" \
    -o /usr/local/tomcat/lib/mysql-connector-j-8.3.0.jar

# Copiar la aplicación web a ROOT para que esté en la raíz /
COPY . /usr/local/tomcat/webapps/ROOT/

# Exponer puerto 8080
EXPOSE 8080

# Comando por defecto (ya viene en la imagen base)
CMD ["catalina.sh", "run"]