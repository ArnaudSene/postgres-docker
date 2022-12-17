# Install Postgres SQL object-relational database system on Docker

[Postgres Docker source](https://github.com/docker-library/docs/blob/master/postgres/README.md)

## Prepare your environment

### Docker
`Docker` and `docker compose` must be installed on the server in order to install and start Postgres system. 

- docker installed [Install Docker Engine](https://docs.docker.com/engine/install/)
- docker-compose installed [Install Docker Compose](https://docs.docker.com/compose/install/)

### Postgres configuration 
Edit the `.env` file with required values.

```dotenv
POSTGRES_USER=postgres
POSTGRES_PASSWORD="pg password"
POSTGRES_DB="database name"
PGADMIN_DEFAULT_EMAIL="a valid email"
PGADMIN_DEFAULT_PASSWORD="pgadmin password"
```

## Install & start Postgres container
The script will configure the environment, create and start containers.

```shell
bash start-postgres.sh
```

## Connect to pgadmin
### Retrieve the pgadmin IP address.

On the server run the following command
```shell
docker inspect postgres-docker-pgadmin-1|grep IPAddress|cut -d":" -f2|tail -1
```

### Open the pgadmin web GUI
Through a web browser enter the url to pgadmin with the IP address retrieve before.

> e.g: with IP address = 10.0.0.1
> 
> http://10.0.0.1:5433/

Use the credentials defined in the .env

> PGADMIN_DEFAULT_EMAIL="a valid email"
> 
> PGADMIN_DEFAULT_PASSWORD="pgadmin password"


### Add New Server
#### General
> server name: e.g: server_poc

![](img/pgadmin-tab-general-server-name.png)

#### Connection
> hostname: postgres-docker-database-1
>  
> username: postgres
>  
> password: in file `.env` *POSTGRES_PASSWORD*

![](img/pgadmin-tab-connection.png)