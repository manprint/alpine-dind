# Alpine image with SSHD, Crontab and Docker

Immagine docker alpine con installati docker, cron e ssh.

## Uso

Uso destinato esclusivamente alla creazione di ambienti di test, pipeline, ci/cd, etc.

**NON UTILIZZARE IN PRODUZIONE!**

### Prerequisiti

- Se si usa il comando rapido, l'immagine non ha prerequisiti.
- Make deve essere installato sulla macchina host per poter utilizzare il makefile
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
- Scaricare il makefile (versione Lite, senza i task di test e push) tramite il seguente comando:
  `curl -sSL https://raw.githubusercontent.com/manprint/alpine-dind/develop/MakefileLite -o Makefile`
- Eseguire il comando `make` per vedere i task disponibili
- Modificare il makefile se è necessario secondo le proprie esigenze (ad esempio per aggiungere la persistenza o inserire una network)

**Nota bene**: nel caso si voglia sviluppare o modificare le funzionalità, clonare il repo: `git clone https://github.com/manprint/alpine-dind.git`

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
export USER=user
mkdir /home/$USER/home_alpine_volume && chown -R 1000:1000 /home/$USER/home_alpine_volume
```

- Comando da aggiungere all'avvio rapido oppure al makefile (sostituire user con il proprio utente o specificare un path specifico):

```
--volume=/home/$USER/home_alpine_volume:/home/alpine
```