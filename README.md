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
2. Stwórz plik `.env` w folderze  
```bash
$ echo "POSTGRES_PASSWORD=HASLO" > .env
```
3. Uruchom serwer
```bash
$ docker-compose up -d
```

## Łączenie się z bazą:
```
User: postgres
Haslo: takie jak w POSTGRES_PASSWORD
Database: postgres
Adres: localhost
Port: 5432
```

## Administracja
Na porcie `8080` dostępny jest Adminer. Można się z nim połączyć wchodząc na adres [http://localhost:8080](http://localhost:8080)

## Wyłączanie bazy
```
$ docker-compose down 
```
Jeżeli chcesz usunąć dane:
```
docker-compose down -v
```
