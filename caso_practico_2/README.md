# Enunciado

Este practico se trata de una implementación de un servidor de metabase, junto con una base de datos MySQL, un LoadBalancer Nginx y un Bastion para poder acceder a todas las máquinas virtuales.

# Como correrlo

Para hacerlo funcionar, simplemente debemos descomprimir la carpeta, hacer cd a la carpeta descomprimida y hacer **tofu apply**. Todo está orquestado en los template file para que la conexión entre la base de datos y el metabase sea automática junto con la generacion del dashboard y la pregunta.

Para poder acceder al servicio, debemos buscar la IP flotante del LoadBalancer y escribirla en el buscador.
