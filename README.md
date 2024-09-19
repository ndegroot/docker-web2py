# About this repo
The repo contains the Docker image for the [web2py](http://www.web2py.com/) web framework. See the hub page. 

## Usage:
`docker pull ndegroot/web2py`

For now the image uses the local application files (software and database)

`docker run -p 443:443 -p 80:80 -v my_app:/home/www-data/web2py/applications/webapp ndegroot/web2py`

Based on original docker-web2py for Python 2.7 by acidjunk:
- Changed towards Python 3 
- Added scheduler proces to supervisor
- Contains very broad list of debian python3 packages
- Some packages are pip3 installed 
## Todo:
- Use `git pull` to get the webapp code from a repository and add a mount for the dev database if SQLite to get persistence.
- Add and test internal or external (on the host) PostgreSQL database connections
- Make it possible to run without SSL so setup behind a reversed Nginx Proxy is easier
- Make it possible to add your own Python requirements


---
Inspired by: [thehipbot](https://hub.docker.com/r/thehipbot/web2py/) and [rafs](https://github.com/rafsAcorsi/docker-web2py/)
