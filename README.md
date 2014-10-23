Docker-based PowerDNS Slave with Supermaster Support
====================================================

This is a simple Docker container, based on CentOS 7 which runs a PowerDNS slave. It also contains support for configuring upstream 'supermaster' servers, which will automatically provision the slave domain on the PowerDNS server.

Configuration
-------------

PowerDNS is configured to use the "bind" zonefile backend, zonefiles and configuration are located in `/zones` within the container. It is expected that you would mount this volume from your Docker host to provide persistent configuration.

### Configuring Slave Zones ###

Edit `zones/cfg/named-zones.conf` and add your slave zone configuration, for example:

    $ cat zones/cfg/named-zones.conf
    zone "example.com" IN {
        type slave;
        file "example.com.zone";
        masters { 192.0.2.1; };
    };

*Note:* Only `type slave` zones are supported - the PowerDNS daemon has master mode disabled in this container.

### Configuring Supermasters ###

PowerDNS supports the concept of a "Supermaster" server. If a PowerDNS slave receives a notify from a server on the supermaster list, and the slave does not have an existing configuration for the notified zone, it will be automatically created.

The zone file for the new zone will be placed in to `/zones`, and the configuration file `/zones/cfg/named-superslave.conf` will be automatically updated by PowerDNS. This file must not be manually edited.

To configure your supermaster servers (if required), add an entry (one per line) to `zones/cfg/supermasters.conf`, for example:

    $ cat zones/cfg/supermasters.conf
    # IP         Name/comment
    192.0.2.1    ns1

The name/comment will be displayed in the logs, and written to the `named-superslave.conf` file when a new zone is added as the result of a NOTIFY from a supermaster server.

### Configuring PowerDNS ###

The configuration files for PowerDNS live in the `pdns/` directory of this repository. If these files are changed, you will need to rebuild the Docker image, as per the instructions below.

Installation
------------

Configure the appropriate files in your `zones/` directory as per the information above. Make any changes to the PowerDNS server configuration in `pdns/`, if required.

Build the Docker image as follows:

    $ cd docker-pdns-slave
    $ docker build -t pdns-slave .

Start the container:

    $ docker run -d -v /path/to/docker-pdns-slave/zones:/zones -p 53:53/udp -p 53:53/tcp pdns-slave

The command above will map port 53 (TCP and UDP) to port 53 on the Docker host. If this is not what you want, adjust the command above to suit.

PowerDNS provides it's own "guardian" instance, so should restart in the event of failure.
