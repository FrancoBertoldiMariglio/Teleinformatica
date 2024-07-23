# Enunciado

Este práctico se trata de una implementación de un servidor de metabase, junto con una base de datos MySQL y un Ingress 
Nginx. Toda esta implementación esta hecha sobre un cluster kubernetes.

# Como correrlo

Para hacerlo funcionar, simplemente debemos descomprimir la carpeta, hacer cd a la carpeta descomprimida y vamos a ver que hay distintos directorios:

- config-maps: en este directorio estan los ConfigMaps
- net-policies: en este directorio estan los NetworkPolicies
- secrets: en este directorio estan los Secrets
- services: en este directorio estan los Services

Luego, tenemos que hacer cd a cada una de los directorios mencioandos y hacer **kubectl**. Por último, tenemos que volver al 
directorio principal (caso_practico_3) y hacer **kubectl**.

Para poder acceder al servicio, debemos listar alguna de las IPs de los nodos del cluster (con kubectl get node) y escribir en el buscador:
**<ip-nodo/metabase**.
