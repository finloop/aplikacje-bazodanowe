# aplikacje-bazodanowe
## Jak uruchomić?
Wymagania:
- Docker 
- Docker compose

1. Sklonuj repozytorium
```bash
$ git clone git@github.com:finloop/aplikacje-bazodanowe.git
$ cd aplikacje-bazodanowe
```
2. Uruchom serwer
```bash
$ docker-compose up -d
```

## Łączenie się z bazą:
```
User: postgres
Haslo: takie jak w POSTGRES_PASSWORD (patrz plik .env)
Database: postgres
Adres: localhost
Port: 5432
```

## Administracja
Na porcie `80` dostępny jest pgAdmin. Można się z nim połączyć wchodząc na adres [http://localhost:80](http://localhost:80)

## Wyłączanie bazy
```
$ docker-compose down 
```
Jeżeli chcesz usunąć dane:
```
docker-compose down -v
```
