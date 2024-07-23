# Enunciado

Este practico se trata de una implementacion de un servidor de metabase, junto con una base de datos MySQL, un LoadBalancer Nginx y un Bastion para poder acceder a todas las maquinas virtuales.

# Como correrlo

Para hacerlo funcionar, simplemente debemos descomprimir la carpeta, hacer cd a la carpeta descomrpimida y hacer **tofu apply**. Todo esta orquestado en los template file para que la conexion entre la base de datos y el metabase sea automatica junto con la generacion del dashboard y la pregunta.
