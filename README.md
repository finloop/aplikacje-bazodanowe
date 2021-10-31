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
$ docker-copose up -d
```
