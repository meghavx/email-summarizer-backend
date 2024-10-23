# email-summarizer-backend

> Flask
> Python
> PostgreSQL


### Instructions

#### Creating environment and installing dependencies

```
$ python3 -m venv flask_env
$ source flask_env/bin/activate
$ pip3 install -r requirements.txt
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
### To Setup LLAMA Model 

Download the tool from [here](https://ollama.com)

We have used llama3.2. To install that version use following command :

```
$ ollama run llama3.2

```

### to run the application

```bash
$ python3 run.py
```

To run sentiment analysis:

$ make run_sentiment_analysis_gpt