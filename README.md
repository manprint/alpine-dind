# Alpine image with SSHD, Crontab and Docker

Immagine docker alpine con installati docker, cron e ssh.

## Uso

Uso destinato esclusivamente ai fini di test.
NON UTILIZZARE IN PRODUZIONE!

### Prerequisiti

- Make deve essere installato sulla macchina host
  `sudo apt install make`

### Avvio rapido privilegiato

```
docker run -d \
	--name=dind-env \
	--hostname=alpine \
	--privileged=true \
	--publish=2375:2375/tcp \
	--publish=2255:22/tcp \
	ghcr.io/manprint/alpine-dind:latest
```
### Avvio rapido non privilegiato (sysbox)

Per utilizzare il runtime sysbox è necessario installarlo seguendo le istruzioni della pagina dello sviluppatore:
Nota bene: installare la release `v0.5.0` (https://github.com/nestybox/sysbox/releases)

- https://github.com/nestybox/sysbox
- https://github.com/nestybox/sysbox/blob/master/docs/user-guide/install-package.md

```
docker run -d \
	--name=dind-env \
	--hostname=alpine \
	--runtime=sysbox-runc \
	--publish=2375:2375/tcp \
	--publish=2255:22/tcp \
	ghcr.io/manprint/alpine-dind:latest
```

### Gestione container tramite makefile

Per comodità, è stato creato un makefile per eseguire i task di avvio, stop, etc. del container.
Per utilizzare il makefile seguire le istruzioni seguenti:

- Creare una cartella di lavoro, ad esempio `~/dind-env` ed entrare nella cartella
- Scaricare il makefile tramite il seguente comando:
  `curl -sSL https://raw.githubusercontent.com/manprint/alpine-dind/develop/Makefile -o Makefile`
- Eseguire il comando `make` per vedere i task disponibili
- Modificare il makefile se è necessario secondo le proprie esigenze (ad esempio per aggiungere la persistenza o inserire una network)

## Persistenza

Volume configurato: `/var/lib/docker`

### Persistenza docker

Si consiglia per la persistenza della directory di docker di utilizzare un `named volume`. La riga da aggiungere all'avvio rapido ed al makefile è la seguente:

```
--volume=docker_alpine_volume:/var/lib/docker \
```

### Persistenza home

Per la persistenza della cartella home dell'utente alpine (utente predefinito, UID=1000, GID=1000 all'interno del container) utilizzare un `binded volume`. Le istruzioni e la riga da aggiungere al makefile ed all'avvio rapido sono le seguenti:

- Creazione cartella locale (sostituire user con il proprio utente o specificare un path specifico):
  
```
mkidir /home/<user>/home_alpine_volume
```

- Comando da aggiungere all'avvio rapido oppure al makefile (sostituire user con il proprio utente o specificare un path specifico):

```
--volume=/home/<user>/home_alpine_volume:/home/alpine
```