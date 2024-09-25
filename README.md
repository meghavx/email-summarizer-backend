# email-summarizer-backend

> Flask
> Python
> PostgreSQL


### Instructions

#### Creating environment and installing dependencies

```
$ python3 -m venv flask_env
$ source flask_env/bin/activate
$ pip3 install flask flask_sqlalchemy psycopg2 flask-cors
```

#### Setting up postgres

```
$ docker run \
                --name email_summarizer_db \
                -e POSTGRES_PASSWORD=qwerty \
                -e POSTGRES_USER=ruchita \
                -e POSTGRES_DB=poc \
                -p 5432:5432 \
                --rm -d \
                postgres:16.3-alpine3.20
```

```
$ docker exec -it email_summarizer_db psql -U ruchita -d poc
$ psql (16.3)
Type "help" for help.

poc=# 

```

### to run the application

```bash
$ python3 app.py
```