# Email Summarizer Backend

This repository contains the backend code for an email automation system powered by AI. The system is designed to automate email processing, summarization, 
and sentiment analysis using machine learning models. It leverages the capabilities of AI to improve email communication efficiency.

## Technologies Used

- Flask: A micro web framework for Python used to create the RESTful API.
- Python: he programming language used for development.
- PostgreSQL: A powerful, open-source object-relational database system.
- Docker: Used for containerizing PostgreSQL to ensure consistent environments.
- Ollama: A tool for running the LLAMA model used in the application.

## Architecture Overview

The application is architected into several components to ensure modularity, scalability, and efficiency:

1. API Layer (Flask): Handles HTTP requests and routes them to appropriate services.
2. Database (PostgreSQL): Stores emails, summaries, and other related data.
3. AI Models: Utilizes models like GPT-4o, LLAMA for various AI tasks such as summarization and sentiment analysis.
4. Cron Jobs: Scheduled tasks that perform background processing of emails, such as sentiment analysis and automated replies.

### Setting up development environment

#### Prerequisites

- Python 3.x
- Docker
- Ollama tool for LLAMA model
- PostgreSQL installed on Docker

#### 0. Creating environment and installing dependencies

```bash
$ python3 -m venv flask_env
$ source flask_env/bin/activate
$ pip3 install -r requirements.txt
```

#### 1. Simply run the start-dev script

Run the following script to start the PostgreSQL container, initialize the database schema, and start the Flask application:

```bash
$ sh ./scripts/start-dev.sh
```
Note: Make sure Docker is running on your machine. If not, download and install Docker [here](https://docs.docker.com/desktop/install/linux/).

### 2. Setting Up LLAMA Model

To use the open-source LLAMA model for AI tasks, ensure you have the Ollama tool installed. Download it [here](https://ollama.com/download). Install the LLAMA model using:

```bash
$ ollama run llama3.2

```

### 3. run the application

Although it's recommended to use `./scripts/start-dev.sh`, you can also start the application manually:

```bash
$ python3 run.py
```

Warning: Using `start-dev.sh` restarts the PostgreSQL container, leading to data loss. Use this method only for initial setup.

### Cron jobs

The application includes several background processes managed by cron jobs to handle ongoing tasks like sentiment analysis:

- Sentiment Analysis: Uses GPT model for analyzing email sentiment.
- Email Summarization: Generates concise summaries for emails.

To run these cron jobs, use the `make` command. For example, to start the sentiment analysis cron job:

```bash
$ make run_sentiment_analysis_gpt
```

These scripts are located in the `cron_job` directory and are designed to run indefinitely, rechecking and processing data every 5 minutes.

### ERD (Entity-Relationship Diagram)

ER-diagram of the DDL schema:

<img src="./erd.svg" />
